package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for depth testing in nested layouts
TestDepthLayouts = {}

function TestDepthLayouts:testMaximumNestingDepth()
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

  -- Create a deeply nested structure (5 levels deep)
  local level1 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 250,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local level2 = Gui.new({
    parent = level1,
    x = 0,
    y = 0,
    w = 200,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local level3 = Gui.new({
    parent = level2,
    x = 0,
    y = 0,
    w = 150,
    h = 80,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
  })

  local level4 = Gui.new({
    parent = level3,
    x = 0,
    y = 0,
    w = 100,
    h = 60,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local level5 = Gui.new({
    parent = level4,
    x = 0,
    y = 0,
    w = 50,
    h = 40,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_END,
    alignItems = enums.AlignItems.FLEX_END,
  })

  -- Add a child to the deepest level
  local deepChild = Gui.new({
    parent = level5,
    x = 0,
    y = 0,
    w = 20,
    h = 15,
    text = "Deep Child",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that each level is positioned correctly
  luaunit.assertEquals(level1.x, 0)
  luaunit.assertEquals(level1.y, 0)

  luaunit.assertEquals(level2.x, 0)
  luaunit.assertEquals(level2.y, 0)

  luaunit.assertEquals(level3.x, 0)
  luaunit.assertEquals(level3.y, 0)

  luaunit.assertEquals(level4.x, 0)
  luaunit.assertEquals(level4.y, 0)

  luaunit.assertEquals(level5.x, 0)
  luaunit.assertEquals(level5.y, 0)

  -- Verify that the deepest child is positioned correctly
  luaunit.assertEquals(deepChild.x, 0)
  luaunit.assertEquals(deepChild.y, 40 - 15) -- Should be at bottom position
end

function TestDepthLayouts:testPropertyInheritanceThroughNesting()
  -- Create a parent window with specific properties
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.CENTER,
    flexWrap = enums.FlexWrap.WRAP,
  })

  -- Create nested structure with inherited properties
  local level1 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 250,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local level2 = Gui.new({
    parent = level1,
    x = 0,
    y = 0,
    w = 200,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add children to each level
  local child1 = Gui.new({
    parent = level1,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Child 1",
  })

  local child2 = Gui.new({
    parent = level2,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Child 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that properties are inherited appropriately
  -- The parent's flexWrap should be preserved through nesting
  -- The level1's flexDirection should be VERTICAL, and level2's should be HORIZONTAL
  luaunit.assertEquals(level1.x, 0)
  luaunit.assertEquals(level1.y, (200 - 150) / 2) -- Centered vertically

  luaunit.assertEquals(level2.x, 0)
  luaunit.assertEquals(level2.y, 0)

  -- Verify that children are positioned correctly based on their container's properties
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, (150 - 30) / 2) -- Centered vertically within level1

  luaunit.assertEquals(child2.x, (200 - 60) / 2) -- Centered horizontally within level2
  luaunit.assertEquals(child2.y, (100 - 40) / 2) -- Centered vertically within level2
end

function TestDepthLayouts:testSizeCalculationAccuracyAtDepth()
  -- Create a parent window with specific dimensions
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

  -- Create nested structure with precise sizing
  local level1 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local level2 = Gui.new({
    parent = level1,
    x = 0,
    y = 0,
    w = 250,
    h = 150,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local level3 = Gui.new({
    parent = level2,
    x = 0,
    y = 0,
    w = 200,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add children to the deepest level
  local child1 = Gui.new({
    parent = level3,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Child 1",
  })

  local child2 = Gui.new({
    parent = level3,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Child 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that dimensions are preserved through nesting
  luaunit.assertEquals(level1.w, 300)
  luaunit.assertEquals(level1.h, 200)

  luaunit.assertEquals(level2.w, 250)
  luaunit.assertEquals(level2.h, 150)

  luaunit.assertEquals(level3.w, 200)
  luaunit.assertEquals(level3.h, 100)

  -- Verify that children are positioned correctly within their containers
  luaunit.assertEquals(child1.x, (200 - 50) / 2) -- Centered horizontally within level3
  luaunit.assertEquals(child1.y, (100 - 30) / 2) -- Centered vertically within level3

  luaunit.assertEquals(child2.x, (200 - 60) / 2 + 50 + 10) -- Positioned after first child + gap
  luaunit.assertEquals(child2.y, (100 - 40) / 2) -- Centered vertically within level3
end

function TestDepthLayouts:testEdgeCasesInDeepLayouts()
  -- Create a parent window with complex layout properties
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 400,
    h = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.STRETCH,
    flexWrap = enums.FlexWrap.WRAP,
  })

  -- Create a deep nested structure with varying child sizes
  local level1 = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 350,
    h = 250,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  local level2 = Gui.new({
    parent = level1,
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add children with different sizes at various depths
  local child1 = Gui.new({
    parent = level2,
    x = 0,
    y = 0,
    w = 80,
    h = 40,
    text = "Child 1",
  })

  local child2 = Gui.new({
    parent = level2,
    x = 0,
    y = 0,
    w = 100,
    h = 50,
    text = "Child 2",
  })

  -- Add children to the deepest level
  local deepChild1 = Gui.new({
    parent = level1,
    x = 0,
    y = 0,
    w = 30,
    h = 20,
    text = "Deep Child 1",
  })

  local deepChild2 = Gui.new({
    parent = level1,
    x = 0,
    y = 0,
    w = 40,
    h = 25,
    text = "Deep Child 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that edge cases are handled correctly
  luaunit.assertEquals(level1.x, 0)
  luaunit.assertEquals(level1.y, 0)

  luaunit.assertEquals(level2.x, 0)
  luaunit.assertEquals(level2.y, 0)

  -- Verify children in level2 are positioned correctly (centered)
  luaunit.assertEquals(child1.x, (300 - 80) / 2) -- Centered horizontally
  luaunit.assertEquals(child1.y, (200 - 40) / 2) -- Centered vertically

  luaunit.assertEquals(child2.x, (300 - 100) / 2 + 80 + 10) -- Positioned after first child + gap
  luaunit.assertEquals(child2.y, (200 - 50) / 2) -- Centered vertically

  -- Verify children in level1 are positioned correctly
  luaunit.assertEquals(deepChild1.x, 0)
  luaunit.assertEquals(deepChild1.y, 0)

  luaunit.assertEquals(deepChild2.x, 0)
  luaunit.assertEquals(deepChild2.y, 20 + 10) -- Positioned after first child + gap
end

-- Run the tests
luaunit.LuaUnit.run()

