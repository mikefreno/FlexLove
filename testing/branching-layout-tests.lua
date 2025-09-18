package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for branching flex layouts
TestBranchingLayouts = {}

function TestBranchingLayouts:testMultipleChildrenAtSameLevel()
  -- Create a parent window with horizontal flex direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create first child with different properties
  local child1 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create second child with different properties
  local child2 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add children to first child (nested)
  local nestedChild1 = Gui.new({
    parent = child1,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local nestedChild2 = Gui.new({
    parent = child1,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Add children to second child (nested)
  local nestedChild3 = Gui.new({
    parent = child2,
    x = 0,
    y = 0,
    w = 70,
    h = 40,
    text = "Button 3",
  })

  local nestedChild4 = Gui.new({
    parent = child2,
    x = 0,
    y = 0,
    w = 80,
    h = 50,
    text = "Button 4",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the main children are positioned correctly
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, 0)

  luaunit.assertEquals(child2.x, 100)
  luaunit.assertEquals(child2.y, 0)

  -- Verify that nested children in first child are laid out correctly (vertical)
  luaunit.assertEquals(nestedChild1.x, 0)
  luaunit.assertEquals(nestedChild1.y, 0)

  luaunit.assertEquals(nestedChild2.x, 0)
  luaunit.assertEquals(nestedChild2.y, 30 + 10) -- Should be positioned after first child + gap

  -- Verify that nested children in second child are laid out correctly (centered vertically)
  luaunit.assertEquals(nestedChild3.x, 0)
  luaunit.assertEquals(nestedChild3.y, (100 - 40) / 2) -- Should be centered vertically

  luaunit.assertEquals(nestedChild4.x, 0)
  luaunit.assertEquals(nestedChild4.y, (100 - 50) / 2 + 40 + 10) -- Should be positioned after first child + gap
end

function TestBranchingLayouts:testAsymmetricBranchingStructure()
  -- Create a parent window with horizontal flex direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 400,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a child with 3 branches - different sizes
  local branch1 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local branch2 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
  })

  local branch3 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_END,
    alignItems = enums.AlignItems.FLEX_END,
  })

  -- Add children to each branch with different sizes
  local child1_1 = Gui.new({
    parent = branch1,
    x = 0,
    y = 0,
    w = 50,
    h = 20,
    text = "Button 1",
  })

  local child1_2 = Gui.new({
    parent = branch1,
    x = 0,
    y = 0,
    w = 60,
    h = 30,
    text = "Button 2",
  })

  -- Add children to second branch
  local child2_1 = Gui.new({
    parent = branch2,
    x = 0,
    y = 0,
    w = 70,
    h = 40,
    text = "Button 3",
  })

  local child2_2 = Gui.new({
    parent = branch2,
    x = 0,
    y = 0,
    w = 80,
    h = 50,
    text = "Button 4",
  })

  local child2_3 = Gui.new({
    parent = branch2,
    x = 0,
    y = 0,
    w = 90,
    h = 60,
    text = "Button 5",
  })

  -- Add children to third branch
  local child3_1 = Gui.new({
    parent = branch3,
    x = 0,
    y = 0,
    w = 70,
    h = 40,
    text = "Button 6",
  })

  local child3_2 = Gui.new({
    parent = branch3,
    x = 0,
    y = 0,
    w = 80,
    h = 50,
    text = "Button 7",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the branches are positioned correctly
  luaunit.assertEquals(branch1.x, 0)
  luaunit.assertEquals(branch1.y, 0)

  luaunit.assertEquals(branch2.x, 100)
  luaunit.assertEquals(branch2.y, 0)

  luaunit.assertEquals(branch3.x, 250)
  luaunit.assertEquals(branch3.y, 0)

  -- Verify that children in first branch are laid out correctly (flex-start)
  luaunit.assertEquals(child1_1.x, 0)
  luaunit.assertEquals(child1_1.y, 0)

  luaunit.assertEquals(child1_2.x, 0)
  luaunit.assertEquals(child1_2.y, 20 + 10) -- Should be positioned after first child + gap

  -- Verify that children in second branch are laid out correctly (centered)
  luaunit.assertEquals(child2_1.x, 0)
  luaunit.assertEquals(child2_1.y, (100 - 40) / 2) -- Should be centered vertically

  luaunit.assertEquals(child2_2.x, 0)
  luaunit.assertEquals(child2_2.y, (100 - 50) / 2 + 40 + 10) -- Should be positioned after first child + gap

  luaunit.assertEquals(child2_3.x, 0)
  luaunit.assertEquals(child2_3.y, (100 - 60) / 2 + 40 + 10 + 50 + 10) -- Should be positioned after second child + gap

  -- Verify that children in third branch are laid out correctly (flex-end)
  luaunit.assertEquals(child3_1.x, 0)
  luaunit.assertEquals(child3_1.y, 100 - 40) -- Should be at bottom position

  luaunit.assertEquals(child3_2.x, 0)
  luaunit.assertEquals(child3_2.y, 100 - 50 - 10) -- Should be positioned after first child + gap
end

function TestBranchingLayouts:testMixedFlexDirectionInBranches()
  -- Create a parent window with horizontal flex direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 400,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a child branch with horizontal direction
  local horizontalBranch = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 200,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a child branch with vertical direction
  local verticalBranch = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 200,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add children to horizontal branch
  local child1 = Gui.new({
    parent = horizontalBranch,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = horizontalBranch,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Add children to vertical branch
  local child3 = Gui.new({
    parent = verticalBranch,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 3",
  })

  local child4 = Gui.new({
    parent = verticalBranch,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 4",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the branches are positioned correctly
  luaunit.assertEquals(horizontalBranch.x, 0)
  luaunit.assertEquals(horizontalBranch.y, 0)

  luaunit.assertEquals(verticalBranch.x, 200)
  luaunit.assertEquals(verticalBranch.y, 0)

  -- Verify that children in horizontal branch are laid out horizontally
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, 0)

  luaunit.assertEquals(child2.x, 50 + 10) -- Should be positioned after first child + gap
  luaunit.assertEquals(child2.y, 0)

  -- Verify that children in vertical branch are laid out vertically
  luaunit.assertEquals(child3.x, 0)
  luaunit.assertEquals(child3.y, 0)

  luaunit.assertEquals(child4.x, 0)
  luaunit.assertEquals(child4.y, 30 + 10) -- Should be positioned after first child + gap
end

function TestBranchingLayouts:testCrossBranchAlignmentCoordination()
  -- Create a parent window with horizontal flex direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 400,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Create a child branch with different alignment
  local branch1 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create another child branch with different alignment
  local branch2 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add children to first branch
  local child1_1 = Gui.new({
    parent = branch1,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child1_2 = Gui.new({
    parent = branch1,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Add children to second branch
  local child2_1 = Gui.new({
    parent = branch2,
    x = 0,
    y = 0,
    w = 70,
    h = 30,
    text = "Button 3",
  })

  local child2_2 = Gui.new({
    parent = branch2,
    x = 0,
    y = 0,
    w = 80,
    h = 40,
    text = "Button 4",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the branches are positioned correctly with space between
  luaunit.assertEquals(branch1.x, 0)
  luaunit.assertEquals(branch1.y, (300 - 150) / 2) -- Should be centered vertically

  luaunit.assertEquals(branch2.x, 250)
  luaunit.assertEquals(branch2.y, (300 - 150) / 2) -- Should be centered vertically

  -- Verify that children in first branch are laid out with stretch alignment
  luaunit.assertEquals(child1_1.x, 0)
  luaunit.assertEquals(child1_1.y, 0)

  luaunit.assertEquals(child1_2.x, 0)
  luaunit.assertEquals(child1_2.y, 30 + 10) -- Should be positioned after first child + gap

  -- Verify that children in second branch are laid out with center alignment
  luaunit.assertEquals(child2_1.x, (150 - 70) / 2) -- Should be centered horizontally
  luaunit.assertEquals(child2_1.y, 0)

  luaunit.assertEquals(child2_2.x, (150 - 80) / 2) -- Should be centered horizontally
  luaunit.assertEquals(child2_2.y, 30 + 10) -- Should be positioned after first child + gap
end

-- Run the tests
luaunit.LuaUnit.run()

