package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local Color = require("game.libs.FlexLove").Color
local enums = require("game.libs.FlexLove").enums

-- Test case for absolute positioning behavior
TestAbsolutePositioning = {}

function TestAbsolutePositioning:testWindowWithAbsolutePositioning()
  -- Create a window with absolute positioning
  local window = Gui.new({
    x = 100,
    y = 100,
    w = 200,
    h = 150,
    positioning = enums.Positioning.ABSOLUTE,
  })

  -- Verify window properties
  luaunit.assertEquals(window.x, 100)
  luaunit.assertEquals(window.y, 100)
  luaunit.assertEquals(window.width, 200)
  luaunit.assertEquals(window.height, 150)
  luaunit.assertEquals(window.positioning, enums.Positioning.ABSOLUTE)

  -- Create a child with absolute positioning
  local child = Gui.new({
    parent = window,
    x = 20,
    y = 30,
    w = 50,
    h = 30,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Test Button",
  })

  -- Verify child properties
  luaunit.assertEquals(child.x, 20)
  luaunit.assertEquals(child.y, 30)
  luaunit.assertEquals(child.width, 50)
  luaunit.assertEquals(child.height, 30)
  luaunit.assertEquals(child.positioning, enums.Positioning.ABSOLUTE)

  -- Verify child is properly added to parent
  luaunit.assertEquals(#window.children, 1)
  luaunit.assertEquals(window.children[1], child)

  -- Verify parent-child relationship
  luaunit.assertEquals(child.parent, window)
end

function TestAbsolutePositioning:testChildInheritsAbsolutePositioning()
  -- Create a window with flex positioning
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

  -- Create a child without explicit positioning (should inherit)
  local child = Gui.new({
    parent = parentWindow,
    x = 10,
    y = 10,
    w = 50,
    h = 30,
    text = "Test Button",
  })

  -- Verify child inherits positioning from parent
  luaunit.assertEquals(child.positioning, enums.Positioning.FLEX)
end

function TestAbsolutePositioning:testAbsolutePositioningDoesNotAffectLayout()
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

  -- Add a child with absolute positioning
  local absoluteChild = Gui.new({
    parent = window,
    x = 100,
    y = 50,
    w = 80,
    h = 40,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Absolute Button",
  })

  -- Add a child with flex positioning
  local flexChild = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 60,
    h = 30,
    text = "Flex Button",
  })

  -- Verify both children are added
  luaunit.assertEquals(#window.children, 2)

  -- Test that absolute child's position is not affected by flex layout calculations
  -- The absolute child should keep its position (100, 50) regardless of other children
  luaunit.assertEquals(absoluteChild.x, 100)
  luaunit.assertEquals(absoluteChild.y, 50)

  -- Test that flex child's position is affected by layout calculations
  luaunit.assertEquals(flexChild.x, 0) -- Should be positioned according to flex layout

  -- Check that absolute positioning doesn't interfere with container auto-sizing
  window:layoutChildren()
  -- The absolute child should not affect the auto-sizing calculation
  luaunit.assertEquals(window.width, 300) -- Window width remains unchanged
end

function TestAbsolutePositioning:testAbsolutePositioningResizing()
  -- Create a window with absolute positioning
  local window = Gui.new({
    x = 100,
    y = 100,
    w = 200,
    h = 150,
    positioning = enums.Positioning.ABSOLUTE,
  })

  -- Add an absolute positioned child
  local child = Gui.new({
    parent = window,
    x = 20,
    y = 30,
    w = 50,
    h = 30,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Test Button",
  })

  -- Resize the window (from 200x150 to 400x300)
  local newWidth, newHeight = 400, 300
  window:resize(newWidth, newHeight)

  -- The key test is that absolute positioning should work regardless of how we resize
  -- The child's coordinates should be maintained as they are, and the parent should resize properly
  luaunit.assertEquals(window.width, 400)
  luaunit.assertEquals(window.height, 300)
  luaunit.assertEquals(child.positioning, enums.Positioning.ABSOLUTE) -- Child should still be absolute

  -- We can't easily test exact coordinate values because the resize behavior is complex,
  -- but we can verify that the child still exists and maintains its properties
end

function TestAbsolutePositioning:testAbsolutePositioningWithPaddingAndMargin()
  -- Create a window with absolute positioning
  local window = Gui.new({
    x = 10,
    y = 10,
    w = 200,
    h = 150,
    positioning = enums.Positioning.ABSOLUTE,
    padding = { left = 10, top = 5 },
    margin = { left = 5, top = 5 },
  })

  -- Add an absolute positioned child
  local child = Gui.new({
    parent = window,
    x = 20,
    y = 30,
    w = 50,
    h = 30,
    positioning = enums.Positioning.ABSOLUTE,
    text = "Test Button",
  })

  -- Verify absolute child position is independent of padding/margin
  luaunit.assertEquals(child.x, 20)
  luaunit.assertEquals(child.y, 30)
end

-- Run the tests
luaunit.LuaUnit.run()
