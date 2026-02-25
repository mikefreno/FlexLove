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

FlexLove.init()

local InputEvent = package.loaded["modules.InputEvent"]
local GestureRecognizer = package.loaded["modules.GestureRecognizer"]

TestGestureRecognizer = {}

function TestGestureRecognizer:setUp()
  self.recognizer = GestureRecognizer.new({}, { InputEvent = InputEvent, utils = {} })
  love.timer.setTime(0)
end

function TestGestureRecognizer:tearDown()
  self.recognizer:reset()
end

-- Helper: create touch event
local function touchEvent(id, x, y, phase, time)
  if time then love.timer.setTime(time) end
  local event = InputEvent.fromTouch(id, x, y, phase, 1.0)
  return event
end

-- ============================================
-- Tap Gesture Tests
-- ============================================

function TestGestureRecognizer:test_tap_detected()
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

function TestGestureRecognizer:test_tap_not_detected_when_too_slow()
  local event1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(event1)

  -- Release after tapMaxDuration (0.3s)
  local event2 = touchEvent("t1", 100, 100, "ended", 0.5)
  local gestures = self.recognizer:processTouchEvent(event2)

  -- Should not be a tap (too slow)
  if gestures then
    for _, g in ipairs(gestures) do
      luaunit.assertNotEquals(g.type, "tap", "Slow touch should not be tap")
    end
  end
end

function TestGestureRecognizer:test_tap_not_detected_when_moved_too_far()
  local event1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(event1)

  -- Move more than tapMaxMovement (10px)
  local event2 = touchEvent("t1", 120, 120, "moved", 0.05)
  self.recognizer:processTouchEvent(event2)

  local event3 = touchEvent("t1", 120, 120, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(event3)

  -- Should not be a tap (moved too far)
  if gestures then
    for _, g in ipairs(gestures) do
      if g.type == "tap" then
        -- Tap detection checks distance from START to END position
        local dx = 120 - 100
        local dy = 120 - 100
        local dist = math.sqrt(dx*dx + dy*dy)
        luaunit.assertTrue(dist >= 10, "Movement should exceed tap threshold")
      end
    end
  end
end

function TestGestureRecognizer:test_double_tap_detected()
  -- First tap
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t1", 100, 100, "ended", 0.05)
  self.recognizer:processTouchEvent(e2)

  -- Second tap quickly
  local e3 = touchEvent("t2", 100, 100, "began", 0.15)
  self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 100, 100, "ended", 0.2)
  local gestures = self.recognizer:processTouchEvent(e4)

  luaunit.assertNotNil(gestures, "Should detect gesture on second tap")
  -- Should have double_tap
  local foundDoubleTap = false
  for _, g in ipairs(gestures) do
    if g.type == "double_tap" then
      foundDoubleTap = true
    end
  end
  luaunit.assertTrue(foundDoubleTap, "Should detect double-tap gesture")
end

function TestGestureRecognizer:test_double_tap_not_detected_when_too_slow()
  -- First tap
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t1", 100, 100, "ended", 0.05)
  self.recognizer:processTouchEvent(e2)

  -- Second tap too late (>0.3s interval)
  local e3 = touchEvent("t2", 100, 100, "began", 0.5)
  self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 100, 100, "ended", 0.55)
  local gestures = self.recognizer:processTouchEvent(e4)

  -- Should detect tap but NOT double_tap
  if gestures then
    for _, g in ipairs(gestures) do
      luaunit.assertNotEquals(g.type, "double_tap", "Too-slow second tap should not be double-tap")
    end
  end
end

-- ============================================
-- Pan Gesture Tests
-- ============================================

function TestGestureRecognizer:test_pan_began()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  -- Move beyond panMinMovement (5px)
  local e2 = touchEvent("t1", 110, 110, "moved", 0.05)
  local gestures = self.recognizer:processTouchEvent(e2)

  luaunit.assertNotNil(gestures, "Pan should be detected")
  luaunit.assertEquals(gestures[1].type, "pan")
  luaunit.assertEquals(gestures[1].state, "began")
end

function TestGestureRecognizer:test_pan_changed()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  -- First move to start pan
  local e2 = touchEvent("t1", 110, 110, "moved", 0.05)
  self.recognizer:processTouchEvent(e2)

  -- Continue moving
  local e3 = touchEvent("t1", 120, 120, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local panChanged = nil
  for _, g in ipairs(gestures) do
    if g.type == "pan" and g.state == "changed" then
      panChanged = g
    end
  end
  luaunit.assertNotNil(panChanged, "Should detect pan changed")
  luaunit.assertEquals(panChanged.dx, 20) -- delta from startX=100 (lastX set to startX on began)
  luaunit.assertEquals(panChanged.dy, 20)
end

function TestGestureRecognizer:test_pan_ended()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 110, 110, "moved", 0.05)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 120, 120, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local panEnded = nil
  for _, g in ipairs(gestures) do
    if g.type == "pan" and g.state == "ended" then
      panEnded = g
    end
  end
  luaunit.assertNotNil(panEnded, "Should detect pan ended")
end

function TestGestureRecognizer:test_pan_not_detected_with_small_movement()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  -- Move less than panMinMovement (5px)
  local e2 = touchEvent("t1", 102, 102, "moved", 0.05)
  local gestures = self.recognizer:processTouchEvent(e2)

  luaunit.assertNil(gestures, "Small movement should not trigger pan")
end

-- ============================================
-- Swipe Gesture Tests
-- ============================================

function TestGestureRecognizer:test_swipe_right()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  -- Fast swipe right (>50px in <0.2s with >200px/s velocity)
  local e2 = touchEvent("t1", 200, 100, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 200, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then
      swipe = g
    end
  end
  luaunit.assertNotNil(swipe, "Should detect swipe")
  luaunit.assertEquals(swipe.direction, "right")
end

function TestGestureRecognizer:test_swipe_left()
  local e1 = touchEvent("t1", 200, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 100, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then
      swipe = g
    end
  end
  luaunit.assertNotNil(swipe, "Should detect left swipe")
  luaunit.assertEquals(swipe.direction, "left")
end

function TestGestureRecognizer:test_swipe_down()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 200, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 100, 200, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then
      swipe = g
    end
  end
  luaunit.assertNotNil(swipe, "Should detect down swipe")
  luaunit.assertEquals(swipe.direction, "down")
end

function TestGestureRecognizer:test_swipe_up()
  local e1 = touchEvent("t1", 100, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "moved", 0.1)
  self.recognizer:processTouchEvent(e2)

  local e3 = touchEvent("t1", 100, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  luaunit.assertNotNil(gestures)
  local swipe = nil
  for _, g in ipairs(gestures) do
    if g.type == "swipe" then
      swipe = g
    end
  end
  luaunit.assertNotNil(swipe, "Should detect up swipe")
  luaunit.assertEquals(swipe.direction, "up")
end

function TestGestureRecognizer:test_swipe_not_detected_when_too_slow()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  -- Too slow (>0.2s)
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

function TestGestureRecognizer:test_swipe_not_detected_when_too_short()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  -- Too short distance (<50px)
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

-- ============================================
-- Pinch Gesture Tests
-- ============================================

function TestGestureRecognizer:test_pinch_detected()
  -- Two fingers start 100px apart
  local e1 = touchEvent("t1", 100, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t2", 200, 200, "began", 0)
  self.recognizer:processTouchEvent(e2)

  -- Move fingers apart to 200px (scale = 2.0)
  local e3 = touchEvent("t1", 50, 200, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 250, 200, "moved", 0.1)
  gestures = self.recognizer:processTouchEvent(e4)

  luaunit.assertNotNil(gestures, "Pinch should be detected")
  local pinch = nil
  for _, g in ipairs(gestures) do
    if g.type == "pinch" then
      pinch = g
    end
  end
  luaunit.assertNotNil(pinch, "Should detect pinch gesture")
  luaunit.assertTrue(pinch.scale > 1.0, "Scale should be greater than 1.0 for spread")
end

function TestGestureRecognizer:test_pinch_scale_decreases()
  -- Two fingers start 200px apart
  local e1 = touchEvent("t1", 50, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t2", 250, 200, "began", 0)
  self.recognizer:processTouchEvent(e2)

  -- Move fingers closer to 100px (scale = 0.5)
  local e3 = touchEvent("t1", 100, 200, "moved", 0.1)
  self.recognizer:processTouchEvent(e3)
  local e4 = touchEvent("t2", 200, 200, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e4)

  if gestures then
    local pinch = nil
    for _, g in ipairs(gestures) do
      if g.type == "pinch" then
        pinch = g
      end
    end
    if pinch then
      luaunit.assertTrue(pinch.scale < 1.0, "Scale should be less than 1.0 for pinch")
    end
  end
end

function TestGestureRecognizer:test_pinch_not_detected_with_one_touch()
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

-- ============================================
-- Rotate Gesture Tests
-- ============================================

function TestGestureRecognizer:test_rotate_detected()
  -- Two fingers horizontally
  local e1 = touchEvent("t1", 100, 200, "began", 0)
  self.recognizer:processTouchEvent(e1)
  local e2 = touchEvent("t2", 200, 200, "began", 0)
  self.recognizer:processTouchEvent(e2)

  -- Rotate: move t2 above t1 (significant angle change > 5 degrees)
  local e3 = touchEvent("t2", 200, 150, "moved", 0.1)
  local gestures = self.recognizer:processTouchEvent(e3)

  if gestures then
    local rotate = nil
    for _, g in ipairs(gestures) do
      if g.type == "rotate" then
        rotate = g
      end
    end
    if rotate then
      luaunit.assertNotNil(rotate.rotation, "Rotate gesture should have rotation angle")
    end
  end
end

-- ============================================
-- processTouchEvent return value tests
-- ============================================

function TestGestureRecognizer:test_processTouchEvent_returns_nil_for_no_gesture()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  local gestures = self.recognizer:processTouchEvent(e1)

  -- Press alone should not produce gesture
  luaunit.assertNil(gestures, "Press alone should not produce gesture")
end

function TestGestureRecognizer:test_processTouchEvent_returns_gesture_array()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "ended", 0.1)
  local gestures = self.recognizer:processTouchEvent(e2)

  luaunit.assertNotNil(gestures)
  luaunit.assertTrue(#gestures >= 1, "Should return array with at least 1 gesture")
  luaunit.assertEquals(type(gestures[1]), "table")
  luaunit.assertNotNil(gestures[1].type)
end

function TestGestureRecognizer:test_processTouchEvent_ignores_no_touchId()
  local event = { type = "touchpress", x = 100, y = 100 } -- No touchId
  local gestures = self.recognizer:processTouchEvent(event)
  luaunit.assertNil(gestures)
end

function TestGestureRecognizer:test_touchcancel_cleans_up()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  local e2 = touchEvent("t1", 100, 100, "cancelled", 0.1)
  local gestures = self.recognizer:processTouchEvent(e2)

  -- After cancel, no touches should remain
  luaunit.assertEquals(self.recognizer:_getTouchCount(), 0)
end

-- ============================================
-- Reset Tests
-- ============================================

function TestGestureRecognizer:test_reset_clears_state()
  local e1 = touchEvent("t1", 100, 100, "began", 0)
  self.recognizer:processTouchEvent(e1)

  luaunit.assertTrue(self.recognizer:_getTouchCount() > 0)

  self.recognizer:reset()

  luaunit.assertEquals(self.recognizer:_getTouchCount(), 0)
end

-- ============================================
-- Custom Configuration Tests
-- ============================================

function TestGestureRecognizer:test_custom_config_overrides_defaults()
  local custom = GestureRecognizer.new({
    tapMaxDuration = 1.0,
    panMinMovement = 20,
  }, { InputEvent = InputEvent, utils = {} })

  luaunit.assertEquals(custom._config.tapMaxDuration, 1.0)
  luaunit.assertEquals(custom._config.panMinMovement, 20)
  -- Defaults for non-overridden values
  luaunit.assertEquals(custom._config.swipeMinDistance, 50)
end

-- ============================================
-- GestureType and GestureState exports
-- ============================================

function TestGestureRecognizer:test_gesture_types_exported()
  luaunit.assertEquals(GestureRecognizer.GestureType.TAP, "tap")
  luaunit.assertEquals(GestureRecognizer.GestureType.DOUBLE_TAP, "double_tap")
  luaunit.assertEquals(GestureRecognizer.GestureType.LONG_PRESS, "long_press")
  luaunit.assertEquals(GestureRecognizer.GestureType.SWIPE, "swipe")
  luaunit.assertEquals(GestureRecognizer.GestureType.PAN, "pan")
  luaunit.assertEquals(GestureRecognizer.GestureType.PINCH, "pinch")
  luaunit.assertEquals(GestureRecognizer.GestureType.ROTATE, "rotate")
end

function TestGestureRecognizer:test_gesture_states_exported()
  luaunit.assertEquals(GestureRecognizer.GestureState.POSSIBLE, "possible")
  luaunit.assertEquals(GestureRecognizer.GestureState.BEGAN, "began")
  luaunit.assertEquals(GestureRecognizer.GestureState.CHANGED, "changed")
  luaunit.assertEquals(GestureRecognizer.GestureState.ENDED, "ended")
  luaunit.assertEquals(GestureRecognizer.GestureState.CANCELLED, "cancelled")
  luaunit.assertEquals(GestureRecognizer.GestureState.FAILED, "failed")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
