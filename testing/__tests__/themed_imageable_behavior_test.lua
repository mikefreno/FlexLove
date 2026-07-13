-- Unit + integration tests for modules/behaviors/Themed + Imageable (task 07).
--
-- Validates the concrete behaviors extracted from Element:_initImageAndRenderer /
-- Element:draw / Element:_loadImage: Themed owns the Renderer + the single
-- Renderer:draw call; Imageable owns image config + deferred image loading +
-- _loadedImage persistence.
--
-- Coverage:
--   * shouldAttach predicates (spec acceptance cases + behavior-preservation)
--   * Behavior interface conformance (Behavior instance, all 6 hooks present)
--   * Themed integration — every element gets a Renderer (always-attach render
--     surface behavior); Renderer:draw dispatched via behavior onDraw.
--   * Imageable integration — image elements get image config on the renderer,
--     deferred load pipeline fires onImageLoad/onImageError, _loadedImage
--     cached + persisted across saveState/restoreState.

package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local Behavior = require("modules.Behavior")
local Themed = require("modules.behaviors.Themed")
local Imageable = require("modules.behaviors.Imageable")
local ImageCache = require("modules.ImageCache")
local FlexLove = require("FlexLove")

-- ============================================================================
-- Themed.shouldAttach (predicate)
-- ============================================================================

TestThemedShouldAttach = {}

function TestThemedShouldAttach:testThemeComponent_Attaches()
  -- Spec acceptance case: Themed.shouldAttach({themeComponent = "button"}) -> true
  luaunit.assertTrue(Themed.shouldAttach({ themeComponent = "button" }))
end

function TestThemedShouldAttach:testEveryRenderableElement_Attaches()
  -- Themed is the universal render-surface behavior: the pre-refactor code
  -- created a Renderer for EVERY element and called Renderer:draw for every
  -- element. Themed mirrors that invariant (editable text fields / scrollable
  -- containers need the Renderer for subsystem delegation even without a theme
  -- component). So shouldAttach is true for plain elements too.
  luaunit.assertTrue(Themed.shouldAttach({}))
  luaunit.assertTrue(Themed.shouldAttach({ width = 100, height = 50 }))
  luaunit.assertTrue(Themed.shouldAttach({ text = "label" }))
  luaunit.assertTrue(Themed.shouldAttach({ editable = true }))
  luaunit.assertTrue(Themed.shouldAttach(nil))
end

-- ============================================================================
-- Imageable.shouldAttach (predicate)
-- ============================================================================

TestImageableShouldAttach = {}

function TestImageableShouldAttach:testImagePath_Attaches()
  -- Spec acceptance case: Imageable.shouldAttach({imagePath = "x.png"}) -> true
  luaunit.assertTrue(Imageable.shouldAttach({ imagePath = "x.png" }))
end

function TestImageableShouldAttach:testDirectImage_Attaches()
  local mockImg = {
    getDimensions = function()
      return 10, 10
    end,
  }
  luaunit.assertTrue(Imageable.shouldAttach({ image = mockImg }))
end

function TestImageableShouldAttach:testNoImage_DoesNotAttach()
  luaunit.assertFalse(Imageable.shouldAttach({}))
  luaunit.assertFalse(Imageable.shouldAttach({ themeComponent = "button" }))
  luaunit.assertFalse(Imageable.shouldAttach({ width = 100, height = 50 }))
  luaunit.assertFalse(Imageable.shouldAttach(nil))
end

-- ============================================================================
-- Behavior interface conformance
-- ============================================================================

TestThemedImageableInterface = {}

function TestThemedImageableInterface:testBothAreBehaviorInstances()
  luaunit.assertTrue(Behavior.isBehavior(Themed))
  luaunit.assertTrue(Behavior.isBehavior(Imageable))
end

function TestThemedImageableInterface:testBothExposeAllLifecycleHooks()
  for _, b in ipairs({ Themed, Imageable }) do
    for _, hook in ipairs(Behavior.HOOK_NAMES) do
      luaunit.assertEquals(type(b[hook]), "function", hook .. " must be a function")
    end
    luaunit.assertEquals(type(b.shouldAttach), "function")
  end
end

function TestThemedImageableInterface:testHooksCallableWithoutError()
  -- Hooks must be safe to invoke on a constructed element (no-op-safe).
  local el = FlexLove.new({ id = "themedimg-iface", width = 10, height = 10 })
  for _, b in ipairs(el.behaviors) do
    b.onUpdate(el, 0)
    b.onDraw(el, { backdropCanvas = nil })
    b.saveState(el)
    b.restoreState(el, {})
    luaunit.assertTrue(true)
  end
end

-- ============================================================================
-- Themed integration: Renderer ownership + Renderer:draw dispatch
-- ============================================================================

TestThemedIntegration = {}

function TestThemedIntegration:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestThemedIntegration:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestThemedIntegration:testEveryElement_GetsRendererViaThemed()
  -- A plain element (no themeComponent / image) still gets a Renderer because
  -- Thamed always-attaches and creates it in onAttach.
  local el = FlexLove.new({ id = "themed-plain", width = 100, height = 50 })
  luaunit.assertNotNil(el._renderer, "Thamed.onAttach must create the Renderer")

  local themedAttached = false
  for _, b in ipairs(el.behaviors) do
    if b == Themed then
      themedAttached = true
      break
    end
  end
  luaunit.assertTrue(themedAttached, "Thamed must be attached to a plain element")
end

function TestThemedIntegration:testThemedElement_RendererHasThemeConfig()
  local el = FlexLove.new({ id = "themed-themed", width = 100, height = 50, themeComponent = "button" })
  luaunit.assertNotNil(el._renderer)
  luaunit.assertEquals(el._renderer.theme, el.theme)
  luaunit.assertEquals(el._renderer.scaleCorners, el.scaleCorners)
  luaunit.assertEquals(el._renderer.scalingAlgorithm, el.scalingAlgorithm)
end

function TestThemedIntegration:testDraw_NoErrorForPlainAndThemedElements()
  -- Renderer:draw is now dispatched via Thamed.onDraw (behavior iteration); the
  -- standalone Element:draw core call was removed. Drawing must still work for
  -- plain and themed elements without error.
  local plain = FlexLove.new({ id = "themed-draw-plain", width = 50, height = 50 })
  local themed = FlexLove.new({ id = "themed-draw-themed", width = 50, height = 50, themeComponent = "button" })
  plain:draw()
  themed:draw()
  luaunit.assertTrue(true)
end

-- ============================================================================
-- Imageable integration: image config + deferred load pipeline
-- ============================================================================

TestImageableIntegration = {}

function TestImageableIntegration:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
  ImageCache.clear()
end

function TestImageableIntegration:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
  ImageCache.clear()
end

local function makeMockImage()
  local img = {}
  img.getDimensions = function()
    return 50, 50
  end
  img.release = function() end
  return img
end

function TestImageableIntegration:testImageElement_AttachesImageableAndConfiguresRenderer()
  local el = FlexLove.new({ id = "img-attach", width = 100, height = 100, imagePath = "test/x.png" })
  local imageableAttached = false
  for _, b in ipairs(el.behaviors) do
    if b == Imageable then
      imageableAttached = true
      break
    end
  end
  luaunit.assertTrue(imageableAttached, "image element must attach the Imageable behavior")
  -- Image value props live on the ELEMENT as source of truth (read at draw
  -- time); Imageable no longer mirrors them onto the renderer. Only the
  -- resolved _loadedImage cache is renderer-mirrored. Assert the source-of-
  -- truth contract directly.
  luaunit.assertEquals(el.imagePath, "test/x.png")
  luaunit.assertEquals(el.objectFit, "fill")
  luaunit.assertEquals(el.imageOpacity, 1)
  luaunit.assertNotNil(el._loadImage, "Imageable must install the deferred _loadImage hook")
  luaunit.assertNotNil(el._reloadImage, "Imageable must install the _reloadImage hook")
end

function TestImageableIntegration:testCachedImage_LoadsImmediatelyAndDeferredCallback()
  -- Mirrors deferred_image_loading_test: cache pre-populated → _loadedImage set
  -- immediately on both element + renderer; onImageLoad fires AFTER update.
  local mockImage = makeMockImage()
  ImageCache._cache["test/cached.png"] = { image = mockImage, imageData = nil }

  local onLoadCalled = false
  local el = FlexLove.new({
    id = "img-cached",
    width = 100,
    height = 100,
    imagePath = "test/cached.png",
    onImageLoad = function()
      onLoadCalled = true
    end,
  })
  luaunit.assertFalse(onLoadCalled, "onImageLoad must not fire in constructor")
  -- Cache hit populates both caches immediately so the image can draw now.
  luaunit.assertEquals(el._loadedImage, mockImage)
  luaunit.assertEquals(el._renderer._loadedImage, mockImage)

  el:update(0)
  luaunit.assertTrue(onLoadCalled, "onImageLoad must fire after update (deferred load)")
end

function TestImageableIntegration:testNonCachedImage_ErrorFiresAfterUpdate()
  local onErrorCalled = false
  local el = FlexLove.new({
    id = "img-error",
    width = 100,
    height = 100,
    imagePath = "nonexistent/bad.png",
    onImageError = function()
      onErrorCalled = true
    end,
  })
  luaunit.assertFalse(onErrorCalled, "onImageError must not fire in constructor")
  el:update(0)
  luaunit.assertTrue(onErrorCalled, "onImageError must fire after update for a bad path")
end

function TestImageableIntegration:testDirectImage_LoadsSynchronouslyAndFires()
  local mockImage = makeMockImage()
  local onLoadCalled = false
  local el = FlexLove.new({
    id = "img-direct",
    width = 100,
    height = 100,
    image = mockImage,
    onImageLoad = function(_, img)
      onLoadCalled = true
    end,
  })
  luaunit.assertTrue(onLoadCalled, "direct image must fire onImageLoad synchronously in constructor")
  luaunit.assertEquals(el._loadedImage, mockImage)
  luaunit.assertEquals(el._renderer._loadedImage, mockImage)
end

function TestImageableIntegration:testSaveRestoreState_RoundTripsLoadedImage()
  -- Imageable.saveState/restoreState persist _loadedImage across the
  -- immediate-mode recreation cycle.
  local mockImage = makeMockImage()
  local el1 = FlexLove.new({
    id = "img-sr",
    width = 100,
    height = 100,
    image = mockImage, -- direct image populates _loadedImage synchronously
  })
  luaunit.assertEquals(el1._loadedImage, mockImage)

  local snapshot = el1:saveState()
  luaunit.assertNotNil(snapshot)
  luaunit.assertEquals(snapshot._loadedImage, mockImage)

  -- Fresh image element without a pre-loaded image; restore re-populates it.
  local el2 = FlexLove.new({ id = "img-sr2", width = 100, height = 100, imagePath = "test/sr.png" })
  el2._loadedImage = nil
  if el2._renderer then
    el2._renderer._loadedImage = nil
  end
  el2:restoreState(snapshot)
  luaunit.assertEquals(el2._loadedImage, mockImage, "restoreState must reapply _loadedImage")
  luaunit.assertEquals(el2._renderer._loadedImage, mockImage, "restoreState must sync renderer._loadedImage")
end

-- ===========================================================================
-- setProperty(imagePath / image) reload pipeline
--
-- setProperty must re-run the Imageable load pipeline so changing an image at
-- runtime actually swaps what draws. Direct `image` wins over `imagePath`; nil
-- for both clears the cache. Mirrors the consistency contract for visual props.
-- (Added alongside wiring imagePath/image into Element._specialSetHandlers.)
-- ===========================================================================

function TestImageableIntegration:test_setProperty_imagePath_swaps_loaded_image_deferred()
  -- Start with a cached image A, then setProperty("imagePath", B-path) where B
  -- is also cached: cache check populates _loadedImage immediately (B), the
  -- deferred load fires onImageLoad for B after update.
  local imgA = makeMockImage()
  local imgB = makeMockImage()
  ImageCache._cache["path/a.png"] = { image = imgA, imageData = nil }
  ImageCache._cache["path/b.png"] = { image = imgB, imageData = nil }

  local loaded = nil
  local onLoadCalls = 0
  local el = FlexLove.new({
    id = "img-swap-path",
    width = 100,
    height = 100,
    imagePath = "path/a.png",
    onImageLoad = function(_, img)
      onLoadCalls = onLoadCalls + 1
      loaded = img
    end,
  })
  -- initial cache check populated A immediately
  luaunit.assertEquals(el._loadedImage, imgA, "initial cache check should populate imgA")

  el:setProperty("imagePath", "path/b.png")
  luaunit.assertEquals(el.imagePath, "path/b.png")
  luaunit.assertEquals(el._loadedImage, imgB, "setProperty(imagePath) cache-check must swap _loadedImage immediately")
  luaunit.assertEquals(el._renderer._loadedImage, imgB, "renderer cache must mirror the swapped image")

  el:update(0)
  luaunit.assertTrue(onLoadCalls >= 1, "deferred onImageLoad must fire for the new path")
  luaunit.assertEquals(loaded, imgB, "onImageLoad must deliver the new image")

  ImageCache._cache["path/a.png"] = nil
  ImageCache._cache["path/b.png"] = nil
end

function TestImageableIntegration:test_setProperty_image_direct_swaps_synchronously()
  local imgA = makeMockImage()
  local direct = makeMockImage()
  ImageCache._cache["path/direct.png"] = { image = imgA, imageData = nil }

  local loaded = nil
  local onLoadCalls = 0
  local el = FlexLove.new({
    id = "img-swap-direct",
    width = 100,
    height = 100,
    imagePath = "path/direct.png",
    onImageLoad = function(_, img)
      onLoadCalls = onLoadCalls + 1
      loaded = img
    end,
  })
  luaunit.assertEquals(el._loadedImage, imgA)

  -- Setting a direct image takes precedence over imagePath and fires sync.
  el:setProperty("image", direct)
  luaunit.assertEquals(el.image, direct)
  luaunit.assertEquals(el._loadedImage, direct, "direct image via setProperty must win over imagePath")
  luaunit.assertEquals(el._renderer._loadedImage, direct)
  luaunit.assertTrue(onLoadCalls >= 1, "direct image must fire onImageLoad synchronously")
  luaunit.assertEquals(loaded, direct)

  ImageCache._cache["path/direct.png"] = nil
end

function TestImageableIntegration:test_setProperty_image_nil_falls_back_to_imagePath()
  local direct = makeMockImage()
  local cached = makeMockImage()
  ImageCache._cache["path/fallback.png"] = { image = cached, imageData = nil }

  local el = FlexLove.new({
    id = "img-fallback",
    width = 100,
    height = 100,
    image = direct,
    imagePath = "path/fallback.png",
  })
  luaunit.assertEquals(el._loadedImage, direct, "direct image wins at construction")

  -- Clearing the direct image falls back to the path load pipeline.
  el:setProperty("image", nil)
  luaunit.assertNil(el.image)
  luaunit.assertEquals(el._loadedImage, cached, "clearing image must fall back to imagePath cache check")
  luaunit.assertEquals(el._renderer._loadedImage, cached)

  ImageCache._cache["path/fallback.png"] = nil
end

function TestImageableIntegration:test_setProperty_clears_loadedImage_when_both_nil()
  local direct = makeMockImage()
  local el = FlexLove.new({
    id = "img-clear",
    width = 100,
    height = 100,
    image = direct,
  })
  luaunit.assertEquals(el._loadedImage, direct)

  el:setProperty("image", nil)
  luaunit.assertNil(el.image)
  luaunit.assertNil(el._loadedImage, "clearing the only image source must nil _loadedImage")
  luaunit.assertNil(el._renderer._loadedImage)
end

function TestImageableIntegration:test_bare_imagePath_write_matches_setProperty_reload()
  -- Bare `element.imagePath = ...` does NOT trigger the load pipeline (Lua
  -- __newindex cannot intercept existing keys, and imagePath is not a tracked
  -- dimension). This locks in that reloading requires setProperty, mirroring the
  -- dimension-prop contract.
  local imgA = makeMockImage()
  local imgB = makeMockImage()
  ImageCache._cache["bare/a.png"] = { image = imgA, imageData = nil }
  ImageCache._cache["bare/b.png"] = { image = imgB, imageData = nil }

  local el = FlexLove.new({ id = "img-bare", width = 100, height = 100, imagePath = "bare/a.png" })
  luaunit.assertEquals(el._loadedImage, imgA)

  el.imagePath = "bare/b.png" -- bare write: field changes, NO reload
  luaunit.assertEquals(el.imagePath, "bare/b.png")
  luaunit.assertEquals(el._loadedImage, imgA, "bare imagePath write must NOT reload")

  -- setProperty is the correct path: it reloads.
  el:setProperty("imagePath", "bare/b.png")
  luaunit.assertEquals(el._loadedImage, imgB)

  ImageCache._cache["bare/a.png"] = nil
  ImageCache._cache["bare/b.png"] = nil
end

-- Run tests if this file is executed directly.
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
