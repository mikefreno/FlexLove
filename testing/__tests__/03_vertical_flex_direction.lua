package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local FlexDirection = FlexLove.enums.FlexDirection
local Positioning = FlexLove.enums.Positioning
local JustifyContent = FlexLove.enums.JustifyContent
local AlignItems = FlexLove.enums.AlignItems

-- Create test cases
TestVerticalFlexDirection = {}

function TestVerticalFlexDirection:setUp()
  self.GUI = FlexLove.GUI
end

function TestVerticalFlexDirection:testVerticalFlexBasic()
  -- Test basic vertical flex layout - like CSS flex-direction: column
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 500,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
  })

  -- Add three children with equal heights
  local child1 = self.GUI.new({
    parent = container,
    w = 50,
    h = 100,
    positioning = Positioning.FLEX,
  })

  local child2 = self.GUI.new({
    parent = container,
    w = 50,
    h = 100,
    positioning = Positioning.FLEX,
  })

  local child3 = self.GUI.new({
    parent = container,
    w = 50,
    h = 100,
    positioning = Positioning.FLEX,
  })

  -- Elements should be positioned vertically with default gap of 10
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 110)
  luaunit.assertEquals(child3.y, 220)

  -- All children should maintain their original heights
  luaunit.assertEquals(child1.height, 100)
  luaunit.assertEquals(child2.height, 100)
  luaunit.assertEquals(child3.height, 100)
end

function TestVerticalFlexDirection:testVerticalFlexWithJustifyContentFlexStart()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 500,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
  })

  -- Add two children
  local child1 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  local child2 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Children should be positioned at the start with default gap
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 60)
end

function TestVerticalFlexDirection:testVerticalFlexWithJustifyContentCenter()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 500,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
  })

  -- Add two children
  local child1 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  local child2 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Children should be centered in container
  -- Total height used: 50 + 10 + 50 = 110px
  -- Remaining space: 500 - 110 = 390px
  -- Space before first child: 390/2 = 195px
  luaunit.assertEquals(child1.y, 195)
  luaunit.assertEquals(child2.y, 255)
end

function TestVerticalFlexDirection:testVerticalFlexWithAlignItemsCenter()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 500,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  -- Add a child narrower than the container
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

function TestVerticalFlexDirection:testVerticalFlexWithAlignItemsStretch()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 500,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Add a child without explicit width
  local child = self.GUI.new({
    parent = container,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Child should stretch to container width
  luaunit.assertEquals(child.width, 100)
end

luaunit.LuaUnit.run()
