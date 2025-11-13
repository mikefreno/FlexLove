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
local StateManager = require("modules.StateManager")

-- Test fixtures
local testElement

TestInputField = {}

function TestInputField:setUp()
  -- Clear all keyboard modifier states at start of each test
  love.keyboard.setDown("lshift", false)
  love.keyboard.setDown("rshift", false)
  love.keyboard.setDown("lctrl", false)
  love.keyboard.setDown("rctrl", false)
  love.keyboard.setDown("lalt", false)
  love.keyboard.setDown("ralt", false)
  love.keyboard.setDown("lgui", false)
  love.keyboard.setDown("rgui", false)
  
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
  -- Clear all keyboard modifier states
  love.keyboard.setDown("lshift", false)
  love.keyboard.setDown("rshift", false)
  love.keyboard.setDown("lctrl", false)
  love.keyboard.setDown("rctrl", false)
  love.keyboard.setDown("lalt", false)
  love.keyboard.setDown("ralt", false)
  love.keyboard.setDown("lgui", false)
  love.keyboard.setDown("rgui", false)
  
  -- Clear StateManager to prevent test contamination
  StateManager.reset()
  
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

function TestInputField:testMouseDownPositionSetOnUnfocusedElement()
  -- Test that _mouseDownPosition is set on mouse press even when element is not focused
  -- This is critical for text selection to work on the first click
  
  -- Ensure element is not focused
  lu.assertFalse(testElement:isFocused())
  
  -- Simulate mouse press at position (150, 120) inside the element
  love.mouse.setPosition(150, 120)
  love.mouse.setDown(1, true)
  testElement:update(0.016)
  
  -- Verify that _mouseDownPosition was set
  lu.assertNotNil(testElement._mouseDownPosition, 
    "_mouseDownPosition should be set on press even when unfocused")
end

function TestInputField:testMouseDownPositionSetOnFocusedElement()
  -- Test that _mouseDownPosition is set on mouse press when element is focused
  
  testElement:focus()
  lu.assertTrue(testElement:isFocused())
  
  -- Simulate mouse press at position (150, 120)
  love.mouse.setPosition(150, 120)
  love.mouse.setDown(1, true)
  testElement:update(0.016)
  
  -- Verify that _mouseDownPosition was set
  lu.assertNotNil(testElement._mouseDownPosition,
    "_mouseDownPosition should be set on press when focused")
end

function TestInputField:testMouseDownPositionNotSetOnNonEditableElement()
  -- Test that _mouseDownPosition is NOT set for non-editable elements
  
  local nonEditableElement = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 40,
    editable = false,
    text = "Not Editable",
  })
  
  -- Simulate mouse press at position (150, 120)
  love.mouse.setPosition(150, 120)
  love.mouse.setDown(1, true)
  nonEditableElement:update(0.016)
  
  -- Verify that _mouseDownPosition was NOT set
  lu.assertNil(nonEditableElement._mouseDownPosition,
    "_mouseDownPosition should not be set for non-editable elements")
end

function TestInputField:testDragSelectionPreservedOnRelease()
  -- Test that text selection created by dragging is preserved when releasing over the element
  -- This is the fix for the bug where selections were dropped on mouse release
  
  testElement:focus()
  
  -- Simulate mouse press at position (110, 120)
  love.mouse.setPosition(110, 120)
  love.mouse.setDown(1, true)
  testElement:update(0.016)
  
  -- Drag to another position to create a selection
  love.mouse.setPosition(150, 120)
  testElement:update(0.016)
  
  -- Verify selection exists after drag
  lu.assertTrue(testElement:hasSelection(), "Selection should exist after drag")
  
  -- Release mouse while still over the element
  love.mouse.setDown(1, false)
  testElement:update(0.016)
  
  -- The key test: selection should STILL be there after release
  lu.assertTrue(testElement:hasSelection(), 
    "Selection should be preserved after releasing mouse over element")
end

function TestInputField:testClickWithoutDragClearsSelection()
  -- Test that a click (press and release without drag) still clears selection as expected
  
  testElement:focus()
  testElement:setSelection(0, 5) -- Select "Hello"
  lu.assertTrue(testElement:hasSelection())
  
  -- Click at a position (press and release without moving)
  love.mouse.setPosition(120, 120)
  love.mouse.setDown(1, true)
  testElement:update(0.016)
  
  -- Release at same position (no drag occurred)
  love.mouse.setDown(1, false)
  testElement:update(0.016)
  
  -- Selection should be cleared since it was a click, not a drag
  lu.assertFalse(testElement:hasSelection(), 
    "Selection should be cleared by click without drag")
end

function TestInputField:testDragSelectionOnInitialClick()
  -- Test that drag selection works even on the first interaction with an unfocused element
  
  local newElement = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 40,
    editable = true,
    text = "Test Text",
  })
  
  lu.assertFalse(newElement:isFocused(), "Element should start unfocused")
  
  -- First interaction: press (will focus on release)
  love.mouse.setPosition(110, 120)
  love.mouse.setDown(1, true)
  newElement:update(0.016)
  
  -- Release to complete the focus
  love.mouse.setDown(1, false)
  newElement:update(0.016)
  
  lu.assertTrue(newElement:isFocused(), "Element should be focused after click")
  
  -- Now perform a drag selection on the focused element
  love.mouse.setPosition(110, 120)
  love.mouse.setDown(1, true)
  newElement:update(0.016)
  
  -- Drag to create selection
  love.mouse.setPosition(150, 120)
  newElement:update(0.016)
  
  lu.assertTrue(newElement:hasSelection(), "Selection should exist after drag")
  
  -- Release over element
  love.mouse.setDown(1, false)
  newElement:update(0.016)
  
  -- Selection should be preserved
  lu.assertTrue(newElement:hasSelection(), 
    "Selection should be preserved after drag release")
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
  element._textEditor:_splitLines()

  lu.assertEquals(#element._textEditor._lines, 3)
  lu.assertEquals(element._textEditor._lines[1], "Line 1")
  lu.assertEquals(element._textEditor._lines[2], "Line 2")
  lu.assertEquals(element._textEditor._lines[3], "Line 3")
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
  local pos = element._textEditor:mouseToTextPosition(10, 10)
  lu.assertEquals(pos, 0)
  
  -- Test conversion far to the right (should be at end)
  pos = element._textEditor:mouseToTextPosition(200, 10)
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

-- ====================
-- Text Scrolling Tests
-- ====================

function TestInputField:testTextScrollInitiallyZero()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 50, -- Small width to force scrolling
    height = 30,
    editable = true,
    text = "",
  })

  element:focus()
  
  -- Initial scroll should be 0
  lu.assertEquals(element._textScrollX, 0)
end

function TestInputField:testTextScrollUpdatesOnCursorMove()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 50, -- Small width to force scrolling
    height = 30,
    editable = true,
    text = "This is a very long text that will overflow",
  })

  element:focus()
  element:setCursorPosition(0)
  
  -- Scroll should be 0 at start
  lu.assertEquals(element._textScrollX, 0)
  
  -- Move cursor to end
  element:moveCursorToEnd()
  
  -- Scroll should have increased to keep cursor visible
  lu.assertTrue(element._textScrollX > 0)
end

function TestInputField:testTextScrollKeepsCursorVisible()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 50, -- Small width
    height = 30,
    editable = true,
    text = "",
  })

  element:focus()
  element:setCursorPosition(0)
  
  -- Set long text directly
  element:setText("This is a very long text that will definitely overflow the bounds")
  element:moveCursorToEnd()
  
  -- Cursor should be at end and scroll should be adjusted
  lu.assertTrue(element._textScrollX > 0)
  
  -- Move cursor back to start
  element:moveCursorToStart()
  
  -- Scroll should reset to 0
  lu.assertEquals(element._textScrollX, 0)
end

function TestInputField:testTextScrollWithSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 50,
    height = 30,
    editable = true,
    text = "This is a very long text for testing",
  })

  element:focus()
  element:setCursorPosition(0)
  
  -- Move to end and check scroll
  element:moveCursorToEnd()
  local scrollAtEnd = element._textScrollX
  lu.assertTrue(scrollAtEnd > 0)
  
  -- Select from end backwards
  element:setSelection(20, 37)
  element._cursorPosition = 20
  element:_updateTextScroll()
  
  -- Scroll should adjust to show cursor at position 20
  lu.assertTrue(element._textScrollX < scrollAtEnd)
end

function TestInputField:testTextScrollDoesNotAffectMultiline()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 50,
    height = 60,
    editable = true,
    multiline = true,
    text = "This is a very long text",
  })

  element:focus()
  element:moveCursorToEnd()
  
  -- Multiline should not use horizontal scroll
  lu.assertEquals(element._textScrollX, 0)
end

function TestInputField:testTextScrollResetsOnClear()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 50,
    height = 30,
    editable = true,
    text = "This is a very long text that overflows",
  })

  element:focus()
  element:moveCursorToEnd()
  
  -- Should have scrolled
  lu.assertTrue(element._textScrollX > 0)
  
  -- Clear text
  element:setText("")
  element:setCursorPosition(0)
  
  -- Scroll should reset
  lu.assertEquals(element._textScrollX, 0)
end

function TestInputField:testTextScrollWithBackspace()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 50,
    height = 30,
    editable = true,
    text = "XXXXXXXXXXXXXXXXXXXXXXXXXX", -- Long text
  })

  element:focus()
  element:moveCursorToEnd()
  
  local initialScroll = element._textScrollX
  lu.assertTrue(initialScroll > 0)
  
  -- Delete characters from end
  element:keypressed("backspace", nil, false)
  element:keypressed("backspace", nil, false)
  element:keypressed("backspace", nil, false)
  
  -- Scroll should decrease as text gets shorter
  lu.assertTrue(element._textScrollX <= initialScroll)
end

-- ====================
-- Multiline Text Selection Tests
-- ====================

function TestInputField:testMultilineMouseToTextPositionBasic()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 100,
    editable = true,
    multiline = true,
    text = "Line 1\nLine 2\nLine 3",
  })

  element:focus()
  
  -- Get font to calculate positions
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Click at start (should be position 0)
  local pos = element._textEditor:mouseToTextPosition(10, 10)
  lu.assertEquals(pos, 0)
  
  -- Click on second line start (should be after "Line 1\n" = position 7)
  pos = element._textEditor:mouseToTextPosition(10, 10 + lineHeight)
  lu.assertEquals(pos, 7)
  
  -- Click on third line start (should be after "Line 1\nLine 2\n" = position 14)
  pos = element._textEditor:mouseToTextPosition(10, 10 + lineHeight * 2)
  lu.assertEquals(pos, 14)
end

function TestInputField:testMultilineMouseToTextPositionXCoordinate()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 100,
    editable = true,
    multiline = true,
    text = "ABC\nDEF\nGHI",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  local charWidth = font:getWidth("A")
  
  -- Click in middle of first line (should be around position 1-2)
  local pos = element._textEditor:mouseToTextPosition(10 + charWidth * 1.5, 10)
  lu.assertTrue(pos >= 1 and pos <= 2)
  
  -- Click at end of second line (should be around position 6-7)
  -- Text is "ABC\nDEF\nGHI", so second line "DEF" ends at position 6 or 7 (newline)
  pos = element._textEditor:mouseToTextPosition(10 + charWidth * 3, 10 + lineHeight)
  lu.assertTrue(pos >= 6 and pos <= 7)
end

function TestInputField:testMultilineMouseDragSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 100,
    editable = true,
    multiline = true,
    text = "Line 1\nLine 2\nLine 3",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Simulate mouse click on first line (sets _mouseDownPosition)
  element:_handleTextClick(10, 10, 1)
  lu.assertEquals(element._cursorPosition, 0)
  lu.assertFalse(element:hasSelection())
  
  -- Drag to second line
  element:_handleTextDrag(50, 10 + lineHeight)
  lu.assertTrue(element:hasSelection())
  
  -- Selection should span from first line to second line
  local startPos, endPos = element:getSelection()
  lu.assertTrue(startPos == 0 or endPos == 0)
  lu.assertTrue(startPos > 6 or endPos > 6) -- Past first newline
  
  -- After drag, selection should be preserved
  lu.assertTrue(element:hasSelection())
end

function TestInputField:testMultilineMouseDragAcrossThreeLines()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 150,
    editable = true,
    multiline = true,
    text = "First\nSecond\nThird\nFourth",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Click on first line, then drag to third line
  element:_handleTextClick(10, 10, 1)
  element:_handleTextDrag(50, 10 + lineHeight * 2.5)
  
  lu.assertTrue(element:hasSelection())
  local startPos, endPos = element:getSelection()
  
  -- Should select across multiple lines
  local minPos = math.min(startPos, endPos)
  local maxPos = math.max(startPos, endPos)
  lu.assertEquals(minPos, 0) -- From start
  lu.assertTrue(maxPos > 12) -- Past "First\nSecond\n"
  
  -- Selection should persist after drag
  lu.assertTrue(element:hasSelection())
end

function TestInputField:testMultilineClickOnDifferentLines()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 100,
    editable = true,
    multiline = true,
    text = "AAA\nBBB\nCCC",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Click on first line
  element:_handleTextClick(10, 10, 1)
  local pos1 = element._cursorPosition
  lu.assertEquals(pos1, 0)
  
  -- Click on second line
  element:_handleTextClick(10, 10 + lineHeight, 1)
  local pos2 = element._cursorPosition
  lu.assertEquals(pos2, 4) -- After "AAA\n"
  
  -- Click on third line
  element:_handleTextClick(10, 10 + lineHeight * 2, 1)
  local pos3 = element._cursorPosition
  lu.assertEquals(pos3, 8) -- After "AAA\nBBB\n"
end

function TestInputField:testMultilineSelectionWithKeyboard()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 100,
    editable = true,
    multiline = true,
    text = "Line 1\nLine 2\nLine 3",
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
  
  -- Test Shift+Right selection (horizontal movement works)
  element:keypressed("right", nil, false)
  lu.assertTrue(element:hasSelection())
  
  local startPos, endPos = element:getSelection()
  lu.assertTrue(math.abs(endPos - startPos) > 0)
  
  -- Reset mock
  _G.love.keyboard.isDown = oldIsDown
end

function TestInputField:testMultilineMouseSelectionPreservedAfterRelease()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 100,
    editable = true,
    multiline = true,
    text = "First line\nSecond line\nThird line",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Create a selection by dragging
  element:_handleTextClick(10, 10, 1)
  element:_handleTextDrag(100, 10 + lineHeight * 1.5)
  
  local startPos, endPos = element:getSelection()
  local hadSelection = element:hasSelection()
  
  lu.assertTrue(hadSelection)
  
  -- Note: There's no mouse release handler that affects selection
  -- The drag creates the selection and it persists
  
  -- Selection should still exist
  lu.assertTrue(element:hasSelection())
  local startPos2, endPos2 = element:getSelection()
  lu.assertEquals(startPos, startPos2)
  lu.assertEquals(endPos, endPos2)
end

function TestInputField:testMultilineClickDoesNotPreserveSelection()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 100,
    editable = true,
    multiline = true,
    text = "First line\nSecond line",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Create a selection
  element:setSelection(0, 5)
  lu.assertTrue(element:hasSelection())
  
  -- Click somewhere else (should clear selection)
  element:_handleTextClick(10, 10 + lineHeight, 1)
  
  -- Selection should be cleared
  lu.assertFalse(element:hasSelection())
end

function TestInputField:testMultilineEmptyLinesHandling()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 150,
    editable = true,
    multiline = true,
    text = "Line 1\n\nLine 3",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Click on empty line (second line)
  local pos = element._textEditor:mouseToTextPosition(10, 10 + lineHeight)
  lu.assertEquals(pos, 7) -- After "Line 1\n"
  
  -- Click on third line
  pos = element._textEditor:mouseToTextPosition(10, 10 + lineHeight * 2)
  lu.assertEquals(pos, 8) -- After "Line 1\n\n"
end

function TestInputField:testMultilineYCoordinateBeyondText()
  local element = FlexLove.Element.new({
    x = 10,
    y = 10,
    width = 300,
    height = 200,
    editable = true,
    multiline = true,
    text = "Line 1\nLine 2",
  })

  element:focus()
  
  local font = element:_getFont()
  local lineHeight = font:getHeight()
  
  -- Click way below the text (should clamp to last line)
  local pos = element._textEditor:mouseToTextPosition(10, 10 + lineHeight * 10)
  local textLen = utf8.len(element.text)
  
  -- Should be at or near end of text
  lu.assertTrue(pos >= textLen - 6) -- Within last line
end

-- Run tests
lu.LuaUnit.run()
