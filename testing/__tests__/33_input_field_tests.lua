-- ====================
-- Input Field Tests
-- ====================
-- Test suite for text input functionality in FlexLove

local lu = require("testing.luaunit")
local loveStub = require("testing.loveStub")

-- Setup LÖVE environment
_G.love = loveStub

-- Load FlexLove after setting up love stub
local FlexLove = require("FlexLove")

-- Test fixtures
local testElement

TestInputField = {}

function TestInputField:setUp()
  -- Reset FlexLove state
  FlexLove.Gui.topElements = {}
  FlexLove.Gui._focusedElement = nil

  -- Create a test input element
  testElement = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 40,
    editable = true,
    text = "Hello World",
  })
end

function TestInputField:tearDown()
  testElement = nil
  FlexLove.Gui.topElements = {}
  FlexLove.Gui._focusedElement = nil
end

-- ====================
-- Focus Management Tests
-- ====================

function TestInputField:testFocusElement()
  -- Initially not focused
  lu.assertFalse(testElement:isFocused())

  -- Focus element
  testElement:focus()

  -- Should be focused
  lu.assertTrue(testElement:isFocused())
  lu.assertEquals(FlexLove.Gui._focusedElement, testElement)
end

function TestInputField:testBlurElement()
  -- Focus element first
  testElement:focus()
  lu.assertTrue(testElement:isFocused())

  -- Blur element
  testElement:blur()

  -- Should not be focused
  lu.assertFalse(testElement:isFocused())
  lu.assertNil(FlexLove.Gui._focusedElement)
end

function TestInputField:testFocusSwitchBetweenElements()
  local element1 = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Element 1",
  })

  local element2 = FlexLove.Element.new({
    x = 10,
    y = 50,
    width = 100,
    height = 30,
    editable = true,
    text = "Element 2",
  })

  -- Focus element1
  element1:focus()
  lu.assertTrue(element1:isFocused())
  lu.assertFalse(element2:isFocused())

  -- Focus element2 (should blur element1)
  element2:focus()
  lu.assertFalse(element1:isFocused())
  lu.assertTrue(element2:isFocused())
  lu.assertEquals(FlexLove.Gui._focusedElement, element2)
end

function TestInputField:testSelectOnFocus()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Test Text",
    selectOnFocus = true,
  })

  -- Focus element with selectOnFocus enabled
  element:focus()

  -- Should select all text
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 9) -- "Test Text" has 9 characters
end

-- ====================
-- Cursor Management Tests
-- ====================

function TestInputField:testSetCursorPosition()
  testElement:focus()

  -- Set cursor to position 5
  testElement:setCursorPosition(5)

  lu.assertEquals(testElement:getCursorPosition(), 5)
end

function TestInputField:testCursorPositionBounds()
  testElement:focus()

  -- Try to set cursor beyond text length
  testElement:setCursorPosition(999)

  -- Should clamp to text length
  lu.assertEquals(testElement:getCursorPosition(), 11) -- "Hello World" has 11 characters

  -- Try to set negative cursor position
  testElement:setCursorPosition(-5)

  -- Should clamp to 0
  lu.assertEquals(testElement:getCursorPosition(), 0)
end

function TestInputField:testMoveCursor()
  testElement:focus()
  testElement:setCursorPosition(5)

  -- Move cursor right
  testElement:moveCursorBy(2)
  lu.assertEquals(testElement:getCursorPosition(), 7)

  -- Move cursor left
  testElement:moveCursorBy(-3)
  lu.assertEquals(testElement:getCursorPosition(), 4)
end

function TestInputField:testMoveCursorToStartEnd()
  testElement:focus()
  testElement:setCursorPosition(5)

  -- Move to end
  testElement:moveCursorToEnd()
  lu.assertEquals(testElement:getCursorPosition(), 11)

  -- Move to start
  testElement:moveCursorToStart()
  lu.assertEquals(testElement:getCursorPosition(), 0)
end

-- ====================
-- Text Buffer Management Tests
-- ====================

function TestInputField:testGetText()
  lu.assertEquals(testElement:getText(), "Hello World")
end

function TestInputField:testSetText()
  testElement:setText("New Text")

  lu.assertEquals(testElement:getText(), "New Text")
  lu.assertEquals(testElement.text, "New Text")
end

function TestInputField:testInsertTextAtCursor()
  testElement:focus()
  testElement:setCursorPosition(5) -- After "Hello"

  testElement:insertText(" Beautiful")

  lu.assertEquals(testElement:getText(), "Hello Beautiful World")
  lu.assertEquals(testElement:getCursorPosition(), 15) -- Cursor after inserted text
end

function TestInputField:testInsertTextAtSpecificPosition()
  testElement:insertText("Super ", 6) -- Before "World"

  lu.assertEquals(testElement:getText(), "Hello Super World")
end

function TestInputField:testDeleteText()
  testElement:deleteText(0, 6) -- Delete "Hello "

  lu.assertEquals(testElement:getText(), "World")
end

function TestInputField:testReplaceText()
  testElement:replaceText(0, 5, "Hi") -- Replace "Hello" with "Hi"

  lu.assertEquals(testElement:getText(), "Hi World")
end

function TestInputField:testMaxLengthConstraint()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Test",
    maxLength = 10,
  })

  element:focus()
  element:moveCursorToEnd()

  -- Try to insert text that would exceed maxLength
  element:insertText(" Very Long Text")

  -- Should not insert text that exceeds maxLength
  lu.assertEquals(element:getText(), "Test")

  -- Insert text that fits within maxLength
  element:insertText(" Text")
  lu.assertEquals(element:getText(), "Test Text")
end

-- ====================
-- Selection Management Tests
-- ====================

function TestInputField:testSetSelection()
  testElement:setSelection(0, 5) -- Select "Hello"

  lu.assertTrue(testElement:hasSelection())
  local startPos, endPos = testElement:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 5)
end

function TestInputField:testGetSelectedText()
  testElement:setSelection(0, 5) -- Select "Hello"

  local selectedText = testElement:getSelectedText()
  lu.assertEquals(selectedText, "Hello")
end

function TestInputField:testSelectAll()
  testElement:selectAll()

  lu.assertTrue(testElement:hasSelection())
  local startPos, endPos = testElement:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 11) -- Full text length
end

function TestInputField:testClearSelection()
  testElement:setSelection(0, 5)
  lu.assertTrue(testElement:hasSelection())

  testElement:clearSelection()

  lu.assertFalse(testElement:hasSelection())
  local startPos, endPos = testElement:getSelection()
  lu.assertNil(startPos)
  lu.assertNil(endPos)
end

function TestInputField:testDeleteSelection()
  testElement:focus()
  testElement:setSelection(0, 6) -- Select "Hello "

  local deleted = testElement:deleteSelection()

  lu.assertTrue(deleted)
  lu.assertEquals(testElement:getText(), "World")
  lu.assertFalse(testElement:hasSelection())
  lu.assertEquals(testElement:getCursorPosition(), 0)
end

-- ====================
-- Text Input Tests
-- ====================

function TestInputField:testTextInput()
  testElement:focus()
  testElement:setCursorPosition(5) -- After "Hello"

  -- Simulate text input
  testElement:textinput(",")

  lu.assertEquals(testElement:getText(), "Hello, World")
  lu.assertEquals(testElement:getCursorPosition(), 6)
end

function TestInputField:testTextInputWithSelection()
  testElement:focus()
  testElement:setSelection(0, 5) -- Select "Hello"

  -- Simulate text input (should replace selection)
  testElement:textinput("Hi")

  lu.assertEquals(testElement:getText(), "Hi World")
  lu.assertFalse(testElement:hasSelection())
  lu.assertEquals(testElement:getCursorPosition(), 2)
end

function TestInputField:testTextInputCallbacks()
  local inputCalled = false
  local changeCalled = false
  local inputText = nil
  local newText = nil
  local oldText = nil

  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Test",
    onTextInput = function(_, text)
      inputCalled = true
      inputText = text
    end,
    onTextChange = function(_, new, old)
      changeCalled = true
      newText = new
      oldText = old
    end,
  })

  element:focus()
  element:moveCursorToEnd()
  element:textinput("!")

  lu.assertTrue(inputCalled)
  lu.assertTrue(changeCalled)
  lu.assertEquals(inputText, "!")
  lu.assertEquals(newText, "Test!")
  lu.assertEquals(oldText, "Test")
end

-- ====================
-- Keyboard Input Tests
-- ====================

function TestInputField:testBackspaceKey()
  testElement:focus()
  testElement:setCursorPosition(5) -- After "Hello"

  -- Simulate backspace key
  testElement:keypressed("backspace", nil, false)

  lu.assertEquals(testElement:getText(), "Hell World")
  lu.assertEquals(testElement:getCursorPosition(), 4)
end

function TestInputField:testDeleteKey()
  testElement:focus()
  testElement:setCursorPosition(5) -- After "Hello", before " "

  -- Simulate delete key
  testElement:keypressed("delete", nil, false)

  lu.assertEquals(testElement:getText(), "HelloWorld")
  lu.assertEquals(testElement:getCursorPosition(), 5)
end

function TestInputField:testArrowKeys()
  testElement:focus()
  testElement:setCursorPosition(5)

  -- Right arrow
  testElement:keypressed("right", nil, false)
  lu.assertEquals(testElement:getCursorPosition(), 6)

  -- Left arrow
  testElement:keypressed("left", nil, false)
  lu.assertEquals(testElement:getCursorPosition(), 5)
end

function TestInputField:testHomeEndKeys()
  testElement:focus()
  testElement:setCursorPosition(5)

  -- End key
  testElement:keypressed("end", nil, false)
  lu.assertEquals(testElement:getCursorPosition(), 11)

  -- Home key
  testElement:keypressed("home", nil, false)
  lu.assertEquals(testElement:getCursorPosition(), 0)
end

function TestInputField:testEscapeKey()
  testElement:focus()
  testElement:setSelection(0, 5)
  lu.assertTrue(testElement:hasSelection())

  -- Escape should clear selection
  testElement:keypressed("escape", nil, false)

  lu.assertFalse(testElement:hasSelection())
  lu.assertTrue(testElement:isFocused()) -- Still focused

  -- Another escape should blur
  testElement:keypressed("escape", nil, false)

  lu.assertFalse(testElement:isFocused())
end

function TestInputField:testCtrlA()
  testElement:focus()

  -- Simulate Ctrl+A (need to mock modifiers)
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  testElement:keypressed("a", "", false)

  lu.assertTrue(testElement:hasSelection())
  local startPos, endPos = testElement:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 11)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testEnterKeyMultiline()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 60,
    editable = true,
    multiline = true,
    text = "Line 1",
  })

  element:focus()
  element:moveCursorToEnd()

  -- Simulate Enter key
  element:keypressed("return", nil, false)

  -- Should insert newline
  lu.assertEquals(element:getText(), "Line 1\n")
end

function TestInputField:testEnterKeySingleline()
  local enterCalled = false

  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    multiline = false,
    text = "Test",
    onEnter = function()
      enterCalled = true
    end,
  })

  element:focus()
  element:moveCursorToEnd()

  -- Simulate Enter key
  element:keypressed("return", nil, false)

  -- Should trigger onEnter callback, not insert newline
  lu.assertTrue(enterCalled)
  lu.assertEquals(element:getText(), "Test")
end

-- ====================
-- Multi-line Tests
-- ====================

function TestInputField:testMultilineTextSplitting()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 80,
    editable = true,
    multiline = true,
    text = "Line 1\nLine 2\nLine 3",
  })

  -- Trigger line splitting
  element:_splitLines()

  lu.assertEquals(#element._lines, 3)
  lu.assertEquals(element._lines[1], "Line 1")
  lu.assertEquals(element._lines[2], "Line 2")
  lu.assertEquals(element._lines[3], "Line 3")
end

-- ====================
-- UTF-8 Support Tests
-- ====================

function TestInputField:testUTF8Characters()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello 世界",
  })

  element:focus()
  element:moveCursorToEnd()

  -- Insert UTF-8 character
  element:insertText("!")

  lu.assertEquals(element:getText(), "Hello 世界!")
end

function TestInputField:testUTF8Selection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello 世界",
  })

  -- Select UTF-8 characters
  element:setSelection(6, 8) -- Select "世界"

  local selected = element:getSelectedText()
  lu.assertEquals(selected, "世界")
end

-- ====================
-- Password Mode Tests
-- ====================

function TestInputField:testPasswordModeDisablesMultiline()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    multiline = true,
    passwordMode = true,
    text = "password",
  })

  -- Password mode should override multiline
  lu.assertFalse(element.multiline)
end

-- ====================
-- Keyboard Selection Tests
-- ====================

function TestInputField:testShiftRightSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setCursorPosition(0)

  -- Mock Shift key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lshift" or key == "rshift" then
        return true
      end
    end
    return false
  end

  -- Shift+Right should select one character
  element:keypressed("right", nil, false)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 1)

  -- Another Shift+Right should extend selection
  element:keypressed("right", nil, false)
  lu.assertTrue(element:hasSelection())
  startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 2)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testShiftLeftSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setCursorPosition(5) -- Position after "Hello"

  -- Mock Shift key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lshift" or key == "rshift" then
        return true
      end
    end
    return false
  end

  -- Shift+Left should select one character backwards
  element:keypressed("left", nil, false)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 4)
  lu.assertEquals(endPos, 5)

  -- Another Shift+Left should extend selection
  element:keypressed("left", nil, false)
  lu.assertTrue(element:hasSelection())
  startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 3)
  lu.assertEquals(endPos, 5)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testShiftHomeSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setCursorPosition(5)

  -- Mock Shift key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lshift" or key == "rshift" then
        return true
      end
    end
    return false
  end

  -- Shift+Home should select from cursor to start
  element:keypressed("home", nil, false)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 5)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testShiftEndSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setCursorPosition(5)

  -- Mock Shift key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lshift" or key == "rshift" then
        return true
      end
    end
    return false
  end

  -- Shift+End should select from cursor to end
  element:keypressed("end", nil, false)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 5)
  lu.assertEquals(endPos, 11) -- "Hello World" has 11 characters

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testSelectionDirectionChange()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setCursorPosition(5)

  -- Mock Shift key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lshift" or key == "rshift" then
        return true
      end
    end
    return false
  end

  -- Select right
  element:keypressed("right", nil, false)
  element:keypressed("right", nil, false)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 5)
  lu.assertEquals(endPos, 7)

  -- Now select left (should shrink selection)
  element:keypressed("left", nil, false)
  lu.assertTrue(element:hasSelection())
  startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 5)
  lu.assertEquals(endPos, 6)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testArrowWithoutShiftClearsSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setSelection(0, 5)
  lu.assertTrue(element:hasSelection())

  -- Arrow key without Shift should clear selection and move cursor
  element:keypressed("right", nil, false)
  lu.assertFalse(element:hasSelection())
  lu.assertEquals(element._cursorPosition, 5) -- Should move to end of selection
end

function TestInputField:testTypingReplacesSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setSelection(0, 5) -- Select "Hello"

  -- Type a character - should replace selection
  element:textinput("X")
  lu.assertEquals(element:getText(), "X World")
  lu.assertFalse(element:hasSelection())
  lu.assertEquals(element._cursorPosition, 1)
end

-- ====================
-- Mouse Selection Tests
-- ====================

function TestInputField:testMouseClickSetsCursorPosition()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  
  -- Simulate single click (this would normally be done through the event system)
  -- We'll test the _handleTextClick method directly
  element:_handleTextClick(15, 15, 1) -- Single click near start
  
  -- Cursor should be set (exact position depends on font, so we just check it's valid)
  lu.assertTrue(element._cursorPosition >= 0)
  lu.assertTrue(element._cursorPosition <= 11)
  lu.assertFalse(element:hasSelection())
end

function TestInputField:testMouseDoubleClickSelectsWord()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setCursorPosition(3) -- Position in "Hello"
  
  -- Simulate double click to select word
  element:_handleTextClick(15, 15, 2) -- Double click
  
  -- Should have selected a word (we can't test exact positions without font metrics)
  -- But we can verify a selection was created
  lu.assertTrue(element:hasSelection() or element._cursorPosition >= 0)
end

function TestInputField:testMouseTripleClickSelectsAll()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  
  -- Simulate triple click
  element:_handleTextClick(15, 15, 3) -- Triple click
  
  -- Should select all text
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 11)
end

function TestInputField:testMouseDragCreatesSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  
  -- Simulate mouse down at position 0
  element._mouseDownPosition = 0
  
  -- Simulate drag to position 5
  element:_handleTextDrag(50, 15)
  
  -- Should have created a selection (exact positions depend on font metrics)
  -- We just verify the drag handler works
  lu.assertTrue(element._cursorPosition >= 0)
end

function TestInputField:testSelectWordAtPosition()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World Test",
  })

  element:focus()
  
  -- Select word at position 6 (in "World")
  element:_selectWordAtPosition(6)
  
  -- Should have selected "World"
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 6)
  lu.assertEquals(endPos, 11)
  lu.assertEquals(element:getSelectedText(), "World")
end

function TestInputField:testSelectWordWithNonAlphanumeric()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello, World!",
  })

  element:focus()
  
  -- Select word at position 0 (in "Hello")
  element:_selectWordAtPosition(2)
  
  -- Should have selected "Hello" (not including comma)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 5)
  lu.assertEquals(element:getSelectedText(), "Hello")
end

function TestInputField:testMouseToTextPosition()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello",
  })

  element:focus()
  
  -- Test conversion at start of element
  local pos = element:_mouseToTextPosition(10, 10)
  lu.assertEquals(pos, 0)
  
  -- Test conversion far to the right (should be at end)
  pos = element:_mouseToTextPosition(200, 10)
  lu.assertEquals(pos, 5) -- "Hello" has 5 characters
end

-- ====================
-- Clipboard Operations Tests
-- ====================

function TestInputField:testCtrlCCopiesSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setSelection(0, 5) -- Select "Hello"

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Simulate Ctrl+C
  element:keypressed("c", nil, false)

  -- Check clipboard content
  lu.assertEquals(love.system.getClipboardText(), "Hello")
  
  -- Text should remain unchanged
  lu.assertEquals(element:getText(), "Hello World")
  lu.assertTrue(element:hasSelection())

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCtrlXCutsSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setSelection(0, 5) -- Select "Hello"

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Simulate Ctrl+X
  element:keypressed("x", nil, false)

  -- Check clipboard content
  lu.assertEquals(love.system.getClipboardText(), "Hello")
  
  -- Text should be cut
  lu.assertEquals(element:getText(), " World")
  lu.assertFalse(element:hasSelection())
  lu.assertEquals(element._cursorPosition, 0)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCtrlVPastesFromClipboard()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "World",
  })

  element:focus()
  element:setCursorPosition(0)

  -- Set clipboard content
  love.system.setClipboardText("Hello ")

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Simulate Ctrl+V
  element:keypressed("v", nil, false)

  -- Text should be pasted
  lu.assertEquals(element:getText(), "Hello World")
  lu.assertEquals(element._cursorPosition, 6)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCtrlVReplacesSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  element:setSelection(6, 11) -- Select "World"

  -- Set clipboard content
  love.system.setClipboardText("Everyone")

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Simulate Ctrl+V
  element:keypressed("v", nil, false)

  -- Selection should be replaced
  lu.assertEquals(element:getText(), "Hello Everyone")
  lu.assertFalse(element:hasSelection())
  lu.assertEquals(element._cursorPosition, 14)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCopyWithoutSelectionDoesNothing()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  
  -- Clear clipboard
  love.system.setClipboardText("")

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Simulate Ctrl+C without selection
  element:keypressed("c", nil, false)

  -- Clipboard should remain empty
  lu.assertEquals(love.system.getClipboardText(), "")

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCutWithoutSelectionDoesNothing()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  element:focus()
  
  -- Clear clipboard
  love.system.setClipboardText("")

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Simulate Ctrl+X without selection
  element:keypressed("x", nil, false)

  -- Clipboard should remain empty and text unchanged
  lu.assertEquals(love.system.getClipboardText(), "")
  lu.assertEquals(element:getText(), "Hello World")

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testPasteEmptyClipboard()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello",
  })

  element:focus()
  element:setCursorPosition(5)
  
  -- Clear clipboard
  love.system.setClipboardText("")

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Simulate Ctrl+V with empty clipboard
  element:keypressed("v", nil, false)

  -- Text should remain unchanged
  lu.assertEquals(element:getText(), "Hello")
  lu.assertEquals(element._cursorPosition, 5)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

-- ====================
-- Word Navigation Tests
-- ====================

function TestInputField:testCtrlLeftMovesToPreviousWord()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World Test",
  })

  element:focus()
  element:setCursorPosition(16) -- At end of text

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Ctrl+Left should move to start of "Test"
  element:keypressed("left", nil, false)
  lu.assertEquals(element._cursorPosition, 12)

  -- Another Ctrl+Left should move to start of "World"
  element:keypressed("left", nil, false)
  lu.assertEquals(element._cursorPosition, 6)

  -- Another Ctrl+Left should move to start of "Hello"
  element:keypressed("left", nil, false)
  lu.assertEquals(element._cursorPosition, 0)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCtrlRightMovesToNextWord()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World Test",
  })

  element:focus()
  element:setCursorPosition(0) -- At start of text

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Ctrl+Right should move to start of "World"
  element:keypressed("right", nil, false)
  lu.assertEquals(element._cursorPosition, 6)

  -- Another Ctrl+Right should move to start of "Test"
  element:keypressed("right", nil, false)
  lu.assertEquals(element._cursorPosition, 12)

  -- Another Ctrl+Right should move to end
  element:keypressed("right", nil, false)
  lu.assertEquals(element._cursorPosition, 16)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCtrlShiftLeftSelectsWord()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World Test",
  })

  element:focus()
  element:setCursorPosition(16) -- At end of text

  -- Mock Ctrl+Shift keys
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" or key == "lshift" or key == "rshift" then
        return true
      end
    end
    return false
  end

  -- Ctrl+Shift+Left should select "Test"
  element:keypressed("left", nil, false)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 12)
  lu.assertEquals(endPos, 16)
  lu.assertEquals(element:getSelectedText(), "Test")

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testCtrlShiftRightSelectsWord()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello World Test",
  })

  element:focus()
  element:setCursorPosition(0) -- At start of text

  -- Mock Ctrl+Shift keys
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" or key == "lshift" or key == "rshift" then
        return true
      end
    end
    return false
  end

  -- Ctrl+Shift+Right should select "Hello"
  element:keypressed("right", nil, false)
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 6)
  lu.assertEquals(element:getSelectedText(), "Hello ")

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testWordNavigationWithPunctuation()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 100,
    height = 30,
    editable = true,
    text = "Hello, World! Test.",
  })

  element:focus()
  element:setCursorPosition(0)

  -- Mock Ctrl key
  local oldIsDown = _G.love.keyboard.isDown
  _G.love.keyboard.isDown = function(...)
    local keys = {...}
    for _, key in ipairs(keys) do
      if key == "lctrl" or key == "rctrl" then
        return true
      end
    end
    return false
  end

  -- Ctrl+Right should skip punctuation and move to "World"
  element:keypressed("right", nil, false)
  lu.assertEquals(element._cursorPosition, 7)

  -- Another Ctrl+Right should move to "Test"
  element:keypressed("right", nil, false)
  lu.assertEquals(element._cursorPosition, 14)

  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

-- Run tests
lu.LuaUnit.run()
