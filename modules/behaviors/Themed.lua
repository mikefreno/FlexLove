-- modules/behaviors/Themed.lua
--
-- Concrete behavior: Renderer ownership + theme-state rendering.
--
-- Themed owns the per-element Renderer instance and the single
-- `Renderer:draw` call that paints the core visual layers (background, image,
-- theme 9-patch, borders, text, customDraw). It is the behavior-mode-unification
-- replacement for the former `_initImageAndRenderer` Renderer creation block and
-- the former first `self._renderer:draw(self, backdropCanvas)` call in
-- Element:draw (behavior-mode-unification task 07).
--
-- Attachment rule (shouldAttach): every renderable Element. The pre-refactor
-- code unconditionally created a Renderer for every Element and unconditionally
-- called `Renderer:draw` in Element:draw; Themed mirrors that invariant so the
-- Renderer is always available to subsystems that depend on it (TextEditor font
-- / wrap delegation, ScrollManager scrollbar drawing) AND so visual rendering of
-- background / border / theme / image layers is preserved for every element.
-- Restricting attachment to `themeComponent`-only elements would break editable
-- text fields and scrollable containers (which need a Renderer for subsystem
-- delegation even when they have no theme component). The 9-patch theme-state
-- rendering within `Renderer:draw` is a no-op for elements without a
-- `themeComponent`, so always-attaching carries no rendering cost.
--
-- Themed and Imageable are paired (both configure the same `element._renderer`):
-- Themed.onAttach creates the Renderer with the theme/blur config; Imageable
-- (attached for imagePath/image elements) enriches the SAME renderer instance with
-- image config + deferred image loading. They share `element._renderer`.
--
-- onUpdate is a no-op: theme-state transitions are DRIVEN by the Clickable
-- behavior (whose onUpdate recomputes hover/press/focus and calls
-- `renderer:setThemeState`). Themed only READS that state for rendering, so it has
-- no per-frame update work.
--
-- State ownership (per the locked Behavior contract):
--   * Per-element runtime state lives ON THE ELEMENT (`element._renderer`,
--     `element._themeState`). The behavior instance is stateless and shared.
--   * No saveState/restoreState: theme state is recomputed each frame by
--     Clickable (from persistent EventHandler state) and is not itself
--     behavior-persisted. `element._renderer` is recreated on attach.

local Behavior = require("modules.Behavior")

-- Resolve the Element class from an element instance (mirrors Clickable).
-- Element instances are created via `setmetatable({}, Element)`, so their
-- metatable IS the Element class — giving access to Element._Renderer,
-- Element._rendererDeps, etc. without threading deps through the hook signature.
local function ElementClass(element)
  return getmetatable(element)
end

-- ----------------------------------------------------------------------------
-- shouldAttach (class-level predicate, no element required)
-- ----------------------------------------------------------------------------

-- Returns true for every renderable Element. See file header for the rationale:
-- the pre-refactor invariant was "every Element has a Renderer; Element:draw
-- always calls Renderer:draw", and Thamed is the behavior-system embodiment of
-- that invariant. Returns true for `themeComponent`-bearing props (the spec's
-- headline case) and for every other element so subsystems/rendering stay intact.
local function shouldAttach(props)
  return true
end

-- ----------------------------------------------------------------------------
-- onAttach — create the Renderer with theme/blur config (formerly the
-- Renderer.new block of Element:_initImageAndRenderer).
-- ----------------------------------------------------------------------------

local function onAttach(element)
  local Element = ElementClass(element)

  -- Create-or-reuse the Renderer. Thamed is the first render behavior in the
  -- registry, so it normally creates the instance; Imageable (if attached) will
  -- reuse this same instance for image config. Guarded so Imageable-onAttach-
  -- first (defensive) does not clobber an existing renderer.
  if element._renderer then
    return
  end

  -- NOTE: backgroundColor/borderColor/opacity/cornerRadius/themeComponent are
  -- intentionally NOT passed here. Renderer:draw() reads them from the element
  -- as the single source of truth (see Renderer.lua draw()). Only renderer-owned
  -- state (theme, blur) is cached on the renderer; image config is added by the
  -- Imageable behavior. border is element-sourced too.
  element._renderer = Element._Renderer.new({
    theme = element.theme,
    scaleCorners = element.scaleCorners,
    scalingAlgorithm = element.scalingAlgorithm,
    contentBlur = element.contentBlur,
    backdropBlur = element.backdropBlur,
  }, Element._rendererDeps)
end

-- ----------------------------------------------------------------------------
-- onDraw — the single Renderer:draw call (formerly the first call in
-- Element:draw). Paints all core visual layers for this element.
-- ----------------------------------------------------------------------------

local function onDraw(element, ctx)
  local renderer = element._renderer
  if not renderer then
    return
  end
  renderer:draw(element, ctx and ctx.backdropCanvas)
end

-- ----------------------------------------------------------------------------
-- Build the (stateless, shared, immutable) behavior instance.
-- ----------------------------------------------------------------------------

local Themed = Behavior.new({
  onAttach = onAttach,
  -- onDetach: the Renderer is recreated each attach (immediate mode per-frame);
  -- no explicit teardown needed beyond releasing the `element._renderer`
  -- reference, which happens naturally when the element is GC'd.
  onUpdate = function() end,
  onDraw = onDraw,
  -- saveState/restoreState: no-op (see file header — theme state is recomputed
  -- by Clickable each frame, not persisted by Themed).
})

-- Expose the predicate at module level so callers/tests can reference it
-- directly without an element instance (mirrors Behavior.shouldAttach /
-- Clickable.shouldAttach).
Themed.shouldAttach = shouldAttach

return Themed
