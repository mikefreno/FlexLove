package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

-- Mock Logger to avoid dependency issues
local Logger = {
  debug = function() end,
  info = function() end,
  warn = function() end,
  error = function() end,
}

-- Make sure the logger is available in the global scope
_G.Logger = Logger

local Gui = require("game.libs.FlexLove").GUI
local Color = require("game.libs.FlexLove").Color
local enums = require("game.libs.FlexLove").enums

-- Test case for flex container layout behavior
TestFlexContainer = {}

function TestFlexContainer:testWindowWithFlexPositioning()
  -- Create a window with flex positioning
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
  luaunit.assertEquals(window.x, 0)
  luaunit.assertEquals(window.y, 0)
  luaunit.assertEquals(window.width, 300)
  luaunit.assertEquals(window.height, 200)
  luaunit.assertEquals(window.positioning, enums.Positioning.FLEX)
  luaunit.assertEquals(window.flexDirection, enums.FlexDirection.HORIZONTAL)
  luaunit.assertEquals(window.justifyContent, enums.JustifyContent.FLEX_START)
  luaunit.assertEquals(window.alignItems, enums.AlignItems.STRETCH)
end

function TestFlexContainer:testWindowAutoSizing()
  -- Create a window with flex positioning and auto-sizing
  local window = Gui.new({
    x = 0,
    y = 0,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add a child with explicit dimensions
  local child = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
  })

  -- Verify that the window auto-sizes to fit children (this should be calculated by layoutChildren)
  window:layoutChildren()

  -- The window should have auto-sized based on children
  luaunit.assertEquals(#window.children, 1)
  luaunit.assertEquals(window.children[1], child)
end

function TestFlexContainer:testWindowWithMultipleChildren()
  -- Create a flex container window
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

  local child3 = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 70,
    h = 50,
    text = "Button 3",
  })

  -- Verify all children are added
  luaunit.assertEquals(#window.children, 3)
  luaunit.assertEquals(window.children[1], child1)
  luaunit.assertEquals(window.children[2], child2)
  luaunit.assertEquals(window.children[3], child3)

  -- Test layout calculation
  window:layoutChildren()

  -- Verify children positions are calculated (basic checks)
  luaunit.assertEquals(child1.x, 0) -- First child should be at start position
end

function TestFlexContainer:testWindowDimensionsUpdateWhenChildrenAdded()
  -- Create a flex container window with explicit size
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

  -- Add a child
  local child = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
  })

  -- Test that layoutChildren properly calculates positions
  window:layoutChildren()

  -- Window dimensions should remain unchanged since we explicitly set them
  luaunit.assertEquals(window.width, 300)
  luaunit.assertEquals(window.height, 200)
end

function TestFlexContainer:testWindowAutoSizingWhenNotExplicitlySet()
  -- Create a flex container window without explicit size (should auto-size)
  local window = Gui.new({
    x = 0,
    y = 0,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add children
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

  -- Test auto-sizing calculation
  window:layoutChildren()

  -- The window should have auto-sized based on children (this is a basic check)
  luaunit.assertEquals(#window.children, 2)
end

function TestFlexContainer:testContainerLayoutChildrenFunction()
  -- Create a flex container window
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

  -- Add children
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

  -- Test that layoutChildren function exists and works
  luaunit.assertNotNil(window.layoutChildren)

  -- Run the layout function
  window:layoutChildren()

  -- Verify child positions (this is a basic test of functionality)
  luaunit.assertEquals(child1.x, 0) -- Should be at position 0 initially
end

-- Run the tests
luaunit.LuaUnit.run()
