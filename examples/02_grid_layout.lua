--[[
  FlexLove Example 02: Grid Layout
  
  This example demonstrates grid layouts in FlexLove:
  - Different grid configurations (2x2, 3x3, 4x2)
  - Row and column gaps
  - AlignItems behavior in grid cells
  - Automatic grid cell positioning
  
  Run with: love /path/to/libs/examples/02_grid_layout.lua
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
    text = "FlexLove Example 02: Grid Layout",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: 2x2 Grid with Gaps
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "10vh",
    width = "30vw",
    height = "3vh",
    text = "2x2 Grid (rowGap: 10px, columnGap: 10px)",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local grid2x2 = Gui.new({
    x = "2vw",
    y = "14vh",
    width = "30vw",
    height = "30vh",
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
    rowGap = 10,
    columnGap = 10,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })
  
  -- Add 4 cells to 2x2 grid
  local colors2x2 = {
    Color.new(0.8, 0.3, 0.3, 1),
    Color.new(0.3, 0.8, 0.3, 1),
    Color.new(0.3, 0.3, 0.8, 1),
    Color.new(0.8, 0.8, 0.3, 1),
  }
  
  for j = 1, 4 do
    Gui.new({
      parent = grid2x2,
      backgroundColor = colors2x2[j],
      text = "Cell " .. j,
      textSize = "2.5vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end
  
  -- ========================================
  -- Section 2: 3x3 Grid with Different Gap Sizes
  -- ========================================
  
  Gui.new({
    x = "34vw",
    y = "10vh",
    width = "30vw",
    height = "3vh",
    text = "3x3 Grid (rowGap: 5px, columnGap: 15px)",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local grid3x3 = Gui.new({
    x = "34vw",
    y = "14vh",
    width = "30vw",
    height = "30vh",
    positioning = enums.Positioning.GRID,
    gridRows = 3,
    gridColumns = 3,
    rowGap = 5,
    columnGap = 15,
    backgroundColor = Color.new(0.1, 0.15, 0.1, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.4, 0.3, 1),
  })
  
  -- Add 9 cells to 3x3 grid
  for j = 1, 9 do
    local hue = (j - 1) / 9
    Gui.new({
      parent = grid3x3,
      backgroundColor = Color.new(0.3 + hue * 0.5, 0.5, 0.7 - hue * 0.4, 1),
      text = tostring(j),
      textSize = "2vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end
  
  -- ========================================
  -- Section 3: 4x2 Grid with AlignItems
  -- ========================================
  
  Gui.new({
    x = "66vw",
    y = "10vh",
    width = "32vw",
    height = "3vh",
    text = "4x2 Grid (alignItems: center)",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local grid4x2 = Gui.new({
    x = "66vw",
    y = "14vh",
    width = "32vw",
    height = "30vh",
    positioning = enums.Positioning.GRID,
    gridRows = 4,
    gridColumns = 2,
    rowGap = 8,
    columnGap = 8,
    alignItems = enums.AlignItems.CENTER,
    backgroundColor = Color.new(0.15, 0.1, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.4, 0.3, 0.4, 1),
  })
  
  -- Add 8 cells with varying content
  for j = 1, 8 do
    Gui.new({
      parent = grid4x2,
      backgroundColor = Color.new(0.6, 0.4 + j * 0.05, 0.7 - j * 0.05, 1),
      text = "Item " .. j,
      textSize = "1.8vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end
  
  -- ========================================
  -- Section 4: Grid with Responsive Units (vw/vh gaps)
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "46vh",
    width = "96vw",
    height = "3vh",
    text = "Grid with Responsive Gaps (rowGap: 2vh, columnGap: 2vw)",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local gridResponsive = Gui.new({
    x = "2vw",
    y = "50vh",
    width = "96vw",
    height = "45vh",
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 5,
    rowGap = "2vh",
    columnGap = "2vw",
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.25, 0.25, 0.35, 1),
  })
  
  -- Add 10 cells with gradient colors
  for j = 1, 10 do
    local progress = (j - 1) / 9
    Gui.new({
      parent = gridResponsive,
      backgroundColor = Color.new(
        0.2 + progress * 0.6,
        0.4 + math.sin(progress * 3.14) * 0.4,
        0.8 - progress * 0.4,
        1
      ),
      text = "Cell " .. j,
      textSize = "2.5vh",
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
