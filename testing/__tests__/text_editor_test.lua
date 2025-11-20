-- Test suite for TextEditor module
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local TextEditor = require("modules.TextEditor")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local Color = require("modules.Color")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local utils = require("modules.utils")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

TestTextEditor = {}

-- Mock dependencies
local MockContext = {
  _immediateMode = false,
  _focusedElement = nil,
}

local MockStateManager = {
  getState = function(id)
    return nil
  end,
  saveState = function(id, state) end,
}

-- Helper to create TextEditor with dependencies
local function createTextEditor(config)
  config = config or {}
  return TextEditor.new(config, {
    Context = MockContext,
    StateManager = MockStateManager,
    Color = Color,
    utils = utils,
  })
end

-- Helper to create mock element
local function createMockElement()
  return {
    _stateId = "test-element-1",
    width = 200,
    height = 30,
  }
end

-- Test: new() creates instance with defaults
function TestTextEditor:test_new_creates_with_defaults()
  local editor = createTextEditor()

  luaunit.assertNotNil(editor)
  luaunit.assertFalse(editor.editable)
  luaunit.assertFalse(editor.multiline)
  luaunit.assertFalse(editor.passwordMode)
  luaunit.assertEquals(editor.inputType, "text")
  luaunit.assertEquals(editor._textBuffer, "")
  luaunit.assertEquals(editor._cursorPosition, 0)
  luaunit.assertFalse(editor._focused)
end

-- Test: new() accepts configuration
function TestTextEditor:test_new_accepts_config()
  local editor = createTextEditor({
    editable = true,
    multiline = true,
    passwordMode = true,
    text = "Hello",
    placeholder = "Enter text",
    maxLength = 100,
    inputType = "email",
  })

  luaunit.assertTrue(editor.editable)
  luaunit.assertTrue(editor.multiline)
  luaunit.assertTrue(editor.passwordMode)
  luaunit.assertEquals(editor._textBuffer, "Hello")
  luaunit.assertEquals(editor.placeholder, "Enter text")
  luaunit.assertEquals(editor.maxLength, 100)
  luaunit.assertEquals(editor.inputType, "email")
end

-- Test: new() sanitizes initial text
function TestTextEditor:test_new_sanitizes_initial_text()
  local editor = createTextEditor({
    text = "Hello\n\nWorld",
    multiline = false,
    allowNewlines = false,
  })

  -- Newlines should be removed for single-line
  luaunit.assertNotEquals(editor._textBuffer, "Hello\n\nWorld")
end

-- Test: initialize() sets element reference
function TestTextEditor:test_initialize_sets_element()
  local editor = createTextEditor()
  local element = createMockElement()

  editor:initialize(element)

  luaunit.assertEquals(editor._element, element)
end

-- Test: getText() returns current text
function TestTextEditor:test_getText_returns_text()
  local editor = createTextEditor({ text = "Hello World" })

  luaunit.assertEquals(editor:getText(), "Hello World")
end

-- Test: getText() returns empty string for nil buffer
function TestTextEditor:test_getText_returns_empty_for_nil()
  local editor = createTextEditor()
  editor._textBuffer = nil

  luaunit.assertEquals(editor:getText(), "")
end

-- Test: setText() updates text buffer
function TestTextEditor:test_setText_updates_buffer()
  local editor = createTextEditor()

  editor:setText("New text")

  luaunit.assertEquals(editor:getText(), "New text")
end

-- Test: setText() sanitizes text by default
function TestTextEditor:test_setText_sanitizes()
  local editor = createTextEditor({
    multiline = false,
    allowNewlines = false,
  })

  editor:setText("Line1\nLine2")

  -- Should remove newlines for single-line
  local text = editor:getText()
  luaunit.assertFalse(text:find("\n") ~= nil)
end

-- Test: setText() skips sanitization when requested
function TestTextEditor:test_setText_skips_sanitization()
  local editor = createTextEditor({
    multiline = false,
    allowNewlines = false,
  })

  editor:setText("Line1\nLine2", true) -- skipSanitization = true

  luaunit.assertEquals(editor:getText(), "Line1\nLine2")
end

-- Test: insertText() adds text at position
function TestTextEditor:test_insertText_at_position()
  local editor = createTextEditor({ text = "Hello" })

  editor:insertText(" World", 5)

  luaunit.assertEquals(editor:getText(), "Hello World")
end

-- Test: insertText() adds text at start
function TestTextEditor:test_insertText_at_start()
  local editor = createTextEditor({ text = "World" })

  editor:insertText("Hello ", 0)

  luaunit.assertEquals(editor:getText(), "Hello World")
end

-- Test: deleteText() removes text range
function TestTextEditor:test_deleteText_removes_range()
  local editor = createTextEditor({ text = "Hello World" })

  editor:deleteText(5, 11) -- Remove " World"

  luaunit.assertEquals(editor:getText(), "Hello")
end

-- Test: deleteText() handles reversed positions
function TestTextEditor:test_deleteText_handles_reversed()
  local editor = createTextEditor({ text = "Hello World" })

  editor:deleteText(11, 5) -- Reversed: should swap

  luaunit.assertEquals(editor:getText(), "Hello")
end

-- Test: replaceText() replaces range with new text
function TestTextEditor:test_replaceText_replaces_range()
  local editor = createTextEditor({ text = "Hello World" })

  editor:replaceText(6, 11, "Lua")

  luaunit.assertEquals(editor:getText(), "Hello Lua")
end

-- Test: setCursorPosition() sets cursor
function TestTextEditor:test_setCursorPosition()
  local editor = createTextEditor({ text = "Hello" })

  editor:setCursorPosition(3)

  luaunit.assertEquals(editor:getCursorPosition(), 3)
end

-- Test: setCursorPosition() clamps to valid range
function TestTextEditor:test_setCursorPosition_clamps()
  local editor = createTextEditor({ text = "Hello" })

  editor:setCursorPosition(100) -- Beyond text length

  luaunit.assertEquals(editor:getCursorPosition(), 5)
end

-- Test: moveCursorBy() moves cursor relative
function TestTextEditor:test_moveCursorBy()
  local editor = createTextEditor({ text = "Hello" })
  editor:setCursorPosition(2)

  editor:moveCursorBy(2)

  luaunit.assertEquals(editor:getCursorPosition(), 4)
end

-- Test: moveCursorToStart() moves to beginning
function TestTextEditor:test_moveCursorToStart()
  local editor = createTextEditor({ text = "Hello" })
  editor:setCursorPosition(3)

  editor:moveCursorToStart()

  luaunit.assertEquals(editor:getCursorPosition(), 0)
end

-- Test: moveCursorToEnd() moves to end
function TestTextEditor:test_moveCursorToEnd()
  local editor = createTextEditor({ text = "Hello" })

  editor:moveCursorToEnd()

  luaunit.assertEquals(editor:getCursorPosition(), 5)
end

-- Test: setSelection() sets selection range
function TestTextEditor:test_setSelection()
  local editor = createTextEditor({ text = "Hello World" })

  editor:setSelection(0, 5)

  local start, endPos = editor:getSelection()
  luaunit.assertEquals(start, 0)
  luaunit.assertEquals(endPos, 5)
end

-- Test: hasSelection() returns true when selected
function TestTextEditor:test_hasSelection_true()
  local editor = createTextEditor({ text = "Hello" })
  editor:setSelection(0, 5)

  luaunit.assertTrue(editor:hasSelection())
end

-- Test: hasSelection() returns false when no selection
function TestTextEditor:test_hasSelection_false()
  local editor = createTextEditor({ text = "Hello" })

  luaunit.assertFalse(editor:hasSelection())
end

-- Test: clearSelection() removes selection
function TestTextEditor:test_clearSelection()
  local editor = createTextEditor({ text = "Hello" })
  editor:setSelection(0, 5)

  editor:clearSelection()

  luaunit.assertFalse(editor:hasSelection())
end

-- Test: getSelectedText() returns selected text
function TestTextEditor:test_getSelectedText()
  local editor = createTextEditor({ text = "Hello World" })
  editor:setSelection(0, 5)

  luaunit.assertEquals(editor:getSelectedText(), "Hello")
end

-- Test: deleteSelection() removes selected text
function TestTextEditor:test_deleteSelection()
  local editor = createTextEditor({ text = "Hello World" })
  editor:setSelection(0, 6)

  editor:deleteSelection()

  luaunit.assertEquals(editor:getText(), "World")
  luaunit.assertFalse(editor:hasSelection())
end

-- Test: selectAll() selects entire text
function TestTextEditor:test_selectAll()
  local editor = createTextEditor({ text = "Hello World" })

  editor:selectAll()

  local start, endPos = editor:getSelection()
  luaunit.assertEquals(start, 0)
  luaunit.assertEquals(endPos, 11)
end

-- Test: sanitization with maxLength
function TestTextEditor:test_sanitize_max_length()
  local editor = createTextEditor({
    maxLength = 5,
  })

  editor:setText("HelloWorld")

  luaunit.assertEquals(editor:getText(), "Hello")
end

-- Test: sanitization disabled
function TestTextEditor:test_sanitization_disabled()
  local editor = createTextEditor({
    sanitize = false,
    multiline = false,
    allowNewlines = false,
  })

  editor:setText("Line1\nLine2")

  -- Should NOT sanitize newlines when disabled
  luaunit.assertEquals(editor:getText(), "Line1\nLine2")
end

-- Test: customSanitizer callback
function TestTextEditor:test_custom_sanitizer()
  local editor = createTextEditor({
    customSanitizer = function(text)
      return text:upper()
    end,
  })

  editor:setText("hello")

  luaunit.assertEquals(editor:getText(), "HELLO")
end

-- Test: allowNewlines follows multiline setting
function TestTextEditor:test_allowNewlines_follows_multiline()
  local editor = createTextEditor({
    multiline = true,
  })

  luaunit.assertTrue(editor.allowNewlines)

  editor = createTextEditor({
    multiline = false,
  })

  luaunit.assertFalse(editor.allowNewlines)
end

-- Test: allowNewlines can be overridden
function TestTextEditor:test_allowNewlines_override()
  local editor = createTextEditor({
    multiline = true,
    allowNewlines = false,
  })

  luaunit.assertFalse(editor.allowNewlines)
end

-- Test: allowTabs defaults to true
function TestTextEditor:test_allowTabs_default()
  local editor = createTextEditor()

  luaunit.assertTrue(editor.allowTabs)
end

-- Test: cursorBlinkRate default
function TestTextEditor:test_cursorBlinkRate_default()
  local editor = createTextEditor()

  luaunit.assertEquals(editor.cursorBlinkRate, 0.5)
end

-- Test: selectOnFocus default
function TestTextEditor:test_selectOnFocus_default()
  local editor = createTextEditor()

  luaunit.assertFalse(editor.selectOnFocus)
end

-- Test: onSanitize callback triggered when text is sanitized
function TestTextEditor:test_onSanitize_callback()
  local callbackCalled = false
  local originalText = nil
  local sanitizedText = nil

  local editor = createTextEditor({
    maxLength = 5,
    onSanitize = function(element, original, sanitized)
      callbackCalled = true
      originalText = original
      sanitizedText = sanitized
    end,
  })

  local mockElement = createMockElement()
  editor:initialize(mockElement)

  -- Insert text that exceeds maxLength
  editor:_sanitizeText("This is a long text that exceeds max length")

  luaunit.assertTrue(callbackCalled)
  luaunit.assertEquals(originalText, "This is a long text that exceeds max length")
  luaunit.assertEquals(sanitizedText, "This ")
end

-- Test: initialize with immediate mode and existing state
function TestTextEditor:test_initialize_immediate_mode_with_state()
  local mockStateManager = {
    getState = function(id)
      return {
        _focused = true,
        _textBuffer = "restored text",
        _cursorPosition = 10,
        _selectionStart = 2,
        _selectionEnd = 5,
        _cursorBlinkTimer = 0.3,
        _cursorVisible = false,
        _cursorBlinkPaused = true,
        _cursorBlinkPauseTimer = 1.0,
      }
    end,
    saveState = function(id, state) end,
  }

  local mockContext = {
    _immediateMode = true,
    _focusedElement = nil,
  }

  local editor = TextEditor.new({}, {
    Context = mockContext,
    StateManager = mockStateManager,
    Color = Color,
    utils = utils,
  })

  local mockElement = createMockElement()
  editor:initialize(mockElement)

  -- State should be fully restored
  luaunit.assertEquals(editor._textBuffer, "restored text")
  luaunit.assertEquals(editor._cursorPosition, 10)
  luaunit.assertEquals(editor._selectionStart, 2)
  luaunit.assertEquals(editor._selectionEnd, 5)
  luaunit.assertEquals(editor._cursorBlinkTimer, 0.3)
  luaunit.assertEquals(editor._cursorVisible, false)
  luaunit.assertEquals(editor._cursorBlinkPaused, true)
  luaunit.assertEquals(editor._cursorBlinkPauseTimer, 1.0)
  luaunit.assertTrue(editor._focused)
  luaunit.assertEquals(mockContext._focusedElement, mockElement)
end

-- Test: customSanitizer function
function TestTextEditor:test_customSanitizer()
  local editor = createTextEditor({
    customSanitizer = function(text)
      return text:upper()
    end,
  })

  local result = editor:_sanitizeText("hello world")
  luaunit.assertEquals(result, "HELLO WORLD")
end

-- Test: sanitize disabled
function TestTextEditor:test_sanitize_disabled()
  local editor = createTextEditor({
    sanitize = false,
    maxLength = 5,
  })

  local result = editor:_sanitizeText("This is a very long text")
  -- Should not be truncated since sanitize is false
  luaunit.assertEquals(result, "This is a very long text")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
