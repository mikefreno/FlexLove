-- modules/behaviors/Imageable.lua
--
-- Concrete behavior: image loading + image rendering config.
--
-- Imageable owns the image side of the Renderer: it enriches the shared
-- `element._renderer` with image config (imagePath/image/objectFit/...), runs
-- the deferred image-load pipeline (cache check → defer → load → fire
-- onImageLoad/onImageError callbacks), and persists the loaded-image cache
-- across immediate-mode recreation. It is the behavior-mode-unification
-- replacement for the image-loading half of Element:_initImageAndRenderer and
-- the deferred Element:_loadImage method (behavior-mode-unification task 07).
--
-- Attachment rule (shouldAttach): an element owns image concern exactly when it
-- declares an `imagePath` (load-from-path) or a direct `image` (already-loaded
-- love.Image). Mirrors the old `if self.imagePath / if self.image` init branches.
--
-- Pairing with Themed: Themed.onAttach creates the Renderer with theme/blur
-- config; Imageable.onAttach enriches the SAME renderer instance with image
-- config + kicks off loading. They share `element._renderer`. In the registry
-- Imageable runs after Themed, so the renderer already exists; the create-or-
-- reuse guard below covers the defensive case where Imageable attaches first.
--
-- onDraw: the image LAYER is rendered by the integrated `Renderer:draw` call
-- (owned by the Themed behavior) which executes the renderer's `image` draw
-- command using the config Imageable.onAttach wired. Imageable.onDraw is
-- therefore a no-op for the draw call itself — there is no separate
-- `_renderer:_drawImage` entry point; pixel emission lives in the integrated
-- Renderer:draw command buffer. Splitting it out would require Renderer surgery
-- with no behavioral gain (Renderer:draw already conditionally skips the image
-- layer when no image is loaded).
--
-- State ownership (per the locked Behavior contract):
--   * Per-element runtime state lives ON THE ELEMENT (`element._loadedImage`,
--     `element._renderer._loadedImage`). The behavior instance is stateless.
--   * saveState/restoreState persist `_loadedImage` across immediate-mode frames
--     so the image renders even if the ImageCache is cleared between frames and
--     so the renderer's loaded-image cache survives element recreation.

local _pkg = (...):match("^(.-)behaviors%.") or "modules."
local Behavior = require(_pkg .. "Behavior")

-- Lua 5.4 removed the global `unpack`; mirror Element's alias.
local unpack = table.unpack or unpack

-- Resolve the Element class from an element instance (mirrors Clickable/Themed).
local function ElementClass(element)
  return getmetatable(element)
end

-- ----------------------------------------------------------------------------
-- shouldAttach (class-level predicate, no element required)
-- ----------------------------------------------------------------------------

local function shouldAttach(props)
  props = props or {}
  return props.imagePath ~= nil or props.image ~= nil
end

-- ----------------------------------------------------------------------------
-- Image callback helper (moved from Element._fireImageCallback).
-- Fires a user-supplied image callback (onImageLoad/onImageError) under pcall,
-- honoring the onXDeferred flag when `honorDeferred` is true, and emits a single
-- EVT_002 warn on failure. The direct-`image` sync init path passes
-- honorDeferred=false to preserve immediate firing (image is already loaded).
-- ----------------------------------------------------------------------------

local function fireImageCallback(element, callbackField, honorDeferred, ...)
  local cb = element[callbackField]
  if type(cb) ~= "function" then
    return
  end
  local Element = ElementClass(element)
  local argc = select("#", ...)
  local args = { ... }
  local function invoke()
    local ok, err = pcall(cb, element, unpack(args, 1, argc))
    if not ok then
      Element._ErrorHandler:warn("Element", "EVT_002", {
        callback = callbackField,
        error = tostring(err),
      })
    end
  end
  if honorDeferred and element[callbackField .. "Deferred"] then
    Element._Context.deferCallback(invoke)
  else
    invoke()
  end
end

-- ----------------------------------------------------------------------------
-- Deferred image loader (replaces Element:_loadImage).
--
-- Invoked by Element's deferred-method dispatcher via the instance closure that
-- onAttach installs on `element._loadImage`. Loads the image from cache or disk
-- (I/O), updates BOTH the element and renderer `_loadedImage` caches so the
-- image draws after an async load, and fires the load/error callback (deferred,
-- honoring onImageLoadDeferred / onImageErrorDeferred).
-- ----------------------------------------------------------------------------

local function loadImage(element)
  if not element.imagePath or element.image then
    return
  end
  local Element = ElementClass(element)
  local loadedImage, err = Element._ImageCache.load(element.imagePath)
  if loadedImage then
    element._loadedImage = loadedImage
    if element._renderer then
      element._renderer._loadedImage = loadedImage
    end
    fireImageCallback(element, "onImageLoad", true, loadedImage)
  else
    fireImageCallback(element, "onImageError", true, err or "Unknown error")
  end
end

-- ----------------------------------------------------------------------------
-- onAttach — enrich the shared renderer with image config + kick off loading
-- (formerly the image block of Element:_initImageAndRenderer).
-- ----------------------------------------------------------------------------

local function onAttach(element)
  local Element = ElementClass(element)

  -- Ensure the renderer exists (Thamed normally creates it; this create-or-reuse
  -- guard is defensive for the Imageable-attaches-first ordering). Image config
  -- is then written onto the shared renderer instance.
  if not element._renderer then
    element._renderer = Element._Renderer.new({
      theme = element.theme,
      scaleCorners = element.scaleCorners,
      scalingAlgorithm = element.scalingAlgorithm,
      contentBlur = element.contentBlur,
      backdropBlur = element.backdropBlur,
    }, Element._rendererDeps)
  end

  local renderer = element._renderer
  -- Image config (imagePath/image/objectFit/objectPosition/imageOpacity/
  -- imageRepeat/imageTint are bound on the element by _applyProps; mirror them
  -- onto the renderer which owns the image draw layer).
  renderer.imagePath = element.imagePath
  renderer.image = element.image
  renderer.objectFit = element.objectFit
  renderer.objectPosition = element.objectPosition
  renderer.imageOpacity = element.imageOpacity
  renderer.imageRepeat = element.imageRepeat
  renderer.imageTint = element.imageTint

  -- Image load pipeline (formerly Element:_initImageAndRenderer image block).
  if element.imagePath and not element.image then
    -- Cache check (no I/O). Populate both caches immediately if cached so the
    -- image can draw this frame without waiting for the deferred load.
    element._loadedImage = Element._ImageCache.get(element.imagePath)
    renderer._loadedImage = element._loadedImage
    -- Install the deferred loader as an instance method so Element's
    -- deferred-method dispatcher (which resolves `self[methodName]`) can invoke
    -- the behavior's loader without Element needing a behavior reference. This
    -- keeps Element decoupled from the Imageable behavior (mirrors the
    -- stateless-behavior + element-owned-state contract).
    element._loadImage = function(el)
      loadImage(el)
    end
    -- Defer the actual I/O + callbacks (avoids I/O / callbacks in constructor).
    element:_deferMethod("_loadImage")
  elseif element.image then
    -- Direct image prop (already loaded): set immediately and fire synchronously.
    element._loadedImage = element.image
    renderer._loadedImage = element.image
    fireImageCallback(element, "onImageLoad", false, element.image)
  else
    element._loadedImage = nil
  end
end

-- ----------------------------------------------------------------------------
-- onDraw — no-op (see file header: the image layer is rendered by the integrated
-- Renderer:draw call owned by the Themed behavior, using the config wired here).
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- saveState / restoreState — `_loadedImage` cache (for immediate-mode).
-- ----------------------------------------------------------------------------

local function saveState(element)
  if element._loadedImage ~= nil then
    return { _loadedImage = element._loadedImage }
  end
  return nil
end

local function restoreState(element, state)
  if not state or state._loadedImage == nil then
    return nil
  end
  local loadedImage = state._loadedImage
  element._loadedImage = loadedImage
  if element._renderer then
    element._renderer._loadedImage = loadedImage
  end
  return nil
end

-- ----------------------------------------------------------------------------
-- onDetach — release image-load callback closures so the element can be GC'd
-- cleanly in immediate mode (formerly part of Element:_cleanup). The cached
-- `_loadedImage` is reproduced on the next attach via the Imageable saveState
-- -> restoreState cycle, so dropping the live references is always safe.
-- ----------------------------------------------------------------------------

local function onDetach(element)
  element.onImageLoad = nil
  element.onImageError = nil
end

-- ----------------------------------------------------------------------------
-- Build the (stateless, shared, immutable) behavior instance.
-- ----------------------------------------------------------------------------

local Imageable = Behavior.new({
  onAttach = onAttach,
  onDetach = onDetach,
  onUpdate = function() end,
  onDraw = function() end,
  saveState = saveState,
  restoreState = restoreState,
  shouldAttach = shouldAttach,
})

-- Expose the predicate at module level so callers/tests can reference it
-- directly without an element instance (mirrors Behavior.shouldAttach /
-- Clickable.shouldAttach). `loadImage` is NOT exposed on the (frozen) behavior
-- instance; it is captured as a module-local upvalue by the onAttach closure that
-- installs `element._loadImage`.
Imageable.shouldAttach = shouldAttach

return Imageable
