-- Grid Layout Tests
-- Tests for CSS Grid layout functionality

package.path = package.path .. ";?.lua"

local lu = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color
local enums = FlexLove.enums

TestGridLayout = {}

function TestGridLayout:setUp()
  -- Reset GUI before each test
  Gui.destroy()
  Gui.init({})
end

function TestGridLayout:tearDown()
  Gui.destroy()
end

-- ====================
-- Track Parsing Tests (via grid behavior)
-- ====================

function TestGridLayout:test_grid_accepts_various_track_formats()
  -- Test that grid accepts various track size formats without errors
  local grid1 = Gui.new({
    x = 0,
    y = 0,
    width = 600,
    height = 400,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px 2fr 50%",
    gridTemplateRows = "auto 1fr",
  })
  lu.assertNotNil(grid1)

  local grid2 = Gui.new({
    x = 0,
    y = 0,
    width = 600,
    height = 400,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "repeat(3, 1fr)",
    gridTemplateRows = "repeat(2, 100px)",
  })
  lu.assertNotNil(grid2)

  Gui.destroy()
end

-- ====================
-- Basic Grid Layout Tests
-- ====================

function TestGridLayout:test_simple_grid_creation()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 600,
    height = 400,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "1fr 1fr 1fr",
    gridTemplateRows = "1fr 1fr",
  })

  lu.assertEquals(grid.positioning, enums.Positioning.GRID)
  lu.assertEquals(grid.gridTemplateColumns, "1fr 1fr 1fr")
  lu.assertEquals(grid.gridTemplateRows, "1fr 1fr")
end

function TestGridLayout:test_grid_with_gaps()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 600,
    height = 400,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "1fr 1fr",
    gridTemplateRows = "1fr 1fr",
    columnGap = 10,
    rowGap = 20,
  })

  lu.assertEquals(grid.columnGap, 10)
  lu.assertEquals(grid.rowGap, 20)
end

function TestGridLayout:test_grid_auto_placement()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px 100px 100px",
    gridTemplateRows = "100px 100px",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  -- Add 6 items that should auto-place in a 3x2 grid
  local items = {}
  for i = 1, 6 do
    items[i] = Gui.new({
      parent = grid,
      width = 50,
      height = 50,
    })
  end

  -- Check first item (top-left)
  lu.assertAlmostEquals(items[1].x, 0, 1)
  lu.assertAlmostEquals(items[1].y, 0, 1)

  -- Check second item (top-middle)
  lu.assertAlmostEquals(items[2].x, 100, 1)
  lu.assertAlmostEquals(items[2].y, 0, 1)

  -- Check fourth item (bottom-left)
  lu.assertAlmostEquals(items[4].x, 0, 1)
  lu.assertAlmostEquals(items[4].y, 100, 1)
end

function TestGridLayout:test_grid_explicit_placement()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px 100px 100px",
    gridTemplateRows = "100px 100px",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  -- Place item at column 2, row 2
  local item = Gui.new({
    parent = grid,
    gridColumn = 2,
    gridRow = 2,
    width = 50,
    height = 50,
  })

  -- Should be at position (100, 100)
  lu.assertAlmostEquals(item.x, 100, 1)
  lu.assertAlmostEquals(item.y, 100, 1)
end

function TestGridLayout:test_grid_spanning()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px 100px 100px",
    gridTemplateRows = "100px 100px",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  -- Item spanning columns 1-3
  local item = Gui.new({
    parent = grid,
    gridColumn = "1 / 4",
    gridRow = 1,
    width = 50,
    height = 50,
  })

  -- Should start at x=0 and span 300px (3 columns)
  lu.assertAlmostEquals(item.x, 0, 1)
  lu.assertAlmostEquals(item.width, 300, 1)
end

-- ====================
-- Track Sizing Tests
-- ====================

function TestGridLayout:test_fr_unit_distribution()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "1fr 2fr",
    gridTemplateRows = "1fr",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({
    parent = grid,
    gridColumn = 1,
    gridRow = 1,
    width = 50,
    height = 50,
  })

  local item2 = Gui.new({
    parent = grid,
    gridColumn = 2,
    gridRow = 1,
    width = 50,
    height = 50,
  })

  -- First column should be 100px (1fr), second should be 200px (2fr)
  lu.assertAlmostEquals(item1.x, 0, 1)
  lu.assertAlmostEquals(item2.x, 100, 1)
  lu.assertAlmostEquals(item1.width, 100, 1)
  lu.assertAlmostEquals(item2.width, 200, 1)
end

function TestGridLayout:test_mixed_units()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 400,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px 1fr 2fr",
    gridTemplateRows = "1fr",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({ parent = grid, gridColumn = 1, gridRow = 1, width = 50, height = 50 })
  local item2 = Gui.new({ parent = grid, gridColumn = 2, gridRow = 1, width = 50, height = 50 })
  local item3 = Gui.new({ parent = grid, gridColumn = 3, gridRow = 1, width = 50, height = 50 })

  -- First column: 100px (fixed)
  -- Remaining 300px divided as 1fr (100px) and 2fr (200px)
  lu.assertAlmostEquals(item1.width, 100, 1)
  lu.assertAlmostEquals(item2.width, 100, 1)
  lu.assertAlmostEquals(item3.width, 200, 1)
end

function TestGridLayout:test_percentage_columns()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 400,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "25% 50% 25%",
    gridTemplateRows = "1fr",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({ parent = grid, gridColumn = 1, gridRow = 1, width = 50, height = 50 })
  local item2 = Gui.new({ parent = grid, gridColumn = 2, gridRow = 1, width = 50, height = 50 })
  local item3 = Gui.new({ parent = grid, gridColumn = 3, gridRow = 1, width = 50, height = 50 })

  lu.assertAlmostEquals(item1.width, 100, 1) -- 25% of 400
  lu.assertAlmostEquals(item2.width, 200, 1) -- 50% of 400
  lu.assertAlmostEquals(item3.width, 100, 1) -- 25% of 400
end

-- ====================
-- Alignment Tests
-- ====================

function TestGridLayout:test_justify_items_stretch()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px 100px 100px",
    gridTemplateRows = "100px",
    justifyItems = enums.JustifyItems.STRETCH,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item = Gui.new({
    parent = grid,
    gridColumn = 1,
    gridRow = 1,
    height = 50,
  })

  -- Item should stretch to fill cell width
  lu.assertAlmostEquals(item.width, 100, 1)
end

function TestGridLayout:test_align_items_stretch()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px",
    gridTemplateRows = "100px 100px",
    alignItems = enums.AlignItems.STRETCH,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item = Gui.new({
    parent = grid,
    gridColumn = 1,
    gridRow = 1,
    width = 50,
  })

  -- Item should stretch to fill cell height
  lu.assertAlmostEquals(item.height, 100, 1)
end

-- ====================
-- Gap Tests
-- ====================

function TestGridLayout:test_column_gap()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 320,
    height = 100,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px 100px 100px",
    gridTemplateRows = "100px",
    columnGap = 10,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({ parent = grid, gridColumn = 1, gridRow = 1, width = 50, height = 50 })
  local item2 = Gui.new({ parent = grid, gridColumn = 2, gridRow = 1, width = 50, height = 50 })
  local item3 = Gui.new({ parent = grid, gridColumn = 3, gridRow = 1, width = 50, height = 50 })

  lu.assertAlmostEquals(item1.x, 0, 1)
  lu.assertAlmostEquals(item2.x, 110, 1) -- 100 + 10 gap
  lu.assertAlmostEquals(item3.x, 220, 1) -- 100 + 10 + 100 + 10
end

function TestGridLayout:test_row_gap()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 100,
    height = 320,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "100px",
    gridTemplateRows = "100px 100px 100px",
    columnGap = 0,
    rowGap = 10,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({ parent = grid, gridColumn = 1, gridRow = 1, width = 50, height = 50 })
  local item2 = Gui.new({ parent = grid, gridColumn = 1, gridRow = 2, width = 50, height = 50 })
  local item3 = Gui.new({ parent = grid, gridColumn = 1, gridRow = 3, width = 50, height = 50 })

  lu.assertAlmostEquals(item1.y, 0, 1)
  lu.assertAlmostEquals(item2.y, 110, 1) -- 100 + 10 gap
  lu.assertAlmostEquals(item3.y, 220, 1) -- 100 + 10 + 100 + 10
end

-- ====================
-- Nested Grid Tests
-- ====================

function TestGridLayout:test_nested_grids()
  local outerGrid = Gui.new({
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "1fr 1fr",
    gridTemplateRows = "1fr 1fr",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local innerGrid = Gui.new({
    parent = outerGrid,
    gridColumn = 1,
    gridRow = 1,
    positioning = enums.Positioning.GRID,
    gridTemplateColumns = "1fr 1fr",
    gridTemplateRows = "1fr 1fr",
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local innerItem = Gui.new({
    parent = innerGrid,
    gridColumn = 2,
    gridRow = 2,
    width = 50,
    height = 50,
  })

  -- Inner grid should be in top-left quadrant (200x200)
  -- Inner item should be in bottom-right of that (at 100, 100 relative to inner grid)
  lu.assertAlmostEquals(innerItem.x, 100, 1)
  lu.assertAlmostEquals(innerItem.y, 100, 1)
end

print("Running Grid Layout Tests...")
os.exit(lu.LuaUnit.run())
