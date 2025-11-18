local luaunit = require("testing.luaunit")
require("testing.loveStub")

local Animation = require("modules.Animation")
local Easing = require("modules.Easing")
local ErrorHandler = require("modules.ErrorHandler")
local ErrorCodes = require("modules.ErrorCodes")

-- Initialize modules
ErrorHandler.init({ ErrorCodes = ErrorCodes })
Animation.init({ ErrorHandler = ErrorHandler, Easing = Easing })

TestKeyframeAnimation = {}

function TestKeyframeAnimation:setUp()
  -- Reset state before each test
end

-- Test basic keyframe animation creation
function TestKeyframeAnimation:testCreateKeyframeAnimation()
  local anim = Animation.keyframes({
    duration = 2,
    keyframes = {
      {at = 0, values = {x = 0, opacity = 0}},
      {at = 1, values = {x = 100, opacity = 1}},
    }
  })
  
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(type(anim), "table")
  luaunit.assertEquals(anim.duration, 2)
  luaunit.assertNotNil(anim.keyframes)
  luaunit.assertEquals(#anim.keyframes, 2)
end

-- Test keyframe animation with multiple waypoints
function TestKeyframeAnimation:testMultipleWaypoints()
  local anim = Animation.keyframes({
    duration = 3,
    keyframes = {
      {at = 0,    values = {x = 0,   opacity = 0}},
      {at = 0.25, values = {x = 50,  opacity = 1}},
      {at = 0.75, values = {x = 150, opacity = 1}},
      {at = 1,    values = {x = 200, opacity = 0}},
    }
  })
  
  luaunit.assertEquals(#anim.keyframes, 4)
  luaunit.assertEquals(anim.keyframes[1].at, 0)
  luaunit.assertEquals(anim.keyframes[2].at, 0.25)
  luaunit.assertEquals(anim.keyframes[3].at, 0.75)
  luaunit.assertEquals(anim.keyframes[4].at, 1)
end

-- Test keyframe sorting
function TestKeyframeAnimation:testKeyframeSorting()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 1,    values = {x = 100}},
      {at = 0,    values = {x = 0}},
      {at = 0.5,  values = {x = 50}},
    }
  })
  
  -- Should be sorted by 'at' position
  luaunit.assertEquals(anim.keyframes[1].at, 0)
  luaunit.assertEquals(anim.keyframes[2].at, 0.5)
  luaunit.assertEquals(anim.keyframes[3].at, 1)
end

-- Test keyframe interpolation at start
function TestKeyframeAnimation:testInterpolationAtStart()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0, values = {x = 0, opacity = 0}},
      {at = 1, values = {x = 100, opacity = 1}},
    }
  })
  
  anim.elapsed = 0
  local result = anim:interpolate()
  
  luaunit.assertNotNil(result.x)
  luaunit.assertNotNil(result.opacity)
  luaunit.assertAlmostEquals(result.x, 0, 0.01)
  luaunit.assertAlmostEquals(result.opacity, 0, 0.01)
end

-- Test keyframe interpolation at end
function TestKeyframeAnimation:testInterpolationAtEnd()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0, values = {x = 0, opacity = 0}},
      {at = 1, values = {x = 100, opacity = 1}},
    }
  })
  
  anim.elapsed = 1
  local result = anim:interpolate()
  
  luaunit.assertAlmostEquals(result.x, 100, 0.01)
  luaunit.assertAlmostEquals(result.opacity, 1, 0.01)
end

-- Test keyframe interpolation at midpoint
function TestKeyframeAnimation:testInterpolationAtMidpoint()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0, values = {x = 0}},
      {at = 1, values = {x = 100}},
    }
  })
  
  anim.elapsed = 0.5
  local result = anim:interpolate()
  
  luaunit.assertAlmostEquals(result.x, 50, 0.01)
end

-- Test per-keyframe easing
function TestKeyframeAnimation:testPerKeyframeEasing()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0,   values = {x = 0},   easing = "easeInQuad"},
      {at = 0.5, values = {x = 50},  easing = "linear"},
      {at = 1,   values = {x = 100}},
    }
  })
  
  -- At t=0.25 (middle of first segment with easeInQuad)
  anim.elapsed = 0.25
  anim._resultDirty = true  -- Mark dirty to force recalculation
  local result1 = anim:interpolate()
  -- easeInQuad at 0.5 should give 0.25, so x = 0 + (50-0) * 0.25 = 12.5
  luaunit.assertTrue(result1.x < 25, "easeInQuad should slow start")
  
  -- At t=0.75 (middle of second segment with linear)
  anim.elapsed = 0.75
  anim._resultDirty = true  -- Mark dirty to force recalculation
  local result2 = anim:interpolate()
  -- linear at 0.5 should give 0.5, so x = 50 + (100-50) * 0.5 = 75
  luaunit.assertAlmostEquals(result2.x, 75, 1)
end

-- Test findKeyframes method
function TestKeyframeAnimation:testFindKeyframes()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0,    values = {x = 0}},
      {at = 0.25, values = {x = 25}},
      {at = 0.75, values = {x = 75}},
      {at = 1,    values = {x = 100}},
    }
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
function TestKeyframeAnimation:testKeyframeAnimationUpdate()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0, values = {opacity = 0}},
      {at = 1, values = {opacity = 1}},
    }
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
function TestKeyframeAnimation:testKeyframeAnimationCallbacks()
  local startCalled = false
  local updateCalled = false
  local completeCalled = false
  
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0, values = {x = 0}},
      {at = 1, values = {x = 100}},
    },
    onStart = function() startCalled = true end,
    onUpdate = function() updateCalled = true end,
    onComplete = function() completeCalled = true end,
  })
  
  anim:update(0.5)
  luaunit.assertTrue(startCalled)
  luaunit.assertTrue(updateCalled)
  luaunit.assertFalse(completeCalled)
  
  anim:update(0.6)
  luaunit.assertTrue(completeCalled)
end

-- Test missing keyframes (error handling)
function TestKeyframeAnimation:testMissingKeyframes()
  -- Should create default keyframes with warning
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {}
  })
  
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(#anim.keyframes, 2) -- Should have default start and end
end

-- Test single keyframe (error handling)
function TestKeyframeAnimation:testSingleKeyframe()
  -- Should create default keyframes with warning
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0.5, values = {x = 50}}
    }
  })
  
  luaunit.assertNotNil(anim)
  luaunit.assertTrue(#anim.keyframes >= 2) -- Should have at least 2 keyframes
end

-- Test keyframes without start (at=0)
function TestKeyframeAnimation:testKeyframesWithoutStart()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0.5, values = {x = 50}},
      {at = 1,   values = {x = 100}},
    }
  })
  
  -- Should auto-add keyframe at 0
  luaunit.assertEquals(anim.keyframes[1].at, 0)
  luaunit.assertEquals(anim.keyframes[1].values.x, 50) -- Should copy first keyframe values
end

-- Test keyframes without end (at=1)
function TestKeyframeAnimation:testKeyframesWithoutEnd()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0,   values = {x = 0}},
      {at = 0.5, values = {x = 50}},
    }
  })
  
  -- Should auto-add keyframe at 1
  luaunit.assertEquals(anim.keyframes[#anim.keyframes].at, 1)
  luaunit.assertEquals(anim.keyframes[#anim.keyframes].values.x, 50) -- Should copy last keyframe values
end

-- Test keyframe with invalid props
function TestKeyframeAnimation:testInvalidKeyframeProps()
  -- Should handle gracefully with warnings
  local anim = Animation.keyframes({
    duration = 0, -- Invalid
    keyframes = "not a table" -- Invalid
  })
  
  luaunit.assertNotNil(anim)
  luaunit.assertEquals(anim.duration, 1) -- Should use default
end

-- Test complex multi-property keyframes
function TestKeyframeAnimation:testMultiPropertyKeyframes()
  local anim = Animation.keyframes({
    duration = 2,
    keyframes = {
      {at = 0,    values = {x = 0,   y = 0,   opacity = 0,   width = 50}},
      {at = 0.33, values = {x = 100, y = 50,  opacity = 1,   width = 100}},
      {at = 0.66, values = {x = 200, y = 100, opacity = 1,   width = 150}},
      {at = 1,    values = {x = 300, y = 150, opacity = 0,   width = 200}},
    }
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
function TestKeyframeAnimation:testKeyframeWithEasingFunction()
  local customEasing = function(t) return t * t end
  
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0, values = {x = 0},   easing = customEasing},
      {at = 1, values = {x = 100}},
    }
  })
  
  anim.elapsed = 0.5
  local result = anim:interpolate()
  
  -- At t=0.5, easing(0.5) = 0.25, so x = 0 + 100 * 0.25 = 25
  luaunit.assertAlmostEquals(result.x, 25, 1)
end

-- Test caching behavior with keyframes
function TestKeyframeAnimation:testKeyframeCaching()
  local anim = Animation.keyframes({
    duration = 1,
    keyframes = {
      {at = 0, values = {x = 0}},
      {at = 1, values = {x = 100}},
    }
  })
  
  anim.elapsed = 0.5
  local result1 = anim:interpolate()
  local result2 = anim:interpolate() -- Should return cached result
  
  luaunit.assertEquals(result1, result2) -- Should be same table
end

os.exit(luaunit.LuaUnit.run())
