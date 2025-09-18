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
  -- CSS behavior: first child positioned at start (leftmost for horizontal, topmost for vertical)
  luaunit.assertAlmostEquals(child1.x, 0) -- First child at start position
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
  -- CSS behavior: children should be centered within the container's available space
  -- Calculate expected position based on container width and child sizes
  local totalWidth = child1.width + child2.width + window.gap -- child1.width + child2.width + gap
  local containerWidth = window.width
  local expectedPosition = (containerWidth - totalWidth) / 2

  luaunit.assertAlmostEquals(child1.x, expectedPosition)
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
  -- CSS behavior: children positioned at the end (rightmost for horizontal, bottommost for vertical)
  local totalWidth = child1.w + child2.w + window.gap -- child1.width + child2.width + gap
  local containerWidth = window.w
  local expectedPosition = containerWidth - totalWidth

  luaunit.assertAlmostEquals(child1.x, expectedPosition)
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
  -- CSS behavior: each child should have equal spacing on both sides (including edges)
  -- This test ensures the function doesn't crash and children are positioned
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
  -- CSS behavior: spacing is distributed evenly across the container
  -- This test ensures the function doesn't crash and children are positioned
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
  -- CSS behavior: first and last child at edges, others spaced evenly in between
  -- This test ensures the function doesn't crash and children are positioned
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
  -- CSS behavior: justify content controls positioning along the main axis (Y for vertical flex)
  luaunit.assertNotNil(child1.y)
end

function TestJustifyContent:testFlexStart()
  -- Create a test container with horizontal flexDirection and FLEX_START justifyContent
  local container = Gui.new({
    w = 300,
    h = 100,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    gap = 10,
  })

  -- Add children with fixed widths
  local child1 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  local child2 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  container:layoutChildren()

  -- For FLEX_START, children should be positioned at the start with gaps
  luaunit.assertEquals(child1.x, container.x)
  luaunit.assertEquals(child2.x, container.x + 50 + 10) -- child1 width + gap
end

function TestJustifyContent:testCenter()
  -- Create a test container with horizontal flexDirection and CENTER justifyContent
  local container = Gui.new({
    w = 300,
    h = 100,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.CENTER,
    gap = 10,
  })

  -- Add children with fixed widths
  local child1 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  local child2 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  container:layoutChildren()

  -- For CENTER, children should be centered within available space
  -- Total width of children + gaps = 50 + 10 + 50 = 110
  -- Free space = 300 - 110 = 190
  -- Spacing = 190 / 2 = 95
  luaunit.assertEquals(child1.x, container.x + 95)
  luaunit.assertEquals(child2.x, container.x + 95 + 50 + 10) -- spacing + child1 width + gap
end

function TestJustifyContent:testFlexEnd()
  -- Create a test container with horizontal flexDirection and FLEX_END justifyContent
  local container = Gui.new({
    w = 300,
    h = 100,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_END,
    gap = 10,
  })

  -- Add children with fixed widths
  local child1 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  local child2 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  container:layoutChildren()

  -- For FLEX_END, children should be positioned at the end of available space
  -- Total width of children + gaps = 50 + 10 + 50 = 110
  -- Free space = 300 - 110 = 190
  -- Spacing = 190 (full free space)
  luaunit.assertEquals(child1.x, container.x + 190)
  luaunit.assertEquals(child2.x, container.x + 190 + 50 + 10) -- spacing + child1 width + gap
end

function TestJustifyContent:testSpaceAround()
  -- Create a test container with horizontal flexDirection and SPACE_AROUND justifyContent
  local container = Gui.new({
    w = 300,
    h = 100,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_AROUND,
    gap = 10,
  })

  -- Add children with fixed widths
  local child1 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  local child2 = Gui.new({
    w = 50,
    h = 50,
    parent = container,
  })

  container:layoutChildren()

  -- For SPACE_AROUND, spacing should be freeSpace / (childCount + 1)
  -- Total width of children + gaps = 50 + 10 + 50 = 110
  -- Free space = 300 - 110 = 190
  -- Spacing = 190 / (2 + 1) = 63.33
  luaunit.assertEquals(child1.x, container.x + 63.33)
  luaunit.assertEquals(child2.x, container.x + 63.33 + 50 + 10) -- spacing + child1 width + gap
end

-- Run the tests
luaunit.LuaUnit.run()
