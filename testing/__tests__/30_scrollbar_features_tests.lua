package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")
require("testing.loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums, Color = FlexLove.GUI, FlexLove.enums, FlexLove.Color

local Positioning = enums.Positioning

-- Create test cases for scrollbar features
TestScrollbarFeatures = {}

function TestScrollbarFeatures:setUp()
  -- Clean up before each test
  Gui.destroy()
end

function TestScrollbarFeatures:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- ========================================
-- Test 1: hideScrollbars with boolean value
-- ========================================
function TestScrollbarFeatures:testHideScrollbarsBooleanTrue()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    hideScrollbars = true,
  })

  -- Verify hideScrollbars is properly initialized
  luaunit.assertNotNil(container.hideScrollbars)
  luaunit.assertEquals(type(container.hideScrollbars), "table")
  luaunit.assertEquals(container.hideScrollbars.vertical, true)
  luaunit.assertEquals(container.hideScrollbars.horizontal, true)
end

function TestScrollbarFeatures:testHideScrollbarsBooleanFalse()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    hideScrollbars = false,
  })

  -- Verify hideScrollbars defaults to showing scrollbars
  luaunit.assertNotNil(container.hideScrollbars)
  luaunit.assertEquals(container.hideScrollbars.vertical, false)
  luaunit.assertEquals(container.hideScrollbars.horizontal, false)
end

-- ========================================
-- Test 2: hideScrollbars with table configuration
-- ========================================
function TestScrollbarFeatures:testHideScrollbarsTableVerticalOnly()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    hideScrollbars = { vertical = true, horizontal = false },
  })

  -- Verify only vertical scrollbar is hidden
  luaunit.assertEquals(container.hideScrollbars.vertical, true)
  luaunit.assertEquals(container.hideScrollbars.horizontal, false)
end

function TestScrollbarFeatures:testHideScrollbarsTableHorizontalOnly()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    hideScrollbars = { vertical = false, horizontal = true },
  })

  -- Verify only horizontal scrollbar is hidden
  luaunit.assertEquals(container.hideScrollbars.vertical, false)
  luaunit.assertEquals(container.hideScrollbars.horizontal, true)
end

function TestScrollbarFeatures:testHideScrollbarsTableBothHidden()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    hideScrollbars = { vertical = false, horizontal = false },
  })

  -- Verify both scrollbars are shown
  luaunit.assertEquals(container.hideScrollbars.vertical, false)
  luaunit.assertEquals(container.hideScrollbars.horizontal, false)
end

-- ========================================
-- Test 3: Default hideScrollbars behavior
-- ========================================
function TestScrollbarFeatures:testHideScrollbarsDefault()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
  })

  -- Verify default is to show scrollbars (backward compatibility)
  luaunit.assertNotNil(container.hideScrollbars)
  luaunit.assertEquals(container.hideScrollbars.vertical, false)
  luaunit.assertEquals(container.hideScrollbars.horizontal, false)
end

-- ========================================
-- Test 4: Independent hover states initialization
-- ========================================
function TestScrollbarFeatures:testIndependentHoverStatesInitialization()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
  })

  -- Verify independent hover states are initialized
  luaunit.assertNotNil(container._scrollbarHoveredVertical)
  luaunit.assertNotNil(container._scrollbarHoveredHorizontal)
  luaunit.assertEquals(container._scrollbarHoveredVertical, false)
  luaunit.assertEquals(container._scrollbarHoveredHorizontal, false)
end

-- ========================================
-- Test 5: Scrollbar dimensions calculation
-- ========================================
function TestScrollbarFeatures:testScrollbarDimensionsCalculation()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Calculate scrollbar dimensions
  local dims = container:_calculateScrollbarDimensions()

  -- Verify dimensions structure
  luaunit.assertNotNil(dims.vertical)
  luaunit.assertNotNil(dims.horizontal)
  luaunit.assertNotNil(dims.vertical.visible)
  luaunit.assertNotNil(dims.horizontal.visible)
end

-- ========================================
-- Test 6: Scroll position management
-- ========================================
function TestScrollbarFeatures:testScrollPositionSetAndGet()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow to set max scroll
  container:_detectOverflow()

  -- Set scroll position
  container:setScrollPosition(50, 100)

  -- Get scroll position
  local scrollX, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollX, 50)
  luaunit.assertEquals(scrollY, 100)
end

function TestScrollbarFeatures:testScrollPositionClamping()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow to set max scroll
  container:_detectOverflow()

  -- Try to set scroll position beyond max
  container:setScrollPosition(1000, 1000)

  -- Get scroll position - should be clamped to max
  local scrollX, scrollY = container:getScrollPosition()
  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertEquals(scrollX, maxScrollX)
  luaunit.assertEquals(scrollY, maxScrollY)
end

-- ========================================
-- Test 7: Scroll by delta
-- ========================================
function TestScrollbarFeatures:testScrollByDelta()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Initial scroll position
  container:setScrollPosition(50, 50)

  -- Scroll by delta
  container:scrollBy(10, 20)

  -- Verify new position
  local scrollX, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollX, 60)
  luaunit.assertEquals(scrollY, 70)
end

-- ========================================
-- Test 8: Scroll to top/bottom/left/right
-- ========================================
function TestScrollbarFeatures:testScrollToTop()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Set initial scroll position
  container:setScrollPosition(50, 50)

  -- Scroll to top
  container:scrollToTop()

  -- Verify position
  local scrollX, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollY, 0)
end

function TestScrollbarFeatures:testScrollToBottom()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Scroll to bottom
  container:scrollToBottom()

  -- Verify position
  local scrollX, scrollY = container:getScrollPosition()
  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertEquals(scrollY, maxScrollY)
end

function TestScrollbarFeatures:testScrollToLeft()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Set initial scroll position
  container:setScrollPosition(50, 50)

  -- Scroll to left
  container:scrollToLeft()

  -- Verify position
  local scrollX, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollX, 0)
end

function TestScrollbarFeatures:testScrollToRight()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Scroll to right
  container:scrollToRight()

  -- Verify position
  local scrollX, scrollY = container:getScrollPosition()
  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertEquals(scrollX, maxScrollX)
end

-- ========================================
-- Test 9: Get scroll percentage
-- ========================================
function TestScrollbarFeatures:testGetScrollPercentage()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Scroll to middle
  local maxScrollX, maxScrollY = container:getMaxScroll()
  container:setScrollPosition(maxScrollX / 2, maxScrollY / 2)

  -- Get scroll percentage
  local percentX, percentY = container:getScrollPercentage()
  luaunit.assertAlmostEquals(percentX, 0.5, 0.01)
  luaunit.assertAlmostEquals(percentY, 0.5, 0.01)
end

-- ========================================
-- Test 10: Has overflow detection
-- ========================================
function TestScrollbarFeatures:testHasOverflow()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows vertically
  local child = Gui.new({
    parent = container,
    width = 150,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Check overflow
  local hasOverflowX, hasOverflowY = container:hasOverflow()
  luaunit.assertEquals(hasOverflowX, false)
  luaunit.assertEquals(hasOverflowY, true)
end

-- ========================================
-- Test 11: Get content size
-- ========================================
function TestScrollbarFeatures:testGetContentSize()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child with specific size
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 400,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Get content size
  local contentWidth, contentHeight = container:getContentSize()
  luaunit.assertEquals(contentWidth, 300)
  luaunit.assertEquals(contentHeight, 400)
end

-- ========================================
-- Test 12: Scrollbar configuration options
-- ========================================
function TestScrollbarFeatures:testScrollbarConfigurationOptions()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    scrollbarWidth = 20,
    scrollbarRadius = 10,
    scrollbarPadding = 5,
    scrollSpeed = 30,
    scrollbarColor = Color.new(1, 0, 0, 1),
    scrollbarTrackColor = Color.new(0, 1, 0, 1),
  })

  -- Verify custom configuration
  luaunit.assertEquals(container.scrollbarWidth, 20)
  luaunit.assertEquals(container.scrollbarRadius, 10)
  luaunit.assertEquals(container.scrollbarPadding, 5)
  luaunit.assertEquals(container.scrollSpeed, 30)
  luaunit.assertEquals(container.scrollbarColor.r, 1)
  luaunit.assertEquals(container.scrollbarTrackColor.g, 1)
end

-- ========================================
-- Test 13: Wheel scroll handling
-- ========================================
function TestScrollbarFeatures:testWheelScrollHandling()
  local container = Gui.new({
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = Positioning.FLEX,
  })

  -- Add child that overflows
  local child = Gui.new({
    parent = container,
    width = 300,
    height = 300,
  })

  -- Detect overflow
  container:_detectOverflow()

  -- Set initial position away from top so we can scroll up
  container:setScrollPosition(nil, 50)
  local initialScrollX, initialScrollY = container:getScrollPosition()

  -- Handle wheel scroll (vertical) - positive y means scroll up
  local handled = container:_handleWheelScroll(0, 1)

  -- Verify scroll was handled and position changed (scrolled up means lower scroll value)
  luaunit.assertEquals(handled, true)
  local scrollX, scrollY = container:getScrollPosition()
  luaunit.assertTrue(scrollY < initialScrollY, "Expected scroll position to decrease when scrolling up")
end

-- Run the tests
os.exit(luaunit.LuaUnit.run())
