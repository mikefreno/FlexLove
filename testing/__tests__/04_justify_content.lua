package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local FlexDirection = FlexLove.enums.FlexDirection
local Positioning = FlexLove.enums.Positioning
local JustifyContent = FlexLove.enums.JustifyContent

-- Create test cases
TestJustifyContent = {}

function TestJustifyContent:setUp()
  self.GUI = FlexLove.GUI
end

function TestJustifyContent:testJustifyContentSpaceEvenly()
  -- Test space-evenly distribution in horizontal layout
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
  })

  -- Add three children of equal width
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

  -- Calculate expected positions
  -- Total width of children: 150px (3 * 50px)
  -- Remaining space: 150px (300px - 150px)
  -- Space between and around items: 150px / 4 = 37.5px
  luaunit.assertEquals(child1.x, 37) -- First space
  luaunit.assertEquals(child2.x, 125) -- First space + width + second space
  luaunit.assertEquals(child3.x, 212) -- Previous + width + third space
end

function TestJustifyContent:testJustifyContentSpaceAround()
  -- Test space-around distribution
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
  })

  -- Add two children with equal widths
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

  -- Calculate expected positions
  -- Total width of children: 100px (2 * 50px)
  -- Remaining space: 200px (300px - 100px)
  -- Space around each item: 200px / 4 = 50px
  -- First item gets 50px margin, second gets 150px (50px * 3) margin
  luaunit.assertEquals(child1.x, 50)
  luaunit.assertEquals(child2.x, 200)
end

function TestJustifyContent:testJustifyContentSpaceBetween()
  -- Test space-between distribution
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
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

  local child3 = self.GUI.new({
    parent = container,
    w = 50,
    h = 50,
    positioning = Positioning.FLEX,
  })

  -- Calculate expected positions
  -- Total width of children: 150px (3 * 50px)
  -- Remaining space: 150px (300px - 150px)
  -- Space between items: 75px (150px / 2)
  luaunit.assertEquals(child1.x, 0) -- First child at start
  luaunit.assertEquals(child2.x, 125) -- After first gap
  luaunit.assertEquals(child3.x, 250) -- After second gap
end

function TestJustifyContent:testJustifyContentFlexStart()
  -- Test flex-start alignment
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
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

  -- Children should be at the start with default gap
  luaunit.assertEquals(child1.x, 0) -- First child at start
  luaunit.assertEquals(child2.x, 60) -- After first child + gap
end

function TestJustifyContent:testJustifyContentFlexEnd()
  -- Test flex-end alignment
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 300,
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

  -- Children should be at the end with default gap
  -- Total width needed: 110px (50px + 10px + 50px)
  -- Start position: 300px - 110px = 190px
  luaunit.assertEquals(child1.x, 190)
  luaunit.assertEquals(child2.x, 250)
end

luaunit.LuaUnit.run()
