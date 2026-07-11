-- Unit + integration tests for modules.behaviors.Scrollable (task 03 / 08).
--
-- Validates the concrete Scrollable behavior extracted from the former
-- Element:_initScrollManager phase: ScrollManager creation + field exposure +
-- immediate-mode scrollbar interaction-state restore.
--
-- Coverage:
--   * shouldAttach predicate — matches the legacy
--     `if props.overflow or props.overflowX or props.overflowY` guard.
--   * Behavior interface conformance — Scrollable is a Behavior instance
--     exposing all 6 lifecycle hooks (callable no-op-safe) + shouldAttach.
--   * Integration — Element.new attaches Scrollable to overflow-bearing
--     elements and allocates self._scrollManager (plus exposes
--     overflow/overflowX/overflowY + scrollbar fields) via onAttach; plain
--     elements attach no Scrollable and have no ScrollManager.

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
local Scrollable = require("modules.behaviors.Scrollable")
local FlexLove = require("FlexLove")

-- ============================================================================
-- shouldAttach predicate
-- ============================================================================

TestScrollableShouldAttach = {}

function TestScrollableShouldAttach:testOverflow_Attaches()
  luaunit.assertTrue(Scrollable.shouldAttach({ overflow = "scroll" }))
  luaunit.assertTrue(Scrollable.shouldAttach({ overflow = "auto" }))
  luaunit.assertTrue(Scrollable.shouldAttach({ overflow = "hidden" }))
end

function TestScrollableShouldAttach:testOverflowX_Attaches()
  luaunit.assertTrue(Scrollable.shouldAttach({ overflowX = "scroll" }))
end

function TestScrollableShouldAttach:testOverflowY_Attaches()
  luaunit.assertTrue(Scrollable.shouldAttach({ overflowY = "auto" }))
end

function TestScrollableShouldAttach:testEmptyProps_DoesNotAttach()
  luaunit.assertFalse(Scrollable.shouldAttach({}))
  luaunit.assertFalse(Scrollable.shouldAttach(nil))
end

function TestScrollableShouldAttach:testPassiveElementDoesNotAttach()
  luaunit.assertFalse(Scrollable.shouldAttach({ width = 100, height = 50 }))
  luaunit.assertFalse(Scrollable.shouldAttach({ text = "label", editable = true }))
  luaunit.assertFalse(Scrollable.shouldAttach({ scrollable = true }))
end

-- ============================================================================
-- Behavior interface conformance
-- ============================================================================

TestScrollableInterface = {}

function TestScrollableInterface:testIsBehaviorInstance()
  luaunit.assertTrue(Behavior.isBehavior(Scrollable))
end

function TestScrollableInterface:testExposesAllLifecycleHooks()
  for _, hook in ipairs({ "onAttach", "onDetach", "onUpdate", "onDraw", "saveState", "restoreState" }) do
    luaunit.assertEquals(type(Scrollable[hook]), "function", hook .. " must be a function")
  end
  luaunit.assertEquals(type(Scrollable.shouldAttach), "function")
end

function TestScrollableInterface:testDefaultHooksCallableWithoutElement()
  -- onUpdate/onDraw/saveState/restoreState are deferred-to-task-09 no-ops; they
  -- must be safe to call (behavior dispatch loop calls them unconditionally).
  local el = { id = "stub" }
  Scrollable.onDetach(el)
  Scrollable.onUpdate(el, 0.016)
  Scrollable.onDraw(el, {})
  luaunit.assertIsNil(Scrollable.saveState(el))
  Scrollable.restoreState(el, nil)
  Scrollable.restoreState(el, { scrollManager = {} })
end

-- ============================================================================
-- Integration: Element.new attaches Scrollable + creates ScrollManager
-- ============================================================================

TestScrollableIntegration = {}

function TestScrollableIntegration:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestScrollableIntegration:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestScrollableIntegration:testAutoAttach_OverflowElement()
  local el = FlexLove.new({
    id = "scrollable-1",
    width = 100,
    height = 100,
    overflow = "scroll",
  })
  local found = false
  for _, b in ipairs(el.behaviors) do
    if b == Scrollable then
      found = true
      break
    end
  end
  luaunit.assertTrue(found, "Scrollable behavior should be auto-attached when overflow is set")
  luaunit.assertNotNil(el._scrollManager, "ScrollManager created via onAttach")
  luaunit.assertEquals(el.overflow, "scroll", "overflow exposed from ScrollManager")
  luaunit.assertNotNil(el.setScrollPosition, "scroll API bound from ScrollManager")
  luaunit.assertNotNil(el.getScrollPosition, "scroll API bound from ScrollManager")
end

function TestScrollableIntegration:testNoAttach_PlainElement()
  local el = FlexLove.new({ id = "scrollable-plain", width = 100, height = 100 })
  local found = false
  for _, b in ipairs(el.behaviors) do
    if b == Scrollable then
      found = true
      break
    end
  end
  luaunit.assertFalse(found, "Scrollable should NOT attach to plain elements")
  luaunit.assertNil(el._scrollManager, "no ScrollManager without overflow")
end

function TestScrollableIntegration:testScrollbarFieldsExposed()
  local el = FlexLove.new({
    id = "scrollable-2",
    width = 100,
    height = 100,
    overflow = "auto",
    scrollbarWidth = 12,
    scrollbarPlacement = "left",
  })
  luaunit.assertEquals(el.scrollbarWidth, 12, "scrollbarWidth exposed from ScrollManager")
  luaunit.assertEquals(el.scrollbarPlacement, "left", "scrollbarPlacement exposed from ScrollManager")
  -- state fields initialized
  luaunit.assertEquals(el._scrollX, 0)
  luaunit.assertEquals(el._scrollY, 0)
  luaunit.assertFalse(el._scrollbarDragging)
end

function TestScrollableIntegration:testOverflowXOnly_AttachesAndExposes()
  local el = FlexLove.new({
    id = "scrollable-x",
    width = 100,
    height = 100,
    overflowX = "scroll",
  })
  luaunit.assertNotNil(el._scrollManager, "ScrollManager created when only overflowX set")
  luaunit.assertEquals(el.overflowX, "scroll", "overflowX exposed")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
