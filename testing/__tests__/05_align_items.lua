package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local FlexDirection = FlexLove.enums.FlexDirection
local Positioning = FlexLove.enums.Positioning
local AlignItems = FlexLove.enums.AlignItems

-- Create test cases
TestAlignItems = {}

function TestAlignItems:setUp()
  self.GUI = FlexLove.GUI
end

function TestAlignItems:testAlignItemsStretchHorizontal()
  -- Test stretch alignment in horizontal layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Add child without explicit height
  local child = self.GUI.new({
    parent = container,
    w = 50,
    positioning = Positioning.FLEX,
  })

  -- Child should stretch to container height
  luaunit.assertEquals(child.height, container.height)
end

function TestAlignItems:testAlignItemsStretchVertical()
  -- Test stretch alignment in vertical layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Add child without explicit width
  local child = self.GUI.new({
    parent = container,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Child should stretch to container width
  luaunit.assertEquals(child.width, container.width)
end

function TestAlignItems:testAlignItemsCenterHorizontal()
  -- Test center alignment in horizontal layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  -- Add child shorter than container
  local child = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Child should be vertically centered
  -- Container height: 100px, Child height: 50px
  -- Expected y: (100 - 50) / 2 = 25px
  luaunit.assertEquals(child.y, 25)
end

function TestAlignItems:testAlignItemsCenterVertical()
  -- Test center alignment in vertical layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  -- Add child narrower than container
  local child = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Child should be horizontally centered
  -- Container width: 100px, Child width: 50px
  -- Expected x: (100 - 50) / 2 = 25px
  luaunit.assertEquals(child.x, 25)
end

function TestAlignItems:testAlignItemsFlexStart()
  -- Test flex-start alignment in horizontal layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_START,
  })

  -- Add child shorter than container
  local child = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Child should be at the top
  luaunit.assertEquals(child.y, 0)
end

function TestAlignItems:testAlignItemsFlexEnd()
  -- Test flex-end alignment in horizontal layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_END,
  })

  -- Add child shorter than container
  local child = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Child should be at the bottom
  -- Container height: 100px, Child height: 50px
  -- Expected y: 100px - 50px = 50px
  luaunit.assertEquals(child.y, 50)
end

-- Run the test suite
os.exit(luaunit.LuaUnit.run())

