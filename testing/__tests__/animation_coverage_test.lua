-- Advanced test suite for Animation.lua to increase coverage
-- Focuses on uncovered edge cases, error handling, and complex scenarios

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

-- Load FlexLove which properly initializes all dependencies
local FlexLove = require("FlexLove")

-- Initialize FlexLove
FlexLove.init()

local Animation = FlexLove.Animation

-- Test suite for Animation error handling and validation
TestAnimationValidation = {}

function TestAnimationValidation:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationValidation:tearDown()
  FlexLove.endFrame()
end

function TestAnimationValidation:test_new_with_invalid_props()
  -- Should handle non-table props gracefully
  local anim = Animation.new(nil)
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(anim.duration, 1)

  local anim2 = Animation.new("invalid")
  luaunit.assertNotNil(anim2)
  luaunit.assertEquals(anim2.duration, 1)
end

function TestAnimationValidation:test_new_with_invalid_duration()
  -- Negative duration
  local anim = Animation.new({
    duration = -1,
    start = { x = 0 },
    final = { x = 100 },
  })
  luaunit.assertEquals(anim.duration, 1) -- Should default to 1

  -- Zero duration
  local anim2 = Animation.new({
    duration = 0,
    start = { x = 0 },
    final = { x = 100 },
  })
  luaunit.assertEquals(anim2.duration, 1)

  -- Non-number duration
  local anim3 = Animation.new({
    duration = "invalid",
    start = { x = 0 },
    final = { x = 100 },
  })
  luaunit.assertEquals(anim3.duration, 1)
end

function TestAnimationValidation:test_new_with_invalid_start_final()
  -- Invalid start table
  local anim = Animation.new({
    duration = 1,
    start = "invalid",
    final = { x = 100 },
  })
  luaunit.assertEquals(type(anim.start), "table")

  -- Invalid final table
  local anim2 = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = "invalid",
  })
  luaunit.assertEquals(type(anim2.final), "table")
end

function TestAnimationValidation:test_easing_string_and_function()
  -- Valid easing string
  local anim = Animation.new({
    duration = 1,
    easing = "easeInQuad",
    start = { x = 0 },
    final = { x = 100 },
  })
  luaunit.assertEquals(type(anim.easing), "function")

  -- Invalid easing string (should default to linear)
  local anim2 = Animation.new({
    duration = 1,
    easing = "invalidEasing",
    start = { x = 0 },
    final = { x = 100 },
  })
  luaunit.assertEquals(type(anim2.easing), "function")

  -- Custom easing function
  local customEasing = function(t)
    return t * t
  end
  local anim3 = Animation.new({
    duration = 1,
    easing = customEasing,
    start = { x = 0 },
    final = { x = 100 },
  })
  luaunit.assertEquals(anim3.easing, customEasing)
end

-- Test suite for Animation update with edge cases
TestAnimationUpdate = {}

function TestAnimationUpdate:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationUpdate:tearDown()
  FlexLove.endFrame()
end

function TestAnimationUpdate:test_update_with_invalid_dt()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  -- Negative dt
  anim:update(-1)
  luaunit.assertEquals(anim.elapsed, 0)

  -- NaN dt
  anim:update(0 / 0)
  luaunit.assertEquals(anim.elapsed, 0)

  -- Infinite dt
  anim:update(math.huge)
  luaunit.assertEquals(anim.elapsed, 0)

  -- String dt (non-number)
  anim:update("invalid")
  luaunit.assertEquals(anim.elapsed, 0)
end

function TestAnimationUpdate:test_update_while_paused()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:pause()
  local complete = anim:update(0.5)

  luaunit.assertFalse(complete)
  luaunit.assertEquals(anim.elapsed, 0)
end

function TestAnimationUpdate:test_callbacks()
  local onStartCalled = false
  local onUpdateCalled = false
  local onCompleteCalled = false

  local anim = Animation.new({
    duration = 0.1,
    start = { x = 0 },
    final = { x = 100 },
    onStart = function()
      onStartCalled = true
    end,
    onUpdate = function()
      onUpdateCalled = true
    end,
    onComplete = function()
      onCompleteCalled = true
    end,
  })

  -- First update should trigger onStart
  anim:update(0.05)
  luaunit.assertTrue(onStartCalled)
  luaunit.assertTrue(onUpdateCalled)
  luaunit.assertFalse(onCompleteCalled)

  -- Complete the animation
  anim:update(0.1)
  luaunit.assertTrue(onCompleteCalled)
end

function TestAnimationUpdate:test_onCancel_callback()
  local onCancelCalled = false

  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
    onCancel = function()
      onCancelCalled = true
    end,
  })

  anim:update(0.5)
  anim:cancel()

  luaunit.assertTrue(onCancelCalled)
end

-- Test suite for Animation state control
TestAnimationStateControl = {}

function TestAnimationStateControl:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationStateControl:tearDown()
  FlexLove.endFrame()
end

function TestAnimationStateControl:test_pause_resume()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:update(0.5)
  local elapsed1 = anim.elapsed

  anim:pause()
  anim:update(0.5)
  luaunit.assertEquals(anim.elapsed, elapsed1) -- Should not advance

  anim:resume()
  anim:update(0.1)
  luaunit.assertTrue(anim.elapsed > elapsed1) -- Should advance
end

function TestAnimationStateControl:test_reverse()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:update(0.5)
  anim:reverse()

  luaunit.assertTrue(anim._reversed)

  -- Continue updating - it should go backwards
  anim:update(0.3)
  luaunit.assertTrue(anim.elapsed < 0.5)
end

function TestAnimationStateControl:test_setSpeed()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:setSpeed(2.0)
  luaunit.assertEquals(anim._speed, 2.0)

  -- Update with 0.1 seconds at 2x speed should advance 0.2 seconds
  anim:update(0.1)
  luaunit.assertAlmostEquals(anim.elapsed, 0.2, 0.01)
end

function TestAnimationStateControl:test_reset()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:update(0.7)
  luaunit.assertTrue(anim.elapsed > 0)

  anim:reset()
  luaunit.assertEquals(anim.elapsed, 0)
  luaunit.assertFalse(anim._hasStarted)
end

function TestAnimationStateControl:test_isPaused_isComplete()
  local anim = Animation.new({
    duration = 0.5,
    start = { x = 0 },
    final = { x = 100 },
  })

  luaunit.assertFalse(anim:isPaused())

  anim:pause()
  luaunit.assertTrue(anim:isPaused())

  anim:resume()
  luaunit.assertFalse(anim:isPaused())

  local complete = anim:update(1.0) -- Complete it
  luaunit.assertTrue(complete)
  luaunit.assertEquals(anim:getState(), "completed")
end

-- Test suite for delay functionality
TestAnimationDelay = {}

function TestAnimationDelay:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationDelay:tearDown()
  FlexLove.endFrame()
end

function TestAnimationDelay:test_delay()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:delay(0.5)

  -- Update during delay - animation should not start yet
  local result = anim:update(0.3)
  luaunit.assertFalse(result)
  luaunit.assertEquals(anim:getState(), "pending")

  -- Update past delay - animation should be ready to start
  anim:update(0.3) -- Now delay elapsed is > 0.5
  luaunit.assertEquals(anim:getState(), "pending") -- Still pending until next update

  -- One more update to actually start
  anim:update(0.01)
  luaunit.assertEquals(anim:getState(), "playing")
end

-- Run all tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
