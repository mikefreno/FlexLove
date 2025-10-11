-- Example demonstrating basic CSS Grid layout
-- Shows how to create grid containers and position items

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color
local enums = FlexLove.enums

print("=== Basic Grid Layout Examples ===\n")

-- Example 1: Simple 3-column grid
print("1. Simple 3-Column Grid")
print("   Grid with equal columns using fr units")

local grid1 = Gui.new({
  x = 50,
  y = 50,
  width = 600,
  height = 400,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "1fr 1fr 1fr",
  gridTemplateRows = "auto auto",
  columnGap = 10,
  rowGap = 10,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 20, vertical = 20 },
})

-- Add grid items
for i = 1, 6 do
  Gui.new({
    parent = grid1,
    width = 50,
    height = 50,
    background = Color.new(0.2, 0.5, 0.8, 1),
    text = "Item " .. i,
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   Grid container: 600x400, 3 columns (1fr each), 2 rows (auto)")
print("   Column gap: 10px, Row gap: 10px")
print("   Items: 6 items auto-placed in grid\n")

-- Example 2: Mixed column sizes
print("2. Mixed Column Sizes")
print("   Grid with different column widths")

Gui.destroy()
local grid2 = Gui.new({
  x = 50,
  y = 50,
  width = 800,
  height = 300,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "200px 1fr 2fr",
  gridTemplateRows = "100px 100px",
  columnGap = 15,
  rowGap = 15,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 20, vertical = 20 },
})

local labels = { "Sidebar", "Content", "Main", "Footer", "Info", "Extra" }
for i = 1, 6 do
  Gui.new({
    parent = grid2,
    background = Color.new(0.3, 0.6, 0.3, 1),
    text = labels[i],
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   Columns: 200px (fixed), 1fr, 2fr (flexible)")
print("   The flexible columns share remaining space proportionally\n")

-- Example 3: Explicit item placement
print("3. Explicit Grid Item Placement")
print("   Items placed at specific grid positions")

Gui.destroy()
local grid3 = Gui.new({
  x = 50,
  y = 50,
  width = 600,
  height = 400,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "1fr 1fr 1fr",
  gridTemplateRows = "1fr 1fr 1fr",
  columnGap = 10,
  rowGap = 10,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 20, vertical = 20 },
})

-- Header spanning all columns
Gui.new({
  parent = grid3,
  gridColumn = "1 / 4", -- Span from column 1 to 4 (all 3 columns)
  gridRow = 1,
  background = Color.new(0.8, 0.3, 0.3, 1),
  text = "Header (spans all columns)",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

-- Sidebar spanning 2 rows
Gui.new({
  parent = grid3,
  gridColumn = 1,
  gridRow = "2 / 4", -- Span from row 2 to 4 (2 rows)
  background = Color.new(0.3, 0.3, 0.8, 1),
  text = "Sidebar",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

-- Main content area
Gui.new({
  parent = grid3,
  gridColumn = "2 / 4", -- Span columns 2-3
  gridRow = 2,
  background = Color.new(0.3, 0.8, 0.3, 1),
  text = "Main Content",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

-- Footer spanning columns 2-3
Gui.new({
  parent = grid3,
  gridColumn = "2 / 4",
  gridRow = 3,
  background = Color.new(0.8, 0.8, 0.3, 1),
  text = "Footer",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

print("   Header: spans columns 1-3, row 1")
print("   Sidebar: column 1, spans rows 2-3")
print("   Main: spans columns 2-3, row 2")
print("   Footer: spans columns 2-3, row 3\n")

-- Example 4: Using repeat() function
print("4. Using repeat() Function")
print("   Create multiple columns with repeat notation")

Gui.destroy()
local grid4 = Gui.new({
  x = 50,
  y = 50,
  width = 800,
  height = 300,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "repeat(4, 1fr)", -- Creates 4 equal columns
  gridTemplateRows = "repeat(2, 1fr)", -- Creates 2 equal rows
  columnGap = 10,
  rowGap = 10,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 20, vertical = 20 },
})

for i = 1, 8 do
  Gui.new({
    parent = grid4,
    background = Color.new(0.5, 0.3, 0.7, 1),
    text = "Box " .. i,
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   gridTemplateColumns: repeat(4, 1fr)")
print("   gridTemplateRows: repeat(2, 1fr)")
print("   Creates a 4x2 grid with 8 equal cells\n")

-- Example 5: Percentage-based grid
print("5. Percentage-Based Grid")
print("   Using percentage units for columns")

Gui.destroy()
local grid5 = Gui.new({
  x = 50,
  y = 50,
  width = 600,
  height = 200,
  positioning = enums.Positioning.GRID,
  gridTemplateColumns = "25% 50% 25%",
  gridTemplateRows = "100%",
  columnGap = 0,
  rowGap = 0,
  background = Color.new(0.9, 0.9, 0.9, 1),
})

local colors = {
  Color.new(0.8, 0.2, 0.2, 1),
  Color.new(0.2, 0.8, 0.2, 1),
  Color.new(0.2, 0.2, 0.8, 1),
}

for i = 1, 3 do
  Gui.new({
    parent = grid5,
    background = colors[i],
    text = (i == 1 and "25%" or i == 2 and "50%" or "25%"),
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   Columns: 25%, 50%, 25%")
print("   Perfect for layouts with specific proportions\n")

print("=== Summary ===")
print("• Set positioning = Positioning.GRID to create a grid container")
print("• Use gridTemplateColumns and gridTemplateRows to define track sizes")
print("• Supported units: px, %, fr, auto, repeat()")
print("• Use columnGap and rowGap for spacing between tracks")
print("• Use gridColumn and gridRow on children for explicit placement")
print("• Use 'start / end' syntax to span multiple tracks")
print("• Items auto-place if no explicit position is set")
