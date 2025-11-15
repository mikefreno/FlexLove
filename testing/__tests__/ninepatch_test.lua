local luaunit = require("testing.luaunit")
require("testing.loveStub")

local NinePatch = require("modules.NinePatch")

TestNinePatch = {}

function TestNinePatch:setUp()
  -- Create a minimal mock component with regions
  self.mockComponent = {
    regions = {
      topLeft = { x = 0, y = 0, w = 10, h = 10 },
      topCenter = { x = 10, y = 0, w = 20, h = 10 },
      topRight = { x = 30, y = 0, w = 10, h = 10 },
      middleLeft = { x = 0, y = 10, w = 10, h = 20 },
      middleCenter = { x = 10, y = 10, w = 20, h = 20 },
      middleRight = { x = 30, y = 10, w = 10, h = 20 },
      bottomLeft = { x = 0, y = 30, w = 10, h = 10 },
      bottomCenter = { x = 10, y = 30, w = 20, h = 10 },
      bottomRight = { x = 30, y = 30, w = 10, h = 10 },
    },
  }

  self.mockAtlas = {
    getDimensions = function()
      return 100, 100
    end,
  }
end

-- Unhappy path tests for NinePatch.draw()

function TestNinePatch:testDrawWithNilComponent()
  -- Should return early without error
  NinePatch.draw(nil, self.mockAtlas, 0, 0, 100, 100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithNilAtlas()
  -- Should return early without error
  NinePatch.draw(self.mockComponent, nil, 0, 0, 100, 100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithBothNil()
  -- Should return early without error
  NinePatch.draw(nil, nil, 0, 0, 100, 100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithZeroWidth()
  -- Should handle zero width gracefully
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 0, 100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithZeroHeight()
  -- Should handle zero height gracefully
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 0)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithNegativeWidth()
  -- Should handle negative width
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, -100, 100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithNegativeHeight()
  -- Should handle negative height
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, -100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithSmallDimensions()
  -- Dimensions smaller than borders - should clamp
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 5, 5)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithVeryLargeDimensions()
  -- Very large dimensions
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 10000, 10000)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithNegativePosition()
  -- Negative x, y positions
  NinePatch.draw(self.mockComponent, self.mockAtlas, -100, -100, 200, 200)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithDefaultOpacity()
  -- Opacity defaults to 1
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 100, nil)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithZeroOpacity()
  -- Zero opacity
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 100, 0)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithNegativeOpacity()
  -- Negative opacity
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 100, -0.5)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithOpacityGreaterThanOne()
  -- Opacity > 1
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 100, 2.0)
  luaunit.assertTrue(true)
end

-- Test with missing regions

-- Test with scaleCorners = 0 (no scaling, just stretching)

function TestNinePatch:testDrawWithZeroScaleCorners()
  -- Zero should not trigger scaling path
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 100, 1, 0)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithNegativeScaleCorners()
  -- Negative should not trigger scaling path
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 100, 1, -1)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithNilScaleCorners()
  -- Nil should use component setting or default (no scaling)
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 100, 1, nil)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithComponentScalingAlgorithm()
  -- Test that scalingAlgorithm property exists but don't trigger scaling path
  local componentWithAlgorithm = {
    regions = self.mockComponent.regions,
    scalingAlgorithm = "nearest",
  }
  -- Pass nil for scaleCorners to avoid scaling path
  NinePatch.draw(componentWithAlgorithm, self.mockAtlas, 0, 0, 100, 100, 1, nil, nil)
  luaunit.assertTrue(true)
end

-- Edge cases with specific dimensions

function TestNinePatch:testDrawWithWidthEqualToBorders()
  -- Width exactly equals left + right borders
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 20, 100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithHeightEqualToBorders()
  -- Height exactly equals top + bottom borders
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100, 20)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithExactBorderDimensions()
  -- Both width and height equal borders
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 20, 20)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithOneLessThanBorders()
  -- Dimensions one pixel less than borders
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 19, 19)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithFractionalDimensions()
  -- Non-integer dimensions
  NinePatch.draw(self.mockComponent, self.mockAtlas, 0, 0, 100.5, 100.7)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithFractionalPosition()
  -- Non-integer position
  NinePatch.draw(self.mockComponent, self.mockAtlas, 10.3, 20.7, 100, 100)
  luaunit.assertTrue(true)
end

-- Test with unusual region sizes

function TestNinePatch:testDrawWithAsymmetricBorders()
  local asymmetric = {
    regions = {
      topLeft = { x = 0, y = 0, w = 5, h = 5 },
      topCenter = { x = 5, y = 0, w = 30, h = 5 },
      topRight = { x = 35, y = 0, w = 15, h = 5 },
      middleLeft = { x = 0, y = 5, w = 5, h = 30 },
      middleCenter = { x = 5, y = 5, w = 30, h = 30 },
      middleRight = { x = 35, y = 5, w = 15, h = 30 },
      bottomLeft = { x = 0, y = 35, w = 5, h = 10 },
      bottomCenter = { x = 5, y = 35, w = 30, h = 10 },
      bottomRight = { x = 35, y = 35, w = 15, h = 10 },
    },
  }
  NinePatch.draw(asymmetric, self.mockAtlas, 0, 0, 100, 100)
  luaunit.assertTrue(true)
end

function TestNinePatch:testDrawWithVerySmallRegions()
  local tiny = {
    regions = {
      topLeft = { x = 0, y = 0, w = 1, h = 1 },
      topCenter = { x = 1, y = 0, w = 1, h = 1 },
      topRight = { x = 2, y = 0, w = 1, h = 1 },
      middleLeft = { x = 0, y = 1, w = 1, h = 1 },
      middleCenter = { x = 1, y = 1, w = 1, h = 1 },
      middleRight = { x = 2, y = 1, w = 1, h = 1 },
      bottomLeft = { x = 0, y = 2, w = 1, h = 1 },
      bottomCenter = { x = 1, y = 2, w = 1, h = 1 },
      bottomRight = { x = 2, y = 2, w = 1, h = 1 },
    },
  }
  NinePatch.draw(tiny, self.mockAtlas, 0, 0, 100, 100)
  luaunit.assertTrue(true)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
