-- 06. Align Items Tests
-- Tests for FlexLove align items functionality

-- Load test framework and dependencies
package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

-- Import required enums
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local AlignItems = enums.AlignItems
local JustifyContent = enums.JustifyContent

-- Test class for align items functionality
TestAlignItems = {}

function TestAlignItems:setUp()
  -- Clear any previous state if needed
  Gui.destroy()
end

function TestAlignItems:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Test 1: Horizontal Flex with AlignItems.FLEX_START
function TestAlignItems:testHorizontalFlexAlignItemsFlexStart()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_START,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local child3 = Gui.new({
    id = "child3",
    width = 70,
    height = 20,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)
  container:addChild(child3)

  -- With FLEX_START, children should be aligned to top (start of cross axis)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 0)
  luaunit.assertEquals(child3.y, 0)

  -- Heights should remain original (no stretching)
  luaunit.assertEquals(child1.height, 30)
  luaunit.assertEquals(child2.height, 40)
  luaunit.assertEquals(child3.height, 20)
end

-- Test 2: Horizontal Flex with AlignItems.CENTER
function TestAlignItems:testHorizontalFlexAlignItemsCenter()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children should be centered vertically
  -- child1: (100 - 30) / 2 = 35
  -- child2: (100 - 40) / 2 = 30
  luaunit.assertEquals(child1.y, 35)
  luaunit.assertEquals(child2.y, 30)

  -- Heights should remain original
  luaunit.assertEquals(child1.height, 30)
  luaunit.assertEquals(child2.height, 40)
end

-- Test 3: Horizontal Flex with AlignItems.FLEX_END
function TestAlignItems:testHorizontalFlexAlignItemsFlexEnd()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_END,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children should be aligned to bottom (end of cross axis)
  -- child1: 100 - 30 = 70
  -- child2: 100 - 40 = 60
  luaunit.assertEquals(child1.y, 70)
  luaunit.assertEquals(child2.y, 60)

  -- Heights should remain original
  luaunit.assertEquals(child1.height, 30)
  luaunit.assertEquals(child2.height, 40)
end

-- Test 4: Horizontal Flex with AlignItems.STRETCH
function TestAlignItems:testHorizontalFlexAlignItemsStretch()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.STRETCH,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children with explicit heights should NOT be stretched (CSS flexbox behavior)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 0)
  luaunit.assertEquals(child1.height, 30)  -- Keeps explicit height
  luaunit.assertEquals(child2.height, 40)  -- Keeps explicit height
end

-- Test 5: Vertical Flex with AlignItems.FLEX_START
function TestAlignItems:testVerticalFlexAlignItemsFlexStart()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 80,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local child3 = Gui.new({
    id = "child3",
    width = 60,
    height = 35,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)
  container:addChild(child3)

  -- With FLEX_START, children should be aligned to left (start of cross axis)
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 0)
  luaunit.assertEquals(child3.x, 0)

  -- Widths should remain original (no stretching)
  luaunit.assertEquals(child1.width, 50)
  luaunit.assertEquals(child2.width, 80)
  luaunit.assertEquals(child3.width, 60)
end

-- Test 6: Vertical Flex with AlignItems.CENTER
function TestAlignItems:testVerticalFlexAlignItemsCenter()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 80,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children should be centered horizontally
  -- child1: (200 - 50) / 2 = 75
  -- child2: (200 - 80) / 2 = 60
  luaunit.assertEquals(child1.x, 75)
  luaunit.assertEquals(child2.x, 60)

  -- Widths should remain original
  luaunit.assertEquals(child1.width, 50)
  luaunit.assertEquals(child2.width, 80)
end

-- Test 7: Vertical Flex with AlignItems.FLEX_END
function TestAlignItems:testVerticalFlexAlignItemsFlexEnd()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_END,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 80,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children should be aligned to right (end of cross axis)
  -- child1: 200 - 50 = 150
  -- child2: 200 - 80 = 120
  luaunit.assertEquals(child1.x, 150)
  luaunit.assertEquals(child2.x, 120)

  -- Widths should remain original
  luaunit.assertEquals(child1.width, 50)
  luaunit.assertEquals(child2.width, 80)
end

-- Test 8: Vertical Flex with AlignItems.STRETCH
function TestAlignItems:testVerticalFlexAlignItemsStretch()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 300,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 80,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children with explicit widths should NOT be stretched (CSS flexbox behavior)
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 0)
  luaunit.assertEquals(child1.width, 50)  -- Keeps explicit width
  luaunit.assertEquals(child2.width, 80)  -- Keeps explicit width
end

-- Test 9: Default AlignItems value (should be STRETCH)
function TestAlignItems:testDefaultAlignItems()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    -- No alignItems specified, should default to STRETCH
  })

  local child = Gui.new({
    id = "child",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  container:addChild(child)

  -- Default should be STRETCH, but explicit heights are respected
  luaunit.assertEquals(container.alignItems, AlignItems.STRETCH)
  luaunit.assertEquals(child.height, 30) -- Keeps explicit height (CSS flexbox behavior)
end

-- Test 10: AlignItems with mixed child sizes
function TestAlignItems:testAlignItemsWithMixedChildSizes()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 40,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 50,
    height = 80,
    positioning = Positioning.FLEX,
  })

  local child3 = Gui.new({
    id = "child3",
    width = 60,
    height = 30,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)
  container:addChild(child3)

  -- All children should be centered vertically
  -- child1: (120 - 20) / 2 = 50
  -- child2: (120 - 80) / 2 = 20
  -- child3: (120 - 30) / 2 = 45
  luaunit.assertEquals(child1.y, 50)
  luaunit.assertEquals(child2.y, 20)
  luaunit.assertEquals(child3.y, 45)
end

-- Test 11: AlignItems with single child
function TestAlignItems:testAlignItemsWithSingleChild()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_END,
  })

  local child = Gui.new({
    id = "child",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  container:addChild(child)

  -- Child should be aligned to bottom
  luaunit.assertEquals(child.y, 70) -- 100 - 30
end

-- Test 12: AlignItems with container coordinates
function TestAlignItems:testAlignItemsWithContainerCoordinates()
  local container = Gui.new({
    id = "container",
    x = 50,
    y = 20,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local child = Gui.new({
    id = "child",
    width = 60,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child)

  -- Child should be centered relative to container position
  -- Y position: container.y + (container.height - child.height) / 2
  -- Y position: 20 + (100 - 40) / 2 = 20 + 30 = 50
  luaunit.assertEquals(child.y, 50)
end

-- Test 13: AlignItems BASELINE (should behave like FLEX_START for now)
function TestAlignItems:testAlignItemsBaseline()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.BASELINE,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- BASELINE should behave like FLEX_START for basic implementation
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.y, 0)
end

-- Test 14: AlignItems interaction with gap
function TestAlignItems:testAlignItemsWithGap()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 300,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    gap = 10,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
    positioning = Positioning.FLEX,
  })

  container:addChild(child1)
  container:addChild(child2)

  -- Children should be centered vertically despite gap
  luaunit.assertEquals(child1.y, 35) -- (100 - 30) / 2
  luaunit.assertEquals(child2.y, 30) -- (100 - 40) / 2

  -- X positions should respect gap
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child2.x, 60) -- 50 + 10 gap
end

-- Test 15: AlignItems with different flex directions
function TestAlignItems:testAlignItemsCrossAxisConsistency()
  -- Horizontal container with vertical alignment
  local hContainer = Gui.new({
    id = "hContainer",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local hChild = Gui.new({
    id = "hChild",
    width = 50,
    height = 40,
    positioning = Positioning.FLEX,
  })

  hContainer:addChild(hChild)

  -- Vertical container with horizontal alignment
  local vContainer = Gui.new({
    id = "vContainer",
    x = 0,
    y = 0,
    width = 100,
    height = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local vChild = Gui.new({
    id = "vChild",
    width = 40,
    height = 50,
    positioning = Positioning.FLEX,
  })

  vContainer:addChild(vChild)

  -- Both should be centered on their respective cross axes
  luaunit.assertEquals(hChild.y, 30) -- (100 - 40) / 2 - vertical centering
  luaunit.assertEquals(vChild.x, 30) -- (100 - 40) / 2 - horizontal centering
end

-- Test 16: Complex Card Layout with Mixed AlignItems
function TestAlignItems:testComplexCardLayoutMixedAlignItems()
  -- Main card container
  local card = Gui.new({
    id = "card",
    x = 10,
    y = 10,
    width = 300,
    height = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Card header with icon and title (horizontal layout, center-aligned)
  local header = Gui.new({
    id = "header",
    width = 300,
    height = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local icon = Gui.new({
    id = "icon",
    width = 24,
    height = 24,
    positioning = Positioning.FLEX,
  })

  local title = Gui.new({
    id = "title",
    width = 200,
    height = 24,
    positioning = Positioning.FLEX,
  })

  local actions = Gui.new({
    id = "actions",
    width = 60,
    height = 30,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_START,
  })

  local btn1 = Gui.new({
    id = "btn1",
    width = 28,
    height = 28,
    positioning = Positioning.FLEX,
  })

  local btn2 = Gui.new({
    id = "btn2",
    width = 28,
    height = 20,
    positioning = Positioning.FLEX,
  })

  -- Card content with flex-end alignment
  local content = Gui.new({
    id = "content",
    width = 300,
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_END,
  })

  local contentText = Gui.new({
    id = "contentText",
    width = 250,
    height = 80,
    positioning = Positioning.FLEX,
  })

  local metadata = Gui.new({
    id = "metadata",
    width = 180,
    height = 30,
    positioning = Positioning.FLEX,
  })

  -- Card footer with space-between and center alignment
  local footer = Gui.new({
    id = "footer",
    width = 300,
    height = 30,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local timestamp = Gui.new({
    id = "timestamp",
    width = 80,
    height = 16,
    positioning = Positioning.FLEX,
  })

  local status = Gui.new({
    id = "status",
    width = 60,
    height = 20,
    positioning = Positioning.FLEX,
  })

  -- Build the tree
  actions:addChild(btn1)
  actions:addChild(btn2)
  header:addChild(icon)
  header:addChild(title)
  header:addChild(actions)

  content:addChild(contentText)
  content:addChild(metadata)

  footer:addChild(timestamp)
  footer:addChild(status)

  card:addChild(header)
  card:addChild(content)
  card:addChild(footer)

  -- Verify alignments in header (CENTER)
  luaunit.assertEquals(icon.y, 23) -- (50 - 24) / 2 = 13, plus card.y = 10 + 13 = 23
  luaunit.assertEquals(title.y, 23) -- Same center alignment

  -- Verify actions buttons have FLEX_START alignment
  -- actions is centered in header: header.y (10) + (header.height (50) - actions.height (30)) / 2 = 20
  luaunit.assertEquals(btn1.y, 20) -- Start of actions container
  luaunit.assertEquals(btn2.y, 20) -- Same start position

  -- Verify content alignment (FLEX_END)
  luaunit.assertEquals(contentText.x, 60) -- 300 - 250 = 50, plus card.x = 10 + 50 = 60
  luaunit.assertEquals(metadata.x, 130) -- 300 - 180 = 120, plus card.x = 10 + 120 = 130

  -- Verify footer center alignment
  -- footer.y = card.y (10) + header.height (50) + content.height (120) = 180 (no gap specified)
  luaunit.assertEquals(timestamp.y, 187) -- Footer center: (30 - 16) / 2 = 7, plus footer.y = 180 + 7 = 187
  luaunit.assertEquals(status.y, 185) -- Footer center: (30 - 20) / 2 = 5, plus footer.y = 180 + 5 = 185
end

-- Test 17: Complex Media Object Pattern with Nested Alignments
function TestAlignItems:testComplexMediaObjectNestedAlignments()
  -- Main media container
  local mediaContainer = Gui.new({
    id = "mediaContainer",
    x = 0,
    y = 0,
    width = 400,
    height = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_START,
  })

  -- Media (image/avatar) section
  local mediaSection = Gui.new({
    id = "mediaSection",
    width = 80,
    height = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local avatar = Gui.new({
    id = "avatar",
    width = 60,
    height = 60,
    positioning = Positioning.FLEX,
  })

  local badge = Gui.new({
    id = "badge",
    width = 20,
    height = 20,
    positioning = Positioning.FLEX,
  })

  -- Content section with multiple alignment variations
  local contentSection = Gui.new({
    id = "contentSection",
    width = 280,
    height = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Header with user info (flex-end alignment)
  local userHeader = Gui.new({
    id = "userHeader",
    width = 280,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_END,
  })

  local username = Gui.new({
    id = "username",
    width = 120,
    height = 24,
    positioning = Positioning.FLEX,
  })

  local timestamp = Gui.new({
    id = "timestamp",
    width = 80,
    height = 16,
    positioning = Positioning.FLEX,
  })

  local menu = Gui.new({
    id = "menu",
    width = 30,
    height = 30,
    positioning = Positioning.FLEX,
  })

  -- Main content with center alignment
  local mainContent = Gui.new({
    id = "mainContent",
    width = 280,
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local text = Gui.new({
    id = "text",
    width = 260,
    height = 60,
    positioning = Positioning.FLEX,
  })

  local attachments = Gui.new({
    id = "attachments",
    width = 200,
    height = 15,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local attach1 = Gui.new({
    id = "attach1",
    width = 12,
    height = 12,
    positioning = Positioning.FLEX,
  })

  local attach2 = Gui.new({
    id = "attach2",
    width = 12,
    height = 8,
    positioning = Positioning.FLEX,
  })

  -- Footer actions with space-between
  local actionsFooter = Gui.new({
    id = "actionsFooter",
    width = 280,
    height = 30,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local reactions = Gui.new({
    id = "reactions",
    width = 100,
    height = 20,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local like = Gui.new({
    id = "like",
    width = 16,
    height = 16,
    positioning = Positioning.FLEX,
  })

  local share = Gui.new({
    id = "share",
    width = 16,
    height = 14,
    positioning = Positioning.FLEX,
  })

  local moreActions = Gui.new({
    id = "moreActions",
    width = 60,
    height = 24,
    positioning = Positioning.FLEX,
  })

  -- Build the tree
  mediaSection:addChild(avatar)
  mediaSection:addChild(badge)

  userHeader:addChild(username)
  userHeader:addChild(timestamp)
  userHeader:addChild(menu)

  attachments:addChild(attach1)
  attachments:addChild(attach2)
  mainContent:addChild(text)
  mainContent:addChild(attachments)

  reactions:addChild(like)
  reactions:addChild(share)
  actionsFooter:addChild(reactions)
  actionsFooter:addChild(moreActions)

  contentSection:addChild(userHeader)
  contentSection:addChild(mainContent)
  contentSection:addChild(actionsFooter)

  mediaContainer:addChild(mediaSection)
  mediaContainer:addChild(contentSection)

  -- Verify media section center alignment
  luaunit.assertEquals(avatar.x, 10) -- (80 - 60) / 2 = 10
  luaunit.assertEquals(badge.x, 30) -- (80 - 20) / 2 = 30

  -- Verify user header flex-end alignment
  luaunit.assertEquals(username.y, 16) -- (40 - 24) = 16 from bottom
  luaunit.assertEquals(timestamp.y, 24) -- (40 - 16) = 24 from bottom
  luaunit.assertEquals(menu.y, 10) -- (40 - 30) = 10 from bottom

  -- Verify main content center alignment
  luaunit.assertEquals(text.x, 90) -- 80 + (280 - 260) / 2 = 80 + 10 = 90
  luaunit.assertEquals(attachments.x, 120) -- 80 + (280 - 200) / 2 = 80 + 40 = 120

  -- Verify attachment items center alignment
  luaunit.assertEquals(attach1.y, 101.5) -- attachments.y (100) + (15 - 12) / 2 = 100 + 1.5 = 101.5
  luaunit.assertEquals(attach2.y, 103.5) -- attachments.y (100) + (15 - 8) / 2 = 100 + 3.5 = 103.5

  -- Verify actions footer center alignment
  luaunit.assertEquals(like.y, 127) -- actionsFooter.y (120) + reactions centered (5) + like centered (2) = 127
  luaunit.assertEquals(moreActions.y, 123) -- actionsFooter.y + (30 - 24) / 2 = 120 + 3 = 123
end

-- Test 18: Complex Toolbar with Varied Alignments
function TestAlignItems:testComplexToolbarVariedAlignments()
  -- Main toolbar container
  local toolbar = Gui.new({
    id = "toolbar",
    x = 0,
    y = 0,
    width = 600,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  -- Left section with logo and nav (flex-start alignment)
  local leftSection = Gui.new({
    id = "leftSection",
    width = 200,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_START,
  })

  local logo = Gui.new({
    id = "logo",
    width = 40,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local navigation = Gui.new({
    id = "navigation",
    width = 150,
    height = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local navItem1 = Gui.new({
    id = "navItem1",
    width = 60,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local navItem2 = Gui.new({
    id = "navItem2",
    width = 70,
    height = 35,
    positioning = Positioning.FLEX,
  })

  -- Center section with search (stretch alignment)
  local centerSection = Gui.new({
    id = "centerSection",
    width = 250,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  local searchContainer = Gui.new({
    id = "searchContainer",
    width = 250,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local searchInput = Gui.new({
    id = "searchInput",
    width = 200,
    height = 32,
    positioning = Positioning.FLEX,
  })

  local searchButton = Gui.new({
    id = "searchButton",
    width = 36,
    height = 36,
    positioning = Positioning.FLEX,
  })

  local searchHint = Gui.new({
    id = "searchHint",
    width = 250,
    height = 16,
    positioning = Positioning.FLEX,
  })

  -- Right section with user controls (flex-end alignment)
  local rightSection = Gui.new({
    id = "rightSection",
    width = 150,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_END,
  })

  local notifications = Gui.new({
    id = "notifications",
    width = 30,
    height = 35,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local notifIcon = Gui.new({
    id = "notifIcon",
    width = 20,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local notifBadge = Gui.new({
    id = "notifBadge",
    width = 12,
    height = 12,
    positioning = Positioning.FLEX,
  })

  local userMenu = Gui.new({
    id = "userMenu",
    width = 80,
    height = 45,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local userAvatar = Gui.new({
    id = "userAvatar",
    width = 32,
    height = 32,
    positioning = Positioning.FLEX,
  })

  local dropdown = Gui.new({
    id = "dropdown",
    width = 40,
    height = 25,
    positioning = Positioning.FLEX,
  })

  -- Build the tree
  navigation:addChild(navItem1)
  navigation:addChild(navItem2)
  leftSection:addChild(logo)
  leftSection:addChild(navigation)

  searchContainer:addChild(searchInput)
  searchContainer:addChild(searchButton)
  centerSection:addChild(searchContainer)
  centerSection:addChild(searchHint)

  notifications:addChild(notifIcon)
  notifications:addChild(notifBadge)
  userMenu:addChild(userAvatar)
  userMenu:addChild(dropdown)
  rightSection:addChild(notifications)
  rightSection:addChild(userMenu)

  toolbar:addChild(leftSection)
  toolbar:addChild(centerSection)
  toolbar:addChild(rightSection)

  -- Verify left section flex-start alignment
  luaunit.assertEquals(logo.y, 0) -- Aligned to top
  luaunit.assertEquals(navItem1.y, 10) -- navigation.y (0) + (50 - 30) / 2 = 0 + 10 = 10
  luaunit.assertEquals(navItem2.y, 7.5) -- navigation.y (0) + (50 - 35) / 2 = 0 + 7.5 = 7.5

  -- Verify center section stretch alignment
  luaunit.assertEquals(searchInput.y, 4) -- searchContainer.y + (40 - 32) / 2 = 10 + 4 = 14
  luaunit.assertEquals(searchButton.y, 2) -- searchContainer.y + (40 - 36) / 2 = 10 + 2 = 12
  luaunit.assertEquals(searchHint.width, 250) -- Should be stretched to full width

  -- Verify right section flex-end alignment
  luaunit.assertEquals(notifications.y, 25) -- (60 - 35) = 25 from bottom
  luaunit.assertEquals(userMenu.y, 15) -- (60 - 45) = 15 from bottom

  -- Verify notification items center alignment
  luaunit.assertEquals(notifIcon.x, 455) -- rightSection.x (450) + notifications.x (0) + center offset (5) = 455
  luaunit.assertEquals(notifBadge.x, 459) -- rightSection.x (450) + notifications.x (0) + center offset (9) = 459

  -- Verify user menu center alignment
  luaunit.assertEquals(userAvatar.y, 21.5) -- userMenu.y + (45 - 32) / 2 = 15 + 6.5 = 21.5
  luaunit.assertEquals(dropdown.y, 25) -- userMenu.y + (45 - 25) / 2 = 15 + 10 = 25
end

-- Test 19: Complex Dashboard Widget Layout
function TestAlignItems:testComplexDashboardWidgetLayout()
  -- Main dashboard container
  local dashboard = Gui.new({
    id = "dashboard",
    x = 0,
    y = 0,
    width = 800,
    height = 600,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Header with title and controls
  local header = Gui.new({
    id = "header",
    width = 800,
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local titleSection = Gui.new({
    id = "titleSection",
    width = 300,
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START,
  })

  local title = Gui.new({
    id = "title",
    width = 250,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local subtitle = Gui.new({
    id = "subtitle",
    width = 200,
    height = 24,
    positioning = Positioning.FLEX,
  })

  local controlsSection = Gui.new({
    id = "controlsSection",
    width = 200,
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_END,
  })

  local filterBtn = Gui.new({
    id = "filterBtn",
    width = 60,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local exportBtn = Gui.new({
    id = "exportBtn",
    width = 70,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local settingsBtn = Gui.new({
    id = "settingsBtn",
    width = 40,
    height = 40,
    positioning = Positioning.FLEX,
  })

  -- Main content area with widgets
  local mainContent = Gui.new({
    id = "mainContent",
    width = 800,
    height = 480,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Left panel with statistics (center alignment)
  local leftPanel = Gui.new({
    id = "leftPanel",
    width = 250,
    height = 480,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local statCard1 = Gui.new({
    id = "statCard1",
    width = 220,
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local stat1Value = Gui.new({
    id = "stat1Value",
    width = 100,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local stat1Label = Gui.new({
    id = "stat1Label",
    width = 150,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local stat1Chart = Gui.new({
    id = "stat1Chart",
    width = 180,
    height = 50,
    positioning = Positioning.FLEX,
  })

  local statCard2 = Gui.new({
    id = "statCard2",
    width = 220,
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_END,
  })

  local stat2Value = Gui.new({
    id = "stat2Value",
    width = 120,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local stat2Trend = Gui.new({
    id = "stat2Trend",
    width = 80,
    height = 20,
    positioning = Positioning.FLEX,
  })

  -- Center panel with main chart (stretch alignment)
  local centerPanel = Gui.new({
    id = "centerPanel",
    width = 400,
    height = 480,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  local chartHeader = Gui.new({
    id = "chartHeader",
    width = 400,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local chartTitle = Gui.new({
    id = "chartTitle",
    width = 200,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local chartControls = Gui.new({
    id = "chartControls",
    width = 120,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local timeRange = Gui.new({
    id = "timeRange",
    width = 80,
    height = 25,
    positioning = Positioning.FLEX,
  })

  local refreshBtn = Gui.new({
    id = "refreshBtn",
    width = 30,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local mainChart = Gui.new({
    id = "mainChart",
    width = 400,
    height = 380,
    positioning = Positioning.FLEX,
  })

  -- Right panel with lists (flex-start alignment)
  local rightPanel = Gui.new({
    id = "rightPanel",
    width = 150,
    height = 480,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START,
  })

  local alertsList = Gui.new({
    id = "alertsList",
    width = 140,
    height = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  local alert1 = Gui.new({
    id = "alert1",
    width = 140,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local alert2 = Gui.new({
    id = "alert2",
    width = 140,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local tasksList = Gui.new({
    id = "tasksList",
    width = 130,
    height = 240,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_END,
  })

  local task1 = Gui.new({
    id = "task1",
    width = 120,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local task2 = Gui.new({
    id = "task2",
    width = 110,
    height = 25,
    positioning = Positioning.FLEX,
  })

  -- Footer with status info
  local footer = Gui.new({
    id = "footer",
    width = 800,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local status = Gui.new({
    id = "status",
    width = 200,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local timestamp = Gui.new({
    id = "timestamp",
    width = 150,
    height = 16,
    positioning = Positioning.FLEX,
  })

  -- Build the tree
  titleSection:addChild(title)
  titleSection:addChild(subtitle)
  controlsSection:addChild(filterBtn)
  controlsSection:addChild(exportBtn)
  controlsSection:addChild(settingsBtn)
  header:addChild(titleSection)
  header:addChild(controlsSection)

  statCard1:addChild(stat1Value)
  statCard1:addChild(stat1Label)
  statCard1:addChild(stat1Chart)
  statCard2:addChild(stat2Value)
  statCard2:addChild(stat2Trend)
  leftPanel:addChild(statCard1)
  leftPanel:addChild(statCard2)

  chartControls:addChild(timeRange)
  chartControls:addChild(refreshBtn)
  chartHeader:addChild(chartTitle)
  chartHeader:addChild(chartControls)
  centerPanel:addChild(chartHeader)
  centerPanel:addChild(mainChart)

  alertsList:addChild(alert1)
  alertsList:addChild(alert2)
  tasksList:addChild(task1)
  tasksList:addChild(task2)
  rightPanel:addChild(alertsList)
  rightPanel:addChild(tasksList)

  mainContent:addChild(leftPanel)
  mainContent:addChild(centerPanel)
  mainContent:addChild(rightPanel)

  footer:addChild(status)
  footer:addChild(timestamp)

  dashboard:addChild(header)
  dashboard:addChild(mainContent)
  dashboard:addChild(footer)

  -- Verify title section flex-start alignment
  luaunit.assertEquals(title.x, 0) -- Aligned to left
  luaunit.assertEquals(subtitle.x, 0) -- Also aligned to left

  -- Verify controls section flex-end alignment
  luaunit.assertEquals(filterBtn.y, 45) -- (80 - 35) = 45 from bottom
  luaunit.assertEquals(exportBtn.y, 45) -- Same flex-end alignment
  luaunit.assertEquals(settingsBtn.y, 40) -- (80 - 40) = 40 from bottom

  -- Verify left panel center alignment
  luaunit.assertEquals(statCard1.x, 15) -- (250 - 220) / 2 = 15
  luaunit.assertEquals(statCard2.x, 15) -- Same center alignment

  -- Verify stat card alignments
  luaunit.assertEquals(stat1Value.x, 75) -- statCard1.x + (220 - 100) / 2 = 15 + 60 = 75
  luaunit.assertEquals(stat1Label.x, 50) -- statCard1.x + (220 - 150) / 2 = 15 + 35 = 50
  luaunit.assertEquals(stat2Value.x, 115) -- statCard2.x + (220 - 120) = 15 + 100 = 115
  luaunit.assertEquals(stat2Trend.x, 155) -- statCard2.x + (220 - 80) = 15 + 140 = 155

  -- Verify center panel stretch alignment
  luaunit.assertEquals(chartHeader.width, 400) -- Should be stretched
  luaunit.assertEquals(mainChart.width, 400) -- Should be stretched

  -- Verify right panel flex-start alignment
  luaunit.assertEquals(alertsList.x, 650) -- rightPanel starts at 650
  luaunit.assertEquals(tasksList.x, 650) -- Also aligned to start

  -- Verify tasks list flex-end alignment
  luaunit.assertEquals(task1.x, 660) -- tasksList.x + (130 - 120) = 650 + 10 = 660
  luaunit.assertEquals(task2.x, 670) -- tasksList.x + (130 - 110) = 650 + 20 = 670

  -- Verify footer center alignment
  luaunit.assertEquals(status.y, 570) -- footer.y (560) + (40 - 20) / 2 = 560 + 10 = 570
  luaunit.assertEquals(timestamp.y, 572) -- footer.y (560) + (40 - 16) / 2 = 560 + 12 = 572
end

-- Test 20: Complex Form Layout with Multi-Level Alignments
function TestAlignItems:testComplexFormMultiLevelAlignments()
  -- Main form container
  local form = Gui.new({
    id = "form",
    x = 50,
    y = 50,
    width = 500,
    height = 600,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Form header with center alignment
  local formHeader = Gui.new({
    id = "formHeader",
    width = 500,
    height = 80,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local formTitle = Gui.new({
    id = "formTitle",
    width = 300,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local formDescription = Gui.new({
    id = "formDescription",
    width = 400,
    height = 30,
    positioning = Positioning.FLEX,
  })

  -- Personal info section with flex-start alignment
  local personalSection = Gui.new({
    id = "personalSection",
    width = 500,
    height = 200,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START,
  })

  local sectionTitle1 = Gui.new({
    id = "sectionTitle1",
    width = 200,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local nameRow = Gui.new({
    id = "nameRow",
    width = 480,
    height = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local firstNameField = Gui.new({
    id = "firstNameField",
    width = 220,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START,
  })

  local firstNameLabel = Gui.new({
    id = "firstNameLabel",
    width = 100,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local firstNameInput = Gui.new({
    id = "firstNameInput",
    width = 200,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local lastNameField = Gui.new({
    id = "lastNameField",
    width = 220,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_END,
  })

  local lastNameLabel = Gui.new({
    id = "lastNameLabel",
    width = 120,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local lastNameInput = Gui.new({
    id = "lastNameInput",
    width = 200,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local emailRow = Gui.new({
    id = "emailRow",
    width = 480,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  local emailLabel = Gui.new({
    id = "emailLabel",
    width = 100,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local emailInput = Gui.new({
    id = "emailInput",
    width = 480,
    height = 35,
    positioning = Positioning.FLEX,
  })

  -- Preferences section with center alignment
  local preferencesSection = Gui.new({
    id = "preferencesSection",
    width = 500,
    height = 180,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local sectionTitle2 = Gui.new({
    id = "sectionTitle2",
    width = 250,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local optionsContainer = Gui.new({
    id = "optionsContainer",
    width = 400,
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_START,
  })

  local leftOptions = Gui.new({
    id = "leftOptions",
    width = 180,
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START,
  })

  local option1 = Gui.new({
    id = "option1",
    width = 150,
    height = 25,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local checkbox1 = Gui.new({
    id = "checkbox1",
    width = 20,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local label1 = Gui.new({
    id = "label1",
    width = 120,
    height = 18,
    positioning = Positioning.FLEX,
  })

  local option2 = Gui.new({
    id = "option2",
    width = 160,
    height = 25,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local checkbox2 = Gui.new({
    id = "checkbox2",
    width = 20,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local label2 = Gui.new({
    id = "label2",
    width = 130,
    height = 18,
    positioning = Positioning.FLEX,
  })

  local rightOptions = Gui.new({
    id = "rightOptions",
    width = 180,
    height = 120,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_END,
  })

  local dropdown = Gui.new({
    id = "dropdown",
    width = 150,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local slider = Gui.new({
    id = "slider",
    width = 140,
    height = 20,
    positioning = Positioning.FLEX,
  })

  -- Form actions with space-between alignment
  local actionsSection = Gui.new({
    id = "actionsSection",
    width = 500,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local cancelBtn = Gui.new({
    id = "cancelBtn",
    width = 80,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local submitGroup = Gui.new({
    id = "submitGroup",
    width = 200,
    height = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local saveBtn = Gui.new({
    id = "saveBtn",
    width = 80,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local submitBtn = Gui.new({
    id = "submitBtn",
    width = 100,
    height = 45,
    positioning = Positioning.FLEX,
  })

  -- Build the tree
  formHeader:addChild(formTitle)
  formHeader:addChild(formDescription)

  firstNameField:addChild(firstNameLabel)
  firstNameField:addChild(firstNameInput)
  lastNameField:addChild(lastNameLabel)
  lastNameField:addChild(lastNameInput)
  nameRow:addChild(firstNameField)
  nameRow:addChild(lastNameField)

  emailRow:addChild(emailLabel)
  emailRow:addChild(emailInput)

  personalSection:addChild(sectionTitle1)
  personalSection:addChild(nameRow)
  personalSection:addChild(emailRow)

  option1:addChild(checkbox1)
  option1:addChild(label1)
  option2:addChild(checkbox2)
  option2:addChild(label2)
  leftOptions:addChild(option1)
  leftOptions:addChild(option2)

  rightOptions:addChild(dropdown)
  rightOptions:addChild(slider)

  optionsContainer:addChild(leftOptions)
  optionsContainer:addChild(rightOptions)
  preferencesSection:addChild(sectionTitle2)
  preferencesSection:addChild(optionsContainer)

  submitGroup:addChild(saveBtn)
  submitGroup:addChild(submitBtn)
  actionsSection:addChild(cancelBtn)
  actionsSection:addChild(submitGroup)

  form:addChild(formHeader)
  form:addChild(personalSection)
  form:addChild(preferencesSection)
  form:addChild(actionsSection)

  -- Verify form header center alignment
  luaunit.assertEquals(formTitle.x, 150) -- 50 + (500 - 300) / 2 = 50 + 100 = 150
  luaunit.assertEquals(formDescription.x, 100) -- 50 + (500 - 400) / 2 = 50 + 50 = 100

  -- Verify personal section flex-start alignment
  luaunit.assertEquals(sectionTitle1.x, 50) -- Aligned to start
  luaunit.assertEquals(nameRow.x, 50) -- Same as personalSection.x (no margin)

  -- Verify name field alignments
  luaunit.assertEquals(firstNameLabel.x, 50) -- firstNameField starts at nameRow.x (50)
  luaunit.assertEquals(lastNameLabel.x, 370) -- lastNameField.x (270) + (220 - 120) = 270 + 100 = 370 (flex-end within field)
  luaunit.assertEquals(lastNameInput.x, 290) -- lastNameField.x (270) + (220 - 200) = 270 + 20 = 290

  -- Verify preferences section center alignment
  luaunit.assertEquals(sectionTitle2.x, 175) -- 50 + (500 - 250) / 2 = 50 + 125 = 175
  luaunit.assertEquals(optionsContainer.x, 100) -- 50 + (500 - 400) / 2 = 50 + 50 = 100

  -- Verify option alignments
  luaunit.assertEquals(checkbox1.y, 362.5) -- option1.y (360) + (25 - 20) / 2 = 360 + 2.5 = 362.5
  luaunit.assertEquals(label1.y, 363.5) -- option1.y (360) + (25 - 18) / 2 = 360 + 3.5 = 363.5

  -- Verify right options flex-end alignment
  luaunit.assertEquals(dropdown.x, 310) -- rightOptions.x + (180 - 150) = 280 + 30 = 310
  luaunit.assertEquals(slider.x, 320) -- rightOptions.x + (180 - 140) = 280 + 40 = 320

  -- Verify actions section alignments
  luaunit.assertEquals(cancelBtn.y, 520) -- actionsSection.y (510) + (60 - 40) / 2 = 510 + 10 = 520
  luaunit.assertEquals(saveBtn.y, 520) -- submitGroup.y (515) + (50 - 40) / 2 = 515 + 5 = 520
  luaunit.assertEquals(submitBtn.y, 517.5) -- submitGroup.y (515) + (50 - 45) / 2 = 515 + 2.5 = 517.5
end

-- Test 21: Complex Modal Dialog with Nested Alignments
function TestAlignItems:testComplexModalDialogNestedAlignments()
  -- Modal backdrop
  local backdrop = Gui.new({
    id = "backdrop",
    x = 0,
    y = 0,
    width = 1024,
    height = 768,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.CENTER,
  })

  -- Modal dialog
  local modal = Gui.new({
    id = "modal",
    width = 600,
    height = 500,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Modal header with space-between alignment
  local modalHeader = Gui.new({
    id = "modalHeader",
    width = 600,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local headerLeft = Gui.new({
    id = "headerLeft",
    width = 300,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local modalIcon = Gui.new({
    id = "modalIcon",
    width = 32,
    height = 32,
    positioning = Positioning.FLEX,
  })

  local modalTitle = Gui.new({
    id = "modalTitle",
    width = 250,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local headerRight = Gui.new({
    id = "headerRight",
    width = 100,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.FLEX_END,
  })

  local helpBtn = Gui.new({
    id = "helpBtn",
    width = 30,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local closeBtn = Gui.new({
    id = "closeBtn",
    width = 32,
    height = 32,
    positioning = Positioning.FLEX,
  })

  -- Modal content with mixed alignments
  local modalContent = Gui.new({
    id = "modalContent",
    width = 600,
    height = 380,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.STRETCH,
  })

  -- Left sidebar with navigation
  local sidebar = Gui.new({
    id = "sidebar",
    width = 150,
    height = 380,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
  })

  local navItem1 = Gui.new({
    id = "navItem1",
    width = 150,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local navIcon1 = Gui.new({
    id = "navIcon1",
    width = 20,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local navLabel1 = Gui.new({
    id = "navLabel1",
    width = 100,
    height = 18,
    positioning = Positioning.FLEX,
  })

  local navItem2 = Gui.new({
    id = "navItem2",
    width = 150,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local navIcon2 = Gui.new({
    id = "navIcon2",
    width = 20,
    height = 20,
    positioning = Positioning.FLEX,
  })

  local navLabel2 = Gui.new({
    id = "navLabel2",
    width = 110,
    height = 18,
    positioning = Positioning.FLEX,
  })

  -- Main content area
  local contentArea = Gui.new({
    id = "contentArea",
    width = 450,
    height = 380,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START,
  })

  -- Content header with flex-end alignment
  local contentHeader = Gui.new({
    id = "contentHeader",
    width = 450,
    height = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.FLEX_END,
  })

  local contentTitle = Gui.new({
    id = "contentTitle",
    width = 200,
    height = 35,
    positioning = Positioning.FLEX,
  })

  local contentActions = Gui.new({
    id = "contentActions",
    width = 180,
    height = 40,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  local editBtn = Gui.new({
    id = "editBtn",
    width = 50,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local deleteBtn = Gui.new({
    id = "deleteBtn",
    width = 55,
    height = 30,
    positioning = Positioning.FLEX,
  })

  local moreBtn = Gui.new({
    id = "moreBtn",
    width = 30,
    height = 30,
    positioning = Positioning.FLEX,
  })

  -- Content body with center alignment
  local contentBody = Gui.new({
    id = "contentBody",
    width = 450,
    height = 280,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
  })

  local contentText = Gui.new({
    id = "contentText",
    width = 400,
    height = 150,
    positioning = Positioning.FLEX,
  })

  local contentImage = Gui.new({
    id = "contentImage",
    width = 200,
    height = 100,
    positioning = Positioning.FLEX,
  })

  -- Content meta with flex-end alignment
  local contentMeta = Gui.new({
    id = "contentMeta",
    width = 350,
    height = 30,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.FLEX_END,
  })

  local lastModified = Gui.new({
    id = "lastModified",
    width = 120,
    height = 16,
    positioning = Positioning.FLEX,
  })

  local author = Gui.new({
    id = "author",
    width = 100,
    height = 18,
    positioning = Positioning.FLEX,
  })

  -- Modal footer with center alignment
  local modalFooter = Gui.new({
    id = "modalFooter",
    width = 600,
    height = 60,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.CENTER,
  })

  local footerActions = Gui.new({
    id = "footerActions",
    width = 300,
    height = 50,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
    justifyContent = JustifyContent.SPACE_AROUND,
  })

  local cancelModalBtn = Gui.new({
    id = "cancelModalBtn",
    width = 80,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local applyBtn = Gui.new({
    id = "applyBtn",
    width = 70,
    height = 40,
    positioning = Positioning.FLEX,
  })

  local okBtn = Gui.new({
    id = "okBtn",
    width = 60,
    height = 45,
    positioning = Positioning.FLEX,
  })

  -- Build the tree
  headerLeft:addChild(modalIcon)
  headerLeft:addChild(modalTitle)
  headerRight:addChild(helpBtn)
  headerRight:addChild(closeBtn)
  modalHeader:addChild(headerLeft)
  modalHeader:addChild(headerRight)

  navItem1:addChild(navIcon1)
  navItem1:addChild(navLabel1)
  navItem2:addChild(navIcon2)
  navItem2:addChild(navLabel2)
  sidebar:addChild(navItem1)
  sidebar:addChild(navItem2)

  contentActions:addChild(editBtn)
  contentActions:addChild(deleteBtn)
  contentActions:addChild(moreBtn)
  contentHeader:addChild(contentTitle)
  contentHeader:addChild(contentActions)

  contentBody:addChild(contentText)
  contentBody:addChild(contentImage)

  contentMeta:addChild(lastModified)
  contentMeta:addChild(author)

  contentArea:addChild(contentHeader)
  contentArea:addChild(contentBody)
  contentArea:addChild(contentMeta)

  modalContent:addChild(sidebar)
  modalContent:addChild(contentArea)

  footerActions:addChild(cancelModalBtn)
  footerActions:addChild(applyBtn)
  footerActions:addChild(okBtn)
  modalFooter:addChild(footerActions)

  modal:addChild(modalHeader)
  modal:addChild(modalContent)
  modal:addChild(modalFooter)

  backdrop:addChild(modal)

  -- Verify modal is centered in backdrop
  luaunit.assertEquals(modal.x, 212) -- (1024 - 600) / 2 = 212
  luaunit.assertEquals(modal.y, 134) -- (768 - 500) / 2 = 134

  -- Verify header alignment
  luaunit.assertEquals(modalIcon.y, 148) -- modal.y + (60 - 32) / 2 = 134 + 14 = 148
  luaunit.assertEquals(modalTitle.y, 149) -- modal.y + (60 - 30) / 2 = 134 + 15 = 149
  luaunit.assertEquals(helpBtn.y, 149) -- header center alignment
  luaunit.assertEquals(closeBtn.y, 148) -- header center alignment

  -- Verify nav item alignments
  luaunit.assertEquals(navIcon1.y, 204) -- navItem1.y + (40 - 20) / 2 = 194 + 10 = 204
  luaunit.assertEquals(navLabel1.y, 205) -- navItem1.y + (40 - 18) / 2 = 194 + 11 = 205

  -- Verify content header flex-end alignment
  luaunit.assertEquals(contentTitle.y, 209) -- contentHeader.y + (50 - 35) = 194 + 15 = 209
  luaunit.assertEquals(editBtn.y, 209) -- contentActions center: contentHeader.y + (50 - 40)/2 + (40 - 30)/2 = 194 + 5 + 10 = 209

  -- Verify content body center alignment
  luaunit.assertEquals(contentText.x, 387) -- contentArea.x (362) + (450 - 400) / 2 = 362 + 25 = 387
  luaunit.assertEquals(contentImage.x, 487) -- contentArea.x (362) + (450 - 200) / 2 = 362 + 125 = 487

  -- Verify content meta flex-end alignment
  luaunit.assertEquals(lastModified.x, 492) -- contentArea.x (362) + (350 - 220) = 362 + 130 = 492
  luaunit.assertEquals(author.x, 612) -- lastModified.x (492) + lastModified.width (120) = 612

  -- Verify footer center alignment
  luaunit.assertEquals(footerActions.x, 362) -- modal.x + (600 - 300) / 2 = 212 + 150 = 362
  luaunit.assertEquals(cancelModalBtn.y, 584) -- modalFooter.y (574) + (60-50)/2 + (50-40)/2 = 574 + 5 + 5 = 584
  luaunit.assertEquals(okBtn.y, 581.5) -- footerActions.y (579) + (50 - 45) / 2 = 579 + 2.5 = 581.5
end

luaunit.LuaUnit.run()
