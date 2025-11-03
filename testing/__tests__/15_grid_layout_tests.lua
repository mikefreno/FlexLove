-- Grid Layout Tests
-- Tests for simplified grid layout functionality

package.path = package.path .. ";?.lua"

local lu = require("testing.luaunit")
require("testing.loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui = FlexLove.Gui
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
-- Basic Grid Layout Tests
-- ====================

function TestGridLayout:test_simple_grid_creation()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 600,
    height = 400,
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 3,
  })

  lu.assertEquals(grid.positioning, enums.Positioning.GRID)
  lu.assertEquals(grid.gridRows, 2)
  lu.assertEquals(grid.gridColumns, 3)
end

function TestGridLayout:test_grid_with_gaps()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 600,
    height = 400,
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
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
    gridRows = 2,
    gridColumns = 3,
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

function TestGridLayout:test_grid_equal_distribution()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({
    parent = grid,
    width = 50,
    height = 50,
  })

  local item2 = Gui.new({
    parent = grid,
    width = 50,
    height = 50,
  })

  -- Each cell should be 150x100 (300/2 x 200/2)
  lu.assertAlmostEquals(item1.width, 150, 1)
  lu.assertAlmostEquals(item1.height, 100, 1)
  lu.assertAlmostEquals(item2.x, 150, 1)
  lu.assertAlmostEquals(item2.width, 150, 1)
end

function TestGridLayout:test_grid_stretch_behavior()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 400,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridRows = 1,
    gridColumns = 3,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({ parent = grid, width = 50, height = 50 })
  local item2 = Gui.new({ parent = grid, width = 50, height = 50 })
  local item3 = Gui.new({ parent = grid, width = 50, height = 50 })

  -- Each cell should be ~133.33px wide (400/3)
  -- Items should stretch to fill cells
  lu.assertAlmostEquals(item1.width, 133.33, 1)
  lu.assertAlmostEquals(item2.width, 133.33, 1)
  lu.assertAlmostEquals(item3.width, 133.33, 1)
end

-- ====================
-- Alignment Tests
-- ====================

function TestGridLayout:test_align_items_stretch()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 1,
    alignItems = enums.AlignItems.STRETCH,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item = Gui.new({
    parent = grid,
    width = 50,
  })

  -- Item should stretch to fill cell height (200/2 = 100)
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
    gridRows = 1,
    gridColumns = 3,
    columnGap = 10,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({ parent = grid, width = 50, height = 50 })
  local item2 = Gui.new({ parent = grid, width = 50, height = 50 })
  local item3 = Gui.new({ parent = grid, width = 50, height = 50 })

  -- Total width: 320, gaps: 2*10=20, available: 300, per cell: 100
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
    gridRows = 3,
    gridColumns = 1,
    columnGap = 0,
    rowGap = 10,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item1 = Gui.new({ parent = grid, width = 50, height = 50 })
  local item2 = Gui.new({ parent = grid, width = 50, height = 50 })
  local item3 = Gui.new({ parent = grid, width = 50, height = 50 })

  -- Total height: 320, gaps: 2*10=20, available: 300, per cell: 100
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
    gridRows = 2,
    gridColumns = 2,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local innerGrid = Gui.new({
    parent = outerGrid,
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  -- Add items to inner grid
  local item1 = Gui.new({ parent = innerGrid, width = 50, height = 50 })
  local item2 = Gui.new({ parent = innerGrid, width = 50, height = 50 })

  -- Inner grid should be stretched to fill outer grid cell (200x200)
  lu.assertAlmostEquals(innerGrid.width, 200, 1)
  lu.assertAlmostEquals(innerGrid.height, 200, 1)

  -- Items in inner grid should be positioned correctly
  -- Each cell in inner grid is 100x100
  lu.assertAlmostEquals(item1.x, 0, 1)
  lu.assertAlmostEquals(item1.y, 0, 1)
  lu.assertAlmostEquals(item2.x, 100, 1)
  lu.assertAlmostEquals(item2.y, 0, 1)
end

-- ====================
-- Edge Cases
-- ====================

function TestGridLayout:test_more_items_than_cells()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local items = {}
  for i = 1, 6 do
    items[i] = Gui.new({
      parent = grid,
      width = 50,
      height = 50,
    })
  end

  -- First 4 items should be positioned
  lu.assertAlmostEquals(items[1].x, 0, 1)
  lu.assertAlmostEquals(items[4].x, 100, 1)
  lu.assertAlmostEquals(items[4].y, 100, 1)

  -- Items 5 and 6 should not be laid out (remain at parent position)
  -- This is acceptable behavior - they're just not visible in the grid
end

function TestGridLayout:test_single_cell_grid()
  local grid = Gui.new({
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    positioning = enums.Positioning.GRID,
    gridRows = 1,
    gridColumns = 1,
    columnGap = 0,
    rowGap = 0,
    padding = { horizontal = 0, vertical = 0 },
  })

  local item = Gui.new({
    parent = grid,
    width = 50,
    height = 50,
  })

  -- Item should stretch to fill the entire grid
  lu.assertAlmostEquals(item.x, 0, 1)
  lu.assertAlmostEquals(item.y, 0, 1)
  lu.assertAlmostEquals(item.width, 100, 1)
  lu.assertAlmostEquals(item.height, 100, 1)
end

print("Running Simplified Grid Layout Tests...")
lu.LuaUnit.run()
