package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for align items alignment properties
TestAlignItems = {}

function TestAlignItems:testStretchAlignItems()
  -- Create a horizontal flex container with stretch align items
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

  -- Add multiple children with different heights
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

  -- With stretch, children should be stretched to fill the container height
  luaunit.assertEquals(child1.height, 200) -- Should stretch to full container height
  luaunit.assertEquals(child2.height, 200) -- Should stretch to full container height
end

function TestAlignItems:testFlexStartAlignItems()
  -- Create a horizontal flex container with flex-start align items
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.FLEX_START,
  })

  -- Add multiple children with different heights
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

  -- With flex-start, children should be aligned to the start of the cross axis (top)
  luaunit.assertEquals(child1.y, 0) -- Should be at top position
  luaunit.assertEquals(child2.y, 0) -- Should be at top position
end

function TestAlignItems:testFlexEndAlignItems()
  -- Create a horizontal flex container with flex-end align items
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.FLEX_END,
  })

  -- Add multiple children with different heights
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

  -- With flex-end, children should be aligned to the end of the cross axis (bottom)
  luaunit.assertEquals(child1.y, 200 - 30) -- Should be at bottom position
  luaunit.assertEquals(child2.y, 200 - 40) -- Should be at bottom position
end

function TestAlignItems:testCenterAlignItems()
  -- Create a horizontal flex container with center align items
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add multiple children with different heights
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

  -- With center, children should be centered along the cross axis
  luaunit.assertEquals(child1.y, (200 - 30) / 2) -- Should be centered vertically
  luaunit.assertEquals(child2.y, (200 - 40) / 2) -- Should be centered vertically
end

function TestAlignItems:testVerticalAlignItems()
  -- Create a vertical flex container with align items properties
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add multiple children with different widths
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

  -- With vertical container, align items affects the X axis
  luaunit.assertEquals(child1.x, (300 - 50) / 2) -- Should be centered horizontally
  luaunit.assertEquals(child2.x, (300 - 60) / 2) -- Should be centered horizontally
end

function TestAlignItems:testAlignItemsInheritance()
  -- Create a parent with stretch alignment
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

  -- Create a child without explicit alignment (should inherit)
  local child = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
  })

  -- Verify child inherits align items from parent
  luaunit.assertEquals(child.alignItems, enums.AlignItems.STRETCH)
end

-- Run the tests
luaunit.LuaUnit.run()
