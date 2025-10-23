--[[
  FlexLove Example 08: Absolute vs Relative Positioning
  
  This example demonstrates positioning modes in FlexLove:
  - Absolute positioning (fixed coordinates)
  - Relative positioning (relative to siblings)
  - Comparison between the two modes
  - Practical use cases
  
  Run with: love /path/to/libs/examples/08_absolute_relative_positioning.lua
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
    text = "FlexLove Example 08: Absolute vs Relative Positioning",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: Absolute Positioning
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "10vh",
    width = "46vw",
    height = "3vh",
    text = "Absolute Positioning - Fixed coordinates",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local absoluteContainer = Gui.new({
    x = "2vw",
    y = "14vh",
    width = "46vw",
    height = "40vh",
    positioning = enums.Positioning.ABSOLUTE,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })
  
  -- Absolute positioned children
  Gui.new({
    parent = absoluteContainer,
    x = 20,
    y = 20,
    width = 150,
    height = 80,
    positioning = enums.Positioning.ABSOLUTE,
    backgroundColor = Color.new(0.8, 0.3, 0.3, 1),
    text = "x:20, y:20",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  Gui.new({
    parent = absoluteContainer,
    x = 200,
    y = 50,
    width = 150,
    height = 80,
    positioning = enums.Positioning.ABSOLUTE,
    backgroundColor = Color.new(0.3, 0.8, 0.3, 1),
    text = "x:200, y:50",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  Gui.new({
    parent = absoluteContainer,
    x = 100,
    y = 150,
    width = 150,
    height = 80,
    positioning = enums.Positioning.ABSOLUTE,
    backgroundColor = Color.new(0.3, 0.3, 0.8, 1),
    text = "x:100, y:150",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  Gui.new({
    parent = absoluteContainer,
    x = 280,
    y = 180,
    width = 150,
    height = 80,
    positioning = enums.Positioning.ABSOLUTE,
    backgroundColor = Color.new(0.8, 0.8, 0.3, 1),
    text = "x:280, y:180",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  -- ========================================
  -- Section 2: Relative Positioning
  -- ========================================
  
  Gui.new({
    x = "50vw",
    y = "10vh",
    width = "48vw",
    height = "3vh",
    text = "Relative Positioning - Flows with siblings",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local relativeContainer = Gui.new({
    x = "50vw",
    y = "14vh",
    width = "48vw",
    height = "40vh",
    positioning = enums.Positioning.RELATIVE,
    backgroundColor = Color.new(0.1, 0.15, 0.1, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.4, 0.3, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  -- Relative positioned children (flow naturally)
  local relativeColors = {
    Color.new(0.8, 0.3, 0.3, 1),
    Color.new(0.3, 0.8, 0.3, 1),
    Color.new(0.3, 0.3, 0.8, 1),
    Color.new(0.8, 0.8, 0.3, 1),
  }
  
  for i = 1, 4 do
    Gui.new({
      parent = relativeContainer,
      width = "45%",
      height = "8vh",
      positioning = enums.Positioning.RELATIVE,
      backgroundColor = relativeColors[i],
      text = "Element " .. i .. " (relative)",
      textSize = "1.8vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 5,
      margin = { top = 5, right = 5, bottom = 5, left = 5 },
    })
  end
  
  -- ========================================
  -- Section 3: Comparison with Overlapping
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "56vh",
    width = "96vw",
    height = "3vh",
    text = "Absolute Positioning Allows Overlapping",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local overlapContainer = Gui.new({
    x = "2vw",
    y = "60vh",
    width = "96vw",
    height = "36vh",
    positioning = enums.Positioning.ABSOLUTE,
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.25, 0.25, 0.35, 1),
  })
  
  -- Create overlapping elements
  local overlapColors = {
    Color.new(0.9, 0.3, 0.3, 0.7),
    Color.new(0.3, 0.9, 0.3, 0.7),
    Color.new(0.3, 0.3, 0.9, 0.7),
    Color.new(0.9, 0.9, 0.3, 0.7),
  }
  
  for i = 1, 4 do
    Gui.new({
      parent = overlapContainer,
      x = 50 + (i - 1) * 60,
      y = 30 + (i - 1) * 40,
      width = 300,
      height = 150,
      positioning = enums.Positioning.ABSOLUTE,
      backgroundColor = overlapColors[i],
      text = "Layer " .. i,
      textSize = "2.5vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 10,
      z = i, -- Z-index for layering
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
