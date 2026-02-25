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

-- Helper to create ScrollManager with touch config
local function createTouchScrollManager(config)
  config = config or {}
  config.overflow = config.overflow or "scroll"
  return ScrollManager.new(config, {
    Color = Color,
    utils = utils,
  })
end

-- Helper to create mock element with content taller than container
local function createMockElement(width, height, contentWidth, contentHeight)
  local children = {}
  -- Create a single child that represents all content
  table.insert(children, {
    x = 0,
    y = 0,
    width = contentWidth or 200,
    height = contentHeight or 600,
    margin = { top = 0, right = 0, bottom = 0, left = 0 },
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function(self) return self.width end,
    getBorderBoxHeight = function(self) return self.height end,
  })

  return {
    x = 0,
    y = 0,
    width = width or 200,
    height = height or 300,
    padding = { top = 0, right = 0, bottom = 0, left = 0 },
    children = children,
    getBorderBoxWidth = function(self) return self.width end,
    getBorderBoxHeight = function(self) return self.height end,
  }
end

-- ============================================================================
-- Test Suite: Touch Press
-- ============================================================================

TestTouchScrollPress = {}

function TestTouchScrollPress:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollPress:test_handleTouchPress_starts_scrolling()
  local sm = createTouchScrollManager()
  local el = createMockElement()
  sm:detectOverflow(el)

  local started = sm:handleTouchPress(100, 150)

  luaunit.assertTrue(started)
  luaunit.assertTrue(sm:isTouchScrolling())
end

function TestTouchScrollPress:test_handleTouchPress_disabled_returns_false()
  local sm = createTouchScrollManager({ touchScrollEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  local started = sm:handleTouchPress(100, 150)

  luaunit.assertFalse(started)
  luaunit.assertFalse(sm:isTouchScrolling())
end

function TestTouchScrollPress:test_handleTouchPress_no_overflow_returns_false()
  local sm = createTouchScrollManager({ overflow = "hidden" })

  local started = sm:handleTouchPress(100, 150)

  luaunit.assertFalse(started)
end

function TestTouchScrollPress:test_handleTouchPress_stops_momentum_scrolling()
  local sm = createTouchScrollManager()
  local el = createMockElement()
  sm:detectOverflow(el)

  -- Simulate momentum by starting touch, moving fast, releasing
  sm:handleTouchPress(100, 200)
  -- Manually set momentum state
  sm._momentumScrolling = true
  sm._scrollVelocityY = 500

  -- New press should stop momentum
  sm:handleTouchPress(100, 200)

  luaunit.assertFalse(sm:isMomentumScrolling())
  luaunit.assertEquals(sm._scrollVelocityX, 0)
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

-- ============================================================================
-- Test Suite: Touch Move
-- ============================================================================

TestTouchScrollMove = {}

function TestTouchScrollMove:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollMove:test_handleTouchMove_scrolls_content()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)

  -- Advance time so dt > 0 in handleTouchMove
  love.timer.step(1 / 60)
  local handled = sm:handleTouchMove(100, 150)

  luaunit.assertTrue(handled)
  -- Touch moved UP by 50px, so scroll should increase (content moves down relative to finger)
  luaunit.assertTrue(sm._scrollY > 0)
end

function TestTouchScrollMove:test_handleTouchMove_without_press_returns_false()
  local sm = createTouchScrollManager()

  local handled = sm:handleTouchMove(100, 150)

  luaunit.assertFalse(handled)
end

function TestTouchScrollMove:test_handleTouchMove_calculates_velocity()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)
  love.timer.step(1 / 60)
  sm:handleTouchMove(100, 100) -- Move 100px up

  -- Velocity should be set (non-zero since time elapsed)
  -- Note: velocity direction is inverted (touch up = scroll down = positive velocity)
  luaunit.assertTrue(sm._scrollVelocityY > 0)
end

function TestTouchScrollMove:test_handleTouchMove_horizontal()
  local sm = createTouchScrollManager({
    bounceEnabled = false,
    overflowX = "scroll",
    overflowY = "hidden",
  })
  local el = createMockElement(200, 300, 600, 300) -- Wide content
  sm:detectOverflow(el)

  sm:handleTouchPress(200, 150)
  love.timer.step(1 / 60)
  sm:handleTouchMove(100, 150) -- Move 100px left

  luaunit.assertTrue(sm._scrollX > 0)
end

function TestTouchScrollMove:test_handleTouchMove_with_bounce_allows_overscroll()
  local sm = createTouchScrollManager({ bounceEnabled = true, maxOverscroll = 100 })
  local el = createMockElement()
  sm:detectOverflow(el)

  -- Scroll is at 0 (top), try to scroll further up (negative)
  sm:handleTouchPress(100, 100)
  love.timer.step(1 / 60)
  sm:handleTouchMove(100, 200) -- Move down = scroll up (negative)

  -- With bounce, overscroll should be allowed (scroll < 0)
  luaunit.assertTrue(sm._scrollY < 0)
end

-- ============================================================================
-- Test Suite: Touch Release and Momentum
-- ============================================================================

TestTouchScrollRelease = {}

function TestTouchScrollRelease:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollRelease:test_handleTouchRelease_ends_touch_scrolling()
  local sm = createTouchScrollManager()
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)
  luaunit.assertTrue(sm:isTouchScrolling())

  sm:handleTouchRelease()
  luaunit.assertFalse(sm:isTouchScrolling())
end

function TestTouchScrollRelease:test_handleTouchRelease_without_press_returns_false()
  local sm = createTouchScrollManager()

  local released = sm:handleTouchRelease()

  luaunit.assertFalse(released)
end

function TestTouchScrollRelease:test_handleTouchRelease_starts_momentum_with_velocity()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)
  love.timer.step(1 / 60)
  sm:handleTouchMove(100, 50) -- Fast swipe up

  sm:handleTouchRelease()

  -- Should start momentum scrolling due to high velocity
  luaunit.assertTrue(sm:isMomentumScrolling())
end

function TestTouchScrollRelease:test_handleTouchRelease_no_momentum_with_low_velocity()
  local sm = createTouchScrollManager()
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)
  -- Simulate a very slow move by setting low velocity manually
  sm._scrollVelocityX = 0
  sm._scrollVelocityY = 10 -- Below threshold of 50

  sm:handleTouchRelease()

  luaunit.assertFalse(sm:isMomentumScrolling())
end

function TestTouchScrollRelease:test_handleTouchRelease_no_momentum_when_disabled()
  local sm = createTouchScrollManager({ momentumScrollEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)
  sm._scrollVelocityY = 500

  sm:handleTouchRelease()

  luaunit.assertFalse(sm:isMomentumScrolling())
  luaunit.assertEquals(sm._scrollVelocityX, 0)
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

-- ============================================================================
-- Test Suite: Momentum Scrolling
-- ============================================================================

TestMomentumScrolling = {}

function TestMomentumScrolling:setUp()
  love.timer.setTime(0)
end

function TestMomentumScrolling:test_momentum_decelerates_over_time()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  -- Set up momentum manually
  sm._momentumScrolling = true
  sm._scrollVelocityY = 200

  local initialVelocity = sm._scrollVelocityY

  sm:update(1 / 60)

  luaunit.assertTrue(sm._scrollVelocityY < initialVelocity)
  luaunit.assertTrue(sm._scrollVelocityY > 0)
end

function TestMomentumScrolling:test_momentum_stops_at_low_velocity()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm._momentumScrolling = true
  sm._scrollVelocityY = 200

  -- Run many frames until momentum stops
  for i = 1, 500 do
    sm:update(1 / 60)
    if not sm:isMomentumScrolling() then
      break
    end
  end

  luaunit.assertFalse(sm:isMomentumScrolling())
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

function TestMomentumScrolling:test_momentum_moves_scroll_position()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm._momentumScrolling = true
  sm._scrollVelocityY = 500

  local initialScrollY = sm._scrollY
  sm:update(1 / 60)

  luaunit.assertTrue(sm._scrollY > initialScrollY)
end

function TestMomentumScrolling:test_friction_coefficient_affects_deceleration()
  local smFast = createTouchScrollManager({ scrollFriction = 0.99, bounceEnabled = false })
  local smSlow = createTouchScrollManager({ scrollFriction = 0.90, bounceEnabled = false })
  local el = createMockElement()
  smFast:detectOverflow(el)
  smSlow:detectOverflow(el)

  smFast._momentumScrolling = true
  smFast._scrollVelocityY = 200
  smSlow._momentumScrolling = true
  smSlow._scrollVelocityY = 200

  smFast:update(1 / 60)
  smSlow:update(1 / 60)

  -- Higher friction (0.99) preserves more velocity than lower friction (0.90)
  luaunit.assertTrue(smFast._scrollVelocityY > smSlow._scrollVelocityY)
end

-- ============================================================================
-- Test Suite: Bounce Effects
-- ============================================================================

TestTouchScrollBounce = {}

function TestTouchScrollBounce:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollBounce:test_bounce_returns_to_boundary()
  local sm = createTouchScrollManager({ bounceEnabled = true })
  local el = createMockElement()
  sm:detectOverflow(el)

  -- Force overscroll position
  sm._scrollY = -50

  -- Run bounce updates
  for i = 1, 100 do
    sm:update(1 / 60)
  end

  -- Should have bounced back to 0
  luaunit.assertAlmostEquals(sm._scrollY, 0, 1)
end

function TestTouchScrollBounce:test_bounce_at_bottom_boundary()
  local sm = createTouchScrollManager({ bounceEnabled = true })
  local el = createMockElement()
  sm:detectOverflow(el)

  -- Force overscroll past max
  sm._scrollY = sm._maxScrollY + 50

  for i = 1, 100 do
    sm:update(1 / 60)
  end

  luaunit.assertAlmostEquals(sm._scrollY, sm._maxScrollY, 1)
end

function TestTouchScrollBounce:test_no_bounce_when_disabled()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm._scrollY = -50

  sm:update(1 / 60)

  -- Without bounce, scroll should stay where it is (clamped by scrollBy)
  -- But here we set it directly, so it stays
  luaunit.assertEquals(sm._scrollY, -50)
end

-- ============================================================================
-- Test Suite: State Query Methods
-- ============================================================================

TestTouchScrollState = {}

function TestTouchScrollState:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollState:test_isTouchScrolling_initially_false()
  local sm = createTouchScrollManager()
  luaunit.assertFalse(sm:isTouchScrolling())
end

function TestTouchScrollState:test_isMomentumScrolling_initially_false()
  local sm = createTouchScrollManager()
  luaunit.assertFalse(sm:isMomentumScrolling())
end

function TestTouchScrollState:test_isTouchScrolling_true_during_touch()
  local sm = createTouchScrollManager()
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)
  luaunit.assertTrue(sm:isTouchScrolling())

  sm:handleTouchRelease()
  luaunit.assertFalse(sm:isTouchScrolling())
end

-- ============================================================================
-- Test Suite: Configuration
-- ============================================================================

TestTouchScrollConfig = {}

function TestTouchScrollConfig:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollConfig:test_default_config_values()
  local sm = createTouchScrollManager()

  luaunit.assertTrue(sm.touchScrollEnabled)
  luaunit.assertTrue(sm.momentumScrollEnabled)
  luaunit.assertTrue(sm.bounceEnabled)
  luaunit.assertEquals(sm.scrollFriction, 0.95)
  luaunit.assertEquals(sm.bounceStiffness, 0.2)
  luaunit.assertEquals(sm.maxOverscroll, 100)
end

function TestTouchScrollConfig:test_custom_config_values()
  local sm = createTouchScrollManager({
    touchScrollEnabled = false,
    momentumScrollEnabled = false,
    bounceEnabled = false,
    scrollFriction = 0.98,
    bounceStiffness = 0.1,
    maxOverscroll = 50,
  })

  luaunit.assertFalse(sm.touchScrollEnabled)
  luaunit.assertFalse(sm.momentumScrollEnabled)
  luaunit.assertFalse(sm.bounceEnabled)
  luaunit.assertEquals(sm.scrollFriction, 0.98)
  luaunit.assertEquals(sm.bounceStiffness, 0.1)
  luaunit.assertEquals(sm.maxOverscroll, 50)
end

-- Run all tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
