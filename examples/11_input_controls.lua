--[[
  FlexLove Example 11: Input Controls
  
  This example demonstrates input controls (if available):
  - Text input fields
  - Keyboard input handling
  - Focus management
  
  Run with: love /path/to/libs/examples/11_input_controls.lua
]]

local Lv = love

local FlexLove = require("../FlexLove")
local Color = FlexLove.Color
local enums = FlexLove.enums

function Lv.load()
  FlexLove.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Title
  FlexLove.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 11: Input Controls",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Note: Input controls may require additional setup in FlexLove
  FlexLove.new({
    x = "2vw",
    y = "10vh",
    width = "96vw",
    height = "4vh",
    text = "Note: This example demonstrates basic input handling patterns",
    textSize = "2vh",
    textColor = Color.new(0.8, 0.8, 0.8, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Interactive buttons
  local counter = 0
  local counterDisplay = FlexLove.new({
    x = "35vw",
    y = "20vh",
    width = "30vw",
    height = "10vh",
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    text = "Counter: 0",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
  })
  
  -- Increment button
  FlexLove.new({
    x = "20vw",
    y = "35vh",
    width = "20vw",
    height = "8vh",
    backgroundColor = Color.new(0.3, 0.6, 0.3, 1),
    text = "Increment (+)",
    textSize = "2.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 8,
    onEvent = function()
      counter = counter + 1
      counterDisplay.text = "Counter: " .. counter
    end
  })
  
  -- Decrement button
  FlexLove.new({
    x = "60vw",
    y = "35vh",
    width = "20vw",
    height = "8vh",
    backgroundColor = Color.new(0.6, 0.3, 0.3, 1),
    text = "Decrement (-)",
    textSize = "2.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 8,
    onEvent = function()
      counter = counter - 1
      counterDisplay.text = "Counter: " .. counter
    end
  })
  
  -- Reset button
  FlexLove.new({
    x = "40vw",
    y = "46vh",
    width = "20vw",
    height = "8vh",
    backgroundColor = Color.new(0.4, 0.4, 0.6, 1),
    text = "Reset",
    textSize = "2.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 8,
    onEvent = function()
      counter = 0
      counterDisplay.text = "Counter: " .. counter
    end
  })
  
  -- Keyboard input info
  FlexLove.new({
    x = "2vw",
    y = "60vh",
    width = "96vw",
    height = "30vh",
    backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
    text = "Keyboard Input:\n\nFlexLove supports keyboard input through Element properties:\n\n" ..
           "- Use 'inputType' property for text input fields\n" ..
           "- Handle onTextInput, onTextChange, onEnter callbacks\n" ..
           "- Manage focus with onFocus and onBlur events\n\n" ..
           "See FlexLove documentation for full input API",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.4, 0.4, 0.5, 1),
  })
end

function Lv.update(dt)
  FlexLove.update(dt)
end

function Lv.draw()
  Lv.graphics.clear(0.05, 0.05, 0.08, 1)
  FlexLove.draw()
end

function Lv.resize(w, h)
  FlexLove.resize(w, h)
end
