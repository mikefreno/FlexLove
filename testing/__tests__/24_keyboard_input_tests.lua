local lu = require("testing.luaunit")
local FlexLove = require("FlexLove")
local Gui = FlexLove.Gui
local Element = FlexLove.Element

TestKeyboardInput = {}

function TestKeyboardInput:setUp()
  Gui.init({ baseScale = { width = 1920, height = 1080 } })
end

function TestKeyboardInput:tearDown()
  Gui.destroy()
end

-- ====================
-- Focus Management Tests
-- ====================

function TestKeyboardInput:testFocusEditable()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  lu.assertFalse(input:isFocused())

  input:focus()

  lu.assertTrue(input:isFocused())
  lu.assertEquals(Gui._focusedElement, input)
end

function TestKeyboardInput:testBlurEditable()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  lu.assertTrue(input:isFocused())

  input:blur()

  lu.assertFalse(input:isFocused())
  lu.assertNil(Gui._focusedElement)
end

function TestKeyboardInput:testFocusSwitching()
  local input1 = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Input 1",
  })

  local input2 = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Input 2",
  })

  input1:focus()
  lu.assertTrue(input1:isFocused())
  lu.assertFalse(input2:isFocused())

  input2:focus()
  lu.assertFalse(input1:isFocused())
  lu.assertTrue(input2:isFocused())
  lu.assertEquals(Gui._focusedElement, input2)
end

function TestKeyboardInput:testSelectOnFocus()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello World",
    selectOnFocus = true,
  })

  lu.assertFalse(input:hasSelection())

  input:focus()

  lu.assertTrue(input:hasSelection())
  local startPos, endPos = input:getSelection()
  lu.assertEquals(startPos, 0)
  lu.assertEquals(endPos, 11) -- Length of "Hello World"
end

-- ====================
-- Text Input Tests
-- ====================

function TestKeyboardInput:testTextInput()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "",
  })

  input:focus()
  input:textinput("H")
  input:textinput("i")

  lu.assertEquals(input:getText(), "Hi")
  lu.assertEquals(input._cursorPosition, 2)
end

function TestKeyboardInput:testTextInputAtPosition()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(2) -- After "He"
  input:textinput("X")

  lu.assertEquals(input:getText(), "HeXllo")
  lu.assertEquals(input._cursorPosition, 3)
end

function TestKeyboardInput:testTextInputWithSelection()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello World",
  })

  input:focus()
  input:setSelection(0, 5) -- Select "Hello"
  input:textinput("Hi")

  lu.assertEquals(input:getText(), "Hi World")
  lu.assertEquals(input._cursorPosition, 2)
  lu.assertFalse(input:hasSelection())
end

function TestKeyboardInput:testMaxLengthConstraint()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "",
    maxLength = 5,
  })

  input:focus()
  input:textinput("Hello")
  lu.assertEquals(input:getText(), "Hello")

  input:textinput("X") -- Should not be added
  lu.assertEquals(input:getText(), "Hello")
end

-- ====================
-- Backspace/Delete Tests
-- ====================

function TestKeyboardInput:testBackspace()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(5) -- At end
  input:keypressed("backspace", "backspace", false)

  lu.assertEquals(input:getText(), "Hell")
  lu.assertEquals(input._cursorPosition, 4)
end

function TestKeyboardInput:testBackspaceAtStart()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(0) -- At start
  input:keypressed("backspace", "backspace", false)

  lu.assertEquals(input:getText(), "Hello") -- No change
  lu.assertEquals(input._cursorPosition, 0)
end

function TestKeyboardInput:testDelete()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(0) -- At start
  input:keypressed("delete", "delete", false)

  lu.assertEquals(input:getText(), "ello")
  lu.assertEquals(input._cursorPosition, 0)
end

function TestKeyboardInput:testDeleteAtEnd()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(5) -- At end
  input:keypressed("delete", "delete", false)

  lu.assertEquals(input:getText(), "Hello") -- No change
  lu.assertEquals(input._cursorPosition, 5)
end

function TestKeyboardInput:testBackspaceWithSelection()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello World",
  })

  input:focus()
  input:setSelection(0, 5) -- Select "Hello"
  input:keypressed("backspace", "backspace", false)

  lu.assertEquals(input:getText(), " World")
  lu.assertEquals(input._cursorPosition, 0)
  lu.assertFalse(input:hasSelection())
end

-- ====================
-- Cursor Movement Tests
-- ====================

function TestKeyboardInput:testArrowLeft()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(5)
  input:keypressed("left", "left", false)

  lu.assertEquals(input._cursorPosition, 4)
end

function TestKeyboardInput:testArrowRight()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(0)
  input:keypressed("right", "right", false)

  lu.assertEquals(input._cursorPosition, 1)
end

function TestKeyboardInput:testHomeKey()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(5)
  input:keypressed("home", "home", false)

  lu.assertEquals(input._cursorPosition, 0)
end

function TestKeyboardInput:testEndKey()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(0)
  input:keypressed("end", "end", false)

  lu.assertEquals(input._cursorPosition, 5)
end

function TestKeyboardInput:testEscapeClearsSelection()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:selectAll()
  lu.assertTrue(input:hasSelection())

  input:keypressed("escape", "escape", false)

  lu.assertFalse(input:hasSelection())
  lu.assertTrue(input:isFocused()) -- Still focused
end

function TestKeyboardInput:testEscapeBlurs()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  lu.assertTrue(input:isFocused())

  input:keypressed("escape", "escape", false)

  lu.assertFalse(input:isFocused())
end

-- ====================
-- Callback Tests
-- ====================

function TestKeyboardInput:testOnTextChangeCallback()
  local changeCount = 0
  local oldTextValue = nil
  local newTextValue = nil

  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
    onTextChange = function(element, newText, oldText)
      changeCount = changeCount + 1
      newTextValue = newText
      oldTextValue = oldText
    end,
  })

  input:focus()
  input:textinput("X")

  lu.assertEquals(changeCount, 1)
  lu.assertEquals(oldTextValue, "Hello")
  lu.assertEquals(newTextValue, "HelloX")
end

function TestKeyboardInput:testOnTextInputCallback()
  local inputCount = 0
  local lastChar = nil

  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "",
    onTextInput = function(element, text)
      inputCount = inputCount + 1
      lastChar = text
    end,
  })

  input:focus()
  input:textinput("A")
  input:textinput("B")

  lu.assertEquals(inputCount, 2)
  lu.assertEquals(lastChar, "B")
end

function TestKeyboardInput:testOnEnterCallback()
  local enterCalled = false

  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    multiline = false,
    text = "Hello",
    onEnter = function(element)
      enterCalled = true
    end,
  })

  input:focus()
  input:keypressed("return", "return", false)

  lu.assertTrue(enterCalled)
end

function TestKeyboardInput:testOnFocusCallback()
  local focusCalled = false

  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
    onFocus = function(element)
      focusCalled = true
    end,
  })

  input:focus()

  lu.assertTrue(focusCalled)
end

function TestKeyboardInput:testOnBlurCallback()
  local blurCalled = false

  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
    onBlur = function(element)
      blurCalled = true
    end,
  })

  input:focus()
  input:blur()

  lu.assertTrue(blurCalled)
end

-- ====================
-- GUI-level Input Forwarding Tests
-- ====================

function TestKeyboardInput:testGuiTextinputForwarding()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "",
  })

  input:focus()
  Gui.textinput("A")

  lu.assertEquals(input:getText(), "A")
end

function TestKeyboardInput:testGuiKeypressedForwarding()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  input:focus()
  input:setCursorPosition(5)
  Gui.keypressed("backspace", "backspace", false)

  lu.assertEquals(input:getText(), "Hell")
end

function TestKeyboardInput:testGuiInputWithoutFocus()
  local input = Element.new({
    width = 200,
    height = 40,
    editable = true,
    text = "Hello",
  })

  -- No focus
  Gui.textinput("X")

  lu.assertEquals(input:getText(), "Hello") -- No change
end

lu.LuaUnit.run()
