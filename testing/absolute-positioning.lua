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
  luaunit.assertEquals(absoluteChildInNested.x, 120) -- 100 + 20
  luaunit.assertEquals(absoluteChildInNested.y, 80) -- 50 + 30

  -- Verify flex child position is calculated correctly within nested container
  luaunit.assertEquals(flexChildInNested.x, 0) -- Should be at start of container
  luaunit.assertEquals(flexChildInNested.y, 100 - 30) -- Should be centered vertically in 100px container

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

  -- Verify absolute positions are correct
  luaunit.assertEquals(absoluteChild1.x, 50)
  luaunit.assertEquals(absoluteChild1.y, 20)
  luaunit.assertEquals(nestedAbsoluteChild.x, 100)
  luaunit.assertEquals(nestedAbsoluteChild.y, 100)

  -- Verify flex child is positioned by flex layout
  luaunit.assertEquals(flexChild.x, 0) -- First flex child in space-between should be at start
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
  luaunit.assertEquals(absChild1.x, 10) -- 0 + 10
  luaunit.assertEquals(absChild1.y, 15) -- 0 + 15
  luaunit.assertEquals(absChild2.x, 250 + 20) -- 250 + 20
  luaunit.assertEquals(absChild2.y, 100 + 30) -- 100 + 30
  luaunit.assertEquals(absChild3.x, 500 + 30) -- 500 + 30
  luaunit.assertEquals(absChild3.y, 200 + 40) -- 200 + 40

  -- Verify that regular children are positioned by flex layout
  luaunit.assertEquals(regularChild1.x, 0)
  luaunit.assertEquals(regularChild2.x, 0)
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
  luaunit.assertEquals(absChildWithPadding.x, 100 + 15 + 20) -- root x + margin + child x
  luaunit.assertEquals(absChildWithPadding.y, 50 + 10 + 30) -- root y + margin + child y
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

  -- Verify absolute position at deepest level
  luaunit.assertEquals(absChildAtLevel3.x, 50 + 0 + 20 + 10) -- root x + level1 x + level2 x + child x
  luaunit.assertEquals(absChildAtLevel3.y, 30 + 0 + 10 + 20) -- root y + level1 y + level2 y + child y

  -- Verify that flex child is positioned by flex layout at level 3
  luaunit.assertEquals(flexChildAtLevel3.x, 0) -- Should be at start of container
end

-- Run the tests
luaunit.LuaUnit.run()