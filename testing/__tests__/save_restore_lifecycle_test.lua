-- Unit + integration tests for behavior-mode-unification task 12
-- (Unified Save/Restore Lifecycle).
--
-- Locks in the contract that Element:saveState / Element:restoreState /
-- Element:_cleanup are thin behavior-dispatch loops (zero per-subsystem state
-- extraction inlined in Element): each persisted state slice is owned by
-- exactly one behavior's saveState/restoreState hook, and _cleanup tears down
-- via each behavior's onDetach hook.

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
local FlexLove = require("FlexLove")
local Persistable = require("modules.behaviors.Persistable")

-- Read a file's text (returns nil if missing).
local function readFile(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*all")
  f:close()
  return content
end

-- ============================================================================
-- Source-invariant tests (acceptance criteria)
-- ============================================================================

TestSaveRestoreLifecycleInvariants = {}

-- Acceptance: Element:saveState is a thin behavior-dispatch loop (≤15 LOC).
function TestSaveRestoreLifecycleInvariants:testSaveStateUnderFifteenLines()
  local src = readFile("modules/Element.lua")
  luaunit.assertNotNil(src)
  local body = src:match("function Element:saveState%b()\n(.-)\nend")
  luaunit.assertNotNil(body, "Element:saveState must be present")
  local _, lineCount = body:gsub("\n", "\n")
  -- awk counts the `function` line through the closing `end` (inclusive).
  luaunit.assertTrue(lineCount + 1 <= 15, "Element:saveState must be ≤15 LOC (got " .. (lineCount + 1) .. ")")
end

-- Acceptance: Element:restoreState is a thin behavior-dispatch loop (≤15 LOC).
function TestSaveRestoreLifecycleInvariants:testRestoreStateUnderFifteenLines()
  local src = readFile("modules/Element.lua")
  luaunit.assertNotNil(src)
  local body = src:match("function Element:restoreState%b()\n(.-)\nend")
  luaunit.assertNotNil(body, "Element:restoreState must be present")
  local _, lineCount = body:gsub("\n", "\n")
  luaunit.assertTrue(lineCount + 1 <= 15, "Element:restoreState must be ≤15 LOC (got " .. (lineCount + 1) .. ")")
end

-- Acceptance: Element:saveState / Element:restoreState contain NO per-subsystem
-- state extraction (no _textEditor/_scrollManager/_select/eventHandler literal
-- extraction branches). Each slice is owned by a behavior.
function TestSaveRestoreLifecycleInvariants:testSaveRestoreInlineNoSubsystemExtraction()
  local src = readFile("modules/Element.lua")
  luaunit.assertNotNil(src)
  local saveBody = src:match("function Element:saveState%b()\n(.-)\nend") or ""
  local restoreBody = src:match("function Element:restoreState%b()\n(.-)\nend") or ""
  local combined = saveBody .. "\n" .. restoreBody
  -- The blur block / select save / _props scan / textEditor extraction were
  -- the per-subsystem extractions moved into behaviors.
  for _, banned in ipairs({
    "state%.blur",
    "Element%._Select%.saveState",
    "Element%._Select%.restoreState",
    "state%.textEditor",
    "state%.scrollManager",
  }) do
    luaunit.assertEquals(
      select(2, combined:gsub(banned, "")),
      0,
      "Element save/restore must not inline subsystem extraction matching " .. banned
    )
  end
end

-- Deliverable: _cleanup dispatches onDetach per behavior + clears the behaviors
-- list (no inline per-subsystem teardown).
function TestSaveRestoreLifecycleInvariants:testCleanupIsBehaviorDispatchLoop()
  local src = readFile("modules/Element.lua")
  luaunit.assertNotNil(src)
  local body = src:match("function Element:_cleanup%b()\n(.-)\nend") or ""
  luaunit.assertTrue(body:find("onDetach", 1, true) ~= nil, "_cleanup must iterate behavior onDetach hooks")
  luaunit.assertTrue(body:find("self.behaviors = {}", 1, true) ~= nil, "_cleanup must clear the behaviors list")
end

-- Deliverable: the Persistable behavior exists, is in the registry, and is the
-- registry tail (so its restoreState applies _props last).
function TestSaveRestoreLifecycleInvariants:testPersistableIsRegistryTail()
  local Element = require("modules.Element")
  local registry = Element._behaviorRegistry
  luaunit.assertNotNil(registry)
  luaunit.assertEquals(registry[#registry], Persistable, "Persistable must be the last behavior in the registry")
end

-- ============================================================================

function TestSaveRestoreLifecycleInvariants:setUp()
  FlexLove.destroy()
  FlexLove.init()
end

function TestSaveRestoreLifecycleInvariants:tearDown()
  FlexLove.destroy()
end

-- ============================================================================
-- Behavioral tests: Element:saveState aggregates behavior snapshots
-- ============================================================================

TestSaveStateAggregation = {}

function TestSaveStateAggregation:setUp()
  FlexLove.destroy()
  FlexLove.init()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame(800, 600)
end

function TestSaveStateAggregation:tearDown()
  FlexLove.endFrame()
  FlexLove.setMode("retained")
  FlexLove.destroy()
end

-- Unit: saveState returns a state table keyed by each attached behavior's slice.
function TestSaveStateAggregation:testClickableStateKeyedUnderEventHandler()
  local el = FlexLove.new({
    id = "save-clickable",
    width = 100,
    height = 50,
    onEvent = function() end,
  })
  el._eventHandler._hovered = true
  local state = el:saveState()
  luaunit.assertNotNil(state.eventHandler, "Clickable.saveState must emit the `eventHandler` slice")
  luaunit.assertTrue(state.eventHandler._hovered, "Clickable.saveState must capture hovered state")
end

-- Unit: Persistable emits the `_props` slice in immediate mode (public scalar
-- mutations persist across frames).
function TestSaveStateAggregation:testPropsSliceEmittedInImmediateMode()
  local el = FlexLove.new({
    id = "save-props",
    width = 100,
    height = 50,
    text = "original",
  })
  el.text = "mutated"
  el.display = false
  local state = el:saveState()
  luaunit.assertNotNil(state._props, "Persistable.saveState must emit `_props` in immediate mode")
  luaunit.assertEquals(state._props.text, "mutated")
  luaunit.assertEquals(state._props.display, false)
end

-- Unit: Persistable.saveState returns nil (no _props) in retained mode is
-- covered by TestImmediateModePropertyPersistence in flexlove_test.lua.

-- Unit: Themed.saveState emits the `blur` slice for blur-configured elements.
function TestSaveStateAggregation:testBlurSliceEmittedForBlurElement()
  local el = FlexLove.new({
    id = "save-blur",
    width = 100,
    height = 50,
    backdropBlur = { radius = 4, quality = 3 },
  })
  local state = el:saveState()
  luaunit.assertNotNil(state.blur, "Themed.saveState must emit the `blur` slice for blur elements")
  luaunit.assertEquals(state.blur._backdropBlurRadius, 4)
  luaunit.assertEquals(state.blur._backdropBlurQuality, 3)
end

function TestSaveStateAggregation:testBlurSliceAbsentForPlainElement()
  local el = FlexLove.new({ id = "save-noblur", width = 100, height = 50 })
  local state = el:saveState()
  luaunit.assertNil(state.blur, "Themed.saveState must omit `blur` for plain elements")
end

-- ============================================================================
-- Behavioral tests: Element:restoreState hydrates via behaviors
-- ============================================================================

TestRestoreStateAggregation = {}

function TestRestoreStateAggregation:setUp()
  FlexLove.destroy()
  FlexLove.init()
end

function TestRestoreStateAggregation:tearDown()
  FlexLove.destroy()
end

-- Unit: restoreState hydrates the Clickable event-handler slice onto a fresh
-- element (Persistable runs last; _props overrides still win for scalar props).
function TestRestoreStateAggregation:testClickableStateHydratedOnFreshElement()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame(800, 600)
  local el1 = FlexLove.new({
    id = "restore-clickable",
    width = 100,
    height = 50,
    onEvent = function() end,
  })
  el1._eventHandler._hovered = true
  local snapshot = el1:saveState()
  FlexLove.endFrame()

  -- New frame: recreate, behavior restoreState must hydrate the handler.
  FlexLove.beginFrame(800, 600)
  local el2 = FlexLove.new({
    id = "restore-clickable",
    width = 100,
    height = 50,
    onEvent = function() end,
  })
  luaunit.assertTrue(el2._eventHandler._hovered, "restoreState must hydrate hovered state onto the fresh EventHandler")
  FlexLove.endFrame()
  FlexLove.setMode("retained")
end

-- Unit: restoreState's _props override applies LAST (registry tail), overriding
-- any subsystem-hydrated scalar field.
function TestRestoreStateAggregation:testPropsOverrideAppliedLast()
  local el = FlexLove.new({
    id = "restore-props-order",
    width = 100,
    height = 50,
    text = "constructor",
  })
  el:restoreState({ _props = { text = "persisted" } })
  luaunit.assertEquals(el.text, "persisted", "Persistable.restoreState (registry tail) must override constructor props")
end

-- ============================================================================
-- Behavioral tests: _cleanup dispatches onDetach + clears behaviors
-- ============================================================================

TestCleanupDispatch = {}

function TestCleanupDispatch:setUp()
  FlexLove.destroy()
  FlexLove.init()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame(800, 600)
end

function TestCleanupDispatch:tearDown()
  FlexLove.setMode("retained")
  FlexLove.destroy()
end

-- Unit: _cleanup clears the behaviors list (lifecycle contract).
function TestCleanupDispatch:testCleanupClearsBehaviorsList()
  local el = FlexLove.new({ id = "cleanup-behaviors", width = 100, height = 50, onEvent = function() end })
  luaunit.assertTrue(#el.behaviors >= 1, "element must attach behaviors before cleanup")
  el:_cleanup()
  luaunit.assertEquals(el.behaviors[1] or nil, nil, "behaviors list must be empty after _cleanup")
  luaunit.assertEquals(#el.behaviors, 0)
end

-- Unit: _cleanup unregisters the element from StateManager.
function TestCleanupDispatch:testCleanupUnregistersFromStateManager()
  local el = FlexLove.new({ id = "cleanup-unregister", width = 100, height = 50 })
  luaunit.assertEquals(el._stateId, "cleanup-unregister")
  el:_cleanup()
  -- After unregister, retained-mode cache-through resolves to nil.
  luaunit.assertNil(require("modules.StateManager").getStateValue("cleanup-unregister", "text"))
end

-- Unit: _cleanup clears callback closures (focus/text) via behavior onDetach,
-- preserving the "keeps structure for inspection" invariant (subsystem
-- instances like _eventHandler are intentionally retained for stale-element
-- inspection in immediate mode).
function TestCleanupDispatch:testCleanupClearsCallbacksKeepsStructureForInspection()
  local el = FlexLove.new({
    id = "cleanup-callbacks",
    width = 100,
    height = 50,
    onEvent = function() end,
    onFocus = function() end,
    onBlur = function() end,
  })
  luaunit.assertNotNil(el._eventHandler)
  luaunit.assertNotNil(el.onFocus)
  el:_cleanup()
  luaunit.assertNil(el.onFocus, "onFocus closure must be cleared by Clickable.onDetach")
  luaunit.assertNil(el.onBlur, "onBlur closure must be cleared by Clickable.onDetach")
  -- onEvent is intentionally preserved (Renderer/EventHandler read it directly).
  luaunit.assertNotNil(el.onEvent, "onEvent must be preserved (read directly at dispatch time)")
  -- _eventHandler is intentionally preserved ("keeps structure for inspection").
  luaunit.assertNotNil(el._eventHandler, "_eventHandler must be preserved for structure inspection")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
