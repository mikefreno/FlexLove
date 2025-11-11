--[[
  FlexLove Example 12: Z-Index Layering
  
  This example demonstrates z-index for element layering:
  - Different z-index values
  - Overlapping elements
  - Layer ordering
  
  Run with: love /path/to/libs/examples/12_z_index_layering.lua
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
    text = "FlexLove Example 12: Z-Index Layering",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Description
  Gui.new({
    x = "2vw",
    y = "10vh",
    width = "96vw",
    height = "3vh",
    text = "Elements with higher z-index values appear on top",
    textSize = "2vh",
    textColor = Color.new(0.8, 0.8, 0.8, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Section 1: Overlapping boxes with different z-index
  Gui.new({
    x = "2vw",
    y = "15vh",
    width = "46vw",
    height = "3vh",
    text = "Overlapping Elements",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Box 1 (z-index: 1)
  Gui.new({
    x = "5vw",
    y = "20vh",
    width = "20vw",
    height = "20vh",
    z = 1,
    backgroundColor = Color.new(0.8, 0.3, 0.3, 1),
    text = "Z-Index: 1",
    textSize = "2.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
  })
  
  -- Box 2 (z-index: 2) - overlaps Box 1
  Gui.new({
    x = "12vw",
    y = "25vh",
    width = "20vw",
    height = "20vh",
    z = 2,
    backgroundColor = Color.new(0.3, 0.8, 0.3, 1),
    text = "Z-Index: 2",
    textSize = "2.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
  })
  
  -- Box 3 (z-index: 3) - overlaps Box 1 and 2
  Gui.new({
    x = "19vw",
    y = "30vh",
    width = "20vw",
    height = "20vh",
    z = 3,
    backgroundColor = Color.new(0.3, 0.3, 0.8, 1),
    text = "Z-Index: 3",
    textSize = "2.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
  })
  
  -- Section 2: Cards with different layers
  Gui.new({
    x = "50vw",
    y = "15vh",
    width = "48vw",
    height = "3vh",
    text = "Layered Cards",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Create a stack of cards
  for i = 1, 5 do
    Gui.new({
      x = (52 + i * 2) .. "vw",
      y = (18 + i * 3) .. "vh",
      width = "22vw",
      height = "15vh",
      z = i,
      backgroundColor = Color.new(0.3 + i * 0.1, 0.4, 0.7 - i * 0.1, 1),
      text = "Card " .. i .. "\nZ-Index: " .. i,
      textSize = "2vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 8,
      border = { top = true, right = true, bottom = true, left = true },
      borderColor = Color.new(1, 1, 1, 0.3),
    })
  end
  
  -- Section 3: Interactive z-index demo
  Gui.new({
    x = "2vw",
    y = "53vh",
    width = "96vw",
    height = "3vh",
    text = "Click to Bring to Front",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local maxZ = 10
  
  -- Create interactive boxes
  for i = 1, 4 do
    local box = Gui.new({
      x = (5 + (i - 1) * 22) .. "vw",
      y = "58vh",
      width = "20vw",
      height = "20vh",
      z = i,
      backgroundColor = Color.new(
        0.4 + i * 0.1,
        0.5 + math.sin(i) * 0.2,
        0.7 - i * 0.1,
        1
      ),
      text = "Box " .. i .. "\nClick me!",
      textSize = "2.2vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 10,
    })
    
    -- Add click handler to bring to front
    box.onEvent = function(element)
      maxZ = maxZ + 1
      element.z = maxZ
      element.text = "Box " .. i .. "\nZ: " .. element.z
    end
  end
  
  -- Info text
  Gui.new({
    x = "2vw",
    y = "82vh",
    width = "96vw",
    height = "14vh",
    backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
    text = "Z-Index determines the stacking order of elements.\n" ..
           "Higher values appear on top of lower values.\n" ..
           "Click the boxes above to bring them to the front!",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 8,
  })
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
