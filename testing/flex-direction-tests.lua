package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for flex direction properties
TestFlexDirection = {}

function TestFlexDirection:testHorizontalFlexDirection()
  -- Create a window with horizontal flex direction
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

  -- Verify window properties
  luaunit.assertEquals(window.flexDirection, enums.FlexDirection.HORIZONTAL)
end

function TestFlexDirection:testVerticalFlexDirection()
  -- Create a window with vertical flex direction
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Verify window properties
  luaunit.assertEquals(window.flexDirection, enums.FlexDirection.VERTICAL)
end

function TestFlexDirection:testHorizontalLayoutChildren()
  -- Create a horizontal flex container
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

  -- Verify positions for horizontal layout (children should be placed side by side)
  -- In CSS, horizontal flex direction means children are laid out from left to right
  luaunit.assertAlmostEquals(child1.x, 0) -- First child at start position
  luaunit.assertAlmostEquals(child1.y, 0) -- First child at top position

  -- Second child should be positioned after first child + gap
  luaunit.assertAlmostEquals(child2.x, child1.w + window.gap) -- child1 width + gap
  luaunit.assertAlmostEquals(child2.y, 0) -- Same y position as first child
end

function TestFlexDirection:testVerticalLayoutChildren()
  -- Create a vertical flex container
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
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

  -- Verify positions for vertical layout (children should be placed one below another)
  -- In CSS, vertical flex direction means children are laid out from top to bottom
  luaunit.assertAlmostEquals(child1.x, 0) -- First child at left position
  luaunit.assertAlmostEquals(child1.y, 0) -- First child at start position

  -- Second child should be positioned after first child + gap
  luaunit.assertAlmostEquals(child2.x, 0) -- Same x position as first child
  luaunit.assertAlmostEquals(child2.y, child1.h + window.gap) -- child1 height + gap
end

function TestFlexDirection:testFlexDirectionInheritance()
  -- Create a parent with horizontal direction
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a child without explicit direction (should inherit)
  local child = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
  })

  -- Verify child inherits flex direction from parent
  -- CSS inheritance means child should inherit the flex direction from its parent
  luaunit.assertEquals(child.flexDirection, parentWindow.flexDirection)
end

-- Run the tests
luaunit.LuaUnit.run()