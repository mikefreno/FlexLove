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
  -- CSS behavior: nested containers should maintain their relative positions within parents
  luaunit.assertAlmostEquals(level1.x, 0)
  luaunit.assertAlmostEquals(level1.y, 0)

  luaunit.assertAlmostEquals(level2.x, 0)
  luaunit.assertAlmostEquals(level2.y, 0)

  luaunit.assertAlmostEquals(level3.x, 0)
  luaunit.assertAlmostEquals(level3.y, 0)

  luaunit.assertAlmostEquals(level4.x, 0)
  luaunit.assertAlmostEquals(level4.y, 0)

  luaunit.assertAlmostEquals(level5.x, 0)
  luaunit.assertAlmostEquals(level5.y, 0)

  -- Verify that the deepest child is positioned correctly
  -- CSS behavior: deepest child should be positioned according to its container's justify content and alignment properties
  luaunit.assertAlmostEquals(deepChild.x, 0)
  luaunit.assertAlmostEquals(deepChild.y, level5.h - deepChild.h) -- Should be at bottom position
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
  -- CSS behavior: nested containers should inherit flex properties from their parent, unless explicitly overridden
  luaunit.assertAlmostEquals(level1.x, 0)
  luaunit.assertAlmostEquals(level1.y, (parentWindow.h - level1.h) / 2) -- Centered vertically

  luaunit.assertAlmostEquals(level2.x, 0)
  luaunit.assertAlmostEquals(level2.y, 0)

  -- Verify that children are positioned correctly based on their container's properties
  -- CSS behavior: child positioning should respect the flex direction and justify content of its container
  luaunit.assertAlmostEquals(child1.x, 0)
  luaunit.assertAlmostEquals(child1.y, (level1.h - child1.h) / 2) -- Centered vertically within level1

  luaunit.assertAlmostEquals(child2.x, (level2.w - child2.w) / 2) -- Centered horizontally within level2
  luaunit.assertAlmostEquals(child2.y, (level2.h - child2.h) / 2) -- Centered vertically within level2
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
  -- CSS behavior: nested containers should maintain their specified dimensions
  luaunit.assertAlmostEquals(level1.w, 300)
  luaunit.assertAlmostEquals(level1.h, 200)

  luaunit.assertAlmostEquals(level2.w, 250)
  luaunit.assertAlmostEquals(level2.h, 150)

  luaunit.assertAlmostEquals(level3.w, 200)
  luaunit.assertAlmostEquals(level3.h, 100)

  -- Verify that children are positioned correctly within their containers
  -- CSS behavior: child positioning should be calculated based on container dimensions and justify content
  luaunit.assertAlmostEquals(child1.x, (level3.w - child1.w) / 2) -- Centered horizontally within level3
  luaunit.assertAlmostEquals(child1.y, (level3.h - child1.h) / 2) -- Centered vertically within level3

  luaunit.assertAlmostEquals(child2.x, (level3.w - child2.w) / 2 + child1.w + parentWindow.gap) -- Positioned after first child + gap
  luaunit.assertAlmostEquals(child2.y, (level3.h - child2.h) / 2) -- Centered vertically within level3
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
  -- CSS behavior: nested layouts should handle various combinations of flex properties and child sizes gracefully
  luaunit.assertAlmostEquals(level1.x, 0)
  luaunit.assertAlmostEquals(level1.y, 0)

  luaunit.assertAlmostEquals(level2.x, 0)
  luaunit.assertAlmostEquals(level2.y, 0)

  -- Verify children in level2 are positioned correctly (centered)
  -- CSS behavior: child positioning should respect justify content properties
  luaunit.assertAlmostEquals(child1.x, (level2.w - child1.w) / 2) -- Centered horizontally
  luaunit.assertAlmostEquals(child1.y, (level2.h - child1.h) / 2) -- Centered vertically

  luaunit.assertAlmostEquals(child2.x, (level2.w - child2.w) / 2 + child1.w + parentWindow.gap) -- Positioned after first child + gap
  luaunit.assertAlmostEquals(child2.y, (level2.h - child2.h) / 2) -- Centered vertically

  -- Verify children in level1 are positioned correctly
  -- CSS behavior: child positioning should respect the flex direction and justify content of its container
  luaunit.assertAlmostEquals(deepChild1.x, 0)
  luaunit.assertAlmostEquals(deepChild1.y, 0)

  luaunit.assertAlmostEquals(deepChild2.x, 0)
  luaunit.assertAlmostEquals(deepChild2.y, deepChild1.h + parentWindow.gap) -- Positioned after first child + gap
end

-- Run the tests
luaunit.LuaUnit.run()