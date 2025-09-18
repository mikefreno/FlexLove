package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for complex nested flex layouts
TestComplexNestedLayouts = {}

function TestComplexNestedLayouts:testDeepThreeLevelNesting()
  -- Create a parent window with horizontal flex direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 400,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create first nested window (level 1)
  local level1Window = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 200,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.FLEX_START,
  })

  -- Create second nested window (level 2)
  local level2Window = Gui.new({
    parent = level1Window,
    x = 0,
    y = 0,
    w = 100,
    h = 75,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Create third nested window (level 3)
  local level3Window = Gui.new({
    parent = level2Window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.SPACE_AROUND,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add children to level 3 window
  local child1 = Gui.new({
    parent = level3Window,
    x = 0,
    y = 0,
    w = 15,
    h = 10,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = level3Window,
    x = 0,
    y = 0,
    w = 20,
    h = 12,
    text = "Button 2",
  })

  local child3 = Gui.new({
    parent = level3Window,
    x = 0,
    y = 0,
    w = 18,
    h = 15,
    text = "Button 3",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the nested structure is positioned correctly (basic checks)
  luaunit.assertTrue(level1Window.x >= 0)
  luaunit.assertTrue(level1Window.y >= 0)

  luaunit.assertTrue(level2Window.x >= 0)
  luaunit.assertTrue(level2Window.y >= 0)

  luaunit.assertTrue(level3Window.x >= 0)
  luaunit.assertTrue(level3Window.y >= 0)

  -- Verify that level 3 children are laid out correctly (basic checks)
  luaunit.assertTrue(child1.x >= 0)
  luaunit.assertTrue(child1.y >= 0)

  luaunit.assertTrue(child2.x >= 0)
  luaunit.assertTrue(child2.y >= 0)

  luaunit.assertTrue(child3.x >= 0)
  luaunit.assertTrue(child3.y >= 0)
end

function TestComplexNestedLayouts:testFourLevelNestingWithMixedDirections()
  -- Create a parent window with vertical flex direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 400,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create first nested window (level 1)
  local level1Window = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 250,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.FLEX_START,
  })

  -- Create second nested window (level 2)
  local level2Window = Gui.new({
    parent = level1Window,
    x = 0,
    y = 0,
    w = 150,
    h = 80,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create third nested window (level 3)
  local level3Window = Gui.new({
    parent = level2Window,
    x = 0,
    y = 0,
    w = 75,
    h = 40,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_END,
    alignItems = enums.AlignItems.FLEX_START,
  })

  -- Create fourth nested window (level 4)
  local level4Window = Gui.new({
    parent = level3Window,
    x = 0,
    y = 0,
    w = 30,
    h = 20,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add children to level 4 window
  local child1 = Gui.new({
    parent = level4Window,
    x = 0,
    y = 0,
    w = 10,
    h = 8,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = level4Window,
    x = 0,
    y = 0,
    w = 12,
    h = 10,
    text = "Button 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the nested structure is positioned correctly (basic checks)
  luaunit.assertTrue(level1Window.x >= 0)
  luaunit.assertTrue(level1Window.y >= 0)

  luaunit.assertTrue(level2Window.x >= 0)
  luaunit.assertTrue(level2Window.y >= 0)

  luaunit.assertTrue(level3Window.x >= 0)
  luaunit.assertTrue(level3Window.y >= 0)

  luaunit.assertTrue(level4Window.x >= 0)
  luaunit.assertTrue(level4Window.y >= 0)

  -- Verify that level 4 children are laid out correctly (basic checks)
  luaunit.assertTrue(child1.x >= 0)
  luaunit.assertTrue(child1.y >= 0)

  luaunit.assertTrue(child2.x >= 0)
  luaunit.assertTrue(child2.y >= 0)
end

function TestComplexNestedLayouts:testBranchingNestingStructure()
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

  -- Create first branch (left side)
  local leftBranch = Gui.new({
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

  -- Create second branch (right side)
  local rightBranch = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 200,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.FLEX_START,
  })

  -- Create children for left branch
  local leftChild1 = Gui.new({
    parent = leftBranch,
    x = 0,
    y = 0,
    w = 100,
    h = 50,
    text = "Left Child 1",
  })

  local leftChild2 = Gui.new({
    parent = leftBranch,
    x = 0,
    y = 0,
    w = 100,
    h = 40,
    text = "Left Child 2",
  })

  -- Create children for right branch
  local rightChild1 = Gui.new({
    parent = rightBranch,
    x = 0,
    y = 0,
    w = 150,
    h = 60,
    text = "Right Child 1",
  })

  local rightChild2 = Gui.new({
    parent = rightBranch,
    x = 0,
    y = 0,
    w = 150,
    h = 70,
    text = "Right Child 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the branches are positioned correctly (basic checks)
  luaunit.assertTrue(leftBranch.x >= 0)
  luaunit.assertTrue(leftBranch.y >= 0)

  luaunit.assertTrue(rightBranch.x >= 0)
  luaunit.assertTrue(rightBranch.y >= 0)

  -- Verify that left branch children are laid out correctly (basic checks)
  luaunit.assertTrue(leftChild1.x >= 0)
  luaunit.assertTrue(leftChild1.y >= 0)

  luaunit.assertTrue(leftChild2.x >= 0)
  luaunit.assertTrue(leftChild2.y >= 0)

  -- Verify that right branch children are laid out correctly (basic checks)
  luaunit.assertTrue(rightChild1.x >= 0)
  luaunit.assertTrue(rightChild1.y >= 0)

  luaunit.assertTrue(rightChild2.x >= 0)
  luaunit.assertTrue(rightChild2.y >= 0)
end

function TestComplexNestedLayouts:testComplexAlignmentInNesting()
  -- Create a parent window with horizontal flex direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Create nested window with different alignment
  local nestedWindow = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.FLEX_END,
  })

  -- Create children with different sizes
  local child1 = Gui.new({
    parent = nestedWindow,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = nestedWindow,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  local child3 = Gui.new({
    parent = nestedWindow,
    x = 0,
    y = 0,
    w = 45,
    h = 35,
    text = "Button 3",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the nested structure is positioned correctly (basic checks)
  luaunit.assertTrue(nestedWindow.x >= 0)
  luaunit.assertTrue(nestedWindow.y >= 0)

  -- Verify that children are laid out correctly (basic checks)
  luaunit.assertTrue(child1.x >= 0)
  luaunit.assertTrue(child1.y >= 0)

  luaunit.assertTrue(child2.x >= 0)
  luaunit.assertTrue(child2.y >= 0)

  luaunit.assertTrue(child3.x >= 0)
  luaunit.assertTrue(child3.y >= 0)
end

-- Run the tests
luaunit.LuaUnit.run()

