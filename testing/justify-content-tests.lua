package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for justify content alignment properties
TestJustifyContent = {}

function TestJustifyContent:testFlexStartJustifyContent()
  -- Create a horizontal flex container with flex-start justify content
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add multiple children
  local child1 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout children
  window:layoutChildren()

  -- With flex-start, children should start at the beginning of the container
  luaunit.assertEquals(child1.x, 0) -- First child at start position
end

function TestJustifyContent:testCenterJustifyContent()
  -- Create a horizontal flex container with center justify content
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add multiple children
  local child1 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout children
  window:layoutChildren()

  -- With center, children should be centered in the container
  -- Calculate expected position based on container width and child sizes
  local totalWidth = 50 + 60 + 10 -- child1.width + child2.width + gap
  local containerWidth = 300
  local expectedPosition = (containerWidth - totalWidth) / 2

  luaunit.assertEquals(child1.x, expectedPosition)
end

function TestJustifyContent:testFlexEndJustifyContent()
  -- Create a horizontal flex container with flex-end justify content
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_END,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add multiple children
  local child1 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout children
  window:layoutChildren()

  -- With flex-end, children should be positioned at the end of the container
  local totalWidth = 50 + 60 + 10 -- child1.width + child2.width + gap
  local containerWidth = 300
  local expectedPosition = containerWidth - totalWidth

  luaunit.assertEquals(child1.x, expectedPosition)
end

function TestJustifyContent:testSpaceAroundJustifyContent()
  -- Create a horizontal flex container with space-around justify content
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_AROUND,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add multiple children
  local child1 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout children
  window:layoutChildren()

  -- With space-around, there should be equal spacing around each child
  -- This is a basic test to ensure the function doesn't crash and children are positioned
  luaunit.assertNotNil(child1.x)
end

function TestJustifyContent:testSpaceEvenlyJustifyContent()
  -- Create a horizontal flex container with space-evenly justify content
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add multiple children
  local child1 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout children
  window:layoutChildren()

  -- With space-evenly, there should be equal spacing between each child
  -- This is a basic test to ensure the function doesn't crash and children are positioned
  luaunit.assertNotNil(child1.x)
end

function TestJustifyContent:testSpaceBetweenJustifyContent()
  -- Create a horizontal flex container with space-between justify content
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add multiple children
  local child1 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout children
  window:layoutChildren()

  -- With space-between, there should be equal spacing between each child
  -- This is a basic test to ensure the function doesn't crash and children are positioned
  luaunit.assertNotNil(child1.x)
end

function TestJustifyContent:testVerticalJustifyContent()
  -- Create a vertical flex container with justify content properties
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add multiple children
  local child1 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout children
  window:layoutChildren()

  -- With vertical container, justify content affects the Y axis
  luaunit.assertNotNil(child1.y)
end

-- Run the tests
luaunit.LuaUnit.run()
