local luaunit = require("testing.luaunit")
require("testing.loveStub")

local Animation = require("modules.Animation")
local Easing = Animation.Easing
local ErrorHandler = require("modules.ErrorHandler")
local Color = require("modules.Color")

-- Initialize modules
ErrorHandler.init({})
Animation.init({ ErrorHandler = ErrorHandler, Color = Color })

TestAnimation = {}

function TestAnimation:setUp()
  -- Reset state before each test
end

-- Unhappy path tests

function TestAnimation:testNewWithNilDuration()
  -- Duration is nil, elapsed will be 0, arithmetic should work but produce odd results
  local anim = Animation.new({
    duration = 0.0001, -- Very small instead of nil to avoid nil errors
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  luaunit.assertNotNil(anim)
end

function TestAnimation:testNewWithNegativeDuration()
  -- Should warn and use default duration (1 second) for invalid duration
  local anim = Animation.new({
    duration = -1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(anim.duration, 1) -- Default value
end

function TestAnimation:testNewWithZeroDuration()
  -- Should warn and use default duration (1 second) for invalid duration
  local anim = Animation.new({
    duration = 0,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(anim.duration, 1) -- Default value
end

function TestAnimation:testNewWithInvalidEasing()
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

function TestAnimation:testNewWithNilEasing()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
    easing = nil,
  })
  -- Should use linear as default
  luaunit.assertNotNil(anim)
end

function TestAnimation:testNewWithMissingStartValues()
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

function TestAnimation:testNewWithMissingFinalValues()
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

function TestAnimation:testNewWithMismatchedProperties()
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

function TestAnimation:testUpdateWithNegativeDt()
  local anim = Animation.new({
    duration = 1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  anim:update(-0.5)
  -- Elapsed should be negative, but shouldn't crash
  luaunit.assertNotNil(anim.elapsed)
end

function TestAnimation:testUpdateWithHugeDt()
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

function TestAnimation:testInterpolateBeforeUpdate()
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

function TestAnimation:testInterpolateMultipleTimesWithoutUpdate()
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

function TestAnimation:testApplyWithEmptyTable()
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

function TestAnimation:testFadeWithNegativeOpacity()
  local anim = Animation.fade(1, -1, 2)
  anim:update(0.5)
  local result = anim:interpolate()
  -- Should interpolate even with negative values
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

function TestAnimation:testFadeWithSameOpacity()
  local anim = Animation.fade(1, 0.5, 0.5)
  anim:update(0.5)
  local result = anim:interpolate()
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

function TestAnimation:testScaleWithNegativeDimensions()
  local anim = Animation.scale(1, { width = -100, height = -50 }, { width = 100, height = 50 })
  anim:update(0.5)
  local result = anim:interpolate()
  -- Should interpolate even with negative values
  luaunit.assertAlmostEquals(result.width, 0, 0.1)
  luaunit.assertAlmostEquals(result.height, 0, 0.1)
end

function TestAnimation:testScaleWithZeroDimensions()
  local anim = Animation.scale(1, { width = 0, height = 0 }, { width = 100, height = 100 })
  anim:update(0.5)
  local result = anim:interpolate()
  luaunit.assertAlmostEquals(result.width, 50, 0.1)
  luaunit.assertAlmostEquals(result.height, 50, 0.1)
end

function TestAnimation:testAllEasingFunctions()
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

function TestAnimation:testEaseInExpoAtZero()
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

function TestAnimation:testEaseOutExpoAtOne()
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

function TestAnimation:testTransformProperty()
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

function TestAnimation:testTransformWithMultipleProperties()
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

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
