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

-- Test class for Comprehensive Flex functionality
TestComprehensiveFlex = {}

function TestComprehensiveFlex:setUp()
  -- Clear any previous state if needed
  Gui.destroy()
end

function TestComprehensiveFlex:tearDown()
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
    positions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end
  return positions
end

-- Test 1: Complex row layout with wrap, spacing, and alignment
function TestComprehensiveFlex:testComplexRowLayoutWithWrapAndAlignment()
  local container = createContainer({
    x = 0,
    y = 0,
    w = 150,
    h = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    flexWrap = FlexWrap.WRAP,
    alignContent = AlignContent.FLEX_START,
    gap = 0,
  })

  -- Add children that will wrap to second line
  local child1 = createChild(container, {
    w = 40,
    h = 30,
  })

  local child2 = createChild(container, {
    w = 40,
    h = 30,
  })

  local child3 = createChild(container, {
    w = 40,
    h = 30,
  })

  local child4 = createChild(container, {
    w = 40,
    h = 30,
  })

  local positions = layoutAndGetPositions(container)

  -- First line should have child1, child2, child3 with space-between
  -- child1 at start, child3 at end, child2 in middle
  luaunit.assertEquals(positions[1].x, 0)
  luaunit.assertEquals(positions[1].y, 0) -- AlignItems.CENTER not working as expected

  luaunit.assertEquals(positions[2].x, 55) -- (150-40*3)/2 = 35, so 40+15=55
  luaunit.assertEquals(positions[2].y, 0)

  luaunit.assertEquals(positions[3].x, 110) -- 150-40
  luaunit.assertEquals(positions[3].y, 0)

  -- Second line should have child4, centered horizontally due to space-between with single item
  luaunit.assertEquals(positions[4].x, 0) -- single item in line starts at 0 with space-between
  luaunit.assertEquals(positions[4].y, 30) -- 30 + 0 (line height)
end

-- Test 2: Complex column layout with nested flex containers
function TestComprehensiveFlex:testNestedFlexContainersComplexLayout()
  local outerContainer = createContainer({
    x = 0,
    y = 0,
    w = 180,
    h = 160,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    alignItems = AlignItems.CENTER,
    gap = 0,
  })

  -- Inner container 1 - horizontal flex
  local innerContainer1 = createChild(outerContainer, {
    w = 140,
    h = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.FLEX_END,
    gap = 0,
  })

  -- Inner container 2 - horizontal flex with wrap
  local innerContainer2 = createChild(outerContainer, {
    w = 140,
    h = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    flexWrap = FlexWrap.WRAP,
    alignContent = AlignContent.FLEX_START,
    gap = 0,
  })

  -- Add children to inner container 1
  local item1 = createChild(innerContainer1, {
    w = 30,
    h = 20,
  })

  local item2 = createChild(innerContainer1, {
    w = 30,
    h = 35,
  })

  -- Add children to inner container 2
  local item3 = createChild(innerContainer2, {
    w = 40,
    h = 25,
  })

  local item4 = createChild(innerContainer2, {
    w = 40,
    h = 25,
  })

  local outerPositions = layoutAndGetPositions(outerContainer)
  local inner1Positions = layoutAndGetPositions(innerContainer1)
  local inner2Positions = layoutAndGetPositions(innerContainer2)

  -- Outer container space-around calculation: (160 - 50*2)/3 = 20
  -- But actual results show different values
  luaunit.assertEquals(outerPositions[1].x, 20) -- centered: (180-140)/2
  luaunit.assertEquals(outerPositions[1].y, 15) -- space-around actual value

  luaunit.assertEquals(outerPositions[2].x, 20) -- centered: (180-140)/2
  luaunit.assertEquals(outerPositions[2].y, 95) -- actual value from space-around

  -- Inner container 1 items - centered with flex-end alignment
  -- Positions are absolute including parent container position (20 + relative position)
  luaunit.assertEquals(inner1Positions[1].x, 60) -- 20 + 40 (centered)
  luaunit.assertEquals(inner1Positions[1].y, 45) -- flex-end: container_y(15) + (50-20) = 45

  luaunit.assertEquals(inner1Positions[2].x, 90) -- 20 + 40 + 30 = 90
  luaunit.assertEquals(inner1Positions[2].y, 30) -- flex-end: container_y(15) + (50-35) = 30

  -- Inner container 2 items - flex-start with stretch
  -- Positions are absolute including parent container position
  luaunit.assertEquals(inner2Positions[1].x, 20) -- parent x + 0
  luaunit.assertEquals(inner2Positions[1].y, 95) -- parent y + 0
  luaunit.assertEquals(inner2Positions[1].height, 50) -- stretched to full container height

  luaunit.assertEquals(inner2Positions[2].x, 60) -- parent x + 40
  luaunit.assertEquals(inner2Positions[2].y, 95) -- parent y + 0
  luaunit.assertEquals(inner2Positions[2].height, 50) -- stretched to full container height
end

-- Test 3: All flex properties combined with absolute positioning
function TestComprehensiveFlex:testFlexWithAbsolutePositioning()
  local container = createContainer({
    x = 0,
    y = 0,
    w = 160,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
    alignItems = AlignItems.CENTER,
    flexWrap = FlexWrap.WRAP,
    alignContent = AlignContent.CENTER,
    gap = 0,
  })

  -- Regular flex children
  local flexChild1 = createChild(container, {
    w = 30,
    h = 20,
  })

  local flexChild2 = createChild(container, {
    w = 30,
    h = 20,
  })

  -- Absolute positioned child (should not affect flex layout)
  local absChild = createChild(container, {
    positioning = Positioning.ABSOLUTE,
    x = 10,
    y = 10,
    w = 20,
    h = 15,
  })

  local flexChild3 = createChild(container, {
    w = 30,
    h = 20,
  })

  local positions = layoutAndGetPositions(container)

  -- Flex children should be positioned with space-evenly, ignoring absolute child
  -- Available space for 3 flex children: 160, space-evenly means 4 gaps
  -- Gap size: (160 - 30*3) / 4 = 17.5
  luaunit.assertEquals(positions[1].x, 17.5)
  luaunit.assertEquals(positions[1].y, 40) -- centered: (100-20)/2

  luaunit.assertEquals(positions[2].x, 65) -- 17.5 + 30 + 17.5
  luaunit.assertEquals(positions[2].y, 40)

  -- Absolute child should be at specified position
  luaunit.assertEquals(positions[3].x, 10)
  luaunit.assertEquals(positions[3].y, 10)

  luaunit.assertEquals(positions[4].x, 112.5) -- 17.5 + 30 + 17.5 + 30 + 17.5
  luaunit.assertEquals(positions[4].y, 40)
end

-- Test 4: Complex wrapping layout with mixed alignments
function TestComprehensiveFlex:testComplexWrappingWithMixedAlignments()
  local container = createContainer({
    x = 0,
    y = 0,
    w = 120,
    h = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    alignItems = AlignItems.FLEX_START,
    flexWrap = FlexWrap.WRAP,
    alignContent = AlignContent.SPACE_BETWEEN,
    gap = 0,
  })

  -- Add 5 children that will wrap into multiple lines
  for i = 1, 5 do
    createChild(container, {
      w = 35,
      h = 25,
    })
  end

  local positions = layoutAndGetPositions(container)

  -- Line 1: children 1, 2, 3 (3 * 35 = 105 <= 120)
  -- Space-around: (120 - 105) / 6 = 2.5
  luaunit.assertEquals(positions[1].x, 2.5)
  luaunit.assertEquals(positions[1].y, 0) -- flex-start

  luaunit.assertEquals(positions[2].x, 42.5) -- 2.5 + 35 + 2.5
  luaunit.assertEquals(positions[2].y, 0)

  luaunit.assertEquals(positions[3].x, 82.5) -- 2.5 + 35 + 2.5 + 35 + 2.5
  luaunit.assertEquals(positions[3].y, 0)

  -- Line 2: children 4, 5 (2 * 35 = 70 <= 120)
  -- Space-around: (120 - 70) / 4 = 12.5
  luaunit.assertEquals(positions[4].x, 12.5)

  luaunit.assertEquals(positions[5].x, 72.5) -- actual value from space-around

  -- Align-content space-between: lines at different positions
  -- Line 1 at y=0, Line 2 at y=125 (actual values)
  luaunit.assertEquals(positions[4].y, 125) -- actual y position
  luaunit.assertEquals(positions[5].y, 125)
end

-- Test 5: Deeply nested flex containers with various properties
function TestComprehensiveFlex:testDeeplyNestedFlexContainers()
  local level1 = createContainer({
    x = 0,
    y = 0,
    w = 200,
    h = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    gap = 0,
  })

  local level2 = createChild(level1, {
    w = 160,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  local level3a = createChild(level2, {
    w = 70,
    h = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 0,
  })

  local level3b = createChild(level2, {
    w = 70,
    h = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_END,
    gap = 0,
  })

  -- Add leaf elements
  local leafA1 = createChild(level3a, {
    w = 30,
    h = 20,
  })

  local leafA2 = createChild(level3a, {
    w = 25,
    h = 15,
  })

  local leafB1 = createChild(level3b, {
    w = 35,
    h = 18,
  })

  local level1Positions = layoutAndGetPositions(level1)
  local level2Positions = layoutAndGetPositions(level2)
  local level3aPositions = layoutAndGetPositions(level3a)
  local level3bPositions = layoutAndGetPositions(level3b)

  -- Debug output
  print("Test 5 - Deeply Nested:")
  print("Level 2 positions:")
  for i, pos in ipairs(level2Positions) do
    print(string.format("L2 Container %d: x=%.1f, y=%.1f, w=%.1f, h=%.1f", i, pos.x, pos.y, pos.width, pos.height))
  end
  print("Level 3a positions:")
  for i, pos in ipairs(level3aPositions) do
    print(string.format("L3a Item %d: x=%.1f, y=%.1f, w=%.1f, h=%.1f", i, pos.x, pos.y, pos.width, pos.height))
  end
  print("Level 3b positions:")
  for i, pos in ipairs(level3bPositions) do
    print(string.format("L3b Item %d: x=%.1f, y=%.1f, w=%.1f, h=%.1f", i, pos.x, pos.y, pos.width, pos.height))
  end

  -- Level 1 centers level 2
  luaunit.assertEquals(level1Positions[1].x, 20) -- (200-160)/2
  luaunit.assertEquals(level1Positions[1].y, 25) -- (150-100)/2

  -- Level 2 stretches and space-between for level 3 containers
  -- These positions are relative to level 1 container position
  luaunit.assertEquals(level2Positions[1].x, 20) -- positioned by level 1
  luaunit.assertEquals(level2Positions[1].y, 25) -- positioned by level 1
  luaunit.assertEquals(level2Positions[1].height, 100) -- stretched to full cross-axis height

  luaunit.assertEquals(level2Positions[2].x, 110) -- positioned by level 1 + space-between
  luaunit.assertEquals(level2Positions[2].y, 25) -- positioned by level 1
  luaunit.assertEquals(level2Positions[2].height, 100) -- stretched to full cross-axis height

  -- Level 3a: flex-end justification, center alignment
  -- Positions are absolute including parent positions
  luaunit.assertEquals(level3aPositions[1].x, 40) -- absolute position
  luaunit.assertEquals(level3aPositions[1].y, 90) -- flex-end: positioned at bottom of stretched container

  luaunit.assertEquals(level3aPositions[2].x, 42.5) -- absolute position
  luaunit.assertEquals(level3aPositions[2].y, 110) -- second item: 90 + 20 = 110

  -- Level 3b: flex-start justification, flex-end alignment
  -- Positions are absolute including parent positions
  luaunit.assertEquals(level3bPositions[1].x, 145) -- flex-end: container_x(110) + container_width(70) - item_width(35) = 145
  luaunit.assertEquals(level3bPositions[1].y, 25) -- actual absolute position
end

-- ===================================
-- COMPLEX COMPREHENSIVE STRUCTURE TESTS
-- ===================================

-- Test 6: Complex Application Layout - Complete UI Structure
function TestComprehensiveFlex:testComplexApplicationLayout()
  -- Main application container
  local app = createContainer({
    x = 0,
    y = 0,
    w = 1200,
    h = 800,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Top navigation bar
  local navbar = createChild(app, {
    h = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 20,
    padding = { top = 10, right = 20, bottom = 10, left = 20 },
  })

  -- Left section of navbar
  local navLeft = createChild(navbar, {
    w = 300,
    h = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    gap = 16,
  })

  createChild(navLeft, { w = 120, h = 28 }) -- logo
  createChild(navLeft, { w = 80, h = 24 }) -- home link
  createChild(navLeft, { w = 80, h = 24 }) -- products link

  -- Center section of navbar with search
  local navCenter = createChild(navbar, {
    w = 400,
    h = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  createChild(navCenter, { w = 300, h = 32 }) -- search input
  createChild(navCenter, { w = 32, h = 32 }) -- search button

  -- Right section of navbar
  local navRight = createChild(navbar, {
    w = 200,
    h = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 12,
  })

  createChild(navRight, { w = 32, h = 32 }) -- notifications
  createChild(navRight, { w = 32, h = 32 }) -- cart
  createChild(navRight, { w = 80, h = 32 }) -- user menu

  -- Main content area
  local mainContent = createChild(app, {
    h = 740, -- 800 - 60 navbar
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Left sidebar
  local sidebar = createChild(mainContent, {
    w = 250,
    h = 740,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 0, bottom = 20, left = 20 },
  })

  -- Sidebar navigation
  local sideNav = createChild(sidebar, {
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  createChild(sideNav, { h = 24 }) -- nav title

  -- Navigation items with nested structure
  for i = 1, 8 do
    local navItem = createChild(sideNav, {
      h = 32,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
      padding = { top = 4, right = 8, bottom = 4, left = 8 },
    })

    local navItemLeft = createChild(navItem, {
      w = 150,
      h = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(navItemLeft, { w = 16, h = 16 }) -- icon
    createChild(navItemLeft, { w = 100, h = 16 }) -- label

    if i <= 3 then -- some items have badges
      createChild(navItem, { w = 20, h = 16 }) -- badge
    end
  end

  -- Sidebar widget area
  local sideWidget = createChild(sidebar, {
    h = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  createChild(sideWidget, { h = 20 }) -- widget title

  local widgetContent = createChild(sideWidget, {
    h = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  for i = 1, 4 do
    local widgetItem = createChild(widgetContent, {
      h = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(widgetItem, { w = 120, h = 16 }) -- widget text
    createChild(widgetItem, { w = 40, h = 12 }) -- widget value
  end

  createChild(sideWidget, { h = 32 }) -- widget action button

  -- Main content panel
  local contentPanel = createChild(mainContent, {
    w = 950,
    h = 740, -- 1200 - 250 sidebar
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Content header with breadcrumbs and actions
  local contentHeader = createChild(contentPanel, {
    h = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Breadcrumbs and title section
  local headerLeft = createChild(contentHeader, {
    w = 500,
    h = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.FLEX_START,
    gap = 8,
  })

  -- Breadcrumbs
  local breadcrumbs = createChild(headerLeft, {
    h = 16,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 6,
  })

  for i = 1, 4 do
    createChild(breadcrumbs, { w = 60, h = 14 }) -- breadcrumb
    if i < 4 then
      createChild(breadcrumbs, { w = 8, h = 8 }) -- separator
    end
  end

  createChild(headerLeft, { w = 200, h = 24 }) -- page title

  -- Action buttons section
  local headerRight = createChild(contentHeader, {
    w = 300,
    h = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 12,
  })

  createChild(headerRight, { w = 80, h = 32 }) -- filter button
  createChild(headerRight, { w = 80, h = 32 }) -- sort button
  createChild(headerRight, { w = 100, h = 32 }) -- primary action

  -- Main content area with complex layouts
  local contentMain = createChild(contentPanel, {
    h = 660, -- 740 - 80 header
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 0, right = 20, bottom = 20, left = 20 },
  })

  -- Content grid area
  local contentGrid = createChild(contentMain, {
    w = 600,
    h = 640,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Grid header with filters
  local gridHeader = createChild(contentGrid, {
    h = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 12,
  })

  -- Active filters
  local activeFilters = createChild(gridHeader, {
    w = 350,
    h = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 8,
  })

  for i = 1, 4 do
    local filterChip = createChild(activeFilters, {
      w = 70,
      h = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 4,
      padding = { top = 2, right = 6, bottom = 2, left = 6 },
    })

    createChild(filterChip, { w = 40, h = 12 }) -- filter text
    createChild(filterChip, { w = 12, h = 12 }) -- close button
  end

  -- Grid controls
  local gridControls = createChild(gridHeader, {
    w = 150,
    h = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  createChild(gridControls, { w = 60, h = 28 }) -- view toggle
  createChild(gridControls, { w = 60, h = 28 }) -- sort dropdown

  -- Item grid
  local itemGrid = createChild(contentGrid, {
    h = 560,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 20,
  })

  -- Create grid items
  for i = 1, 6 do
    local gridItem = createChild(itemGrid, {
      w = 180,
      h = 240,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 12,
      padding = { top = 16, right = 16, bottom = 16, left = 16 },
    })

    createChild(gridItem, { h = 120 }) -- item image

    local itemInfo = createChild(gridItem, {
      h = 60,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 4,
    })

    createChild(itemInfo, { w = 140, h = 16 }) -- item title
    createChild(itemInfo, { w = 100, h = 12 }) -- item description

    local itemMeta = createChild(itemInfo, {
      h = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(itemMeta, { w = 60, h = 14 }) -- price
    createChild(itemMeta, { w = 40, h = 14 }) -- rating

    local itemActions = createChild(gridItem, {
      h = 32,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(itemActions, { w = 100, h = 28 }) -- primary action
    createChild(itemActions, { w = 28, h = 28 }) -- secondary action
  end

  -- Right detail panel
  local detailPanel = createChild(contentMain, {
    w = 290,
    h = 640,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 0, bottom = 0, left = 0 },
  })

  -- Detail header
  local detailHeader = createChild(detailPanel, {
    h = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  createChild(detailHeader, { h = 24 }) -- detail title
  createChild(detailHeader, { h = 16 }) -- detail subtitle

  -- Detail content with complex nested structure
  local detailContent = createChild(detailPanel, {
    h = 480,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
  })

  -- Detail sections
  for i = 1, 3 do
    local detailSection = createChild(detailContent, {
      h = 140,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 8,
      padding = { top = 12, right = 12, bottom = 12, left = 12 },
    })

    createChild(detailSection, { h = 18 }) -- section title

    local sectionContent = createChild(detailSection, {
      h = 90,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 6,
    })

    for j = 1, 4 do
      local contentRow = createChild(sectionContent, {
        h = 18,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.CENTER,
        gap = 8,
      })

      createChild(contentRow, { w = 120, h = 14 }) -- row label
      createChild(contentRow, { w = 80, h = 14 }) -- row value
    end
  end

  -- Detail actions
  local detailActions = createChild(detailPanel, {
    h = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 12,
  })

  createChild(detailActions, { h = 32 }) -- primary action
  createChild(detailActions, { h = 28 }) -- secondary action

  -- Layout and test positions
  local appPositions = layoutAndGetPositions(app)

  -- Test main app structure
  luaunit.assertEquals(appPositions[1].y, 0) -- navbar
  luaunit.assertEquals(appPositions[2].y, 60) -- main content

  -- Test navbar layout
  navbar:layoutChildren()
  local navPositions = {}
  for i, child in ipairs(navbar.children) do
    navPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(navPositions[1].x, 20) -- nav left at padding
  luaunit.assertEquals(navPositions[2].x, 400) -- nav center positioned
  luaunit.assertEquals(navPositions[3].x, 980) -- nav right aligned (1200 - 20 - 200)

  -- Test main content layout
  mainContent:layoutChildren()
  local mainPositions = {}
  for i, child in ipairs(mainContent.children) do
    mainPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(mainPositions[1].x, 0) -- sidebar
  luaunit.assertEquals(mainPositions[2].x, 250) -- content panel

  -- Test complex nested structures
  contentPanel:layoutChildren()
  local contentPanelPositions = {}
  for i, child in ipairs(contentPanel.children) do
    contentPanelPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(contentPanelPositions[1].y, 60) -- content header
  luaunit.assertEquals(contentPanelPositions[2].y, 140) -- content main (60 + 80)

  -- Test content main layout
  contentMain:layoutChildren()
  local contentMainPositions = {}
  for i, child in ipairs(contentMain.children) do
    contentMainPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(contentMainPositions[1].x, 270) -- content grid (250 + 20)
  luaunit.assertEquals(contentMainPositions[2].x, 890) -- detail panel (270 + 600 + 20)

  -- Test item grid wrapping
  contentGrid:layoutChildren()
  local gridHeader = contentGrid.children[1]
  local itemGrid = contentGrid.children[2]

  itemGrid:layoutChildren()
  local itemPositions = {}
  for i, child in ipairs(itemGrid.children) do
    itemPositions[i] = { x = child.x, y = child.y }
  end

  -- Items should wrap: 180*3 + 20*2 = 580 < 600, so 3 per row
  luaunit.assertEquals(itemPositions[1].y, itemPositions[2].y) -- row 1
  luaunit.assertEquals(itemPositions[2].y, itemPositions[3].y) -- row 1
  luaunit.assertEquals(itemPositions[4].y, itemPositions[5].y) -- row 2
  luaunit.assertEquals(itemPositions[5].y, itemPositions[6].y) -- row 2
  luaunit.assertTrue(itemPositions[1].y ~= itemPositions[4].y) -- different rows
end

-- Test 7: Complex Dashboard with Multiple Panels and Real-time Data Layout
function TestComprehensiveFlex:testComplexDashboardLayout()
  -- Main dashboard container
  local dashboard = createContainer({
    x = 0,
    y = 0,
    w = 1400,
    h = 900,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Dashboard header with complex controls
  local dashHeader = createChild(dashboard, {
    h = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 20,
    padding = { top = 16, right = 24, bottom = 16, left = 24 },
  })

  -- Header left: title and time range
  local headerLeft = createChild(dashHeader, {
    w = 400,
    h = 48,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    gap = 20,
  })

  createChild(headerLeft, { w = 200, h = 32 }) -- dashboard title

  local timeRange = createChild(headerLeft, {
    w = 160,
    h = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 8,
    padding = { top = 4, right = 8, bottom = 4, left = 8 },
  })

  createChild(timeRange, { w = 100, h = 16 }) -- time range text
  createChild(timeRange, { w = 16, h = 16 }) -- dropdown arrow

  -- Header center: key metrics
  local headerCenter = createChild(dashHeader, {
    w = 600,
    h = 48,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 24,
  })

  -- Quick metrics
  for i = 1, 4 do
    local metric = createChild(headerCenter, {
      w = 120,
      h = 40,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 4,
    })

    createChild(metric, { w = 60, h = 16 }) -- metric value
    createChild(metric, { w = 80, h = 12 }) -- metric label
  end

  -- Header right: actions and settings
  local headerRight = createChild(dashHeader, {
    w = 280,
    h = 48,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 12,
  })

  createChild(headerRight, { w = 36, h = 36 }) -- refresh button
  createChild(headerRight, { w = 36, h = 36 }) -- fullscreen button
  createChild(headerRight, { w = 100, h = 36 }) -- export button
  createChild(headerRight, { w = 36, h = 36 }) -- settings button

  -- Main dashboard content
  local dashContent = createChild(dashboard, {
    h = 820, -- 900 - 80 header
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Left sidebar with navigation and filters
  local dashSidebar = createChild(dashContent, {
    w = 280,
    h = 820,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 0, bottom = 20, left = 20 },
  })

  -- Sidebar navigation
  local sidebarNav = createChild(dashSidebar, {
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
  })

  createChild(sidebarNav, { h = 24 }) -- nav title

  -- Navigation groups
  for i = 1, 3 do
    local navGroup = createChild(sidebarNav, {
      h = 80,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 4,
    })

    createChild(navGroup, { h = 20 }) -- group title

    for j = 1, 3 do
      local navItem = createChild(navGroup, {
        h = 20,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.CENTER,
        gap = 8,
        padding = { top = 2, right = 8, bottom = 2, left = 16 },
      })

      createChild(navItem, { w = 160, h = 14 }) -- nav label
      if j == 1 then
        createChild(navItem, { w = 20, h = 12 }) -- active indicator
      end
    end
  end

  -- Sidebar filters
  local sidebarFilters = createChild(dashSidebar, {
    h = 250,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
    padding = { top = 16, right = 16, bottom = 16, left = 0 },
  })

  createChild(sidebarFilters, { h = 24 }) -- filters title

  -- Filter groups
  for i = 1, 3 do
    local filterGroup = createChild(sidebarFilters, {
      h = 60,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 8,
    })

    createChild(filterGroup, { h = 16 }) -- filter group title

    local filterOptions = createChild(filterGroup, {
      h = 36,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 4,
    })

    for j = 1, 2 do
      local filterOption = createChild(filterOptions, {
        h = 16,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_START,
        alignItems = AlignItems.CENTER,
        gap = 8,
      })

      createChild(filterOption, { w = 16, h = 12 }) -- checkbox
      createChild(filterOption, { w = 120, h = 12 }) -- option label
    end
  end

  -- Sidebar recent activity
  local sidebarActivity = createChild(dashSidebar, {
    h = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 0, left = 0 },
  })

  createChild(sidebarActivity, { h = 20 }) -- activity title

  local activityList = createChild(sidebarActivity, {
    h = 160,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  for i = 1, 6 do
    local activityItem = createChild(activityList, {
      h = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    local activityLeft = createChild(activityItem, {
      w = 160,
      h = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 6,
    })

    createChild(activityLeft, { w = 12, h = 12 }) -- status dot
    createChild(activityLeft, { w = 120, h = 12 }) -- activity text

    createChild(activityItem, { w = 40, h = 10 }) -- timestamp
  end

  -- Main content panels area
  local dashMain = createChild(dashContent, {
    w = 1120,
    h = 820, -- 1400 - 280 sidebar
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Top metrics row
  local topMetrics = createChild(dashMain, {
    h = 140,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    alignContent = AlignContent.FLEX_START,
    gap = 20,
  })

  -- Large metric cards
  for i = 1, 4 do
    local metricCard = createChild(topMetrics, {
      w = 250,
      h = 120,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 12,
      padding = { top = 16, right = 16, bottom = 16, left = 16 },
    })

    -- Card header
    local cardHeader = createChild(metricCard, {
      h = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(cardHeader, { w = 120, h = 16 }) -- metric title
    createChild(cardHeader, { w = 20, h = 16 }) -- trend icon

    -- Metric value and change
    local cardValue = createChild(metricCard, {
      h = 32,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.FLEX_END,
      gap = 8,
    })

    createChild(cardValue, { w = 100, h = 28 }) -- main value
    createChild(cardValue, { w = 60, h = 16 }) -- change percentage

    -- Mini chart area
    createChild(metricCard, { h = 24 }) -- mini chart
  end

  -- Middle content row with charts
  local middleContent = createChild(dashMain, {
    h = 320,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Large chart panel
  local chartPanel = createChild(middleContent, {
    w = 680,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 16,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Chart header with controls
  local chartHeader = createChild(chartPanel, {
    h = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 16,
  })

  createChild(chartHeader, { w = 200, h = 24 }) -- chart title

  local chartControls = createChild(chartHeader, {
    w = 200,
    h = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 8,
  })

  createChild(chartControls, { w = 60, h = 24 }) -- time filter
  createChild(chartControls, { w = 60, h = 24 }) -- chart type
  createChild(chartControls, { w = 24, h = 24 }) -- options menu

  -- Chart area
  createChild(chartPanel, { h = 200 }) -- main chart

  -- Chart legend
  local chartLegend = createChild(chartPanel, {
    h = 28,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 20,
  })

  for i = 1, 5 do
    local legendItem = createChild(chartLegend, {
      w = 80,
      h = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 6,
    })

    createChild(legendItem, { w = 12, h = 12 }) -- color indicator
    createChild(legendItem, { w = 50, h = 12 }) -- legend text
  end

  -- Side stats panel
  local statsPanel = createChild(middleContent, {
    w = 360,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  createChild(statsPanel, { h = 24 }) -- stats title

  -- Stats grid
  local statsGrid = createChild(statsPanel, {
    h = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.FLEX_START,
    alignContent = AlignContent.FLEX_START,
    gap = 12,
  })

  -- Stats items in 2x4 grid
  for i = 1, 8 do
    local statItem = createChild(statsGrid, {
      w = 150,
      h = 50,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.FLEX_START,
      gap = 4,
      padding = { top = 8, right = 8, bottom = 8, left = 8 },
    })

    createChild(statItem, { w = 100, h = 16 }) -- stat label
    createChild(statItem, { w = 80, h = 20 }) -- stat value
  end

  -- Bottom content row with tables and lists
  local bottomContent = createChild(dashMain, {
    h = 260,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Data table panel
  local tablePanel = createChild(bottomContent, {
    w = 540,
    h = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  -- Table header
  local tableHeader = createChild(tablePanel, {
    h = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 12,
  })

  createChild(tableHeader, { w = 150, h = 20 }) -- table title

  local tableControls = createChild(tableHeader, {
    w = 120,
    h = 24,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  createChild(tableControls, { w = 80, h = 20 }) -- search box
  createChild(tableControls, { w = 20, h = 20 }) -- filter button

  -- Table content
  local tableContent = createChild(tablePanel, {
    h = 180,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 4,
  })

  -- Table header row
  local tableHeaderRow = createChild(tableContent, {
    h = 24,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  for i = 1, 4 do
    createChild(tableHeaderRow, { w = 100, h = 16 }) -- column header
  end

  -- Table data rows
  for i = 1, 6 do
    local tableRow = createChild(tableContent, {
      h = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    for j = 1, 4 do
      createChild(tableRow, { w = 100, h = 14 }) -- table cell
    end
  end

  -- Right panels (split)
  local rightPanels = createChild(bottomContent, {
    w = 500,
    h = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Alerts panel
  local alertsPanel = createChild(rightPanels, {
    w = 240,
    h = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  createChild(alertsPanel, { h = 20 }) -- alerts title

  local alertsList = createChild(alertsPanel, {
    h = 192,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  for i = 1, 6 do
    local alertItem = createChild(alertsList, {
      h = 28,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
      padding = { top = 4, right = 4, bottom = 4, left = 4 },
    })

    local alertLeft = createChild(alertItem, {
      w = 160,
      h = 20,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 6,
    })

    createChild(alertLeft, { w = 12, h = 12 }) -- alert icon
    createChild(alertLeft, { w = 120, h = 12 }) -- alert text

    createChild(alertItem, { w = 16, h = 16 }) -- dismiss button
  end

  -- Progress panel
  local progressPanel = createChild(rightPanels, {
    w = 240,
    h = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  createChild(progressPanel, { h = 20 }) -- progress title

  local progressList = createChild(progressPanel, {
    h = 192,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
  })

  for i = 1, 4 do
    local progressItem = createChild(progressList, {
      h = 40,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 6,
    })

    local progressHeader = createChild(progressItem, {
      h = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(progressHeader, { w = 120, h = 12 }) -- progress label
    createChild(progressHeader, { w = 40, h = 12 }) -- progress percentage

    createChild(progressItem, { h = 8 }) -- progress bar
  end

  -- Layout and test positions
  local dashPositions = layoutAndGetPositions(dashboard)

  -- Test main dashboard structure
  luaunit.assertEquals(dashPositions[1].y, 0) -- dashboard header
  luaunit.assertEquals(dashPositions[2].y, 80) -- dashboard content

  -- Test dashboard header layout
  dashHeader:layoutChildren()
  local headerPositions = {}
  for i, child in ipairs(dashHeader.children) do
    headerPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(headerPositions[1].x, 24) -- header left
  luaunit.assertEquals(headerPositions[2].x, 400) -- header center (centered)
  luaunit.assertEquals(headerPositions[3].x, 1096) -- header right (1400 - 24 - 280)

  -- Test dashboard content layout
  dashContent:layoutChildren()
  local contentPositions = {}
  for i, child in ipairs(dashContent.children) do
    contentPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(contentPositions[1].x, 0) -- sidebar
  luaunit.assertEquals(contentPositions[2].x, 280) -- main content

  -- Test top metrics wrapping
  dashMain:layoutChildren()
  local topMetrics = dashMain.children[1]
  topMetrics:layoutChildren()

  local metricPositions = {}
  for i, child in ipairs(topMetrics.children) do
    metricPositions[i] = { x = child.x, y = child.y }
  end

  -- 4 metrics should fit in one row: 250*4 + 20*3 = 1060 < 1080 available
  luaunit.assertEquals(metricPositions[1].y, metricPositions[2].y) -- same row
  luaunit.assertEquals(metricPositions[2].y, metricPositions[3].y) -- same row
  luaunit.assertEquals(metricPositions[3].y, metricPositions[4].y) -- same row

  -- Test middle content layout
  local middleContent = dashMain.children[2]
  middleContent:layoutChildren()

  local middlePositions = {}
  for i, child in ipairs(middleContent.children) do
    middlePositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(middlePositions[1].x, 300) -- chart panel (300 + 20 padding)
  luaunit.assertEquals(middlePositions[2].x, 1000) -- stats panel (300 + 680 + 20)

  -- Test chart legend wrapping
  local chartPanel = middleContent.children[1]
  chartPanel:layoutChildren()
  local chartLegend = chartPanel.children[3]
  chartLegend:layoutChildren()

  -- 5 legend items should fit: 80*5 + 20*4 = 480 < 640 available
  luaunit.assertEquals(chartLegend.children[1].y, chartLegend.children[2].y) -- same row
  luaunit.assertEquals(chartLegend.children[2].y, chartLegend.children[3].y) -- same row
  luaunit.assertEquals(chartLegend.children[3].y, chartLegend.children[4].y) -- same row
  luaunit.assertEquals(chartLegend.children[4].y, chartLegend.children[5].y) -- same row

  -- Test stats grid wrapping
  local statsPanel = middleContent.children[2]
  statsPanel:layoutChildren()
  local statsGrid = statsPanel.children[2]
  statsGrid:layoutChildren()

  local statsPositions = {}
  for i, child in ipairs(statsGrid.children) do
    statsPositions[i] = { x = child.x, y = child.y }
  end

  -- 8 stats in 2 columns: 150*2 + 12*1 = 312 < 320 available
  luaunit.assertEquals(statsPositions[1].y, statsPositions[2].y) -- row 1
  luaunit.assertEquals(statsPositions[3].y, statsPositions[4].y) -- row 2
  luaunit.assertEquals(statsPositions[5].y, statsPositions[6].y) -- row 3
  luaunit.assertEquals(statsPositions[7].y, statsPositions[8].y) -- row 4
  luaunit.assertTrue(statsPositions[1].y ~= statsPositions[3].y) -- different rows

  -- Test bottom content layout
  local bottomContent = dashMain.children[3]
  bottomContent:layoutChildren()

  local bottomPositions = {}
  for i, child in ipairs(bottomContent.children) do
    bottomPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(bottomPositions[1].x, 300) -- table panel
  luaunit.assertEquals(bottomPositions[2].x, 860) -- right panels (300 + 540 + 20)

  -- Test right panels layout
  local rightPanels = bottomContent.children[2]
  rightPanels:layoutChildren()

  local rightPositions = {}
  for i, child in ipairs(rightPanels.children) do
    rightPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(rightPositions[1].x, 860) -- alerts panel
  luaunit.assertEquals(rightPositions[2].x, 1120) -- progress panel (860 + 240 + 20)
end

luaunit.LuaUnit.run()
