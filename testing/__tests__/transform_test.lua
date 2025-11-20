local luaunit = require("testing.luaunit")
require("testing.loveStub")

local Animation = require("modules.Animation")
local Transform = Animation.Transform

TestTransform = {}

function TestTransform:setUp()
  -- Reset state before each test
end

-- Test Transform.new()

function TestTransform:testNew_DefaultValues()
  local transform = Transform.new()

  luaunit.assertNotNil(transform)
  luaunit.assertEquals(transform.rotate, 0)
  luaunit.assertEquals(transform.scaleX, 1)
  luaunit.assertEquals(transform.scaleY, 1)
  luaunit.assertEquals(transform.translateX, 0)
  luaunit.assertEquals(transform.translateY, 0)
  luaunit.assertEquals(transform.skewX, 0)
  luaunit.assertEquals(transform.skewY, 0)
  luaunit.assertEquals(transform.originX, 0.5)
  luaunit.assertEquals(transform.originY, 0.5)
end

function TestTransform:testNew_CustomValues()
  local transform = Transform.new({
    rotate = math.pi / 4,
    scaleX = 2,
    scaleY = 3,
    translateX = 100,
    translateY = 200,
    skewX = 0.1,
    skewY = 0.2,
    originX = 0,
    originY = 1,
  })

  luaunit.assertAlmostEquals(transform.rotate, math.pi / 4, 0.01)
  luaunit.assertEquals(transform.scaleX, 2)
  luaunit.assertEquals(transform.scaleY, 3)
  luaunit.assertEquals(transform.translateX, 100)
  luaunit.assertEquals(transform.translateY, 200)
  luaunit.assertAlmostEquals(transform.skewX, 0.1, 0.01)
  luaunit.assertAlmostEquals(transform.skewY, 0.2, 0.01)
  luaunit.assertEquals(transform.originX, 0)
  luaunit.assertEquals(transform.originY, 1)
end

function TestTransform:testNew_PartialValues()
  local transform = Transform.new({
    rotate = math.pi,
    scaleX = 2,
  })

  luaunit.assertAlmostEquals(transform.rotate, math.pi, 0.01)
  luaunit.assertEquals(transform.scaleX, 2)
  luaunit.assertEquals(transform.scaleY, 1) -- default
  luaunit.assertEquals(transform.translateX, 0) -- default
end

function TestTransform:testNew_EmptyProps()
  local transform = Transform.new({})

  -- Should use all defaults
  luaunit.assertEquals(transform.rotate, 0)
  luaunit.assertEquals(transform.scaleX, 1)
  luaunit.assertEquals(transform.originX, 0.5)
end

function TestTransform:testNew_NilProps()
  local transform = Transform.new(nil)

  -- Should use all defaults
  luaunit.assertEquals(transform.rotate, 0)
  luaunit.assertEquals(transform.scaleX, 1)
end

-- Test Transform.lerp()

function TestTransform:testLerp_MidPoint()
  local from = Transform.new({ rotate = 0, scaleX = 1, scaleY = 1 })
  local to = Transform.new({ rotate = math.pi, scaleX = 2, scaleY = 3 })

  local result = Transform.lerp(from, to, 0.5)

  luaunit.assertAlmostEquals(result.rotate, math.pi / 2, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 1.5, 0.01)
  luaunit.assertAlmostEquals(result.scaleY, 2, 0.01)
end

function TestTransform:testLerp_StartPoint()
  local from = Transform.new({ rotate = 0, scaleX = 1 })
  local to = Transform.new({ rotate = math.pi, scaleX = 2 })

  local result = Transform.lerp(from, to, 0)

  luaunit.assertAlmostEquals(result.rotate, 0, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 1, 0.01)
end

function TestTransform:testLerp_EndPoint()
  local from = Transform.new({ rotate = 0, scaleX = 1 })
  local to = Transform.new({ rotate = math.pi, scaleX = 2 })

  local result = Transform.lerp(from, to, 1)

  luaunit.assertAlmostEquals(result.rotate, math.pi, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 2, 0.01)
end

function TestTransform:testLerp_AllProperties()
  local from = Transform.new({
    rotate = 0,
    scaleX = 1,
    scaleY = 1,
    translateX = 0,
    translateY = 0,
    skewX = 0,
    skewY = 0,
    originX = 0,
    originY = 0,
  })

  local to = Transform.new({
    rotate = math.pi,
    scaleX = 2,
    scaleY = 3,
    translateX = 100,
    translateY = 200,
    skewX = 0.2,
    skewY = 0.4,
    originX = 1,
    originY = 1,
  })

  local result = Transform.lerp(from, to, 0.5)

  luaunit.assertAlmostEquals(result.rotate, math.pi / 2, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 1.5, 0.01)
  luaunit.assertAlmostEquals(result.scaleY, 2, 0.01)
  luaunit.assertAlmostEquals(result.translateX, 50, 0.01)
  luaunit.assertAlmostEquals(result.translateY, 100, 0.01)
  luaunit.assertAlmostEquals(result.skewX, 0.1, 0.01)
  luaunit.assertAlmostEquals(result.skewY, 0.2, 0.01)
  luaunit.assertAlmostEquals(result.originX, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.originY, 0.5, 0.01)
end

function TestTransform:testLerp_InvalidInputs()
  -- Should handle nil gracefully
  local result = Transform.lerp(nil, nil, 0.5)

  luaunit.assertNotNil(result)
  luaunit.assertEquals(result.rotate, 0)
  luaunit.assertEquals(result.scaleX, 1)
end

function TestTransform:testLerp_ClampT()
  local from = Transform.new({ scaleX = 1 })
  local to = Transform.new({ scaleX = 2 })

  -- Test t > 1
  local result1 = Transform.lerp(from, to, 1.5)
  luaunit.assertAlmostEquals(result1.scaleX, 2, 0.01)

  -- Test t < 0
  local result2 = Transform.lerp(from, to, -0.5)
  luaunit.assertAlmostEquals(result2.scaleX, 1, 0.01)
end

function TestTransform:testLerp_InvalidT()
  local from = Transform.new({ scaleX = 1 })
  local to = Transform.new({ scaleX = 2 })

  -- Test NaN
  local result1 = Transform.lerp(from, to, 0 / 0)
  luaunit.assertAlmostEquals(result1.scaleX, 1, 0.01) -- Should default to 0

  -- Test Infinity
  local result2 = Transform.lerp(from, to, math.huge)
  luaunit.assertAlmostEquals(result2.scaleX, 2, 0.01) -- Should clamp to 1
end

-- Test Transform.isIdentity()

function TestTransform:testIsIdentity_True()
  local transform = Transform.new()
  luaunit.assertTrue(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_Nil()
  luaunit.assertTrue(Transform.isIdentity(nil))
end

function TestTransform:testIsIdentity_FalseRotate()
  local transform = Transform.new({ rotate = 0.1 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_FalseScale()
  local transform = Transform.new({ scaleX = 2 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_FalseTranslate()
  local transform = Transform.new({ translateX = 10 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_FalseSkew()
  local transform = Transform.new({ skewX = 0.1 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

-- Test Transform.clone()

function TestTransform:testClone_AllProperties()
  local original = Transform.new({
    rotate = math.pi / 4,
    scaleX = 2,
    scaleY = 3,
    translateX = 100,
    translateY = 200,
    skewX = 0.1,
    skewY = 0.2,
    originX = 0.25,
    originY = 0.75,
  })

  local clone = Transform.clone(original)

  luaunit.assertAlmostEquals(clone.rotate, math.pi / 4, 0.01)
  luaunit.assertEquals(clone.scaleX, 2)
  luaunit.assertEquals(clone.scaleY, 3)
  luaunit.assertEquals(clone.translateX, 100)
  luaunit.assertEquals(clone.translateY, 200)
  luaunit.assertAlmostEquals(clone.skewX, 0.1, 0.01)
  luaunit.assertAlmostEquals(clone.skewY, 0.2, 0.01)
  luaunit.assertAlmostEquals(clone.originX, 0.25, 0.01)
  luaunit.assertAlmostEquals(clone.originY, 0.75, 0.01)

  -- Ensure it's a different object (use raw comparison)
  luaunit.assertFalse(rawequal(clone, original), "Clone should be a different table instance")
end

function TestTransform:testClone_Nil()
  local clone = Transform.clone(nil)

  luaunit.assertNotNil(clone)
  luaunit.assertEquals(clone.rotate, 0)
  luaunit.assertEquals(clone.scaleX, 1)
end

function TestTransform:testClone_Mutation()
  local original = Transform.new({ rotate = 0 })
  local clone = Transform.clone(original)

  -- Mutate clone
  clone.rotate = math.pi

  -- Original should be unchanged
  luaunit.assertEquals(original.rotate, 0)
  luaunit.assertAlmostEquals(clone.rotate, math.pi, 0.01)
end

-- Integration Tests

function TestTransform:testTransformAnimation()
  local anim = Animation.new({
    duration = 1,
    start = { transform = Transform.new({ rotate = 0, scaleX = 1 }) },
    final = { transform = Transform.new({ rotate = math.pi, scaleX = 2 }) },
  })

  anim:update(0.5)

  local result = anim:interpolate()

  luaunit.assertNotNil(result.transform)
  luaunit.assertAlmostEquals(result.transform.rotate, math.pi / 2, 0.01)
  luaunit.assertAlmostEquals(result.transform.scaleX, 1.5, 0.01)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
