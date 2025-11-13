--[[
  FlexLove Example 14: Drag Event - Slider Implementation

  This example demonstrates how to use the new drag event to create
  interactive sliders without any first-party slider component.

  Features demonstrated:
  - Using drag events for continuous mouse tracking
  - Converting mouse coordinates to element-relative positions
  - Updating UI elements based on drag position
  - Creating reusable slider components

  Run with: love /path/to/libs/examples/14_drag_slider.lua
]]

local Lv = love

local FlexLove = require("../FlexLove")
local Color = FlexLove.Color
local enums = FlexLove.enums

-- Slider state
local volume = 0.5 -- 0.0 to 1.0
local brightness = 0.75 -- 0.0 to 1.0
local temperature = 20 -- 0 to 40 (degrees)

-- UI elements
local volumeValueText
local brightnessValueText
local temperatureValueText
local volumeHandle
local brightnessHandle
local temperatureHandle

--- Helper function to create a slider
---@param x string|number
---@param y string|number
---@param width string|number
---@param label string
---@param min number
---@param max number
---@param initialValue number
---@param onValueChange function
---@return table -- Returns { bg, handle, valueText }
local function createSlider(x, y, width, label, min, max, initialValue, onValueChange)
  -- Container for the slider
  local container = FlexLove.new({
    x = x,
    y = y,
    width = width,
    height = "12vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 5,
  })

  -- Label
  FlexLove.new({
    parent = container,
    height = "3vh",
    text = label,
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })

  -- Slider track background
  local sliderBg = FlexLove.new({
    parent = container,
    height = "4vh",
    backgroundColor = Color.new(0.2, 0.2, 0.25, 1),
    cornerRadius = 5,
    positioning = enums.Positioning.RELATIVE,
  })

  -- Slider handle
  local normalized = (initialValue - min) / (max - min)
  local handle = FlexLove.new({
    parent = sliderBg,
    x = (normalized * 95) .. "%",
    y = "50%",
    width = "5%",
    height = "80%",
    backgroundColor = Color.new(0.4, 0.6, 0.9, 1),
    cornerRadius = 3,
    positioning = enums.Positioning.ABSOLUTE,
    -- Center the handle vertically
    top = "10%",
  })

  -- Value display
  local valueText = FlexLove.new({
    parent = container,
    height = "3vh",
    text = string.format("%.2f", initialValue),
    textSize = "2vh",
    textColor = Color.new(0.7, 0.8, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })

  -- Make the background track interactive
  sliderBg.onEvent = function(element, event)
    if event.type == "press" or event.type == "drag" then
      -- Get element bounds
      local bg_x = element.x
      local bg_width = element.width

      -- Calculate relative position (0 to 1)
      local mouse_x = event.x
      local relative_x = mouse_x - bg_x
      local new_normalized = math.max(0, math.min(1, relative_x / bg_width))

      -- Calculate actual value
      local new_value = min + (new_normalized * (max - min))

      -- Update handle position (use percentage for responsiveness)
      handle.x = (new_normalized * 95) .. "%"

      -- Update value text
      if max - min > 10 then
        -- For larger ranges (like temperature), show integers
        valueText.text = string.format("%d", new_value)
      else
        -- For smaller ranges (like 0-1), show decimals
        valueText.text = string.format("%.2f", new_value)
      end

      -- Call the value change callback
      if onValueChange then
        onValueChange(new_value)
      end

      -- Re-layout to apply position changes
      element:recalculateUnits(Lv.graphics.getWidth(), Lv.graphics.getHeight())
    end
  end

  return {
    container = container,
    bg = sliderBg,
    handle = handle,
    valueText = valueText,
  }
end

function Lv.load()
  FlexLove.init({
    baseScale = { width = 1920, height = 1080 },
  })

  -- Title
  FlexLove.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 14: Drag Event - Slider Implementation",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })

  -- Subtitle
  FlexLove.new({
    x = "2vw",
    y = "9vh",
    width = "96vw",
    height = "3vh",
    text = "Drag the sliders to change values - built using only the drag event primitive!",
    textSize = "2vh",
    textColor = Color.new(0.7, 0.7, 0.7, 1),
    textAlign = enums.TextAlign.CENTER,
  })

  -- Volume Slider (0.0 - 1.0)
  local volumeSlider = createSlider("10vw", "18vh", "80vw", "Volume (0.0 - 1.0)", 0.0, 1.0, volume, function(value)
    volume = value
  end)
  volumeValueText = volumeSlider.valueText
  volumeHandle = volumeSlider.handle

  -- Brightness Slider (0.0 - 1.0)
  local brightnessSlider = createSlider("10vw", "35vh", "80vw", "Brightness (0.0 - 1.0)", 0.0, 1.0, brightness, function(value)
    brightness = value
  end)
  brightnessValueText = brightnessSlider.valueText
  brightnessHandle = brightnessSlider.handle

  -- Temperature Slider (0 - 40°C)
  local temperatureSlider = createSlider("10vw", "52vh", "80vw", "Temperature (0 - 40°C)", 0, 40, temperature, function(value)
    temperature = value
  end)
  temperatureValueText = temperatureSlider.valueText
  temperatureHandle = temperatureSlider.handle

  -- Visual feedback section
  FlexLove.new({
    x = "10vw",
    y = "70vh",
    width = "80vw",
    height = "3vh",
    text = "Visual Feedback:",
    textSize = "2.5vh",
    textColor = Color.new(1, 1, 1, 1),
  })

  -- Volume visualization
  FlexLove.new({
    x = "10vw",
    y = "75vh",
    width = "25vw",
    height = "20vh",
    backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
    cornerRadius = 10,
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })

  -- Brightness visualization
  FlexLove.new({
    x = "37.5vw",
    y = "75vh",
    width = "25vw",
    height = "20vh",
    backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
    cornerRadius = 10,
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })

  -- Temperature visualization
  FlexLove.new({
    x = "65vw",
    y = "75vh",
    width = "25vw",
    height = "20vh",
    backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
    cornerRadius = 10,
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })
end

function Lv.update(dt)
  FlexLove.update(dt)
end

function Lv.draw()
  Lv.graphics.clear(0.05, 0.05, 0.08, 1)
  FlexLove.draw()

  -- Draw volume visualization (speaker icon with bars)
  local volumeX = Lv.graphics.getWidth() * 0.10 + 20
  local volumeY = Lv.graphics.getHeight() * 0.75 + 30
  Lv.graphics.setColor(0.4, 0.6, 0.9, 1)
  Lv.graphics.print("Volume:", volumeX, volumeY, 0, 2, 2)

  -- Volume bars
  local barCount = 10
  for i = 1, barCount do
    if i / barCount <= volume then
      Lv.graphics.setColor(0.4, 0.8, 0.4, 1)
    else
      Lv.graphics.setColor(0.2, 0.2, 0.25, 1)
    end
    local barX = volumeX + 20 + (i - 1) * 30
    local barHeight = 20 + i * 5
    Lv.graphics.rectangle("fill", barX, volumeY + 60 - barHeight, 20, barHeight, 3)
  end

  -- Draw brightness visualization (sun icon)
  local brightnessX = Lv.graphics.getWidth() * 0.375 + 20
  local brightnessY = Lv.graphics.getHeight() * 0.75 + 30
  Lv.graphics.setColor(0.4, 0.6, 0.9, 1)
  Lv.graphics.print("Brightness:", brightnessX, brightnessY, 0, 2, 2)

  -- Sun circle
  Lv.graphics.setColor(1, 0.9, 0.3, brightness)
  Lv.graphics.circle("fill", brightnessX + 150, brightnessY + 80, 30 * brightness + 10)

  -- Draw temperature visualization (thermometer)
  local tempX = Lv.graphics.getWidth() * 0.65 + 20
  local tempY = Lv.graphics.getHeight() * 0.75 + 30
  Lv.graphics.setColor(0.4, 0.6, 0.9, 1)
  Lv.graphics.print("Temperature:", tempX, tempY, 0, 2, 2)

  -- Thermometer
  local tempNormalized = temperature / 40
  local tempColor = {
    1 - tempNormalized * 0.5, -- Red increases with temp
    0.3,
    1 - tempNormalized, -- Blue decreases with temp
  }
  Lv.graphics.setColor(tempColor[1], tempColor[2], tempColor[3], 1)
  Lv.graphics.rectangle("fill", tempX + 100, tempY + 50, 40, 100 * tempNormalized, 5)
  Lv.graphics.setColor(0.3, 0.3, 0.4, 1)
  Lv.graphics.rectangle("line", tempX + 100, tempY + 50, 40, 100, 5)

  -- Temperature text
  Lv.graphics.setColor(1, 1, 1, 1)
  Lv.graphics.print(string.format("%.0f°C", temperature), tempX + 160, tempY + 90, 0, 2, 2)
end

function Lv.resize(w, h)
  FlexLove.resize(w, h)
end
