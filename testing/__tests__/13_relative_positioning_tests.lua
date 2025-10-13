-- Test relative positioning functionality
package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local luaunit = require("testing/luaunit")

local Gui, enums = FlexLove.GUI, FlexLove.enums
local Color = FlexLove.Color
local Positioning = enums.Positioning

TestRelativePositioning = {}

-- Test 1: Basic relative positioning with pixel values
function TestRelativePositioning.testBasicRelativePositioning()
  local parent = Gui.new({
    x = 100,
    y = 50,
    width = 200,
    height = 150,
    positioning = "relative",
    backgroundColor = Color.new(0.2, 0.2, 0.2, 1.0),
  })

  local child = Gui.new({
    parent = parent,
    x = 20,
    y = 30,
    width = 50,
    height = 40,
    positioning = "relative",
    backgroundColor = Color.new(0.8, 0.2, 0.2, 1.0),
  })

  -- Child should be positioned relative to parent
  luaunit.assertEquals(child.positioning, Positioning.RELATIVE)
  luaunit.assertEquals(child.x, 120) -- parent.x (100) + offset (20)
  luaunit.assertEquals(child.y, 80) -- parent.y (50) + offset (30)
end

-- Test 2: Relative positioning with percentage values
function TestRelativePositioning.testRelativePositioningPercentages()
  local parent = Gui.new({
    x = 50,
    y = 100,
    width = 200,
    height = 100,
    positioning = "relative",
    backgroundColor = Color.new(0.2, 0.2, 0.2, 1.0),
  })

  local child = Gui.new({
    parent = parent,
    x = "10%", -- 10% of parent width = 20px
    y = "20%", -- 20% of parent height = 20px
    width = 30,
    height = 20,
    positioning = "relative",
    backgroundColor = Color.new(0.8, 0.2, 0.2, 1.0),
  })

  -- Child should be positioned relative to parent with percentage offsets
  luaunit.assertEquals(child.positioning, Positioning.RELATIVE)
  luaunit.assertEquals(child.x, 70.0) -- parent.x (50) + 10% of width (20)
  luaunit.assertEquals(child.y, 120.0) -- parent.y (100) + 20% of height (20)
end

-- Test 3: Relative positioning with no offset (default to parent position)
function TestRelativePositioning.testRelativePositioningNoOffset()
  local parent = Gui.new({
    x = 75,
    y = 125,
    width = 150,
    height = 200,
    positioning = "relative",
    backgroundColor = Color.new(0.2, 0.2, 0.2, 1.0),
  })

  local child = Gui.new({
    parent = parent,
    width = 40,
    height = 30,
    positioning = "relative",
    backgroundColor = Color.new(0.2, 0.8, 0.2, 1.0),
  })

  -- Child should be positioned at parent's position with no offset
  luaunit.assertEquals(child.positioning, Positioning.RELATIVE)
  luaunit.assertEquals(child.x, 75) -- same as parent.x
  luaunit.assertEquals(child.y, 125) -- same as parent.y
end

-- Test 4: Multiple relative positioned children
function TestRelativePositioning.testMultipleRelativeChildren()
  local parent = Gui.new({
    x = 200,
    y = 300,
    width = 100,
    height = 100,
    positioning = "relative",
    backgroundColor = Color.new(0.2, 0.2, 0.2, 1.0),
  })

  local child1 = Gui.new({
    parent = parent,
    x = 10,
    y = 15,
    width = 20,
    height = 20,
    positioning = "relative",
    backgroundColor = Color.new(0.8, 0.2, 0.2, 1.0),
  })

  local child2 = Gui.new({
    parent = parent,
    x = 30,
    y = 45,
    width = 25,
    height = 25,
    positioning = "relative",
    backgroundColor = Color.new(0.2, 0.8, 0.2, 1.0),
  })

  -- Both children should be positioned relative to parent
  luaunit.assertEquals(child1.x, 210) -- parent.x (200) + offset (10)
  luaunit.assertEquals(child1.y, 315) -- parent.y (300) + offset (15)

  luaunit.assertEquals(child2.x, 230) -- parent.x (200) + offset (30)
  luaunit.assertEquals(child2.y, 345) -- parent.y (300) + offset (45)
end

-- Test 5: Nested relative positioning
function TestRelativePositioning.testNestedRelativePositioning()
  local grandparent = Gui.new({
    x = 50,
    y = 60,
    width = 300,
    height = 250,
    positioning = "relative",
    backgroundColor = Color.new(0.1, 0.1, 0.1, 1.0),
  })

  local parent = Gui.new({
    parent = grandparent,
    x = 25,
    y = 35,
    width = 200,
    height = 150,
    positioning = "relative",
    backgroundColor = Color.new(0.3, 0.3, 0.3, 1.0),
  })

  local child = Gui.new({
    parent = parent,
    x = 15,
    y = 20,
    width = 50,
    height = 40,
    positioning = "relative",
    backgroundColor = Color.new(0.8, 0.8, 0.8, 1.0),
  })

  -- Each level should be positioned relative to its parent
  luaunit.assertEquals(parent.x, 75) -- grandparent.x (50) + offset (25)
  luaunit.assertEquals(parent.y, 95) -- grandparent.y (60) + offset (35)

  luaunit.assertEquals(child.x, 90) -- parent.x (75) + offset (15)
  luaunit.assertEquals(child.y, 115) -- parent.y (95) + offset (20)
end

-- Test 6: Mixed positioning types (relative child in absolute parent)
function TestRelativePositioning.testMixedPositioning()
  local parent = Gui.new({
    x = 100,
    y = 200,
    width = 180,
    height = 120,
    positioning = "absolute",
    backgroundColor = Color.new(0.2, 0.2, 0.2, 1.0),
  })

  local child = Gui.new({
    parent = parent,
    x = 40,
    y = 25,
    width = 60,
    height = 35,
    positioning = "relative",
    backgroundColor = Color.new(0.8, 0.8, 0.2, 1.0),
  })

  -- Relative child should still be positioned relative to absolute parent
  luaunit.assertEquals(parent.positioning, Positioning.ABSOLUTE)
  luaunit.assertEquals(child.positioning, Positioning.RELATIVE)
  luaunit.assertEquals(child.x, 140) -- parent.x (100) + offset (40)
  luaunit.assertEquals(child.y, 225) -- parent.y (200) + offset (25)
end

-- Run all tests
luaunit.LuaUnit.run()
