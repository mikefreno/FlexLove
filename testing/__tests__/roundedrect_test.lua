local luaunit = require("testing.luaunit")
require("testing.loveStub")

local RoundedRect = require("modules.RoundedRect")

TestRoundedRect = {}

-- Test: getPoints with all corners rounded
function TestRoundedRect:testGetPointsAllCornersRounded()
  local points = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  }, 10)

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
  luaunit.assertEquals(#points % 2, 0) -- Should be even (x,y pairs)
end

-- Test: getPoints with no rounded corners (zero radius)
function TestRoundedRect:testGetPointsNoRounding()
  local points = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 0,
    topRight = 0,
    bottomLeft = 0,
    bottomRight = 0,
  })

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: getPoints with asymmetric corners
function TestRoundedRect:testGetPointsAsymmetric()
  local points = RoundedRect.getPoints(10, 10, 200, 150, {
    topLeft = 5,
    topRight = 15,
    bottomLeft = 20,
    bottomRight = 10,
  })

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: getPoints with very large radius (should be clamped)
function TestRoundedRect:testGetPointsLargeRadius()
  local points = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 1000,
    topRight = 1000,
    bottomLeft = 1000,
    bottomRight = 1000,
  })

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: getPoints with custom segments
function TestRoundedRect:testGetPointsCustomSegments()
  local points1 = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  }, 5)

  local points2 = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  }, 20)

  luaunit.assertNotNil(points1)
  luaunit.assertNotNil(points2)
  -- More segments should produce more points
  luaunit.assertTrue(#points2 > #points1)
end

-- Test: getPoints with very small dimensions
function TestRoundedRect:testGetPointsSmallDimensions()
  local points = RoundedRect.getPoints(0, 0, 10, 10, {
    topLeft = 2,
    topRight = 2,
    bottomLeft = 2,
    bottomRight = 2,
  })

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: getPoints with negative position
function TestRoundedRect:testGetPointsNegativePosition()
  local points = RoundedRect.getPoints(-50, -50, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  })

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: getPoints with one corner rounded
function TestRoundedRect:testGetPointsOneCorner()
  local points = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 0,
    topRight = 0,
    bottomLeft = 0,
    bottomRight = 15,
  })

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: getPoints with fractional dimensions
function TestRoundedRect:testGetPointsFractional()
  local points = RoundedRect.getPoints(0.5, 0.5, 100.7, 50.3, {
    topLeft = 8.5,
    topRight = 8.5,
    bottomLeft = 8.5,
    bottomRight = 8.5,
  })

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: draw with rounded corners (fill mode)
function TestRoundedRect:testDrawFillWithRounding()
  -- Should not error
  RoundedRect.draw("fill", 0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  })
  luaunit.assertTrue(true)
end

-- Test: draw with no rounded corners (should use regular rectangle)
function TestRoundedRect:testDrawNoRounding()
  -- Should use love.graphics.rectangle
  RoundedRect.draw("fill", 0, 0, 100, 100, {
    topLeft = 0,
    topRight = 0,
    bottomLeft = 0,
    bottomRight = 0,
  })
  luaunit.assertTrue(true)
end

-- Test: draw with line mode
function TestRoundedRect:testDrawLineMode()
  RoundedRect.draw("line", 0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  })
  luaunit.assertTrue(true)
end

-- Test: stencilFunction returns a function
function TestRoundedRect:testStencilFunction()
  local stencil = RoundedRect.stencilFunction(0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  })

  luaunit.assertEquals(type(stencil), "function")
end

-- Test: stencilFunction can be called
function TestRoundedRect:testStencilFunctionExecute()
  local stencil = RoundedRect.stencilFunction(0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  })

  -- Should not error when executed
  stencil()
  luaunit.assertTrue(true)
end

-- Test: getPoints with zero-width rectangle
function TestRoundedRect:testGetPointsZeroWidth()
  local points = RoundedRect.getPoints(0, 0, 0, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  })

  luaunit.assertNotNil(points)
end

-- Test: getPoints with zero-height rectangle
function TestRoundedRect:testGetPointsZeroHeight()
  local points = RoundedRect.getPoints(0, 0, 100, 0, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  })

  luaunit.assertNotNil(points)
end

-- Test: draw with mixed zero and non-zero corners
function TestRoundedRect:testDrawMixedCorners()
  RoundedRect.draw("fill", 0, 0, 100, 100, {
    topLeft = 0,
    topRight = 15,
    bottomLeft = 10,
    bottomRight = 0,
  })
  luaunit.assertTrue(true)
end

-- Test: getPoints with very high segment count
function TestRoundedRect:testGetPointsHighSegments()
  local points = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  }, 100)

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

-- Test: getPoints with segment count of 1
function TestRoundedRect:testGetPointsOneSegment()
  local points = RoundedRect.getPoints(0, 0, 100, 100, {
    topLeft = 10,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 10,
  }, 1)

  luaunit.assertNotNil(points)
  luaunit.assertTrue(#points > 0)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
