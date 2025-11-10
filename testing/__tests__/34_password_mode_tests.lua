-- ====================
-- Password Mode Tests
-- ====================
-- Test suite for password mode functionality in FlexLove input fields

local lu = require("testing.luaunit")
local loveStub = require("testing.loveStub")
local utf8 = require("utf8")

-- Setup LÖVE environment
_G.love = loveStub

-- Load FlexLove after setting up love stub
local FlexLove = require("FlexLove")
local StateManager = require("modules.StateManager")

-- Test fixtures
local testElement

TestPasswordMode = {}

function TestPasswordMode:setUp()
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

  -- Create a test password input element
  testElement = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 40,
    editable = true,
    passwordMode = true,
    text = "",
  })
end

function TestPasswordMode:tearDown()
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
-- Property Tests
-- ====================

function TestPasswordMode:testPasswordModePropertyExists()
  -- Test that passwordMode property exists and can be set
  lu.assertNotNil(testElement.passwordMode)
  lu.assertTrue(testElement.passwordMode)
end

function TestPasswordMode:testPasswordModeDefaultIsFalse()
  -- Test that passwordMode defaults to false
  local normalElement = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 40,
    editable = true,
    text = "Normal text",
  })

  lu.assertFalse(normalElement.passwordMode or false)
end

function TestPasswordMode:testPasswordModeIsSingleLineOnly()
  -- Password mode should only work with single-line inputs
  -- The constraint is enforced in Element.lua line 292-293
  local multilinePassword = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    editable = true,
    multiline = true,
    passwordMode = true,
    text = "Password",
  })

  -- Based on the constraint, multiline should be set to false
  lu.assertFalse(multilinePassword.multiline)
end

-- ====================
-- Text Buffer Tests
-- ====================

function TestPasswordMode:testActualTextContentRemains()
  -- Insert text into password field
  testElement:focus()
  testElement:insertText("S")
  testElement:insertText("e")
  testElement:insertText("c")
  testElement:insertText("r")
  testElement:insertText("e")
  testElement:insertText("t")

  -- Verify actual text buffer contains the real text
  lu.assertEquals(testElement._textBuffer, "Secret")
  lu.assertEquals(testElement:getText(), "Secret")
end

function TestPasswordMode:testPasswordTextIsNotModified()
  -- Set initial text
  testElement:setText("MyPassword123")

  -- The actual buffer should contain the real password
  lu.assertEquals(testElement._textBuffer, "MyPassword123")
  lu.assertEquals(testElement:getText(), "MyPassword123")
end

-- ====================
-- Cursor Position Tests
-- ====================

function TestPasswordMode:testCursorPositionWithPasswordMode()
  testElement:setText("test")
  testElement:focus()

  -- Set cursor to end
  testElement:setCursorPosition(4)
  lu.assertEquals(testElement._cursorPosition, 4)

  -- Move cursor to middle
  testElement:setCursorPosition(2)
  lu.assertEquals(testElement._cursorPosition, 2)

  -- Move cursor to start
  testElement:setCursorPosition(0)
  lu.assertEquals(testElement._cursorPosition, 0)
end

function TestPasswordMode:testCursorMovementInPasswordField()
  testElement:setText("password")
  testElement:focus()
  testElement:setCursorPosition(0)

  -- Move right
  testElement:moveCursorBy(1)
  lu.assertEquals(testElement._cursorPosition, 1)

  -- Move right again
  testElement:moveCursorBy(1)
  lu.assertEquals(testElement._cursorPosition, 2)

  -- Move left
  testElement:moveCursorBy(-1)
  lu.assertEquals(testElement._cursorPosition, 1)
end

-- ====================
-- Text Editing Tests
-- ====================

function TestPasswordMode:testInsertTextInPasswordMode()
  testElement:focus()
  testElement:setCursorPosition(0)

  testElement:insertText("a")
  lu.assertEquals(testElement._textBuffer, "a")

  testElement:insertText("b")
  lu.assertEquals(testElement._textBuffer, "ab")

  testElement:insertText("c")
  lu.assertEquals(testElement._textBuffer, "abc")
end

function TestPasswordMode:testBackspaceInPasswordMode()
  testElement:setText("password")
  testElement:focus()
  testElement:setCursorPosition(8) -- End of text

  -- Delete last character
  testElement:keypressed("backspace", nil, false)
  lu.assertEquals(testElement._textBuffer, "passwor")

  -- Delete another character
  testElement:keypressed("backspace", nil, false)
  lu.assertEquals(testElement._textBuffer, "passwo")
end

function TestPasswordMode:testDeleteInPasswordMode()
  testElement:setText("password")
  testElement:focus()
  testElement:setCursorPosition(0) -- Start of text

  -- Delete first character
  testElement:keypressed("delete", nil, false)
  lu.assertEquals(testElement._textBuffer, "assword")

  -- Delete another character
  testElement:keypressed("delete", nil, false)
  lu.assertEquals(testElement._textBuffer, "ssword")
end

function TestPasswordMode:testInsertTextAtPosition()
  testElement:setText("pass")
  testElement:focus()
  testElement:setCursorPosition(2) -- Between 'pa' and 'ss'

  testElement:insertText("x")
  lu.assertEquals(testElement._textBuffer, "paxss")
  lu.assertEquals(testElement._cursorPosition, 3)
end

-- ====================
-- Selection Tests
-- ====================

function TestPasswordMode:testTextSelectionInPasswordMode()
  testElement:setText("password")
  testElement:focus()

  -- Select from position 2 to 5
  testElement:setSelection(2, 5)

  local selStart, selEnd = testElement:getSelection()
  lu.assertEquals(selStart, 2)
  lu.assertEquals(selEnd, 5)
  lu.assertTrue(testElement:hasSelection())
end

function TestPasswordMode:testDeleteSelectionInPasswordMode()
  testElement:setText("password")
  testElement:focus()

  -- Select "sswo" (positions 2-6)
  testElement:setSelection(2, 6)

  -- Delete selection
  testElement:deleteSelection()
  lu.assertEquals(testElement._textBuffer, "pard")
  lu.assertFalse(testElement:hasSelection())
end

function TestPasswordMode:testReplaceSelectionInPasswordMode()
  testElement:setText("password")
  testElement:focus()

  -- Select "sswo" (positions 2-6)
  testElement:setSelection(2, 6)

  -- Type new text (should replace selection)
  testElement:textinput("X")
  lu.assertEquals(testElement._textBuffer, "paXrd")
end

function TestPasswordMode:testSelectAllInPasswordMode()
  testElement:setText("secret")
  testElement:focus()

  testElement:selectAll()

  local selStart, selEnd = testElement:getSelection()
  lu.assertEquals(selStart, 0)
  lu.assertEquals(selEnd, 6)
  lu.assertTrue(testElement:hasSelection())
end

-- ====================
-- Integration Tests
-- ====================

function TestPasswordMode:testPasswordModeWithMaxLength()
  testElement.maxLength = 5
  testElement:focus()

  testElement:insertText("1")
  testElement:insertText("2")
  testElement:insertText("3")
  testElement:insertText("4")
  testElement:insertText("5")
  testElement:insertText("6") -- Should be rejected

  lu.assertEquals(testElement._textBuffer, "12345")
  lu.assertEquals(utf8.len(testElement._textBuffer), 5)
end

function TestPasswordMode:testPasswordModeWithPlaceholder()
  local passwordWithPlaceholder = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 40,
    editable = true,
    passwordMode = true,
    placeholder = "Enter password",
    text = "",
  })

  -- When empty and not focused, placeholder should be available
  lu.assertEquals(passwordWithPlaceholder.placeholder, "Enter password")
  lu.assertEquals(passwordWithPlaceholder._textBuffer, "")

  -- When text is added, actual text should be stored
  passwordWithPlaceholder:focus()
  passwordWithPlaceholder:insertText("secret")
  lu.assertEquals(passwordWithPlaceholder._textBuffer, "secret")
end

function TestPasswordMode:testPasswordModeClearText()
  testElement:setText("password123")
  lu.assertEquals(testElement._textBuffer, "password123")

  -- Clear text
  testElement:setText("")
  lu.assertEquals(testElement._textBuffer, "")
  lu.assertEquals(testElement:getText(), "")
end

function TestPasswordMode:testPasswordModeToggle()
  -- Start with password mode off
  local toggleElement = FlexLove.Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 40,
    editable = true,
    passwordMode = false,
    text = "visible",
  })

  lu.assertEquals(toggleElement._textBuffer, "visible")
  lu.assertFalse(toggleElement.passwordMode)

  -- Enable password mode
  toggleElement.passwordMode = true
  lu.assertTrue(toggleElement.passwordMode)

  -- Text buffer should remain unchanged
  lu.assertEquals(toggleElement._textBuffer, "visible")

  -- Disable password mode again
  toggleElement.passwordMode = false
  lu.assertFalse(toggleElement.passwordMode)
  lu.assertEquals(toggleElement._textBuffer, "visible")
end

-- ====================
-- UTF-8 Support Tests
-- ====================

function TestPasswordMode:testPasswordModeWithUTF8Characters()
  testElement:focus()

  -- Insert UTF-8 characters
  testElement:insertText("h")
  testElement:insertText("é")
  testElement:insertText("l")
  testElement:insertText("l")
  testElement:insertText("ö")

  -- Text buffer should contain actual UTF-8 text
  lu.assertEquals(testElement._textBuffer, "héllö")
  lu.assertEquals(utf8.len(testElement._textBuffer), 5)
end

function TestPasswordMode:testPasswordModeCursorWithUTF8()
  testElement:setText("café")
  testElement:focus()

  -- Move cursor through UTF-8 text
  testElement:setCursorPosition(0)
  lu.assertEquals(testElement._cursorPosition, 0)

  testElement:moveCursorBy(1)
  lu.assertEquals(testElement._cursorPosition, 1)

  testElement:moveCursorBy(1)
  lu.assertEquals(testElement._cursorPosition, 2)

  testElement:setCursorPosition(4)
  lu.assertEquals(testElement._cursorPosition, 4)
end

-- ====================
-- Edge Cases
-- ====================

function TestPasswordMode:testPasswordModeWithEmptyString()
  testElement:setText("")
  lu.assertEquals(testElement._textBuffer, "")
  lu.assertEquals(testElement:getText(), "")
end

function TestPasswordMode:testPasswordModeWithSingleCharacter()
  testElement:setText("x")
  lu.assertEquals(testElement._textBuffer, "x")
  lu.assertEquals(utf8.len(testElement._textBuffer), 1)
end

function TestPasswordMode:testPasswordModeWithLongPassword()
  local longPassword = string.rep("a", 100)
  testElement:setText(longPassword)

  lu.assertEquals(testElement._textBuffer, longPassword)
  lu.assertEquals(utf8.len(testElement._textBuffer), 100)
end

function TestPasswordMode:testPasswordModeSetTextUpdatesBuffer()
  testElement:setText("initial")
  lu.assertEquals(testElement._textBuffer, "initial")

  testElement:setText("updated")
  lu.assertEquals(testElement._textBuffer, "updated")

  testElement:setText("")
  lu.assertEquals(testElement._textBuffer, "")
end

lu.LuaUnit.run()
