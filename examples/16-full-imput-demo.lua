--[[
InputFieldsDemo.lua
Simple input field demo - multiple fields to test all features
Uses retained mode - elements are created once and reused
--]]

local FlexLove = require("FlexLove")
local Element = FlexLove.Element
local Color = FlexLove.Color

local InputFieldsDemo = {}

-- Elements (created once)
local elements = {}
local initialized = false

-- Initialize elements once
local function initialize()
  if initialized then
    return
  end
  initialized = true

  -- Title
  elements.title = Element.new({
    x = 50,
    y = 50,
    width = 700,
    height = 40,
    text = "FlexLove Input Field Demo",
    textSize = 28,
    textColor = Color.new(1, 1, 1, 1),
    z = 1000,
  })

  -- Input field 1 - Empty with placeholder
  elements.inputField1 = Element.new({
    x = 50,
    y = 120,
    width = 600,
    height = 50,
    editable = true,
    text = "",
    textSize = 18,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.3, 0.9),
    cornerRadius = 8,
    padding = { horizontal = 15, vertical = 12 },
    placeholder = "Type here... (empty field with placeholder)",
    selectOnFocus = false,
    z = 1000,
  })

  elements.inputField1.onTextChange = function(element, newText)
    print("Field 1 changed:", newText)
  end

  -- Input field 2 - Pre-filled with selectOnFocus
  elements.inputField2 = Element.new({
    x = 50,
    y = 200,
    width = 600,
    height = 50,
    editable = true,
    text = "Pre-filled text",
    textSize = 18,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.3, 0.2, 0.9),
    cornerRadius = 8,
    padding = { horizontal = 15, vertical = 12 },
    placeholder = "This shouldn't show",
    selectOnFocus = true,
    z = 1000,
  })

  elements.inputField2.onTextChange = function(element, newText)
    print("Field 2 changed:", newText)
  end

  -- Input field 3 - With max length
  elements.inputField3 = Element.new({
    x = 50,
    y = 280,
    width = 600,
    height = 50,
    editable = true,
    text = "",
    textSize = 18,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.3, 0.2, 0.2, 0.9),
    cornerRadius = 8,
    padding = { horizontal = 15, vertical = 12 },
    placeholder = "Max 20 characters",
    maxLength = 20,
    selectOnFocus = false,
    z = 1000,
  })

  elements.inputField3.onTextChange = function(element, newText)
    print("Field 3 changed:", newText)
  end

  -- Instructions
  elements.instructions = Element.new({
    x = 50,
    y = 360,
    width = 700,
    height = 200,
    text = "Instructions:\n• Click on a field to focus it\n• Type to enter text\n• Field 1: Empty with placeholder\n• Field 2: Pre-filled, selects all on focus\n• Field 3: Max 20 characters\n• Press ESC to unfocus\n• Use arrow keys to move cursor",
    textSize = 14,
    textColor = Color.new(0.8, 0.8, 0.8, 1),
    z = 1000,
  })
end

-- Render function (just initializes if needed)
function InputFieldsDemo.render()
  initialize()
end

return InputFieldsDemo
