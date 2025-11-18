local luaunit = require("testing.luaunit")
require("testing.loveStub")

local Animation = require("modules.Animation")
local Color = require("modules.Color")
local Transform = require("modules.Transform")
local ErrorHandler = require("modules.ErrorHandler")
local ErrorCodes = require("modules.ErrorCodes")

-- Initialize ErrorHandler
ErrorHandler.init({ ErrorCodes = ErrorCodes })
Animation.initializeErrorHandler(ErrorHandler)
Color.initializeErrorHandler(ErrorHandler)

-- Make Color module available to Animation
Animation.setColorModule(Color)

TestAnimationProperties = {}

function TestAnimationProperties:setUp()
  -- Reset state before each test
end

-- Test Color.lerp() method

function TestAnimationProperties:testColorLerp_MidPoint()
  local colorA = Color.new(0, 0, 0, 1) -- Black
  local colorB = Color.new(1, 1, 1, 1) -- White
  local result = Color.lerp(colorA, colorB, 0.5)

  luaunit.assertAlmostEquals(result.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.g, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.b, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.a, 1, 0.01)
end

function TestAnimationProperties:testColorLerp_StartPoint()
  local colorA = Color.new(1, 0, 0, 1) -- Red
  local colorB = Color.new(0, 0, 1, 1) -- Blue
  local result = Color.lerp(colorA, colorB, 0)

  luaunit.assertAlmostEquals(result.r, 1, 0.01)
  luaunit.assertAlmostEquals(result.g, 0, 0.01)
  luaunit.assertAlmostEquals(result.b, 0, 0.01)
end

function TestAnimationProperties:testColorLerp_EndPoint()
  local colorA = Color.new(1, 0, 0, 1) -- Red
  local colorB = Color.new(0, 0, 1, 1) -- Blue
  local result = Color.lerp(colorA, colorB, 1)

  luaunit.assertAlmostEquals(result.r, 0, 0.01)
  luaunit.assertAlmostEquals(result.g, 0, 0.01)
  luaunit.assertAlmostEquals(result.b, 1, 0.01)
end

function TestAnimationProperties:testColorLerp_Alpha()
  local colorA = Color.new(1, 1, 1, 0) -- Transparent white
  local colorB = Color.new(1, 1, 1, 1) -- Opaque white
  local result = Color.lerp(colorA, colorB, 0.5)

  luaunit.assertAlmostEquals(result.a, 0.5, 0.01)
end

function TestAnimationProperties:testColorLerp_InvalidInputs()
  -- Should handle invalid inputs gracefully
  local result = Color.lerp("invalid", "invalid", 0.5)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(getmetatable(result), Color)
end

function TestAnimationProperties:testColorLerp_ClampT()
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

function TestAnimationProperties:testPositionAnimation_XProperty()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.x, 50, 0.01)
end

function TestAnimationProperties:testPositionAnimation_YProperty()
  local anim = Animation.new({
    duration = 1,
    start = { y = 0 },
    final = { y = 200 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.y, 100, 0.01)
end

function TestAnimationProperties:testPositionAnimation_XY()
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

function TestAnimationProperties:testColorAnimation_BackgroundColor()
  local anim = Animation.new({
    duration = 1,
    start = { backgroundColor = Color.new(1, 0, 0, 1) }, -- Red
    final = { backgroundColor = Color.new(0, 0, 1, 1) }, -- Blue
  })
  anim:setColorModule(Color)

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.backgroundColor.b, 0.5, 0.01)
end

function TestAnimationProperties:testColorAnimation_MultipleColors()
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
  anim:setColorModule(Color)

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertNotNil(result.borderColor)
  luaunit.assertNotNil(result.textColor)

  -- Mid-point should be (0.5, 0.5, 0.5) for backgroundColor
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.backgroundColor.g, 0.5, 0.01)
end

function TestAnimationProperties:testColorAnimation_WithoutColorModule()
  -- Should not interpolate colors without Color module set
  local anim = Animation.new({
    duration = 1,
    start = { backgroundColor = Color.new(1, 0, 0, 1) },
    final = { backgroundColor = Color.new(0, 0, 1, 1) },
  })
  -- Don't set Color module

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNil(result.backgroundColor)
end

function TestAnimationProperties:testColorAnimation_HexColors()
  local anim = Animation.new({
    duration = 1,
    start = { backgroundColor = "#FF0000" }, -- Red
    final = { backgroundColor = "#0000FF" }, -- Blue
  })
  anim:setColorModule(Color)

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.5, 0.01)
end

function TestAnimationProperties:testColorAnimation_NamedColors()
  local anim = Animation.new({
    duration = 1,
    start = { backgroundColor = "red" },
    final = { backgroundColor = "blue" },
  })
  anim:setColorModule(Color)

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertNotNil(result.backgroundColor)
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.5, 0.01)
end

-- Test Numeric Property Animation

function TestAnimationProperties:testNumericAnimation_Gap()
  local anim = Animation.new({
    duration = 1,
    start = { gap = 0 },
    final = { gap = 20 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.gap, 10, 0.01)
end

function TestAnimationProperties:testNumericAnimation_ImageOpacity()
  local anim = Animation.new({
    duration = 1,
    start = { imageOpacity = 0 },
    final = { imageOpacity = 1 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.imageOpacity, 0.5, 0.01)
end

function TestAnimationProperties:testNumericAnimation_BorderWidth()
  local anim = Animation.new({
    duration = 1,
    start = { borderWidth = 1 },
    final = { borderWidth = 10 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.borderWidth, 5.5, 0.01)
end

function TestAnimationProperties:testNumericAnimation_FontSize()
  local anim = Animation.new({
    duration = 1,
    start = { fontSize = 12 },
    final = { fontSize = 24 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.fontSize, 18, 0.01)
end

function TestAnimationProperties:testNumericAnimation_MultipleProperties()
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

function TestAnimationProperties:testTableAnimation_Padding()
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

function TestAnimationProperties:testTableAnimation_Margin()
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

function TestAnimationProperties:testTableAnimation_CornerRadius()
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

function TestAnimationProperties:testTableAnimation_PartialKeys()
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

function TestAnimationProperties:testTableAnimation_NonNumericValues()
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

function TestAnimationProperties:testCombinedAnimation_AllTypes()
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
  anim:setColorModule(Color)

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

function TestAnimationProperties:testCombinedAnimation_WithEasing()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0, backgroundColor = Color.new(0, 0, 0, 1) },
    final = { x = 100, backgroundColor = Color.new(1, 1, 1, 1) },
    easing = "easeInQuad",
  })
  anim:setColorModule(Color)

  anim:update(0.5)
  local result = anim:interpolate()

  -- With easeInQuad, at t=0.5, eased value should be 0.25
  luaunit.assertAlmostEquals(result.x, 25, 0.01)
  luaunit.assertAlmostEquals(result.backgroundColor.r, 0.25, 0.01)
end

-- Test Backward Compatibility

function TestAnimationProperties:testBackwardCompatibility_WidthHeightOpacity()
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

function TestAnimationProperties:testBackwardCompatibility_FadeHelper()
  local anim = Animation.fade(1, 0, 1)

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01)
end

function TestAnimationProperties:testBackwardCompatibility_ScaleHelper()
  local anim = Animation.scale(1, { width = 100, height = 100 }, { width = 200, height = 200 })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.width, 150, 0.01)
  luaunit.assertAlmostEquals(result.height, 150, 0.01)
end

-- Test Edge Cases

function TestAnimationProperties:testEdgeCase_MissingStartValue()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0 },
    final = { x = 100, y = 100 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.x, 50, 0.01)
  luaunit.assertNil(result.y) -- Should be nil since start.y is missing
end

function TestAnimationProperties:testEdgeCase_MissingFinalValue()
  local anim = Animation.new({
    duration = 1,
    start = { x = 0, y = 0 },
    final = { x = 100 },
  })

  anim:update(0.5)
  local result = anim:interpolate()

  luaunit.assertAlmostEquals(result.x, 50, 0.01)
  luaunit.assertNil(result.y) -- Should be nil since final.y is missing
end

function TestAnimationProperties:testEdgeCase_EmptyTables()
  local anim = Animation.new({
    duration = 1,
    start = {},
    final = {},
  })

  anim:update(0.5)
  local result = anim:interpolate()

  -- Should not error, just return empty result
  luaunit.assertNotNil(result)
end

function TestAnimationProperties:testEdgeCase_CachedResult()
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

function TestAnimationProperties:testEdgeCase_ResultInvalidatedOnUpdate()
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

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
