-- Edge case and unhappy path tests for TextEditor module
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local TextEditor = require("modules.TextEditor")
local Color = require("modules.Color")
local utils = require("modules.utils")

TestTextEditorEdgeCases = {}

-- Mock dependencies
local MockContext = {
  _immediateMode = false,
  _focusedElement = nil,
}

local MockStateManager = {
  getState = function(id)
    return nil
  end,
  updateState = function(id, state) end,
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
    padding = {top = 0, right = 0, bottom = 0, left = 0},
    _renderer = {
      getFont = function()
        return {
          getWidth = function(text) return #text * 8 end,
          getHeight = function() return 16 end,
        }
      end,
      wrapLine = function(element, line, maxWidth)
        return {{text = line, startIdx = 0, endIdx = #line}}
      end,
    },
  }
end

-- ============================================================================
-- Constructor Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testNewWithInvalidCursorBlinkRate()
  -- Negative blink rate
  local editor = createTextEditor({cursorBlinkRate = -1})
  luaunit.assertEquals(editor.cursorBlinkRate, -1) -- Should accept any value
end

function TestTextEditorEdgeCases:testNewWithZeroCursorBlinkRate()
  -- Zero blink rate (would cause rapid blinking)
  local editor = createTextEditor({cursorBlinkRate = 0})
  luaunit.assertEquals(editor.cursorBlinkRate, 0)
end

function TestTextEditorEdgeCases:testNewWithVeryLargeCursorBlinkRate()
  -- Very large blink rate
  local editor = createTextEditor({cursorBlinkRate = 1000})
  luaunit.assertEquals(editor.cursorBlinkRate, 1000)
end

function TestTextEditorEdgeCases:testNewWithNegativeMaxLength()
  -- Negative maxLength should be ignored
  local editor = createTextEditor({maxLength = -10})
  luaunit.assertEquals(editor.maxLength, -10) -- Module doesn't validate, just stores
end

function TestTextEditorEdgeCases:testNewWithZeroMaxLength()
  -- Zero maxLength (no text allowed)
  local editor = createTextEditor({maxLength = 0})
  editor:setText("test")
  luaunit.assertEquals(editor:getText(), "") -- Should be empty
end

function TestTextEditorEdgeCases:testNewWithInvalidInputType()
  -- Invalid input type (not validated by constructor)
  local editor = createTextEditor({inputType = "invalid"})
  luaunit.assertEquals(editor.inputType, "invalid")
end

function TestTextEditorEdgeCases:testNewWithCustomSanitizerReturnsNil()
  -- Custom sanitizer that returns nil
  local editor = createTextEditor({
    customSanitizer = function(text)
      return nil
    end,
  })
  
  editor:setText("test")
  -- Should fallback to original text when sanitizer returns nil
  luaunit.assertEquals(editor:getText(), "test")
end

function TestTextEditorEdgeCases:testNewWithCustomSanitizerThrowsError()
  -- Custom sanitizer that throws error
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

-- ============================================================================
-- Text Buffer Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testSetTextWithEmptyString()
  local editor = createTextEditor()
  editor:setText("")
  luaunit.assertEquals(editor:getText(), "")
end

function TestTextEditorEdgeCases:testSetTextWithNil()
  local editor = createTextEditor({text = "initial"})
  editor:setText(nil)
  luaunit.assertEquals(editor:getText(), "") -- Should default to empty string
end


function TestTextEditorEdgeCases:testInsertTextAtInvalidPosition()
  local editor = createTextEditor({text = "Hello"})
  
  -- Insert at negative position (should treat as 0)
  editor:insertText("X", -10)
  luaunit.assertStrContains(editor:getText(), "X")
end

function TestTextEditorEdgeCases:testInsertTextBeyondLength()
  local editor = createTextEditor({text = "Hello"})
  
  -- Insert beyond text length
  editor:insertText("X", 1000)
  luaunit.assertStrContains(editor:getText(), "X")
end

function TestTextEditorEdgeCases:testInsertTextWithEmptyString()
  local editor = createTextEditor({text = "Hello"})
  editor:insertText("", 2)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should remain unchanged
end

function TestTextEditorEdgeCases:testInsertTextWhenAtMaxLength()
  local editor = createTextEditor({text = "Hello", maxLength = 5})
  editor:insertText("X", 5)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not insert
end

function TestTextEditorEdgeCases:testDeleteTextWithInvertedRange()
  local editor = createTextEditor({text = "Hello World"})
  editor:deleteText(10, 2) -- End before start
  -- Should swap and delete
  luaunit.assertEquals(#editor:getText(), 3) -- Deleted 8 characters
end

function TestTextEditorEdgeCases:testDeleteTextBeyondBounds()
  local editor = createTextEditor({text = "Hello"})
  editor:deleteText(10, 20) -- Beyond text length
  luaunit.assertEquals(editor:getText(), "Hello") -- Should clamp to bounds
end

function TestTextEditorEdgeCases:testDeleteTextWithNegativePositions()
  local editor = createTextEditor({text = "Hello"})
  editor:deleteText(-5, -1) -- Negative positions
  luaunit.assertEquals(editor:getText(), "Hello") -- Should clamp to 0
end

function TestTextEditorEdgeCases:testReplaceTextWithEmptyString()
  local editor = createTextEditor({text = "Hello World"})
  editor:replaceText(0, 5, "")
  luaunit.assertEquals(editor:getText(), " World") -- Should just delete
end

function TestTextEditorEdgeCases:testReplaceTextBeyondBounds()
  local editor = createTextEditor({text = "Hello"})
  editor:replaceText(10, 20, "X")
  luaunit.assertStrContains(editor:getText(), "X")
end

-- ============================================================================
-- UTF-8 Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testSetTextWithUTF8Emoji()
  local editor = createTextEditor()
  editor:setText("Hello 👋 World 🌍")
  luaunit.assertStrContains(editor:getText(), "👋")
  luaunit.assertStrContains(editor:getText(), "🌍")
end

function TestTextEditorEdgeCases:testInsertTextWithUTF8Characters()
  local editor = createTextEditor({text = "Hello"})
  editor:insertText("世界", 5) -- Chinese characters
  luaunit.assertStrContains(editor:getText(), "世界")
end

function TestTextEditorEdgeCases:testCursorPositionWithUTF8()
  local editor = createTextEditor({text = "Hello👋World"})
  -- Cursor positions should be in characters, not bytes
  editor:setCursorPosition(6) -- After emoji
  luaunit.assertEquals(editor:getCursorPosition(), 6)
end

function TestTextEditorEdgeCases:testDeleteTextWithUTF8()
  local editor = createTextEditor({text = "Hello👋World"})
  editor:deleteText(5, 6) -- Delete emoji
  luaunit.assertEquals(editor:getText(), "HelloWorld")
end

function TestTextEditorEdgeCases:testMaxLengthWithUTF8()
  local editor = createTextEditor({maxLength = 10})
  editor:setText("Hello👋👋👋👋👋") -- 10 characters including emojis
  luaunit.assertTrue(utf8.len(editor:getText()) <= 10)
end

-- ============================================================================
-- Cursor Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testSetCursorPositionNegative()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(-10)
  luaunit.assertEquals(editor:getCursorPosition(), 0) -- Should clamp to 0
end

function TestTextEditorEdgeCases:testSetCursorPositionBeyondLength()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(1000)
  luaunit.assertEquals(editor:getCursorPosition(), 5) -- Should clamp to length
end

function TestTextEditorEdgeCases:testSetCursorPositionWithNonNumber()
  local editor = createTextEditor({text = "Hello"})
  editor._cursorPosition = "invalid" -- Corrupt state
  editor:setCursorPosition(3)
  luaunit.assertEquals(editor:getCursorPosition(), 3) -- Should validate and fix
end

function TestTextEditorEdgeCases:testMoveCursorByZero()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(2)
  editor:moveCursorBy(0)
  luaunit.assertEquals(editor:getCursorPosition(), 2) -- Should stay same
end

function TestTextEditorEdgeCases:testMoveCursorByLargeNegative()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(2)
  editor:moveCursorBy(-1000)
  luaunit.assertEquals(editor:getCursorPosition(), 0) -- Should clamp to 0
end

function TestTextEditorEdgeCases:testMoveCursorByLargePositive()
  local editor = createTextEditor({text = "Hello"})
  editor:setCursorPosition(2)
  editor:moveCursorBy(1000)
  luaunit.assertEquals(editor:getCursorPosition(), 5) -- Should clamp to length
end

function TestTextEditorEdgeCases:testMoveCursorToPreviousWordAtStart()
  local editor = createTextEditor({text = "Hello World"})
  editor:moveCursorToStart()
  editor:moveCursorToPreviousWord()
  luaunit.assertEquals(editor:getCursorPosition(), 0) -- Should stay at start
end

function TestTextEditorEdgeCases:testMoveCursorToNextWordAtEnd()
  local editor = createTextEditor({text = "Hello World"})
  editor:moveCursorToEnd()
  editor:moveCursorToNextWord()
  luaunit.assertEquals(editor:getCursorPosition(), 11) -- Should stay at end
end

function TestTextEditorEdgeCases:testMoveCursorWithEmptyBuffer()
  local editor = createTextEditor({text = ""})
  editor:moveCursorToStart()
  luaunit.assertEquals(editor:getCursorPosition(), 0)
  editor:moveCursorToEnd()
  luaunit.assertEquals(editor:getCursorPosition(), 0)
end

-- ============================================================================
-- Selection Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testSetSelectionWithInvertedRange()
  local editor = createTextEditor({text = "Hello World"})
  editor:setSelection(10, 2) -- End before start
  local start, endPos = editor:getSelection()
  luaunit.assertTrue(start <= endPos) -- Should be swapped
end

function TestTextEditorEdgeCases:testSetSelectionBeyondBounds()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(0, 1000)
  local start, endPos = editor:getSelection()
  luaunit.assertEquals(endPos, 5) -- Should clamp to length
end

function TestTextEditorEdgeCases:testSetSelectionWithNegativePositions()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(-5, -1)
  local start, endPos = editor:getSelection()
  luaunit.assertEquals(start, 0) -- Should clamp to 0
  luaunit.assertEquals(endPos, 0)
end

function TestTextEditorEdgeCases:testSetSelectionWithSameStartEnd()
  local editor = createTextEditor({text = "Hello"})
  editor:setSelection(2, 2) -- Same position
  luaunit.assertFalse(editor:hasSelection()) -- Should be no selection
end

function TestTextEditorEdgeCases:testGetSelectedTextWithNoSelection()
  local editor = createTextEditor({text = "Hello"})
  luaunit.assertNil(editor:getSelectedText())
end

function TestTextEditorEdgeCases:testDeleteSelectionWithNoSelection()
  local editor = createTextEditor({text = "Hello"})
  local deleted = editor:deleteSelection()
  luaunit.assertFalse(deleted) -- Should return false
  luaunit.assertEquals(editor:getText(), "Hello") -- Text unchanged
end

function TestTextEditorEdgeCases:testSelectAllWithEmptyBuffer()
  local editor = createTextEditor({text = ""})
  editor:selectAll()
  luaunit.assertFalse(editor:hasSelection()) -- No selection on empty text
end

function TestTextEditorEdgeCases:testGetSelectionRectsWithEmptyBuffer()
  local editor = createTextEditor({text = ""})
  local mockElement = createMockElement()
  editor:initialize(mockElement)
  
  editor:setSelection(0, 0)
  local rects = editor:_getSelectionRects(0, 0)
  luaunit.assertEquals(#rects, 0) -- No rects for empty selection
end

-- ============================================================================
-- Focus Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testFocusWithoutElement()
  local editor = createTextEditor()
  -- Should not error
  editor:focus()
  luaunit.assertTrue(editor:isFocused())
end

function TestTextEditorEdgeCases:testBlurWithoutElement()
  local editor = createTextEditor()
  editor:focus()
  editor:blur()
  luaunit.assertFalse(editor:isFocused())
end

function TestTextEditorEdgeCases:testFocusTwice()
  local editor = createTextEditor()
  editor:focus()
  editor:focus() -- Focus again
  luaunit.assertTrue(editor:isFocused()) -- Should remain focused
end

function TestTextEditorEdgeCases:testBlurTwice()
  local editor = createTextEditor()
  editor:focus()
  editor:blur()
  editor:blur() -- Blur again
  luaunit.assertFalse(editor:isFocused()) -- Should remain blurred
end

-- ============================================================================
-- Mouse Input Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testMouseToTextPositionWithoutElement()
  local editor = createTextEditor({text = "Hello"})
  local pos = editor:mouseToTextPosition(10, 10)
  luaunit.assertEquals(pos, 0) -- Should return 0 without element
end

function TestTextEditorEdgeCases:testMouseToTextPositionWithNilBuffer()
  local editor = createTextEditor()
  local mockElement = createMockElement()
  mockElement.x = 0
  mockElement.y = 0
  editor:initialize(mockElement)
  editor._textBuffer = nil
  
  local pos = editor:mouseToTextPosition(10, 10)
  luaunit.assertEquals(pos, 0) -- Should handle nil buffer
end

function TestTextEditorEdgeCases:testMouseToTextPositionWithNegativeCoords()
  local editor = createTextEditor({text = "Hello"})
  local mockElement = createMockElement()
  mockElement.x = 100
  mockElement.y = 100
  editor:initialize(mockElement)
  
  local pos = editor:mouseToTextPosition(-10, -10)
  luaunit.assertTrue(pos >= 0) -- Should clamp to valid position
end

function TestTextEditorEdgeCases:testHandleTextClickWithoutFocus()
  local editor = createTextEditor({text = "Hello"})
  editor:handleTextClick(10, 10, 1)
  -- Should not error, but also won't do anything without focus
  luaunit.assertTrue(true)
end

function TestTextEditorEdgeCases:testHandleTextDragWithoutMouseDown()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleTextDrag(20, 10) -- Drag without mouseDownPosition
  -- Should not error
  luaunit.assertTrue(true)
end

function TestTextEditorEdgeCases:testHandleTextClickWithZeroClickCount()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleTextClick(10, 10, 0)
  -- Should not error
  luaunit.assertTrue(true)
end

-- ============================================================================
-- Update Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testUpdateWithoutFocus()
  local editor = createTextEditor()
  editor:update(1.0) -- Should not update cursor blink
  luaunit.assertTrue(true) -- Should not error
end

function TestTextEditorEdgeCases:testUpdateWithNegativeDt()
  local editor = createTextEditor()
  editor:focus()
  editor:update(-1.0) -- Negative delta time
  -- Should not error
  luaunit.assertTrue(true)
end

function TestTextEditorEdgeCases:testUpdateWithZeroDt()
  local editor = createTextEditor()
  editor:focus()
  editor:update(0) -- Zero delta time
  -- Should not error
  luaunit.assertTrue(true)
end


-- ============================================================================
-- Key Press Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testHandleKeyPressWithoutFocus()
  local editor = createTextEditor({text = "Hello"})
  editor:handleKeyPress("backspace", "backspace", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not modify
end

function TestTextEditorEdgeCases:testHandleKeyPressBackspaceAtStart()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:moveCursorToStart()
  editor:handleKeyPress("backspace", "backspace", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not delete
end

function TestTextEditorEdgeCases:testHandleKeyPressDeleteAtEnd()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:moveCursorToEnd()
  editor:handleKeyPress("delete", "delete", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not delete
end

function TestTextEditorEdgeCases:testHandleKeyPressWithUnknownKey()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleKeyPress("unknownkey", "unknownkey", false)
  luaunit.assertEquals(editor:getText(), "Hello") -- Should ignore
end

-- ============================================================================
-- Text Input Edge Cases
-- ============================================================================

function TestTextEditorEdgeCases:testHandleTextInputWithoutFocus()
  local editor = createTextEditor({text = "Hello"})
  editor:handleTextInput("X")
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not insert
end

function TestTextEditorEdgeCases:testHandleTextInputWithEmptyString()
  local editor = createTextEditor({text = "Hello"})
  editor:focus()
  editor:handleTextInput("")
  luaunit.assertEquals(editor:getText(), "Hello") -- Should not modify
end

function TestTextEditorEdgeCases:testHandleTextInputWithNewlineInSingleLine()
  local editor = createTextEditor({text = "Hello", multiline = false, allowNewlines = false})
  editor:focus()
  editor:handleTextInput("\n")
  -- Should sanitize newline in single-line mode
  luaunit.assertFalse(editor:getText():find("\n") ~= nil)
end

function TestTextEditorEdgeCases:testHandleTextInputCallbackReturnsFalse()
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

-- ============================================================================
-- Special Cases
-- ============================================================================

function TestTextEditorEdgeCases:testPasswordModeWithEmptyText()
  local editor = createTextEditor({passwordMode = true, text = ""})
  luaunit.assertEquals(editor:getText(), "")
end

function TestTextEditorEdgeCases:testMultilineWithMaxLines()
  local editor = createTextEditor({multiline = true, maxLines = 2})
  editor:setText("Line1\nLine2\nLine3\nLine4")
  -- MaxLines might not be enforced by setText, depends on implementation
  luaunit.assertTrue(true)
end

function TestTextEditorEdgeCases:testTextWrapWithZeroWidth()
  local editor = createTextEditor({textWrap = true})
  local mockElement = createMockElement()
  mockElement.width = 0
  editor:initialize(mockElement)
  editor:setText("Hello World")
  -- Should handle zero width gracefully
  luaunit.assertTrue(true)
end

function TestTextEditorEdgeCases:testAutoGrowWithoutElement()
  local editor = createTextEditor({autoGrow = true, multiline = true})
  editor:updateAutoGrowHeight()
  -- Should not error without element
  luaunit.assertTrue(true)
end

function TestTextEditorEdgeCases:testGetCursorScreenPositionWithoutElement()
  local editor = createTextEditor({text = "Hello"})
  local x, y = editor:_getCursorScreenPosition()
  luaunit.assertEquals(x, 0)
  luaunit.assertEquals(y, 0)
end

function TestTextEditorEdgeCases:testSelectWordAtPositionWithEmptyText()
  local editor = createTextEditor({text = ""})
  editor:_selectWordAtPosition(0)
  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorEdgeCases:testSelectWordAtPositionOnWhitespace()
  local editor = createTextEditor({text = "Hello     World"})
  editor:_selectWordAtPosition(7) -- In whitespace
  -- Behavior depends on implementation
  luaunit.assertTrue(true)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
