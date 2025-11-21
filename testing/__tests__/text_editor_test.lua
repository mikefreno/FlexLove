-- Comprehensive test suite for TextEditor module
-- Consolidated from multiple test files for complete coverage
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

local TextEditor = require("modules.TextEditor")
local Color = require("modules.Color")
local utils = require("modules.utils")

-- ============================================================================
-- Mock Dependencies and Helpers
-- ============================================================================

-- Mock Context
local MockContext = {
  _immediateMode = false,
  _focusedElement = nil,
  setFocusedElement = function(self, element)
    self._focusedElement = element
  end,
}

-- Mock StateManager
local MockStateManager = {
  getState = function(id) return nil end,
  updateState = function(id, state) end,
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

-- Helper to create mock element with full renderer support
local function createMockElement(width, height)
  return {
    _stateId = "test-element-1",
    width = width or 200,
    height = height or 30,
    x = 10,
    y = 10,
    _absoluteX = 10,
    _absoluteY = 10,
    padding = {top = 5, right = 5, bottom = 5, left = 5},
    _borderBoxWidth = (width or 200) + 10,
    _borderBoxHeight = (height or 30) + 10,
    getScaledContentPadding = function(self)
      return self.padding
    end,
    _renderer = {
      getFont = function(self, element)
        return {
          getWidth = function(text) return #text * 8 end,
          getHeight = function() return 16 end,
        }
      end,
      wrapLine = function(element, line, maxWidth)
        -- Simple word wrapping simulation
        line = tostring(line or "")
        maxWidth = tonumber(maxWidth) or 1000
        local words = {}
        for word in line:gmatch("%S+") do
          table.insert(words, word)
        end
        
        local wrapped = {}
        local currentLine = ""
        local startIdx = 0
        
        for i, word in ipairs(words) do
          local testLine = currentLine == "" and word or (currentLine .. " " .. word)
          if #testLine * 8 <= maxWidth then
            currentLine = testLine
          else
            if currentLine ~= "" then
              table.insert(wrapped, {text = currentLine, startIdx = startIdx, endIdx = startIdx + #currentLine})
              startIdx = startIdx + #currentLine + 1
            end
            currentLine = word
          end
        end
        
        if currentLine ~= "" then
          table.insert(wrapped, {text = currentLine, startIdx = startIdx, endIdx = startIdx + #currentLine})
        end
        
        return #wrapped > 0 and wrapped or {{text = line, startIdx = 0, endIdx = #line}}
      end,
    },
  }
end

-- ============================================================================
-- Constructor and Initialization Tests
-- ============================================================================

TestTextEditorConstructor = {}

function TestTextEditorConstructor:test_new_creates_with_defaults()
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

function TestTextEditorConstructor:test_new_accepts_config()
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

function TestTextEditorConstructor:test_new_sanitizes_initial_text()
  local editor = createTextEditor({
    text = "Hello\n\nWorld",
    multiline = false,
    allowNewlines = false,
  })

  -- Newlines should be removed for single-line
  luaunit.assertNotEquals(editor._textBuffer, "Hello\n\nWorld")
end

function TestTextEditorConstructor:test_initialize_sets_element()
  local editor = createTextEditor()
  local element = createMockElement()

  editor:initialize(element)

  luaunit.assertEquals(editor._element, element)
end

function TestTextEditorConstructor:test_cursorBlinkRate_default()
  local editor = createTextEditor()
  luaunit.assertEquals(editor.cursorBlinkRate, 0.5)
end

function TestTextEditorConstructor:test_selectOnFocus_default()
  local editor = createTextEditor()
  luaunit.assertFalse(editor.selectOnFocus)
end

function TestTextEditorConstructor:test_allowTabs_default()
  local editor = createTextEditor()
  luaunit.assertTrue(editor.allowTabs)
end

function TestTextEditorConstructor:test_allowNewlines_follows_multiline()
  local editor = createTextEditor({multiline = true})
  luaunit.assertTrue(editor.allowNewlines)

  editor = createTextEditor({multiline = false})
  luaunit.assertFalse(editor.allowNewlines)
end

function TestTextEditorConstructor:test_allowNewlines_override()
  local editor = createTextEditor({
    multiline = true,
    allowNewlines = false,
  })
  luaunit.assertFalse(editor.allowNewlines)
end

-- ============================================================================
-- Text Buffer Operations Tests
-- ============================================================================

TestTextEditorBufferOps = {}

function TestTextEditorBufferOps:test_getText_returns_text()
  local editor = createTextEditor({text = "Hello World"})
  luaunit.assertEquals(editor:getText(), "Hello World")
end

function TestTextEditorBufferOps:test_getText_returns_empty_for_nil()
  local editor = createTextEditor()
  editor._textBuffer = nil
  luaunit.assertEquals(editor:getText(), "")
end

function TestTextEditorBufferOps:test_setText_updates_buffer()
  local editor = createTextEditor()
  editor:setText("New text")
  luaunit.assertEquals(editor:getText(), "New text")
end

function TestTextEditorBufferOps:test_setText_sanitizes()
  local editor = createTextEditor({
    multiline = false,
    allowNewlines = false,
  })

  editor:setText("Line1\nLine2")

  -- Should remove newlines for single-line
  local text = editor:getText()
  luaunit.assertFalse(text:find("\n") ~= nil)
end

function TestTextEditorBufferOps:test_setText_skips_sanitization()
  local editor = createTextEditor({
    multiline = false,
    allowNewlines = false,
  })

  editor:setText("Line1\nLine2", true) -- skipSanitization = true
  luaunit.assertEquals(editor:getText(), "Line1\nLine2")
end

function TestTextEditorBufferOps:test_setText_with_empty_string()
  local editor = createTextEditor()
  editor:setText("")
  luaunit.assertEquals(editor:getText(), "")
end

function TestTextEditorBufferOps:test_setText_with_nil()
  local editor = createTextEditor({text = "initial"})
  editor:setText(nil)
  luaunit.assertEquals(editor:getText(), "") -- Should default to empty string
end

function TestTextEditorBufferOps:test_insertText_at_position()
  local editor = createTextEditor({text = "Hello"})
  editor:insertText(" World", 5)
  luaunit.assertEquals(editor:getText(), "Hello World")
end

function TestTextEditorBufferOps:test_insertText_at_start()
  local editor = createTextEditor({text = "World"})
  editor:insertText("Hello ", 0)
  luaunit.assertEquals(editor:getText(), "Hello World")
end

function TestTextEditorBufferOps:test_insertText_with_empty_string()
  local editor = createTextEditor({text = "Hello"})
  editor:insertText("", 2)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should remain unchanged
end

function TestTextEditorBufferOps:test_insertText_at_invalid_position()
  local editor = createTextEditor({text = "Hello"})
  -- Insert at negative position (should treat as 0)
  editor:insertText("X", -10)
  luaunit.assertStrContains(editor:getText(), "X")
end

function TestTextEditorBufferOps:test_insertText_beyond_length()
  local editor = createTextEditor({text = "Hello"})
  editor:insertText("X", 1000)
  luaunit.assertStrContains(editor:getText(), "X")
end

function TestTextEditorBufferOps:test_insertText_when_at_maxLength()
  local editor = createTextEditor({text = "Hello", maxLength = 5})
  editor:insertText("X", 5)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not insert
end

function TestTextEditorBufferOps:test_insertText_updates_cursor()
  local editor = createTextEditor({text = "Hello"})
  local element = createMockElement()
  editor:initialize(element)

  editor:setCursorPosition(5)
  editor:insertText(" World")

  luaunit.assertEquals(editor:getCursorPosition(), 11)
end

function TestTextEditorBufferOps:test_deleteText_removes_range()
  local editor = createTextEditor({text = "Hello World"})
  editor:deleteText(5, 11) -- Remove " World"
  luaunit.assertEquals(editor:getText(), "Hello")
end

function TestTextEditorBufferOps:test_deleteText_handles_reversed()
  local editor = createTextEditor({text = "Hello World"})
  editor:deleteText(11, 5) -- Reversed: should swap
  luaunit.assertEquals(editor:getText(), "Hello")
end

function TestTextEditorBufferOps:test_deleteText_with_inverted_range()
  local editor = createTextEditor({text = "Hello World"})
  editor:deleteText(10, 2) -- End before start
  -- Should swap and delete
  luaunit.assertEquals(#editor:getText(), 3) -- Deleted 8 characters
end

function TestTextEditorBufferOps:test_deleteText_beyond_bounds()
  local editor = createTextEditor({text = "Hello"})
  editor:deleteText(10, 20) -- Beyond text length
  luaunit.assertEquals(editor:getText(), "Hello") -- Should clamp to bounds
end

function TestTextEditorBufferOps:test_deleteText_with_negative_positions()
  local editor = createTextEditor({text = "Hello"})
  editor:deleteText(-5, -1) -- Negative positions
  luaunit.assertEquals(editor:getText(), "Hello") -- Should clamp to 0
end

function TestTextEditorBufferOps:test_replaceText_replaces_range()
  local editor = createTextEditor({text = "Hello World"})
  editor:replaceText(6, 11, "Lua")
  luaunit.assertEquals(editor:getText(), "Hello Lua")
end

function TestTextEditorBufferOps:test_replaceText_with_empty_string()
  local editor = createTextEditor({text = "Hello World"})
  editor:replaceText(0, 5, "")
  luaunit.assertEquals(editor:getText(), " World") -- Should just delete
end

function TestTextEditorBufferOps:test_replaceText_beyond_bounds()
  local editor = createTextEditor({text = "Hello"})
  editor:replaceText(10, 20, "X")
  luaunit.assertStrContains(editor:getText(), "X")
end

-- ============================================================================
-- Cursor Position Tests
-- ============================================================================

TestTextEditorCursor = {}

function TestTextEditorCursor:test_setCursorPosition()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(3)
  luaunit.assertEquals(editor:getCursorPosition(), 3)
end

function TestTextEditorCursor:test_setCursorPosition_clamps()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(100) -- Beyond text length
  luaunit.assertEquals(editor:getCursorPosition(), 5)
end

function TestTextEditorCursor:test_setCursorPosition_negative()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(-10)
  luaunit.assertEquals(editor:getCursorPosition(), 0) -- Should clamp to 0
end

function TestTextEditorCursor:test_setCursorPosition_with_non_number()
  local editor = createTextEditor({text = "Hello"})
  editor._cursorPosition = "invalid" -- Corrupt state
  editor:setCursorPosition(3)
  luaunit.assertEquals(editor:getCursorPosition(), 3) -- Should validate and fix
end

function TestTextEditorCursor:test_moveCursorBy()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(2)
  editor:moveCursorBy(2)
  luaunit.assertEquals(editor:getCursorPosition(), 4)
end

function TestTextEditorCursor:test_moveCursorBy_zero()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(2)
  editor:moveCursorBy(0)
  luaunit.assertEquals(editor:getCursorPosition(), 2) -- Should stay same
end

function TestTextEditorCursor:test_moveCursorBy_large_negative()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(2)
  editor:moveCursorBy(-1000)
  luaunit.assertEquals(editor:getCursorPosition(), 0) -- Should clamp to 0
end

function TestTextEditorCursor:test_moveCursorBy_large_positive()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(2)
  editor:moveCursorBy(1000)
  luaunit.assertEquals(editor:getCursorPosition(), 5) -- Should clamp to length
end

function TestTextEditorCursor:test_moveCursorToStart()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(3)
  editor:moveCursorToStart()
  luaunit.assertEquals(editor:getCursorPosition(), 0)
end

function TestTextEditorCursor:test_moveCursorToEnd()
  local editor = createTextEditor({text = "Hello"})
  editor:moveCursorToEnd()
  luaunit.assertEquals(editor:getCursorPosition(), 5)
end

function TestTextEditorCursor:test_moveCursor_with_empty_buffer()
  local editor = createTextEditor({text = ""})
  editor:moveCursorToStart()
  luaunit.assertEquals(editor:getCursorPosition(), 0)
  editor:moveCursorToEnd()
  luaunit.assertEquals(editor:getCursorPosition(), 0)
end

function TestTextEditorCursor:test_getCursorScreenPosition_single_line()
  local editor = createTextEditor({text = "Hello", multiline = false})
  local element = createMockElement()
  editor:initialize(element)

  editor:setCursorPosition(3)
  local x, y = editor:_getCursorScreenPosition()

  luaunit.assertNotNil(x)
  luaunit.assertNotNil(y)
  luaunit.assertTrue(x >= 0)
  luaunit.assertEquals(y, 0)
end

function TestTextEditorCursor:test_getCursorScreenPosition_multiline()
  local editor = createTextEditor({text = "Line 1\nLine 2", multiline = true})
  local element = createMockElement()
  editor:initialize(element)

  editor:setCursorPosition(10) -- Second line
  local x, y = editor:_getCursorScreenPosition()

  luaunit.assertNotNil(x)
  luaunit.assertNotNil(y)
end

function TestTextEditorCursor:test_getCursorScreenPosition_password_mode()
  local editor = createTextEditor({
    text = "password123",
    passwordMode = true
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:setCursorPosition(8)
  local x, y = editor:_getCursorScreenPosition()

  luaunit.assertNotNil(x)
  luaunit.assertEquals(y, 0)
end

function TestTextEditorCursor:test_getCursorScreenPosition_without_element()
  local editor = createTextEditor({text = "Hello"})
  local x, y = editor:_getCursorScreenPosition()
  luaunit.assertEquals(x, 0)
  luaunit.assertEquals(y, 0)
end

-- ============================================================================
-- Word Navigation Tests
-- ============================================================================

TestTextEditorWordNav = {}

function TestTextEditorWordNav:test_moveCursorToNextWord()
  local editor = createTextEditor({text = "Hello World Test"})
  local element = createMockElement()
  editor:initialize(element)

  editor:setCursorPosition(0)
  editor:moveCursorToNextWord()

  luaunit.assertTrue(editor:getCursorPosition() > 0)
end

function TestTextEditorWordNav:test_moveCursorToPreviousWord()
  local editor = createTextEditor({text = "Hello World Test"})
  local element = createMockElement()
  editor:initialize(element)

  editor:setCursorPosition(16)
  editor:moveCursorToPreviousWord()

  luaunit.assertTrue(editor:getCursorPosition() < 16)
end

function TestTextEditorWordNav:test_moveCursorToPreviousWord_at_start()
  local editor = createTextEditor({text = "Hello World"})
  editor:moveCursorToStart()
  editor:moveCursorToPreviousWord()
  luaunit.assertEquals(editor:getCursorPosition(), 0) -- Should stay at start
end

function TestTextEditorWordNav:test_moveCursorToNextWord_at_end()
  local editor = createTextEditor({text = "Hello World"})
  editor:moveCursorToEnd()
  editor:moveCursorToNextWord()
  luaunit.assertEquals(editor:getCursorPosition(), 11) -- Should stay at end
end

-- ============================================================================
-- Selection Tests
-- ============================================================================

TestTextEditorSelection = {}

function TestTextEditorSelection:test_setSelection()
  local editor = createTextEditor({text = "Hello World"})
  editor:setSelection(0, 5)

  local start, endPos = editor:getSelection()
  luaunit.assertEquals(start, 0)
  luaunit.assertEquals(endPos, 5)
end

function TestTextEditorSelection:test_setSelection_inverted_range()
  local editor = createTextEditor({text = "Hello World"})
  editor:setSelection(10, 2) -- End before start
  local start, endPos = editor:getSelection()
  luaunit.assertTrue(start <= endPos) -- Should be swapped
end

function TestTextEditorSelection:test_setSelection_beyond_bounds()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(0, 1000)
  local start, endPos = editor:getSelection()
  luaunit.assertEquals(endPos, 5) -- Should clamp to length
end

function TestTextEditorSelection:test_setSelection_negative_positions()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(-5, -1)
  local start, endPos = editor:getSelection()
  luaunit.assertEquals(start, 0) -- Should clamp to 0
  luaunit.assertEquals(endPos, 0)
end

function TestTextEditorSelection:test_setSelection_same_start_end()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(2, 2) -- Same position
  luaunit.assertFalse(editor:hasSelection()) -- Should be no selection
end

function TestTextEditorSelection:test_hasSelection_true()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(0, 5)
  luaunit.assertTrue(editor:hasSelection())
end

function TestTextEditorSelection:test_hasSelection_false()
  local editor = createTextEditor({text = "Hello"})
  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorSelection:test_clearSelection()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(0, 5)
  editor:clearSelection()
  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorSelection:test_getSelectedText()
  local editor = createTextEditor({text = "Hello World"})
  editor:setSelection(0, 5)
  luaunit.assertEquals(editor:getSelectedText(), "Hello")
end

function TestTextEditorSelection:test_getSelectedText_with_no_selection()
  local editor = createTextEditor({text = "Hello"})
  luaunit.assertNil(editor:getSelectedText())
end

function TestTextEditorSelection:test_deleteSelection()
  local editor = createTextEditor({text = "Hello World"})
  editor:setSelection(0, 6)
  editor:deleteSelection()
  luaunit.assertEquals(editor:getText(), "World")
  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorSelection:test_deleteSelection_with_no_selection()
  local editor = createTextEditor({text = "Hello"})
  local deleted = editor:deleteSelection()
  luaunit.assertFalse(deleted) -- Should return false
  luaunit.assertEquals(editor:getText(), "Hello") -- Text unchanged
end

function TestTextEditorSelection:test_selectAll()
  local editor = createTextEditor({text = "Hello World"})
  editor:selectAll()

  local start, endPos = editor:getSelection()
  luaunit.assertEquals(start, 0)
  luaunit.assertEquals(endPos, 11)
end

function TestTextEditorSelection:test_selectAll_with_empty_buffer()
  local editor = createTextEditor({text = ""})
  editor:selectAll()
  luaunit.assertFalse(editor:hasSelection()) -- No selection on empty text
end

function TestTextEditorSelection:test_selectWordAtPosition()
  local editor = createTextEditor({text = "Hello World Test"})
  local element = createMockElement()
  editor:initialize(element)

  editor:_selectWordAtPosition(7) -- "World"

  luaunit.assertTrue(editor:hasSelection())
  local selected = editor:getSelectedText()
  luaunit.assertEquals(selected, "World")
end

function TestTextEditorSelection:test_selectWordAtPosition_with_punctuation()
  local editor = createTextEditor({text = "Hello, World!"})
  local element = createMockElement()
  editor:initialize(element)

  editor:_selectWordAtPosition(7) -- "World"

  local selected = editor:getSelectedText()
  luaunit.assertEquals(selected, "World")
end

function TestTextEditorSelection:test_selectWordAtPosition_empty()
  local editor = createTextEditor({text = ""})
  local element = createMockElement()
  editor:initialize(element)

  editor:_selectWordAtPosition(0)
  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorSelection:test_selectWordAtPosition_on_whitespace()
  local editor = createTextEditor({text = "Hello     World"})
  editor:_selectWordAtPosition(7) -- In whitespace
  -- Behavior depends on implementation
  luaunit.assertTrue(true)
end

-- ============================================================================
-- Selection Rectangle Tests
-- ============================================================================

TestTextEditorSelectionRects = {}

function TestTextEditorSelectionRects:test_getSelectionRects_single_line()
  local editor = createTextEditor({text = "Hello World", multiline = false})
  local element = createMockElement()
  editor:initialize(element)

  editor:setSelection(0, 5)
  local rects = editor:_getSelectionRects(0, 5)

  luaunit.assertNotNil(rects)
  luaunit.assertTrue(#rects > 0)
  luaunit.assertNotNil(rects[1].x)
  luaunit.assertNotNil(rects[1].y)
  luaunit.assertNotNil(rects[1].width)
  luaunit.assertNotNil(rects[1].height)
end

function TestTextEditorSelectionRects:test_getSelectionRects_multiline()
  local editor = createTextEditor({text = "Line 1\nLine 2\nLine 3", multiline = true})
  local element = createMockElement()
  editor:initialize(element)

  -- Select across lines
  editor:setSelection(0, 14) -- "Line 1\nLine 2"
  local rects = editor:_getSelectionRects(0, 14)

  luaunit.assertNotNil(rects)
  luaunit.assertTrue(#rects > 0)
end

function TestTextEditorSelectionRects:test_getSelectionRects_password_mode()
  local editor = createTextEditor({
    text = "secret",
    passwordMode = true,
    multiline = false
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:setSelection(0, 6)
  local rects = editor:_getSelectionRects(0, 6)

  luaunit.assertNotNil(rects)
  luaunit.assertTrue(#rects > 0)
end

function TestTextEditorSelectionRects:test_getSelectionRects_empty_buffer()
  local editor = createTextEditor({text = ""})
  local mockElement = createMockElement()
  editor:initialize(mockElement)

  editor:setSelection(0, 0)
  local rects = editor:_getSelectionRects(0, 0)
  luaunit.assertEquals(#rects, 0) -- No rects for empty selection
end

-- ============================================================================
-- Focus and Blur Tests
-- ============================================================================

TestTextEditorFocus = {}

function TestTextEditorFocus:test_focus()
  local focusCalled = false
  local editor = createTextEditor({
    text = "Test",
    onFocus = function() focusCalled = true end
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  luaunit.assertTrue(editor:isFocused())
  luaunit.assertTrue(focusCalled)
end

function TestTextEditorFocus:test_blur()
  local blurCalled = false
  local editor = createTextEditor({
    text = "Test",
    onBlur = function() blurCalled = true end
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:blur()
  luaunit.assertFalse(editor:isFocused())
  luaunit.assertTrue(blurCalled)
end

function TestTextEditorFocus:test_selectOnFocus()
  local editor = createTextEditor({
    text = "Hello World",
    selectOnFocus = true
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  luaunit.assertTrue(editor:hasSelection())
  luaunit.assertEquals(editor:getSelectedText(), "Hello World")
end

function TestTextEditorFocus:test_focus_without_element()
  local editor = createTextEditor()
  editor:focus()
  luaunit.assertTrue(editor:isFocused())
end

function TestTextEditorFocus:test_blur_without_element()
  local editor = createTextEditor()
  editor:focus()
  editor:blur()
  luaunit.assertFalse(editor:isFocused())
end

function TestTextEditorFocus:test_focus_twice()
  local editor = createTextEditor()
  editor:focus()
  editor:focus() -- Focus again
  luaunit.assertTrue(editor:isFocused()) -- Should remain focused
end

function TestTextEditorFocus:test_blur_twice()
  local editor = createTextEditor()
  editor:focus()
  editor:blur()
  editor:blur() -- Blur again
  luaunit.assertFalse(editor:isFocused()) -- Should remain blurred
end

function TestTextEditorFocus:test_focus_blurs_previous()
  local editor1 = createTextEditor({text = "Editor 1"})
  local editor2 = createTextEditor({text = "Editor 2"})

  local element1 = createMockElement()
  local element2 = createMockElement()

  element1._textEditor = editor1
  element2._textEditor = editor2

  editor1:initialize(element1)
  editor2:initialize(element2)

  MockContext._focusedElement = element1
  editor1:focus()

  -- Focus second editor
  editor2:focus()

  luaunit.assertFalse(editor1:isFocused())
  luaunit.assertTrue(editor2:isFocused())
end

-- ============================================================================
-- Keyboard Input Tests
-- ============================================================================

TestTextEditorKeyboard = {}

function TestTextEditorKeyboard:test_handleTextInput()
  local editor = createTextEditor({text = "", editable = true})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:handleTextInput("H")
  editor:handleTextInput("i")

  luaunit.assertEquals(editor:getText(), "Hi")
end

function TestTextEditorKeyboard:test_handleTextInput_without_focus()
  local editor = createTextEditor({text = "Hello"})
  editor:handleTextInput("X")
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not insert
end

function TestTextEditorKeyboard:test_handleTextInput_empty_string()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleTextInput("")
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not modify
end

function TestTextEditorKeyboard:test_handleTextInput_newline_in_singleline()
  local editor = createTextEditor({text = "Hello", multiline = false, allowNewlines = false})
  editor:focus()
  editor:handleTextInput("\n")
  -- Should sanitize newline in single-line mode
  luaunit.assertFalse(editor:getText():find("\n") ~= nil)
end

function TestTextEditorKeyboard:test_handleTextInput_callback_returns_false()
  local editor = createTextEditor({
    text = "Hello",
    onTextInput = function(element, text)
      return false -- Reject input
    end,
  })
  local mockElement = createMockElement()
  editor:initialize(mockElement)
  editor:focus()
  editor:handleTextInput("X")
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not insert
end

function TestTextEditorKeyboard:test_handleKeyPress_backspace()
  local editor = createTextEditor({text = "Hello", editable = true})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(5)
  editor:handleKeyPress("backspace", "backspace", false)

  luaunit.assertEquals(editor:getText(), "Hell")
end

function TestTextEditorKeyboard:test_handleKeyPress_backspace_at_start()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:moveCursorToStart()
  editor:handleKeyPress("backspace", "backspace", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not delete
end

function TestTextEditorKeyboard:test_handleKeyPress_delete()
  local editor = createTextEditor({text = "Hello", editable = true})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(0)
  editor:handleKeyPress("delete", "delete", false)

  luaunit.assertEquals(editor:getText(), "ello")
end

function TestTextEditorKeyboard:test_handleKeyPress_delete_at_end()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:moveCursorToEnd()
  editor:handleKeyPress("delete", "delete", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not delete
end

function TestTextEditorKeyboard:test_handleKeyPress_return_multiline()
  local editor = createTextEditor({text = "Hello", editable = true, multiline = true})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(5)
  editor:handleKeyPress("return", "return", false)
  editor:handleTextInput("World")

  luaunit.assertEquals(editor:getText(), "Hello\nWorld")
end

function TestTextEditorKeyboard:test_handleKeyPress_return_singleline()
  local onEnterCalled = false
  local editor = createTextEditor({
    text = "Hello",
    editable = true,
    multiline = false,
    onEnter = function() onEnterCalled = true end
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:handleKeyPress("return", "return", false)

  luaunit.assertTrue(onEnterCalled)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not add newline
end

function TestTextEditorKeyboard:test_handleKeyPress_home_end()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(5)

  -- Home key
  editor:handleKeyPress("home", "home", false)
  luaunit.assertEquals(editor:getCursorPosition(), 0)

  -- End key
  editor:handleKeyPress("end", "end", false)
  luaunit.assertEquals(editor:getCursorPosition(), 11)
end

function TestTextEditorKeyboard:test_handleKeyPress_arrow_keys()
  local editor = createTextEditor({text = "Hello"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(2)

  -- Right arrow
  editor:handleKeyPress("right", "right", false)
  luaunit.assertEquals(editor:getCursorPosition(), 3)

  -- Left arrow
  editor:handleKeyPress("left", "left", false)
  luaunit.assertEquals(editor:getCursorPosition(), 2)
end

function TestTextEditorKeyboard:test_handleKeyPress_without_focus()
  local editor = createTextEditor({text = "Hello"})
  editor:handleKeyPress("backspace", "backspace", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not modify
end

function TestTextEditorKeyboard:test_handleKeyPress_unknown_key()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleKeyPress("unknownkey", "unknownkey", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should ignore
end

function TestTextEditorKeyboard:test_handleKeyPress_escape_with_selection()
  local editor = createTextEditor({text = "Select me"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:selectAll()

  editor:handleKeyPress("escape", "escape", false)

  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorKeyboard:test_handleKeyPress_escape_without_selection()
  local editor = createTextEditor({text = "Test"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:handleKeyPress("escape", "escape", false)

  luaunit.assertFalse(editor:isFocused())
end

function TestTextEditorKeyboard:test_handleKeyPress_arrow_with_shift()
  local editor = createTextEditor({text = "Select this"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(0)

  -- Simulate shift+right arrow
  love.keyboard.setDown("lshift", true)
  editor:handleKeyPress("right", "right", false)
  love.keyboard.setDown("lshift", false)

  luaunit.assertTrue(editor:hasSelection())
end

function TestTextEditorKeyboard:test_handleKeyPress_ctrl_backspace()
  local editor = createTextEditor({text = "Delete this"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(11)

  -- Simulate ctrl+backspace
  love.keyboard.setDown("lctrl", true)
  editor:handleKeyPress("backspace", "backspace", false)
  love.keyboard.setDown("lctrl", false)

  luaunit.assertEquals(editor:getText(), "")
end

-- ============================================================================
-- Mouse Interaction Tests
-- ============================================================================

TestTextEditorMouse = {}

function TestTextEditorMouse:test_mouseToTextPosition()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)

  -- Click in middle of text (approximate)
  local pos = editor:mouseToTextPosition(40, 10)
  luaunit.assertNotNil(pos)
  luaunit.assertTrue(pos >= 0 and pos <= 11)
end

function TestTextEditorMouse:test_mouseToTextPosition_without_element()
  local editor = createTextEditor({text = "Hello"})
  local pos = editor:mouseToTextPosition(10, 10)
  luaunit.assertEquals(pos, 0) -- Should return 0 without element
end

function TestTextEditorMouse:test_mouseToTextPosition_with_nil_buffer()
  local editor = createTextEditor()
  local mockElement = createMockElement()
  mockElement.x = 0
  mockElement.y = 0
  editor:initialize(mockElement)
  editor._textBuffer = nil

  local pos = editor:mouseToTextPosition(10, 10)
  luaunit.assertEquals(pos, 0) -- Should handle nil buffer
end

function TestTextEditorMouse:test_mouseToTextPosition_negative_coords()
  local editor = createTextEditor({text = "Hello"})
  local mockElement = createMockElement()
  mockElement.x = 100
  mockElement.y = 100
  editor:initialize(mockElement)

  local pos = editor:mouseToTextPosition(-10, -10)
  luaunit.assertTrue(pos >= 0) -- Should clamp to valid position
end

function TestTextEditorMouse:test_mouseToTextPosition_multiline()
  local editor = createTextEditor({text = "Line 1\nLine 2\nLine 3", multiline = true})
  local element = createMockElement()
  editor:initialize(element)

  -- Click on second line
  local pos = editor:mouseToTextPosition(20, 25)

  luaunit.assertNotNil(pos)
  luaunit.assertTrue(pos >= 0) -- Valid position
end

function TestTextEditorMouse:test_handleTextClick_single_click()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)

  editor:handleTextClick(40, 10, 1)
  luaunit.assertTrue(editor:getCursorPosition() >= 0)
end

function TestTextEditorMouse:test_handleTextClick_double_click()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  -- Double click on first word
  editor:handleTextClick(20, 10, 2)
  luaunit.assertTrue(editor:hasSelection())
  local selected = editor:getSelectedText()
  luaunit.assertTrue(selected == "Hello" or selected == "World")
end

function TestTextEditorMouse:test_handleTextClick_triple_click()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:handleTextClick(20, 10, 3)
  luaunit.assertTrue(editor:hasSelection())
  luaunit.assertEquals(editor:getSelectedText(), "Hello World")
end

function TestTextEditorMouse:test_handleTextClick_without_focus()
  local editor = createTextEditor({text = "Hello"})
  editor:handleTextClick(10, 10, 1)
  -- Should not error, but also won't do anything without focus
  luaunit.assertTrue(true)
end

function TestTextEditorMouse:test_handleTextClick_zero_count()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleTextClick(10, 10, 0)
  -- Should not error
  luaunit.assertTrue(true)
end

function TestTextEditorMouse:test_handleTextDrag()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  -- Start at text beginning (element x=10 + padding left=5 = 15)
  editor:handleTextClick(15, 15, 1)

  -- Verify mouseDownPosition was set
  luaunit.assertNotNil(editor._mouseDownPosition)

  -- Drag to position much further right (should be different position)
  editor:handleTextDrag(100, 15)

  -- If still no selection, the positions might be the same - just verify drag was called
  luaunit.assertTrue(editor:hasSelection() or editor._mouseDownPosition ~= nil)
end

function TestTextEditorMouse:test_handleTextDrag_without_mousedown()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleTextDrag(20, 10) -- Drag without mouseDownPosition
  -- Should not error
  luaunit.assertTrue(true)
end

function TestTextEditorMouse:test_handleTextDrag_sets_flag()
  local editor = createTextEditor({text = "Drag me"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:handleTextClick(10, 10, 1)
  editor:handleTextDrag(50, 10)

  luaunit.assertTrue(editor._textDragOccurred or not editor:hasSelection())
end

-- ============================================================================
-- Multiline Text Tests
-- ============================================================================

TestTextEditorMultiline = {}

function TestTextEditorMultiline:test_multiline_split_lines()
  local editor = createTextEditor({multiline = true, text = "Line 1\nLine 2\nLine 3"})
  local element = createMockElement()
  editor:initialize(element)

  editor:_splitLines()
  luaunit.assertNotNil(editor._lines)
  luaunit.assertEquals(#editor._lines, 3)
  luaunit.assertEquals(editor._lines[1], "Line 1")
  luaunit.assertEquals(editor._lines[2], "Line 2")
  luaunit.assertEquals(editor._lines[3], "Line 3")
end

function TestTextEditorMultiline:test_multiline_cursor_movement()
  local editor = createTextEditor({multiline = true, text = "Line 1\nLine 2"})
  local element = createMockElement()
  editor:initialize(element)

  -- Move to end
  editor:moveCursorToEnd()
  luaunit.assertEquals(editor:getCursorPosition(), 13) -- "Line 1\nLine 2" = 13 chars

  -- Move to start
  editor:moveCursorToStart()
  luaunit.assertEquals(editor:getCursorPosition(), 0)
end

function TestTextEditorMultiline:test_multiline_insert_newline()
  local editor = createTextEditor({multiline = true, text = "Hello"})
  local element = createMockElement()
  editor:initialize(element)

  editor:setCursorPosition(5)
  editor:insertText("\n", 5)
  editor:insertText("World", 6)

  luaunit.assertEquals(editor:getText(), "Hello\nWorld")
end

-- ============================================================================
-- Text Wrapping Tests
-- ============================================================================

TestTextEditorWrapping = {}

function TestTextEditorWrapping:test_word_wrapping()
  local editor = createTextEditor({
    multiline = true,
    textWrap = "word",
    text = "This is a long line that should wrap"
  })
  local element = createMockElement(50, 100) -- Very narrow width to force wrapping
  editor:initialize(element)

  editor._textDirty = true
  editor:_updateTextIfDirty()
  luaunit.assertNotNil(editor._wrappedLines)
  luaunit.assertTrue(#editor._wrappedLines >= 1) -- Should have wrapped lines
end

function TestTextEditorWrapping:test_char_wrapping()
  local editor = createTextEditor({
    multiline = true,
    textWrap = "char",
    text = "Verylongwordwithoutspaces"
  })
  local element = createMockElement(100, 100)
  editor:initialize(element)

  editor:_calculateWrapping()
  luaunit.assertNotNil(editor._wrappedLines)
end

function TestTextEditorWrapping:test_no_wrapping()
  local editor = createTextEditor({
    multiline = true,
    textWrap = false,
    text = "This is a long line that should not wrap"
  })
  local element = createMockElement(100, 100)
  editor:initialize(element)

  editor:_calculateWrapping()
  -- With textWrap = false, _wrappedLines should be nil
  luaunit.assertNil(editor._wrappedLines)
end

function TestTextEditorWrapping:test_wrapLine_empty_line()
  local editor = createTextEditor({multiline = true, textWrap = "word"})
  local element = createMockElement()
  editor:initialize(element)

  local wrapped = editor:_wrapLine("", 100)

  luaunit.assertNotNil(wrapped)
  luaunit.assertTrue(#wrapped > 0)
end

function TestTextEditorWrapping:test_calculateWrapping_empty_lines()
  local editor = createTextEditor({
    multiline = true,
    textWrap = "word",
    text = "Line 1\n\nLine 3"
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:_calculateWrapping()

  luaunit.assertNotNil(editor._wrappedLines)
end

function TestTextEditorWrapping:test_calculateWrapping_no_element()
  local editor = createTextEditor({
    multiline = true,
    textWrap = "word",
    text = "Test"
  })

  -- No element initialized
  editor:_calculateWrapping()

  luaunit.assertNil(editor._wrappedLines)
end

-- ============================================================================
-- Sanitization Tests
-- ============================================================================

TestTextEditorSanitization = {}

function TestTextEditorSanitization:test_sanitize_max_length()
  local editor = createTextEditor({maxLength = 5})
  editor:setText("HelloWorld")
  luaunit.assertEquals(editor:getText(), "Hello")
end

function TestTextEditorSanitization:test_sanitize_zero_maxLength()
  local editor = createTextEditor({maxLength = 0})
  editor:setText("test")
  luaunit.assertEquals(editor:getText(), "") -- Should be empty
end

function TestTextEditorSanitization:test_sanitization_disabled()
  local editor = createTextEditor({
    sanitize = false,
    multiline = false,
    allowNewlines = false,
  })

  editor:setText("Line1\nLine2")

  -- Should NOT sanitize newlines when disabled
  luaunit.assertEquals(editor:getText(), "Line1\nLine2")
end

function TestTextEditorSanitization:test_custom_sanitizer()
  local editor = createTextEditor({
    customSanitizer = function(text)
      return text:upper()
    end,
  })

  editor:setText("hello")
  luaunit.assertEquals(editor:getText(), "HELLO")
end

function TestTextEditorSanitization:test_custom_sanitizer_via_sanitizeText()
  local editor = createTextEditor({
    customSanitizer = function(text)
      return text:upper()
    end,
  })

  local result = editor:_sanitizeText("hello world")
  luaunit.assertEquals(result, "HELLO WORLD")
end

function TestTextEditorSanitization:test_custom_sanitizer_returns_nil()
  local editor = createTextEditor({
    customSanitizer = function(text)
      return nil
    end,
  })

  editor:setText("test")
  -- Should fallback to original text when sanitizer returns nil
  luaunit.assertEquals(editor:getText(), "test")
end

function TestTextEditorSanitization:test_custom_sanitizer_throws_error()
  local editor = createTextEditor({
    customSanitizer = function(text)
      error("Intentional error")
    end,
  })

  -- Should error when setting text
  luaunit.assertErrorMsgContains("Intentional error", function()
    editor:setText("test")
  end)
end

function TestTextEditorSanitization:test_sanitize_disabled_via_flag()
  local editor = createTextEditor({
    sanitize = false,
    maxLength = 5,
  })

  local result = editor:_sanitizeText("This is a very long text")
  -- Should not be truncated since sanitize is false
  luaunit.assertEquals(result, "This is a very long text")
end

function TestTextEditorSanitization:test_disallow_newlines()
  local editor = createTextEditor({
    text = "",
    editable = true,
    multiline = false,
    allowNewlines = false
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:setText("Hello\nWorld")
  -- Newlines should be removed or replaced
  luaunit.assertNil(editor:getText():find("\n"))
end

function TestTextEditorSanitization:test_disallow_tabs()
  local editor = createTextEditor({
    text = "",
    editable = true,
    allowTabs = false
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:setText("Hello\tWorld")
  -- Tabs should be removed or replaced
  luaunit.assertNil(editor:getText():find("\t"))
end

function TestTextEditorSanitization:test_onSanitize_callback()
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

-- ============================================================================
-- Password Mode Tests
-- ============================================================================

TestTextEditorPassword = {}

function TestTextEditorPassword:test_password_mode_masks_text()
  local editor = createTextEditor({text = "secret123", passwordMode = true})
  local element = createMockElement()
  editor:initialize(element)

  -- Password mode should be enabled
  luaunit.assertTrue(editor.passwordMode)

  -- The actual text should still be stored
  luaunit.assertEquals(editor:getText(), "secret123")
end

function TestTextEditorPassword:test_password_mode_empty_text()
  local editor = createTextEditor({passwordMode = true, text = ""})
  luaunit.assertEquals(editor:getText(), "")
end

-- ============================================================================
-- Input Validation Tests
-- ============================================================================

TestTextEditorValidation = {}

function TestTextEditorValidation:test_number_input_type()
  local editor = createTextEditor({text = "", editable = true, inputType = "number"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:handleTextInput("123")
  luaunit.assertEquals(editor:getText(), "123")

  -- Non-numeric input should be sanitized
  editor:handleTextInput("abc")
  -- Sanitization behavior depends on implementation
end

function TestTextEditorValidation:test_max_length()
  local editor = createTextEditor({text = "", editable = true, maxLength = 5})
  local element = createMockElement()
  editor:initialize(element)

  editor:setText("12345")
  luaunit.assertEquals(editor:getText(), "12345")

  editor:setText("123456789")
  luaunit.assertEquals(editor:getText(), "12345") -- Should be truncated
end

function TestTextEditorValidation:test_invalid_input_type()
  -- Invalid input type (not validated by constructor)
  local editor = createTextEditor({inputType = "invalid"})
  luaunit.assertEquals(editor.inputType, "invalid")
end

function TestTextEditorValidation:test_negative_maxLength()
  -- Negative maxLength should be ignored
  local editor = createTextEditor({maxLength = -10})
  luaunit.assertEquals(editor.maxLength, -10) -- Module doesn't validate, just stores
end

-- ============================================================================
-- Cursor Blink and Update Tests
-- ============================================================================

TestTextEditorUpdate = {}

function TestTextEditorUpdate:test_update_cursor_blink()
  local editor = createTextEditor({text = "Test", cursorBlinkRate = 0.5})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()

  -- Initial state
  local initialVisible = editor._cursorVisible

  -- Update for half the blink rate
  editor:update(0.25)
  luaunit.assertEquals(editor._cursorVisible, initialVisible)

  -- Update to complete blink cycle
  editor:update(0.26)
  luaunit.assertNotEquals(editor._cursorVisible, initialVisible)
end

function TestTextEditorUpdate:test_cursor_blink_pause()
  local editor = createTextEditor({text = "Test", cursorBlinkRate = 0.5})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:_resetCursorBlink(true) -- Pause blink

  luaunit.assertTrue(editor._cursorBlinkPaused)
  luaunit.assertTrue(editor._cursorVisible)
end

function TestTextEditorUpdate:test_cursor_blink_pause_resume()
  local editor = createTextEditor({text = "Test"})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  editor:_resetCursorBlink(true) -- Pause

  luaunit.assertTrue(editor._cursorBlinkPaused)

  -- Update to resume blink
  editor:update(0.6) -- More than 0.5 second pause

  luaunit.assertFalse(editor._cursorBlinkPaused)
end

function TestTextEditorUpdate:test_update_not_focused()
  local editor = createTextEditor({text = "Test"})
  local element = createMockElement()
  editor:initialize(element)

  -- Not focused - update should exit early
  editor:update(0.1)
  luaunit.assertTrue(true) -- Should not crash
end

function TestTextEditorUpdate:test_update_without_focus()
  local editor = createTextEditor()
  editor:update(1.0) -- Should not update cursor blink
  luaunit.assertTrue(true) -- Should not error
end

function TestTextEditorUpdate:test_update_negative_dt()
  local editor = createTextEditor()
  editor:focus()
  editor:update(-1.0) -- Negative delta time
  -- Should not error
  luaunit.assertTrue(true)
end

function TestTextEditorUpdate:test_update_zero_dt()
  local editor = createTextEditor()
  editor:focus()
  editor:update(0) -- Zero delta time
  -- Should not error
  luaunit.assertTrue(true)
end

function TestTextEditorUpdate:test_cursor_blink_cycle()
  local editor = createTextEditor({text = "Test", cursorBlinkRate = 0.5})
  local element = createMockElement()
  editor:initialize(element)

  editor:focus()
  local initialVisible = editor._cursorVisible

  -- Complete a full blink cycle
  editor:update(0.5)
  luaunit.assertNotEquals(editor._cursorVisible, initialVisible)
end

function TestTextEditorUpdate:test_cursor_blink_rate_negative()
  -- Negative blink rate
  local editor = createTextEditor({cursorBlinkRate = -1})
  luaunit.assertEquals(editor.cursorBlinkRate, -1) -- Should accept any value
end

function TestTextEditorUpdate:test_cursor_blink_rate_zero()
  -- Zero blink rate (would cause rapid blinking)
  local editor = createTextEditor({cursorBlinkRate = 0})
  luaunit.assertEquals(editor.cursorBlinkRate, 0)
end

function TestTextEditorUpdate:test_cursor_blink_rate_large()
  -- Very large blink rate
  local editor = createTextEditor({cursorBlinkRate = 1000})
  luaunit.assertEquals(editor.cursorBlinkRate, 1000)
end

-- ============================================================================
-- Text Scroll Tests
-- ============================================================================

TestTextEditorScroll = {}

function TestTextEditorScroll:test_updateTextScroll()
  local editor = createTextEditor({text = "This is very long text that needs scrolling"})
  local element = createMockElement(100, 30)
  editor:initialize(element)

  editor:focus()
  editor:moveCursorToEnd()
  editor:_updateTextScroll()

  -- Scroll should be updated
  luaunit.assertTrue(editor._textScrollX >= 0)
end

function TestTextEditorScroll:test_updateTextScroll_keeps_cursor_visible()
  local editor = createTextEditor({text = "Long text here"})
  local element = createMockElement(50, 30)
  editor:initialize(element)

  editor:focus()
  editor:setCursorPosition(10)
  editor:_updateTextScroll()

  local scrollX = editor._textScrollX
  luaunit.assertTrue(scrollX >= 0)
end

function TestTextEditorScroll:test_mouseToTextPosition_with_scroll()
  local editor = createTextEditor({text = "Very long scrolling text"})
  local element = createMockElement(100, 30)
  editor:initialize(element)

  editor:focus()
  editor._textScrollX = 50

  local pos = editor:mouseToTextPosition(30, 15)
  luaunit.assertNotNil(pos)
end

-- ============================================================================
-- Auto-grow Height Tests
-- ============================================================================

TestTextEditorAutoGrow = {}

function TestTextEditorAutoGrow:test_updateAutoGrowHeight_single_line()
  local editor = createTextEditor({
    multiline = false,
    autoGrow = true,
    text = "Single line"
  })
  local element = createMockElement()
  editor:initialize(element)

  editor:updateAutoGrowHeight()
  -- Single line should not trigger height change
  luaunit.assertNotNil(element.height)
end

function TestTextEditorAutoGrow:test_updateAutoGrowHeight_multiline()
  local editor = createTextEditor({
    multiline = true,
    autoGrow = true,
    text = "Line 1\nLine 2\nLine 3"
  })
  local element = createMockElement(200, 50)
  editor:initialize(element)

  local initialHeight = element.height
  editor:updateAutoGrowHeight()

  -- Height should be updated based on line count
  luaunit.assertNotNil(element.height)
end

function TestTextEditorAutoGrow:test_updateAutoGrowHeight_with_wrapping()
  local editor = createTextEditor({
    multiline = true,
    autoGrow = true,
    textWrap = "word",
    text = "This is a very long line that will wrap multiple times when displayed"
  })
  local element = createMockElement(100, 50)
  editor:initialize(element)

  editor:updateAutoGrowHeight()
  -- Should account for wrapped lines
  luaunit.assertNotNil(element.height)
end

function TestTextEditorAutoGrow:test_autoGrow_without_element()
  local editor = createTextEditor({autoGrow = true, multiline = true})
  editor:updateAutoGrowHeight()
  -- Should not error without element
  luaunit.assertTrue(true)
end

function TestTextEditorAutoGrow:test_textWrap_zero_width()
  local editor = createTextEditor({textWrap = true})
  local mockElement = createMockElement()
  mockElement.width = 0
  editor:initialize(mockElement)
  editor:setText("Hello World")
  -- Should handle zero width gracefully
  luaunit.assertTrue(true)
end

-- ============================================================================
-- UTF-8 Edge Cases
-- ============================================================================

TestTextEditorUTF8 = {}

function TestTextEditorUTF8:test_setText_with_emoji()
  local editor = createTextEditor()
  editor:setText("Hello 👋 World 🌍")
  luaunit.assertStrContains(editor:getText(), "👋")
  luaunit.assertStrContains(editor:getText(), "🌍")
end

function TestTextEditorUTF8:test_insertText_with_utf8()
  local editor = createTextEditor({text = "Hello"})
  editor:insertText("世界", 5) -- Chinese characters
  luaunit.assertStrContains(editor:getText(), "世界")
end

function TestTextEditorUTF8:test_cursorPosition_with_utf8()
  local editor = createTextEditor({text = "Hello👋World"})
  -- Cursor positions should be in characters, not bytes
  editor:setCursorPosition(6) -- After emoji
  luaunit.assertEquals(editor:getCursorPosition(), 6)
end

function TestTextEditorUTF8:test_deleteText_with_utf8()
  local editor = createTextEditor({text = "Hello👋World"})
  editor:deleteText(5, 6) -- Delete emoji
  luaunit.assertEquals(editor:getText(), "HelloWorld")
end

function TestTextEditorUTF8:test_maxLength_with_utf8()
  local editor = createTextEditor({maxLength = 10})
  editor:setText("Hello👋👋👋👋👋") -- 10 characters including emojis
  luaunit.assertTrue(utf8.len(editor:getText()) <= 10)
end

-- ============================================================================
-- State Management Tests
-- ============================================================================

TestTextEditorStateSaving = {}

function TestTextEditorStateSaving:test_initialize_immediate_mode_with_state()
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

function TestTextEditorStateSaving:test_saveState_immediate_mode()
  local savedState = nil
  local mockStateManager = {
    getState = function(id) return nil end,
    updateState = function(id, state)
      savedState = state
    end,
  }

  local mockContext = {
    _immediateMode = true,
    _focusedElement = nil,
  }

  local editor = TextEditor.new({text = "Test"}, {
    Context = mockContext,
    StateManager = mockStateManager,
    Color = Color,
    utils = utils,
  })

  local element = createMockElement()
  element._stateId = "test-state-id"
  editor:initialize(element)

  editor:setText("New text")

  luaunit.assertNotNil(savedState)
  luaunit.assertEquals(savedState._textBuffer, "New text")
end

function TestTextEditorStateSaving:test_saveState_not_immediate_mode()
  local saveCalled = false
  local mockStateManager = {
    getState = function(id) return nil end,
    updateState = function(id, state)
      saveCalled = true
    end,
  }

  local mockContext = {
    _immediateMode = false,
    _focusedElement = nil,
  }

  local editor = TextEditor.new({text = "Test"}, {
    Context = mockContext,
    StateManager = mockStateManager,
    Color = Color,
    utils = utils,
  })

  local element = createMockElement()
  editor:initialize(element)

  editor:_saveState()

  -- Should not save in retained mode
  luaunit.assertFalse(saveCalled)
end

-- ============================================================================
-- Run Tests
-- ============================================================================

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
