package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

-- Create test cases
TestAbsolutePositioning = {}

function TestAbsolutePositioning:setUp()
  -- Reset layout engine before each test
  self.GUI = FlexLove.GUI
end

function TestAbsolutePositioning:testBasicAbsolutePositioning()
  -- Test basic absolute positioning - similar to CSS position: absolute
  local element = self.GUI.new({
    x = 100,
    y = 150,
    w = 200,
    h = 100,
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(element.x, 100)
  luaunit.assertEquals(element.y, 150)
  luaunit.assertEquals(element.width, 200)
  luaunit.assertEquals(element.height, 100)
  luaunit.assertEquals(element.positioning, FlexLove.enums.Positioning.ABSOLUTE)
end

function TestAbsolutePositioning:testAbsolutePositioningWithOffsets()
  -- Test absolute positioning with top/left/right/bottom - like CSS absolute positioning
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  local child = self.GUI.new({
    parent = container,
    x = 50,
    y = 75,
    w = 100,
    h = 50,
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
  })

  -- Element should maintain its absolute position
  luaunit.assertEquals(child.x, 50)
  luaunit.assertEquals(child.y, 75)
  luaunit.assertEquals(child.width, 100)
  luaunit.assertEquals(child.height, 50)
end

function TestAbsolutePositioning:testAbsolutePositioningInContainer()
  -- Test absolute positioning within a container - similar to CSS relative container
  local container = self.GUI.new({
    x = 100,
    y = 100,
    w = 500,
    h = 500,
  })

  local child = self.GUI.new({
    parent = container,
    x = 50,
    y = 50,
    w = 100,
    h = 100,
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
  })

  -- Child should keep its absolute position
  luaunit.assertEquals(child.x, 50)
  luaunit.assertEquals(child.y, 50)
  luaunit.assertEquals(child.width, 100)
  luaunit.assertEquals(child.height, 100)
end

function TestAbsolutePositioning:testAbsolutePositioningWithRightBottom()
  -- Test absolute positioning with right/bottom properties - like CSS
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 1000,
    h = 800,
  })

  local child = self.GUI.new({
    parent = container,
    x = 850,
    y = 650,
    w = 100,
    h = 100,
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
  })

  -- Child should maintain its position from right/bottom edges
  luaunit.assertEquals(child.x, 850)
  luaunit.assertEquals(child.y, 650)
  luaunit.assertEquals(child.width, 100)
  luaunit.assertEquals(child.height, 100)
end

function TestAbsolutePositioning:testAbsolutePositioningZIndex()
  -- Test z-index with absolute positioning - like CSS z-index
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  local child1 = self.GUI.new({
    parent = container,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    z = 1,
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
  })

  local child2 = self.GUI.new({
    parent = container,
    x = 50,
    y = 50,
    w = 100,
    h = 100,
    z = 2,
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
  })

  -- Elements should maintain their z-index order
  luaunit.assertEquals(child1.z, 1)
  luaunit.assertEquals(child2.z, 2)
  luaunit.assertTrue(child1.z < child2.z)
end

luaunit.LuaUnit.run()
