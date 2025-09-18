package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local FlexDirection = FlexLove.enums.FlexDirection
local Positioning = FlexLove.enums.Positioning
local JustifyContent = FlexLove.enums.JustifyContent
local AlignItems = FlexLove.enums.AlignItems

-- Create test cases
TestLayoutValidation = {}

function TestLayoutValidation:setUp()
  self.GUI = FlexLove.GUI
end

function TestLayoutValidation:testNestedFlexContainers()
  -- Test nested flex containers behave correctly
  local outerContainer = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
  })

  local innerContainer1 = self.GUI.new({
    parent = outerContainer,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local innerContainer2 = self.GUI.new({
    parent = outerContainer,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
  })

  -- Add children to inner container 1
  local child1 = self.GUI.new({
    parent = innerContainer1,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  local child2 = self.GUI.new({
    parent = innerContainer1,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Add child to inner container 2
  local child3 = self.GUI.new({
    parent = innerContainer2,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Verify outer container layout
  luaunit.assertEquals(innerContainer1.y, 0)
  luaunit.assertEquals(innerContainer2.y, 110) -- 100 + 10 gap

  -- Verify inner container 1 layout (space-between)
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 250)

  -- Verify inner container 2 layout (center)
  luaunit.assertEquals(child3.x, 125) -- (300 - 50) / 2

  -- Test container references
  luaunit.assertEquals(#innerContainer1.children, 2)
  luaunit.assertEquals(#innerContainer2.children, 1)
  luaunit.assertEquals(innerContainer1.children[1], child1)
  luaunit.assertEquals(innerContainer1.children[2], child2)
  luaunit.assertEquals(innerContainer2.children[1], child3)
end

function TestLayoutValidation:testMixedPositioning()
  -- Test mixing absolute and flex positioning
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
  })

  -- Add flex positioned child
  local flexChild = self.GUI.new({
    parent = container,
    w = 100,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Add absolute positioned child
  local absoluteChild = self.GUI.new({
    parent = container,
    x = 150,
    y = 150,
    w = 100,
    h = 50,
    positioning = Positioning.ABSOLUTE,
  })

  -- Add another flex positioned child
  local flexChild2 = self.GUI.new({
    parent = container,
    w = 100,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Verify flex children positions
  luaunit.assertEquals(flexChild.y, 0)
  luaunit.assertEquals(flexChild2.y, 60) -- 50 + 10 gap

  -- Verify absolute child position is maintained
  luaunit.assertEquals(absoluteChild.x, 150)
  luaunit.assertEquals(absoluteChild.y, 150)
end

function TestLayoutValidation:testDynamicSizing()
  -- Test auto-sizing of flex containers
  local container = self.GUI.new({
    x = 0,
    y = 0,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
  })

  -- Add children to determine container size
  local child1 = self.GUI.new({
    parent = container,
    w = 50,
    h = 100,
    positioning = Positioning.FLEX,
  })

  local child2 = self.GUI.new({
    parent = container,
    w = 50,
    h = 150,
    positioning = Positioning.FLEX,
  })

  -- Container should size to fit children
  luaunit.assertEquals(container.width, 110) -- 50 + 10 + 50
  luaunit.assertEquals(container.height, 150) -- Max of child heights
end

function TestLayoutValidation:testDeepNesting()
  -- Test deeply nested flex containers
  local level1 = self.GUI.new({
    x = 0,
    y = 0,
    w = 400,
    h = 400,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
  })

  local level2 = self.GUI.new({
    parent = level1,
    w = 300,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
  })

  local level3 = self.GUI.new({
    parent = level2,
    w = 200,
    h = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local level4 = self.GUI.new({
    parent = level3,
    w = 100,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
  })

  -- Add a child to the deepest level
  local deepChild = self.GUI.new({
    parent = level4,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Verify positioning through all levels
  luaunit.assertEquals(level2.y, 0)
  luaunit.assertEquals(level3.x, 0)
  luaunit.assertEquals(level4.x, 50) -- (200 - 100) / 2
  luaunit.assertEquals(deepChild.x, 25) -- (100 - 50) / 2
end

function TestLayoutValidation:testEdgeCases()
  -- Test edge cases and potential layout issues
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
  })

  -- Test zero-size child
  local zeroSizeChild = self.GUI.new({
    parent = container,
    w = 0,
    h = 0,
    positioning = Positioning.FLEX,
  })

  -- Test negative size (should be clamped to 0)
  local negativeSizeChild = self.GUI.new({
    parent = container,
    w = -50,
    h = -50,
    positioning = Positioning.FLEX,
  })

  -- Test oversized child
  local oversizedChild = self.GUI.new({
    parent = container,
    w = 200,
    h = 200,
    positioning = Positioning.FLEX,
  })

  -- Verify layout handles edge cases gracefully
  luaunit.assertTrue(zeroSizeChild.width >= 0)
  luaunit.assertTrue(zeroSizeChild.height >= 0)
  luaunit.assertTrue(negativeSizeChild.width >= 0)
  luaunit.assertTrue(negativeSizeChild.height >= 0)
  luaunit.assertEquals(oversizedChild.x, 0) -- Should still be positioned at start

  -- Check that containers handle children properly
  luaunit.assertEquals(zeroSizeChild.x, 0) -- First child should be at start
  luaunit.assertEquals(negativeSizeChild.x, 0) -- Should be positioned after zero-size child
  luaunit.assertEquals(oversizedChild.x, 0) -- Should be positioned after negative-size child
  luaunit.assertNotNil(container.children[1]) -- Container should maintain child references
  luaunit.assertEquals(#container.children, 3) -- All children should be tracked
end

luaunit.LuaUnit.run()
