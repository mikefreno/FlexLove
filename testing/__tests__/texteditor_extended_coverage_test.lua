-- Extended coverage tests for TextEditor module
-- Focuses on uncovered code paths to increase coverage

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

local TextEditor = require("modules.TextEditor")
local Color = require("modules.Color")
local utils = require("modules.utils")

-- Mock dependencies
local MockContext = {
  _immediateMode = false,
  _focusedElement = nil,
}

local MockStateManager = {
  getState = function(id) return nil end,
  updateState = function(id, state) end,
}

-- Helper to create TextEditor
local function createTextEditor(config)
  config = config or {}
  return TextEditor.new(config, {
    Context = MockContext,
    StateManager = MockStateManager,
    Color = Color,
    utils = utils,
  })
end

-- Helper to create mock element with renderer
local function createMockElement(width, height)
  return {
    _stateId = "test-element",
    width = width or 200,
    height = height or 100,
    padding = {top = 5, right = 5, bottom = 5, left = 5},
    x = 10,
    y = 10,
    _absoluteX = 10,
    _absoluteY = 10,
    _borderBoxWidth = (width or 200) + 10,
    _borderBoxHeight = (height or 100) + 10,
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
        -- Simple word wrapping
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

-- ============================================================================
-- Update and Cursor Blink Tests
-- ============================================================================

TestTextEditorUpdate = {}

function TestTextEditorUpdate:test_update_cursor_blink_pause_resume()
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

-- ============================================================================
-- Selection Rectangle Calculation Tests
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

function TestTextEditorSelectionRects:test_getSelectionRects_with_wrapping()
  local editor = createTextEditor({
    text = "This is a long line that wraps",
    multiline = true,
    textWrap = "word"
  })
  local element = createMockElement(100, 100)
  editor:initialize(element)
  
  editor:setSelection(0, 20)
  local rects = editor:_getSelectionRects(0, 20)
  
  luaunit.assertNotNil(rects)
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

-- ============================================================================
-- Cursor Screen Position Tests
-- ============================================================================

TestTextEditorCursorPosition = {}

function TestTextEditorCursorPosition:test_getCursorScreenPosition_single_line()
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

function TestTextEditorCursorPosition:test_getCursorScreenPosition_multiline()
  local editor = createTextEditor({text = "Line 1\nLine 2", multiline = true})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setCursorPosition(10) -- Second line
  local x, y = editor:_getCursorScreenPosition()
  
  luaunit.assertNotNil(x)
  luaunit.assertNotNil(y)
end

function TestTextEditorCursorPosition:test_getCursorScreenPosition_with_wrapping()
  local editor = createTextEditor({
    text = "Very long text that will wrap",
    multiline = true,
    textWrap = "word"
  })
  local element = createMockElement(100, 100)
  editor:initialize(element)
  
  editor:setCursorPosition(15)
  local x, y = editor:_getCursorScreenPosition()
  
  luaunit.assertNotNil(x)
  luaunit.assertNotNil(y)
end

function TestTextEditorCursorPosition:test_getCursorScreenPosition_password_mode()
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

-- ============================================================================
-- Mouse Interaction Edge Cases
-- ============================================================================

TestTextEditorMouseEdgeCases = {}

function TestTextEditorMouseEdgeCases:test_handleTextDrag_sets_flag()
  local editor = createTextEditor({text = "Drag me"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:handleTextClick(10, 10, 1)
  editor:handleTextDrag(50, 10)
  
  luaunit.assertTrue(editor._textDragOccurred or not editor:hasSelection())
end

function TestTextEditorMouseEdgeCases:test_mouseToTextPosition_multiline()
  local editor = createTextEditor({text = "Line 1\nLine 2\nLine 3", multiline = true})
  local element = createMockElement()
  editor:initialize(element)
  
  -- Click on second line
  local pos = editor:mouseToTextPosition(20, 25)
  
  luaunit.assertNotNil(pos)
  luaunit.assertTrue(pos >= 0) -- Valid position
end

function TestTextEditorMouseEdgeCases:test_mouseToTextPosition_with_scroll()
  local editor = createTextEditor({text = "Very long scrolling text"})
  local element = createMockElement(100, 30)
  editor:initialize(element)
  
  editor:focus()
  editor._textScrollX = 50
  
  local pos = editor:mouseToTextPosition(30, 15)
  luaunit.assertNotNil(pos)
end

-- ============================================================================
-- Word Selection Tests
-- ============================================================================

TestTextEditorWordSelection = {}

function TestTextEditorWordSelection:test_selectWordAtPosition()
  local editor = createTextEditor({text = "Hello World Test"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:_selectWordAtPosition(7) -- "World"
  
  luaunit.assertTrue(editor:hasSelection())
  local selected = editor:getSelectedText()
  luaunit.assertEquals(selected, "World")
end

function TestTextEditorWordSelection:test_selectWordAtPosition_with_punctuation()
  local editor = createTextEditor({text = "Hello, World!"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:_selectWordAtPosition(7) -- "World"
  
  local selected = editor:getSelectedText()
  luaunit.assertEquals(selected, "World")
end

function TestTextEditorWordSelection:test_selectWordAtPosition_empty()
  local editor = createTextEditor({text = ""})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:_selectWordAtPosition(0)
  -- Should not crash
  luaunit.assertFalse(editor:hasSelection())
end

-- ============================================================================
-- State Saving Tests
-- ============================================================================

TestTextEditorStateSaving = {}

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
-- Text Wrapping Edge Cases
-- ============================================================================

TestTextEditorWrappingEdgeCases = {}

function TestTextEditorWrappingEdgeCases:test_wrapLine_empty_line()
  local editor = createTextEditor({multiline = true, textWrap = "word"})
  local element = createMockElement()
  editor:initialize(element)
  
  local wrapped = editor:_wrapLine("", 100)
  
  luaunit.assertNotNil(wrapped)
  luaunit.assertTrue(#wrapped > 0)
end

function TestTextEditorWrappingEdgeCases:test_calculateWrapping_empty_lines()
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

function TestTextEditorWrappingEdgeCases:test_calculateWrapping_no_element()
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
-- Insert Text Edge Cases
-- ============================================================================

TestTextEditorInsertEdgeCases = {}

function TestTextEditorInsertEdgeCases:test_insertText_empty_after_sanitization()
  local editor = createTextEditor({
    maxLength = 5,
    text = "12345"
  })
  local element = createMockElement()
  editor:initialize(element)
  
  -- Try to insert when at max length
  editor:insertText("67890")
  
  -- Should not insert anything
  luaunit.assertEquals(editor:getText(), "12345")
end

function TestTextEditorInsertEdgeCases:test_insertText_updates_cursor()
  local editor = createTextEditor({text = "Hello"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setCursorPosition(5)
  editor:insertText(" World")
  
  luaunit.assertEquals(editor:getCursorPosition(), 11)
end

-- ============================================================================
-- Keyboard Input Edge Cases
-- ============================================================================

TestTextEditorKeyboardEdgeCases = {}

function TestTextEditorKeyboardEdgeCases:test_handleKeyPress_escape_with_selection()
  local editor = createTextEditor({text = "Select me"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:selectAll()
  
  editor:handleKeyPress("escape", "escape", false)
  
  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorKeyboardEdgeCases:test_handleKeyPress_escape_without_selection()
  local editor = createTextEditor({text = "Test"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:handleKeyPress("escape", "escape", false)
  
  luaunit.assertFalse(editor:isFocused())
end

function TestTextEditorKeyboardEdgeCases:test_handleKeyPress_arrow_with_shift()
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

function TestTextEditorKeyboardEdgeCases:test_handleKeyPress_ctrl_backspace()
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
-- Focus Edge Cases
-- ============================================================================

TestTextEditorFocusEdgeCases = {}

function TestTextEditorFocusEdgeCases:test_focus_blurs_previous()
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

-- Run tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
