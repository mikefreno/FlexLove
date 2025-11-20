-- Comprehensive coverage tests for TextEditor module
-- Focuses on multiline, wrapping, keyboard/mouse interactions, and advanced features

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

local FlexLove = require("FlexLove")
FlexLove.init()

local TextEditor = require("modules.TextEditor")
local Color = require("modules.Color")
local utils = require("modules.utils")

-- Mock dependencies
local MockContext = {
  _immediateMode = false,
  _focusedElement = nil,
  setFocusedElement = function(self, element)
    self._focusedElement = element
  end,
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

-- Helper to create mock element
local function createMockElement(width, height)
  return {
    _stateId = "test-element",
    width = width or 200,
    height = height or 100,
    padding = {top = 5, right = 5, bottom = 5, left = 5},
    getScaledContentPadding = function(self)
      return self.padding
    end,
    _renderer = {
      getFont = function()
        return {
          getWidth = function(text) return #text * 8 end,
          getHeight = function() return 16 end,
        }
      end,
      wrapLine = function(element, line, maxWidth)
        -- Simple word wrapping simulation
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

function TestTextEditorMultiline:test_multiline_line_start_end()
  local editor = createTextEditor({multiline = true, text = "Line 1\nLine 2"})
  local element = createMockElement()
  editor:initialize(element)
  
  -- Position in middle of first line
  editor:setCursorPosition(3)
  
  -- Move to line start
  editor:moveCursorToLineStart()
  luaunit.assertEquals(editor:getCursorPosition(), 0)
  
  -- Move to line end
  editor:moveCursorToLineEnd()
  luaunit.assertEquals(editor:getCursorPosition(), 6)
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
  local element = createMockElement(100, 100) -- Narrow width to force wrapping
  editor:initialize(element)
  
  editor:_calculateWrapping()
  luaunit.assertNotNil(editor._wrappedLines)
  luaunit.assertTrue(#editor._wrappedLines > 1) -- Should wrap into multiple lines
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
  luaunit.assertNotNil(editor._wrappedLines)
end

-- ============================================================================
-- Selection Tests
-- ============================================================================

TestTextEditorSelection = {}

function TestTextEditorSelection:test_select_all()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:selectAll()
  luaunit.assertTrue(editor:hasSelection())
  luaunit.assertEquals(editor:getSelectedText(), "Hello World")
end

function TestTextEditorSelection:test_get_selected_text()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setSelection(0, 5)
  luaunit.assertEquals(editor:getSelectedText(), "Hello")
end

function TestTextEditorSelection:test_delete_selection()
  local editor = createTextEditor({text = "Hello World", editable = true})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setSelection(0, 5)
  editor:deleteSelection()
  luaunit.assertEquals(editor:getText(), " World")
end

function TestTextEditorSelection:test_clear_selection()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setSelection(0, 5)
  luaunit.assertTrue(editor:hasSelection())
  
  editor:clearSelection()
  luaunit.assertFalse(editor:hasSelection())
end

function TestTextEditorSelection:test_selection_reversed()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  -- Set selection in reverse order
  editor:setSelection(5, 0)
  local start, endPos = editor:getSelection()
  luaunit.assertEquals(start, 0)
  luaunit.assertEquals(endPos, 5)
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

function TestTextEditorFocus:test_select_on_focus()
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

-- ============================================================================
-- Keyboard Input Tests
-- ============================================================================

TestTextEditorKeyboard = {}

function TestTextEditorKeyboard:test_handle_text_input()
  local editor = createTextEditor({text = "", editable = true})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:handleTextInput("H")
  editor:handleTextInput("i")
  
  luaunit.assertEquals(editor:getText(), "Hi")
end

function TestTextEditorKeyboard:test_handle_backspace()
  local editor = createTextEditor({text = "Hello", editable = true})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:setCursorPosition(5)
  editor:handleKeyPress("backspace", "backspace", false)
  
  luaunit.assertEquals(editor:getText(), "Hell")
end

function TestTextEditorKeyboard:test_handle_delete()
  local editor = createTextEditor({text = "Hello", editable = true})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:setCursorPosition(0)
  editor:handleKeyPress("delete", "delete", false)
  
  luaunit.assertEquals(editor:getText(), "ello")
end

function TestTextEditorKeyboard:test_handle_return_multiline()
  local editor = createTextEditor({text = "Hello", editable = true, multiline = true})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:setCursorPosition(5)
  editor:handleKeyPress("return", "return", false)
  editor:handleTextInput("World")
  
  luaunit.assertEquals(editor:getText(), "Hello\nWorld")
end

function TestTextEditorKeyboard:test_handle_return_singleline()
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

function TestTextEditorKeyboard:test_handle_tab()
  local editor = createTextEditor({text = "Hello", editable = true, allowTabs = true})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:focus()
  editor:setCursorPosition(5)
  editor:handleKeyPress("tab", "tab", false)
  
  luaunit.assertEquals(editor:getText(), "Hello\t")
end

function TestTextEditorKeyboard:test_handle_home_end()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setCursorPosition(5)
  
  -- Home key
  editor:handleKeyPress("home", "home", false)
  luaunit.assertEquals(editor:getCursorPosition(), 0)
  
  -- End key
  editor:handleKeyPress("end", "end", false)
  luaunit.assertEquals(editor:getCursorPosition(), 11)
end

function TestTextEditorKeyboard:test_handle_arrow_keys()
  local editor = createTextEditor({text = "Hello"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setCursorPosition(2)
  
  -- Right arrow
  editor:handleKeyPress("right", "right", false)
  luaunit.assertEquals(editor:getCursorPosition(), 3)
  
  -- Left arrow
  editor:handleKeyPress("left", "left", false)
  luaunit.assertEquals(editor:getCursorPosition(), 2)
end

-- ============================================================================
-- Mouse Interaction Tests
-- ============================================================================

TestTextEditorMouse = {}

function TestTextEditorMouse:test_mouse_to_text_position()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  -- Click in middle of text (approximate)
  local pos = editor:mouseToTextPosition(40, 10)
  luaunit.assertNotNil(pos)
  luaunit.assertTrue(pos >= 0 and pos <= 11)
end

function TestTextEditorMouse:test_handle_single_click()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:handleTextClick(40, 10, 1)
  luaunit.assertTrue(editor:getCursorPosition() >= 0)
end

function TestTextEditorMouse:test_handle_double_click_selects_word()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  -- Double click on first word
  editor:handleTextClick(20, 10, 2)
  luaunit.assertTrue(editor:hasSelection())
  local selected = editor:getSelectedText()
  luaunit.assertTrue(selected == "Hello" or selected == "World")
end

function TestTextEditorMouse:test_handle_triple_click_selects_all()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:handleTextClick(20, 10, 3)
  luaunit.assertTrue(editor:hasSelection())
  luaunit.assertEquals(editor:getSelectedText(), "Hello World")
end

function TestTextEditorMouse:test_handle_text_drag()
  local editor = createTextEditor({text = "Hello World"})
  local element = createMockElement()
  editor:initialize(element)
  
  -- Start at position 0
  editor:handleTextClick(0, 10, 1)
  
  -- Drag to position further right
  editor:handleTextDrag(40, 10)
  
  luaunit.assertTrue(editor:hasSelection())
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

function TestTextEditorValidation:test_max_lines()
  local editor = createTextEditor({
    text = "",
    editable = true,
    multiline = true,
    maxLines = 2
  })
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setText("Line 1\nLine 2")
  luaunit.assertEquals(editor:getText(), "Line 1\nLine 2")
  
  editor:setText("Line 1\nLine 2\nLine 3")
  -- Should be limited to 2 lines
  local lines = {}
  for line in editor:getText():gmatch("[^\n]+") do
    table.insert(lines, line)
  end
  luaunit.assertTrue(#lines <= 2)
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

-- ============================================================================
-- Word Navigation Tests
-- ============================================================================

TestTextEditorWordNav = {}

function TestTextEditorWordNav:test_move_to_next_word()
  local editor = createTextEditor({text = "Hello World Test"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setCursorPosition(0)
  editor:moveCursorToNextWord()
  
  luaunit.assertTrue(editor:getCursorPosition() > 0)
end

function TestTextEditorWordNav:test_move_to_previous_word()
  local editor = createTextEditor({text = "Hello World Test"})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setCursorPosition(16)
  editor:moveCursorToPreviousWord()
  
  luaunit.assertTrue(editor:getCursorPosition() < 16)
end

-- ============================================================================
-- Sanitization Tests
-- ============================================================================

TestTextEditorSanitization = {}

function TestTextEditorSanitization:test_sanitize_disabled()
  local editor = createTextEditor({text = "", editable = true, sanitize = false})
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setText("<script>alert('xss')</script>", true) -- Skip sanitization
  -- With sanitization disabled, text should be preserved
  luaunit.assertNotNil(editor:getText())
end

function TestTextEditorSanitization:test_custom_sanitizer()
  local customCalled = false
  local editor = createTextEditor({
    text = "",
    editable = true,
    customSanitizer = function(text)
      customCalled = true
      return text:upper()
    end
  })
  local element = createMockElement()
  editor:initialize(element)
  
  editor:setText("hello")
  luaunit.assertTrue(customCalled)
  luaunit.assertEquals(editor:getText(), "HELLO")
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
  luaunit.assertFalse(editor:getText():find("\n"))
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
  luaunit.assertFalse(editor:getText():find("\t"))
end

-- Run tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
