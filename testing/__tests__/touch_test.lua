package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)
require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")
local ErrorHandler = require("modules.ErrorHandler")
local ScrollManager = require("modules.ScrollManager")
local Color = require("modules.Color")
local utils = require("modules.utils")

FlexLove.init()

local InputEvent = package.loaded["modules.InputEvent"]
local GestureRecognizer = package.loaded["modules.GestureRecognizer"]

-- ============================================================================
-- Helpers
-- ============================================================================

--- Create a GestureRecognizer touch event helper
local function touchEvent(id, x, y, phase, time)
  if time then love.timer.setTime(time) end
  return InputEvent.fromTouch(id, x, y, phase, 1.0)
end

--- Create a ScrollManager with touch config (uses direct module init, not FlexLove)
local function createTouchScrollManager(config)
  config = config or {}
  config.overflow = config.overflow or "scroll"
  ErrorHandler.init({})
  ScrollManager.init({ ErrorHandler = ErrorHandler })
  return ScrollManager.new(config, {
    Color = Color,
    utils = utils,
  })
end

--- Create a mock element for ScrollManager tests
local function createMockElement(width, height, contentWidth, contentHeight)
  local children = {}
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
-- InputEvent.fromTouch Tests
-- ============================================================================

TestTouchInputEvent = {}

function TestTouchInputEvent:test_fromTouch_creates_valid_touchpress()
  local event = InputEvent.fromTouch("touch1", 100, 200, "began", 0.8)

  luaunit.assertEquals(event.type, "touchpress")
  luaunit.assertEquals(event.x, 100)
  luaunit.assertEquals(event.y, 200)
  luaunit.assertEquals(event.touchId, "touch1")
  luaunit.assertEquals(event.pressure, 0.8)
  luaunit.assertEquals(event.phase, "began")
  luaunit.assertEquals(event.button, 1)
end

function TestTouchInputEvent:test_fromTouch_moved_phase()
  local event = InputEvent.fromTouch("touch1", 150, 250, "moved", 1.0)

  luaunit.assertEquals(event.type, "touchmove")
  luaunit.assertEquals(event.phase, "moved")
end

function TestTouchInputEvent:test_fromTouch_ended_phase()
  local event = InputEvent.fromTouch("touch1", 150, 250, "ended", 1.0)

  luaunit.assertEquals(event.type, "touchrelease")
  luaunit.assertEquals(event.phase, "ended")
end

function TestTouchInputEvent:test_fromTouch_cancelled_phase()
  local event = InputEvent.fromTouch("touch1", 150, 250, "cancelled", 1.0)

  luaunit.assertEquals(event.type, "touchcancel")
  luaunit.assertEquals(event.phase, "cancelled")
end

-- ============================================================================
-- EventHandler Touch Processing Tests
-- ============================================================================

TestTouchEventHandler = {}

function TestTouchEventHandler:test_touch_began()
  FlexLove.beginFrame()

  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })

  FlexLove.endFrame()

  love.touch.getTouches = function() return { "touch1" } end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 100, 100 end
    return 0, 0
  end

  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents(element)
  FlexLove.endFrame()

  local filteredEvents = {}
  for _, event in ipairs(touchEvents) do
    if event.type ~= "hover" and event.type ~= "unhover" then
      table.insert(filteredEvents, event)
    end
  end

  luaunit.assertTrue(#filteredEvents >= 1, "Should receive at least 1 touch event, got " .. #filteredEvents)
  luaunit.assertEquals(filteredEvents[1].type, "touchpress")
  luaunit.assertEquals(filteredEvents[1].touchId, "touch1")
end

function TestTouchEventHandler:test_touch_moved()
  FlexLove.beginFrame()

  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })

  FlexLove.endFrame()

  love.touch.getTouches = function() return { "touch1" } end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 100, 100 end
    return 0, 0
  end

  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents(element)
  FlexLove.endFrame()

  love.touch.getPosition = function(id)
    if id == "touch1" then return 150, 150 end
    return 0, 0
  end

  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents(element)
  FlexLove.endFrame()

  local filteredEvents = {}
  for _, event in ipairs(touchEvents) do
    if event.type ~= "hover" and event.type ~= "unhover" then
      table.insert(filteredEvents, event)
    end
  end

  luaunit.assertEquals(#filteredEvents, 2)
  luaunit.assertEquals(filteredEvents[1].type, "touchpress")
  luaunit.assertEquals(filteredEvents[2].type, "touchmove")
  luaunit.assertEquals(filteredEvents[2].dx, 50)
  luaunit.assertEquals(filteredEvents[2].dy, 50)
end

function TestTouchEventHandler:test_touch_ended()
  FlexLove.beginFrame()

  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })

  FlexLove.endFrame()

  love.touch.getTouches = function() return { "touch1" } end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 100, 100 end
    return 0, 0
  end

  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents(element)
  FlexLove.endFrame()

  love.touch.getTouches = function() return {} end

  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents(element)
  FlexLove.endFrame()

  local filteredEvents = {}
  for _, event in ipairs(touchEvents) do
    if event.type ~= "hover" and event.type ~= "unhover" then
      table.insert(filteredEvents, event)
    end
  end

  luaunit.assertEquals(#filteredEvents, 2)
  luaunit.assertEquals(filteredEvents[1].type, "touchpress")
  luaunit.assertEquals(filteredEvents[2].type, "touchrelease")
end

function TestTouchEventHandler:test_multi_touch()
  FlexLove.beginFrame()

  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    multiTouchEnabled = true,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })

  FlexLove.endFrame()

  love.touch.getTouches = function() return { "touch1", "touch2" } end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 50, 50 end
    if id == "touch2" then return 150, 150 end
    return 0, 0
  end

  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents(element)
  FlexLove.endFrame()

  local filteredEvents = {}
  for _, event in ipairs(touchEvents) do
    if event.type ~= "hover" and event.type ~= "unhover" then
      table.insert(filteredEvents, event)
    end
  end

  luaunit.assertEquals(#filteredEvents, 2)
  luaunit.assertEquals(filteredEvents[1].type, "touchpress")
  luaunit.assertEquals(filteredEvents[2].type, "touchpress")
  luaunit.assertNotEquals(filteredEvents[1].touchId, filteredEvents[2].touchId)
end

function TestTouchEventHandler:test_gestureRecognizer_structural()
  local recognizer = GestureRecognizer.new({}, {
    InputEvent = InputEvent,
    utils = utils,
  })

  local pressEvent = InputEvent.fromTouch("touch1", 100, 100, "began", 1.0)
  local releaseEvent = InputEvent.fromTouch("touch1", 102, 102, "ended", 1.0)

  recognizer:processTouchEvent(pressEvent)
  recognizer:processTouchEvent(releaseEvent)

  luaunit.assertNotNil(recognizer)
end

-- ============================================================================
-- GestureRecognizer Tests
-- ============================================================================

TestTouchGestureRecognizer = {}

function TestTouchGestureRecognizer:setUp()
  self.recognizer = GestureRecognizer.new({}, { InputEvent = InputEvent, utils = {} })
  love.timer.setTime(0)
end

function TestTouchGestureRecognizer:tearDown()
  self.recognizer:reset()
end

-- Tap tests

function TestTouchGestureRecognizer:test_tap_detected()
  local event1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(event1)

  local event2 = touchEvent("t1", 100, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(event2)

  luaunit.assertNotNil(gestures, "Tap gesture should be detected")
  luaunit.assertEquals(gestures[1].type, "tap")
  luaunit.assertEquals(gestures[1].state, "ended")
  luaunit.assertEquals(gestures[1].x, 100)
  luaunit.assertEquals(gestures[1].y, 100)
end

function TestTouchGestureRecognizer:test_tap_not_detected_when_too_slow()
  local event1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(event1)

  local event2 = touchEvent("t1", 100, 100, "ended", 0.5)
  local gestures = self.recognizer:processTouchEvent(event2)

  if gestures then
    for _, g in ipairs(gestures) do
      luaunit.assertNotEquals(g.type, "tap", "Slow touch should not be tap")
    end
  end
end

function TestTouchGestureRecognizer:test_tap_not_detected_when_moved_too_far()
  local event1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(event1)

  local event2 = touchEvent("t1", 120, 120, "moved", 0.05)
  self.recognizer:processTouchEvent(event2)

  local event3 = touchEvent("t1", 120, 120, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(event3)

  if gestures then
    for _, g in ipairs(gestures) do
      if g.type == "tap" then
        local dx = 120 - 100
        local dy = 120 - 100
        local dist = math.sqrt(dx * dx + dy * dy)
        luaunit.assertTrue(dist >= 10, "Movement should exceed tap threshold")
      end
    end
  end
end

function TestTouchGestureRecognizer:test_double_tap_detected()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t1", 100, 100, "ended", 0.05)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t2", 100, 100, "began", 0.15)
  self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 100, 100, "ended", 0.2)
  local gestures = self.recognizer:processTouchEvent(e4)

  luaunit.assertNotNil(gestures, "Should detect gesture on second tap")
  local foundDoubleTap = false
  for _, g in ipairs(gestures) do
    if g.type == "double_tap" then foundDoubleTap = true end
  end
  luaunit.assertTrue(foundDoubleTap, "Should detect double-tap gesture")
end

function TestTouchGestureRecognizer:test_double_tap_not_detected_when_too_slow()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t1", 100, 100, "ended", 0.05)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t2", 100, 100, "began", 0.5)
  self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 100, 100, "ended", 0.55)
  local gestures = self.recognizer:processTouchEvent(e4)

  if gestures then
    for _, g in ipairs(gestures) do
      luaunit.assertNotEquals(g.type, "double_tap", "Too-slow second tap should not be double-tap")
    end
  end
end

-- Pan tests

function TestTouchGestureRecognizer:test_pan_began()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 110, 110, "moved", 0.05)
  local gestures = self.recognizer:processTouchEvent(e2)

  luaunit.assertNotNil(gestures, "Pan should be detected")
  luaunit.assertEquals(gestures[1].type, "pan")
  luaunit.assertEquals(gestures[1].state, "began")
end

function TestTouchGestureRecognizer:test_pan_changed()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 110, 110, "moved", 0.05)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 120, 120, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local panChanged = nil
  for _, g in ipairs(gestures) do
    if g.type == "pan" and g.state == "changed" then panChanged = g end
  end
  luaunit.assertNotNil(panChanged, "Should detect pan changed")
  luaunit.assertEquals(panChanged.dx, 20)
  luaunit.assertEquals(panChanged.dy, 20)
end

function TestTouchGestureRecognizer:test_pan_ended()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 110, 110, "moved", 0.05)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 120, 120, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local panEnded = nil
  for _, g in ipairs(gestures) do
    if g.type == "pan" and g.state == "ended" then panEnded = g end
  end
  luaunit.assertNotNil(panEnded, "Should detect pan ended")
end

function TestTouchGestureRecognizer:test_pan_not_detected_with_small_movement()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 102, 102, "moved", 0.05)
  local gestures = self.recognizer:processTouchEvent(e2)

  luaunit.assertNil(gestures, "Small movement should not trigger pan")
end

-- Swipe tests

function TestTouchGestureRecognizer:test_swipe_right()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 200, 100, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 200, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then swipe = g end
  end
  luaunit.assertNotNil(swipe, "Should detect swipe")
  luaunit.assertEquals(swipe.direction, "right")
end

function TestTouchGestureRecognizer:test_swipe_left()
  local e1 = touchEvent("t1", 200, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 100, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then swipe = g end
  end
  luaunit.assertNotNil(swipe, "Should detect left swipe")
  luaunit.assertEquals(swipe.direction, "left")
end

function TestTouchGestureRecognizer:test_swipe_down()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 200, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 100, 200, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then swipe = g end
  end
  luaunit.assertNotNil(swipe, "Should detect down swipe")
  luaunit.assertEquals(swipe.direction, "down")
end

function TestTouchGestureRecognizer:test_swipe_up()
  local e1 = touchEvent("t1", 100, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 100, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then swipe = g end
  end
  luaunit.assertNotNil(swipe, "Should detect up swipe")
  luaunit.assertEquals(swipe.direction, "up")
end

function TestTouchGestureRecognizer:test_swipe_not_detected_when_too_slow()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 200, 100, "moved", 0.3)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 200, 100, "ended", 0.3)
  local gestures = self.recognizer:processTouchEvent(e3)

  if gestures then
    for _, g in ipairs(gestures) do
      luaunit.assertNotEquals(g.type, "swipe", "Slow movement should not be a swipe")
    end
  end
end

function TestTouchGestureRecognizer:test_swipe_not_detected_when_too_short()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 130, 100, "moved", 0.05)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 130, 100, "ended", 0.05)
  local gestures = self.recognizer:processTouchEvent(e3)

  if gestures then
    for _, g in ipairs(gestures) do
      luaunit.assertNotEquals(g.type, "swipe", "Short movement should not be a swipe")
    end
  end
end

-- Pinch tests

function TestTouchGestureRecognizer:test_pinch_detected()
  local e1 = touchEvent("t1", 100, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t2", 200, 200, "began", 0)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 50, 200, "moved", 0.1)
  self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 250, 200, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e4)

  luaunit.assertNotNil(gestures, "Pinch should be detected")
  local pinch = nil
  for _, g in ipairs(gestures) do
    if g.type == "pinch" then pinch = g end
  end
  luaunit.assertNotNil(pinch, "Should detect pinch gesture")
  luaunit.assertTrue(pinch.scale > 1.0, "Scale should be greater than 1.0 for spread")
end

function TestTouchGestureRecognizer:test_pinch_scale_decreases()
  local e1 = touchEvent("t1", 50, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t2", 250, 200, "began", 0)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 100, 200, "moved", 0.1)
  self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 200, 200, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e4)

  if gestures then
    local pinch = nil
    for _, g in ipairs(gestures) do
      if g.type == "pinch" then pinch = g end
    end
    if pinch then
      luaunit.assertTrue(pinch.scale < 1.0, "Scale should be less than 1.0 for pinch")
    end
  end
end

function TestTouchGestureRecognizer:test_pinch_not_detected_with_one_touch()
  local e1 = touchEvent("t1", 100, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 150, 200, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e2)

  if gestures then
    for _, g in ipairs(gestures) do
      luaunit.assertNotEquals(g.type, "pinch", "Single touch should not trigger pinch")
    end
  end
end

-- Rotate tests

function TestTouchGestureRecognizer:test_rotate_detected()
  local e1 = touchEvent("t1", 100, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t2", 200, 200, "began", 0)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t2", 200, 150, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  if gestures then
    local rotate = nil
    for _, g in ipairs(gestures) do
      if g.type == "rotate" then rotate = g end
    end
    if rotate then
      luaunit.assertNotNil(rotate.rotation, "Rotate gesture should have rotation angle")
    end
  end
end

-- Return value tests

function TestTouchGestureRecognizer:test_processTouchEvent_returns_nil_for_no_gesture()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  local gestures = self.recognizer:processTouchEvent(e1)

  luaunit.assertNil(gestures, "Press alone should not produce gesture")
end

function TestTouchGestureRecognizer:test_processTouchEvent_returns_gesture_array()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e2)

  luaunit.assertNotNil(gestures)
  luaunit.assertTrue(#gestures >= 1, "Should return array with at least 1 gesture")
  luaunit.assertEquals(type(gestures[1]), "table")
  luaunit.assertNotNil(gestures[1].type)
end

function TestTouchGestureRecognizer:test_processTouchEvent_ignores_no_touchId()
  local event = { type = "touchpress", x = 100, y = 100 }
  local gestures = self.recognizer:processTouchEvent(event)
  luaunit.assertNil(gestures)
end

function TestTouchGestureRecognizer:test_touchcancel_cleans_up()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "cancelled", 0.1)
  self.recognizer:processTouchEvent(e2)

  luaunit.assertEquals(self.recognizer:_getTouchCount(), 0)
end

-- Reset tests

function TestTouchGestureRecognizer:test_reset_clears_state()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  luaunit.assertTrue(self.recognizer:_getTouchCount() > 0)

  self.recognizer:reset()

  luaunit.assertEquals(self.recognizer:_getTouchCount(), 0)
end

-- Config tests

function TestTouchGestureRecognizer:test_custom_config_overrides_defaults()
  local custom = GestureRecognizer.new({
    tapMaxDuration = 1.0,
    panMinMovement = 20,
  }, { InputEvent = InputEvent, utils = {} })

  luaunit.assertEquals(custom._config.tapMaxDuration, 1.0)
  luaunit.assertEquals(custom._config.panMinMovement, 20)
  luaunit.assertEquals(custom._config.swipeMinDistance, 50)
end

-- Type/state exports

function TestTouchGestureRecognizer:test_gesture_types_exported()
  luaunit.assertEquals(GestureRecognizer.GestureType.TAP, "tap")
  luaunit.assertEquals(GestureRecognizer.GestureType.DOUBLE_TAP, "double_tap")
  luaunit.assertEquals(GestureRecognizer.GestureType.LONG_PRESS, "long_press")
  luaunit.assertEquals(GestureRecognizer.GestureType.SWIPE, "swipe")
  luaunit.assertEquals(GestureRecognizer.GestureType.PAN, "pan")
  luaunit.assertEquals(GestureRecognizer.GestureType.PINCH, "pinch")
  luaunit.assertEquals(GestureRecognizer.GestureType.ROTATE, "rotate")
end

function TestTouchGestureRecognizer:test_gesture_states_exported()
  luaunit.assertEquals(GestureRecognizer.GestureState.POSSIBLE, "possible")
  luaunit.assertEquals(GestureRecognizer.GestureState.BEGAN, "began")
  luaunit.assertEquals(GestureRecognizer.GestureState.CHANGED, "changed")
  luaunit.assertEquals(GestureRecognizer.GestureState.ENDED, "ended")
  luaunit.assertEquals(GestureRecognizer.GestureState.CANCELLED, "cancelled")
  luaunit.assertEquals(GestureRecognizer.GestureState.FAILED, "failed")
end

-- ============================================================================
-- Touch Scroll: Press Tests
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

  sm:handleTouchPress(100, 200)
  sm._momentumScrolling = true
  sm._scrollVelocityY = 500

  sm:handleTouchPress(100, 200)

  luaunit.assertFalse(sm:isMomentumScrolling())
  luaunit.assertEquals(sm._scrollVelocityX, 0)
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

-- ============================================================================
-- Touch Scroll: Move Tests
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

  love.timer.step(1 / 60)
  local handled = sm:handleTouchMove(100, 150)

  luaunit.assertTrue(handled)
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
  sm:handleTouchMove(100, 100)

  luaunit.assertTrue(sm._scrollVelocityY > 0)
end

function TestTouchScrollMove:test_handleTouchMove_horizontal()
  local sm = createTouchScrollManager({
    bounceEnabled = false,
    overflowX = "scroll",
    overflowY = "hidden",
  })
  local el = createMockElement(200, 300, 600, 300)
  sm:detectOverflow(el)

  sm:handleTouchPress(200, 150)
  love.timer.step(1 / 60)
  sm:handleTouchMove(100, 150)

  luaunit.assertTrue(sm._scrollX > 0)
end

function TestTouchScrollMove:test_handleTouchMove_with_bounce_allows_overscroll()
  local sm = createTouchScrollManager({ bounceEnabled = true, maxOverscroll = 100 })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 100)
  love.timer.step(1 / 60)
  sm:handleTouchMove(100, 200)

  luaunit.assertTrue(sm._scrollY < 0)
end

-- ============================================================================
-- Touch Scroll: Release and Momentum Tests
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
  sm:handleTouchMove(100, 50)

  sm:handleTouchRelease()

  luaunit.assertTrue(sm:isMomentumScrolling())
end

function TestTouchScrollRelease:test_handleTouchRelease_no_momentum_with_low_velocity()
  local sm = createTouchScrollManager()
  local el = createMockElement()
  sm:detectOverflow(el)

  sm:handleTouchPress(100, 200)
  sm._scrollVelocityX = 0
  sm._scrollVelocityY = 10

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
-- Touch Scroll: Momentum Tests
-- ============================================================================

TestTouchScrollMomentum = {}

function TestTouchScrollMomentum:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollMomentum:test_momentum_decelerates_over_time()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm._momentumScrolling = true
  sm._scrollVelocityY = 200

  local initialVelocity = sm._scrollVelocityY

  sm:update(1 / 60)

  luaunit.assertTrue(sm._scrollVelocityY < initialVelocity)
  luaunit.assertTrue(sm._scrollVelocityY > 0)
end

function TestTouchScrollMomentum:test_momentum_stops_at_low_velocity()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm._momentumScrolling = true
  sm._scrollVelocityY = 200

  for i = 1, 500 do
    sm:update(1 / 60)
    if not sm:isMomentumScrolling() then break end
  end

  luaunit.assertFalse(sm:isMomentumScrolling())
  luaunit.assertEquals(sm._scrollVelocityY, 0)
end

function TestTouchScrollMomentum:test_momentum_moves_scroll_position()
  local sm = createTouchScrollManager({ bounceEnabled = false })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm._momentumScrolling = true
  sm._scrollVelocityY = 500

  local initialScrollY = sm._scrollY
  sm:update(1 / 60)

  luaunit.assertTrue(sm._scrollY > initialScrollY)
end

function TestTouchScrollMomentum:test_friction_coefficient_affects_deceleration()
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

  luaunit.assertTrue(smFast._scrollVelocityY > smSlow._scrollVelocityY)
end

-- ============================================================================
-- Touch Scroll: Bounce Tests
-- ============================================================================

TestTouchScrollBounce = {}

function TestTouchScrollBounce:setUp()
  love.timer.setTime(0)
end

function TestTouchScrollBounce:test_bounce_returns_to_boundary()
  local sm = createTouchScrollManager({ bounceEnabled = true })
  local el = createMockElement()
  sm:detectOverflow(el)

  sm._scrollY = -50

  for i = 1, 100 do
    sm:update(1 / 60)
  end

  luaunit.assertAlmostEquals(sm._scrollY, 0, 1)
end

function TestTouchScrollBounce:test_bounce_at_bottom_boundary()
  local sm = createTouchScrollManager({ bounceEnabled = true })
  local el = createMockElement()
  sm:detectOverflow(el)

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

  luaunit.assertEquals(sm._scrollY, -50)
end

-- ============================================================================
-- Touch Scroll: State Query Tests
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
-- Touch Scroll: Configuration Tests
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

-- ============================================================================
-- Touch Routing Tests
-- ============================================================================

TestTouchRouting = {}

function TestTouchRouting:setUp()
  FlexLove.setMode("immediate")
  love.window.setMode(800, 600)
end

function TestTouchRouting:tearDown()
  FlexLove.destroy()
  love.touch.getTouches = function() return {} end
  love.touch.getPosition = function() return 0, 0 end
end

function TestTouchRouting:test_touchpressed_routes_to_element()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#touchEvents >= 1, "Should receive touchpress event")
  luaunit.assertEquals(touchEvents[1].type, "touchpress")
  luaunit.assertEquals(touchEvents[1].touchId, "touch1")
  luaunit.assertEquals(touchEvents[1].x, 100)
  luaunit.assertEquals(touchEvents[1].y, 100)
end

function TestTouchRouting:test_touchmoved_routes_to_owner()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  FlexLove.touchmoved("touch1", 150, 150, 50, 50, 1.0)

  local moveEvents = {}
  for _, e in ipairs(touchEvents) do
    if e.type == "touchmove" then table.insert(moveEvents, e) end
  end

  luaunit.assertTrue(#moveEvents >= 1, "Should receive touchmove event")
  luaunit.assertEquals(moveEvents[1].x, 150)
  luaunit.assertEquals(moveEvents[1].y, 150)
end

function TestTouchRouting:test_touchreleased_routes_and_cleans_up()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNotNil(FlexLove.getTouchOwner("touch1"), "Touch should be owned")

  FlexLove.touchreleased("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "Touch ownership should be cleaned up")

  local releaseEvents = {}
  for _, e in ipairs(touchEvents) do
    if e.type == "touchrelease" then table.insert(releaseEvents, e) end
  end

  luaunit.assertTrue(#releaseEvents >= 1, "Should receive touchrelease event")
end

function TestTouchRouting:test_touch_ownership_persists_outside_bounds()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  FlexLove.touchmoved("touch1", 500, 500, 400, 400, 1.0)

  local moveEvents = {}
  for _, e in ipairs(touchEvents) do
    if e.type == "touchmove" then table.insert(moveEvents, e) end
  end

  luaunit.assertTrue(#moveEvents >= 1, "Move event should route to owner even outside bounds")
  luaunit.assertEquals(moveEvents[1].x, 500)
  luaunit.assertEquals(moveEvents[1].y, 500)
end

function TestTouchRouting:test_touch_outside_elements_no_ownership()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 100,
    height = 100,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 500, 500, 0, 0, 1.0)

  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "No element should own touch outside bounds")
  luaunit.assertEquals(#touchEvents, 0, "No events should fire for touch outside bounds")
end

function TestTouchRouting:test_multi_touch_different_elements()
  FlexLove.beginFrame()
  local events1 = {}
  local events2 = {}
  local container = FlexLove.new({
    width = 400,
    height = 200,
  })
  local element1 = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(events1, event)
    end,
    parent = container,
  })
  local element2 = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(events2, event)
    end,
    parent = container,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 50, 100, 0, 0, 1.0)
  FlexLove.touchpressed("touch2", 300, 100, 0, 0, 1.0)

  luaunit.assertTrue(#events1 >= 1, "Element1 should receive touch event")
  luaunit.assertTrue(#events2 >= 1, "Element2 should receive touch event")
  luaunit.assertEquals(events1[1].touchId, "touch1")
  luaunit.assertEquals(events2[1].touchId, "touch2")
end

function TestTouchRouting:test_z_index_ordering()
  FlexLove.beginFrame()
  local eventsLow = {}
  local eventsHigh = {}
  local low = FlexLove.new({
    width = 200,
    height = 200,
    z = 1,
    onTouchEvent = function(el, event)
      table.insert(eventsLow, event)
    end,
  })
  local high = FlexLove.new({
    width = 200,
    height = 200,
    z = 10,
    onTouchEvent = function(el, event)
      table.insert(eventsHigh, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#eventsHigh >= 1, "Higher z element should receive touch")
  luaunit.assertEquals(#eventsLow, 0, "Lower z element should NOT receive touch")
end

function TestTouchRouting:test_disabled_element_no_touch()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    disabled = true,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertEquals(#touchEvents, 0, "Disabled element should not receive touch events")
  luaunit.assertNil(FlexLove.getTouchOwner("touch1"))
end

function TestTouchRouting:test_getActiveTouchCount()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 800,
    height = 600,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 1)

  FlexLove.touchpressed("touch2", 200, 200, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 2)

  FlexLove.touchreleased("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 1)

  FlexLove.touchreleased("touch2", 200, 200, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)
end

function TestTouchRouting:test_getTouchOwner()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    id = "owner-test",
    width = 200,
    height = 200,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertNil(FlexLove.getTouchOwner("touch1"))

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  local owner = FlexLove.getTouchOwner("touch1")
  luaunit.assertNotNil(owner)
  luaunit.assertEquals(owner.id, "owner-test")
end

function TestTouchRouting:test_destroy_cleans_touch_state()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 1)

  FlexLove.destroy()
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)
end

function TestTouchRouting:test_onEvent_receives_touch_events()
  FlexLove.beginFrame()
  local allEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(allEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  local touchPressEvents = {}
  for _, e in ipairs(allEvents) do
    if e.type == "touchpress" then table.insert(touchPressEvents, e) end
  end

  luaunit.assertTrue(#touchPressEvents >= 1, "onEvent should receive touchpress events")
end

function TestTouchRouting:test_gesture_routing()
  FlexLove.beginFrame()
  local gestureEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
    onGesture = function(el, gesture)
      table.insert(gestureEvents, gesture)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  love.timer.step(0.05)
  FlexLove.touchreleased("touch1", 100, 100, 0, 0, 1.0)

  local tapGestures = {}
  for _, g in ipairs(gestureEvents) do
    if g.type == "tap" then table.insert(tapGestures, g) end
  end

  luaunit.assertTrue(#tapGestures >= 1, "Should detect tap gesture from press+release")
end

function TestTouchRouting:test_element_with_only_onGesture()
  FlexLove.beginFrame()
  local gestureEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onGesture = function(el, gesture)
      table.insert(gestureEvents, gesture)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNotNil(FlexLove.getTouchOwner("touch1"), "Element with onGesture should be found")
end

function TestTouchRouting:test_touchEnabled_false_prevents_routing()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    touchEnabled = false,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "touchEnabled=false should prevent ownership")
  luaunit.assertEquals(#touchEvents, 0, "touchEnabled=false should prevent events")
end

function TestTouchRouting:test_full_lifecycle()
  FlexLove.beginFrame()
  local phases = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(phases, event.type)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  FlexLove.touchmoved("touch1", 110, 110, 10, 10, 1.0)
  FlexLove.touchmoved("touch1", 120, 120, 10, 10, 1.0)
  FlexLove.touchreleased("touch1", 120, 120, 0, 0, 1.0)

  luaunit.assertEquals(phases[1], "touchpress")
  luaunit.assertEquals(phases[2], "touchmove")
  luaunit.assertEquals(phases[3], "touchmove")
  luaunit.assertEquals(phases[4], "touchrelease")
  luaunit.assertEquals(#phases, 4)
end

function TestTouchRouting:test_orphaned_move_release_no_crash()
  FlexLove.touchmoved("ghost_touch", 100, 100, 0, 0, 1.0)
  FlexLove.touchreleased("ghost_touch", 100, 100, 0, 0, 1.0)

  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)
end

function TestTouchRouting:test_pressure_passthrough()
  FlexLove.beginFrame()
  local receivedPressure = nil
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      if event.type == "touchpress" then
        receivedPressure = event.pressure
      end
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 0.75)
  luaunit.assertAlmostEquals(receivedPressure, 0.75, 0.01)
end

function TestTouchRouting:test_retained_mode_routing()
  FlexLove.setMode("retained")

  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#touchEvents >= 1, "Touch routing should work in retained mode")
  luaunit.assertEquals(touchEvents[1].type, "touchpress")
end

function TestTouchRouting:test_child_receives_touch_over_parent()
  FlexLove.beginFrame()
  local parentEvents = {}
  local childEvents = {}
  local parent = FlexLove.new({
    width = 400,
    height = 400,
    onTouchEvent = function(el, event)
      table.insert(parentEvents, event)
    end,
  })
  local child = FlexLove.new({
    width = 200,
    height = 200,
    z = 1,
    onTouchEvent = function(el, event)
      table.insert(childEvents, event)
    end,
    parent = parent,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#childEvents >= 1,
    string.format("Child should receive touch (child=%d, parent=%d, topElements=%d)",
      #childEvents, #parentEvents, #FlexLove.topElements))
end

function TestTouchRouting:test_non_interactive_element_ignored()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "Non-interactive element should not capture touch")
end

-- ============================================================================
-- Element Touch Property Tests
-- ============================================================================

TestTouchElementProps = {}

function TestTouchElementProps:setUp()
  FlexLove.setMode("immediate")
  love.window.setMode(800, 600)
end

function TestTouchElementProps:tearDown()
  FlexLove.destroy()
end

function TestTouchElementProps:test_touchEnabled_defaults_true()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100 })
  FlexLove.endFrame()

  luaunit.assertTrue(element.touchEnabled)
end

function TestTouchElementProps:test_touchEnabled_can_be_set_false()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100, touchEnabled = false })
  FlexLove.endFrame()

  luaunit.assertFalse(element.touchEnabled)
end

function TestTouchElementProps:test_multiTouchEnabled_defaults_false()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100 })
  FlexLove.endFrame()

  luaunit.assertFalse(element.multiTouchEnabled)
end

function TestTouchElementProps:test_multiTouchEnabled_can_be_set_true()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100, multiTouchEnabled = true })
  FlexLove.endFrame()

  luaunit.assertTrue(element.multiTouchEnabled)
end

-- ============================================================================
-- Element Touch Callback Tests
-- ============================================================================

TestTouchElementCallbacks = {}

function TestTouchElementCallbacks:setUp()
  FlexLove.setMode("immediate")
  love.window.setMode(800, 600)
end

function TestTouchElementCallbacks:tearDown()
  FlexLove.destroy()
end

function TestTouchElementCallbacks:test_onTouchEvent_callback()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#receivedEvents >= 1)
  luaunit.assertEquals(receivedEvents[1].type, "touchpress")
end

function TestTouchElementCallbacks:test_onGesture_callback()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)
  love.timer.step(0.05)
  FlexLove.touchreleased("t1", 100, 100, 0, 0, 1.0)

  local tapGestures = {}
  for _, g in ipairs(receivedGestures) do
    if g.type == "tap" then table.insert(tapGestures, g) end
  end
  luaunit.assertTrue(#tapGestures >= 1, "Should receive tap gesture callback")
end

function TestTouchElementCallbacks:test_onEvent_also_receives_touch()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)

  local touchEvents = {}
  for _, e in ipairs(receivedEvents) do
    if e.type == "touchpress" then table.insert(touchEvents, e) end
  end
  luaunit.assertTrue(#touchEvents >= 1, "onEvent should receive touch events")
end

-- ============================================================================
-- Element handleTouchEvent Direct Tests
-- ============================================================================

TestTouchElementDirect = {}

function TestTouchElementDirect:setUp()
  FlexLove.setMode("immediate")
  love.window.setMode(800, 600)
end

function TestTouchElementDirect:tearDown()
  FlexLove.destroy()
end

function TestTouchElementDirect:test_handleTouchEvent_disabled_element()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    disabled = true,
    onTouchEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  local touchEvt = InputEvent.fromTouch("t1", 100, 100, "began", 1.0)
  element:handleTouchEvent(touchEvt)

  luaunit.assertEquals(#receivedEvents, 0, "Disabled element should not receive touch events")
end

function TestTouchElementDirect:test_handleTouchEvent_touchEnabled_false()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    touchEnabled = false,
    onTouchEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  local touchEvt = InputEvent.fromTouch("t1", 100, 100, "began", 1.0)
  element:handleTouchEvent(touchEvt)

  luaunit.assertEquals(#receivedEvents, 0, "touchEnabled=false should prevent events")
end

function TestTouchElementDirect:test_handleGesture_fires_callback()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  element:handleGesture({ type = "tap", state = "ended", x = 100, y = 100 })

  luaunit.assertEquals(#receivedGestures, 1)
  luaunit.assertEquals(receivedGestures[1].type, "tap")
end

function TestTouchElementDirect:test_handleGesture_disabled_element()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    disabled = true,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  element:handleGesture({ type = "tap", state = "ended", x = 100, y = 100 })

  luaunit.assertEquals(#receivedGestures, 0, "Disabled element should not receive gestures")
end

function TestTouchElementDirect:test_handleGesture_touchEnabled_false()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    touchEnabled = false,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  element:handleGesture({ type = "tap", state = "ended", x = 100, y = 100 })

  luaunit.assertEquals(#receivedGestures, 0, "touchEnabled=false should prevent gestures")
end

function TestTouchElementDirect:test_getTouches_returns_table()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  local touches = element:getTouches()
  luaunit.assertEquals(type(touches), "table")
end

function TestTouchElementDirect:test_touch_pan_lifecycle()
  FlexLove.beginFrame()
  local touchEvents = {}
  local gestureEvents = {}
  local element = FlexLove.new({
    width = 400,
    height = 400,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
    onGesture = function(el, gesture)
      table.insert(gestureEvents, gesture)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)
  love.timer.step(0.05)
  FlexLove.touchmoved("t1", 150, 150, 50, 50, 1.0)
  love.timer.step(0.05)
  FlexLove.touchmoved("t1", 200, 200, 50, 50, 1.0)
  love.timer.step(0.05)
  FlexLove.touchreleased("t1", 200, 200, 0, 0, 1.0)

  luaunit.assertTrue(#touchEvents >= 3, "Should receive press + move + release touch events")

  local panGestures = {}
  for _, g in ipairs(gestureEvents) do
    if g.type == "pan" then table.insert(panGestures, g) end
  end
  luaunit.assertTrue(#panGestures >= 1, "Should receive pan gesture events")
end

function TestTouchElementDirect:test_onTouchEventDeferred_prop_accepted()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEventDeferred = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertNotNil(element, "Element with onTouchEventDeferred should be created")
end

function TestTouchElementDirect:test_onGestureDeferred_prop_accepted()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onGestureDeferred = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertNotNil(element, "Element with onGestureDeferred should be created")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
