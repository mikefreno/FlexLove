local luaunit = require("testing.luaunit")
require("testing.loveStub")

local Easing = require("modules.Easing")
local ErrorHandler = require("modules.ErrorHandler")
local ErrorCodes = require("modules.ErrorCodes")

-- Initialize ErrorHandler
ErrorHandler.init({ ErrorCodes = ErrorCodes })

TestEasing = {}

function TestEasing:setUp()
  -- Reset state before each test
end

-- Test that all easing functions exist
function TestEasing:testAllEasingFunctionsExist()
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

-- Test that all easing functions accept t parameter (0-1)
function TestEasing:testEasingFunctionsAcceptParameter()
  local result = Easing.linear(0.5)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(type(result), "number")
end

-- Test linear easing
function TestEasing:testLinear()
  luaunit.assertEquals(Easing.linear(0), 0)
  luaunit.assertEquals(Easing.linear(0.5), 0.5)
  luaunit.assertEquals(Easing.linear(1), 1)
end

-- Test easeInQuad
function TestEasing:testEaseInQuad()
  luaunit.assertEquals(Easing.easeInQuad(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInQuad(0.5), 0.25, 0.01)
  luaunit.assertEquals(Easing.easeInQuad(1), 1)
end

-- Test easeOutQuad
function TestEasing:testEaseOutQuad()
  luaunit.assertEquals(Easing.easeOutQuad(0), 0)
  luaunit.assertAlmostEquals(Easing.easeOutQuad(0.5), 0.75, 0.01)
  luaunit.assertEquals(Easing.easeOutQuad(1), 1)
end

-- Test easeInOutQuad
function TestEasing:testEaseInOutQuad()
  luaunit.assertEquals(Easing.easeInOutQuad(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutQuad(0.5), 0.5, 0.01)
  luaunit.assertEquals(Easing.easeInOutQuad(1), 1)
end

-- Test easeInSine
function TestEasing:testEaseInSine()
  luaunit.assertEquals(Easing.easeInSine(0), 0)
  local mid = Easing.easeInSine(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeInSine(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeInSine(1), 1, 0.01)
end

-- Test easeOutSine
function TestEasing:testEaseOutSine()
  luaunit.assertEquals(Easing.easeOutSine(0), 0)
  local mid = Easing.easeOutSine(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeOutSine(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeOutSine(1), 1, 0.01)
end

-- Test easeInOutSine
function TestEasing:testEaseInOutSine()
  luaunit.assertEquals(Easing.easeInOutSine(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutSine(0.5), 0.5, 0.01)
  luaunit.assertAlmostEquals(Easing.easeInOutSine(1), 1, 0.01)
end

-- Test easeInQuint
function TestEasing:testEaseInQuint()
  luaunit.assertEquals(Easing.easeInQuint(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInQuint(0.5), 0.03125, 0.01)
  luaunit.assertEquals(Easing.easeInQuint(1), 1)
end

-- Test easeOutQuint
function TestEasing:testEaseOutQuint()
  luaunit.assertEquals(Easing.easeOutQuint(0), 0)
  luaunit.assertAlmostEquals(Easing.easeOutQuint(0.5), 0.96875, 0.01)
  luaunit.assertEquals(Easing.easeOutQuint(1), 1)
end

-- Test easeInCirc
function TestEasing:testEaseInCirc()
  luaunit.assertEquals(Easing.easeInCirc(0), 0)
  local mid = Easing.easeInCirc(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeInCirc(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeInCirc(1), 1, 0.01)
end

-- Test easeOutCirc
function TestEasing:testEaseOutCirc()
  luaunit.assertEquals(Easing.easeOutCirc(0), 0)
  local mid = Easing.easeOutCirc(0.5)
  luaunit.assertTrue(mid > 0 and mid < 1, "easeOutCirc(0.5) should be between 0 and 1")
  luaunit.assertAlmostEquals(Easing.easeOutCirc(1), 1, 0.01)
end

-- Test easeInOutCirc
function TestEasing:testEaseInOutCirc()
  luaunit.assertEquals(Easing.easeInOutCirc(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutCirc(0.5), 0.5, 0.01)
  luaunit.assertAlmostEquals(Easing.easeInOutCirc(1), 1, 0.01)
end

-- Test easeInBack (should overshoot at start)
function TestEasing:testEaseInBack()
  luaunit.assertEquals(Easing.easeInBack(0), 0)
  local early = Easing.easeInBack(0.3)
  luaunit.assertTrue(early < 0, "easeInBack should go negative (overshoot) early on")
  luaunit.assertAlmostEquals(Easing.easeInBack(1), 1, 0.001)
end

-- Test easeOutBack (should overshoot at end)
function TestEasing:testEaseOutBack()
  luaunit.assertAlmostEquals(Easing.easeOutBack(0), 0, 0.001)
  local late = Easing.easeOutBack(0.7)
  luaunit.assertTrue(late > 0.7, "easeOutBack should overshoot at the end")
  luaunit.assertAlmostEquals(Easing.easeOutBack(1), 1, 0.01)
end

-- Test easeInElastic (should oscillate)
function TestEasing:testEaseInElastic()
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
function TestEasing:testEaseOutElastic()
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
function TestEasing:testEaseInBounce()
  luaunit.assertEquals(Easing.easeInBounce(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInBounce(1), 1, 0.01)
  -- Bounce should have multiple "bounces" (local minima)
  local result = Easing.easeInBounce(0.5)
  luaunit.assertTrue(result >= 0 and result <= 1, "easeInBounce should stay within 0-1 range")
end

-- Test easeOutBounce
function TestEasing:testEaseOutBounce()
  luaunit.assertEquals(Easing.easeOutBounce(0), 0)
  luaunit.assertAlmostEquals(Easing.easeOutBounce(1), 1, 0.01)
  -- Bounce should have bounces
  local result = Easing.easeOutBounce(0.8)
  luaunit.assertTrue(result >= 0 and result <= 1, "easeOutBounce should stay within 0-1 range")
end

-- Test easeInOutBounce
function TestEasing:testEaseInOutBounce()
  luaunit.assertEquals(Easing.easeInOutBounce(0), 0)
  luaunit.assertAlmostEquals(Easing.easeInOutBounce(0.5), 0.5, 0.01)
  luaunit.assertAlmostEquals(Easing.easeInOutBounce(1), 1, 0.01)
end

-- Test configurable back() factory
function TestEasing:testBackFactory()
  local customBack = Easing.back(2.5)
  luaunit.assertEquals(type(customBack), "function")
  luaunit.assertEquals(customBack(0), 0)
  luaunit.assertEquals(customBack(1), 1)
  -- Should overshoot with custom amount
  local mid = customBack(0.3)
  luaunit.assertTrue(mid < 0, "Custom back easing should overshoot")
end

-- Test configurable elastic() factory
function TestEasing:testElasticFactory()
  local customElastic = Easing.elastic(1.5, 0.4)
  luaunit.assertEquals(type(customElastic), "function")
  luaunit.assertEquals(customElastic(0), 0)
  luaunit.assertAlmostEquals(customElastic(1), 1, 0.01)
end

-- Test that all InOut easings are symmetric around 0.5
function TestEasing:testInOutSymmetry()
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
function TestEasing:testBoundaryConditions()
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

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
