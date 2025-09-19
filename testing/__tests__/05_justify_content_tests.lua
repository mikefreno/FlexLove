-- 05. Justify Content Alignment Tests
-- Tests for FlexLove justify content functionality

-- Load test framework and dependencies
package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

-- Import required enums
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems

-- Test class for justify content functionality
TestJustifyContent = {}

function TestJustifyContent:setUp()
  -- Clear any previous state if needed
  Gui.destroy()
end

function TestJustifyContent:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Test 1: Horizontal Flex with JustifyContent.FLEX_START
function TestJustifyContent:testHorizontalFlexJustifyContentFlexStart()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  local child3 = Gui.new({
    id = "child3",
    w = 70,
    h = 35,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)
  container:addChild(child3)

  -- With FLEX_START, children should be positioned from the start (left)
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 50)
  luaunit.assertEquals(child3.x, 110)

  -- Y positions should be 0 (aligned to top by default)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 0)
  luaunit.assertEquals(child3.y, 0)
end

-- Test 2: Horizontal Flex with JustifyContent.CENTER
function TestJustifyContent:testHorizontalFlexJustifyContentCenter()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child width: 50 + 60 = 110
  -- Available space: 300 - 110 = 190
  -- Center offset: 190 / 2 = 95
  luaunit.assertEquals(child1.x, 95)
  luaunit.assertEquals(child2.x, 145)
end

-- Test 3: Horizontal Flex with JustifyContent.FLEX_END
function TestJustifyContent:testHorizontalFlexJustifyContentFlexEnd()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child width: 50 + 60 = 110
  -- Available space: 300 - 110 = 190
  -- Children should be positioned from the end
  luaunit.assertEquals(child1.x, 190)
  luaunit.assertEquals(child2.x, 240)
end

-- Test 4: Horizontal Flex with JustifyContent.SPACE_BETWEEN
function TestJustifyContent:testHorizontalFlexJustifyContentSpaceBetween()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  local child3 = Gui.new({
    id = "child3",
    w = 40,
    h = 35,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)
  container:addChild(child3)

  -- Total child width: 50 + 60 + 40 = 150
  -- Available space: 300 - 150 = 150
  -- Space between 3 children: 150 / 2 = 75
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 125) -- 0 + 50 + 75
  luaunit.assertEquals(child3.x, 260) -- 125 + 60 + 75
end

-- Test 5: Horizontal Flex with JustifyContent.SPACE_AROUND
function TestJustifyContent:testHorizontalFlexJustifyContentSpaceAround()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child width: 50 + 60 = 110
  -- Available space: 300 - 110 = 190
  -- Space around each: 190 / 2 = 95 (FlexLove divides by number of children)
  -- Start position: 95 / 2 = 47.5
  -- Item spacing: 0 + 95 = 95
  luaunit.assertEquals(child1.x, 47.5)
  luaunit.assertEquals(child2.x, 192.5) -- 47.5 + 50 + 95
end

-- Test 6: Horizontal Flex with JustifyContent.SPACE_EVENLY
function TestJustifyContent:testHorizontalFlexJustifyContentSpaceEvenly()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child width: 50 + 60 = 110
  -- Available space: 300 - 110 = 190
  -- Space evenly: 190 / 3 = 63.33... (equal spaces at start, between, and end)
  local expectedSpace = 190 / 3
  luaunit.assertAlmostEquals(child1.x, expectedSpace, 0.01)
  luaunit.assertAlmostEquals(child2.x, expectedSpace + 50 + expectedSpace, 0.01)
end

-- Test 7: Vertical Flex with JustifyContent.FLEX_START
function TestJustifyContent:testVerticalFlexJustifyContentFlexStart()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  local child3 = Gui.new({
    id = "child3",
    w = 70,
    h = 35,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)
  container:addChild(child3)

  -- With FLEX_START, children should be positioned from the start (top)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 30)
  luaunit.assertEquals(child3.y, 70)

  -- X positions should be 0 (aligned to left by default)
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 0)
  luaunit.assertEquals(child3.x, 0)
end

-- Test 8: Vertical Flex with JustifyContent.CENTER
function TestJustifyContent:testVerticalFlexJustifyContentCenter()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child height: 30 + 40 = 70
  -- Available space: 300 - 70 = 230
  -- Center offset: 230 / 2 = 115
  luaunit.assertEquals(child1.y, 115)
  luaunit.assertEquals(child2.y, 145)
end

-- Test 9: Vertical Flex with JustifyContent.FLEX_END
function TestJustifyContent:testVerticalFlexJustifyContentFlexEnd()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_END,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child height: 30 + 40 = 70
  -- Available space: 300 - 70 = 230
  -- Children should be positioned from the end
  luaunit.assertEquals(child1.y, 230)
  luaunit.assertEquals(child2.y, 260)
end

-- Test 10: Vertical Flex with JustifyContent.SPACE_BETWEEN
function TestJustifyContent:testVerticalFlexJustifyContentSpaceBetween()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  local child3 = Gui.new({
    id = "child3",
    w = 40,
    h = 35,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)
  container:addChild(child3)

  -- Total child height: 30 + 40 + 35 = 105
  -- Available space: 300 - 105 = 195
  -- Space between 3 children: 195 / 2 = 97.5
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 127.5) -- 0 + 30 + 97.5
  luaunit.assertEquals(child3.y, 265) -- 127.5 + 40 + 97.5
end

-- Test 11: Vertical Flex with JustifyContent.SPACE_AROUND
function TestJustifyContent:testVerticalFlexJustifyContentSpaceAround()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child height: 30 + 40 = 70
  -- Available space: 300 - 70 = 230
  -- Space around each: 230 / 2 = 115 (FlexLove divides by number of children)
  -- Start position: 115 / 2 = 57.5
  -- Item spacing: 0 + 115 = 115
  luaunit.assertEquals(child1.y, 57.5)
  luaunit.assertEquals(child2.y, 202.5) -- 57.5 + 30 + 115
end

-- Test 12: Vertical Flex with JustifyContent.SPACE_EVENLY
function TestJustifyContent:testVerticalFlexJustifyContentSpaceEvenly()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Total child height: 30 + 40 = 70
  -- Available space: 300 - 70 = 230
  -- Space evenly: 230 / 3 = 76.67... (equal spaces at start, between, and end)
  local expectedSpace = 230 / 3
  luaunit.assertAlmostEquals(child1.y, expectedSpace, 0.01)
  luaunit.assertAlmostEquals(child2.y, expectedSpace + 30 + expectedSpace, 0.01)
end

-- Test 13: JustifyContent with Single Child
function TestJustifyContent:testJustifyContentWithSingleChild()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)

  -- With single child and CENTER, child should be centered
  -- Available space: 300 - 50 = 250
  -- Center offset: 250 / 2 = 125
  luaunit.assertEquals(child1.x, 125)
end

-- Test 14: JustifyContent with No Available Space
function TestJustifyContent:testJustifyContentWithNoAvailableSpace()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 50,
    h = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children exactly fill container width (100)
  -- Should fall back to FLEX_START behavior
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 50)
end

-- Test 15: JustifyContent Preservation with Parent Coordinates
function TestJustifyContent:testJustifyContentWithParentCoordinates()
  local parent = Gui.new({
    id = "parent",
    x = 50,
    y = 30,
    w = 400,
    h = 200,
    positioning = Positioning.ABSOLUTE,
  })

  local container = Gui.new({
    id = "container",
    x = 20,
    y = 10,
    w = 300,
    h = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    gap = 0,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 50,
    h = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
    positioning = Positioning.FLEX,
  })

  parent:addChild(container)
  container:addChild(child1)
  container:addChild(child2)

  -- Container should maintain its own coordinates since parent is ABSOLUTE
  luaunit.assertEquals(container.x, 20) -- container keeps its own x
  luaunit.assertEquals(container.y, 10) -- container keeps its own y

  -- Children should be centered within container coordinate system
  -- Total child width: 50 + 60 = 110
  -- Available space: 300 - 110 = 190
  -- Center offset: 190 / 2 = 95
  -- Children are positioned in absolute coordinates: container.x + offset
  luaunit.assertEquals(child1.x, 115) -- container.x(20) + center_offset(95)
  luaunit.assertEquals(child2.x, 165) -- container.x(20) + center_offset(95) + child1.width(50)
end

-- Test 16: Complex navigation bar with space-between and nested elements
function TestJustifyContent:testComplexNavigationBarLayout()
  local navbar = Gui.new({
    id = "navbar",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    x = 0,
    y = 0,
    w = 1200,
    h = 80,
    gap = 0,
  })

  -- Logo section
  local logoSection = Gui.new({
    id = "logoSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    w = 250,
    h = 70,
    gap = 15,
  })

  local logo = Gui.new({ id = "logo", w = 60, h = 50 })
  local brandName = Gui.new({ id = "brandName", w = 120, h = 30 })
  local beta = Gui.new({ id = "beta", w = 40, h = 20 })

  logoSection:addChild(logo)
  logoSection:addChild(brandName)
  logoSection:addChild(beta)

  -- Navigation menu
  local navMenu = Gui.new({
    id = "navMenu",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    w = 500,
    h = 70,
    gap = 30,
  })

  local menuItems = { "Home", "Products", "Solutions", "About", "Contact" }
  for i, itemName in ipairs(menuItems) do
    local menuItem = Gui.new({
      id = "menuItem" .. itemName,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.CENTER,
      alignItems = AlignItems.CENTER,
      w = 80,
      h = 60,
      gap = 5,
    })

    local itemText = Gui.new({ id = "itemText" .. itemName, w = 70, h = 20 })
    local itemDot = Gui.new({ id = "itemDot" .. itemName, w = 6, h = 6 })

    menuItem:addChild(itemText)
    menuItem:addChild(itemDot)
    navMenu:addChild(menuItem)
  end

  -- Action buttons section
  local actionsSection = Gui.new({
    id = "actionsSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    w = 300,
    h = 70,
    gap = 12,
  })

  local searchButton = Gui.new({ id = "searchButton", w = 40, h = 40 })
  local loginButton = Gui.new({ id = "loginButton", w = 80, h = 35 })
  local signupButton = Gui.new({ id = "signupButton", w = 100, h = 40 })
  local mobileMenu = Gui.new({ id = "mobileMenu", w = 35, h = 35 })

  actionsSection:addChild(searchButton)
  actionsSection:addChild(loginButton)
  actionsSection:addChild(signupButton)
  actionsSection:addChild(mobileMenu)

  navbar:addChild(logoSection)
  navbar:addChild(navMenu)
  navbar:addChild(actionsSection)

  -- Verify space-between layout: elements should be distributed with equal space between
  luaunit.assertEquals(logoSection.x, navbar.x)
  luaunit.assertEquals(actionsSection.x + actionsSection.width, navbar.x + navbar.width)

  -- Center menu should be positioned between logo and actions
  local expectedMenuX = logoSection.x
    + logoSection.width
    + ((navbar.width - logoSection.width - navMenu.width - actionsSection.width) / 2)
  luaunit.assertEquals(navMenu.x, expectedMenuX)

  -- Verify nested center alignment in menu items
  local firstMenuItem = navMenu.children[1]
  local menuItemsWidth = 5 * 80 + 4 * 30 -- 5 items × 80px + 4 gaps × 30px = 520px
  local menuStartX = navMenu.x + (navMenu.width - menuItemsWidth) / 2
  luaunit.assertEquals(firstMenuItem.x, menuStartX)

  -- Verify flex-end alignment in actions
  local expectedActionsContentWidth = 40 + 80 + 100 + 35 + 3 * 12 -- widths + gaps = 291px
  local expectedActionsStartX = actionsSection.x + actionsSection.width - expectedActionsContentWidth
  luaunit.assertEquals(searchButton.x, expectedActionsStartX)
end

-- Test 17: Dashboard metrics layout with space-around
function TestJustifyContent:testDashboardMetricsSpaceAround()
  local metricsContainer = Gui.new({
    id = "metricsContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    x = 0,
    y = 0,
    w = 1000,
    h = 200,
    gap = 0,
  })

  -- Create metric cards with different complexities
  local metrics = {
    { title = "Revenue", hasChart = true, hasTrend = true },
    { title = "Users", hasChart = false, hasTrend = true },
    { title = "Orders", hasChart = true, hasTrend = false },
    { title = "Growth", hasChart = false, hasTrend = true },
  }

  for i, metric in ipairs(metrics) do
    local metricCard = Gui.new({
      id = "metricCard" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      w = 220,
      h = 180,
      gap = 10,
    })

    -- Card header
    local cardHeader = Gui.new({
      id = "cardHeader" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      w = 200,
      h = 30,
      gap = 5,
    })

    local metricTitle = Gui.new({ id = "metricTitle" .. i, w = 100, h = 25 })
    local metricIcon = Gui.new({ id = "metricIcon" .. i, w = 24, h = 24 })

    cardHeader:addChild(metricTitle)
    cardHeader:addChild(metricIcon)

    -- Value section
    local valueSection = Gui.new({
      id = "valueSection" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.CENTER,
      alignItems = AlignItems.CENTER,
      w = 200,
      h = 80,
      gap = 8,
    })

    local mainValue = Gui.new({ id = "mainValue" .. i, w = 120, h = 40 })
    local valueLabel = Gui.new({ id = "valueLabel" .. i, w = 80, h = 16 })

    valueSection:addChild(mainValue)
    valueSection:addChild(valueLabel)

    if metric.hasTrend then
      local trendIndicator = Gui.new({ id = "trendIndicator" .. i, w = 60, h = 20 })
      valueSection:addChild(trendIndicator)
      valueSection.height = 100
    end

    -- Bottom section (chart or additional info)
    local bottomSection = Gui.new({
      id = "bottomSection" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = metric.hasChart and JustifyContent.CENTER or JustifyContent.SPACE_EVENLY,
      alignItems = AlignItems.CENTER,
      w = 200,
      h = 50,
      gap = 5,
    })

    if metric.hasChart then
      local miniChart = Gui.new({ id = "miniChart" .. i, w = 150, h = 40 })
      bottomSection:addChild(miniChart)
    else
      -- Add comparison indicators
      local prevPeriod = Gui.new({ id = "prevPeriod" .. i, w = 60, h = 20 })
      local comparison = Gui.new({ id = "comparison" .. i, w = 40, h = 20 })
      local target = Gui.new({ id = "target" .. i, w = 60, h = 20 })

      bottomSection:addChild(prevPeriod)
      bottomSection:addChild(comparison)
      bottomSection:addChild(target)
    end

    metricCard:addChild(cardHeader)
    metricCard:addChild(valueSection)
    metricCard:addChild(bottomSection)
    metricsContainer:addChild(metricCard)
  end

  -- Verify space-around distribution
  local totalCardsWidth = 4 * 220 -- 880px
  local availableSpace = 1000 - 880 -- 120px
  local spaceAroundEach = availableSpace / 4 -- 30px around each card
  local spaceAtEnds = spaceAroundEach / 2 -- 15px at each end

  local firstCard = metricsContainer.children[1]
  local secondCard = metricsContainer.children[2]

  luaunit.assertEquals(firstCard.x, spaceAtEnds)
  luaunit.assertEquals(secondCard.x, spaceAtEnds + 220 + spaceAroundEach)

  -- Verify nested space-between in card headers
  local firstCardHeader = firstCard.children[1]
  local headerTitle = firstCardHeader.children[1]
  local headerIcon = firstCardHeader.children[2]

  luaunit.assertEquals(headerTitle.x, firstCardHeader.x)
  luaunit.assertEquals(headerIcon.x + headerIcon.width, firstCardHeader.x + firstCardHeader.width)
end

-- Test 18: Complex form layout with varied justify content
function TestJustifyContent:testComplexFormJustifyContentLayout()
  local formContainer = Gui.new({
    id = "formContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 600,
    h = 800,
    gap = 25,
  })

  -- Form header with space-between
  local formHeader = Gui.new({
    id = "formHeader",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    w = 580,
    h = 60,
    gap = 0,
  })

  local headerLeft = Gui.new({
    id = "headerLeft",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 200,
    h = 50,
    gap = 5,
  })

  local formTitle = Gui.new({ id = "formTitle", w = 180, h = 30 })
  local formSubtitle = Gui.new({ id = "formSubtitle", w = 200, h = 15 })

  headerLeft:addChild(formTitle)
  headerLeft:addChild(formSubtitle)

  local headerRight = Gui.new({
    id = "headerRight",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    w = 150,
    h = 50,
    gap = 10,
  })

  local helpButton = Gui.new({ id = "helpButton", w = 30, h = 30 })
  local closeButton = Gui.new({ id = "closeButton", w = 30, h = 30 })

  headerRight:addChild(helpButton)
  headerRight:addChild(closeButton)

  formHeader:addChild(headerLeft)
  formHeader:addChild(headerRight)

  -- Field sections with different alignments
  local personalSection = Gui.new({
    id = "personalSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 580,
    h = 250,
    gap = 15,
  })

  local sectionTitle = Gui.new({
    id = "sectionTitle",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    w = 580,
    h = 30,
    gap = 10,
  })

  local titleText = Gui.new({ id = "titleText", w = 150, h = 25 })
  local titleIcon = Gui.new({ id = "titleIcon", w = 20, h = 20 })

  sectionTitle:addChild(titleText)
  sectionTitle:addChild(titleIcon)

  -- Field rows with different layouts
  local nameRow = Gui.new({
    id = "nameRow",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    w = 580,
    h = 60,
    gap = 15,
  })

  local firstNameGroup = Gui.new({
    id = "firstNameGroup",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 275,
    h = 55,
    gap = 5,
  })

  local firstNameLabel = Gui.new({ id = "firstNameLabel", w = 80, h = 20 })
  local firstNameInput = Gui.new({ id = "firstNameInput", w = 275, h = 30 })

  firstNameGroup:addChild(firstNameLabel)
  firstNameGroup:addChild(firstNameInput)

  local lastNameGroup = Gui.new({
    id = "lastNameGroup",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 275,
    h = 55,
    gap = 5,
  })

  local lastNameLabel = Gui.new({ id = "lastNameLabel", w = 80, h = 20 })
  local lastNameInput = Gui.new({ id = "lastNameInput", w = 275, h = 30 })

  lastNameGroup:addChild(lastNameLabel)
  lastNameGroup:addChild(lastNameInput)

  nameRow:addChild(firstNameGroup)
  nameRow:addChild(lastNameGroup)

  -- Contact preferences with space-evenly
  local contactRow = Gui.new({
    id = "contactRow",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
    alignItems = AlignItems.CENTER,
    w = 580,
    h = 50,
    gap = 0,
  })

  local emailOption = Gui.new({
    id = "emailOption",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    w = 120,
    h = 40,
    gap = 8,
  })

  Gui.new({ parent = emailOption, id = "emailCheckbox", w = 20, h = 20 })
  Gui.new({ parent = emailOption, id = "emailLabel", w = 60, h = 18 })

  local phoneOption = Gui.new({
    id = "phoneOption",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    w = 120,
    h = 40,
    gap = 8,
  })

  local phoneCheckbox = Gui.new({ id = "phoneCheckbox", w = 20, h = 20 })
  local phoneLabel = Gui.new({ id = "phoneLabel", w = 60, h = 18 })

  phoneOption:addChild(phoneCheckbox)
  phoneOption:addChild(phoneLabel)

  local smsOption = Gui.new({
    id = "smsOption",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    w = 100,
    h = 40,
    gap = 8,
  })

  local smsCheckbox = Gui.new({ id = "smsCheckbox", w = 20, h = 20 })
  local smsLabel = Gui.new({ id = "smsLabel", w = 50, h = 18 })

  smsOption:addChild(smsCheckbox)
  smsOption:addChild(smsLabel)

  contactRow:addChild(emailOption)
  contactRow:addChild(phoneOption)
  contactRow:addChild(smsOption)

  personalSection:addChild(sectionTitle)
  personalSection:addChild(nameRow)
  personalSection:addChild(contactRow)

  -- Form actions with varied justification
  local actionsSection = Gui.new({
    id = "actionsSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 580,
    h = 120,
    gap = 20,
  })

  local primaryActions = Gui.new({
    id = "primaryActions",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    w = 580,
    h = 45,
    gap = 15,
  })

  local cancelButton = Gui.new({ id = "cancelButton", w = 80, h = 40 })
  local saveButton = Gui.new({ id = "saveButton", w = 100, h = 40 })
  local submitButton = Gui.new({ id = "submitButton", w = 120, h = 40 })

  primaryActions:addChild(cancelButton)
  primaryActions:addChild(saveButton)
  primaryActions:addChild(submitButton)

  local secondaryActions = Gui.new({
    id = "secondaryActions",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    w = 580,
    h = 35,
    gap = 25,
  })

  local resetButton = Gui.new({ id = "resetButton", w = 70, h = 30 })
  local previewButton = Gui.new({ id = "previewButton", w = 80, h = 30 })

  secondaryActions:addChild(resetButton)
  secondaryActions:addChild(previewButton)

  actionsSection:addChild(primaryActions)
  actionsSection:addChild(secondaryActions)

  formContainer:addChild(formHeader)
  formContainer:addChild(personalSection)
  formContainer:addChild(actionsSection)

  -- Verify complex justify content behaviors
  -- Header space-between
  luaunit.assertEquals(headerLeft.x, formHeader.x)
  luaunit.assertEquals(headerRight.x + headerRight.width, formHeader.x + formHeader.width)

  -- Name row space-between
  luaunit.assertEquals(firstNameGroup.x, nameRow.x)
  luaunit.assertEquals(lastNameGroup.x + lastNameGroup.width, nameRow.x + nameRow.width)

  -- Contact preferences space-evenly
  local totalOptionsWidth = 120 + 120 + 100 -- 340px
  local availableSpace = 580 - 340 -- 240px
  local evenSpacing = 240 / 4 -- 60px (spaces before, between, between, after)

  luaunit.assertEquals(emailOption.x, contactRow.x + evenSpacing)
  luaunit.assertEquals(phoneOption.x, emailOption.x + emailOption.width + evenSpacing)
  luaunit.assertEquals(smsOption.x, phoneOption.x + phoneOption.width + evenSpacing)

  -- Primary actions flex-end
  local totalPrimaryWidth = 80 + 100 + 120 + 2 * 15 -- 330px including gaps
  local expectedPrimaryStartX = primaryActions.x + primaryActions.width - totalPrimaryWidth
  luaunit.assertEquals(cancelButton.x, expectedPrimaryStartX)

  -- Secondary actions center
  local totalSecondaryWidth = 70 + 80 + 25 -- 175px including gap
  local expectedSecondaryStartX = secondaryActions.x + (secondaryActions.width - totalSecondaryWidth) / 2
  luaunit.assertEquals(resetButton.x, expectedSecondaryStartX)
end

-- Test 19: Grid-like layout with justify content variations
function TestJustifyContent:testGridLayoutJustifyContentVariations()
  local gridContainer = Gui.new({
    id = "gridContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 800,
    h = 600,
    gap = 20,
  })

  -- Row 1: Space-between
  local row1 = Gui.new({
    id = "row1",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    w = 780,
    h = 120,
    gap = 0,
  })

  for i = 1, 4 do
    local card = Gui.new({
      id = "row1Card" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.CENTER,
      alignItems = AlignItems.CENTER,
      w = 150,
      h = 100,
      gap = 10,
    })

    local cardIcon = Gui.new({ id = "row1Icon" .. i, w = 40, h = 40 })
    local cardLabel = Gui.new({ id = "row1Label" .. i, w = 100, h = 20 })

    card:addChild(cardIcon)
    card:addChild(cardLabel)
    row1:addChild(card)
  end

  -- Row 2: Space-around
  local row2 = Gui.new({
    id = "row2",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    w = 780,
    h = 120,
    gap = 0,
  })

  for i = 1, 3 do
    local card = Gui.new({
      id = "row2Card" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      w = 200,
      h = 100,
      gap = 5,
    })

    local cardHeader = Gui.new({
      id = "row2Header" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      w = 180,
      h = 25,
      gap = 0,
    })

    local headerTitle = Gui.new({ id = "row2HeaderTitle" .. i, w = 100, h = 20 })
    local headerIcon = Gui.new({ id = "row2HeaderIcon" .. i, w = 20, h = 20 })

    cardHeader:addChild(headerTitle)
    cardHeader:addChild(headerIcon)

    local cardContent = Gui.new({ id = "row2Content" .. i, w = 180, h = 40 })
    local cardFooter = Gui.new({ id = "row2Footer" .. i, w = 180, h = 20 })

    card:addChild(cardHeader)
    card:addChild(cardContent)
    card:addChild(cardFooter)
    row2:addChild(card)
  end

  -- Row 3: Space-evenly
  local row3 = Gui.new({
    id = "row3",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
    w = 780,
    h = 120,
    gap = 0,
  })

  for i = 1, 5 do
    local item = Gui.new({
      id = "row3Item" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_END,
      alignItems = AlignItems.CENTER,
      w = 100,
      h = 100,
      gap = 5,
    })

    local itemValue = Gui.new({ id = "row3Value" .. i, w = 60, h = 30 })
    local itemLabel = Gui.new({ id = "row3Label" .. i, w = 80, h = 15 })
    local itemTrend = Gui.new({ id = "row3Trend" .. i, w = 40, h = 12 })

    item:addChild(itemValue)
    item:addChild(itemLabel)
    item:addChild(itemTrend)
    row3:addChild(item)
  end

  -- Row 4: Center with overflow behavior
  local row4 = Gui.new({
    id = "row4",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    w = 780,
    h = 120,
    gap = 10,
  })

  -- Create many items that might overflow
  for i = 1, 8 do
    local chip = Gui.new({
      id = "row4Chip" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.CENTER,
      alignItems = AlignItems.CENTER,
      w = 90,
      h = 30,
      gap = 5,
    })

    local chipIcon = Gui.new({ id = "row4ChipIcon" .. i, w = 16, h = 16 })
    local chipText = Gui.new({ id = "row4ChipText" .. i, w = 60, h = 14 })

    chip:addChild(chipIcon)
    chip:addChild(chipText)
    row4:addChild(chip)
  end

  gridContainer:addChild(row1)
  gridContainer:addChild(row2)
  gridContainer:addChild(row3)
  gridContainer:addChild(row4)

  -- Verify row 1 space-between (4 cards, 150px each)
  local row1Card1 = row1.children[1]
  local row1Card4 = row1.children[4]

  luaunit.assertEquals(row1Card1.x, row1.x)
  luaunit.assertEquals(row1Card4.x + row1Card4.width, row1.x + row1.width)

  -- Verify row 2 space-around (3 cards, 200px each)
  local totalRow2Width = 3 * 200 -- 600px
  local row2AvailableSpace = 780 - 600 -- 180px
  local row2SpaceAround = 180 / 3 -- 60px around each
  local row2SpaceAtEnds = 60 / 2 -- 30px at ends

  local row2Card1 = row2.children[1]
  luaunit.assertEquals(row2Card1.x, row2.x + row2SpaceAtEnds)

  -- Verify row 3 space-evenly (5 items, 100px each)
  local totalRow3Width = 5 * 100 -- 500px
  local row3AvailableSpace = 780 - 500 -- 280px
  local row3EvenSpacing = 280 / 6 -- 46.67px (6 spaces: before, between×4, after)

  local row3Item1 = row3.children[1]
  luaunit.assertAlmostEquals(row3Item1.x, row3.x + row3EvenSpacing, 0.1)

  -- Verify row 4 center behavior (8 chips, 90px each + 7 gaps of 10px = 790px)
  -- Should overflow slightly but center the content
  local totalRow4Width = 8 * 90 + 7 * 10 -- 790px (larger than container)
  local row4Offset = (row4.width - totalRow4Width) / 2 -- Should be negative
  local row4Chip1 = row4.children[1]

  -- When content is larger than container, should start at calculated offset (possibly negative)
  luaunit.assertEquals(row4Chip1.x, row4.x + row4Offset)

  -- Verify nested justify content in cards
  local row2Card1Header = row2.children[1].children[1]
  local headerTitle = row2Card1Header.children[1]
  local headerIcon = row2Card1Header.children[2]

  luaunit.assertEquals(headerTitle.x, row2Card1Header.x)
  luaunit.assertEquals(headerIcon.x + headerIcon.width, row2Card1Header.x + row2Card1Header.width)
end

-- Test 20: Multi-level nested justify content with modal dialogs
function TestJustifyContent:testMultiLevelNestedModalJustifyContent()
  local modalOverlay = Gui.new({
    id = "modalOverlay",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.CENTER,
    x = 0,
    y = 0,
    w = 1200,
    h = 800,
    gap = 0,
  })

  local modal = Gui.new({
    id = "modal",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    w = 600,
    h = 500,
    gap = 0,
  })

  -- Modal header with space-between
  local modalHeader = Gui.new({
    id = "modalHeader",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    w = 580,
    h = 60,
    gap = 0,
  })

  local headerLeft = Gui.new({
    id = "headerLeft",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    w = 200,
    h = 50,
    gap = 12,
  })

  local modalIcon = Gui.new({ id = "modalIcon", w = 24, h = 24 })
  local modalTitle = Gui.new({ id = "modalTitle", w = 150, h = 30 })

  headerLeft:addChild(modalIcon)
  headerLeft:addChild(modalTitle)

  local headerRight = Gui.new({
    id = "headerRight",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    w = 100,
    h = 50,
    gap = 8,
  })

  local minimizeButton = Gui.new({ id = "minimizeButton", w = 30, h = 30 })
  local closeButton = Gui.new({ id = "closeButton", w = 30, h = 30 })

  headerRight:addChild(minimizeButton)
  headerRight:addChild(closeButton)

  modalHeader:addChild(headerLeft)
  modalHeader:addChild(headerRight)

  -- Modal content with complex nested layouts
  local modalContent = Gui.new({
    id = "modalContent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 580,
    h = 380,
    gap = 20,
  })

  -- Tab navigation
  local tabNavigation = Gui.new({
    id = "tabNavigation",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
    w = 580,
    h = 50,
    gap = 0,
  })

  local tabs = { "General", "Advanced", "Security", "Notifications" }
  for i, tabName in ipairs(tabs) do
    local tab = Gui.new({
      id = "tab" .. tabName,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.CENTER,
      alignItems = AlignItems.CENTER,
      w = 120,
      h = 45,
      gap = 5,
    })

    local tabText = Gui.new({ id = "tabText" .. tabName, w = 80, h = 18 })
    local tabIndicator = Gui.new({ id = "tabIndicator" .. tabName, w = 60, h = 3 })

    tab:addChild(tabText)
    tab:addChild(tabIndicator)
    tabNavigation:addChild(tab)
  end

  -- Content area with settings rows
  local settingsArea = Gui.new({
    id = "settingsArea",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 580,
    h = 250,
    gap = 15,
  })

  -- Setting rows with different alignments
  for i = 1, 4 do
    local settingRow = Gui.new({
      id = "settingRow" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = i % 2 == 1 and JustifyContent.SPACE_BETWEEN or JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      w = 560,
      h = 50,
      gap = 15,
    })

    local settingInfo = Gui.new({
      id = "settingInfo" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.CENTER,
      w = 300,
      h = 40,
      gap = 3,
    })

    local settingLabel = Gui.new({ id = "settingLabel" .. i, w = 200, h = 20 })
    local settingDescription = Gui.new({ id = "settingDescription" .. i, w = 280, h = 14 })

    settingInfo:addChild(settingLabel)
    settingInfo:addChild(settingDescription)

    local settingControl = Gui.new({
      id = "settingControl" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.CENTER,
      alignItems = AlignItems.CENTER,
      w = i % 2 == 1 and 100 or 200,
      h = 35,
      gap = 8,
    })

    if i % 2 == 1 then
      -- Toggle switch
      local toggle = Gui.new({ id = "toggle" .. i, w = 60, h = 30 })
      settingControl:addChild(toggle)
    else
      -- Dropdown or input
      local input = Gui.new({ id = "input" .. i, w = 120, h = 30 })
      local button = Gui.new({ id = "button" .. i, w = 60, h = 28 })
      settingControl:addChild(input)
      settingControl:addChild(button)
    end

    settingRow:addChild(settingInfo)
    settingRow:addChild(settingControl)
    settingsArea:addChild(settingRow)
  end

  modalContent:addChild(tabNavigation)
  modalContent:addChild(settingsArea)

  -- Modal footer with action buttons
  local modalFooter = Gui.new({
    id = "modalFooter",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    w = 580,
    h = 60,
    gap = 0,
  })

  local footerLeft = Gui.new({
    id = "footerLeft",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.CENTER,
    w = 200,
    h = 50,
    gap = 10,
  })

  local resetButton = Gui.new({ id = "resetButton", w = 80, h = 35 })
  local helpLink = Gui.new({ id = "helpLink", w = 60, h = 20 })

  footerLeft:addChild(resetButton)
  footerLeft:addChild(helpLink)

  local footerRight = Gui.new({
    id = "footerRight",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    alignItems = AlignItems.CENTER,
    w = 250,
    h = 50,
    gap = 12,
  })

  local cancelButton = Gui.new({ id = "cancelButton", w = 70, h = 35 })
  local applyButton = Gui.new({ id = "applyButton", w = 70, h = 35 })
  local saveButton = Gui.new({ id = "saveButton", w = 80, h = 35 })

  footerRight:addChild(cancelButton)
  footerRight:addChild(applyButton)
  footerRight:addChild(saveButton)

  modalFooter:addChild(footerLeft)
  modalFooter:addChild(footerRight)

  modal:addChild(modalHeader)
  modal:addChild(modalContent)
  modal:addChild(modalFooter)
  modalOverlay:addChild(modal)

  -- Verify modal is centered in overlay
  local expectedModalX = modalOverlay.x + (modalOverlay.width - modal.width) / 2
  luaunit.assertEquals(modal.x, expectedModalX)

  -- Verify modal space-between layout
  luaunit.assertEquals(modalHeader.y, modal.y)
  luaunit.assertEquals(modalFooter.y + modalFooter.height, modal.y + modal.height)

  -- Verify header space-between
  luaunit.assertEquals(headerLeft.x, modalHeader.x)
  luaunit.assertEquals(headerRight.x + headerRight.width, modalHeader.x + modalHeader.width)

  -- Verify tab space-evenly distribution
  local totalTabsWidth = 4 * 120 -- 480px
  local tabAvailableSpace = 580 - 480 -- 100px
  local tabEvenSpacing = 100 / 5 -- 20px (5 spaces: before, between×3, after)

  local firstTab = tabNavigation.children[1]
  luaunit.assertEquals(firstTab.x, tabNavigation.x + tabEvenSpacing)

  -- Verify setting rows alternate justification
  local setting1 = settingsArea.children[1] -- space-between
  local setting2 = settingsArea.children[2] -- flex-start

  local setting1Info = setting1.children[1]
  local setting1Control = setting1.children[2]

  luaunit.assertEquals(setting1Info.x, setting1.x)
  luaunit.assertEquals(setting1Control.x + setting1Control.width, setting1.x + setting1.width)

  local setting2Info = setting2.children[1]
  local setting2Control = setting2.children[2]

  luaunit.assertEquals(setting2Info.x, setting2.x)
  luaunit.assertEquals(setting2Control.x, setting2Info.x + setting2Info.width + setting2.gap)

  -- Verify footer space-between
  luaunit.assertEquals(footerLeft.x, modalFooter.x)
  luaunit.assertEquals(footerRight.x + footerRight.width, modalFooter.x + modalFooter.width)

  -- Verify nested button layouts in footer
  local footerRightFirstButton = footerRight.children[1]
  local footerRightLastButton = footerRight.children[3]
  local expectedFooterRightStartX = footerRight.x + footerRight.width - (70 + 70 + 80 + 2 * 12)

  luaunit.assertEquals(footerRightFirstButton.x, expectedFooterRightStartX)
end

luaunit.LuaUnit.run()
