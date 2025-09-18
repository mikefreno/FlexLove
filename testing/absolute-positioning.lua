package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for absolute positioning behavior with complex nested layouts
TestAbsolutePositioning = {}

function TestAbsolutePositioning:testDeeplyNestedAbsolutePositioning()
  -- Create a root window with flex positioning
  local rootWindow = Gui.new({
    x = 0,
    y = 0,
    w = 800,
    h = 600,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a nested flex container
  local nestedFlexContainer = Gui.new({
    parent = rootWindow,
    x = 100,
    y = 50,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create an absolute positioned child in nested container
  local absoluteChildInNested = Gui.new({
    parent = nestedFlexContainer,
    x = 20,
    y = 30,
    w = 80,
    h = 40,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Nested Absolute",
  })

  -- Create another flex child in nested container
  local flexChildInNested = Gui.new({
    parent = nestedFlexContainer,
    x = 0,
    y = 0,
    w = 60,
    h = 30,
    text = "Nested Flex",
  })

  -- Layout all children
  rootWindow:layoutChildren()

  -- Verify absolute child position is correct (relative to parent)
  -- Absolute positioning should be relative to the parent container's origin
  luaunit.assertEquals(absoluteChildInNested.x, nestedFlexContainer.x + absoluteChildInNested.x)
  luaunit.assertEquals(absoluteChildInNested.y, nestedFlexContainer.y + absoluteChildInNested.y)

  -- Verify flex child position is calculated correctly within nested container
  -- Flex children should be positioned by flex layout rules (not affected by absolute positioning of others)
  luaunit.assertAlmostEquals(flexChildInNested.x, 0) -- Should be at start of container
  luaunit.assertAlmostEquals(flexChildInNested.y, (nestedFlexContainer.height - flexChildInNested.height)/2) -- Should be centered vertically in container

  -- Verify parent-child relationships
  luaunit.assertEquals(#nestedFlexContainer.children, 2)
  luaunit.assertEquals(nestedFlexContainer.children[1], absoluteChildInNested)
  luaunit.assertEquals(nestedFlexContainer.children[2], flexChildInNested)
end

function TestAbsolutePositioning:testMixedLayoutTypesWithNesting()
  -- Create a complex nested structure with mixed layout types
  local rootWindow = Gui.new({
    x = 0,
    y = 0,
    w = 800,
    h = 600,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a flex container with absolute positioning
  local flexContainerWithAbsolute = Gui.new({
    parent = rootWindow,
    x = 0,
    y = 0,
    w = 400,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add absolute positioned child to flex container
  local absoluteChild1 = Gui.new({
    parent = flexContainerWithAbsolute,
    x = 50,
    y = 20,
    w = 60,
    h = 30,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Abs Child 1",
  })

  -- Add nested absolute positioned child
  local nestedAbsoluteChild = Gui.new({
    parent = flexContainerWithAbsolute,
    x = 100,
    y = 100,
    w = 40,
    h = 20,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Nested Abs",
  })

  -- Add regular flex child
  local flexChild = Gui.new({
    parent = flexContainerWithAbsolute,
    x = 0,
    y = 0,
    w = 80,
    h = 40,
    text = "Flex Child",
  })

  -- Layout children
  rootWindow:layoutChildren()

  -- Verify absolute positions are correct (relative to parent)
  luaunit.assertEquals(absoluteChild1.x, flexContainerWithAbsolute.x + absoluteChild1.x)
  luaunit.assertEquals(absoluteChild1.y, flexContainerWithAbsolute.y + absoluteChild1.y)
  luaunit.assertEquals(nestedAbsoluteChild.x, flexContainerWithAbsolute.x + nestedAbsoluteChild.x)
  luaunit.assertEquals(nestedAbsoluteChild.y, flexContainerWithAbsolute.y + nestedAbsoluteChild.y)

  -- Verify flex child is positioned by flex layout (not affected by absolute positioning)
  -- First flex child in space-between should be at start
  luaunit.assertAlmostEquals(flexChild.x, 0)
end

function TestAbsolutePositioning:testAbsolutePositioningInComplexBranchingStructure()
  -- Create a complex branching structure with multiple absolute positions
  local rootWindow = Gui.new({
    x = 0,
    y = 0,
    w = 800,
    h = 600,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create three branches with different absolute positions
  local branch1 = Gui.new({
    parent = rootWindow,
    x = 0,
    y = 0,
    w = 200,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local branch2 = Gui.new({
    parent = rootWindow,
    x = 250,
    y = 100,
    w = 200,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local branch3 = Gui.new({
    parent = rootWindow,
    x = 500,
    y = 200,
    w = 200,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add absolute positioned children to each branch
  local absChild1 = Gui.new({
    parent = branch1,
    x = 10,
    y = 15,
    w = 50,
    h = 20,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Branch1 Abs",
  })

  local absChild2 = Gui.new({
    parent = branch2,
    x = 20,
    y = 30,
    w = 60,
    h = 25,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Branch2 Abs",
  })

  local absChild3 = Gui.new({
    parent = branch3,
    x = 30,
    y = 40,
    w = 70,
    h = 30,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Branch3 Abs",
  })

  -- Add regular children to branches
  local regularChild1 = Gui.new({
    parent = branch1,
    x = 0,
    y = 0,
    w = 40,
    h = 25,
    text = "Branch1 Regular",
  })

  local regularChild2 = Gui.new({
    parent = branch2,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Branch2 Regular",
  })

  -- Layout all children
  rootWindow:layoutChildren()

  -- Verify absolute positions in each branch (absolute position relative to branch parent)
  luaunit.assertEquals(absChild1.x, branch1.x + absChild1.x)
  luaunit.assertEquals(absChild1.y, branch1.y + absChild1.y)
  luaunit.assertEquals(absChild2.x, branch2.x + absChild2.x)
  luaunit.assertEquals(absChild2.y, branch2.y + absChild2.y)
  luaunit.assertEquals(absChild3.x, branch3.x + absChild3.x)
  luaunit.assertEquals(absChild3.y, branch3.y + absChild3.y)

  -- Verify that regular children are positioned by flex layout
  luaunit.assertAlmostEquals(regularChild1.x, 0)
  luaunit.assertAlmostEquals(regularChild2.x, 0)
end

function TestAbsolutePositioning:testAbsolutePositioningWithComplexTransformations()
  -- Create a complex structure with transformations and absolute positioning
  local rootWindow = Gui.new({
    x = 100,
    y = 50,
    w = 600,
    h = 400,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a container with padding and margin
  local containerWithPadding = Gui.new({
    parent = rootWindow,
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_AROUND,
    alignItems = enums.AlignItems.CENTER,
    padding = { left = 10, top = 5 },
    margin = { left = 15, top = 10 },
  })

  -- Add absolute positioned child with padding/margin consideration
  local absChildWithPadding = Gui.new({
    parent = containerWithPadding,
    x = 20,
    y = 30,
    w = 80,
    h = 40,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Abs with Padding",
  })

  -- Layout children
  rootWindow:layoutChildren()

  -- Verify absolute position accounts for parent padding and margin
  luaunit.assertEquals(absChildWithPadding.x, rootWindow.x + containerWithPadding.margin.left + absChildWithPadding.x)
  luaunit.assertEquals(absChildWithPadding.y, rootWindow.y + containerWithPadding.margin.top + absChildWithPadding.y)
end

function TestAbsolutePositioning:testAbsolutePositioningInNestedLayoutWithMultipleLevels()
  -- Create a deeply nested structure with absolute positioning at multiple levels
  local rootWindow = Gui.new({
    x = 0,
    y = 0,
    w = 800,
    h = 600,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Level 1: Main container
  local level1Container = Gui.new({
    parent = rootWindow,
    x = 50,
    y = 30,
    w = 400,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Level 2: Nested container
  local level2Container = Gui.new({
    parent = level1Container,
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Level 3: Deep nested container
  local level3Container = Gui.new({
    parent = level2Container,
    x = 20,
    y = 10,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add absolute positioned child at level 3
  local absChildAtLevel3 = Gui.new({
    parent = level3Container,
    x = 10,
    y = 20,
    w = 60,
    h = 30,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Deep Abs",
  })

  -- Add flex child at level 3
  local flexChildAtLevel3 = Gui.new({
    parent = level3Container,
    x = 0,
    y = 0,
    w = 40,
    h = 25,
    text = "Deep Flex",
  })

  -- Layout all children
  rootWindow:layoutChildren()

  -- Verify absolute position at deepest level (relative to parent hierarchy)
  luaunit.assertEquals(absChildAtLevel3.x, rootWindow.x + level1Container.x + level2Container.x + level3Container.x + absChildAtLevel3.x)
  luaunit.assertEquals(absChildAtLevel3.y, rootWindow.y + level1Container.y + level2Container.y + level3Container.y + absChildAtLevel3.y)

  -- Verify that flex child is positioned by flex layout at level 3
  luaunit.assertAlmostEquals(flexChildAtLevel3.x, 0) -- Should be at start of container
end

-- Run the tests
luaunit.LuaUnit.run()