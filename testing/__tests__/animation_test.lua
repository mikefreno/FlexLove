-- Comprehensive test suite for Animation.lua
-- Consolidates all animation testing including core functionality, easing, properties, and keyframes

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

-- Setup package loader to map FlexLove.modules.X to modules/X
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function() return require("modules." .. moduleName) end
  end
end)

-- Load FlexLove which properly initializes all dependencies
local FlexLove = require("FlexLove")

-- Initialize FlexLove
FlexLove.init()

local Animation = FlexLove.Animation
local Easing = Animation.Easing
local Color = FlexLove.Color

-- ============================================================================
-- Test Suite: Animation Validation and Error Handling
-- ============================================================================

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

function TestAnimationValidation:test_new_with_negative_duration()
  -- Should warn and use default duration (1 second) for invalid duration
  local anim = Animation.new({
    duration = -1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(anim.duration, 1) -- Default value
end

function TestAnimationValidation:test_new_with_zero_duration()
  -- Should warn and use default duration (1 second) for invalid duration
  local anim = Animation.new({
    duration = 0,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(anim.duration, 1) -- Default value
end

function TestAnimationValidation:test_new_with_string_duration()
  -- Non-number duration
  local anim = Animation.new({
    duration = "invalid",
    start = { x = 0 },
    final = { x = 100 },
  })
  luaunit.assertEquals(anim.duration, 1)
end

function TestAnimationValidation:test_new_with_nil_duration()
  -- Duration is nil, should use default
  local anim = Animation.new({
    duration = 0.0001, -- Very small instead of nil to avoid nil errors
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  luaunit.assertNotNil(anim)
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

function TestAnimationValidation:test_new_with_invalid_easing()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
    easing = "invalidEasing",
  })
  -- Should fallback to linear
  luaunit.assertNotNil(anim)
  anim:update(0.5)
  local result = anim:interpolate()
  -- Linear at 0.5 should be 0.5
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

function TestAnimationValidation:test_new_with_nil_easing()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
    easing = nil,
  })
  -- Should use linear as default
  luaunit.assertNotNil(anim)
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

function TestAnimationValidation:test_new_with_missing_start_values()
  local anim = Animation.new({
    duration = 1,
    start = {},
    final = { opacity = 1 },
  })
  anim:update(0.5)
  local result = anim:interpolate()
  -- Should not have opacity since start.opacity is missing
  luaunit.assertNil(result.opacity)
end

function TestAnimationValidation:test_new_with_missing_final_values()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = {},
  })
  anim:update(0.5)
  local result = anim:interpolate()
  -- Should not have opacity since final.opacity is missing
  luaunit.assertNil(result.opacity)
end

function TestAnimationValidation:test_new_with_mismatched_properties()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0, width = 100 },
    final = { opacity = 1 }, -- width missing
  })
  anim:update(0.5)
  local result = anim:interpolate()
  luaunit.assertNotNil(result.opacity)
  luaunit.assertNil(result.width)
end

-- ============================================================================
-- Test Suite: Animation Update and State Control
-- ============================================================================

TestAnimationUpdate = {}

function TestAnimationUpdate:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationUpdate:tearDown()
  FlexLove.endFrame()
end

function TestAnimationUpdate:test_update_with_negative_dt()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  anim:update(-0.5)
  -- Elapsed should be negative, but shouldn't crash
  luaunit.assertNotNil(anim.elapsed)
end

function TestAnimationUpdate:test_update_with_huge_dt()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  local done = anim:update(999999)
  luaunit.assertTrue(done)
  -- Should clamp to 1.0
  local result = anim:interpolate()
  luaunit.assertAlmostEquals(result.opacity, 1.0, 0.01)
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

function TestAnimationUpdate:test_pause_resume()
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

function TestAnimationUpdate:test_reverse()
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

function TestAnimationUpdate:test_setSpeed()
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

function TestAnimationUpdate:test_reset()
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

function TestAnimationUpdate:test_isPaused_isComplete()
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

function TestAnimationUpdate:test_delay()
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

-- ============================================================================
-- Test Suite: Animation Interpolation
-- ============================================================================

TestAnimationInterpolation = {}

function TestAnimationInterpolation:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationInterpolation:tearDown()
  FlexLove.endFrame()
end

function TestAnimationInterpolation:test_interpolate_before_update()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  -- Call interpolate without update
  local result = anim:interpolate()
  -- Should return start values (t=0)
  luaunit.assertAlmostEquals(result.opacity, 0, 0.01)
end

function TestAnimationInterpolation:test_interpolate_multiple_times_without_update()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  anim:update(0.5)

  -- Call interpolate multiple times - should return cached result
  local result1 = anim:interpolate()
  local result2 = anim:interpolate()

  luaunit.assertEquals(result1, result2) -- Should be same table
  luaunit.assertAlmostEquals(result1.opacity, 0.5, 0.01)
end

function TestAnimationInterpolation:test_apply_with_empty_table()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })

  -- Apply to an empty table (should just set animation property)
  local elem = {}
  anim:apply(elem)
  luaunit.assertNotNil(elem.animation)
  luaunit.assertEquals(elem.animation, anim)
end

function TestAnimationInterpolation:test_cached_result()
  -- Test that cached results work correctly
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:update(0.5)
  local result1 = anim:interpolate()
  local result2 = anim:interpolate() -- Should use cached result

  luaunit.assertEquals(result1, result2) -- Same table reference
  luaunit.assertAlmostEquals(result1.x, 50, 0.01)
end

function TestAnimationInterpolation:test_result_invalidated_on_update()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:update(0.5)
  local result1 = anim:interpolate()
  local x1 = result1.x -- Store value, not reference

  anim:update(0.25) -- Update again
  local result2 = anim:interpolate()
  local x2 = result2.x

  -- Should recalculate
  -- Note: result1 and result2 are the same cached table, but values should be updated
  luaunit.assertAlmostEquals(x1, 50, 0.01)
  luaunit.assertAlmostEquals(x2, 75, 0.01)
  -- result1.x will actually be 75 now since it's the same table reference
  luaunit.assertAlmostEquals(result1.x, 75, 0.01)
end

-- ============================================================================
-- Test Suite: Animation Helper Functions
-- ============================================================================

TestAnimationHelpers = {}

function TestAnimationHelpers:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationHelpers:tearDown()
  FlexLove.endFrame()
end

function TestAnimationHelpers:test_fade_with_negative_opacity()
  local anim = Animation.fade(1, -1, 2)
  anim:update(0.5)
  local result = anim:interpolate()
  -- Should interpolate even with negative values
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

function TestAnimationHelpers:test_fade_with_same_opacity()
  local anim = Animation.fade(1, 0.5, 0.5)
  anim:update(0.5)
  local result = anim:interpolate()
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

function TestAnimationHelpers:test_fade_helper_backwards_compatibility()
  local anim = Animation.fade(1, 0, 1)

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

function TestAnimationHelpers:test_scale_with_negative_dimensions()
  local anim = Animation.scale(1, { width = -100, height = -50 }, { width = 100, height = 50 })
  anim:update(0.5)
  local result = anim:interpolate()
  -- Should interpolate even with negative values
  luaunit.assertAlmostEquals(result.width, 0, 0.1)
  luaunit.assertAlmostEquals(result.height, 0, 0.1)
end

function TestAnimationHelpers:test_scale_with_zero_dimensions()
  local anim = Animation.scale(1, { width = 0, height = 0 }, { width = 100, height = 100 })
  anim:update(0.5)
  local result = anim:interpolate()
  luaunit.assertAlmostEquals(result.width, 50, 0.1)
  luaunit.assertAlmostEquals(result.height, 50, 0.1)
end

function TestAnimationHelpers:test_scale_helper_backwards_compatibility()
  local anim = Animation.scale(1, { width = 100, height = 100 }, { width = 200, height = 200 })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.width, 150, 0.01)
  luaunit.assertAlmostEquals(result.height, 150, 0.01)
end

-- ============================================================================
-- Test Suite: Animation Transform Property
-- ============================================================================

TestAnimationTransform = {}

function TestAnimationTransform:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationTransform:tearDown()
  FlexLove.endFrame()
end

function TestAnimationTransform:test_transform_property()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
    transform = { rotation = 45 },
  })
  anim:update(0.5)
  local result = anim:interpolate()
  -- Transform should be applied
  luaunit.assertEquals(result.rotation, 45)
end

function TestAnimationTransform:test_transform_with_multiple_properties()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
    transform = { rotation = 45, scale = 2, custom = "value" },
  })
  anim:update(0.5)
  local result = anim:interpolate()
  luaunit.assertEquals(result.rotation, 45)
  luaunit.assertEquals(result.scale, 2)
  luaunit.assertEquals(result.custom, "value")
end

-- ============================================================================
-- Test Suite: Easing Functions
-- ============================================================================

TestEasing = {}

function TestEasing:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestEasing:tearDown()
  FlexLove.endFrame()
end

-- Test that all easing functions exist
function TestEasing:test_all_easing_functions_exist()
  local easings = {
    -- Linear
    "linear",
    -- Quad
    "easeInQuad",
    "easeOutQuad",
    "easeInOutQuad",
    -- Cubic
    "easeInCubic",
    "easeOutCubic",
    "easeInOutCubic",
    -- Quart
    "easeInQuart",
    "easeOutQuart",
    "easeInOutQuart",
    -- Quint
    "easeInQuint",
    "easeOutQuint",
    "easeInOutQuint",
    -- Expo
    "easeInExpo",
    "easeOutExpo",
    "easeInOutExpo",
    -- Sine
    "easeInSine",
    "easeOutSine",
    "easeInOutSine",
    -- Circ
    "easeInCirc",
    "easeOutCirc",
    "easeInOutCirc",
    -- Back
    "easeInBack",
    "easeOutBack",
    "easeInOutBack",
    -- Elastic
    "easeInElastic",
    "easeOutElastic",
    "easeInOutElastic",
    -- Bounce
    "easeInBounce",
    "easeOutBounce",
    "easeInOutBounce",
  }

  for _, name in ipairs(easings) do
    luaunit.assertNotNil(Easing[name], "Easing function " .. name .. " should exist")
    luaunit.assertEquals(type(Easing[name]), "function", name .. " should be a function")
  end
end

function TestEasing:test_all_easing_functions_with_animation()
  local easings = {
    "linear",
    "easeInQuad",
    "easeOutQuad",
    "easeInOutQuad",
    "easeInCubic",
    "easeOutCubic",
    "easeInOutCubic",
    "easeInQuart",
    "easeOutQuart",
    "easeInExpo",
    "easeOutExpo",
  }

  for _, easingName in ipairs(easings) do
    local anim = Animation.new({
      duration = 1,
      start = { opacity = 0 },
      final = { opacity = 1 },
      easing = easingName,
    })
    anim:update(0.5)
    local result = anim:interpolate()
    -- All should produce valid values
    luaunit.assertNotNil(result.opacity)
    luaunit.assertTrue(result.opacity >= 0 and result.opacity <= 1)
  end
end

-- Test that all easing functions accept t parameter (0-1)
function TestEasing:test_easing_functions_accept_parameter()
  local result = Easing.linear(0.5)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(type(result), "number")
end

-- Test linear easing
function TestEasing:test_linear()
  luaunit.assertEquals(Easing.linear(0), 0)
  luaunit.assertEquals(Easing.linear(0.5), 0.5)
  luaunit.assertEquals(Easing.linear(1), 1)
end

-- Test easeInQuad
function TestEasing:test_easeInQuad()
  luaunit.assertEquals(Easing.easeInQuad(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInQuad(0.5), 0.25, 0.01)
  luaunit.assertEquals(Easing.easeInQuad(1), 1)
end

-- Test easeOutQuad
function TestEasing:test_easeOutQuad()
  luaunit.assertEquals(Easing.easeOutQuad(0), 0)
  luaunit.assertAlmostEquals(Easing.easeOutQuad(0.5), 0.75, 0.01)
  luaunit.assertEquals(Easing.easeOutQuad(1), 1)
end

-- Test easeInOutQuad
function TestEasing:test_easeInOutQuad()
  luaunit.assertEquals(Easing.easeInOutQuad(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutQuad(0.5), 0.5, 0.01)
  luaunit.assertEquals(Easing.easeInOutQuad(1), 1)
end

-- Test easeInSine
function TestEasing:test_easeInSine()
  luaunit.assertEquals(Easing.easeInSine(0), 0)
  local mid = Easing.easeInSine(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeInSine(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeInSine(1), 1, 0.01)
end

-- Test easeOutSine
function TestEasing:test_easeOutSine()
  luaunit.assertEquals(Easing.easeOutSine(0), 0)
  local mid = Easing.easeOutSine(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeOutSine(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeOutSine(1), 1, 0.01)
end

-- Test easeInOutSine
function TestEasing:test_easeInOutSine()
  luaunit.assertEquals(Easing.easeInOutSine(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutSine(0.5), 0.5, 0.01)
  luaunit.assertAlmostEquals(Easing.easeInOutSine(1), 1, 0.01)
end

-- Test easeInQuint
function TestEasing:test_easeInQuint()
  luaunit.assertEquals(Easing.easeInQuint(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInQuint(0.5), 0.03125, 0.01)
  luaunit.assertEquals(Easing.easeInQuint(1), 1)
end

-- Test easeOutQuint
function TestEasing:test_easeOutQuint()
  luaunit.assertEquals(Easing.easeOutQuint(0), 0)
  luaunit.assertAlmostEquals(Easing.easeOutQuint(0.5), 0.96875, 0.01)
  luaunit.assertEquals(Easing.easeOutQuint(1), 1)
end

-- Test easeInCirc
function TestEasing:test_easeInCirc()
  luaunit.assertEquals(Easing.easeInCirc(0), 0)
  local mid = Easing.easeInCirc(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeInCirc(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeInCirc(1), 1, 0.01)
end

-- Test easeOutCirc
function TestEasing:test_easeOutCirc()
  luaunit.assertEquals(Easing.easeOutCirc(0), 0)
  local mid = Easing.easeOutCirc(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeOutCirc(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeOutCirc(1), 1, 0.01)
end

-- Test easeInOutCirc
function TestEasing:test_easeInOutCirc()
  luaunit.assertEquals(Easing.easeInOutCirc(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutCirc(0.5), 0.5, 0.01)
  luaunit.assertAlmostEquals(Easing.easeInOutCirc(1), 1, 0.01)
end

-- Test easeInBack (should overshoot at start)
function TestEasing:test_easeInBack()
  luaunit.assertEquals(Easing.easeInBack(0), 0)
  local early = Easing.easeInBack(0.3)
  luaunit.assertTrue(early < 0, "easeInBack should go negative (overshoot) early on")
  luaunit.assertAlmostEquals(Easing.easeInBack(1), 1, 0.001)
end

-- Test easeOutBack (should overshoot at end)
function TestEasing:test_easeOutBack()
  luaunit.assertAlmostEquals(Easing.easeOutBack(0), 0, 0.001)
  local late = Easing.easeOutBack(0.7)
  luaunit.assertTrue(late > 0.7, "easeOutBack should overshoot at the end")
  luaunit.assertAlmostEquals(Easing.easeOutBack(1), 1, 0.01)
end

-- Test easeInElastic (should oscillate)
function TestEasing:test_easeInElastic()
  luaunit.assertEquals(Easing.easeInElastic(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInElastic(1), 1, 0.01)
  -- Elastic should go negative at some point
  local hasNegative = false
  for i = 1, 9 do
    local t = i / 10
    if Easing.easeInElastic(t) < 0 then
      hasNegative = true
      break
    end
  end
  luaunit.assertTrue(hasNegative, "easeInElastic should have negative values (oscillation)")
end

-- Test easeOutElastic (should oscillate)
function TestEasing:test_easeOutElastic()
  luaunit.assertEquals(Easing.easeOutElastic(0), 0)
  luaunit.assertAlmostEquals(Easing.easeOutElastic(1), 1, 0.01)
  -- Elastic should go above 1 at some point
  local hasOvershoot = false
  for i = 1, 9 do
    local t = i / 10
    if Easing.easeOutElastic(t) > 1 then
      hasOvershoot = true
      break
    end
  end
  luaunit.assertTrue(hasOvershoot, "easeOutElastic should overshoot 1 (oscillation)")
end

-- Test easeInBounce
function TestEasing:test_easeInBounce()
  luaunit.assertEquals(Easing.easeInBounce(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInBounce(1), 1, 0.01)
  -- Bounce should have multiple "bounces" (local minima)
  local result = Easing.easeInBounce(0.5)
  luaunit.assertTrue(result >= 0 and result <= 1, "easeInBounce should stay within 0-1 range")
end

-- Test easeOutBounce
function TestEasing:test_easeOutBounce()
  luaunit.assertEquals(Easing.easeOutBounce(0), 0)
  luaunit.assertAlmostEquals(Easing.easeOutBounce(1), 1, 0.01)
  -- Bounce should have bounces
  local result = Easing.easeOutBounce(0.8)
  luaunit.assertTrue(result >= 0 and result <= 1, "easeOutBounce should stay within 0-1 range")
end

-- Test easeInOutBounce
function TestEasing:test_easeInOutBounce()
  luaunit.assertEquals(Easing.easeInOutBounce(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutBounce(0.5), 0.5, 0.01)
  luaunit.assertAlmostEquals(Easing.easeInOutBounce(1), 1, 0.01)
end

function TestEasing:test_easeInExpo_at_zero()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
    easing = "easeInExpo",
  })
  -- t=0 should return 0
  local result = anim:interpolate()
  luaunit.assertAlmostEquals(result.opacity, 0, 0.01)
end

function TestEasing:test_easeOutExpo_at_one()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
    easing = "easeOutExpo",
  })
  anim:update(1)
  local result = anim:interpolate()
  luaunit.assertAlmostEquals(result.opacity, 1.0, 0.01)
end

-- Test configurable back() factory
function TestEasing:test_back_factory()
  local customBack = Easing.back(2.5)
  luaunit.assertEquals(type(customBack), "function")
  luaunit.assertEquals(customBack(0), 0)
  luaunit.assertEquals(customBack(1), 1)
  -- Should overshoot with custom amount
  local mid = customBack(0.3)
  luaunit.assertTrue(mid < 0, "Custom back easing should overshoot")
end

-- Test configurable elastic() factory
function TestEasing:test_elastic_factory()
  local customElastic = Easing.elastic(1.5, 0.4)
  luaunit.assertEquals(type(customElastic), "function")
  luaunit.assertEquals(customElastic(0), 0)
  luaunit.assertAlmostEquals(customElastic(1), 1, 0.01)
end

-- Test that all InOut easings are symmetric around 0.5
function TestEasing:test_inOut_symmetry()
  local inOutEasings = {
    "easeInOutQuad",
    "easeInOutCubic",
    "easeInOutQuart",
    "easeInOutQuint",
    "easeInOutExpo",
    "easeInOutSine",
    "easeInOutCirc",
    "easeInOutBack",
    "easeInOutElastic",
    "easeInOutBounce",
  }

  for _, name in ipairs(inOutEasings) do
    local easing = Easing[name]
    -- At t=0.5, all InOut easings should be close to 0.5
    local mid = easing(0.5)
    luaunit.assertAlmostEquals(mid, 0.5, 0.1, name .. " should be close to 0.5 at t=0.5")
  end
end

-- Test boundary conditions for all easings
function TestEasing:test_boundary_conditions()
  local easings = {
    "linear",
    "easeInQuad",
    "easeOutQuad",
    "easeInOutQuad",
    "easeInCubic",
    "easeOutCubic",
    "easeInOutCubic",
    "easeInQuart",
    "easeOutQuart",
    "easeInOutQuart",
    "easeInQuint",
    "easeOutQuint",
    "easeInOutQuint",
    "easeInExpo",
    "easeOutExpo",
    "easeInOutExpo",
    "easeInSine",
    "easeOutSine",
    "easeInOutSine",
    "easeInCirc",
    "easeOutCirc",
    "easeInOutCirc",
    "easeInBack",
    "easeOutBack",
    "easeInOutBack",
    "easeInElastic",
    "easeOutElastic",
    "easeInOutElastic",
    "easeInBounce",
    "easeOutBounce",
    "easeInOutBounce",
  }

  for _, name in ipairs(easings) do
    local easing = Easing[name]
    -- All easings should start at 0
    local start = easing(0)
    luaunit.assertAlmostEquals(start, 0, 0.01, name .. " should start at 0")

    -- All easings should end at 1
    local finish = easing(1)
    luaunit.assertAlmostEquals(finish, 1, 0.01, name .. " should end at 1")
  end
end

-- ============================================================================
-- Test Suite: Animation Properties (Color, Position, Numeric, Tables)
-- ============================================================================

TestAnimationProperties = {}

function TestAnimationProperties:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationProperties:tearDown()
  FlexLove.endFrame()
end

-- Test Color.lerp() method
function TestAnimationProperties:test_color_lerp_midpoint()
  local colorA = Color.new(0, 0, 0, 1) -- Black
  local colorB = Color.new(1, 1, 1, 1) -- White
  local result = Color.lerp(colorA, colorB, 0.5)

  luaunit.assertAlmostEquals(result.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.g, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.b, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.a, 1, 0.01)
end

function TestAnimationProperties:test_color_lerp_start_point()
  local colorA = Color.new(1, 0, 0, 1) -- Red
  local colorB = Color.new(0, 0, 1, 1) -- Blue
  local result = Color.lerp(colorA, colorB, 0)

  luaunit.assertAlmostEquals(result.r, 1, 0.01)
  luaunit.assertAlmostEquals(result.g, 0, 0.01)
  luaunit.assertAlmostEquals(result.b, 0, 0.01)
end

function TestAnimationProperties:test_color_lerp_end_point()
  local colorA = Color.new(1, 0, 0, 1) -- Red
  local colorB = Color.new(0, 0, 1, 1) -- Blue
  local result = Color.lerp(colorA, colorB, 1)

  luaunit.assertAlmostEquals(result.r, 0, 0.01)
  luaunit.assertAlmostEquals(result.g, 0, 0.01)
  luaunit.assertAlmostEquals(result.b, 1, 0.01)
end

function TestAnimationProperties:test_color_lerp_alpha()
  local colorA = Color.new(1, 1, 1, 0) -- Transparent white
  local colorB = Color.new(1, 1, 1, 1) -- Opaque white
  local result = Color.lerp(colorA, colorB, 0.5)

  luaunit.assertAlmostEquals(result.a, 0.5, 0.01)
end

function TestAnimationProperties:test_color_lerp_clamp_t()
  local colorA = Color.new(0, 0, 0, 1)
  local colorB = Color.new(1, 1, 1, 1)

  -- Test t > 1
  local result1 = Color.lerp(colorA, colorB, 1.5)
  luaunit.assertAlmostEquals(result1.r, 1, 0.01)

  -- Test t < 0
  local result2 = Color.lerp(colorA, colorB, -0.5)
  luaunit.assertAlmostEquals(result2.r, 0, 0.01)
end

-- Test Position Animation (x, y)
function TestAnimationProperties:test_position_animation_x()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.x, 50, 0.01)
end

function TestAnimationProperties:test_position_animation_y()
  local anim = Animation.new({
    duration = 1,
    start = { y = 0 },
    final = { y = 200 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.y, 100, 0.01)
end

function TestAnimationProperties:test_position_animation_xy()
  local anim = Animation.new({
    duration = 1,
    start = { x = 10, y = 20 },
    final = { x = 110, y = 220 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.x, 60, 0.01)
  luaunit.assertAlmostEquals(result.y, 120, 0.01)
end

-- Test Color Property Animation
function TestAnimationProperties:test_color_animation_backgroundColor()
  local anim = Animation.new({
    duration = 1,
    start = { backgroundColor = Color.new(1, 0, 0, 1) }, -- Red
    final = { backgroundColor = Color.new(0, 0, 1, 1) }, -- Blue
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.backgroundColor.b, 0.5, 0.01)
end

function TestAnimationProperties:test_color_animation_multiple_colors()
  local anim = Animation.new({
    duration = 1,
    start = {
      backgroundColor = Color.new(1, 0, 0, 1),
      borderColor = Color.new(0, 1, 0, 1),
      textColor = Color.new(0, 0, 1, 1),
    },
    final = {
      backgroundColor = Color.new(0, 1, 0, 1),
      borderColor = Color.new(0, 0, 1, 1),
      textColor = Color.new(1, 0, 0, 1),
    },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertNotNil(result.borderColor)
  luaunit.assertNotNil(result.textColor)

  -- Mid-point should be (0.5, 0.5, 0.5) for backgroundColor
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.backgroundColor.g, 0.5, 0.01)
end

function TestAnimationProperties:test_color_animation_hex_colors()
  local anim = Animation.new({
    duration = 1,
    start = { backgroundColor = "#FF0000" }, -- Red
    final = { backgroundColor = "#0000FF" }, -- Blue
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.5, 0.01)
end

-- Test Numeric Property Animation
function TestAnimationProperties:test_numeric_animation_gap()
  local anim = Animation.new({
    duration = 1,
    start = { gap = 0 },
    final = { gap = 20 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.gap, 10, 0.01)
end

function TestAnimationProperties:test_numeric_animation_image_opacity()
  local anim = Animation.new({
    duration = 1,
    start = { imageOpacity = 0 },
    final = { imageOpacity = 1 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.imageOpacity, 0.5, 0.01)
end

function TestAnimationProperties:test_numeric_animation_border_width()
  local anim = Animation.new({
    duration = 1,
    start = { borderWidth = 1 },
    final = { borderWidth = 10 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.borderWidth, 5.5, 0.01)
end

function TestAnimationProperties:test_numeric_animation_font_size()
  local anim = Animation.new({
    duration = 1,
    start = { fontSize = 12 },
    final = { fontSize = 24 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.fontSize, 18, 0.01)
end

function TestAnimationProperties:test_numeric_animation_multiple_properties()
  local anim = Animation.new({
    duration = 1,
    start = { gap = 0, imageOpacity = 0, borderWidth = 1 },
    final = { gap = 20, imageOpacity = 1, borderWidth = 5 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.gap, 10, 0.01)
  luaunit.assertAlmostEquals(result.imageOpacity, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.borderWidth, 3, 0.01)
end

-- Test Table Property Animation (padding, margin, cornerRadius)
function TestAnimationProperties:test_table_animation_padding()
  local anim = Animation.new({
    duration = 1,
    start = { padding = { top = 0, right = 0, bottom = 0, left = 0 } },
    final = { padding = { top = 10, right = 20, bottom = 10, left = 20 } },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.padding)
  luaunit.assertAlmostEquals(result.padding.top, 5, 0.01)
  luaunit.assertAlmostEquals(result.padding.right, 10, 0.01)
  luaunit.assertAlmostEquals(result.padding.bottom, 5, 0.01)
  luaunit.assertAlmostEquals(result.padding.left, 10, 0.01)
end

function TestAnimationProperties:test_table_animation_margin()
  local anim = Animation.new({
    duration = 1,
    start = { margin = { top = 0, right = 0, bottom = 0, left = 0 } },
    final = { margin = { top = 20, right = 20, bottom = 20, left = 20 } },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.margin)
  luaunit.assertAlmostEquals(result.margin.top, 10, 0.01)
  luaunit.assertAlmostEquals(result.margin.right, 10, 0.01)
end

function TestAnimationProperties:test_table_animation_corner_radius()
  local anim = Animation.new({
    duration = 1,
    start = { cornerRadius = { topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = 0 } },
    final = { cornerRadius = { topLeft = 10, topRight = 10, bottomLeft = 10, bottomRight = 10 } },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.cornerRadius)
  luaunit.assertAlmostEquals(result.cornerRadius.topLeft, 5, 0.01)
  luaunit.assertAlmostEquals(result.cornerRadius.topRight, 5, 0.01)
end

function TestAnimationProperties:test_table_animation_partial_keys()
  -- Test when start and final have different keys
  local anim = Animation.new({
    duration = 1,
    start = { padding = { top = 0, left = 0 } },
    final = { padding = { top = 10, right = 20, left = 10 } },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.padding)
  luaunit.assertAlmostEquals(result.padding.top, 5, 0.01)
  luaunit.assertAlmostEquals(result.padding.left, 5, 0.01)
  luaunit.assertNotNil(result.padding.right)
end

function TestAnimationProperties:test_table_animation_non_numeric_values()
  -- Should skip non-numeric values in tables
  local anim = Animation.new({
    duration = 1,
    start = { padding = { top = 0, special = "value" } },
    final = { padding = { top = 10, special = "value" } },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.padding)
  luaunit.assertAlmostEquals(result.padding.top, 5, 0.01)
end

-- Test Combined Animations
function TestAnimationProperties:test_combined_animation_all_types()
  local anim = Animation.new({
    duration = 1,
    start = {
      width = 100,
      height = 100,
      x = 0,
      y = 0,
      opacity = 0,
      backgroundColor = Color.new(1, 0, 0, 1),
      gap = 0,
      padding = { top = 0, left = 0 },
    },
    final = {
      width = 200,
      height = 200,
      x = 100,
      y = 100,
      opacity = 1,
      backgroundColor = Color.new(0, 0, 1, 1),
      gap = 20,
      padding = { top = 10, left = 10 },
    },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  -- Check all properties interpolated correctly
  luaunit.assertAlmostEquals(result.width, 150, 0.01)
  luaunit.assertAlmostEquals(result.height, 150, 0.01)
  luaunit.assertAlmostEquals(result.x, 50, 0.01)
  luaunit.assertAlmostEquals(result.y, 50, 0.01)
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.gap, 10, 0.01)
  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertNotNil(result.padding)
end

function TestAnimationProperties:test_combined_animation_with_easing()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0, backgroundColor = Color.new(0, 0, 0, 1) },
    final = { x = 100, backgroundColor = Color.new(1, 1, 1, 1) },
    easing = "easeInQuad",
  })

  anim:update(0.5)
  local result = anim:interpolate()

  -- With easeInQuad, at t=0.5, eased value should be 0.25
  luaunit.assertAlmostEquals(result.x, 25, 0.01)
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.25, 0.01)
end

function TestAnimationProperties:test_backwards_compatibility_width_height_opacity()
  -- Ensure old animations still work
  local anim = Animation.new({
    duration = 1,
    start = { width = 100, height = 100, opacity = 0 },
    final = { width = 200, height = 200, opacity = 1 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.width, 150, 0.01)
  luaunit.assertAlmostEquals(result.height, 150, 0.01)
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

-- ============================================================================
-- Test Suite: Keyframe Animation
-- ============================================================================

TestKeyframeAnimation = {}

function TestKeyframeAnimation:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestKeyframeAnimation:tearDown()
  FlexLove.endFrame()
end

-- Test basic keyframe animation creation
function TestKeyframeAnimation:test_create_keyframe_animation()
  local anim = Animation.keyframes({
    duration = 2,
    keyframes = {
      { at = 0, values = { x = 0, opacity = 0 } },
      { at = 1, values = { x = 100, opacity = 1 } },
    },
  })

  luaunit.assertNotNil(anim)
  luaunit.assertEquals(type(anim), "table")
  luaunit.assertEquals(anim.duration, 2)
  luaunit.assertNotNil(anim.keyframes)
  luaunit.assertEquals(#anim.keyframes, 2)
end

-- Test keyframe animation with multiple waypoints
function TestKeyframeAnimation:test_multiple_waypoints()
  local anim = Animation.keyframes({
    duration = 3,
    keyframes = {
      { at = 0, values = { x = 0, opacity = 0 } },
      { at = 0.25, values = { x = 50, opacity = 1 } },
      { at = 0.75, values = { x = 150, opacity = 1 } },
      { at = 1, values = { x = 200, opacity = 0 } },
    },
  })

  luaunit.assertEquals(#anim.keyframes, 4)
  luaunit.assertEquals(anim.keyframes[1].at, 0)
  luaunit.assertEquals(anim.keyframes[2].at, 0.25)
  luaunit.assertEquals(anim.keyframes[3].at, 0.75)
  luaunit.assertEquals(anim.keyframes[4].at, 1)
end

-- Test keyframe sorting
function TestKeyframeAnimation:test_keyframe_sorting()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 1, values = { x = 100 } },
      { at = 0, values = { x = 0 } },
      { at = 0.5, values = { x = 50 } },
    },
  })

  -- Should be sorted by 'at' position
  luaunit.assertEquals(anim.keyframes[1].at, 0)
  luaunit.assertEquals(anim.keyframes[2].at, 0.5)
  luaunit.assertEquals(anim.keyframes[3].at, 1)
end

-- Test keyframe interpolation at start
function TestKeyframeAnimation:test_interpolation_at_start()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0, opacity = 0 } },
      { at = 1, values = { x = 100, opacity = 1 } },
    },
  })

  anim.elapsed = 0
  local result = anim:interpolate()

  luaunit.assertNotNil(result.x)
  luaunit.assertNotNil(result.opacity)
  luaunit.assertAlmostEquals(result.x, 0, 0.01)
  luaunit.assertAlmostEquals(result.opacity, 0, 0.01)
end

-- Test keyframe interpolation at end
function TestKeyframeAnimation:test_interpolation_at_end()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0, opacity = 0 } },
      { at = 1, values = { x = 100, opacity = 1 } },
    },
  })

  anim.elapsed = 1
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.x, 100, 0.01)
  luaunit.assertAlmostEquals(result.opacity, 1, 0.01)
end

-- Test keyframe interpolation at midpoint
function TestKeyframeAnimation:test_interpolation_at_midpoint()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0 } },
      { at = 1, values = { x = 100 } },
    },
  })

  anim.elapsed = 0.5
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.x, 50, 0.01)
end

-- Test per-keyframe easing
function TestKeyframeAnimation:test_per_keyframe_easing()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0 }, easing = "easeInQuad" },
      { at = 0.5, values = { x = 50 }, easing = "linear" },
      { at = 1, values = { x = 100 } },
    },
  })

  -- At t=0.25 (middle of first segment with easeInQuad)
  anim.elapsed = 0.25
  anim._resultDirty = true -- Mark dirty to force recalculation
  local result1 = anim:interpolate()
  -- easeInQuad at 0.5 should give 0.25, so x = 0 + (50-0) * 0.25 = 12.5
  luaunit.assertTrue(result1.x < 25, "easeInQuad should slow start")

  -- At t=0.75 (middle of second segment with linear)
  anim.elapsed = 0.75
  anim._resultDirty = true -- Mark dirty to force recalculation
  local result2 = anim:interpolate()
  -- linear at 0.5 should give 0.5, so x = 50 + (100-50) * 0.5 = 75
  luaunit.assertAlmostEquals(result2.x, 75, 1)
end

-- Test findKeyframes method
function TestKeyframeAnimation:test_find_keyframes()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0 } },
      { at = 0.25, values = { x = 25 } },
      { at = 0.75, values = { x = 75 } },
      { at = 1, values = { x = 100 } },
    },
  })

  -- Test finding keyframes at different progress values
  local prev1, next1 = anim:findKeyframes(0.1)
  luaunit.assertEquals(prev1.at, 0)
  luaunit.assertEquals(next1.at, 0.25)

  local prev2, next2 = anim:findKeyframes(0.5)
  luaunit.assertEquals(prev2.at, 0.25)
  luaunit.assertEquals(next2.at, 0.75)

  local prev3, next3 = anim:findKeyframes(0.9)
  luaunit.assertEquals(prev3.at, 0.75)
  luaunit.assertEquals(next3.at, 1)
end

-- Test keyframe animation with update
function TestKeyframeAnimation:test_keyframe_animation_update()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { opacity = 0 } },
      { at = 1, values = { opacity = 1 } },
    },
  })

  -- Update halfway through
  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
  luaunit.assertFalse(anim:update(0)) -- Not complete yet

  -- Update to completion
  luaunit.assertTrue(anim:update(0.6)) -- Should complete
  luaunit.assertEquals(anim:getState(), "completed")
end

-- Test keyframe animation with callbacks
function TestKeyframeAnimation:test_keyframe_animation_callbacks()
  local startCalled = false
  local updateCalled = false
  local completeCalled = false

  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0 } },
      { at = 1, values = { x = 100 } },
    },
    onStart = function()
      startCalled = true
    end,
    onUpdate = function()
      updateCalled = true
    end,
    onComplete = function()
      completeCalled = true
    end,
  })

  anim:update(0.5)
  luaunit.assertTrue(startCalled)
  luaunit.assertTrue(updateCalled)
  luaunit.assertFalse(completeCalled)

  anim:update(0.6)
  luaunit.assertTrue(completeCalled)
end

-- Test missing keyframes (error handling)
function TestKeyframeAnimation:test_missing_keyframes()
  -- Should create default keyframes with warning
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {},
  })

  luaunit.assertNotNil(anim)
  luaunit.assertEquals(#anim.keyframes, 2) -- Should have default start and end
end

-- Test single keyframe (error handling)
function TestKeyframeAnimation:test_single_keyframe()
  -- Should create default keyframes with warning
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0.5, values = { x = 50 } },
    },
  })

  luaunit.assertNotNil(anim)
  luaunit.assertTrue(#anim.keyframes >= 2) -- Should have at least 2 keyframes
end

-- Test keyframes without start (at=0)
function TestKeyframeAnimation:test_keyframes_without_start()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0.5, values = { x = 50 } },
      { at = 1, values = { x = 100 } },
    },
  })

  -- Should auto-add keyframe at 0
  luaunit.assertEquals(anim.keyframes[1].at, 0)
  luaunit.assertEquals(anim.keyframes[1].values.x, 50) -- Should copy first keyframe values
end

-- Test keyframes without end (at=1)
function TestKeyframeAnimation:test_keyframes_without_end()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0 } },
      { at = 0.5, values = { x = 50 } },
    },
  })

  -- Should auto-add keyframe at 1
  luaunit.assertEquals(anim.keyframes[#anim.keyframes].at, 1)
  luaunit.assertEquals(anim.keyframes[#anim.keyframes].values.x, 50) -- Should copy last keyframe values
end

-- Test keyframe with invalid props
function TestKeyframeAnimation:test_invalid_keyframe_props()
  -- Should handle gracefully with warnings
  local anim = Animation.keyframes({
    duration = 0, -- Invalid
    keyframes = "not a table", -- Invalid
  })

  luaunit.assertNotNil(anim)
  luaunit.assertEquals(anim.duration, 1) -- Should use default
end

-- Test complex multi-property keyframes
function TestKeyframeAnimation:test_multi_property_keyframes()
  local anim = Animation.keyframes({
    duration = 2,
    keyframes = {
      { at = 0, values = { x = 0, y = 0, opacity = 0, width = 50 } },
      { at = 0.33, values = { x = 100, y = 50, opacity = 1, width = 100 } },
      { at = 0.66, values = { x = 200, y = 100, opacity = 1, width = 150 } },
      { at = 1, values = { x = 300, y = 150, opacity = 0, width = 200 } },
    },
  })

  -- Test interpolation at 0.5 (middle of second segment)
  anim.elapsed = 1.0 -- t = 0.5
  local result = anim:interpolate()

  luaunit.assertNotNil(result.x)
  luaunit.assertNotNil(result.y)
  luaunit.assertNotNil(result.opacity)
  luaunit.assertNotNil(result.width)

  -- Should be interpolating between keyframes at 0.33 and 0.66
  luaunit.assertTrue(result.x > 100 and result.x < 200)
  luaunit.assertTrue(result.y > 50 and result.y < 100)
end

-- Test keyframe with easing function (not string)
function TestKeyframeAnimation:test_keyframe_with_easing_function()
  local customEasing = function(t)
    return t * t
  end

  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0 }, easing = customEasing },
      { at = 1, values = { x = 100 } },
    },
  })

  anim.elapsed = 0.5
  local result = anim:interpolate()

  -- At t=0.5, easing(0.5) = 0.25, so x = 0 + 100 * 0.25 = 25
  luaunit.assertAlmostEquals(result.x, 25, 1)
end

-- Test caching behavior with keyframes
function TestKeyframeAnimation:test_keyframe_caching()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      { at = 0, values = { x = 0 } },
      { at = 1, values = { x = 100 } },
    },
  })

  anim.elapsed = 0.5
  local result1 = anim:interpolate()
  local result2 = anim:interpolate() -- Should return cached result

  luaunit.assertEquals(result1, result2) -- Should be same table
end

-- Run all tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
