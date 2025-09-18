package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local FlexDirection = FlexLove.enums.FlexDirection
local Positioning = FlexLove.enums.Positioning
local JustifyContent = FlexLove.enums.JustifyContent
local AlignItems = FlexLove.enums.AlignItems

-- Create test cases
TestFlexDirection = {}

function TestFlexDirection:setUp()
  self.GUI = FlexLove.GUI
end

function TestFlexDirection:testHorizontalFlexBasic()
  -- Test basic horizontal flex layout - like CSS flex-direction: row
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
  })

  -- Add three children with equal widths
  local child1 = self.GUI.new({
    parent = container,
    w = 100,
    h = 50,
    positioning = Positioning.FLEX,
  })

  local child2 = self.GUI.new({
    parent = container,
    w = 100,
    h = 50,
    positioning = Positioning.FLEX,
  })

  local child3 = self.GUI.new({
    parent = container,
    w = 100,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Elements should be positioned horizontally with default gap of 10
  luaunit.assertEquals(child1.x, 0) -- First child starts at container's x
  luaunit.assertEquals(child2.x, 110) -- Second child starts after first child + gap
  luaunit.assertEquals(child3.x, 220) -- Third child starts after second child + gap

  -- All children should maintain their original widths
  luaunit.assertEquals(child1.width, 100)
  luaunit.assertEquals(child2.width, 100)
  luaunit.assertEquals(child3.width, 100)
end

function TestFlexDirection:testHorizontalFlexWithJustifyContentFlexStart()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
  })

  -- Add three children
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
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 60)
end

function TestFlexDirection:testHorizontalFlexWithJustifyContentCenter()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
  })

  -- Add three children
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
  -- Total width used: 50 + 10 + 50 = 110px
  -- Remaining space: 500 - 110 = 390px
  -- Space before first child: 390/2 = 195px
  luaunit.assertEquals(child1.x, 195)
  luaunit.assertEquals(child2.x, 255) -- 195 + 50 + 10
end

function TestFlexDirection:testHorizontalFlexWithJustifyContentFlexEnd()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
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

  -- Children should be positioned at the end
  -- Total width used: 50 + 10 + 50 = 110px
  -- First child should start at: 500 - 110 = 390px
  luaunit.assertEquals(child1.x, 390)
  luaunit.assertEquals(child2.x, 450) -- 390 + 50 + 10
end

function TestFlexDirection:testHorizontalFlexWithJustifyContentSpaceBetween()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
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

  -- Children should be positioned at the edges
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 450)
end

function TestFlexDirection:testHorizontalFlexWithAlignItemsCenter()
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  -- Add a child shorter than the container
  local child = self.GUI.new({
    parent = container,
    w = 50,
    h = 50, -- Container is 100px high, child is 50px
    positioning = Positioning.FLEX,
  })

  -- Child should be vertically centered
  -- Container height: 100px, Child height: 50px
  -- Expected y: (100 - 50) / 2 = 25px
  luaunit.assertEquals(child.y, 25)
end

luaunit.LuaUnit.run()
