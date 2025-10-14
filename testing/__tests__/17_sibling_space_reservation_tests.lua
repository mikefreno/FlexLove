-- Test: Sibling Space Reservation in Flex and Grid Layouts
-- Purpose: Verify that absolutely positioned siblings with explicit positioning
--          properly reserve space in flex and grid containers
package.path = package.path .. ";?.lua"

local lu = require("testing.luaunit")
require("testing.loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

TestSiblingSpaceReservation = {}

function TestSiblingSpaceReservation:setUp()
  -- Reset GUI state before each test
  Gui.destroy()
  -- Set up a standard viewport
  love.window.setMode(1920, 1080)
end

function TestSiblingSpaceReservation:tearDown()
  Gui.destroy()
end

-- ====================
-- Flex Layout Tests
-- ====================

function TestSiblingSpaceReservation:test_flex_horizontal_left_positioned_sibling_reserves_space()
  -- Create a flex container
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "flex-start",
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Add an absolutely positioned sibling with left positioning
  local absoluteSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    left = 10, -- 10px from left edge
    width = 50,
    height = 50,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  -- Add a flex child that should start after the absolutely positioned sibling
  local flexChild = Gui.new({
    parent = container,
    width = 100,
    height = 50,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- The absolutely positioned sibling reserves: left (10) + width (50) + padding (0) = 60px
  -- The flex child should start at x = container.x + padding.left + reservedLeft
  -- = 0 + 0 + 60 = 60
  lu.assertEquals(flexChild.x, 60, "Flex child should start after absolutely positioned sibling")
end

function TestSiblingSpaceReservation:test_flex_horizontal_right_positioned_sibling_reserves_space()
  -- Create a flex container
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "flex-start",
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Add an absolutely positioned sibling with right positioning
  local absoluteSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    right = 10, -- 10px from right edge
    width = 50,
    height = 50,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  -- Add a flex child
  local flexChild = Gui.new({
    parent = container,
    width = 100,
    height = 50,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- The absolutely positioned sibling reserves: right (10) + width (50) + padding (0) = 60px
  -- Available space = 1000 - 0 (padding) - 0 (reservedLeft) - 60 (reservedRight) = 940px
  -- The flex child (width 100) should fit within this space
  -- Child should start at x = 0
  lu.assertEquals(flexChild.x, 0, "Flex child should start at container left edge")

  -- The absolutely positioned sibling should be at the right edge
  -- x = container.x + container.width + padding.left - right - (width + padding)
  -- = 0 + 1000 + 0 - 10 - 50 = 940
  lu.assertEquals(absoluteSibling.x, 940, "Absolutely positioned sibling should be at right edge")
end

function TestSiblingSpaceReservation:test_flex_vertical_top_positioned_sibling_reserves_space()
  -- Create a vertical flex container
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 1000,
    positioning = "flex",
    flexDirection = "vertical",
    justifyContent = "flex-start",
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Add an absolutely positioned sibling with top positioning
  local absoluteSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    top = 10, -- 10px from top edge
    width = 50,
    height = 50,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  -- Add a flex child that should start after the absolutely positioned sibling
  local flexChild = Gui.new({
    parent = container,
    width = 50,
    height = 100,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- The absolutely positioned sibling reserves: top (10) + height (50) + padding (0) = 60px
  -- The flex child should start at y = container.y + padding.top + reservedTop
  -- = 0 + 0 + 60 = 60
  lu.assertEquals(flexChild.y, 60, "Flex child should start after absolutely positioned sibling")
end

function TestSiblingSpaceReservation:test_flex_horizontal_multiple_positioned_siblings()
  -- Create a flex container
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "flex-start",
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Add two absolutely positioned siblings (left and right)
  local leftSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    left = 5,
    width = 40,
    height = 50,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  local rightSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    right = 5,
    width = 40,
    height = 50,
    backgroundColor = Color.new(0, 0, 1, 1),
  })

  -- Add flex children
  local flexChild1 = Gui.new({
    parent = container,
    width = 100,
    height = 50,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  local flexChild2 = Gui.new({
    parent = container,
    width = 100,
    height = 50,
    backgroundColor = Color.new(0, 1, 1, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- Reserved left: 5 + 40 = 45px
  -- Reserved right: 5 + 40 = 45px
  -- Available space: 1000 - 45 - 45 = 910px
  -- First flex child should start at x = 0 + 0 + 45 = 45
  lu.assertEquals(flexChild1.x, 45, "First flex child should start after left sibling")

  -- Second flex child should start at x = 45 + 100 + gap = 145 (assuming gap=10)
  lu.assertIsTrue(flexChild2.x >= 145, "Second flex child should be positioned after first")
end

-- ====================
-- Grid Layout Tests
-- ====================

function TestSiblingSpaceReservation:test_grid_left_positioned_sibling_reserves_space()
  -- Create a grid container
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 500,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 3,
    columnGap = 10,
    rowGap = 10,
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Add an absolutely positioned sibling with left positioning
  local absoluteSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    left = 10,
    width = 50,
    height = 50,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  -- Add grid children
  local gridChild1 = Gui.new({
    parent = container,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- Reserved left: 10 + 50 = 60px
  -- Available width: 1000 - 60 = 940px
  -- Column gaps: 2 * 10 = 20px
  -- Cell width: (940 - 20) / 3 = 306.67px
  -- First grid child should start at x = 0 + 0 + 60 = 60
  lu.assertEquals(gridChild1.x, 60, "Grid child should start after absolutely positioned sibling")
end

function TestSiblingSpaceReservation:test_grid_top_positioned_sibling_reserves_space()
  -- Create a grid container
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 500,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 3,
    columnGap = 10,
    rowGap = 10,
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Add an absolutely positioned sibling with top positioning
  local absoluteSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    top = 10,
    width = 50,
    height = 50,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  -- Add grid children
  local gridChild1 = Gui.new({
    parent = container,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- Reserved top: 10 + 50 = 60px
  -- Available height: 500 - 60 = 440px
  -- Row gaps: 1 * 10 = 10px
  -- Cell height: (440 - 10) / 2 = 215px
  -- First grid child should start at y = 0 + 0 + 60 = 60
  lu.assertEquals(gridChild1.y, 60, "Grid child should start after absolutely positioned sibling")
end

function TestSiblingSpaceReservation:test_grid_multiple_positioned_siblings()
  -- Create a grid container
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 500,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    columnGap = 0,
    rowGap = 0,
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Add absolutely positioned siblings at all corners
  local topLeftSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    left = 10,
    top = 10,
    width = 40,
    height = 40,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  local bottomRightSibling = Gui.new({
    parent = container,
    positioning = "absolute",
    right = 10,
    bottom = 10,
    width = 40,
    height = 40,
    backgroundColor = Color.new(0, 0, 1, 1),
  })

  -- Add grid children
  local gridChild1 = Gui.new({
    parent = container,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- Reserved left: 10 + 40 = 50px
  -- Reserved right: 10 + 40 = 50px
  -- Reserved top: 10 + 40 = 50px
  -- Reserved bottom: 10 + 40 = 50px
  -- Available width: 1000 - 50 - 50 = 900px
  -- Available height: 500 - 50 - 50 = 400px
  -- Cell width: 900 / 2 = 450px
  -- Cell height: 400 / 2 = 200px
  -- First grid child should start at (50, 50)
  lu.assertEquals(gridChild1.x, 50, "Grid child X should account for left sibling")
  lu.assertEquals(gridChild1.y, 50, "Grid child Y should account for top sibling")
  lu.assertEquals(gridChild1.width, 450, "Grid cell width should account for reserved space")
  lu.assertEquals(gridChild1.height, 200, "Grid cell height should account for reserved space")
end

-- ====================
-- Edge Cases
-- ====================

function TestSiblingSpaceReservation:test_non_explicitly_absolute_children_dont_reserve_space()
  -- Children that default to absolute positioning (not explicitly set)
  -- should NOT reserve space in flex layouts
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- This child has positioning="flex" so it participates in layout
  local flexChild = Gui.new({
    parent = container,
    positioning = "flex",
    left = 10, -- This should be ignored since it's a flex child
    width = 100,
    height = 50,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- Flex child should start at x = 0 (no reserved space)
  lu.assertEquals(flexChild.x, 0, "Flex children with positioning offsets should not reserve space")
end

function TestSiblingSpaceReservation:test_absolute_without_positioning_offsets_doesnt_reserve_space()
  -- Absolutely positioned children without left/right/top/bottom
  -- should NOT reserve space
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 1000,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
  })

  -- Absolutely positioned but no positioning offsets
  local absoluteChild = Gui.new({
    parent = container,
    positioning = "absolute",
    x = 50,
    y = 50,
    width = 50,
    height = 50,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  -- Flex child
  local flexChild = Gui.new({
    parent = container,
    width = 100,
    height = 50,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- Layout children
  container:layoutChildren()

  -- Flex child should start at x = 0 (no reserved space)
  lu.assertEquals(flexChild.x, 0, "Absolute children without positioning offsets should not reserve space")
end

print("Running Sibling Space Reservation Tests...")
lu.LuaUnit.run()
