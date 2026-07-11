-- modules/behaviors/Scrollable.lua
--
-- Concrete behavior: ScrollManager lifecycle (creation + immediate-mode
-- scrollbar interaction-state restore).
--
-- Scrollable owns the per-element ScrollManager instance — the subsystem that
-- manages overflow detection, scrollbar geometry, scroll position, and scrollbar
-- drag/hover interaction. It is the behavior-mode-unification replacement for
-- the former `Element:_initScrollManager` phase (~84 LOC) of Element.new
-- (behavior-mode-unification task 03 / landed as part of the task 08 capstone).
--
-- Attachment rule (shouldAttach): an element owns a ScrollManager exactly when
-- it declares an `overflow`, `overflowX`, or `overflowY` prop — mirroring the
-- legacy `if props.overflow or props.overflowX or props.overflowY then` guard
-- in `Element:_initScrollManager`. The ScrollManager is created and its
-- normalized fields are exposed back onto the element (so the Renderer /
-- ScrollManager delegates read `element.overflow` / `element.scrollbarWidth`
-- etc.) exactly as the legacy inline phase did.
--
-- Why onAttach reads `element._initProps` (not element fields): the scrollbar
-- configuration props (scrollbarWidth / scrollbarColor / scrollSpeed /
-- scrollbarPlacement / scrollbarBalance / invertScroll / smoothScrollEnabled /
-- scrollBarStyle / scrollbarKnobOffset / hideScrollbars / scrollbarRadius /
-- scrollbarPadding / scrollbarTrackColor / _scrollX / _scrollY) are listed in
-- SPECIAL_PROPS and therefore NOT bound onto the element by the schema-driven
-- `_applyProps` loop — they are consumed only by the ScrollManager constructor.
-- The locked behavior hook signature is `(element, ...)` with no props arg, so
-- the original construction props are stashed on the element as `_initProps` by
-- `Element:_construct` and read back here. (`overflow` / `overflowX` /
-- `overflowY` ARE bound onto the element by `_applyProps` so that
-- `Element:addChild`'s scroll-container auto-size guard sees them during
-- declarative-children processing in `_finalizeConstruction`, which runs BEFORE
-- this onAttach; onAttach then overwrites them with the ScrollManager's
-- normalized values, matching the legacy field-exposure order.)
--
-- onUpdate / onDraw / saveState / restoreState are deferred to the
-- behavior-driven update/draw tasks (09 / 12): the ScrollManager update,
-- interaction, scrollbar drawing, and state save/restore currently stay inline
-- in `Element:update` / `Element:draw` / `Element:saveState` /
-- `Element:restoreState` (delegated through the ScrollManager API bound in
-- `Element.init`). Those inline call sites are NOT behavioral `if` branches —
-- they are unconditional 1-line delegates — so leaving them in Element does not
-- regress the behavior-dispatch goals of tasks 09/12; task 09 will fold them
-- into Scrollable hooks.
--
-- State ownership (per the locked Behavior contract):
--   * Per-element runtime state lives ON THE ELEMENT (`element._scrollManager`,
--     `element.overflow`, `element._scrollX`, `element._scrollbarDragging`, ...).
--   * The behavior instance is stateless + immutable and shared across elements.
--   * Element-class-level dependencies (`Element._ScrollManager`,
--     `Element._scrollManagerDeps`, `Element._Context`, `Element._StateManager`)
--     are resolved from the owning element's metatable (the Element class set by
--     `Element:_construct`).

local Behavior = require("modules.Behavior")

-- Resolve the Element class from an element instance.
-- `setmetatable({}, Element)` in `_construct` makes the instance metatable BE
-- the Element class, so this yields Element._ScrollManager,
-- Element._scrollManagerDeps, Element._Context, Element._StateManager without
-- threading deps through the hook signature.
local function ElementClass(element)
  return getmetatable(element)
end

-- ----------------------------------------------------------------------------
-- shouldAttach (class-level predicate, no element required)
-- ----------------------------------------------------------------------------

-- Mirrors the legacy `if props.overflow or props.overflowX or props.overflowY`
-- guard. Uses `~= nil` (rather than truthiness) so that an explicit
-- `overflow = false` / `overflow = ""` does not spuriously attach — though in
-- practice overflow values are always strings or unset, matching the predicate
-- semantics of the other behaviors (Clickable / TextEditable / Selectable).
local function shouldAttach(props)
  props = props or {}
  return props.overflow ~= nil or props.overflowX ~= nil or props.overflowY ~= nil
end

-- ----------------------------------------------------------------------------
-- onAttach — create the ScrollManager + expose its fields + restore immediate-
-- mode scrollbar interaction state (formerly Element:_initScrollManager).
-- ----------------------------------------------------------------------------

local function onAttach(element)
  local Element = ElementClass(element)
  -- Construction props are stashed on the element by _construct (the scrollbar
  -- config props are SPECIAL_PROPS and not bound as element fields).
  local props = element._initProps or {}

  element._scrollManager = Element._ScrollManager.new({
    overflow = props.overflow,
    overflowX = props.overflowX,
    overflowY = props.overflowY,
    scrollbarWidth = props.scrollbarWidth,
    scrollbarColor = props.scrollbarColor,
    scrollbarTrackColor = props.scrollbarTrackColor,
    scrollbarRadius = props.scrollbarRadius,
    scrollbarPadding = props.scrollbarPadding,
    scrollSpeed = props.scrollSpeed,
    invertScroll = props.invertScroll,
    smoothScrollEnabled = props.smoothScrollEnabled,
    scrollBarStyle = props.scrollBarStyle,
    scrollbarKnobOffset = props.scrollbarKnobOffset,
    hideScrollbars = props.hideScrollbars,
    scrollbarPlacement = props.scrollbarPlacement,
    scrollbarBalance = props.scrollbarBalance,
    _scrollX = props._scrollX,
    _scrollY = props._scrollY,
  }, Element._scrollManagerDeps)

  -- Expose ScrollManager properties for backward compatibility (Renderer access).
  local sm = element._scrollManager
  element.overflow = sm.overflow
  element.overflowX = sm.overflowX
  element.overflowY = sm.overflowY
  element.scrollbarWidth = sm.scrollbarWidth
  element.scrollbarColor = sm.scrollbarColor
  element.scrollbarTrackColor = sm.scrollbarTrackColor
  element.scrollbarRadius = sm.scrollbarRadius
  element.scrollbarPadding = sm.scrollbarPadding
  element.scrollSpeed = sm.scrollSpeed
  element.invertScroll = sm.invertScroll
  element.scrollBarStyle = sm.scrollBarStyle
  element.scrollbarKnobOffset = sm.scrollbarKnobOffset
  element.hideScrollbars = sm.hideScrollbars
  element.scrollbarPlacement = sm.scrollbarPlacement
  element.scrollbarBalance = sm.scrollbarBalance

  -- Initialize state properties (will be synced from ScrollManager).
  element._overflowX = false
  element._overflowY = false
  element._contentWidth = 0
  element._contentHeight = 0
  element._scrollX = 0
  element._scrollY = 0
  element._maxScrollX = 0
  element._maxScrollY = 0
  element._scrollbarHoveredVertical = false
  element._scrollbarHoveredHorizontal = false
  element._scrollbarDragging = false
  element._hoveredScrollbar = nil
  element._scrollbarDragOffset = 0

  -- Restore scrollbar state from StateManager in immediate mode (must happen
  -- before layout). Mirrors the legacy _initScrollManager restore block.
  if Element._Context._immediateMode and element._stateId and element._stateId ~= "" then
    local state = Element._StateManager.getState(element._stateId)
    if state and state.scrollManager then
      element._scrollbarHoveredVertical = state.scrollManager._scrollbarHoveredVertical or false
      element._scrollbarHoveredHorizontal = state.scrollManager._scrollbarHoveredHorizontal or false
      element._scrollbarDragging = state.scrollManager._scrollbarDragging or false
      element._hoveredScrollbar = state.scrollManager._hoveredScrollbar
      element._scrollbarDragOffset = state.scrollManager._scrollbarDragOffset or 0

      -- Apply to ScrollManager immediately.
      sm._scrollbarHoveredVertical = element._scrollbarHoveredVertical
      sm._scrollbarHoveredHorizontal = element._scrollbarHoveredHorizontal
      sm._scrollbarDragging = element._scrollbarDragging
      sm._hoveredScrollbar = element._hoveredScrollbar
      sm._scrollbarDragOffset = element._scrollbarDragOffset

      -- Restore drag start positions for relative movement tracking.
      sm._dragStartMouseX = state.scrollManager._dragStartMouseX or 0
      sm._dragStartMouseY = state.scrollManager._dragStartMouseY or 0
      sm._dragStartScrollX = state.scrollManager._dragStartScrollX or 0
      sm._dragStartScrollY = state.scrollManager._dragStartScrollY or 0
    end
  end
end

-- ----------------------------------------------------------------------------
-- onUpdate / onDraw / saveState / restoreState — deferred to tasks 09 / 12.
-- The ScrollManager update / interaction / scrollbar drawing / state save-restore
-- currently stay inline in Element:update / Element:draw / Element:saveState /
-- Element:restoreState as unconditional 1-line delegates (no behavioral
-- `if self._scrollManager` branching in update/draw), so leaving them inline does
-- not regress the behavior-dispatch goals. Task 09 will fold them into these
-- hooks. Kept as no-ops here so the behavior conforms to the lifecycle contract.
-- ----------------------------------------------------------------------------

local Scrollable = Behavior.new({
  onAttach = onAttach,
  onDetach = function() end,
  onUpdate = function() end,
  onDraw = function() end,
  saveState = function()
    return nil
  end,
  restoreState = function() end,
})

-- Expose the predicate at module level so callers/tests can reference it
-- directly without an element instance (mirrors Clickable.shouldAttach /
-- Selectable.shouldAttach).
Scrollable.shouldAttach = shouldAttach

return Scrollable
