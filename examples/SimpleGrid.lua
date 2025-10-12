-- Example demonstrating the simplified grid layout system
-- Shows how to create grids with simple row/column counts

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color
local enums = FlexLove.enums

print("=== Simplified Grid Layout Examples ===\n")

-- Example 1: Simple 3x2 grid
print("1. Simple 3x2 Grid")
print("   Grid with 3 columns and 2 rows")

local grid1 = Gui.new({
  x = 50,
  y = 50,
  width = 600,
  height = 400,
  positioning = enums.Positioning.GRID,
  gridRows = 2,
  gridColumns = 3,
  columnGap = 10,
  rowGap = 10,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 20, vertical = 20 },
})

-- Add grid items - they auto-tile in order
for i = 1, 6 do
  Gui.new({
    parent = grid1,
    background = Color.new(0.2, 0.5, 0.8, 1),
    text = "Item " .. i,
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   Grid container: 600x400, 3 columns, 2 rows")
print("   Column gap: 10px, Row gap: 10px")
print("   Items: 6 items auto-tiled in order\n")

-- Example 2: Square grid (4x4)
print("2. Square Grid (4x4)")
print("   Perfect for icon grids or game boards")

Gui.destroy()
local grid2 = Gui.new({
  x = 50,
  y = 50,
  width = 400,
  height = 400,
  positioning = enums.Positioning.GRID,
  gridRows = 4,
  gridColumns = 4,
  columnGap = 5,
  rowGap = 5,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 10, vertical = 10 },
})

for i = 1, 16 do
  Gui.new({
    parent = grid2,
    background = Color.new(0.3, 0.6, 0.3, 1),
    text = tostring(i),
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   16 items in a 4x4 grid")
print("   Each cell is equal size\n")

-- Example 3: Horizontal strip (1 row, multiple columns)
print("3. Horizontal Strip")
print("   Single row with multiple columns")

Gui.destroy()
local grid3 = Gui.new({
  x = 50,
  y = 50,
  width = 800,
  height = 100,
  positioning = enums.Positioning.GRID,
  gridRows = 1,
  gridColumns = 5,
  columnGap = 10,
  rowGap = 0,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 10, vertical = 10 },
})

local labels = { "Home", "Products", "About", "Contact", "Login" }
for i = 1, 5 do
  Gui.new({
    parent = grid3,
    background = Color.new(0.3, 0.3, 0.8, 1),
    text = labels[i],
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   Perfect for navigation bars\n")

-- Example 4: Vertical strip (multiple rows, 1 column)
print("4. Vertical Strip")
print("   Single column with multiple rows")

Gui.destroy()
local grid4 = Gui.new({
  x = 50,
  y = 50,
  width = 200,
  height = 500,
  positioning = enums.Positioning.GRID,
  gridRows = 5,
  gridColumns = 1,
  columnGap = 0,
  rowGap = 10,
  background = Color.new(0.9, 0.9, 0.9, 1),
  padding = { horizontal = 10, vertical = 10 },
})

for i = 1, 5 do
  Gui.new({
    parent = grid4,
    background = Color.new(0.5, 0.3, 0.7, 1),
    text = "Option " .. i,
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
end

print("   Perfect for sidebar menus\n")

-- Example 5: Nested grids
print("5. Nested Grids")
print("   Grid containers within grid cells")

Gui.destroy()
local outerGrid = Gui.new({
  x = 50,
  y = 50,
  width = 600,
  height = 400,
  positioning = enums.Positioning.GRID,
  gridRows = 2,
  gridColumns = 2,
  columnGap = 10,
  rowGap = 10,
  background = Color.new(0.85, 0.85, 0.85, 1),
  padding = { horizontal = 10, vertical = 10 },
})

-- Top-left: Simple item
Gui.new({
  parent = outerGrid,
  background = Color.new(0.5, 0.3, 0.7, 1),
  text = "Single Item",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

-- Top-right: Nested 2x2 grid
local nestedGrid1 = Gui.new({
  parent = outerGrid,
  positioning = enums.Positioning.GRID,
  gridRows = 2,
  gridColumns = 2,
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

-- Bottom-left: Nested 1x3 grid
local nestedGrid2 = Gui.new({
  parent = outerGrid,
  positioning = enums.Positioning.GRID,
  gridRows = 1,
  gridColumns = 3,
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

-- Bottom-right: Another simple item
Gui.new({
  parent = outerGrid,
  background = Color.new(0.3, 0.7, 0.5, 1),
  text = "Another Item",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = enums.TextAlign.CENTER,
})

print("   Outer grid: 2x2 layout")
print("   Top-right: 2x2 nested grid")
print("   Bottom-left: 1x3 nested grid\n")

print("=== Summary ===")
print("The simplified grid system provides:")
print("• Simple API: Just set gridRows and gridColumns")
print("• Auto-tiling: Children are placed in order automatically")
print("• Equal sizing: All cells are equal size")
print("• Gaps: Use columnGap and rowGap for spacing")
print("• Stretch: Children stretch to fill cells by default")
print("• Nesting: Grids can contain other grids")
print("\nNo need for complex track definitions, explicit placement, or spans!")

Gui.destroy()
