package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local ScrollManager = require("modules.ScrollManager")
local Color = require("modules.Color")
local utils = require("modules.utils")

-- Initialize ScrollManager with ErrorHandler
ScrollManager.init({ ErrorHandler = ErrorHandler })

TestScrollManagerEdgeCases = {}

-- Helper to create ScrollManager with dependencies
local function createScrollManager(config)
  config = config or {}
  return ScrollManager.new(config, {
    Color = Color,
    utils = utils,
  })
end

-- Helper to create mock element with children
local function createMockElement(width, height, children)
  children = children or {}
  return {
    x = 0,
    y = 0,
    width = width or 200,
    height = height or 300,
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
    children = children,
    getBorderBoxWidth = function(self)
      return self.width
    end,
    getBorderBoxHeight = function(self)
      return self.height
    end,
  }
end

-- Helper to create mock child element
local function createMockChild(x, y, width, height)
  return {
    x = x or 0,
    y = y or 0,
    width = width or 50,
    height = height or 50,
    margin = { top = 0, right = 0, bottom = 0, left = 0 },
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function(self)
      return self.width
    end,
    getBorderBoxHeight = function(self)
      return self.height
    end,
  }
end

function TestScrollManagerEdgeCases:setUp()
  -- Reset any state
end

function TestScrollManagerEdgeCases:tearDown()
  -- Clean up
end

-- ============================================================================
-- Constructor Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testConstructorWithNilConfig()
  local sm = createScrollManager(nil)
  luaunit.assertNotNil(sm)
  luaunit.assertEquals(sm.overflow, "hidden") -- Default value
end

function TestScrollManagerEdgeCases:testConstructorWithEmptyConfig()
  local sm = createScrollManager({})
  luaunit.assertNotNil(sm)
  luaunit.assertEquals(sm.overflow, "hidden")
  luaunit.assertEquals(sm.scrollbarWidth, 12)
end

function TestScrollManagerEdgeCases:testConstructorWithInvalidOverflowValue()
  local sm = createScrollManager({ overflow = "invalid" })
  luaunit.assertNotNil(sm)
  luaunit.assertEquals(sm.overflow, "invalid") -- No validation, stores as-is
end

function TestScrollManagerEdgeCases:testConstructorWithZeroScrollbarWidth()
  local sm = createScrollManager({ scrollbarWidth = 0 })
  luaunit.assertEquals(sm.scrollbarWidth, 0)
end

function TestScrollManagerEdgeCases:testConstructorWithNegativeScrollbarWidth()
  local sm = createScrollManager({ scrollbarWidth = -10 })
  luaunit.assertEquals(sm.scrollbarWidth, -10) -- No validation
end

function TestScrollManagerEdgeCases:testConstructorWithNegativeScrollSpeed()
  local sm = createScrollManager({ scrollSpeed = -50 })
  luaunit.assertEquals(sm.scrollSpeed, -50) -- No validation
end

function TestScrollManagerEdgeCases:testConstructorWithZeroScrollSpeed()
  local sm = createScrollManager({ scrollSpeed = 0 })
  luaunit.assertEquals(sm.scrollSpeed, 0)
end

function TestScrollManagerEdgeCases:testConstructorWithInvalidFriction()
  local sm = createScrollManager({ scrollFriction = 1.5 }) -- > 1 would increase velocity
  luaunit.assertEquals(sm.scrollFriction, 1.5)
end

function TestScrollManagerEdgeCases:testConstructorWithNegativeFriction()
  local sm = createScrollManager({ scrollFriction = -0.5 })
  luaunit.assertEquals(sm.scrollFriction, -0.5)
end

function TestScrollManagerEdgeCases:testConstructorWithZeroBounceStiffness()
  local sm = createScrollManager({ bounceStiffness = 0 })
  luaunit.assertEquals(sm.bounceStiffness, 0)
end

function TestScrollManagerEdgeCases:testConstructorWithNegativeBounceStiffness()
  local sm = createScrollManager({ bounceStiffness = -0.5 })
  luaunit.assertEquals(sm.bounceStiffness, -0.5)
end

function TestScrollManagerEdgeCases:testConstructorWithNegativeMaxOverscroll()
  local sm = createScrollManager({ maxOverscroll = -100 })
  luaunit.assertEquals(sm.maxOverscroll, -100)
end

function TestScrollManagerEdgeCases:testConstructorWithRestoredScrollState()
  local sm = createScrollManager({ _scrollX = 50, _scrollY = 100 })
  luaunit.assertEquals(sm._scrollX, 50)
  luaunit.assertEquals(sm._scrollY, 100)
end

function TestScrollManagerEdgeCases:testConstructorWithHideScrollbarsBooleanTrue()
  local sm = createScrollManager({ hideScrollbars = true })
  luaunit.assertTrue(sm.hideScrollbars.vertical)
  luaunit.assertTrue(sm.hideScrollbars.horizontal)
end

function TestScrollManagerEdgeCases:testConstructorWithHideScrollbarsBooleanFalse()
  local sm = createScrollManager({ hideScrollbars = false })
  luaunit.assertFalse(sm.hideScrollbars.vertical)
  luaunit.assertFalse(sm.hideScrollbars.horizontal)
end

function TestScrollManagerEdgeCases:testConstructorWithHideScrollbarsTable()
  local sm = createScrollManager({ hideScrollbars = { vertical = true, horizontal = false } })
  luaunit.assertTrue(sm.hideScrollbars.vertical)
  luaunit.assertFalse(sm.hideScrollbars.horizontal)
end

-- ============================================================================
-- Method Calls Before Initialization
-- ============================================================================

function TestScrollManagerEdgeCases:testDetectOverflowWithoutElement()
  local sm = createScrollManager({})
  -- Should crash when element is nil (no longer has error handling)
  local success = pcall(function()
    sm:detectOverflow(nil)
  end)
  luaunit.assertFalse(success)
end

function TestScrollManagerEdgeCases:testCalculateScrollbarDimensionsWithoutElement()
  local sm = createScrollManager({})
  -- Should return empty result when element is nil (overflow defaults to "hidden")
  local dims = sm:calculateScrollbarDimensions(nil)
  luaunit.assertNotNil(dims)
  luaunit.assertFalse(dims.vertical.visible)
  luaunit.assertFalse(dims.horizontal.visible)
end

function TestScrollManagerEdgeCases:testGetScrollbarAtPositionWithoutElement()
  local sm = createScrollManager({})
  local result = sm:getScrollbarAtPosition(nil, 50, 50)
  luaunit.assertNil(result)
end

function TestScrollManagerEdgeCases:testHandleMousePressWithoutElement()
  local sm = createScrollManager({})
  local consumed = sm:handleMousePress(nil, 50, 50, 1)
  luaunit.assertFalse(consumed)
end

-- ============================================================================
-- detectOverflow Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testDetectOverflowWithNoChildren()
  local sm = createScrollManager({ overflow = "auto" })
  local element = createMockElement(200, 300, {})
  sm:detectOverflow(element)

  local hasOverflowX, hasOverflowY = sm:hasOverflow()
  luaunit.assertFalse(hasOverflowX)
  luaunit.assertFalse(hasOverflowY)
end

function TestScrollManagerEdgeCases:testDetectOverflowWithZeroDimensions()
  local sm = createScrollManager({ overflow = "auto" })
  local element = createMockElement(0, 0, {})
  sm:detectOverflow(element)

  local contentW, contentH = sm:getContentSize()
  luaunit.assertEquals(contentW, 0)
  luaunit.assertEquals(contentH, 0)
end

function TestScrollManagerEdgeCases:testDetectOverflowWithVisibleOverflow()
  local sm = createScrollManager({ overflow = "visible" })
  local child = createMockChild(0, 0, 500, 500)
  local element = createMockElement(200, 300, { child })
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  -- Should skip detection for visible overflow
  local hasOverflowX, hasOverflowY = sm:hasOverflow()
  luaunit.assertFalse(hasOverflowX)
  luaunit.assertFalse(hasOverflowY)
end

function TestScrollManagerEdgeCases:testDetectOverflowWithAbsolutelyPositionedChildren()
  local sm = createScrollManager({ overflow = "auto" })
  local child = createMockChild(0, 0, 500, 500)
  child._explicitlyAbsolute = true -- Should be ignored in overflow calc
  local element = createMockElement(200, 300, { child })
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local hasOverflowX, hasOverflowY = sm:hasOverflow()
  luaunit.assertFalse(hasOverflowX) -- Absolute children don't contribute
  luaunit.assertFalse(hasOverflowY)
end

function TestScrollManagerEdgeCases:testDetectOverflowWithNegativeChildMargins()
  local sm = createScrollManager({ overflow = "auto" })
  local child = createMockChild(10, 10, 100, 100)
  child.margin = { top = -50, right = -50, bottom = -50, left = -50 }
  local element = createMockElement(200, 300, { child })
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  -- Negative margins shouldn't cause negative overflow detection
  local contentW, contentH = sm:getContentSize()
  luaunit.assertTrue(contentW >= 0)
  luaunit.assertTrue(contentH >= 0)
end

function TestScrollManagerEdgeCases:testDetectOverflowClampsExistingScroll()
  local sm = createScrollManager({ overflow = "auto", _scrollX = 1000, _scrollY = 1000 })
  local child = createMockChild(10, 10, 100, 100)
  local element = createMockElement(200, 300, { child })
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  -- Scroll should be clamped to max bounds
  local scrollX, scrollY = sm:getScroll()
  local maxScrollX, maxScrollY = sm:getMaxScroll()
  luaunit.assertTrue(scrollX <= maxScrollX)
  luaunit.assertTrue(scrollY <= maxScrollY)
end

-- ============================================================================
-- Scroll Position Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testSetScrollNegativeValues()
  local sm = createScrollManager({ overflow = "auto" })
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm:setScroll(-50, -50)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 0) -- Should clamp to 0
  luaunit.assertEquals(scrollY, 0)
end

function TestScrollManagerEdgeCases:testSetScrollBeyondMax()
  local sm = createScrollManager({ overflow = "auto" })
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm:setScroll(500, 500)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 100) -- Should clamp to max
  luaunit.assertEquals(scrollY, 100)
end

function TestScrollManagerEdgeCases:testSetScrollWithNilValues()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm:setScroll(nil, nil)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 50) -- Should keep current
  luaunit.assertEquals(scrollY, 50)
end

function TestScrollManagerEdgeCases:testSetScrollPartialUpdate()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm:setScroll(75, nil)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 75)
  luaunit.assertEquals(scrollY, 50) -- Unchanged
end

function TestScrollManagerEdgeCases:testScrollByNegativeValues()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm:scrollBy(-100, -100)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 0) -- Should clamp to 0
  luaunit.assertEquals(scrollY, 0)
end

function TestScrollManagerEdgeCases:testScrollByBeyondMax()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm:scrollBy(100, 100)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 100) -- Should clamp to max
  luaunit.assertEquals(scrollY, 100)
end

function TestScrollManagerEdgeCases:testScrollByWithNilValues()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm:scrollBy(nil, nil)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 50) -- Unchanged
  luaunit.assertEquals(scrollY, 50)
end

function TestScrollManagerEdgeCases:testGetScrollPercentageWithZeroMax()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 0
  sm._scrollY = 0
  sm._maxScrollX = 0
  sm._maxScrollY = 0

  local percentX, percentY = sm:getScrollPercentage()
  luaunit.assertEquals(percentX, 0)
  luaunit.assertEquals(percentY, 0)
end

function TestScrollManagerEdgeCases:testGetScrollPercentageAtMax()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 100
  sm._scrollY = 100
  sm._maxScrollX = 100
  sm._maxScrollY = 100

  local percentX, percentY = sm:getScrollPercentage()
  luaunit.assertEquals(percentX, 1)
  luaunit.assertEquals(percentY, 1)
end

-- ============================================================================
-- calculateScrollbarDimensions Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testCalculateScrollbarDimensionsWithZeroTrackSize()
  local sm = createScrollManager({ overflow = "scroll", scrollbarPadding = 150 }) -- Padding bigger than element
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local dims = sm:calculateScrollbarDimensions(element)
  -- Should handle zero or negative track sizes
  luaunit.assertNotNil(dims.vertical)
  luaunit.assertNotNil(dims.horizontal)
end

function TestScrollManagerEdgeCases:testCalculateScrollbarDimensionsWithScrollMode()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {}) -- No overflow
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local dims = sm:calculateScrollbarDimensions(element)
  -- Scrollbars should be visible in "scroll" mode even without overflow
  luaunit.assertTrue(dims.vertical.visible)
  luaunit.assertTrue(dims.horizontal.visible)
end

function TestScrollManagerEdgeCases:testCalculateScrollbarDimensionsWithAutoModeNoOverflow()
  local sm = createScrollManager({ overflow = "auto" })
  local element = createMockElement(200, 300, {}) -- No overflow
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local dims = sm:calculateScrollbarDimensions(element)
  -- Scrollbars should NOT be visible in "auto" mode without overflow
  luaunit.assertFalse(dims.vertical.visible)
  luaunit.assertFalse(dims.horizontal.visible)
end

function TestScrollManagerEdgeCases:testCalculateScrollbarDimensionsWithAxisSpecificOverflow()
  local sm = createScrollManager({ overflowX = "scroll", overflowY = "hidden" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local dims = sm:calculateScrollbarDimensions(element)
  luaunit.assertTrue(dims.horizontal.visible) -- X is scroll
  luaunit.assertFalse(dims.vertical.visible) -- Y is hidden
end

function TestScrollManagerEdgeCases:testCalculateScrollbarDimensionsWithMinThumbSize()
  local sm = createScrollManager({ overflow = "scroll" })
  local child = createMockChild(10, 10, 100, 10000) -- Very tall child
  local element = createMockElement(200, 300, { child })
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local dims = sm:calculateScrollbarDimensions(element)
  -- Thumb should have minimum size of 20px
  luaunit.assertTrue(dims.vertical.thumbHeight >= 20)
end

-- ============================================================================
-- Mouse Interaction Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testGetScrollbarAtPositionOutsideBounds()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local result = sm:getScrollbarAtPosition(element, -100, -100)
  luaunit.assertNil(result)
end

function TestScrollManagerEdgeCases:testGetScrollbarAtPositionWithHiddenScrollbars()
  local sm = createScrollManager({ overflow = "scroll", hideScrollbars = true })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  -- Even though scrollbar exists, it's hidden so shouldn't be detected
  local dims = sm:calculateScrollbarDimensions(element)
  local result = sm:getScrollbarAtPosition(element, 190, 50)
  luaunit.assertNil(result)
end

function TestScrollManagerEdgeCases:testHandleMousePressWithRightButton()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local consumed = sm:handleMousePress(element, 50, 50, 2) -- Right button
  luaunit.assertFalse(consumed)
end

function TestScrollManagerEdgeCases:testHandleMousePressWithMiddleButton()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local consumed = sm:handleMousePress(element, 50, 50, 3) -- Middle button
  luaunit.assertFalse(consumed)
end

function TestScrollManagerEdgeCases:testHandleMouseMoveWithoutDragging()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local consumed = sm:handleMouseMove(element, 50, 50)
  luaunit.assertFalse(consumed)
end

function TestScrollManagerEdgeCases:testHandleMouseReleaseWithoutDragging()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  local consumed = sm:handleMouseRelease(1)
  luaunit.assertFalse(consumed)
end

function TestScrollManagerEdgeCases:testHandleMouseReleaseWithWrongButton()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  sm._scrollbarDragging = true -- Simulate dragging
  local consumed = sm:handleMouseRelease(2) -- Wrong button
  luaunit.assertFalse(consumed)
  luaunit.assertTrue(sm._scrollbarDragging) -- Should still be dragging
end

-- ============================================================================
-- Wheel Scrolling Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testHandleWheelWithNoOverflow()
  local sm = createScrollManager({ overflow = "auto" })
  sm._overflowX = false
  sm._overflowY = false
  sm._maxScrollX = 0
  sm._maxScrollY = 0

  local scrolled = sm:handleWheel(0, 1)
  luaunit.assertFalse(scrolled)
end

function TestScrollManagerEdgeCases:testHandleWheelWithHiddenOverflow()
  local sm = createScrollManager({ overflow = "hidden" })
  sm._overflowX = true
  sm._overflowY = true
  sm._maxScrollX = 100
  sm._maxScrollY = 100

  local scrolled = sm:handleWheel(0, 1)
  luaunit.assertFalse(scrolled)
end

function TestScrollManagerEdgeCases:testHandleWheelWithVisibleOverflow()
  local sm = createScrollManager({ overflow = "visible" })
  sm._overflowX = true
  sm._overflowY = true
  sm._maxScrollX = 100
  sm._maxScrollY = 100

  local scrolled = sm:handleWheel(0, 1)
  luaunit.assertFalse(scrolled)
end

function TestScrollManagerEdgeCases:testHandleWheelWithZeroValues()
  local sm = createScrollManager({ overflow = "auto" })
  sm._overflowY = true
  sm._maxScrollY = 100

  local scrolled = sm:handleWheel(0, 0)
  luaunit.assertFalse(scrolled)
end

function TestScrollManagerEdgeCases:testHandleWheelWithExtremeValues()
  local sm = createScrollManager({ overflow = "auto", scrollSpeed = 20 })
  sm._scrollY = 50
  sm._overflowY = true
  sm._maxScrollY = 100

  local scrolled = sm:handleWheel(0, 1000) -- Extreme value
  luaunit.assertTrue(scrolled)

  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollY, 0) -- Should clamp to min (wheel up scrolls to top)
end

function TestScrollManagerEdgeCases:testHandleWheelWithNegativeScrollSpeed()
  local sm = createScrollManager({ overflow = "auto", scrollSpeed = -20 })
  sm._scrollY = 50
  sm._overflowY = true
  sm._maxScrollY = 100

  local scrolled = sm:handleWheel(0, 1)
  luaunit.assertTrue(scrolled)

  -- Negative speed would invert scroll direction
  local scrollX, scrollY = sm:getScroll()
  -- Result depends on implementation
end

-- ============================================================================
-- Touch Scrolling Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testHandleTouchPressWithDisabled()
  local sm = createScrollManager({ overflow = "auto", touchScrollEnabled = false })

  local started = sm:handleTouchPress(50, 50)
  luaunit.assertFalse(started)
end

function TestScrollManagerEdgeCases:testHandleTouchPressWithHiddenOverflow()
  local sm = createScrollManager({ overflow = "hidden", touchScrollEnabled = true })

  local started = sm:handleTouchPress(50, 50)
  luaunit.assertFalse(started)
end

function TestScrollManagerEdgeCases:testHandleTouchPressStopsMomentum()
  local sm = createScrollManager({ overflow = "auto", touchScrollEnabled = true })
  sm._momentumScrolling = true
  sm._scrollVelocityX = 500
  sm._scrollVelocityY = 500

  local started = sm:handleTouchPress(50, 50)
  luaunit.assertTrue(started)
  luaunit.assertFalse(sm._momentumScrolling)
  luaunit.assertEquals(sm._scrollVelocityX, 0)
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

function TestScrollManagerEdgeCases:testHandleTouchMoveWithoutPress()
  local sm = createScrollManager({ overflow = "auto", touchScrollEnabled = true })
  sm._touchScrolling = false

  local handled = sm:handleTouchMove(50, 50)
  luaunit.assertFalse(handled)
end

function TestScrollManagerEdgeCases:testHandleTouchMoveWithZeroDeltaTime()
  local sm = createScrollManager({ overflow = "auto", touchScrollEnabled = true })
  sm._touchScrolling = true
  sm._lastTouchTime = love.timer.getTime() -- Same time

  local handled = sm:handleTouchMove(50, 50)
  luaunit.assertFalse(handled) -- Should reject zero dt
end

function TestScrollManagerEdgeCases:testHandleTouchMoveWithBounceEnabled()
  local sm = createScrollManager({
    overflow = "auto",
    touchScrollEnabled = true,
    bounceEnabled = true,
    maxOverscroll = 100,
  })
  sm._touchScrolling = true
  sm._scrollX = 0
  sm._scrollY = 0
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm._lastTouchX = 100
  sm._lastTouchY = 100
  sm._lastTouchTime = love.timer.getTime() - 0.1

  -- Move backwards to cause overscroll
  local handled = sm:handleTouchMove(200, 200)
  luaunit.assertTrue(handled)

  -- Should allow negative scroll (overscroll)
  local scrollX, scrollY = sm:getScroll()
  luaunit.assertTrue(scrollX < 0)
  luaunit.assertTrue(scrollY < 0)
end

function TestScrollManagerEdgeCases:testHandleTouchMoveWithBounceDisabled()
  local sm = createScrollManager({
    overflow = "auto",
    touchScrollEnabled = true,
    bounceEnabled = false,
  })
  sm._touchScrolling = true
  sm._scrollX = 0
  sm._scrollY = 0
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm._lastTouchX = 100
  sm._lastTouchY = 100
  sm._lastTouchTime = love.timer.getTime() - 0.1

  -- Move backwards to try overscroll
  local handled = sm:handleTouchMove(200, 200)
  luaunit.assertTrue(handled)

  -- Should clamp to 0
  local scrollX, scrollY = sm:getScroll()
  luaunit.assertEquals(scrollX, 0)
  luaunit.assertEquals(scrollY, 0)
end

function TestScrollManagerEdgeCases:testHandleTouchReleaseWithoutPress()
  local sm = createScrollManager({ overflow = "auto", touchScrollEnabled = true })
  sm._touchScrolling = false

  local handled = sm:handleTouchRelease()
  luaunit.assertFalse(handled)
end

function TestScrollManagerEdgeCases:testHandleTouchReleaseWithMomentumDisabled()
  local sm = createScrollManager({
    overflow = "auto",
    touchScrollEnabled = true,
    momentumScrollEnabled = false,
  })
  sm._touchScrolling = true
  sm._scrollVelocityX = 500
  sm._scrollVelocityY = 500

  local handled = sm:handleTouchRelease()
  luaunit.assertTrue(handled)
  luaunit.assertFalse(sm._momentumScrolling)
  luaunit.assertEquals(sm._scrollVelocityX, 0)
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

function TestScrollManagerEdgeCases:testHandleTouchReleaseWithLowVelocity()
  local sm = createScrollManager({
    overflow = "auto",
    touchScrollEnabled = true,
    momentumScrollEnabled = true,
  })
  sm._touchScrolling = true
  sm._scrollVelocityX = 10 -- Below threshold
  sm._scrollVelocityY = 10

  local handled = sm:handleTouchRelease()
  luaunit.assertTrue(handled)
  luaunit.assertFalse(sm._momentumScrolling)
end

function TestScrollManagerEdgeCases:testHandleTouchReleaseWithHighVelocity()
  local sm = createScrollManager({
    overflow = "auto",
    touchScrollEnabled = true,
    momentumScrollEnabled = true,
  })
  sm._touchScrolling = true
  sm._scrollVelocityX = 500
  sm._scrollVelocityY = 500

  local handled = sm:handleTouchRelease()
  luaunit.assertTrue(handled)
  luaunit.assertTrue(sm._momentumScrolling)
end

-- ============================================================================
-- Update and Momentum Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testUpdateWithoutMomentum()
  local sm = createScrollManager({ overflow = "auto" })
  sm._momentumScrolling = false

  sm:update(0.016) -- Normal frame time
  -- Should not crash
end

function TestScrollManagerEdgeCases:testUpdateWithZeroDeltaTime()
  local sm = createScrollManager({ overflow = "auto" })
  sm._momentumScrolling = true
  sm._scrollVelocityX = 100
  sm._scrollVelocityY = 100

  sm:update(0)
  -- Should not cause issues
end

function TestScrollManagerEdgeCases:testUpdateWithNegativeDeltaTime()
  local sm = createScrollManager({ overflow = "auto" })
  sm._momentumScrolling = true
  sm._scrollVelocityX = 100
  sm._scrollVelocityY = 100

  sm:update(-0.016)
  -- Should handle gracefully (may cause backwards scroll)
end

function TestScrollManagerEdgeCases:testUpdateWithVeryLargeDeltaTime()
  local sm = createScrollManager({ overflow = "auto" })
  sm._momentumScrolling = true
  sm._scrollX = 50
  sm._scrollY = 50
  sm._maxScrollX = 100
  sm._maxScrollY = 100
  sm._scrollVelocityX = 100
  sm._scrollVelocityY = 100

  sm:update(10) -- 10 seconds
  -- Should handle gracefully
end

function TestScrollManagerEdgeCases:testUpdateStopsMomentumWhenVelocityLow()
  local sm = createScrollManager({ overflow = "auto", scrollFriction = 0.1 }) -- Very low friction
  sm._momentumScrolling = true
  sm._scrollVelocityX = 0.5 -- Below threshold of 1
  sm._scrollVelocityY = 0.5

  sm:update(0.016)

  -- After friction, velocity should be below threshold and momentum stopped
  luaunit.assertFalse(sm._momentumScrolling)
  luaunit.assertEquals(sm._scrollVelocityX, 0)
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

function TestScrollManagerEdgeCases:testUpdateWithInvalidFriction()
  local sm = createScrollManager({ overflow = "auto", scrollFriction = 1.5 }) -- > 1 increases velocity
  sm._momentumScrolling = true
  sm._scrollVelocityX = 100
  sm._scrollVelocityY = 100

  local initialVX = sm._scrollVelocityX
  sm:update(0.016)

  -- Velocity should increase with friction > 1
  luaunit.assertTrue(math.abs(sm._scrollVelocityX) > initialVX)
end

function TestScrollManagerEdgeCases:testUpdateBounceWithZeroBounceStiffness()
  local sm = createScrollManager({
    overflow = "auto",
    bounceEnabled = true,
    bounceStiffness = 0,
  })
  sm._scrollX = -50 -- Overscrolled
  sm._scrollY = -50
  sm._maxScrollX = 100
  sm._maxScrollY = 100

  sm:update(0.016)

  -- With zero stiffness, no bounce force applied
  luaunit.assertEquals(sm._scrollX, -50)
  luaunit.assertEquals(sm._scrollY, -50)
end

function TestScrollManagerEdgeCases:testUpdateBounceWithNegativeStiffness()
  local sm = createScrollManager({
    overflow = "auto",
    bounceEnabled = true,
    bounceStiffness = -0.2, -- Negative pushes away from bounds
  })
  sm._scrollX = -50 -- Overscrolled
  sm._scrollY = -50
  sm._maxScrollX = 100
  sm._maxScrollY = 100

  local initialX = sm._scrollX
  sm:update(0.016)

  -- Negative stiffness pushes further out
  luaunit.assertTrue(sm._scrollX < initialX)
end

function TestScrollManagerEdgeCases:testUpdateBounceSnapsToZero()
  local sm = createScrollManager({
    overflow = "auto",
    bounceEnabled = true,
    bounceStiffness = 1.0, -- Very high stiffness
  })
  sm._scrollX = -0.3 -- Small overscroll
  sm._scrollY = -0.3
  sm._maxScrollX = 100
  sm._maxScrollY = 100

  sm:update(0.016)

  -- Should snap to 0 when close enough
  luaunit.assertEquals(sm._scrollX, 0)
  luaunit.assertEquals(sm._scrollY, 0)
end

function TestScrollManagerEdgeCases:testUpdateBounceSnapsToMax()
  local sm = createScrollManager({
    overflow = "auto",
    bounceEnabled = true,
    bounceStiffness = 1.0,
  })
  sm._scrollX = 100.3 -- Small overscroll beyond max
  sm._scrollY = 100.3
  sm._maxScrollX = 100
  sm._maxScrollY = 100

  sm:update(0.016)

  -- Should snap to max when close enough
  luaunit.assertEquals(sm._scrollX, 100)
  luaunit.assertEquals(sm._scrollY, 100)
end

-- ============================================================================
-- State Persistence Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testGetState()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 75
  sm._scrollbarDragging = true
  sm._hoveredScrollbar = "vertical"
  sm._scrollbarDragOffset = 10

  local state = sm:getState()
  luaunit.assertEquals(state._scrollX, 50)
  luaunit.assertEquals(state._scrollY, 75)
  luaunit.assertTrue(state._scrollbarDragging)
  luaunit.assertEquals(state._hoveredScrollbar, "vertical")
  luaunit.assertEquals(state._scrollbarDragOffset, 10)
end

function TestScrollManagerEdgeCases:testSetStateWithNil()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50

  sm:setState(nil)

  -- Should not change anything
  luaunit.assertEquals(sm._scrollX, 50)
  luaunit.assertEquals(sm._scrollY, 50)
end

function TestScrollManagerEdgeCases:testSetStateWithEmptyTable()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50

  sm:setState({})

  -- Should not change anything
  luaunit.assertEquals(sm._scrollX, 50)
  luaunit.assertEquals(sm._scrollY, 50)
end

function TestScrollManagerEdgeCases:testSetStatePartial()
  local sm = createScrollManager({ overflow = "auto" })
  sm._scrollX = 50
  sm._scrollY = 50
  sm._scrollbarDragging = false

  sm:setState({ scrollX = 100, scrollbarDragging = true })

  luaunit.assertEquals(sm._scrollX, 100)
  luaunit.assertEquals(sm._scrollY, 50) -- Unchanged
  luaunit.assertTrue(sm._scrollbarDragging)
end

-- ============================================================================
-- Hover State Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testUpdateHoverStateOutsideScrollbar()
  local sm = createScrollManager({ overflow = "scroll" })
  local element = createMockElement(200, 300, {})
  -- sm:initialize(element) -- Removed: element now passed as parameter
  sm:detectOverflow(element)

  sm._scrollbarHoveredVertical = true
  sm._scrollbarHoveredHorizontal = true

  sm:updateHoverState(element, 0, 0) -- Far from scrollbar

  luaunit.assertFalse(sm._scrollbarHoveredVertical)
  luaunit.assertFalse(sm._scrollbarHoveredHorizontal)
end

-- ============================================================================
-- Flag Management Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testResetScrollbarPressFlag()
  local sm = createScrollManager({})
  sm._scrollbarPressHandled = true

  sm:resetScrollbarPressFlag()

  luaunit.assertFalse(sm._scrollbarPressHandled)
end

function TestScrollManagerEdgeCases:testSetScrollbarPressHandled()
  local sm = createScrollManager({})
  sm._scrollbarPressHandled = false

  sm:setScrollbarPressHandled()

  luaunit.assertTrue(sm._scrollbarPressHandled)
end

function TestScrollManagerEdgeCases:testWasScrollbarPressHandled()
  local sm = createScrollManager({})
  sm._scrollbarPressHandled = true

  luaunit.assertTrue(sm:wasScrollbarPressHandled())
end

-- ============================================================================
-- Query Methods Edge Cases
-- ============================================================================

function TestScrollManagerEdgeCases:testIsTouchScrolling()
  local sm = createScrollManager({})
  luaunit.assertFalse(sm:isTouchScrolling())

  sm._touchScrolling = true
  luaunit.assertTrue(sm:isTouchScrolling())
end

function TestScrollManagerEdgeCases:testIsMomentumScrolling()
  local sm = createScrollManager({})
  luaunit.assertFalse(sm:isMomentumScrolling())

  sm._momentumScrolling = true
  luaunit.assertTrue(sm:isMomentumScrolling())
end

-- Test scrollbarKnobOffset configuration
function TestScrollManagerEdgeCases:testScrollbarKnobOffsetNumber()
  local sm = createScrollManager({ scrollbarKnobOffset = 5 })
  luaunit.assertNotNil(sm.scrollbarKnobOffset)
  luaunit.assertEquals(sm.scrollbarKnobOffset.x, 5)
  luaunit.assertEquals(sm.scrollbarKnobOffset.y, 5)
  luaunit.assertEquals(sm.scrollbarKnobOffset.horizontal, 5)
  luaunit.assertEquals(sm.scrollbarKnobOffset.vertical, 5)
end

function TestScrollManagerEdgeCases:testScrollbarKnobOffsetTableXY()
  local sm = createScrollManager({ scrollbarKnobOffset = { x = 10, y = 20 } })
  luaunit.assertNotNil(sm.scrollbarKnobOffset)
  luaunit.assertEquals(sm.scrollbarKnobOffset.x, 10)
  luaunit.assertEquals(sm.scrollbarKnobOffset.y, 20)
  luaunit.assertEquals(sm.scrollbarKnobOffset.horizontal, 10)
  luaunit.assertEquals(sm.scrollbarKnobOffset.vertical, 20)
end

function TestScrollManagerEdgeCases:testScrollbarKnobOffsetTableHorizontalVertical()
  local sm = createScrollManager({ scrollbarKnobOffset = { horizontal = 15, vertical = 25 } })
  luaunit.assertNotNil(sm.scrollbarKnobOffset)
  luaunit.assertEquals(sm.scrollbarKnobOffset.x, 15)
  luaunit.assertEquals(sm.scrollbarKnobOffset.y, 25)
  luaunit.assertEquals(sm.scrollbarKnobOffset.horizontal, 15)
  luaunit.assertEquals(sm.scrollbarKnobOffset.vertical, 25)
end

function TestScrollManagerEdgeCases:testScrollbarKnobOffsetDefault()
  -- When not provided, scrollbarKnobOffset should be nil (use theme default)
  local sm = createScrollManager({})
  luaunit.assertNil(sm.scrollbarKnobOffset)

  -- When explicitly set to 0, it should be normalized
  local sm2 = createScrollManager({ scrollbarKnobOffset = 0 })
  luaunit.assertNotNil(sm2.scrollbarKnobOffset)
  luaunit.assertEquals(sm2.scrollbarKnobOffset.x, 0)
  luaunit.assertEquals(sm2.scrollbarKnobOffset.y, 0)
  luaunit.assertEquals(sm2.scrollbarKnobOffset.horizontal, 0)
  luaunit.assertEquals(sm2.scrollbarKnobOffset.vertical, 0)
end

function TestScrollManagerEdgeCases:testScrollbarKnobOffsetStatePersistence()
  local sm = createScrollManager({ scrollbarKnobOffset = { x = 5, y = 10 } })
  local state = sm:getState()
  luaunit.assertNotNil(state.scrollbarKnobOffset)

  local sm2 = createScrollManager({})
  sm2:setState(state)
  luaunit.assertEquals(sm2.scrollbarKnobOffset.x, 5)
  luaunit.assertEquals(sm2.scrollbarKnobOffset.y, 10)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
