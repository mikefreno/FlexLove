--[[
  FlexLove Example 09: Styling and Visual Effects
  
  This example demonstrates styling and visual effects:
  - Corner radius (uniform and individual corners)
  - Borders (different sides)
  - Opacity levels
  - Background colors
  - Blur effects (contentBlur and backdropBlur)
  
  Run with: love /path/to/libs/examples/09_styling_visual_effects.lua
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
    height = "5vh",
    text = "FlexLove Example 09: Styling and Visual Effects",
    textSize = "3.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: Corner Radius
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "9vh",
    width = "46vw",
    height = "3vh",
    text = "Corner Radius",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Uniform corner radius
  FlexLove.new({
    x = "2vw",
    y = "13vh",
    width = "14vw",
    height = "12vh",
    backgroundColor = Color.new(0.6, 0.3, 0.7, 1),
    cornerRadius = 5,
    text = "radius: 5",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  FlexLove.new({
    x = "17vw",
    y = "13vh",
    width = "14vw",
    height = "12vh",
    backgroundColor = Color.new(0.3, 0.6, 0.7, 1),
    cornerRadius = 15,
    text = "radius: 15",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Individual corner radius
  FlexLove.new({
    x = "32vw",
    y = "13vh",
    width = "16vw",
    height = "12vh",
    backgroundColor = Color.new(0.7, 0.6, 0.3, 1),
    cornerRadius = {
      topLeft = 0,
      topRight = 20,
      bottomLeft = 20,
      bottomRight = 0,
    },
    text = "Individual\ncorners",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 2: Borders
  -- ========================================
  
  FlexLove.new({
    x = "50vw",
    y = "9vh",
    width = "48vw",
    height = "3vh",
    text = "Borders",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- All borders
  FlexLove.new({
    x = "50vw",
    y = "13vh",
    width = "14vw",
    height = "12vh",
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.8, 0.4, 0.4, 1),
    text = "All sides",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Top and bottom borders
  FlexLove.new({
    x = "65vw",
    y = "13vh",
    width = "14vw",
    height = "12vh",
    backgroundColor = Color.new(0.2, 0.3, 0.2, 1),
    border = { top = true, bottom = true },
    borderColor = Color.new(0.4, 0.8, 0.4, 1),
    text = "Top & Bottom",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Left border only
  FlexLove.new({
    x = "80vw",
    y = "13vh",
    width = "16vw",
    height = "12vh",
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    border = { left = true },
    borderColor = Color.new(0.4, 0.4, 0.8, 1),
    text = "Left only",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 3: Opacity
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "27vh",
    width = "96vw",
    height = "3vh",
    text = "Opacity Levels",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local opacityLevels = { 1.0, 0.75, 0.5, 0.25 }
  
  for i, opacity in ipairs(opacityLevels) do
    FlexLove.new({
      x = (2 + (i - 1) * 24) .. "vw",
      y = "31vh",
      width = "22vw",
      height = "12vh",
      backgroundColor = Color.new(0.8, 0.3, 0.5, 1),
      opacity = opacity,
      text = "Opacity: " .. opacity,
      textSize = "2vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 8,
    })
  end
  
  -- ========================================
  -- Section 4: Background Colors
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "45vh",
    width = "96vw",
    height = "3vh",
    text = "Background Colors",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Gradient-like colors
  for i = 1, 8 do
    local hue = (i - 1) / 7
    FlexLove.new({
      x = (2 + (i - 1) * 12) .. "vw",
      y = "49vh",
      width = "11vw",
      height = "18vh",
      backgroundColor = Color.new(
        0.3 + hue * 0.5,
        0.5 + math.sin(hue * 3.14) * 0.3,
        0.8 - hue * 0.5,
        1
      ),
      text = tostring(i),
      textSize = "3vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 5,
    })
  end
  
  -- ========================================
  -- Section 5: Blur Effects (if supported)
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "69vh",
    width = "96vw",
    height = "3vh",
    text = "Blur Effects (contentBlur & backdropBlur)",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Content blur example
  FlexLove.new({
    x = "2vw",
    y = "73vh",
    width = "46vw",
    height = "22vh",
    backgroundColor = Color.new(0.3, 0.4, 0.6, 0.8),
    contentBlur = { intensity = 5, quality = 3 },
    text = "Content Blur\n(blurs this element)",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
  })
  
  -- Backdrop blur example
  FlexLove.new({
    x = "50vw",
    y = "73vh",
    width = "46vw",
    height = "22vh",
    backgroundColor = Color.new(0.6, 0.4, 0.3, 0.6),
    backdropBlur = { intensity = 10, quality = 5 },
    text = "Backdrop Blur\n(blurs background)",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
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
