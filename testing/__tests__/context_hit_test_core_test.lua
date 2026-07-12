-- Unit tests for the shared hit-testing core added to modules.Context by
-- unified-event-routing task 01 (pointHitsElement + elementHasScrollableOverflow).
--
-- These two locals are the single canonical entry point for mode-agnostic
-- hit testing: every future Context query function
-- (findScrollableAtPosition / findInteractiveAtPosition / getFocusableElements)
-- will route through pointHitsElement so that the display:none guard, bounds
-- math, and scroll-offset compensation live in exactly one place.
--
-- Because the helpers are module-local, they are surfaced through
-- Context._test.* — a test-only surface that is NOT part of the public API.

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

TestPointHitsElement = {}

-- Minimal element factory matching the field shape pointHitsElement reads:
-- x/y/width/height + padding, plus optional _borderBoxWidth/_borderBoxHeight,
-- display, overflow{,X,Y}.
local function mkElement(t)
  t = t or {}
  t.padding = t.padding or { left = 0, right = 0, top = 0, bottom = 0 }
  t.x = t.x or 0
  t.y = t.y or 0
  t.width = t.width or 0
  t.height = t.height or 0
  return t
end

function TestPointHitsElement:setUp()
  self.pointHitsElement = Context._test.pointHitsElement
  self.elementHasScrollableOverflow = Context._test.elementHasScrollableOverflow
  luaunit.assertNotNil(self.pointHitsElement)
  luaunit.assertNotNil(self.elementHasScrollableOverflow)
end

-- pointHitsElement returns false when element.display == false regardless of
-- position (the single canonical display:none guard).
function TestPointHitsElement:testDisplayNoneAlwaysMisses()
  local e = mkElement({ x = 10, y = 10, width = 20, height = 20 })
  -- Sanity: without display:none the center hits.
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20))

  e.display = false
  -- Center, corners, and outside all miss when display is none.
  luaunit.assertFalse(self.pointHitsElement(e, 20, 20), "center misses when display:none")
  luaunit.assertFalse(self.pointHitsElement(e, 10, 10), "top-left corner misses when display:none")
  luaunit.assertFalse(self.pointHitsElement(e, 30, 30), "bottom-right corner misses when display:none")
  luaunit.assertFalse(self.pointHitsElement(e, 0, 0), "outside misses when display:none")
end

-- display == nil / true / other truthy values must NOT short-circuit.
function TestPointHitsElement:testDisplayNotFalseStillHits()
  local e = mkElement({ x = 10, y = 10, width = 20, height = 20 })
  e.display = nil
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20), "display=nil hits")

  e.display = true
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20), "display=true hits")

  e.display = "block"
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20), "display='block' hits (only literal false hides)")
end

-- pointHitsElement returns true when the point is within element bounds.
function TestPointHitsElement:testInsideBoundsHits()
  local e = mkElement({ x = 10, y = 10, width = 20, height = 20 })
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20), "center")
  luaunit.assertTrue(self.pointHitsElement(e, 10, 10), "top-left inclusive corner")
  luaunit.assertTrue(self.pointHitsElement(e, 30, 30), "bottom-right inclusive corner")
  luaunit.assertTrue(self.pointHitsElement(e, 15, 25), "interior point")
end

-- Returns false when the point lies on any side outside the bounds.
function TestPointHitsElement:testOutsideBoundsMisses()
  local e = mkElement({ x = 10, y = 10, width = 20, height = 20 })
  luaunit.assertFalse(self.pointHitsElement(e, 9, 20), "just left of left edge")
  luaunit.assertFalse(self.pointHitsElement(e, 31, 20), "just right of right edge")
  luaunit.assertFalse(self.pointHitsElement(e, 20, 9), "just above top edge")
  luaunit.assertFalse(self.pointHitsElement(e, 20, 31), "just below bottom edge")
  luaunit.assertFalse(self.pointHitsElement(e, 0, 0), "way outside")
end

-- _borderBoxWidth/_borderBoxHeight are preferred over width+padding sum so the
-- post-layout border-box is what gets hit-tested.
function TestPointHitsElement:testBorderBoxDimensionsPreferred()
  local e = mkElement({
    x = 0,
    y = 0,
    width = 10,
    height = 10,
    padding = { left = 5, right = 5, top = 5, bottom = 5 },
  })
  -- Without border-box cache the hit area is width+padding (20px).
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20))
  luaunit.assertFalse(self.pointHitsElement(e, 21, 20))

  -- With border-box cache the hit area is the cached value regardless of padding.
  e._borderBoxWidth = 12
  e._borderBoxHeight = 12
  luaunit.assertTrue(self.pointHitsElement(e, 12, 12))
  luaunit.assertFalse(self.pointHitsElement(e, 13, 12), "respects _borderBoxWidth over width+padding")
end

-- pointHitsElement accounts for scroll offsets correctly: the offsets shift the
-- hit window, simulating accumulated scroll translation from the parent chain.
function TestPointHitsElement:testScrollOffsetShiftsHitWindow()
  local e = mkElement({ x = 10, y = 10, width = 20, height = 20 })

  -- (5, 15) is normally just left of the element; +6 scroll X brings it inside.
  luaunit.assertFalse(self.pointHitsElement(e, 5, 15, 0, 0), "no offset: left of bounds")
  luaunit.assertTrue(self.pointHitsElement(e, 5, 15, 6, 0), "scroll x offset shifts into bounds")

  -- (20, 5) is normally above the element; +8 scroll Y brings it inside.
  luaunit.assertFalse(self.pointHitsElement(e, 20, 5, 0, 0), "no offset: above bounds")
  luaunit.assertTrue(self.pointHitsElement(e, 20, 5, 0, 8), "scroll y offset shifts into bounds")

  -- Negative offsets shift the window the other way.
  luaunit.assertTrue(self.pointHitsElement(e, 30, 30, -5, -5), "negative scroll pulls right edge back in")

  -- scrollOffset nil args default to 0 (same as passing 0,0).
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20), "nil scroll defaults to 0 and hits center")
  luaunit.assertTrue(self.pointHitsElement(e, 20, 20, nil, nil), "explicit nil args behave as 0,0")
end

-- elementHasScrollableOverflow returns true for scroll/auto/hidden on either axis.
function TestPointHitsElement:testScrollableOverflowValues()
  local cases = {
    { overflow = "scroll", expect = true },
    { overflow = "auto", expect = true },
    { overflow = "hidden", expect = true },
    { overflow = "visible", expect = false },
    { overflow = nil, expect = false },
    { overflowX = "scroll", expect = true },
    { overflowX = "auto", expect = true },
    { overflowX = "hidden", expect = true },
    { overflowX = "visible", expect = false },
    { overflowY = "scroll", expect = true },
    { overflowY = "auto", expect = true },
    { overflowY = "hidden", expect = true },
    { overflowY = "visible", expect = false },
    { overflowX = "scroll", overflowY = "visible", expect = true },
    { overflowX = "visible", overflowY = "auto", expect = true },
    { overflowX = "visible", overflowY = "visible", expect = false },
  }
  for i, c in ipairs(cases) do
    luaunit.assertEquals(self.elementHasScrollableOverflow(mkElement(c)), c.expect, "case " .. i)
  end
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
