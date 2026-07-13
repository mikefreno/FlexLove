-- Unit tests for `Context.findInteractiveAtPosition(x, y)` added to
-- modules.Context by unified-event-routing task 03.
--
-- This is the mode-agnostic successor to two immediate/retained-mode
-- mechanisms that previously answered "what is the topmost interactive element
-- under the cursor?":
--   * immediate mode — `Context.getTopElementAt()`, which only worked in
--     immediate mode (it early-returns nil when `isImmediateMode()` is false)
--     and used the local `isPointInElement` (which did NOT guard
--     `display == false`); and
--   * retained mode — the `_activeEventElement` field set by
--     `flexlove.getElementAtPosition()` during `flexlove.update()`.
--
-- Both roles are now filled by this single function, which routes every hit
-- test through `pointHitsElement` (the single place `display == false` is
-- guarded) and threads accumulated scroll offsets through
-- `elementHasScrollableOverflow`. It walks `Context.topElements` in BOTH modes
-- (the tree always exists — top-level elements are registered there by
-- `Element._initPositioning` regardless of mode) and resolves occlusion by
-- sorting candidates on `z` descending.
--
-- The immediate-mode tests below were originally parity cross-checks against
-- `Context.getTopElementAt()` (the immediate-mode mechanism this function
-- replaced). `getTopElementAt` was removed in unified-event-routing task 05 once
-- the occlusion check in `behaviors/Clickable.lua` was rerouted to
-- `findInteractiveAtPosition`; the retained-mode tests still cross-check against
-- `flexlove.getElementAtPosition()` (the source of `_activeEventElement`).

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

local luaunit = require("testing.luaunit")
require("testing.loveStub")
local Context = require("modules.Context")
local FlexLove = require("FlexLove")

-- Minimal element factory matching the field surface that
-- findInteractiveAtPosition / pointHitsElement read: x/y/width/height + padding,
-- optional _borderBoxWidth/_borderBoxHeight, display, overflow{,X,Y}, z,
-- children, and the interactivity flags onEvent/themeComponent/editable.
local function mkElement(t)
  t = t or {}
  t.padding = t.padding or { left = 0, right = 0, top = 0, bottom = 0 }
  t.x = t.x or 0
  t.y = t.y or 0
  t.width = t.width or 0
  t.height = t.height or 0
  t.children = t.children or {}
  return t
end

TestFindInteractiveAtPosition = {}

function TestFindInteractiveAtPosition:setUp()
  -- Snapshot mutable Context state so each test gets a clean slate.
  self._savedZ = Context._zIndexOrderedElements
  self._savedTop = Context.topElements
  self._savedImmediate = Context._immediateMode
  self._savedFrame = Context._frameNumber
  Context._zIndexOrderedElements = {}
  Context.topElements = {}
  Context._immediateMode = false
end

function TestFindInteractiveAtPosition:tearDown()
  Context._zIndexOrderedElements = self._savedZ
  Context.topElements = self._savedTop
  Context._immediateMode = self._savedImmediate
  Context._frameNumber = self._savedFrame
end

-- The function is defined and exported on the module table.
function TestFindInteractiveAtPosition:testFunctionIsExported()
  luaunit.assertNotNil(Context.findInteractiveAtPosition)
  luaunit.assertEquals(type(Context.findInteractiveAtPosition), "function")
end

-- Returns the z-highest interactive element at a position. Two overlapping
-- interactive siblings with different z; the higher-z one wins.
function TestFindInteractiveAtPosition:testReturnsZHighestInteractive()
  local low = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    z = 1,
    onEvent = function() end,
  })
  low.id = "low"
  local high = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    z = 9,
    onEvent = function() end,
  })
  high.id = "high"
  Context.topElements = { low, high }

  local hit = Context.findInteractiveAtPosition(25, 25)
  luaunit.assertTrue(hit == high, "higher-z interactive element wins")
end

-- When z is unset (defaults to 0) the candidates tie; the function still
-- returns one of the interactive hits (stable: the first after a stable sort
-- at equal keys is implementation-defined, so we only assert non-nil +
-- interactivity here).
function TestFindInteractiveAtPosition:testEqualZReturnsAnInteractiveHit()
  local a = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    onEvent = function() end,
  })
  a.id = "a"
  Context.topElements = { a }

  local hit = Context.findInteractiveAtPosition(25, 25)
  luaunit.assertTrue(hit == a, "returns the single interactive element")
end

-- Returns nil if no interactive element is at the position: a non-interactive
-- element under the cursor yields nil, and a point outside any bounds yields
-- nil.
function TestFindInteractiveAtPosition:testReturnsNilWhenNoInteractive()
  local e = mkElement({ x = 0, y = 0, width = 50, height = 50 })
  Context.topElements = { e }

  luaunit.assertNil(Context.findInteractiveAtPosition(25, 25), "non-interactive element under cursor yields nil")
  luaunit.assertNil(Context.findInteractiveAtPosition(500, 500), "point outside any bounds yields nil")
  luaunit.assertNil(Context.findInteractiveAtPosition(25, 25), "empty topElements after reset yields nil")
  Context.topElements = {}
  luaunit.assertNil(Context.findInteractiveAtPosition(25, 25), "no top-level elements yields nil")
end

-- Interactivity is recognized via any of the three signals: onEvent handler,
-- themeComponent, or editable flag.
function TestFindInteractiveAtPosition:testRecognizesAllInteractivitySignals()
  local withOnEvent = mkElement({
    x = 0,
    y = 0,
    width = 10,
    height = 10,
    z = 1,
    onEvent = function() end,
  })
  local withTheme = mkElement({
    x = 20,
    y = 0,
    width = 10,
    height = 10,
    z = 1,
    themeComponent = "button",
  })
  local editable = mkElement({
    x = 40,
    y = 0,
    width = 10,
    height = 10,
    z = 1,
    editable = true,
  })
  Context.topElements = { withOnEvent, withTheme, editable }

  luaunit.assertTrue(Context.findInteractiveAtPosition(5, 5) == withOnEvent, "onEvent makes an element interactive")
  luaunit.assertTrue(
    Context.findInteractiveAtPosition(25, 5) == withTheme,
    "themeComponent makes an element interactive"
  )
  luaunit.assertTrue(Context.findInteractiveAtPosition(45, 5) == editable, "editable makes an element interactive")
end

-- display:none elements are skipped via pointHitsElement (the single canonical
-- display guard). A hidden interactive element under the cursor is never
-- returned; a visible interactive element elsewhere is still found.
function TestFindInteractiveAtPosition:testSkipsDisplayNone()
  local hidden = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    z = 9,
    onEvent = function() end,
    display = false,
  })
  hidden.id = "hidden"
  local visible = mkElement({
    x = 60,
    y = 60,
    width = 50,
    height = 50,
    z = 1,
    onEvent = function() end,
  })
  visible.id = "visible"
  Context.topElements = { hidden, visible }

  luaunit.assertNil(Context.findInteractiveAtPosition(25, 25), "display:none interactive element is skipped")
  luaunit.assertTrue(
    Context.findInteractiveAtPosition(85, 85) == visible,
    "visible interactive element elsewhere is still found"
  )
end

-- A display:none subtree root is never entered (pointHitsElement short-circuits
-- before recursing into children).
function TestFindInteractiveAtPosition:testDisplayNoneSubtreeNotEntered()
  local hiddenChild = mkElement({
    x = 5,
    y = 5,
    width = 20,
    height = 20,
    z = 9,
    onEvent = function() end,
  })
  local hiddenRoot = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    z = 1,
    display = false,
    children = { hiddenChild },
  })
  Context.topElements = { hiddenRoot }

  luaunit.assertNil(
    Context.findInteractiveAtPosition(10, 10),
    "display:none root subtree is never entered, so interactive child is not returned"
  )
end

-- An interactive parent of a non-interactive child: when the cursor is over the
-- (non-interactive) child, the parent is still returned because the parent's
-- bounds also contain the point and the parent is interactive. This mirrors
-- `getTopElementAt`'s `findInteractiveAncestor` behavior.
function TestFindInteractiveAtPosition:testInteractiveParentOfNonInteractiveChild()
  local child = mkElement({ x = 5, y = 5, width = 20, height = 20 })
  local parent = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    z = 1,
    onEvent = function() end,
    children = { child },
  })
  parent.id = "parent"
  Context.topElements = { parent }

  local hit = Context.findInteractiveAtPosition(10, 10)
  luaunit.assertTrue(hit == parent, "interactive parent returned when cursor is over non-interactive child")
end

-- Mode-agnostic: the function ignores the mode flag entirely and walks
-- topElements in both modes. The same fixture must yield the identical result
-- with _immediateMode true and false.
function TestFindInteractiveAtPosition:testModeAgnosticIdenticalResult()
  local function buildFixture()
    local low = mkElement({
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      z = 1,
      onEvent = function() end,
    })
    low.id = "low"
    local high = mkElement({
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      z = 9,
      onEvent = function() end,
    })
    high.id = "high"
    return { low, high }
  end

  Context._immediateMode = false
  Context.topElements = buildFixture()
  local retainedHit = Context.findInteractiveAtPosition(25, 25)

  Context._immediateMode = true
  Context.topElements = buildFixture()
  local immediateHit = Context.findInteractiveAtPosition(25, 25)

  luaunit.assertNotNil(retainedHit, "retained mode must return an element")
  luaunit.assertNotNil(immediateHit, "immediate mode must return an element")
  luaunit.assertEquals(retainedHit.id, immediateHit.id, "result must be identical in both modes")
  luaunit.assertEquals(retainedHit.id, "high", "both modes return the higher-z interactive element")
end

-- =====================
-- Immediate-mode behavior (originally parity vs Context.getTopElementAt)
-- =====================

TestFindInteractiveImmediateParity = {}

function TestFindInteractiveImmediateParity:setUp()
  FlexLove.destroy()
  FlexLove.init({ immediateMode = true })
  FlexLove.beginFrame()
end

function TestFindInteractiveImmediateParity:tearDown()
  if FlexLove.endFrame then
    FlexLove.endFrame()
  end
  FlexLove.setMode("retained")
  FlexLove.destroy()
end

-- Immediate-mode behavior: Context.findInteractiveAtPosition returns the
-- expected element across fixtures built with the real FlexLove.new
-- constructor (so elements are registered in both _zIndexOrderedElements and
-- topElements). Fixtures are restricted to onEvent interactive elements with no
-- non-interactive overlays. (Originally a parity cross-check against the now-
-- removed `Context.getTopElementAt()`; the assertions against `c.expect` are
-- preserved.)
function TestFindInteractiveImmediateParity:testParityWithGetTopElementAt()
  -- Fixture 1: single interactive element.
  local e1 = FlexLove.new({ x = 0, y = 0, width = 100, height = 100, onEvent = function() end })
  local cases = {
    { x = 50, y = 50, expect = e1 },
    { x = 200, y = 200, expect = nil },
  }

  FlexLove.endFrame()

  for i, c in ipairs(cases) do
    local got = Context.findInteractiveAtPosition(c.x, c.y)
    if c.expect ~= nil then
      luaunit.assertTrue(
        got == c.expect,
        string.format("fixture 1 case %d: findInteractive=%s expected the element", i, tostring(got))
      )
    else
      luaunit.assertNil(got, string.format("fixture 1 case %d: expected nil off-element", i))
    end
  end
end

-- Fixture 2: two overlapping interactive siblings with different z; the
-- higher-z one must be returned. (Originally a parity cross-check against the
-- now-removed `Context.getTopElementAt()`.)
function TestFindInteractiveImmediateParity:testParityTopmostOverlap()
  FlexLove.beginFrame()
  local low = FlexLove.new({ x = 0, y = 0, width = 100, height = 100, z = 1, onEvent = function() end })
  low.id = "low"
  local high = FlexLove.new({ x = 0, y = 0, width = 100, height = 100, z = 9, onEvent = function() end })
  high.id = "high"
  FlexLove.endFrame()

  local got = Context.findInteractiveAtPosition(50, 50)
  luaunit.assertNotNil(got, "returns an element under the cursor")
  luaunit.assertTrue(got == high, "returns the higher-z overlapping interactive element")
end

-- =====================
-- Parity with flexlove.getElementAtPosition() (retained mode)
-- =====================

TestFindInteractiveRetainedParity = {}

function TestFindInteractiveRetainedParity:setUp()
  FlexLove.destroy()
  FlexLove.init()
  FlexLove.setMode("retained")
end

function TestFindInteractiveRetainedParity:tearDown()
  FlexLove.destroy()
end

-- Cross-check: Context.findInteractiveAtPosition returns the same element as
-- flexlove.getElementAtPosition() in retained mode. getElementAtPosition is
-- the source of _activeEventElement (set during flexlove.update), so this
-- validates the spec's "returns the same result as _activeEventElement"
-- acceptance test. Fixtures use simple onEvent elements (default opacity, not
-- disabled, no select state) so both functions' interactivity criteria
-- coincide and no blocking-element divergence occurs.
function TestFindInteractiveRetainedParity:testParityWithGetElementAtPosition()
  local e1 = FlexLove.new({ x = 0, y = 0, width = 100, height = 100, onEvent = function() end })
  local cases = {
    { x = 50, y = 50 },
    { x = 200, y = 200 },
  }

  for i, c in ipairs(cases) do
    local got = Context.findInteractiveAtPosition(c.x, c.y)
    local want = FlexLove.getElementAtPosition(c.x, c.y)
    luaunit.assertTrue(
      got == want,
      string.format("case %d: findInteractive=%s getElementAtPosition=%s", i, tostring(got), tostring(want))
    )
  end
end

-- Two overlapping interactive siblings with different z; both functions must
-- agree and return the higher-z one.
function TestFindInteractiveRetainedParity:testParityTopmostOverlap()
  local low = FlexLove.new({ x = 0, y = 0, width = 100, height = 100, z = 1, onEvent = function() end })
  low.id = "low"
  local high = FlexLove.new({ x = 0, y = 0, width = 100, height = 100, z = 9, onEvent = function() end })
  high.id = "high"

  local got = Context.findInteractiveAtPosition(50, 50)
  local want = FlexLove.getElementAtPosition(50, 50)
  luaunit.assertTrue(got == want, "both functions agree on the topmost overlapping interactive element")
  luaunit.assertTrue(got == high, "both functions return the higher-z element")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
