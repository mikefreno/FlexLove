package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")

TestGridLayout = {}

function TestGridLayout:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestGridLayout:tearDown()
  FlexLove.endFrame()
end

-- Test basic grid layout with default 1x1 grid
function TestGridLayout:test_default_grid_single_child()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 300,
    positioning = "grid",
    -- Default: gridRows=1, gridColumns=1
  })

  local child = FlexLove.new({
    id = "child1",
    parent = container,
    width = 50, -- Will be stretched by grid
    height = 50,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Child should be stretched to fill the entire grid cell
  luaunit.assertEquals(child.x, 0, "Child should be at x=0")
  luaunit.assertEquals(child.y, 0, "Child should be at y=0")
  luaunit.assertEquals(child.width, 400, "Child should be stretched to container width")
  luaunit.assertEquals(child.height, 300, "Child should be stretched to container height")
end

-- Test 2x2 grid layout
function TestGridLayout:test_2x2_grid_four_children()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
  })

  local children = {}
  for i = 1, 4 do
    children[i] = FlexLove.new({
      id = "child" .. i,
      parent = container,
      width = 50,
      height = 50,
    })
  end

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Each cell should be 200x200
  -- Child 1: top-left (0, 0)
  luaunit.assertEquals(children[1].x, 0, "Child 1 should be at x=0")
  luaunit.assertEquals(children[1].y, 0, "Child 1 should be at y=0")
  luaunit.assertEquals(children[1].width, 200, "Cell width should be 200")
  luaunit.assertEquals(children[1].height, 200, "Cell height should be 200")

  -- Child 2: top-right (200, 0)
  luaunit.assertEquals(children[2].x, 200, "Child 2 should be at x=200")
  luaunit.assertEquals(children[2].y, 0, "Child 2 should be at y=0")

  -- Child 3: bottom-left (0, 200)
  luaunit.assertEquals(children[3].x, 0, "Child 3 should be at x=0")
  luaunit.assertEquals(children[3].y, 200, "Child 3 should be at y=200")

  -- Child 4: bottom-right (200, 200)
  luaunit.assertEquals(children[4].x, 200, "Child 4 should be at x=200")
  luaunit.assertEquals(children[4].y, 200, "Child 4 should be at y=200")
end

-- Test grid with column and row gaps
function TestGridLayout:test_grid_with_gaps()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 420, -- 2 cells * 200 + 1 gap * 20
    height = 320, -- 2 cells * 150 + 1 gap * 20
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    columnGap = 20,
    rowGap = 20,
  })

  local children = {}
  for i = 1, 4 do
    children[i] = FlexLove.new({
      id = "child" .. i,
      parent = container,
      width = 50,
      height = 50,
    })
  end

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Cell size: (420 - 20) / 2 = 200, (320 - 20) / 2 = 150
  luaunit.assertEquals(children[1].width, 200, "Cell width should be 200")
  luaunit.assertEquals(children[1].height, 150, "Cell height should be 150")

  -- Child 2 should be offset by cell width + gap
  luaunit.assertEquals(children[2].x, 220, "Child 2 x = 200 + 20 gap")
  luaunit.assertEquals(children[2].y, 0, "Child 2 should be at y=0")

  -- Child 3 should be offset by cell height + gap
  luaunit.assertEquals(children[3].x, 0, "Child 3 should be at x=0")
  luaunit.assertEquals(children[3].y, 170, "Child 3 y = 150 + 20 gap")
end

-- Test grid with more children than cells (overflow)
function TestGridLayout:test_grid_overflow_children()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 200,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    -- Only 4 cells available
  })

  local children = {}
  for i = 1, 6 do -- 6 children, but only 4 cells
    children[i] = FlexLove.new({
      id = "child" .. i,
      parent = container,
      width = 50,
      height = 50,
    })
  end

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- First 4 children should be positioned
  luaunit.assertNotNil(children[1].x, "Child 1 should be positioned")
  luaunit.assertNotNil(children[4].x, "Child 4 should be positioned")

  -- Children 5 and 6 should NOT be positioned (or positioned at 0,0 by default)
  -- This tests the overflow behavior: row >= rows breaks the loop
end

-- Test grid with alignItems center
function TestGridLayout:test_grid_align_center()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    alignItems = "center",
  })

  local child = FlexLove.new({
    id = "child1",
    parent = container,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Cell is 200x200, child is 100x100, should be centered
  -- Center position: (200 - 100) / 2 = 50
  luaunit.assertEquals(child.x, 50, "Child should be centered horizontally in cell")
  luaunit.assertEquals(child.y, 50, "Child should be centered vertically in cell")
  luaunit.assertEquals(child.width, 100, "Child width should not be stretched")
  luaunit.assertEquals(child.height, 100, "Child height should not be stretched")
end

-- Test grid with alignItems flex-start
function TestGridLayout:test_grid_align_flex_start()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    alignItems = "flex-start",
  })

  local child = FlexLove.new({
    id = "child1",
    parent = container,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Child should be at top-left of cell
  luaunit.assertEquals(child.x, 0, "Child should be at left of cell")
  luaunit.assertEquals(child.y, 0, "Child should be at top of cell")
  luaunit.assertEquals(child.width, 100, "Child width should not be stretched")
  luaunit.assertEquals(child.height, 100, "Child height should not be stretched")
end

-- Test grid with alignItems flex-end
function TestGridLayout:test_grid_align_flex_end()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    alignItems = "flex-end",
  })

  local child = FlexLove.new({
    id = "child1",
    parent = container,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Cell is 200x200, child is 100x100, should be at bottom-right
  luaunit.assertEquals(child.x, 100, "Child should be at right of cell (200 - 100)")
  luaunit.assertEquals(child.y, 100, "Child should be at bottom of cell (200 - 100)")
  luaunit.assertEquals(child.width, 100, "Child width should not be stretched")
  luaunit.assertEquals(child.height, 100, "Child height should not be stretched")
end

-- Test grid with padding
function TestGridLayout:test_grid_with_padding()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 500, -- Total width
    height = 500,
    padding = { top = 50, right = 50, bottom = 50, left = 50 },
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
  })

  local child = FlexLove.new({
    id = "child1",
    parent = container,
    width = 50,
    height = 50,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Available space: 500 - 50 - 50 = 400
  -- Cell size: 400 / 2 = 200
  -- Child should be positioned at padding.left, padding.top
  luaunit.assertEquals(child.x, 50, "Child x should account for left padding")
  luaunit.assertEquals(child.y, 50, "Child y should account for top padding")
  luaunit.assertEquals(child.width, 200, "Cell width should be 200")
  luaunit.assertEquals(child.height, 200, "Cell height should be 200")
end

-- Test grid with absolutely positioned child (should be skipped in grid layout)
function TestGridLayout:test_grid_with_absolute_child()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
  })

  -- Regular child
  local child1 = FlexLove.new({
    id = "child1",
    parent = container,
    width = 50,
    height = 50,
  })

  -- Absolutely positioned child (should be ignored by grid layout)
  local child2 = FlexLove.new({
    id = "child2",
    parent = container,
    positioning = "absolute",
    x = 10,
    y = 10,
    width = 30,
    height = 30,
  })

  -- Another regular child
  local child3 = FlexLove.new({
    id = "child3",
    parent = container,
    width = 50,
    height = 50,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- child1 should be in first grid cell (0, 0)
  luaunit.assertEquals(child1.x, 0, "Child 1 should be at x=0")
  luaunit.assertEquals(child1.y, 0, "Child 1 should be at y=0")

  -- child2 should keep its absolute position
  luaunit.assertEquals(child2.x, 10, "Absolute child should keep x=10")
  luaunit.assertEquals(child2.y, 10, "Absolute child should keep y=10")

  -- child3 should be in second grid cell (200, 0), not third
  luaunit.assertEquals(child3.x, 200, "Child 3 should be in second cell at x=200")
  luaunit.assertEquals(child3.y, 0, "Child 3 should be in second cell at y=0")
end

-- Test edge case: empty grid
function TestGridLayout:test_empty_grid()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    -- No children
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Should not crash
  luaunit.assertEquals(#container.children, 0, "Grid should have no children")
end

-- Test edge case: grid with 0 columns or rows
function TestGridLayout:test_grid_zero_dimensions()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 0, -- Invalid: 0 rows
    gridColumns = 0, -- Invalid: 0 columns
  })

  local child = FlexLove.new({
    id = "child1",
    parent = container,
    width = 50,
    height = 50,
  })

  -- This might cause division by zero or other errors
  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Test passes if it doesn't crash
  luaunit.assertTrue(true, "Grid with 0 dimensions should not crash")
end

-- Test nested grids
function TestGridLayout:test_nested_grids()
  local outerGrid = FlexLove.new({
    id = "outer",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
  })

  -- First cell contains another grid
  local innerGrid = FlexLove.new({
    id = "inner",
    parent = outerGrid,
    width = 200,
    height = 200,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
  })

  -- Add children to inner grid
  for i = 1, 4 do
    FlexLove.new({
      id = "inner_child" .. i,
      parent = innerGrid,
      width = 25,
      height = 25,
    })
  end

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Inner grid should be positioned in first cell of outer grid
  luaunit.assertEquals(innerGrid.x, 0, "Inner grid should be at x=0")
  luaunit.assertEquals(innerGrid.y, 0, "Inner grid should be at y=0")
  luaunit.assertEquals(#innerGrid.children, 4, "Inner grid should have 4 children")
end

-- Test grid with reserved space from absolute children
function TestGridLayout:test_grid_with_reserved_space()
  local container = FlexLove.new({
    id = "grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
  })

  -- Absolute child with left positioning (reserves left space)
  FlexLove.new({
    id = "absolute_left",
    parent = container,
    positioning = "absolute",
    left = 0,
    top = 0,
    width = 50,
    height = 50,
  })

  -- Regular grid child
  local child1 = FlexLove.new({
    id = "child1",
    parent = container,
    width = 50,
    height = 50,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Grid should account for reserved space
  -- Available width: 400 - 50 (reserved left) = 350
  -- Cell width: 350 / 2 = 175
  -- Child should start at x = reserved left = 50
  luaunit.assertEquals(child1.x, 50, "Child should be offset by reserved left space")
  luaunit.assertEquals(child1.width, 175, "Cell width should account for reserved space")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
