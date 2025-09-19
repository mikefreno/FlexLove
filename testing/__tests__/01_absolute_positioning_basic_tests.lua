package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

local Positioning = enums.Positioning

-- Create test cases for basic absolute positioning
TestAbsolutePositioningBasic = {}

function TestAbsolutePositioningBasic:setUp()
  -- Clean up before each test
  Gui.destroy()
end

function TestAbsolutePositioningBasic:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Test 1: Basic element creation with absolute positioning
function TestAbsolutePositioningBasic:testCreateElementWithAbsolutePositioning()
  local elem = Gui.new({
    x = 100,
    y = 200,
    w = 300,
    h = 150,
    positioning = Positioning.ABSOLUTE,
  })

  -- Verify element was created with correct properties
  luaunit.assertEquals(elem.x, 100)
  luaunit.assertEquals(elem.y, 200)
  luaunit.assertEquals(elem.width, 300)
  luaunit.assertEquals(elem.height, 150)
  luaunit.assertEquals(elem.positioning, Positioning.ABSOLUTE)

  -- Verify element was added to topElements
  luaunit.assertEquals(#Gui.topElements, 1)
  luaunit.assertEquals(Gui.topElements[1], elem)
end

-- Test 2: Default absolute positioning when no positioning specified
function TestAbsolutePositioningBasic:testDefaultAbsolutePositioning()
  local elem = Gui.new({
    x = 50,
    y = 75,
    w = 200,
    h = 100,
  })

  -- Default should be absolute positioning
  luaunit.assertEquals(elem.positioning, Positioning.ABSOLUTE)
  luaunit.assertEquals(elem.x, 50)
  luaunit.assertEquals(elem.y, 75)
end

-- Test 3: Z-index handling for absolute positioned elements
function TestAbsolutePositioningBasic:testZIndexHandling()
  local elem1 = Gui.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    z = 1,
    positioning = Positioning.ABSOLUTE,
  })

  local elem2 = Gui.new({
    x = 50,
    y = 50,
    w = 100,
    h = 100,
    z = 5,
    positioning = Positioning.ABSOLUTE,
  })

  local elem3 = Gui.new({
    x = 25,
    y = 25,
    w = 100,
    h = 100,
    z = 3,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem1.z, 1)
  luaunit.assertEquals(elem2.z, 5)
  luaunit.assertEquals(elem3.z, 3)

  -- All should be in topElements
  luaunit.assertEquals(#Gui.topElements, 3)
end

-- Test 4: Default z-index is 0
function TestAbsolutePositioningBasic:testDefaultZIndex()
  local elem = Gui.new({
    x = 10,
    y = 20,
    w = 50,
    h = 50,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.z, 0)
end

-- Test 5: Coordinate independence from other elements
function TestAbsolutePositioningBasic:testCoordinateIndependence()
  local elem1 = Gui.new({
    x = 100,
    y = 100,
    w = 50,
    h = 50,
    positioning = Positioning.ABSOLUTE,
  })

  local elem2 = Gui.new({
    x = 200,
    y = 200,
    w = 50,
    h = 50,
    positioning = Positioning.ABSOLUTE,
  })

  -- Elements should maintain their own coordinates
  luaunit.assertEquals(elem1.x, 100)
  luaunit.assertEquals(elem1.y, 100)
  luaunit.assertEquals(elem2.x, 200)
  luaunit.assertEquals(elem2.y, 200)

  -- Modifying one shouldn't affect the other
  elem1.x = 150
  luaunit.assertEquals(elem1.x, 150)
  luaunit.assertEquals(elem2.x, 200) -- Should remain unchanged
end

-- Test 6: Absolute positioned element with parent but should maintain own coordinates
function TestAbsolutePositioningBasic:testAbsoluteWithParentIndependentCoordinates()
  local parent = Gui.new({
    x = 50,
    y = 50,
    w = 200,
    h = 200,
    positioning = Positioning.ABSOLUTE,
  })

  local child = Gui.new({
    parent = parent,
    x = 25,
    y = 25,
    w = 50,
    h = 50,
    positioning = Positioning.ABSOLUTE,
  })

  -- Child should maintain its absolute coordinates (CSS absolute behavior)
  luaunit.assertEquals(child.x, 25)
  luaunit.assertEquals(child.y, 25)
  luaunit.assertEquals(child.positioning, Positioning.ABSOLUTE)

  -- Parent should have the child
  luaunit.assertEquals(#parent.children, 1)
  luaunit.assertEquals(parent.children[1], child)
end

-- Test 7: Multiple absolute elements should not interfere
function TestAbsolutePositioningBasic:testMultipleAbsoluteElementsNonInterference()
  local elements = {}

  for i = 1, 5 do
    elements[i] = Gui.new({
      x = i * 10,
      y = i * 20,
      w = 30,
      h = 40,
      z = i,
      positioning = Positioning.ABSOLUTE,
    })
  end

  -- Verify all elements maintain their properties
  for i = 1, 5 do
    luaunit.assertEquals(elements[i].x, i * 10)
    luaunit.assertEquals(elements[i].y, i * 20)
    luaunit.assertEquals(elements[i].width, 30)
    luaunit.assertEquals(elements[i].height, 40)
    luaunit.assertEquals(elements[i].z, i)
  end

  luaunit.assertEquals(#Gui.topElements, 5)
end

-- Test 8: Negative coordinates should work
function TestAbsolutePositioningBasic:testNegativeCoordinates()
  local elem = Gui.new({
    x = -50,
    y = -100,
    w = 200,
    h = 150,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.x, -50)
  luaunit.assertEquals(elem.y, -100)
end

-- Test 9: Zero coordinates should work
function TestAbsolutePositioningBasic:testZeroCoordinates()
  local elem = Gui.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.x, 0)
  luaunit.assertEquals(elem.y, 0)
end

-- Test 10: Default coordinates when not specified
function TestAbsolutePositioningBasic:testDefaultCoordinates()
  local elem = Gui.new({
    w = 100,
    h = 100,
    positioning = Positioning.ABSOLUTE,
  })

  -- Default coordinates should be 0,0
  luaunit.assertEquals(elem.x, 0)
  luaunit.assertEquals(elem.y, 0)
end

-- Test 11: Element bounds calculation
function TestAbsolutePositioningBasic:testElementBounds()
  local elem = Gui.new({
    x = 100,
    y = 200,
    w = 300,
    h = 400,
    positioning = Positioning.ABSOLUTE,
  })

  local bounds = elem:getBounds()
  luaunit.assertEquals(bounds.x, 100)
  luaunit.assertEquals(bounds.y, 200)
  luaunit.assertEquals(bounds.width, 300)
  luaunit.assertEquals(bounds.height, 400)
end

-- Test 12: Parent-child relationship with absolute positioning
function TestAbsolutePositioningBasic:testParentChildRelationshipAbsolute()
  local parent = Gui.new({
    x = 100,
    y = 100,
    w = 300,
    h = 300,
    positioning = Positioning.ABSOLUTE,
  })

  local child = Gui.new({
    parent = parent,
    x = 50,
    y = 75,
    w = 100,
    h = 150,
    positioning = Positioning.ABSOLUTE,
  })

  -- Verify parent-child relationship
  luaunit.assertEquals(child.parent, parent)
  luaunit.assertEquals(#parent.children, 1)
  luaunit.assertEquals(parent.children[1], child)

  -- Child should maintain absolute coordinates
  luaunit.assertEquals(child.x, 50)
  luaunit.assertEquals(child.y, 75)
end

-- Test 13: Absolute positioned child should not affect parent auto-sizing
function TestAbsolutePositioningBasic:testAbsoluteChildNoParentAutoSizeAffect()
  local parent = Gui.new({
    x = 0,
    y = 0,
    positioning = Positioning.ABSOLUTE,
  })

  local originalParentWidth = parent.width
  local originalParentHeight = parent.height

  local child = Gui.new({
    parent = parent,
    x = 1000, -- Far outside parent
    y = 1000,
    w = 500,
    h = 500,
    positioning = Positioning.ABSOLUTE,
  })

  -- Parent size should not be affected by absolute positioned child
  -- (In CSS, absolute children don't affect parent size)
  luaunit.assertEquals(parent.width, originalParentWidth)
  luaunit.assertEquals(parent.height, originalParentHeight)
end

-- Test 14: Verify absolute elements don't participate in flex layout
function TestAbsolutePositioningBasic:testAbsoluteNoFlexParticipation()
  local flexParent = Gui.new({
    x = 0,
    y = 0,
    w = 400,
    h = 200,
    positioning = Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
  })

  local flexChild = Gui.new({
    parent = flexParent,
    w = 100,
    h = 50,
    positioning = Positioning.FLEX,
  })

  local absoluteChild = Gui.new({
    parent = flexParent,
    x = 300,
    y = 150,
    w = 80,
    h = 40,
    positioning = Positioning.ABSOLUTE,
  })

  -- Absolute child should maintain its coordinates
  luaunit.assertEquals(absoluteChild.x, 300)
  luaunit.assertEquals(absoluteChild.y, 150)
  luaunit.assertEquals(absoluteChild.positioning, Positioning.ABSOLUTE)

  -- Both children should be in parent
  luaunit.assertEquals(#flexParent.children, 2)
end

-- Test 15: Large coordinate values
function TestAbsolutePositioningBasic:testLargeCoordinateValues()
  local elem = Gui.new({
    x = 9999,
    y = 8888,
    w = 100,
    h = 100,
    z = 1000,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.x, 9999)
  luaunit.assertEquals(elem.y, 8888)
  luaunit.assertEquals(elem.z, 1000)
end

luaunit.LuaUnit.run()
