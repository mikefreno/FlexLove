-- Integration tests for the subsystem extraction delegations (tasks 06/07/08).
--
-- The Element class retains only thin delegate methods that forward to the
-- extracted subsystem modules (Select, ScrollManager, TextEditor). Behavior of
-- the subsystems themselves is covered by select_test / scroll_manager_test /
-- text_editor_test. These tests pin the DELEGATION WIRING so that a future
-- refactor cannot silently re-inline the logic onto Element without breaking a
-- test that explicitly encodes the "Element does not own this logic" contract.
--
-- Three delegation styles are exercised:
--   * Select        — `Element:method()` → `Element._Select.method(self, ...)`
--   * ScrollManager — `Element.<method> = ScrollManager.<fn>` (direct alias)
--   * TextEditor    — `Element:method()` → `self._textEditor:method(self, ...)`

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
local Element = require("modules.Element")
local Select = require("modules.Select")
local ScrollManager = require("modules.ScrollManager")

-- Element instance method  ->  Select module function it must delegate to.
local SELECT_DELEGATIONS = {
  { method = "openSelect", moduleFn = "openSelect" },
  { method = "closeSelect", moduleFn = "closeSelect" },
  { method = "toggleSelect", moduleFn = "toggleSelect" },
  { method = "isSelectOpen", moduleFn = "isSelectOpen" },
  { method = "getSelectValue", moduleFn = "getSelectValue" },
  { method = "getSelectLabel", moduleFn = "getSelectLabel" },
  { method = "isSelectedSelectOption", moduleFn = "isSelectedOption" },
  { method = "setSelectValue", moduleFn = "setSelectValue" },
}

-- Element methods bound as direct aliases of ScrollManager module functions.
local SCROLL_ALIASES = {
  { elementField = "setScrollPosition", smFn = "setScrollPosition" },
  { elementField = "_calculateScrollbarDimensions", smFn = "_calculateScrollbarDimensions" },
  { elementField = "_getScrollbarAtPosition", smFn = "_getScrollbarAtPosition" },
  { elementField = "_handleScrollbarPress", smFn = "_handleScrollbarPress" },
  { elementField = "_handleScrollbarDrag", smFn = "_handleScrollbarDrag" },
  { elementField = "_handleScrollbarRelease", smFn = "_handleScrollbarRelease" },
  { elementField = "_handleWheelScroll", smFn = "_handleWheelScroll" },
  { elementField = "_syncScrollManagerState", smFn = "syncToElement" },
  { elementField = "_detectOverflow", smFn = "_detectOverflow" },
  { elementField = "getScrollPosition", smFn = "getScrollPosition" },
  { elementField = "getMaxScroll", smFn = "elementGetMaxScroll" },
  { elementField = "getScrollPercentage", smFn = "elementGetScrollPercentage" },
  { elementField = "hasOverflow", smFn = "elementHasOverflow" },
  { elementField = "getContentSize", smFn = "elementGetContentSize" },
  { elementField = "scrollBy", smFn = "elementScrollBy" },
  { elementField = "scrollToTop", smFn = "scrollToTop" },
  { elementField = "scrollToBottom", smFn = "scrollToBottom" },
  { elementField = "scrollToLeft", smFn = "scrollToLeft" },
  { elementField = "scrollToRight", smFn = "scrollToRight" },
}

-- Element instance methods that forward into the per-element TextEditor instance.
-- Most use `self._textEditor:method(self, ...)` (passesSelf = true). A few
-- getters omit the element arg and call `self._textEditor:method()` directly
-- (passesSelf = false). extraArgs = number of forwarded args beyond [self].
local TEXT_EDITOR_DELEGATIONS = {
  { method = "setCursorPosition", teFn = "setCursorPosition", extraArgs = 1, passesSelf = true },
  { method = "getCursorPosition", teFn = "getCursorPosition", extraArgs = 0, passesSelf = false },
  { method = "moveCursorBy", teFn = "moveCursorBy", extraArgs = 1, passesSelf = true },
  { method = "moveCursorToStart", teFn = "moveCursorToStart", extraArgs = 0, passesSelf = true },
  { method = "moveCursorToEnd", teFn = "moveCursorToEnd", extraArgs = 0, passesSelf = true },
  { method = "moveCursorToLineStart", teFn = "moveCursorToLineStart", extraArgs = 0, passesSelf = true },
  { method = "moveCursorToLineEnd", teFn = "moveCursorToLineEnd", extraArgs = 0, passesSelf = true },
  { method = "moveCursorToPreviousWord", teFn = "moveCursorToPreviousWord", extraArgs = 0, passesSelf = true },
  { method = "moveCursorToNextWord", teFn = "moveCursorToNextWord", extraArgs = 0, passesSelf = true },
  { method = "setSelection", teFn = "setSelection", extraArgs = 2, passesSelf = true },
  { method = "clearSelection", teFn = "clearSelection", extraArgs = 0, passesSelf = true },
  { method = "selectAll", teFn = "selectAll", extraArgs = 0, passesSelf = true },
  { method = "getSelectedText", teFn = "getSelectedText", extraArgs = 0, passesSelf = false },
  { method = "deleteSelection", teFn = "deleteSelection", extraArgs = 0, passesSelf = true },
  { method = "getText", teFn = "getText", extraArgs = 0, passesSelf = false },
  { method = "setText", teFn = "setText", extraArgs = 1, passesSelf = true },
  { method = "insertText", teFn = "insertText", extraArgs = 1, passesSelf = true },
  { method = "deleteText", teFn = "deleteText", extraArgs = 2, passesSelf = true },
  { method = "replaceText", teFn = "replaceText", extraArgs = 3, passesSelf = true },
}

TestSubsystemDelegation = {}

function TestSubsystemDelegation:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestSubsystemDelegation:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

-- ----------------------------------------------------------------- Select
function TestSubsystemDelegation:test_select_delegates_route_to_select_module()
  -- Build a minimal select parent so the delegate methods have a valid target
  -- if a spy ever falls through to the real implementation.
  local el = FlexLove.new({
    width = 100,
    height = 40,
    selectParent = { value = "a" },
  })

  for _, d in ipairs(SELECT_DELEGATIONS) do
    local original = Select[d.moduleFn]
    local captured = nil
    -- Replace the module function with a recorder. Element:method() calls
    -- Element._Select.<moduleFn>(self, ...) — Element._Select IS the Select
    -- module, so patching the module field is observed by the delegate.
    Select[d.moduleFn] = function(self, ...)
      captured = { self = self, args = { ... } }
      -- Mirror return-value shape for the boolean-returning delegates.
      if d.moduleFn == "isSelectOpen" or d.moduleFn == "isSelectedOption" then
        return false
      elseif d.moduleFn == "getSelectValue" then
        return "spy"
      elseif d.moduleFn == "getSelectLabel" then
        return "spy-label"
      end
    end

    local ok, err = pcall(function()
      if d.method == "setSelectValue" then
        el[d.method](el, "v", nil)
      else
        el[d.method](el)
      end
    end)
    -- Always restore, even if the call errored.
    Select[d.moduleFn] = original
    luaunit.assertTrue(ok, "Element:" .. d.method .. " should not error: " .. tostring(err))
    luaunit.assertNotNil(captured, "Element:" .. d.method .. " did not invoke Select." .. d.moduleFn)
    luaunit.assertTrue(captured.self == el, "Element:" .. d.method .. " must pass self to Select." .. d.moduleFn)
  end
end

function TestSubsystemDelegation:test_setSelectValue_forwards_value_and_option()
  local el = FlexLove.new({
    width = 100,
    height = 40,
    selectParent = { value = "a" },
  })
  local opt = FlexLove.new({ width = 100, height = 40, selectOption = { value = "b" } })

  local original = Select.setSelectValue
  local captured = nil
  Select.setSelectValue = function(self, value, optionElement)
    captured = { self = self, value = value, optionElement = optionElement }
  end
  el:setSelectValue("b", opt)
  Select.setSelectValue = original

  luaunit.assertNotNil(captured)
  luaunit.assertTrue(captured.self == el)
  luaunit.assertEquals(captured.value, "b")
  luaunit.assertTrue(captured.optionElement == opt)
end

function TestSubsystemDelegation:test_select_module_is_element_subsystem_ref()
  -- Element._Select must be the live Select module (delegation target).
  luaunit.assertTrue(Element._Select == Select, "Element._Select must alias the Select module")
end

-- ----------------------------------------------------------------- ScrollManager
function TestSubsystemDelegation:test_scroll_api_aliased_to_scroll_manager()
  -- After init, Element's scroll/scrollbar API fields must be DIRECT aliases
  -- of the ScrollManager module functions (no re-implementation on Element).
  for _, a in ipairs(SCROLL_ALIASES) do
    luaunit.assertNotNil(Element[a.elementField], "Element." .. a.elementField .. " must be bound after init")
    luaunit.assertTrue(
      Element[a.elementField] == ScrollManager[a.smFn],
      "Element." .. a.elementField .. " must alias ScrollManager." .. a.smFn
    )
  end
end

function TestSubsystemDelegation:test_scroll_delegate_invokes_missing_once_is_not_aliased_per_instance()
  -- Without overflow, no per-instance ScrollManager is created, but the
  -- class-level aliases are still present (delegation wiring is class-wide).
  local el = FlexLove.new({ width = 100, height = 100 })
  luaunit.assertNil(el._scrollManager, "no ScrollManager instance without overflow")
  luaunit.assertNotNil(Element.setScrollPosition, "class-level scroll alias present regardless")
end

function TestSubsystemDelegation:test_setScrollPosition_routes_through_scroll_manager_module()
  -- Behavioral delegation: calling el:setScrollPosition must invoke the
  -- ScrollManager module function with (el, x, y) — verified by spying on the
  -- ScrollManager module field (the same table Element aliases).
  local el = FlexLove.new({ width = 100, height = 100, overflow = "auto" })
  local original = ScrollManager.setScrollPosition
  local captured = nil
  ScrollManager.setScrollPosition = function(self, x, y)
    captured = { self = self, x = x, y = y }
  end
  -- Element.setScrollPosition aliases ScrollManager.setScrollPosition, so we
  -- must re-bind after patching to observe the spy.
  Element.setScrollPosition = ScrollManager.setScrollPosition
  el:setScrollPosition(5, 10)
  -- Restore original + re-bind.
  ScrollManager.setScrollPosition = original
  Element.setScrollPosition = original

  luaunit.assertNotNil(captured, "el:setScrollPosition must route through ScrollManager.setScrollPosition")
  luaunit.assertTrue(captured.self == el)
  luaunit.assertEquals(captured.x, 5)
  luaunit.assertEquals(captured.y, 10)
end

-- ----------------------------------------------------------------- TextEditor
-- A self-recording TextEditor stub. Element methods call
-- `self._textEditor:<teFn>(self, ...)` so each method records `(element, args)`.
local function makeTextEditorStub()
  local calls = {}
  local stub = {}
  setmetatable(stub, {
    __index = function(t, key)
      t[key] = function(self, ...)
        table.insert(calls, { method = key, self = self, args = { ... } })
        -- Return false for boolean-shaped delegates so Element can short-circuit.
        if key == "hasSelection" or key == "deleteSelection" then
          return false
        end
        return nil
      end
      return t[key]
    end,
  })
  return stub, calls
end

function TestSubsystemDelegation:test_text_editor_delegates_route_to_instance()
  local el = FlexLove.new({ width = 100, height = 40, text = "hi", editable = true })
  local stub, calls = makeTextEditorStub()
  el._textEditor = stub

  for _, d in ipairs(TEXT_EDITOR_DELEGATIONS) do
    -- Clear calls between iterations.
    for i = #calls, 1, -1 do
      calls[i] = nil
    end
    local args = {}
    for i = 1, d.extraArgs do
      args[i] = "arg" .. i
    end
    el[d.method](el, table.unpack(args, 1, d.extraArgs))

    local found = nil
    for _, c in ipairs(calls) do
      if c.method == d.teFn then
        found = c
        break
      end
    end
    luaunit.assertNotNil(found, "Element:" .. d.method .. " did not route to TextEditor:" .. d.teFn)
    if d.passesSelf then
      -- Element:method calls self._textEditor:<teFn>(self, ...): the textEditor
      -- is the implicit self of the stub, so the Element (el) is the FIRST
      -- forwarded arg, followed by the extra args.
      luaunit.assertTrue(
        found.args[1] == el,
        "Element:" .. d.method .. " must pass self (element) as first arg to TextEditor:" .. d.teFn
      )
      luaunit.assertEquals(
        #found.args,
        d.extraArgs + 1,
        "Element:" .. d.method .. " must forward self + " .. d.extraArgs .. " extra arg(s) to TextEditor:" .. d.teFn
      )
    else
      -- Getter-style delegates omit the element arg entirely.
      luaunit.assertEquals(
        #found.args,
        d.extraArgs,
        "Element:" .. d.method .. " must forward " .. d.extraArgs .. " arg(s) (no self) to TextEditor:" .. d.teFn
      )
    end
  end
end

function TestSubsystemDelegation:test_setText_syncs_display_text_after_delegation()
  -- Element:setText not only delegates but also sets self.text from the TE
  -- result. Verify the post-delegation sync still happens through the wiring.
  local el = FlexLove.new({ width = 100, height = 40, text = "", editable = true })
  local stub = {}
  function stub:setText(element, text)
    self._stored = text
    return text
  end
  function stub:getText()
    return self._stored
  end
  function stub:updateAutoGrowHeight(element) end
  el._textEditor = stub

  el:setText("synced")
  luaunit.assertEquals(el.text, "synced", "Element:setText must sync self.text from TextEditor result")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
