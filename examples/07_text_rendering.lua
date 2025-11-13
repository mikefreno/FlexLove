--[[
  FlexLove Example 07: Text Rendering
  
  This example demonstrates text rendering features in FlexLove:
  - Text alignment (start, center, end, justify)
  - Text size presets (xxs, xs, sm, md, lg, xl, xxl, 3xl, 4xl)
  - Font rendering with custom fonts
  - Text wrapping and positioning
  
  Run with: love /path/to/libs/examples/07_text_rendering.lua
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
    text = "FlexLove Example 07: Text Rendering",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: Text Alignment
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "10vh",
    width = "96vw",
    height = "3vh",
    text = "Text Alignment Options",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local alignments = {
    { name = "START", value = enums.TextAlign.START },
    { name = "CENTER", value = enums.TextAlign.CENTER },
    { name = "END", value = enums.TextAlign.END },
  }
  
  local yOffset = 14
  
  for _, align in ipairs(alignments) do
    FlexLove.new({
      x = "2vw",
      y = yOffset .. "vh",
      width = "30vw",
      height = "8vh",
      backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
      text = "Align: " .. align.name,
      textSize = "2vh",
      textColor = Color.new(0.8, 0.9, 1, 1),
      textAlign = align.value,
      border = { top = true, right = true, bottom = true, left = true },
      borderColor = Color.new(0.3, 0.3, 0.4, 1),
      cornerRadius = 5,
    })
    yOffset = yOffset + 9
  end
  
  -- ========================================
  -- Section 2: Text Size Presets
  -- ========================================
  
  FlexLove.new({
    x = "34vw",
    y = "10vh",
    width = "64vw",
    height = "3vh",
    text = "Text Size Presets",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local textSizes = {
    { name = "XXS", value = "xxs" },
    { name = "XS", value = "xs" },
    { name = "SM", value = "sm" },
    { name = "MD", value = "md" },
    { name = "LG", value = "lg" },
    { name = "XL", value = "xl" },
    { name = "XXL", value = "xxl" },
    { name = "3XL", value = "3xl" },
    { name = "4XL", value = "4xl" },
  }
  
  local sizeContainer = FlexLove.new({
    x = "34vw",
    y = "14vh",
    width = "64vw",
    height = "76vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
    gap = 5,
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.25, 0.25, 0.35, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  for i, size in ipairs(textSizes) do
    local hue = (i - 1) / 8
    FlexLove.new({
      parent = sizeContainer,
      height = "7vh",
      backgroundColor = Color.new(0.2 + hue * 0.3, 0.3 + hue * 0.2, 0.5 - hue * 0.2, 1),
      text = size.name .. " - The quick brown fox jumps over the lazy dog",
      textSize = size.value,
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.START,
      cornerRadius = 3,
    })
  end
  
  -- ========================================
  -- Section 3: Custom Font Sizes (vh units)
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "41vh",
    width = "30vw",
    height = "3vh",
    text = "Custom Text Sizes (vh units)",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local customSizes = { "1vh", "2vh", "3vh", "4vh", "5vh" }
  
  local customContainer = FlexLove.new({
    x = "2vw",
    y = "45vh",
    width = "30vw",
    height = "45vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.STRETCH,
    backgroundColor = Color.new(0.1, 0.12, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.35, 0.4, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  for i, size in ipairs(customSizes) do
    FlexLove.new({
      parent = customContainer,
      backgroundColor = Color.new(0.3, 0.4 + i * 0.08, 0.6 - i * 0.08, 1),
      text = size .. " text",
      textSize = size,
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 3,
      padding = { top = 5, right = 10, bottom = 5, left = 10 },
    })
  end
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
