--[[
  FlexLove Example 10: Padding and Margins
  
  This example demonstrates padding and margin spacing:
  - Uniform padding
  - Individual padding sides
  - Uniform margins
  - Individual margin sides
  - Visual indicators for spacing
  
  Run with: love /path/to/libs/examples/10_padding_margins.lua
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
    text = "FlexLove Example 10: Padding and Margins",
    textSize = "3.5vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Section 1: Padding Examples
  FlexLove.new({
    x = "2vw",
    y = "9vh",
    width = "46vw",
    height = "3vh",
    text = "Padding (internal spacing)",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Uniform padding
  local container1 = FlexLove.new({
    x = "2vw",
    y = "13vh",
    width = "22vw",
    height = "18vh",
    backgroundColor = Color.new(0.3, 0.4, 0.6, 1),
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })
  
  FlexLove.new({
    parent = container1,
    width = "auto",
    height = "auto",
    backgroundColor = Color.new(0.8, 0.6, 0.3, 1),
    text = "Uniform\npadding: 20px",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Individual padding sides
  local container2 = FlexLove.new({
    x = "26vw",
    y = "13vh",
    width = "22vw",
    height = "18vh",
    backgroundColor = Color.new(0.4, 0.6, 0.3, 1),
    padding = { top = 30, right = 10, bottom = 30, left = 10 },
  })
  
  FlexLove.new({
    parent = container2,
    width = "auto",
    height = "auto",
    backgroundColor = Color.new(0.8, 0.3, 0.6, 1),
    text = "Individual\ntop/bottom: 30px\nleft/right: 10px",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Section 2: Margin Examples
  FlexLove.new({
    x = "50vw",
    y = "9vh",
    width = "48vw",
    height = "3vh",
    text = "Margins (external spacing)",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Container to show margins
  local marginContainer = FlexLove.new({
    x = "50vw",
    y = "13vh",
    width = "46vw",
    height = "38vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
  })
  
  -- Elements with different margins
  FlexLove.new({
    parent = marginContainer,
    width = "40vw",
    height = "6vh",
    backgroundColor = Color.new(0.7, 0.3, 0.3, 1),
    margin = { top = 10, right = 10, bottom = 10, left = 10 },
    text = "Uniform margin: 10px",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  FlexLove.new({
    parent = marginContainer,
    width = "40vw",
    height = "6vh",
    backgroundColor = Color.new(0.3, 0.7, 0.3, 1),
    margin = { top = 5, right = 30, bottom = 5, left = 30 },
    text = "Horizontal margin: 30px",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  FlexLove.new({
    parent = marginContainer,
    width = "40vw",
    height = "6vh",
    backgroundColor = Color.new(0.3, 0.3, 0.7, 1),
    margin = { top = 20, right = 10, bottom = 20, left = 10 },
    text = "Vertical margin: 20px",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Section 3: Combined Padding and Margins
  FlexLove.new({
    x = "2vw",
    y = "33vh",
    width = "46vw",
    height = "3vh",
    text = "Combined Padding & Margins",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local combinedContainer = FlexLove.new({
    x = "2vw",
    y = "37vh",
    width = "46vw",
    height = "58vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  
  for i = 1, 3 do
    local box = FlexLove.new({
      parent = combinedContainer,
      width = "auto",
      height = "14vh",
      backgroundColor = Color.new(0.5 + i * 0.1, 0.4, 0.6 - i * 0.1, 1),
      margin = { top = 10, right = 0, bottom = 10, left = 0 },
      padding = { top = 15, right = 15, bottom = 15, left = 15 },
    })
    
    FlexLove.new({
      parent = box,
      width = "auto",
      height = "auto",
      backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
      text = "Box " .. i .. "\nPadding: 15px\nMargin: 10px",
      textSize = "1.8vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
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
