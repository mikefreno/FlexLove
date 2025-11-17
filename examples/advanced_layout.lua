--[[
  Example: Advanced Layout with Flexbox and Grid
  This example demonstrates advanced layout techniques using both flexbox and grid layouts
]]

local FlexLove = require("libs.FlexLove")
local Color = FlexLove.Color
local Theme = FlexLove.Theme

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

-- Left panel - True Grid Layout
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
  text = "True Grid Layout (3x3)",
  textAlign = "center",
  textSize = "lg",
  width = "100%",
})

-- Grid container using positioning = "grid"
local gridContainer = FlexLove.new({
  parent = leftPanel,
  positioning = "grid",
  gridRows = 3,
  gridColumns = 3,
  columnGap = 5,
  rowGap = 5,
  height = "80%",
  alignItems = "stretch",
})

-- Grid items (will auto-flow into cells)
for i = 1, 9 do
  FlexLove.new({
    parent = gridContainer,
    themeComponent = "buttonv2",
    text = "Cell " .. i,
    textAlign = "center",
    textSize = "md",
    onEvent = function(_, event)
      if event.type == "release" then
        print("Grid cell " .. i .. " clicked")
      end
    end,
  })
end

-- Right panel - Grid with Headers (like a schedule)
local rightPanel = FlexLove.new({
  parent = flexContainer,
  width = "55%",
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
})

FlexLove.new({
  parent = rightPanel,
  text = "Grid with Headers (4x4)",
  textAlign = "center",
  textSize = "lg",
  width = "100%",
})

-- Example data for schedule-like grid
local columnHeaders = { "Mon", "Tue", "Wed" }
local rowHeaders = { "Task A", "Task B", "Task C" }

-- Calculate grid dimensions: +1 for header row and column
local numRows = #rowHeaders + 1 -- +1 for header row
local numColumns = #columnHeaders + 1 -- +1 for row labels column

local scheduleGrid = FlexLove.new({
  parent = rightPanel,
  positioning = "grid",
  gridRows = numRows,
  gridColumns = numColumns,
  columnGap = 2,
  rowGap = 2,
  height = "80%",
  alignItems = "stretch",
})

local accentColor = Theme.getColor("primary")
local textColor = Theme.getColor("text")

-- Top-left corner cell (empty)
FlexLove.new({
  parent = scheduleGrid,
})

-- Column headers
for _, header in ipairs(columnHeaders) do
  FlexLove.new({
    parent = scheduleGrid,
    text = header,
    textColor = textColor,
    textAlign = "center",
    backgroundColor = Color.new(0, 0, 0, 0.3),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = accentColor,
    textSize = 12,
  })
end

-- Data rows
for i, rowHeader in ipairs(rowHeaders) do
  -- Row header
  FlexLove.new({
    parent = scheduleGrid,
    text = rowHeader,
    backgroundColor = Color.new(0, 0, 0, 0.3),
    textColor = textColor,
    textAlign = "center",
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = accentColor,
    textSize = 10,
  })

  -- Data cells
  for j = 1, #columnHeaders do
    local value = (i * j) % 5
    FlexLove.new({
      parent = scheduleGrid,
      text = tostring(value),
      textAlign = "center",
      border = { top = true, right = true, bottom = true, left = true },
      borderColor = Color.new(0.5, 0.5, 0.5, 1.0),
      textSize = 12,
      themeComponent = "buttonv2",
      onEvent = function(elem, event)
        if event.type == "click" then
          local newValue = (tonumber(elem.text) + 1) % 10
          elem:updateText(tostring(newValue))
          print("Cell [" .. i .. "," .. j .. "] clicked, new value: " .. newValue)
        end
      end,
    })
  end
end

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
