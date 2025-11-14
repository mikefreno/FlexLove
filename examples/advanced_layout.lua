--[[
  Example: Advanced Layout with Flexbox and Grid
  This example demonstrates advanced layout techniques using both flexbox and grid layouts
]]

local FlexLove = require("libs.FlexLove")

-- Create the main window
local window = FlexLove.new({
  x = "10%",
  y = "10%",
  width = "80%",
  height = "80%",
  themeComponent = "framev3",
  positioning = "flex",
  flexDirection = "vertical",
  gap = 20,
  padding = { horizontal = 20, vertical = 20 },
})

-- Title
FlexLove.new({
  parent = window,
  text = "Advanced Layout Example",
  textAlign = "center",
  textSize = "3xl",
  width = "100%",
})

-- Flex container with complex layout
local flexContainer = FlexLove.new({
  parent = window,
  positioning = "flex",
  flexDirection = "horizontal",
  justifyContent = "space-between",
  alignItems = "stretch",
  gap = 15,
  height = "70%",
})

-- Left panel - Grid layout
local leftPanel = FlexLove.new({
  parent = flexContainer,
  width = "40%",
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
  padding = { horizontal = 10, vertical = 10 },
})

FlexLove.new({
  parent = leftPanel,
  text = "Grid Layout Example",
  textAlign = "center",
  textSize = "lg",
  width = "100%",
})

-- Grid container
local gridContainer = FlexLove.new({
  parent = leftPanel,
  positioning = "flex",
  flexDirection = "horizontal",
  flexWrap = "wrap",
  justifyContent = "space-between",
  alignItems = "flex-start",
  gap = 10,
  height = "80%",
})

-- Grid items
for i = 1, 6 do
  FlexLove.new({
    parent = gridContainer,
    width = "45%",
    height = "40%",
    themeComponent = "buttonv2",
    text = "Item " .. i,
    textAlign = "center",
    textSize = "md",
    onEvent = function(_, event)
      if event.type == "release" then
        print("Grid item " .. i .. " clicked")
      end
    end,
  })
end

-- Right panel - Flex layout with nested flex containers
local rightPanel = FlexLove.new({
  parent = flexContainer,
  width = "55%",
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
})

FlexLove.new({
  parent = rightPanel,
  text = "Nested Flex Containers",
  textAlign = "center",
  textSize = "lg",
  width = "100%",
})

-- First nested flex container
local nestedFlex1 = FlexLove.new({
  parent = rightPanel,
  positioning = "flex",
  flexDirection = "horizontal",
  justifyContent = "space-around",
  alignItems = "center",
  gap = 10,
  height = "40%",
})

FlexLove.new({
  parent = nestedFlex1,
  text = "Button A",
  themeComponent = "buttonv1",
  width = "25%",
  textAlign = "center",
  onEvent = function(_, event)
    if event.type == "release" then
      print("Button A clicked")
    end
  end,
})

FlexLove.new({
  parent = nestedFlex1,
  text = "Button B",
  themeComponent = "buttonv2",
  width = "25%",
  textAlign = "center",
  onEvent = function(_, event)
    if event.type == "release" then
      print("Button B clicked")
    end
  end,
})

-- Second nested flex container
local nestedFlex2 = FlexLove.new({
  parent = rightPanel,
  positioning = "flex",
  flexDirection = "vertical",
  justifyContent = "space-around",
  alignItems = "stretch",
  gap = 10,
  height = "50%",
})

FlexLove.new({
  parent = nestedFlex2,
  text = "Vertical Flex Item 1",
  themeComponent = "framev3",
  textAlign = "center",
  padding = { vertical = 10 },
})

FlexLove.new({
  parent = nestedFlex2,
  text = "Vertical Flex Item 2",
  themeComponent = "framev3",
  textAlign = "center",
  padding = { vertical = 10 },
})

-- Footer with progress bar
local footer = FlexLove.new({
  parent = window,
  positioning = "flex",
  flexDirection = "horizontal",
  justifyContent = "space-between",
  alignItems = "center",
  gap = 15,
  height = "20%",
})

FlexLove.new({
  parent = footer,
  text = "Progress:",
  textAlign = "start",
  textSize = "md",
})

local progressContainer = FlexLove.new({
  parent = footer,
  width = "60%",
  height = "30%",
  themeComponent = "framev3",
  positioning = "flex",
  flexDirection = "horizontal",
  alignItems = "center",
  gap = 5,
})

-- Progress bar fill
local progressFill = FlexLove.new({
  parent = progressContainer,
  width = "70%",
  height = "100%",
  themeComponent = "buttonv1",
})

FlexLove.new({
  parent = footer,
  text = "70%",
  textAlign = "end",
  textSize = "md",
})
