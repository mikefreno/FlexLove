package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")

-- Import the love stub and FlexLove
require("testing.loveStub")
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local FlexWrap = enums.FlexWrap
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems
local AlignContent = enums.AlignContent

-- Test class for FlexWrap functionality
TestFlexWrap = {}

function TestFlexWrap:setUp()
    -- Clear any previous state if needed
    Gui.destroy()
end

function TestFlexWrap:tearDown()
    -- Clean up after each test
    Gui.destroy()
end

-- Test utilities
local function createContainer(props)
  return Gui.new(props)
end

local function createChild(parent, props)
  local child = Gui.new(props)
  child.parent = parent
  table.insert(parent.children, child)
  return child
end

local function layoutAndGetPositions(container)
  container:layoutChildren()
  local positions = {}
  for i, child in ipairs(container.children) do
    positions[i] = {x = child.x, y = child.y, width = child.width, height = child.height}
  end
  return positions
end

-- Test Case 1: NOWRAP - Children should not wrap (default behavior)
function TestFlexWrap01_NoWrapHorizontal()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.NOWRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    gap = 10
  })

  -- Create children that would overflow if wrapped
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30})

  local positions = layoutAndGetPositions(container)

  -- All children should be on one line, even if they overflow
  luaunit.assertEquals(positions[1].x, 0) -- child1 x
  luaunit.assertEquals(positions[1].y, 0) -- child1 y
  
  luaunit.assertEquals(positions[2].x, 90) -- child2 x (80 + 10 gap)
  luaunit.assertEquals(positions[2].y, 0) -- child2 y
  
  luaunit.assertEquals(positions[3].x, 180) -- child3 x (160 + 10 gap) - overflows container
  luaunit.assertEquals(positions[3].y, 0) -- child3 y
end

-- Test Case 2: WRAP - Children should wrap to new lines
function TestFlexWrap02_WrapHorizontal()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30}) -- This should wrap

  local positions = layoutAndGetPositions(container)

  -- First two children on first line
  luaunit.assertEquals(positions[1].x, 0) -- child1 x
  luaunit.assertEquals(positions[1].y, 0) -- child1 y
  
  luaunit.assertEquals(positions[2].x, 90) -- child2 x (80 + 10 gap)
  luaunit.assertEquals(positions[2].y, 0) -- child2 y
  
  -- Third child wrapped to second line
  luaunit.assertEquals(positions[3].x, 0) -- child3 x - starts new line
  luaunit.assertEquals(positions[3].y, 40) -- child3 y - new line (30 height + 10 gap)
end

-- Test Case 3: WRAP_REVERSE - Lines should be in reverse order
function TestFlexWrap03_WrapReverseHorizontal()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP_REVERSE,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30}) -- This would wrap but lines are reversed

  local positions = layoutAndGetPositions(container)

  -- With wrap-reverse, the wrapped line comes first
  luaunit.assertEquals(positions[3].x, 0) -- child3 x - wrapped line comes first
  luaunit.assertEquals(positions[3].y, 0) -- child3 y - first line position
  
  luaunit.assertEquals(positions[1].x, 0) -- child1 x - original first line comes second
  luaunit.assertEquals(positions[1].y, 40) -- child1 y - second line (30 height + 10 gap)
  
  luaunit.assertEquals(positions[2].x, 90) -- child2 x
  luaunit.assertEquals(positions[2].y, 40) -- child2 y
end

-- Test Case 4: WRAP with vertical flex direction
function TestFlexWrap04_WrapVertical()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap vertically
  local child1 = createChild(container, {w = 30, h = 40})
  local child2 = createChild(container, {w = 30, h = 40})
  local child3 = createChild(container, {w = 30, h = 40}) -- This should wrap to new column

  local positions = layoutAndGetPositions(container)

  -- First two children in first column
  luaunit.assertEquals(positions[1].x, 0) -- child1 x
  luaunit.assertEquals(positions[1].y, 0) -- child1 y
  
  luaunit.assertEquals(positions[2].x, 0) -- child2 x
  luaunit.assertEquals(positions[2].y, 50) -- child2 y (40 + 10 gap)
  
  -- Third child wrapped to second column
  luaunit.assertEquals(positions[3].x, 40) -- child3 x - new column (30 width + 10 gap)
  luaunit.assertEquals(positions[3].y, 0) -- child3 y - starts at top of new column
end

-- Test Case 5: WRAP with CENTER justify content
function TestFlexWrap05_WrapWithCenterJustify()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 60, h = 30}) -- Different width, should wrap

  local positions = layoutAndGetPositions(container)

  -- First line: two children centered
  -- Available space for first line: 200 - (80 + 10 + 80) = 30
  -- Center position: 30/2 = 15
  luaunit.assertEquals(positions[1].x, 15) -- child1 x - centered
  luaunit.assertEquals(positions[1].y, 0) -- child1 y
  
  luaunit.assertEquals(positions[2].x, 105) -- child2 x (15 + 80 + 10)
  luaunit.assertEquals(positions[2].y, 0) -- child2 y
  
  -- Second line: one child centered
  -- Available space for second line: 200 - 60 = 140
  -- Center position: 140/2 = 70
  luaunit.assertEquals(positions[3].x, 70) -- child3 x - centered in its line
  luaunit.assertEquals(positions[3].y, 40) -- child3 y - second line
end

-- Test Case 6: WRAP with SPACE_BETWEEN align content
function TestFlexWrap06_WrapWithSpaceBetweenAlignContent()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.SPACE_BETWEEN,
    gap = 10
  })

  -- Create children that will wrap into two lines
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30}) -- This should wrap

  local positions = layoutAndGetPositions(container)

  -- First line at top
  luaunit.assertEquals(positions[1].y, 0) -- child1 y
  luaunit.assertEquals(positions[2].y, 0) -- child2 y
  
  -- Second line at bottom
  -- Total lines height: 30 + 30 = 60, gaps: 10
  -- Available space: 120 - 70 = 50
  -- Second line position: 30 + 50 + 10 = 90
  luaunit.assertEquals(positions[3].y, 90) -- child3 y - at bottom with space between
end

-- Test Case 7: WRAP with STRETCH align items
function TestFlexWrap07_WrapWithStretchAlignItems()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children with different heights
  local child1 = createChild(container, {w = 80, h = 20})
  local child2 = createChild(container, {w = 80, h = 35}) -- Tallest in first line
  local child3 = createChild(container, {w = 80, h = 25}) -- Wraps to second line

  local positions = layoutAndGetPositions(container)

  -- All children in first line should stretch to tallest (35)
  luaunit.assertEquals(positions[1].height, 35) -- child1 stretched
  luaunit.assertEquals(positions[2].height, 35) -- child2 keeps height
  
  -- Child in second line should keep its height (no other children to stretch to)
  luaunit.assertEquals(positions[3].height, 25) -- child3 original height
  
  -- Verify positions
  luaunit.assertEquals(positions[1].y, 0) -- First line
  luaunit.assertEquals(positions[2].y, 0) -- First line
  luaunit.assertEquals(positions[3].y, 45) -- Second line (35 + 10 gap)
end

-- Test Case 8: WRAP with coordinate inheritance
function TestFlexWrap08_WrapWithCoordinateInheritance()
  local container = createContainer({
    x = 50, y = 30, w = 200, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30}) -- This should wrap

  local positions = layoutAndGetPositions(container)

  -- All coordinates should be relative to container position
  luaunit.assertEquals(positions[1].x, 50) -- child1 x (container.x + 0)
  luaunit.assertEquals(positions[1].y, 30) -- child1 y (container.y + 0)
  
  luaunit.assertEquals(positions[2].x, 140) -- child2 x (container.x + 90)
  luaunit.assertEquals(positions[2].y, 30) -- child2 y (container.y + 0)
  
  luaunit.assertEquals(positions[3].x, 50) -- child3 x (container.x + 0) - wrapped
  luaunit.assertEquals(positions[3].y, 70) -- child3 y (container.y + 40) - new line
end

-- Test Case 9: WRAP with padding
function TestFlexWrap09_WrapWithPadding()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 100,
    padding = {top = 15, right = 15, bottom = 15, left = 15},
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap (considering reduced available space)
  local child1 = createChild(container, {w = 70, h = 25})
  local child2 = createChild(container, {w = 70, h = 25})
  local child3 = createChild(container, {w = 70, h = 25}) -- Should wrap due to padding

  local positions = layoutAndGetPositions(container)

  -- Available width: 200 - 15 - 15 = 170
  -- Two children fit: 70 + 10 + 70 = 150 < 170
  luaunit.assertEquals(positions[1].x, 15) -- child1 x (padding.left)
  luaunit.assertEquals(positions[1].y, 15) -- child1 y (padding.top)
  
  luaunit.assertEquals(positions[2].x, 95) -- child2 x (15 + 70 + 10)
  luaunit.assertEquals(positions[2].y, 15) -- child2 y (padding.top)
  
  -- Third child should wrap
  luaunit.assertEquals(positions[3].x, 15) -- child3 x (padding.left)
  luaunit.assertEquals(positions[3].y, 50) -- child3 y (15 + 25 + 10)
end

-- Test Case 10: WRAP with SPACE_AROUND align content
function TestFlexWrap10_WrapWithSpaceAroundAlignContent()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.SPACE_AROUND,
    gap = 10
  })

  -- Create children that will wrap into two lines
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30}) -- This should wrap

  local positions = layoutAndGetPositions(container)

  -- Total lines height: 30 + 30 = 60, gaps: 10, total content: 70
  -- Available space: 100 - 70 = 30
  -- Space around each line: 30/2 = 15
  -- First line at: 15/2 = 7.5, Second line at: 30 + 10 + 15 + 15/2 = 62.5

  luaunit.assertEquals(positions[1].y, 7.5) -- child1 y
  luaunit.assertEquals(positions[2].y, 7.5) -- child2 y
  luaunit.assertEquals(positions[3].y, 62.5) -- child3 y
end

-- Test Case 11: Single child with WRAP (should behave like NOWRAP)
function TestFlexWrap11_SingleChildWrap()
  local container = createContainer({
    x = 0, y = 0, w = 100, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    gap = 10
  })

  local child1 = createChild(container, {w = 50, h = 30})

  local positions = layoutAndGetPositions(container)

  -- Single child should be centered
  luaunit.assertEquals(positions[1].x, 25) -- child1 x - centered
  luaunit.assertEquals(positions[1].y, 35) -- child1 y - centered
end

-- Test Case 12: Multiple wrapping lines
function TestFlexWrap12_MultipleWrappingLines()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap into three lines
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30})
  local child4 = createChild(container, {w = 80, h = 30})
  local child5 = createChild(container, {w = 80, h = 30})

  local positions = layoutAndGetPositions(container)

  -- First line
  luaunit.assertEquals(positions[1].y, 0) -- child1 y
  luaunit.assertEquals(positions[2].y, 0) -- child2 y
  
  -- Second line
  luaunit.assertEquals(positions[3].y, 40) -- child3 y (30 + 10)
  luaunit.assertEquals(positions[4].y, 40) -- child4 y
  
  -- Third line
  luaunit.assertEquals(positions[5].y, 80) -- child5 y (40 + 30 + 10)
end

-- Test Case 13: WRAP_REVERSE with multiple lines
function TestFlexWrap13_WrapReverseMultipleLines()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP_REVERSE,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create children that will wrap into three lines
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})
  local child3 = createChild(container, {w = 80, h = 30})
  local child4 = createChild(container, {w = 80, h = 30})
  local child5 = createChild(container, {w = 80, h = 30})

  local positions = layoutAndGetPositions(container)

  -- With wrap-reverse, lines are reversed: Line 3, Line 2, Line 1
  luaunit.assertEquals(positions[5].y, 0) -- child5 y - third line comes first
  
  luaunit.assertEquals(positions[3].y, 40) -- child3 y - second line in middle
  luaunit.assertEquals(positions[4].y, 40) -- child4 y
  
  luaunit.assertEquals(positions[1].y, 80) -- child1 y - first line comes last
  luaunit.assertEquals(positions[2].y, 80) -- child2 y
end

-- Test Case 14: Edge case - container too small for any children
function TestFlexWrap14_ContainerTooSmall()
  local container = createContainer({
    x = 0, y = 0, w = 50, h = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    gap = 10
  })

  -- Create children larger than container
  local child1 = createChild(container, {w = 80, h = 30})
  local child2 = createChild(container, {w = 80, h = 30})

  local positions = layoutAndGetPositions(container)

  -- Each child should be on its own line since none fit
  luaunit.assertEquals(positions[1].x, 0) -- child1 x
  luaunit.assertEquals(positions[1].y, 0) -- child1 y
  
  luaunit.assertEquals(positions[2].x, 0) -- child2 x
  luaunit.assertEquals(positions[2].y, 40) -- child2 y (30 + 10)
end

-- Test Case 15: WRAP with mixed positioning children
function TestFlexWrap15_WrapWithMixedPositioning()
  local container = createContainer({
    x = 0, y = 0, w = 200, h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 10
  })

  -- Create flex children and one absolute child
  local child1 = createChild(container, {w = 80, h = 30}) -- flex child
  local child2 = createChild(container, {w = 80, h = 30, positioning = Positioning.ABSOLUTE, x = 150, y = 50}) -- absolute child
  local child3 = createChild(container, {w = 80, h = 30}) -- flex child
  local child4 = createChild(container, {w = 80, h = 30}) -- flex child - should wrap

  local positions = layoutAndGetPositions(container)

  -- Only flex children should participate in wrapping
  luaunit.assertEquals(positions[1].y, 0) -- child1 y - first line
  luaunit.assertEquals(positions[2].x, 150) -- child2 x - absolute positioned, not affected by flex
  luaunit.assertEquals(positions[2].y, 50) -- child2 y - absolute positioned
  luaunit.assertEquals(positions[3].y, 0) -- child3 y - first line (child2 doesn't count for flex)
  luaunit.assertEquals(positions[4].y, 40) -- child4 y - wrapped to second line
end

-- Run the tests
print("=== Running FlexWrap Tests ===")
luaunit.LuaUnit.run()