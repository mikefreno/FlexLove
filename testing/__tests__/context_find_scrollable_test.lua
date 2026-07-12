-- Unit tests for `Context.findScrollableAtPosition(x, y)` added to
-- modules.Context by unified-event-routing task 02.
--
-- This is the mode-agnostic successor to the two duplicated scrollable lookups
-- that previously lived inline in `flexlove.wheelmoved`: an immediate-mode
-- z-index loop and a retained-mode recursive `findScrollableAtPosition` tree
-- helper. Both modes now route through this single function, which delegates
-- all hit testing to `pointHitsElement` (the single place `display == false`
-- is guarded) and scroll-offset decisions to `elementHasScrollableOverflow`.
--
-- The retained-mode branch intentionally reproduces the original
-- `findScrollableAtPosition` tree walk found in FlexLove.lua; one test below
-- cross-checks the two implementations element-for-element on shared fixtures.

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

-- Minimal element factory matching the field surface that
-- findScrollableAtPosition / pointHitsElement read: x/y/width/height + padding,
-- optional _borderBoxWidth/_borderBoxHeight, display, overflow{,X,Y}, and the
-- runtime overflow flags `_overflowX`/`_overflowY` (set by the scroll manager
-- when content actually overflows).
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

-- Faithful reimplementation of the ORIGINAL retained-mode helper that lived
-- inside `flexlove.wheelmoved` (FlexLove.lua) before this task. Used by the
-- parity test to cross-check the new Context.findScrollableAtPosition retained
-- branch against the pre-existing behavior. Keep in sync with the original if
-- it is ever referenced again before task 04 removes it.
local function originalFindScrollableAtPosition(elements, x, y)
  for i = #elements, 1, -1 do
    local element = elements[i]
    if element.display ~= false then
      local bx = element.x
      local by = element.y
      local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

      if x >= bx and x <= bx + bw and y >= by and y <= by + bh then
        if #element.children > 0 then
          local childResult = originalFindScrollableAtPosition(element.children, x, y)
          if childResult then
            return childResult
          end
        end

        local overflowX = element.overflowX or element.overflow
        local overflowY = element.overflowY or element.overflow
        if
          (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto")
          and (element._overflowX or element._overflowY)
        then
          return element
        end
      end
    end
  end
  return nil
end

TestFindScrollableAtPosition = {}

function TestFindScrollableAtPosition:setUp()
  -- Snapshot mutable Context state so each test gets a clean slate.
  self._savedZ = Context._zIndexOrderedElements
  self._savedTop = Context.topElements
  self._savedImmediate = Context._immediateMode
  self._savedFrame = Context._frameNumber
  Context._zIndexOrderedElements = {}
  Context.topElements = {}
  Context._immediateMode = false
end

function TestFindScrollableAtPosition:tearDown()
  Context._zIndexOrderedElements = self._savedZ
  Context.topElements = self._savedTop
  Context._immediateMode = self._savedImmediate
  Context._frameNumber = self._savedFrame
end

-- The function is defined and exported on the module table.
function TestFindScrollableAtPosition:testFunctionIsExported()
  luaunit.assertNotNil(Context.findScrollableAtPosition)
  luaunit.assertEquals(type(Context.findScrollableAtPosition), "function")
end

-- =====================
-- Immediate mode
-- =====================

function TestFindScrollableAtPosition:testImmediateModeReturnsScrollableElement()
  Context._immediateMode = true
  local a = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
  })
  Context._zIndexOrderedElements = { a }

  local hit = Context.findScrollableAtPosition(25, 25)
  luaunit.assertTrue(hit == a, "returns the single scrollable element hit")
end

-- Topmost (highest z-index, last in the sorted list) wins in immediate mode
-- when multiple scrollables overlap at the point.
function TestFindScrollableAtPosition:testImmediateModeTopmostWins()
  Context._immediateMode = true
  local bottom = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
  })
  bottom.id = "bottom"
  local top = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
  })
  top.id = "top"
  -- z-index ordered list is lowest→highest; last entry is topmost.
  Context._zIndexOrderedElements = { bottom, top }

  local hit = Context.findScrollableAtPosition(25, 25)
  luaunit.assertTrue(hit == top, "topmost (last) scrollable wins over lower one")
end

-- Immediate mode returns nil when no scrollable element is hit.
function TestFindScrollableAtPosition:testImmediateModeReturnsNilWhenNoScrollable()
  Context._immediateMode = true
  local e = mkElement({ x = 0, y = 0, width = 50, height = 50 })
  Context._zIndexOrderedElements = { e }
  luaunit.assertNil(Context.findScrollableAtPosition(25, 25), "non-scrollable element yields nil")

  -- ...and when the point misses every element entirely.
  Context._zIndexOrderedElements = {
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "auto", _overflowX = true }),
  }
  luaunit.assertNil(Context.findScrollableAtPosition(500, 500), "point outside any bounds yields nil")
end

-- =====================
-- Retained mode
-- =====================

function TestFindScrollableAtPosition:testRetainedModeReturnsScrollableElement()
  Context._immediateMode = false
  local a = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
  })
  Context.topElements = { a }

  local hit = Context.findScrollableAtPosition(25, 25)
  luaunit.assertTrue(hit == a, "returns the single scrollable element hit")
end

-- Deepest scrollable wins: when both a parent and a child are scrollable and
-- the point hits the child, the child is returned.
function TestFindScrollableAtPosition:testRetainedModeDeepestWins()
  Context._immediateMode = false
  local child = mkElement({
    x = 5,
    y = 5,
    width = 20,
    height = 20,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
  })
  child.id = "child"
  local parent = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
    children = { child },
  })
  parent.id = "parent"
  Context.topElements = { parent }

  local hit = Context.findScrollableAtPosition(10, 10)
  luaunit.assertTrue(hit == child, "deepest (child) scrollable wins over parent")
end

-- Retained mode returns the parent itself when the point is inside the parent
-- but no child (or only non-scrollable children) is scrollable at the point.
function TestFindScrollableAtPosition:testRetainedModeParentWhenChildNotScrollable()
  Context._immediateMode = false
  local nonScrollChild = mkElement({ x = 0, y = 0, width = 20, height = 20 })
  local parent = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "scroll",
    _overflowX = true,
    _overflowY = true,
    children = { nonScrollChild },
  })
  Context.topElements = { parent }

  luaunit.assertTrue(
    Context.findScrollableAtPosition(40, 40) == parent,
    "parent returned when no scrollable child matches the point"
  )
end

function TestFindScrollableAtPosition:testRetainedModeReturnsNilWhenNoScrollable()
  Context._immediateMode = false
  local e = mkElement({ x = 0, y = 0, width = 50, height = 50 })
  Context.topElements = { e }
  luaunit.assertNil(Context.findScrollableAtPosition(25, 25), "non-scrollable element yields nil")
  luaunit.assertNil(Context.findScrollableAtPosition(500, 500), "outside bounds yields nil")
end

-- =====================
-- display:none never returned
-- =====================

-- Elements with display == false are never returned, in either mode, even when
-- they are otherwise scrollable and directly under the point. This exercises
-- the consolidated guard inside pointHitsElement.
function TestFindScrollableAtPosition:testDisplayNoneSkippedImmediate()
  Context._immediateMode = true
  local hidden = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
    display = false,
  })
  hidden.id = "hidden"
  local visible = mkElement({
    x = 60,
    y = 60,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
  })
  visible.id = "visible"
  Context._zIndexOrderedElements = { hidden, visible }

  -- Point over hidden: must be skipped so we fall through to nil (visible is
  -- elsewhere and not hit).
  luaunit.assertNil(Context.findScrollableAtPosition(25, 25), "display:none element skipped in immediate mode")
  -- Point over visible still returns the visible scrollable.
  luaunit.assertTrue(
    Context.findScrollableAtPosition(85, 85) == visible,
    "visible scrollable still found in immediate mode"
  )
end

function TestFindScrollableAtPosition:testDisplayNoneSkippedRetained()
  Context._immediateMode = false
  local hiddenChild = mkElement({
    x = 5,
    y = 5,
    width = 20,
    height = 20,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
    display = false,
  })
  local parent = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
    children = { hiddenChild },
  })
  Context.topElements = { parent }

  -- Point is inside both parent and hidden child. The hidden child must be
  -- skipped, so we fall back to the parent.
  local hit = Context.findScrollableAtPosition(10, 10)
  luaunit.assertTrue(hit == parent, "display:none child skipped; parent returned instead")

  -- A subtree whose root is display:none is never entered.
  local hiddenRoot = mkElement({
    x = 0,
    y = 0,
    width = 50,
    height = 50,
    overflow = "auto",
    _overflowX = true,
    _overflowY = true,
    display = false,
  })
  Context.topElements = { hiddenRoot }
  luaunit.assertNil(Context.findScrollableAtPosition(25, 25), "display:none root yields nil in retained mode")
end

-- =====================
-- Elements without scroll overflow are not returned
-- =====================

-- An element that is hit but has overflow:visible (or nil) is not returned,
-- regardless of mode, even if it has children. _overflowX/_overflowY false also
-- disqualifies a scroll/auto element (no actual overflow content).
function TestFindScrollableAtPosition:testNonScrollableNotReturnedImmediate()
  Context._immediateMode = true
  Context._zIndexOrderedElements = {
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "visible" }),
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = nil }),
    -- scroll/auto but no _overflow flags set: not actually overflowing, so nil.
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "auto" }),
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "scroll" }),
  }
  luaunit.assertNil(
    Context.findScrollableAtPosition(25, 25),
    "non-overflowing / non-flagged elements not returned in immediate mode"
  )
end

function TestFindScrollableAtPosition:testNonScrollableNotReturnedRetained()
  Context._immediateMode = false
  Context.topElements = {
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "visible" }),
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = nil }),
    mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "auto" }),
  }
  luaunit.assertNil(
    Context.findScrollableAtPosition(25, 25),
    "non-overflowing / non-flagged elements not returned in retained mode"
  )
end

-- =====================
-- Parity with the original retained-mode helper
-- =====================

-- Cross-check: Context.findScrollableAtPosition (retained branch) returns the
-- same element as the original local helper that lived in flexlove.wheelmoved,
-- across a set of fixtures with nested scrollables and non-scrollables.
-- (Fixtures here have no live scrolling — _scrollX/_scrollY unset — so the
-- original helper's unshifted bounds checks and the new offset-threaded
-- pointHitsElement path agree; this is the case the spec's "direct compare"
-- acceptance test targets.)
function TestFindScrollableAtPosition:testRetainedParityWithOriginalHelper()
  Context._immediateMode = false

  local fixtures = {
    -- single scrollable at origin
    {
      topElements = {
        mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "auto", _overflowX = true }),
      },
      x = 25,
      y = 25,
    },
    -- nested scrollable child wins at child point
    {
      topElements = {
        mkElement({
          x = 0,
          y = 0,
          width = 100,
          height = 100,
          overflow = "auto",
          _overflowX = true,
          children = {
            mkElement({ x = 10, y = 10, width = 20, height = 20, overflow = "scroll", _overflowY = true }),
          },
        }),
      },
      x = 20,
      y = 20,
    },
    -- point in parent region only (child at offset, point outside child)
    {
      topElements = {
        mkElement({
          x = 0,
          y = 0,
          width = 100,
          height = 100,
          overflow = "auto",
          _overflowX = true,
          children = {
            mkElement({ x = 0, y = 0, width = 10, height = 10, overflow = "visible" }),
          },
        }),
      },
      x = 50,
      y = 50,
    },
    -- non-scrollable root with non-scrollable child
    {
      topElements = {
        mkElement({
          x = 0,
          y = 0,
          width = 100,
          height = 100,
          children = { mkElement({ x = 0, y = 0, width = 50, height = 50 }) },
        }),
      },
      x = 25,
      y = 25,
    },
    -- display:none root (both helpers must yield nil)
    {
      topElements = {
        mkElement({ x = 0, y = 0, width = 50, height = 50, overflow = "auto", _overflowX = true, display = false }),
      },
      x = 25,
      y = 25,
    },
    -- multiple top-level, only second is scrollable & hit
    {
      topElements = {
        mkElement({ x = 0, y = 0, width = 10, height = 10 }),
        mkElement({ x = 20, y = 20, width = 50, height = 50, overflow = "scroll", _overflowY = true }),
      },
      x = 30,
      y = 30,
    },
  }

  for i, fx in ipairs(fixtures) do
    Context.topElements = fx.topElements
    local got = Context.findScrollableAtPosition(fx.x, fx.y)
    local want = originalFindScrollableAtPosition(fx.topElements, fx.x, fx.y)
    luaunit.assertTrue(
      got == want,
      string.format(
        "fixture %d: new=%s original=%s (x=%d y=%d)",
        i,
        tostring(got and got.id or got),
        tostring(want and want.id or want),
        fx.x,
        fx.y
      )
    )
  end
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
