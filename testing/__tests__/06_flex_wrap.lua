package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local FlexDirection = FlexLove.enums.FlexDirection
local Positioning = FlexLove.enums.Positioning
local AlignContent = FlexLove.enums.AlignContent

-- Create test cases
TestFlexWrap = {}

function TestFlexWrap:setUp()
  self.GUI = FlexLove.GUI
end

function TestFlexWrap:testFlexWrapHorizontal()
  -- Test flex wrap in horizontal layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignContent = AlignContent.FLEX_START,
  })

  -- Add three children that exceed container width
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

  local child3 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- First line: child1 and child2 (with 10px gap)
  -- Second line: child3
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.x, 60)
  luaunit.assertEquals(child2.y, 0)
  luaunit.assertEquals(child3.x, 0)
  luaunit.assertEquals(child3.y, 60)
end

function TestFlexWrap:testFlexWrapVertical()
  -- Test flex wrap in vertical layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignContent = AlignContent.FLEX_START,
  })

  -- Add three children that exceed container height
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

  local child3 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- First column: child1 and child2 (with 10px gap)
  -- Second column: child3
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.x, 0)
  luaunit.assertEquals(child2.y, 60)
  luaunit.assertEquals(child3.x, 60)
  luaunit.assertEquals(child3.y, 0)
end

function TestFlexWrap:testFlexWrapWithAlignContentCenter()
  -- Test align-content center with flex wrap
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignContent = AlignContent.CENTER,
  })

  -- Add three children that create two rows
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

  local child3 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Total height used: 110px (two rows of 50px + 10px gap)
  -- Remaining space: 190px (300px - 110px)
  -- Space before first row: 95px (190px / 2)
  luaunit.assertEquals(child1.y, 95)
  luaunit.assertEquals(child2.y, 95)
  luaunit.assertEquals(child3.y, 155) -- 95px + 50px + 10px gap
end

function TestFlexWrap:testFlexWrapWithAlignContentSpaceBetween()
  -- Test align-content space-between with flex wrap
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignContent = AlignContent.SPACE_BETWEEN,
  })

  -- Add three children that create two rows
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

  local child3 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- First row at top (y = 0)
  -- Second row at bottom (y = 250)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 0)
  luaunit.assertEquals(child3.y, 250)
end

function TestFlexWrap:testFlexWrapWithAlignContentSpaceAround()
  -- Test align-content space-around with flex wrap
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignContent = AlignContent.SPACE_AROUND,
  })

  -- Add three children that create two rows
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

  local child3 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Space around calculation:
  -- Total height of content: 110px (two rows of 50px + 10px gap)
  -- Remaining space: 190px
  -- Space per unit: 63.33px (190px / 3)
  -- First row: 63.33px (one unit of space)
  -- Second row: 190px (three units of space)
  luaunit.assertEquals(child1.y, 63)
  luaunit.assertEquals(child2.y, 63)
  luaunit.assertEquals(child3.y, 190)
end

luaunit.LuaUnit.run()
