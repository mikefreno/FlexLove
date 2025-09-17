package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for nested flex layouts
TestNestedLayouts = {}

function TestNestedLayouts:testSimpleNestedFlex()
  -- Create a parent window with horizontal flex direction
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

  -- Create a child window (nested flex container)
  local childWindow = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add children to nested window
  local child1 = Gui.new({
    parent = childWindow,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = childWindow,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the nested window is positioned correctly within parent
  luaunit.assertEquals(childWindow.x, 0) -- Should be positioned at start of parent
  luaunit.assertEquals(childWindow.y, 0) -- Should be positioned at start of parent

  -- Verify that nested children are laid out correctly
  luaunit.assertEquals(child1.x, 0) -- Nested child should be at left position
  luaunit.assertEquals(child1.y, 0) -- Nested child should be at top position

  luaunit.assertEquals(child2.x, 0) -- Nested child should be at left position
  luaunit.assertEquals(child2.y, 30 + 10) -- Should be positioned after first child + gap
end

function TestNestedLayouts:testDeeplyNestedFlex()
  -- Create a parent window with horizontal flex direction
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

  -- Create a nested window
  local nestedWindow = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Create a deeply nested window
  local deepNestedWindow = Gui.new({
    parent = nestedWindow,
    x = 0,
    y = 0,
    w = 75,
    h = 50,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add children to deep nested window
  local child1 = Gui.new({
    parent = deepNestedWindow,
    x = 0,
    y = 0,
    w = 20,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = deepNestedWindow,
    x = 0,
    y = 0,
    w = 30,
    h = 40,
    text = "Button 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify nested structure and positioning
  luaunit.assertEquals(nestedWindow.x, 0)
  luaunit.assertEquals(nestedWindow.y, 0)

  luaunit.assertEquals(deepNestedWindow.x, 0)
  luaunit.assertEquals(deepNestedWindow.y, 0)

  -- Verify that deep nested children are laid out correctly
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, (50 - 30) / 2) -- Should be centered vertically

  luaunit.assertEquals(child2.x, 20 + 10) -- Should be positioned after first child + gap
  luaunit.assertEquals(child2.y, (50 - 40) / 2) -- Should be centered vertically
end

function TestNestedLayouts:testNestedFlexWithDifferentDirections()
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

  -- Create a nested window with vertical direction
  local childWindow = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add children to nested window with different sizes
  local child1 = Gui.new({
    parent = childWindow,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = childWindow,
    x = 0,
    y = 0,
    w = 60,
    h = 40,
    text = "Button 2",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that the nested container properly layouts its children vertically
  luaunit.assertEquals(child1.x, 0) -- Should be at left position
  luaunit.assertEquals(child1.y, 0) -- Should be at top position

  luaunit.assertEquals(child2.x, 0) -- Should be at left position
  luaunit.assertEquals(child2.y, 30 + 10) -- Should be positioned after first child + gap

  -- Verify that the parent container positions its children horizontally
  luaunit.assertEquals(childWindow.x, 0) -- Should be at start of parent
end

function TestNestedLayouts:testInheritanceOfPropertiesInNestedLayouts()
  -- Create a parent with specific flex properties
  local parentWindow = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.CENTER,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Create a nested window without explicit properties (should inherit)
  local childWindow = Gui.new({
    parent = parentWindow,
    x = 0,
    y = 0,
    w = 150,
    h = 100,
    positioning = enums.Positioning.FLEX,
  })

  -- Add children to nested window
  local child1 = Gui.new({
    parent = childWindow,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that nested window inherited properties from parent
  luaunit.assertEquals(childWindow.flexDirection, enums.FlexDirection.HORIZONTAL)
  luaunit.assertEquals(childWindow.justifyContent, enums.JustifyContent.CENTER)
  luaunit.assertEquals(childWindow.alignItems, enums.AlignItems.STRETCH)
end

function TestNestedLayouts:testAbsolutePositioningInNestedLayout()
  -- Create a parent with flex direction
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

  -- Create a nested window with absolute positioning
  local childWindow = Gui.new({
    parent = parentWindow,
    x = 50,
    y = 50,
    w = 150,
    h = 100,
    positioning = enums.Positioning.ABSOLUTE,
  })

  -- Add children to nested window
  local child1 = Gui.new({
    parent = childWindow,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Button 1",
  })

  -- Layout all children
  parentWindow:layoutChildren()

  -- Verify that absolute positioned nested window maintains its position
  luaunit.assertEquals(childWindow.x, 50)
  luaunit.assertEquals(childWindow.y, 50)

  -- Verify that absolute positioning doesn't interfere with parent layout
  luaunit.assertEquals(parentWindow.children[1], childWindow)
end

-- Run the tests
os.exit(luaunit.LuaUnit.run())

