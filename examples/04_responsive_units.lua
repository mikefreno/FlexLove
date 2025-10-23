--[[
  FlexLove Example 04: Responsive Units
  
  This example demonstrates responsive unit systems in FlexLove:
  - Viewport units (vw, vh)
  - Percentage units (%)
  - Pixel units (px)
  - How elements resize with the window
  
  Run with: love /path/to/libs/examples/04_responsive_units.lua
  Try resizing the window to see responsive behavior!
]]

local Lv = love

local FlexLove = require("../FlexLove")
local Gui = FlexLove.Gui
local Color = FlexLove.Color
local enums = FlexLove.enums

function Lv.load()
  Gui.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Title
  Gui.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 04: Responsive Units - Try Resizing!",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: Viewport Width Units (vw)
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "10vh",
    width = "96vw",
    height = "3vh",
    text = "Viewport Width (vw) - Scales with window width",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local vwContainer = Gui.new({
    x = "2vw",
    y = "14vh",
    width = "96vw",
    height = "12vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.CENTER,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })
  
  -- Elements with vw widths
  local vwWidths = { "10vw", "15vw", "20vw", "25vw" }
  local colors = {
    Color.new(0.8, 0.3, 0.3, 1),
    Color.new(0.3, 0.8, 0.3, 1),
    Color.new(0.3, 0.3, 0.8, 1),
    Color.new(0.8, 0.8, 0.3, 1),
  }
  
  for i, width in ipairs(vwWidths) do
    Gui.new({
      parent = vwContainer,
      width = width,
      height = "8vh",
      backgroundColor = colors[i],
      text = width,
      textSize = "1.8vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end
  
  -- ========================================
  -- Section 2: Viewport Height Units (vh)
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "28vh",
    width = "96vw",
    height = "3vh",
    text = "Viewport Height (vh) - Scales with window height",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local vhContainer = Gui.new({
    x = "2vw",
    y = "32vh",
    width = "96vw",
    height = "30vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.FLEX_END,
    backgroundColor = Color.new(0.1, 0.15, 0.1, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.4, 0.3, 1),
  })
  
  -- Elements with vh heights
  local vhHeights = { "8vh", "12vh", "16vh", "20vh", "24vh" }
  
  for i, height in ipairs(vhHeights) do
    local hue = (i - 1) / 4
    Gui.new({
      parent = vhContainer,
      width = "16vw",
      height = height,
      backgroundColor = Color.new(0.3 + hue * 0.5, 0.5, 0.7 - hue * 0.4, 1),
      text = height,
      textSize = "1.8vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end
  
  -- ========================================
  -- Section 3: Percentage Units (%)
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "64vh",
    width = "46vw",
    height = "3vh",
    text = "Percentage (%) - Relative to parent",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local percentContainer = Gui.new({
    x = "2vw",
    y = "68vh",
    width = "46vw",
    height = "28vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.STRETCH,
    backgroundColor = Color.new(0.15, 0.1, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.4, 0.3, 0.4, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  -- Child elements with percentage widths
  local percentWidths = { "25%", "50%", "75%", "100%" }
  
  for i, width in ipairs(percentWidths) do
    local progress = (i - 1) / 3
    Gui.new({
      parent = percentContainer,
      width = width,
      height = "5vh",
      backgroundColor = Color.new(0.6, 0.4 + progress * 0.4, 0.7 - progress * 0.4, 1),
      text = width .. " of parent",
      textSize = "1.8vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end
  
  -- ========================================
  -- Section 4: Pixel Units (px) - Fixed Size
  -- ========================================
  
  Gui.new({
    x = "50vw",
    y = "64vh",
    width = "48vw",
    height = "3vh",
    text = "Pixels (px) - Fixed size (doesn't resize)",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local pxContainer = Gui.new({
    x = "50vw",
    y = "68vh",
    width = "48vw",
    height = "28vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
    gap = 10,
    backgroundColor = Color.new(0.1, 0.12, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.35, 0.4, 1),
  })
  
  -- Fixed pixel size elements
  local pxSizes = {
    { w = 80, h = 80 },
    { w = 100, h = 100 },
    { w = 120, h = 120 },
  }
  
  for i, size in ipairs(pxSizes) do
    Gui.new({
      parent = pxContainer,
      width = size.w,
      height = size.h,
      backgroundColor = Color.new(0.8 - i * 0.2, 0.3 + i * 0.2, 0.5, 1),
      text = size.w .. "px",
      textSize = "1.8vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 5,
    })
  end
end

function Lv.update(dt)
  Gui.update(dt)
end

function Lv.draw()
  Lv.graphics.clear(0.05, 0.05, 0.08, 1)
  Gui.draw()
end

function Lv.resize(w, h)
  Gui.resize(w, h)
end
