-- Unit + integration tests for modules.behaviors.TextEditable (task 04).
--
-- Validates the concrete TextEditable behavior extracted from Element:
-- _initSubSystems (TextEditor creation + immediate-mode restore), Element:update
-- (cursor blink), and the 27 text-editor delegate methods (+ save/restore).
--
-- Coverage:
--   * shouldAttach predicate — matches the spec cases (editable → true,
--     text ~= nil → true, {} → false).
--   * Behavior interface conformance — TextEditable is a Behavior instance
--     exposing all 6 lifecycle hooks (callable, no-op-safe) + shouldAttach.
--   * Integration — Element.new attaches TextEditable to editable elements and
--     allocates self._textEditor via onAttach; non-editable text elements
--     attach the behavior but allocate no TextEditor; element:update drives
--     cursor blink through the behavior.
--   * Delegate routing — Element:method() forwards to the TextEditable module
--     functions, which in turn route to self._textEditor:<teFn>(element, ...).
--     (The full delegation contract is pinned by subsystem_delegation_test.lua;
--     here we sanity-check a couple of representative forwarders.)

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
local TextEditable = require("modules.behaviors.TextEditable")
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
-- shouldAttach predicate (spec acceptance cases)
-- ============================================================================

TestTextEditableShouldAttach = {}

function TestTextEditableShouldAttach:testEditable_Attaches()
  -- Spec acceptance case: shouldAttach({editable = true}) -> true
  luaunit.assertTrue(TextEditable.shouldAttach({ editable = true }))
end

function TestTextEditableShouldAttach:testEmptyProps_DoesNotAttach()
  -- Spec acceptance case: shouldAttach({}) -> false
  luaunit.assertFalse(TextEditable.shouldAttach({}))
  luaunit.assertFalse(TextEditable.shouldAttach(nil))
end

function TestTextEditableShouldAttach:testText_Attaches()
  -- Spec predicate: text ~= nil attaches (text-bearing element).
  luaunit.assertTrue(TextEditable.shouldAttach({ text = "hi" }))
  luaunit.assertTrue(TextEditable.shouldAttach({ text = "" }))
end

function TestTextEditableShouldAttach:testNilText_DoesNotAttach()
  -- No editable, no text -> false.
  luaunit.assertFalse(TextEditable.shouldAttach({ width = 100, height = 50 }))
  luaunit.assertFalse(TextEditable.shouldAttach({ scrollable = true }))
end

-- ============================================================================
-- Behavior interface conformance
-- ============================================================================

TestTextEditableInterface = {}

function TestTextEditableInterface:testIsBehaviorInstance()
  -- TextEditable exposes the frozen behavior instance via the module table's
  -- __index metatable (mirrors the Animated pattern); the frozen instance is a
  -- valid Behavior.
  luaunit.assertTrue(Behavior.isBehavior(TextEditable.behavior))
end

function TestTextEditableInterface:testAllHooksCallable()
  -- shouldAttach + every lifecycle hook must be a callable function on the
  -- module table (resolving through __index to the frozen instance).
  luaunit.assertEquals(type(TextEditable.shouldAttach), "function")
  for _, hook in ipairs(HOOK_NAMES) do
    luaunit.assertEquals(type(TextEditable[hook]), "function", hook .. " should be a function")
  end
end

function TestTextEditableInterface:testDefaultHooksDoNotError()
  -- onDraw / onDetach must be safe to call on an element with no TextEditor.
  local el = { x = 0, y = 0 }
  luaunit.assertNil(TextEditable.onDraw(el, {}))
  luaunit.assertNil(TextEditable.onDetach(el))
  -- onUpdate on a TextEditor-less element is a guarded no-op.
  luaunit.assertNil(TextEditable.onUpdate(el, 0.016))
  -- saveState returns nil for a TextEditor-less element with no drag state.
  luaunit.assertNil(TextEditable.saveState(el))
  -- restoreState with no state is a no-op.
  luaunit.assertNil(TextEditable.restoreState(el, nil))
end

-- ============================================================================
-- Integration: onAttach allocates the TextEditor
-- ============================================================================

TestTextEditableIntegration = {}

function TestTextEditableIntegration:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestTextEditableIntegration:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

local function findBehavior(element, behavior)
  for _, b in ipairs(element.behaviors) do
    if b == behavior then
      return true
    end
  end
  return false
end

function TestTextEditableIntegration:testEditableElement_AttachesBehaviorAndTextEditor()
  local el = FlexLove.new({ id = "te-editable", width = 100, height = 30, text = "hi", editable = true })
  luaunit.assertTrue(findBehavior(el, TextEditable), "editable element should attach TextEditable")
  luaunit.assertNotNil(el._textEditor, "onAttach should allocate the TextEditor")
  luaunit.assertEquals(el._textEditor:getText(), "hi")
end

function TestTextEditableIntegration:testNonEditableTextElement_AttachesBehaviorButNoTextEditor()
  -- A text-bearing but non-editable element attaches the behavior (per
  -- shouldAttach) but onAttach does NOT allocate a TextEditor, preserving the
  -- pre-refactor invariant.
  local el = FlexLove.new({ id = "te-label", width = 100, height = 30, text = "label" })
  luaunit.assertTrue(findBehavior(el, TextEditable), "text element should attach TextEditable")
  luaunit.assertNil(el._textEditor, "non-editable element must not allocate a TextEditor")
  -- And the forwarders route through the non-editable branch:
  luaunit.assertEquals(el:getText(), "label")
  el:setText("new")
  luaunit.assertEquals(el.text, "new")
end

function TestTextEditableIntegration:testPlainElement_DoesNotAttach()
  local el = FlexLove.new({ id = "te-plain", width = 100, height = 50 })
  luaunit.assertFalse(findBehavior(el, TextEditable), "plain element should not attach TextEditable")
  luaunit.assertNil(el._textEditor)
end

function TestTextEditableIntegration:testUpdate_DrivesCursorBlinkViaBehavior()
  -- element:update must drive TextEditor:update (cursor blink) through the
  -- behavior dispatch loop, with no inline text-editor reference in
  -- Element:update. We spy on TextEditor:update to confirm dispatch.
  local el = FlexLove.new({ id = "te-blink", width = 100, height = 30, text = "x", editable = true })
  local called = false
  local realUpdate = el._textEditor.update
  el._textEditor.update = function(self, element, dt)
    called = true
    luaunit.assertTrue(element == el)
  end
  el:update(0.016)
  el._textEditor.update = realUpdate
  luaunit.assertTrue(called, "Element:update must dispatch cursor blink to TextEditor:update")
end

function TestTextEditableIntegration:testSaveRestore_RoundTripsTextEditorState()
  local el = FlexLove.new({ id = "te-save", width = 100, height = 30, text = "abc", editable = true })
  el._textEditor._cursorPosition = 2
  local snapshot = TextEditable.saveState(el)
  luaunit.assertNotNil(snapshot)
  luaunit.assertNotNil(snapshot.textEditor)
  luaunit.assertEquals(snapshot.textEditor._cursorPosition, 2)

  -- Restore into a fresh element.
  local el2 = FlexLove.new({ id = "te-restore", width = 100, height = 30, text = "abc", editable = true })
  TextEditable.restoreState(el2, snapshot)
  luaunit.assertEquals(el2._textEditor._cursorPosition, 2)
  -- The Element field sync (cursor/selection) is applied:
  luaunit.assertEquals(el2._cursorPosition, 2)
end

-- ============================================================================
-- Delegate routing sanity (full contract in subsystem_delegation_test.lua)
-- ============================================================================

TestTextEditableDelegates = {}

function TestTextEditableDelegates:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestTextEditableDelegates:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestTextEditableDelegates:testSetText_ForwardsToTextEditorAndSyncsDisplayText()
  local el = FlexLove.new({ id = "te-settext", width = 100, height = 30, text = "", editable = true })
  el:setText("synced")
  luaunit.assertEquals(el.text, "synced", "setText must sync element.text from the TextEditor result")
  luaunit.assertEquals(el._textEditor:getText(), "synced")
end

function TestTextEditableDelegates:testGetText_ForwardsToTextEditor()
  local el = FlexLove.new({ id = "te-gettext", width = 100, height = 30, text = "hello", editable = true })
  luaunit.assertEquals(el:getText(), "hello")
end

function TestTextEditableDelegates:testForwardersAreOneLine_NoTextEditorBranchInElement()
  -- Acceptance: Element.lua must contain zero `if self._textEditor` code
  -- branches. Read the source and assert the literal count is 0.
  local f = io.open("modules/Element.lua", "r")
  luaunit.assertNotNil(f)
  local src = f:read("*all")
  f:close()
  -- Count occurrences of the nil-guard branch that the refactor eliminates.
  -- Comments may legitimately mention the pattern, so we strip Lua comments
  -- (lines starting with --) before counting.
  local code = src:gsub("%-%-[^\n]*", "")
  local _, count = code:gsub("if self%._textEditor", "")
  luaunit.assertEquals(count, 0, "Element.lua must have zero `if self._textEditor` branches")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
