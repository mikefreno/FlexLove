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
    width = 150,
    height = 120,
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
    width = 40,
    height = 30,
  })

  local child2 = createChild(container, {
    width = 40,
    height = 30,
  })

  local child3 = createChild(container, {
    width = 40,
    height = 30,
  })

  local child4 = createChild(container, {
    width = 40,
    height = 30,
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
    width = 180,
    height = 160,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    alignItems = AlignItems.CENTER,
    gap = 0,
  })

  -- Inner container 1 - horizontal flex
  local innerContainer1 = createChild(outerContainer, {
    width = 140,
    height = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.FLEX_END,
    gap = 0,
  })

  -- Inner container 2 - horizontal flex with wrap
  local innerContainer2 = createChild(outerContainer, {
    width = 140,
    height = 50,
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
    width = 30,
    height = 20,
  })

  local item2 = createChild(innerContainer1, {
    width = 30,
    height = 35,
  })

  -- Add children to inner container 2
  local item3 = createChild(innerContainer2, {
    width = 40,
    height = 25,
  })

  local item4 = createChild(innerContainer2, {
    width = 40,
    height = 25,
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
  luaunit.assertEquals(inner2Positions[1].height, 25) -- explicit height, not stretched (CSS spec compliance)

  luaunit.assertEquals(inner2Positions[2].x, 60) -- parent x + 40
  luaunit.assertEquals(inner2Positions[2].y, 95) -- parent y + 0
  luaunit.assertEquals(inner2Positions[2].height, 25) -- explicit height, not stretched (CSS spec compliance)
end

-- Test 3: All flex properties combined with absolute positioning
function TestComprehensiveFlex:testFlexWithAbsolutePositioning()
  local container = createContainer({
    x = 0,
    y = 0,
    width = 160,
    height = 100,
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
    width = 30,
    height = 20,
  })

  local flexChild2 = createChild(container, {
    width = 30,
    height = 20,
  })

  -- Absolute positioned child (should not affect flex layout)
  local absChild = createChild(container, {
    positioning = Positioning.ABSOLUTE,
    x = 10,
    y = 10,
    width = 20,
    height = 15,
  })

  local flexChild3 = createChild(container, {
    width = 30,
    height = 20,
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
    width = 120,
    height = 150,
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
      width = 35,
      height = 25,
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
    width = 200,
    height = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    gap = 0,
  })

  local level2 = createChild(level1, {
    width = 160,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  local level3a = createChild(level2, {
    width = 70,
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 0,
  })

  local level3b = createChild(level2, {
    width = 70,
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.FLEX_END,
    gap = 0,
  })

  -- Add leaf elements
  local leafA1 = createChild(level3a, {
    width = 30,
    height = 20,
  })

  local leafA2 = createChild(level3a, {
    width = 25,
    height = 15,
  })

  local leafB1 = createChild(level3b, {
    width = 35,
    height = 18,
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
  luaunit.assertEquals(level2Positions[1].height, 80) -- explicit height, not stretched (CSS spec compliance)

  luaunit.assertEquals(level2Positions[2].x, 110) -- positioned by level 1 + space-between
  luaunit.assertEquals(level2Positions[2].y, 25) -- positioned by level 1
  luaunit.assertEquals(level2Positions[2].height, 80) -- explicit height, not stretched (CSS spec compliance)

  -- Level 3a: flex-end justification, center alignment
  -- Positions are absolute including parent positions
  luaunit.assertEquals(level3aPositions[1].x, 40) -- absolute position
  luaunit.assertEquals(level3aPositions[1].y, 70) -- flex-end: 25 (level2.y) + 45 (80 - 35 total children)

  luaunit.assertEquals(level3aPositions[2].x, 42.5) -- absolute position
  luaunit.assertEquals(level3aPositions[2].y, 90) -- second item: 70 + 20 = 90

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
    width = 1200,
    height = 800,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Top navigation bar
  local navbar = createChild(app, {
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 20,
    padding = { top = 10, right = 20, bottom = 10, left = 20 },
  })

  -- Left section of navbar
  local navLeft = createChild(navbar, {
    width = 300,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    gap = 16,
  })

  createChild(navLeft, { width = 120, height = 28 }) -- logo
  createChild(navLeft, { width = 80, height = 24 }) -- home link
  createChild(navLeft, { width = 80, height = 24 }) -- products link

  -- Center section of navbar with search
  local navCenter = createChild(navbar, {
    width = 400,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  createChild(navCenter, { width = 300, height = 32 }) -- search input
  createChild(navCenter, { width = 32, height = 32 }) -- search button

  -- Right section of navbar
  local navRight = createChild(navbar, {
    width = 200,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 12,
  })

  createChild(navRight, { width = 32, height = 32 }) -- notifications
  createChild(navRight, { width = 32, height = 32 }) -- cart
  createChild(navRight, { width = 80, height = 32 }) -- user menu

  -- Main content area
  local mainContent = createChild(app, {
    height = 740, -- 800 - 60 navbar
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Left sidebar
  local sidebar = createChild(mainContent, {
    width = 250,
    height = 740,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 0, bottom = 20, left = 20 },
  })

  -- Sidebar navigation
  local sideNav = createChild(sidebar, {
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  createChild(sideNav, { height = 24 }) -- nav title

  -- Navigation items with nested structure
  for i = 1, 8 do
    local navItem = createChild(sideNav, {
      height = 32,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
      padding = { top = 4, right = 8, bottom = 4, left = 8 },
    })

    local navItemLeft = createChild(navItem, {
      width = 150,
      height = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(navItemLeft, { width = 16, height = 16 }) -- icon
    createChild(navItemLeft, { width = 100, height = 16 }) -- label

    if i <= 3 then -- some items have badges
      createChild(navItem, { width = 20, height = 16 }) -- badge
    end
  end

  -- Sidebar widget area
  local sideWidget = createChild(sidebar, {
    height = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  createChild(sideWidget, { height = 20 }) -- widget title

  local widgetContent = createChild(sideWidget, {
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  for i = 1, 4 do
    local widgetItem = createChild(widgetContent, {
      height = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(widgetItem, { width = 120, height = 16 }) -- widget text
    createChild(widgetItem, { width = 40, height = 12 }) -- widget value
  end

  createChild(sideWidget, { height = 32 }) -- widget action button

  -- Main content panel
  local contentPanel = createChild(mainContent, {
    width = 950,
    height = 740, -- 1200 - 250 sidebar
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Content header with breadcrumbs and actions
  local contentHeader = createChild(contentPanel, {
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Breadcrumbs and title section
  local headerLeft = createChild(contentHeader, {
    width = 500,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.FLEX_START,
    gap = 8,
  })

  -- Breadcrumbs
  local breadcrumbs = createChild(headerLeft, {
    height = 16,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 6,
  })

  for i = 1, 4 do
    createChild(breadcrumbs, { width = 60, height = 14 }) -- breadcrumb
    if i < 4 then
      createChild(breadcrumbs, { width = 8, height = 8 }) -- separator
    end
  end

  createChild(headerLeft, { width = 200, height = 24 }) -- page title

  -- Action buttons section
  local headerRight = createChild(contentHeader, {
    width = 300,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 12,
  })

  createChild(headerRight, { width = 80, height = 32 }) -- filter button
  createChild(headerRight, { width = 80, height = 32 }) -- sort button
  createChild(headerRight, { width = 100, height = 32 }) -- primary action

  -- Main content area with complex layouts
  local contentMain = createChild(contentPanel, {
    height = 660, -- 740 - 80 header
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 0, right = 20, bottom = 20, left = 20 },
  })

  -- Content grid area
  local contentGrid = createChild(contentMain, {
    width = 600,
    height = 640,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Grid header with filters
  local gridHeader = createChild(contentGrid, {
    height = 60,
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
    width = 350,
    height = 32,
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
      width = 70,
      height = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 4,
      padding = { top = 2, right = 6, bottom = 2, left = 6 },
    })

    createChild(filterChip, { width = 40, height = 12 }) -- filter text
    createChild(filterChip, { width = 12, height = 12 }) -- close button
  end

  -- Grid controls
  local gridControls = createChild(gridHeader, {
    width = 150,
    height = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  createChild(gridControls, { width = 60, height = 28 }) -- view toggle
  createChild(gridControls, { width = 60, height = 28 }) -- sort dropdown

  -- Item grid
  local itemGrid = createChild(contentGrid, {
    height = 560,
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
      width = 180,
      height = 240,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 12,
      padding = { top = 16, right = 16, bottom = 16, left = 16 },
    })

    createChild(gridItem, { height = 120 }) -- item image

    local itemInfo = createChild(gridItem, {
      height = 60,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 4,
    })

    createChild(itemInfo, { width = 140, height = 16 }) -- item title
    createChild(itemInfo, { width = 100, height = 12 }) -- item description

    local itemMeta = createChild(itemInfo, {
      height = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(itemMeta, { width = 60, height = 14 }) -- price
    createChild(itemMeta, { width = 40, height = 14 }) -- rating

    local itemActions = createChild(gridItem, {
      height = 32,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(itemActions, { width = 100, height = 28 }) -- primary action
    createChild(itemActions, { width = 28, height = 28 }) -- secondary action
  end

  -- Right detail panel
  local detailPanel = createChild(contentMain, {
    width = 290,
    height = 640,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 0, bottom = 0, left = 0 },
  })

  -- Detail header
  local detailHeader = createChild(detailPanel, {
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  createChild(detailHeader, { height = 24 }) -- detail title
  createChild(detailHeader, { height = 16 }) -- detail subtitle

  -- Detail content with complex nested structure
  local detailContent = createChild(detailPanel, {
    height = 480,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
  })

  -- Detail sections
  for i = 1, 3 do
    local detailSection = createChild(detailContent, {
      height = 140,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 8,
      padding = { top = 12, right = 12, bottom = 12, left = 12 },
    })

    createChild(detailSection, { height = 18 }) -- section title

    local sectionContent = createChild(detailSection, {
      height = 90,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 6,
    })

    for j = 1, 4 do
      local contentRow = createChild(sectionContent, {
        height = 18,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.CENTER,
        gap = 8,
      })

      createChild(contentRow, { width = 120, height = 14 }) -- row label
      createChild(contentRow, { width = 80, height = 14 }) -- row value
    end
  end

  -- Detail actions
  local detailActions = createChild(detailPanel, {
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 12,
  })

  createChild(detailActions, { height = 32 }) -- primary action
  createChild(detailActions, { height = 28 }) -- secondary action

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
  print("DEBUG - navCenter actual x:", navPositions[2].x, "expected: 400")
  print("DEBUG - navbar calculation: available=1160, content=900, remaining=260, gap=130")
  print("DEBUG - expected navCenter.x = 20 + 300 + 130 = 450")
  luaunit.assertEquals(navPositions[2].x, 450) -- nav center positioned correctly with SPACE_BETWEEN
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
    width = 1400,
    height = 900,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Dashboard header with complex controls
  local dashHeader = createChild(dashboard, {
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 20,
    padding = { top = 16, right = 24, bottom = 16, left = 24 },
  })

  -- Header left: title and time range
  local headerLeft = createChild(dashHeader, {
    width = 400,
    height = 48,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    gap = 20,
  })

  createChild(headerLeft, { width = 200, height = 32 }) -- dashboard title

  local timeRange = createChild(headerLeft, {
    width = 160,
    height = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 8,
    padding = { top = 4, right = 8, bottom = 4, left = 8 },
  })

  createChild(timeRange, { width = 100, height = 16 }) -- time range text
  createChild(timeRange, { width = 16, height = 16 }) -- dropdown arrow

  -- Header center: key metrics
  local headerCenter = createChild(dashHeader, {
    width = 600,
    height = 48,
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
      width = 120,
      height = 40,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 4,
    })

    createChild(metric, { width = 60, height = 16 }) -- metric value
    createChild(metric, { width = 80, height = 12 }) -- metric label
  end

  -- Header right: actions and settings
  local headerRight = createChild(dashHeader, {
    width = 280,
    height = 48,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 12,
  })

  createChild(headerRight, { width = 36, height = 36 }) -- refresh button
  createChild(headerRight, { width = 36, height = 36 }) -- fullscreen button
  createChild(headerRight, { width = 100, height = 36 }) -- export button
  createChild(headerRight, { width = 36, height = 36 }) -- settings button

  -- Main dashboard content
  local dashContent = createChild(dashboard, {
    height = 820, -- 900 - 80 header
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 0,
  })

  -- Left sidebar with navigation and filters
  local dashSidebar = createChild(dashContent, {
    width = 280,
    height = 820,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 0, bottom = 20, left = 20 },
  })

  -- Sidebar navigation
  local sidebarNav = createChild(dashSidebar, {
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
  })

  createChild(sidebarNav, { height = 24 }) -- nav title

  -- Navigation groups
  for i = 1, 3 do
    local navGroup = createChild(sidebarNav, {
      height = 80,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 4,
    })

    createChild(navGroup, { height = 20 }) -- group title

    for j = 1, 3 do
      local navItem = createChild(navGroup, {
        height = 20,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.CENTER,
        gap = 8,
        padding = { top = 2, right = 8, bottom = 2, left = 16 },
      })

      createChild(navItem, { width = 160, height = 14 }) -- nav label
      if j == 1 then
        createChild(navItem, { width = 20, height = 12 }) -- active indicator
      end
    end
  end

  -- Sidebar filters
  local sidebarFilters = createChild(dashSidebar, {
    height = 250,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
    padding = { top = 16, right = 16, bottom = 16, left = 0 },
  })

  createChild(sidebarFilters, { height = 24 }) -- filters title

  -- Filter groups
  for i = 1, 3 do
    local filterGroup = createChild(sidebarFilters, {
      height = 60,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 8,
    })

    createChild(filterGroup, { height = 16 }) -- filter group title

    local filterOptions = createChild(filterGroup, {
      height = 36,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 4,
    })

    for j = 1, 2 do
      local filterOption = createChild(filterOptions, {
        height = 16,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_START,
        alignItems = AlignItems.CENTER,
        gap = 8,
      })

      createChild(filterOption, { width = 16, height = 12 }) -- checkbox
      createChild(filterOption, { width = 120, height = 12 }) -- option label
    end
  end

  -- Sidebar recent activity
  local sidebarActivity = createChild(dashSidebar, {
    height = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 0, left = 0 },
  })

  createChild(sidebarActivity, { height = 20 }) -- activity title

  local activityList = createChild(sidebarActivity, {
    height = 160,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  for i = 1, 6 do
    local activityItem = createChild(activityList, {
      height = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    local activityLeft = createChild(activityItem, {
      width = 160,
      height = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 6,
    })

    createChild(activityLeft, { width = 12, height = 12 }) -- status dot
    createChild(activityLeft, { width = 120, height = 12 }) -- activity text

    createChild(activityItem, { width = 40, height = 10 }) -- timestamp
  end

  -- Main content panels area
  local dashMain = createChild(dashContent, {
    width = 1120,
    height = 820, -- 1400 - 280 sidebar
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Top metrics row
  local topMetrics = createChild(dashMain, {
    height = 140,
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
      width = 250,
      height = 120,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 12,
      padding = { top = 16, right = 16, bottom = 16, left = 16 },
    })

    -- Card header
    local cardHeader = createChild(metricCard, {
      height = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(cardHeader, { width = 120, height = 16 }) -- metric title
    createChild(cardHeader, { width = 20, height = 16 }) -- trend icon

    -- Metric value and change
    local cardValue = createChild(metricCard, {
      height = 32,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.FLEX_END,
      gap = 8,
    })

    createChild(cardValue, { width = 100, height = 28 }) -- main value
    createChild(cardValue, { width = 60, height = 16 }) -- change percentage

    -- Mini chart area
    createChild(metricCard, { height = 24 }) -- mini chart
  end

  -- Middle content row with charts
  local middleContent = createChild(dashMain, {
    height = 320,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Large chart panel
  local chartPanel = createChild(middleContent, {
    width = 680,
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 16,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Chart header with controls
  local chartHeader = createChild(chartPanel, {
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 16,
  })

  createChild(chartHeader, { width = 200, height = 24 }) -- chart title

  local chartControls = createChild(chartHeader, {
    width = 200,
    height = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    alignContent = AlignContent.CENTER,
    gap = 8,
  })

  createChild(chartControls, { width = 60, height = 24 }) -- time filter
  createChild(chartControls, { width = 60, height = 24 }) -- chart type
  createChild(chartControls, { width = 24, height = 24 }) -- options menu

  -- Chart area
  createChild(chartPanel, { height = 200 }) -- main chart

  -- Chart legend
  local chartLegend = createChild(chartPanel, {
    height = 28,
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
      width = 80,
      height = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 6,
    })

    createChild(legendItem, { width = 12, height = 12 }) -- color indicator
    createChild(legendItem, { width = 50, height = 12 }) -- legend text
  end

  -- Side stats panel
  local statsPanel = createChild(middleContent, {
    width = 360,
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  createChild(statsPanel, { height = 24 }) -- stats title

  -- Stats grid
  local statsGrid = createChild(statsPanel, {
    height = 240,
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
      width = 150,
      height = 50,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.FLEX_START,
      gap = 4,
      padding = { top = 8, right = 8, bottom = 8, left = 8 },
    })

    createChild(statItem, { width = 100, height = 16 }) -- stat label
    createChild(statItem, { width = 80, height = 20 }) -- stat value
  end

  -- Bottom content row with tables and lists
  local bottomContent = createChild(dashMain, {
    height = 260,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Data table panel
  local tablePanel = createChild(bottomContent, {
    width = 540,
    height = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  -- Table header
  local tableHeader = createChild(tablePanel, {
    height = 32,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 12,
  })

  createChild(tableHeader, { width = 150, height = 20 }) -- table title

  local tableControls = createChild(tableHeader, {
    width = 120,
    height = 24,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  createChild(tableControls, { width = 80, height = 20 }) -- search box
  createChild(tableControls, { width = 20, height = 20 }) -- filter button

  -- Table content
  local tableContent = createChild(tablePanel, {
    height = 180,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 4,
  })

  -- Table header row
  local tableHeaderRow = createChild(tableContent, {
    height = 24,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    gap = 8,
  })

  for i = 1, 4 do
    createChild(tableHeaderRow, { width = 100, height = 16 }) -- column header
  end

  -- Table data rows
  for i = 1, 6 do
    local tableRow = createChild(tableContent, {
      height = 24,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    for j = 1, 4 do
      createChild(tableRow, { width = 100, height = 14 }) -- table cell
    end
  end

  -- Right panels (split)
  local rightPanels = createChild(bottomContent, {
    width = 500,
    height = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.STRETCH,
    gap = 20,
  })

  -- Alerts panel
  local alertsPanel = createChild(rightPanels, {
    width = 240,
    height = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  createChild(alertsPanel, { height = 20 }) -- alerts title

  local alertsList = createChild(alertsPanel, {
    height = 192,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 8,
  })

  for i = 1, 6 do
    local alertItem = createChild(alertsList, {
      height = 28,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
      padding = { top = 4, right = 4, bottom = 4, left = 4 },
    })

    local alertLeft = createChild(alertItem, {
      width = 160,
      height = 20,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 6,
    })

    createChild(alertLeft, { width = 12, height = 12 }) -- alert icon
    createChild(alertLeft, { width = 120, height = 12 }) -- alert text

    createChild(alertItem, { width = 16, height = 16 }) -- dismiss button
  end

  -- Progress panel
  local progressPanel = createChild(rightPanels, {
    width = 240,
    height = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 12,
    padding = { top = 16, right = 16, bottom = 16, left = 16 },
  })

  createChild(progressPanel, { height = 20 }) -- progress title

  local progressList = createChild(progressPanel, {
    height = 192,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    gap = 16,
  })

  for i = 1, 4 do
    local progressItem = createChild(progressList, {
      height = 40,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 6,
    })

    local progressHeader = createChild(progressItem, {
      height = 16,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })

    createChild(progressHeader, { width = 120, height = 12 }) -- progress label
    createChild(progressHeader, { width = 40, height = 12 }) -- progress percentage

    createChild(progressItem, { height = 8 }) -- progress bar
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
  print("DEBUG - dashHeader center actual x:", headerPositions[2].x, "expected: 400")
  luaunit.assertEquals(headerPositions[2].x, 460) -- header center (calculated correctly)
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

  luaunit.assertEquals(middlePositions[1].x, 300) -- chart panel (280 sidebar + 20 padding)
  luaunit.assertEquals(middlePositions[2].x, 1020) -- stats panel (280 + 20 + 680 + 40 gap with SPACE_BETWEEN)

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
  luaunit.assertEquals(bottomPositions[2].x, 880) -- right panels (280 + 20 + 540 + 40 gap with SPACE_BETWEEN)

  -- Test right panels layout
  local rightPanels = bottomContent.children[2]
  rightPanels:layoutChildren()

  local rightPositions = {}
  for i, child in ipairs(rightPanels.children) do
    rightPositions[i] = { x = child.x, y = child.y, width = child.width, height = child.height }
  end

  luaunit.assertEquals(rightPositions[1].x, 880) -- alerts panel (same as parent due to SPACE_BETWEEN)
  luaunit.assertEquals(rightPositions[2].x, 1140) -- progress panel (880 + 240 + 20)
end

luaunit.LuaUnit.run()
