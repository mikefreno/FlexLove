-- Example demonstrating responsive grid layouts with viewport units
-- Shows how grids adapt to different screen sizes

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color
local enums = FlexLove.enums

print("=== Responsive Grid Layout Examples ===\n")

-- Example 1: Dashboard layout with responsive grid
print("1. Dashboard Layout")
print("   Responsive grid using viewport units")

local dashboard = Gui.new({
  x = 0,
  y = 0,
  width = "100vw",
  height = "100vh",
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "200px 1fr 1fr",
  gridTemplateRows = "60px 1fr 1fr 80px",
  columnGap = 10,
  rowGap = 10,
  background = Color.new(0.95, 0.95, 0.95, 1),
  padding = { horizontal = 10, vertical = 10 },
})

-- Header (spans all columns)
Gui.new({
  parent = dashboard,
  gridColumn = "1 / 4",
  gridRow = 1,
  background = Color.new(0.2, 0.3, 0.5, 1),
  text = "Dashboard Header",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
  textSize = 24,
})

-- Sidebar (spans rows 2-3)
Gui.new({
  parent = dashboard,
  gridColumn = 1,
  gridRow = "2 / 4",
  background = Color.new(0.3, 0.3, 0.4, 1),
  text = "Navigation",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

-- Main content area (top)
Gui.new({
  parent = dashboard,
  gridColumn = "2 / 4",
  gridRow = 2,
  background = Color.new(1, 1, 1, 1),
  text = "Main Content",
  textColor = Color.new(0.2, 0.2, 0.2, 1),
  textAlign = enums.TextAlign.CENTER,
  border = { top = true, right = true, bottom = true, left = true },
  borderColor = Color.new(0.8, 0.8, 0.8, 1),
})

-- Stats section (bottom left)
Gui.new({
  parent = dashboard,
  gridColumn = 2,
  gridRow = 3,
  background = Color.new(0.9, 0.95, 1, 1),
  text = "Statistics",
  textColor = Color.new(0.2, 0.2, 0.2, 1),
  textAlign = enums.TextAlign.CENTER,
  border = { top = true, right = true, bottom = true, left = true },
  borderColor = Color.new(0.8, 0.8, 0.8, 1),
})

-- Activity feed (bottom right)
Gui.new({
  parent = dashboard,
  gridColumn = 3,
  gridRow = 3,
  background = Color.new(1, 0.95, 0.9, 1),
  text = "Activity Feed",
  textColor = Color.new(0.2, 0.2, 0.2, 1),
  textAlign = enums.TextAlign.CENTER,
  border = { top = true, right = true, bottom = true, left = true },
  borderColor = Color.new(0.8, 0.8, 0.8, 1),
})

-- Footer (spans all columns)
Gui.new({
  parent = dashboard,
  gridColumn = "1 / 4",
  gridRow = 4,
  background = Color.new(0.2, 0.3, 0.5, 1),
  text = "Footer - Copyright 2025",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

print("   Layout structure:")
print("   - Header: Full width, 60px height")
print("   - Sidebar: 200px wide, spans content rows")
print("   - Main content: Flexible width, top content area")
print("   - Stats & Activity: Split remaining space")
print("   - Footer: Full width, 80px height\n")

-- Example 2: Card grid with auto-flow
print("2. Card Grid with Auto-Flow")
print("   Grid that automatically places items")

Gui.destroy()
local cardGrid = Gui.new({
  x = "5vw",
  y = "5vh",
  width = "90vw",
  height = "90vh",
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "repeat(3, 1fr)",
  gridTemplateRows = "auto",
  gridAutoRows = "200px",
  gridAutoFlow = enums.GridAutoFlow.ROW,
  columnGap = 20,
  rowGap = 20,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 20, vertical = 20 },
})

local cardColors = {
  Color.new(0.8, 0.3, 0.3, 1),
  Color.new(0.3, 0.8, 0.3, 1),
  Color.new(0.3, 0.3, 0.8, 1),
  Color.new(0.8, 0.8, 0.3, 1),
  Color.new(0.8, 0.3, 0.8, 1),
  Color.new(0.3, 0.8, 0.8, 1),
}

for i = 1, 9 do
  local colorIndex = ((i - 1) % #cardColors) + 1
  Gui.new({
    parent = cardGrid,
    background = cardColors[colorIndex],
    text = "Card " .. i,
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    textSize = 20,
  })
end

print("   9 cards in a 3-column grid")
print("   Auto-flow: ROW (fills rows first)")
print("   Auto-generated rows: 200px each\n")

-- Example 3: Nested grids
print("3. Nested Grid Layout")
print("   Grid containers within grid items")

Gui.destroy()
local outerGrid = Gui.new({
  x = 50,
  y = 50,
  width = 700,
  height = 500,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "1fr 2fr",
  gridTemplateRows = "1fr 1fr",
  columnGap = 15,
  rowGap = 15,
  background = Color.new(0.85, 0.85, 0.85, 1),
  padding = { horizontal = 15, vertical = 15 },
})

-- Top-left: Simple item
Gui.new({
  parent = outerGrid,
  background = Color.new(0.5, 0.3, 0.7, 1),
  text = "Simple Item",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

-- Top-right: Nested grid
local nestedGrid1 = Gui.new({
  parent = outerGrid,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "1fr 1fr",
  gridTemplateRows = "1fr 1fr",
  columnGap = 5,
  rowGap = 5,
  background = Color.new(0.7, 0.7, 0.7, 1),
  padding = { horizontal = 5, vertical = 5 },
})

for i = 1, 4 do
  Gui.new({
    parent = nestedGrid1,
    background = Color.new(0.3, 0.6, 0.9, 1),
    text = "A" .. i,
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

-- Bottom-left: Another nested grid
local nestedGrid2 = Gui.new({
  parent = outerGrid,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "repeat(3, 1fr)",
  gridTemplateRows = "1fr",
  columnGap = 5,
  rowGap = 5,
  background = Color.new(0.7, 0.7, 0.7, 1),
  padding = { horizontal = 5, vertical = 5 },
})

for i = 1, 3 do
  Gui.new({
    parent = nestedGrid2,
    background = Color.new(0.9, 0.6, 0.3, 1),
    text = "B" .. i,
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

-- Bottom-right: Simple item
Gui.new({
  parent = outerGrid,
  background = Color.new(0.3, 0.7, 0.5, 1),
  text = "Another Item",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

print("   Outer grid: 2x2 layout")
print("   Top-right cell: 2x2 nested grid")
print("   Bottom-left cell: 1x3 nested grid")
print("   Other cells: Simple items\n")

print("=== Summary ===")
print("• Grids work with viewport units (vw, vh) for responsive layouts")
print("• Use gridAutoFlow to control automatic item placement")
print("• gridAutoRows/gridAutoColumns define sizes for auto-generated tracks")
print("• Grids can be nested within grid items")
print("• Combine fixed (px) and flexible (fr) units for hybrid layouts")
print("• Use gaps to create visual separation between grid items")
