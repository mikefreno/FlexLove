-- Unit + integration tests for modules.Behavior.lua.
--
-- Validates the pluggable behavior base interface that tasks 02-07 (concrete
-- behaviors) build on top of and tasks 08+ consume from Element.new.
--
-- Coverage:
--   * Creation — Behavior.new returns a table with all 6 lifecycle hooks present
--   * Default no-ops — calling any un-overridden hook is safe (no error)
--   * Custom hook overrides — provided hooks take effect, others stay default
--   * shouldAttach — defaults to false when not provided; custom predicate honored
--   * Immutability / validation — unknown keys, non-functions, frozen instances
--   * Integration — Element:_construct initializes `behaviors = {}` on new elements

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

-- Behavior is pure Lua (no love dependency); the stub is loaded only to mirror
-- the FlexLove test harness so require("modules.Behavior") resolves identically
-- in both standalone and full-suite runs. The module must NOT import love.
require("testing.loveStub")
local luaunit = require("testing.luaunit")
local Behavior = require("modules.Behavior")
local FlexLove = require("FlexLove")

local HOOK_NAMES = {
  "onAttach",
  "onDetach",
  "onUpdate",
  "onDraw",
  "saveState",
  "restoreState",
}

-- ============================================================================
-- Creation
-- ============================================================================

TestBehaviorCreation = {}

function TestBehaviorCreation:testNew_EmptySpecReturnsTableWithAllHooks()
  local b = Behavior.new({})
  luaunit.assertNotNil(b)
  for _, hook in ipairs(HOOK_NAMES) do
    luaunit.assertEquals(type(b[hook]), "function", hook .. " should be present as a function")
  end
  luaunit.assertEquals(type(b.shouldAttach), "function")
end

function TestBehaviorCreation:testNew_NilSpecReturnsDefaults()
  local b = Behavior.new(nil)
  luaunit.assertNotNil(b)
  for _, hook in ipairs(HOOK_NAMES) do
    luaunit.assertEquals(type(b[hook]), "function", hook .. " should default to a no-op function")
  end
end

function TestBehaviorCreation:testNew_ReturnsABehaviorInstance()
  local b = Behavior.new({})
  -- Type guard: Behavior.isBehavior recognizes instances produced by the factory.
  luaunit.assertTrue(Behavior.isBehavior(b))
  luaunit.assertFalse(Behavior.isBehavior({}))
  luaunit.assertFalse(Behavior.isBehavior(nil))
  luaunit.assertFalse(Behavior.isBehavior("string"))
end

function TestBehaviorCreation:testNew_HookNamesExportMatchesExpectedSet()
  -- HOOK_NAMES is the locked lifecycle contract; tasks 02-13 depend on exactly
  -- these six in this order. Guard against accidental extension.
  luaunit.assertEquals(#Behavior.HOOK_NAMES, 6)
  for i, name in ipairs(HOOK_NAMES) do
    luaunit.assertEquals(Behavior.HOOK_NAMES[i], name)
  end
end

-- ============================================================================
-- Default no-ops
-- ============================================================================

TestBehaviorNoOps = {}

function TestBehaviorNoOps:testDefaultHooks_DoNotErrorAndReturnNil()
  local b = Behavior.new({})
  local el = { id = "stub-element" }
  -- None of these should error; they are safe no-ops callable without nil-checks.
  b.onAttach(el)
  b.onDetach(el)
  b.onUpdate(el, 0.016)
  b.onDraw(el, { viewport = { w = 800, h = 600 } })
  local state = b.saveState(el)
  luaunit.assertIsNil(state)
  b.restoreState(el, nil)
  b.restoreState(el, { cursor = 3 })
end

function TestBehaviorNoOps:testOnDrawWithoutCustomHookIsANoOp()
  -- Explicit acceptance test from the task spec: a behavior that only supplies
  -- onUpdate must still accept an onDraw call without erroring.
  local b = Behavior.new({ onUpdate = function() end })
  b.onDraw({}, {})
  b.onDraw(nil, nil)
  luaunit.assertTrue(true, "onDraw no-op completed without error")
end

function TestBehaviorNoOps:testDefaultShouldAttachIsFalseForArbitraryProps()
  -- The default predicate never auto-attaches, regardless of props content.
  local b = Behavior.new({})
  luaunit.assertFalse(b.shouldAttach({}))
  luaunit.assertFalse(b.shouldAttach({ scrollable = true }))
  luaunit.assertFalse(b.shouldAttach({ editable = true, multiline = true }))
  luaunit.assertFalse(b.shouldAttach(nil))
end

-- ============================================================================
-- Custom hook overrides
-- ============================================================================

TestBehaviorOverrides = {}

function TestBehaviorOverrides:testOnUpdateOverridden_OthersStayDefault()
  local calls = {}
  local fn = function(element, dt)
    table.insert(calls, { element = element, dt = dt })
  end
  local b = Behavior.new({ onUpdate = fn })

  -- The custom hook is installed verbatim (same reference).
  luaunit.assertIs(b.onUpdate, fn)

  -- The other hooks remain no-ops (still callable, do not error).
  b.onAttach({})
  b.onDetach({})
  b.onDraw({}, {})
  local state = b.saveState({})
  luaunit.assertIsNil(state)
  b.restoreState({}, state)

  -- shouldAttach defaults to false (not overridden).
  luaunit.assertFalse(b.shouldAttach({ onUpdate = true }))

  -- Invoking onUpdate actually routes to the custom function.
  local el = { id = "el" }
  b.onUpdate(el, 0.5)
  luaunit.assertEquals(#calls, 1)
  luaunit.assertIs(calls[1].element, el)
  luaunit.assertEquals(calls[1].dt, 0.5)
end

function TestBehaviorOverrides:testEveryHookIsIndependentlyOverridable()
  local counters = { attach = 0, detach = 0, update = 0, draw = 0, save = 0, restore = 0 }
  local saved = nil
  local b = Behavior.new({
    onAttach = function(_)
      counters.attach = counters.attach + 1
    end,
    onDetach = function(_)
      counters.detach = counters.detach + 1
    end,
    onUpdate = function(_, dt)
      counters.update = counters.update + (dt > 0 and 1 or 0)
    end,
    onDraw = function(_, _)
      counters.draw = counters.draw + 1
    end,
    saveState = function(_)
      counters.save = counters.save + 1
      return { cursor = 7 }
    end,
    restoreState = function(_, st)
      counters.restore = counters.restore + 1
      saved = st
    end,
  })

  b.onAttach({})
  b.onDetach({})
  b.onUpdate({}, 0.016)
  b.onDraw({}, {})
  local st = b.saveState({})
  b.restoreState({}, st)

  luaunit.assertEquals(counters.attach, 1)
  luaunit.assertEquals(counters.detach, 1)
  luaunit.assertEquals(counters.update, 1)
  luaunit.assertEquals(counters.draw, 1)
  luaunit.assertEquals(counters.save, 1)
  luaunit.assertEquals(counters.restore, 1)
  luaunit.assertNotNil(st, "saveState must return the provided snapshot")
  luaunit.assertEquals(st.cursor, 7)
  luaunit.assertIs(saved, st, "restoreState must receive the exact saveState return value")
end

function TestBehaviorOverrides:testShouldAttach_CustomPredicateTrueAndFalse()
  local b = Behavior.new({
    shouldAttach = function(props)
      return props.tooltip == true
    end,
  })
  luaunit.assertTrue(b.shouldAttach({ tooltip = true }))
  luaunit.assertFalse(b.shouldAttach({ tooltip = false }))
  luaunit.assertFalse(b.shouldAttach({}))
  luaunit.assertFalse(b.shouldAttach({ other = true }))
end

function TestBehaviorOverrides:testShouldAttach_CanInspectArbitraryProps()
  -- Predicates may read nested props (mirrors how tasks 03/04 will gate on
  -- scrollable/editable/multiline etc.).
  local b = Behavior.new({
    shouldAttach = function(props)
      return props.style ~= nil and props.style.direction == "column"
    end,
  })
  luaunit.assertTrue(b.shouldAttach({ style = { direction = "column" } }))
  luaunit.assertFalse(b.shouldAttach({ style = { direction = "row" } }))
  luaunit.assertFalse(b.shouldAttach({}))
end

function TestBehaviorOverrides:testModuleLevelShouldAttachDefaultsFalse()
  -- The module exposes the base default predicate directly.
  luaunit.assertFalse(Behavior.shouldAttach({}))
  luaunit.assertFalse(Behavior.shouldAttach({ anything = true }))
end

-- ============================================================================
-- Validation & immutability
-- ============================================================================

TestBehaviorValidation = {}

function TestBehaviorValidation:testNew_RejectsUnknownSpecKey()
  luaunit.assertErrorMsgContains("unknown spec key", function()
    Behavior.new({ onUpdat = function() end }) -- typo: should be onUpdate
  end)
end

function TestBehaviorValidation:testNew_RejectsNonFunctionHook()
  luaunit.assertErrorMsgContains("must be a function", function()
    Behavior.new({ onUpdate = 42 })
  end)
end

function TestBehaviorValidation:testNew_RejectsNonFunctionShouldAttach()
  luaunit.assertErrorMsgContains("must be a function", function()
    Behavior.new({ shouldAttach = "yes" })
  end)
end

function TestBehaviorValidation:testNew_RejectsNonFunctionForEveryHook()
  for _, hook in ipairs(HOOK_NAMES) do
    luaunit.assertErrorMsgContains(hook, function()
      Behavior.new({ [hook] = {} })
    end)
  end
end

function TestBehaviorValidation:testInstanceIsFrozenAgainstNewFields()
  local b = Behavior.new({})
  luaunit.assertErrorMsgContains("immutable", function()
    b.someNewField = "nope"
  end)
  -- Hook reassignment is discouraged but Lua metatables cannot intercept writes
  -- to existing keys; verify the canonical accessor still resolves the hook.
  luaunit.assertEquals(type(b.onUpdate), "function")
end

function TestBehaviorValidation:testInstancesShareNoOpDefaults()
  -- no-op hooks are the same function reference across instances — cheap and
  -- lets dispatch sites compare identity when needed.
  local a = Behavior.new({})
  local c = Behavior.new({ onDraw = function() end })
  luaunit.assertIs(a.onAttach, a.onDetach, "default no-op hooks are shared")
  luaunit.assertIs(a.onUpdate, Behavior.new({}).onUpdate, "default hooks shared across instances")
  -- An overridden hook must NOT compare equal to the shared default.
  luaunit.assertNotIs(c.onDraw, a.onDraw, "overridden hook must differ from default")
end

-- ============================================================================
-- Integration: Element._construct initializes `behaviors = {}`
-- ============================================================================

TestBehaviorIntegration = {}

function TestBehaviorIntegration:setUp()
  -- Element is a FlexLove module; init + beginFrame before constructing elements.
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestBehaviorIntegration:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestBehaviorIntegration:testNewElement_AttachesThemedRenderBehavior()
  -- Task 07: the Themed behavior owns the per-element Renderer + the single
  -- Renderer:draw call, and attaches to every renderable Element (mirroring the
  -- pre-refactor invariant that every element had a Renderer). So a freshly
  -- constructed element always has at least the Thamed behavior attached.
  local Themed = require("modules.behaviors.Themed")
  local element = FlexLove.new({
    id = "behavior-int-1",
    width = 100,
    height = 50,
  })
  luaunit.assertNotNil(element.behaviors)
  luaunit.assertEquals(type(element.behaviors), "table")
  luaunit.assertNotIsNil(next(element.behaviors), "every element attaches the Thamed render behavior")
  local themedAttached = false
  for _, b in ipairs(element.behaviors) do
    if b == Themed then
      themedAttached = true
      break
    end
  end
  luaunit.assertTrue(themedAttached, "Thamed render behavior must be auto-attached")
end

function TestBehaviorIntegration:testEachNewElement_GetsIndependentBehaviorsTable()
  local a = FlexLove.new({ id = "behavior-int-a", width = 10, height = 10 })
  local b = FlexLove.new({ id = "behavior-int-b", width = 10, height = 10 })
  luaunit.assertNotIs(a.behaviors, b.behaviors, "each element must own its behaviors table")
  -- Writing to one element's behaviors table must not leak into another.
  a.behaviors.placeholder = true
  luaunit.assertIsNil(b.behaviors.placeholder, "writes to one element must not leak into another")
end

function TestBehaviorIntegration:testBehaviorsFieldPresentAcrossElementTypes()
  -- Every element exposes a `behaviors` slot because _construct runs for all.
  -- Interactive elements (here: an editable text element) auto-attach the
  -- Clickable behavior via shouldAttach(editable=true) ON TOP of the always-
  -- attached Thamed render behavior. A passive scrollable container has no
  -- interaction props so it attaches only Thamed (no Clickable) until the
  -- Scrollable behavior lands in a later task.
  local text = FlexLove.new({ id = "behavior-int-text", width = 100, height = 30, text = "hi", editable = true })
  local panel = FlexLove.new({ id = "behavior-int-panel", width = 200, height = 200, scrollable = true })
  for _, el in ipairs({ text, panel }) do
    luaunit.assertNotNil(el.behaviors)
    luaunit.assertEquals(type(el.behaviors), "table")
  end
  -- editable element attaches Clickable (in addition to the always-present Thamed)
  luaunit.assertNotIsNil(next(text.behaviors), "editable element should attach at least the Thamed behavior")
  -- passive scrollable container attaches only the Thamed render behavior
  luaunit.assertNotIsNil(next(panel.behaviors), "passive panel attaches the Thamed render behavior")
end

-- ============================================================================
-- Selectable behavior (task 05)
-- ============================================================================

TestSelectableBehavior = {}

function TestSelectableBehavior:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestSelectableBehavior:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestSelectableBehavior:testShouldAttach_SelectParentConfigTrue()
  local Selectable = require("modules.behaviors.Selectable")
  luaunit.assertTrue(Selectable.shouldAttach({ selectParent = { value = "a" } }))
end

function TestSelectableBehavior:testShouldAttach_SelectOptionConfigTrue()
  local Selectable = require("modules.behaviors.Selectable")
  luaunit.assertTrue(Selectable.shouldAttach({ selectOption = { value = "x" } }))
end

function TestSelectableBehavior:testShouldAttach_EmptyPropsFalse()
  local Selectable = require("modules.behaviors.Selectable")
  luaunit.assertFalse(Selectable.shouldAttach({}))
end

function TestSelectableBehavior:testShouldAttach_NonTableSelectParentFalse()
  local Selectable = require("modules.behaviors.Selectable")
  luaunit.assertFalse(Selectable.shouldAttach({ selectParent = "not a table" }))
end

function TestSelectableBehavior:testShouldAttach_NilPropsFalse()
  local Selectable = require("modules.behaviors.Selectable")
  luaunit.assertFalse(Selectable.shouldAttach(nil))
end

function TestSelectableBehavior:testAutoAttach_SelectParentElement()
  -- A select-parent element should have the Selectable behavior attached.
  local Selectable = require("modules.behaviors.Selectable")
  local sp = FlexLove.new({
    id = "sel-behavior-sp",
    width = 200,
    height = 40,
    selectParent = { value = "a" },
  })
  local found = false
  for _, b in ipairs(sp.behaviors) do
    if b == Selectable then
      found = true
      break
    end
  end
  luaunit.assertTrue(found, "Selectable behavior should be auto-attached to select parent")
end

function TestSelectableBehavior:testAutoAttach_SelectOptionElement()
  local Selectable = require("modules.behaviors.Selectable")
  local sp = FlexLove.new({
    id = "sel-behavior-sp2",
    width = 200,
    height = 40,
    selectParent = { value = "a" },
  })
  local opt = FlexLove.new({
    id = "sel-behavior-opt",
    parent = sp,
    width = 200,
    height = 30,
    selectOption = { value = "a" },
  })
  local found = false
  for _, b in ipairs(opt.behaviors) do
    if b == Selectable then
      found = true
      break
    end
  end
  luaunit.assertTrue(found, "Selectable behavior should be auto-attached to select option")
end

function TestSelectableBehavior:testAutoAttach_PlainElementFalse()
  -- A plain element with no select props should NOT have Selectable attached.
  local Selectable = require("modules.behaviors.Selectable")
  local el = FlexLove.new({
    id = "sel-behavior-plain",
    width = 100,
    height = 50,
  })
  local found = false
  for _, b in ipairs(el.behaviors) do
    if b == Selectable then
      found = true
      break
    end
  end
  luaunit.assertFalse(found, "Selectable behavior should NOT attach to plain elements")
end

-- Run tests if this file is executed directly.
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
