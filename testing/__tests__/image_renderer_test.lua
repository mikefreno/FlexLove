local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
require("testing.loveStub")

local ImageRenderer = require("modules.ImageRenderer")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

TestImageRenderer = {}

function TestImageRenderer:setUp()
  -- Create a mock image for testing
  self.mockImage = {
    getDimensions = function()
      return 100, 100
    end,
  }
end

-- Unhappy path tests for calculateFit

function TestImageRenderer:testCalculateFitWithZeroImageWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(0, 100, 200, 200, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithZeroImageHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 0, 200, 200, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithNegativeImageWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(-100, 100, 200, 200, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithNegativeImageHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, -100, 200, 200, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithZeroBoundsWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, 0, 200, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithZeroBoundsHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, 200, 0, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithNegativeBoundsWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, -200, 200, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithNegativeBoundsHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, 200, -200, "fill")
  end)
end

function TestImageRenderer:testCalculateFitWithInvalidFitMode()
  -- Now uses 'fill' fallback with warning instead of error
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "invalid-mode")
  luaunit.assertNotNil(result)
  -- Should fall back to 'fill' mode behavior (scales to fill bounds)
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRenderer:testCalculateFitWithNilFitMode()
  -- Should default to "fill"
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, nil)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result.dw, 200)
  luaunit.assertEquals(result.dh, 200)
end

function TestImageRenderer:testCalculateFitFillMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "fill")
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRenderer:testCalculateFitContainMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "contain")
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRenderer:testCalculateFitCoverMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "cover")
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRenderer:testCalculateFitNoneMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "none")
  luaunit.assertEquals(result.scaleX, 1)
  luaunit.assertEquals(result.scaleY, 1)
end

function TestImageRenderer:testCalculateFitScaleDownModeWithLargeImage()
  local result = ImageRenderer.calculateFit(300, 300, 200, 200, "scale-down")
  -- Should behave like contain for larger images
  luaunit.assertNotNil(result)
end

function TestImageRenderer:testCalculateFitScaleDownModeWithSmallImage()
  local result = ImageRenderer.calculateFit(50, 50, 200, 200, "scale-down")
  -- Should behave like none for smaller images
  luaunit.assertEquals(result.scaleX, 1)
  luaunit.assertEquals(result.scaleY, 1)
end

-- Unhappy path tests for _parsePosition

function TestImageRenderer:testParsePositionWithNil()
  local x, y = ImageRenderer._parsePosition(nil)
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRenderer:testParsePositionWithEmptyString()
  local x, y = ImageRenderer._parsePosition("")
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRenderer:testParsePositionWithInvalidType()
  local x, y = ImageRenderer._parsePosition(123)
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRenderer:testParsePositionWithInvalidKeyword()
  local x, y = ImageRenderer._parsePosition("invalid keyword")
  -- Should default to center
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRenderer:testParsePositionWithMixedValid()
  local x, y = ImageRenderer._parsePosition("left top")
  luaunit.assertEquals(x, 0)
  luaunit.assertEquals(y, 0)
end

function TestImageRenderer:testParsePositionWithPercentage()
  local x, y = ImageRenderer._parsePosition("75% 25%")
  luaunit.assertAlmostEquals(x, 0.75, 0.01)
  luaunit.assertAlmostEquals(y, 0.25, 0.01)
end

function TestImageRenderer:testParsePositionWithOutOfRangePercentage()
  local x, y = ImageRenderer._parsePosition("150% -50%")
  -- 150% clamps to 1, but -50% doesn't match pattern so defaults to 0.5
  luaunit.assertEquals(x, 1)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRenderer:testParsePositionWithSingleValue()
  local x, y = ImageRenderer._parsePosition("left")
  luaunit.assertEquals(x, 0)
  luaunit.assertEquals(y, 0.5) -- Should use center for Y
end

function TestImageRenderer:testParsePositionWithSinglePercentage()
  local x, y = ImageRenderer._parsePosition("25%")
  luaunit.assertAlmostEquals(x, 0.25, 0.01)
  luaunit.assertAlmostEquals(y, 0.25, 0.01)
end

-- Unhappy path tests for draw

function TestImageRenderer:testDrawWithNilImage()
  -- Should not crash, just return early
  ImageRenderer.draw(nil, 0, 0, 100, 100, "fill")
  -- If we get here without error, test passes
  luaunit.assertTrue(true)
end

function TestImageRenderer:testDrawWithZeroWidth()
  -- Should error in calculateFit
  luaunit.assertError(function()
    ImageRenderer.draw(self.mockImage, 0, 0, 0, 100, "fill")
  end)
end

function TestImageRenderer:testDrawWithZeroHeight()
  luaunit.assertError(function()
    ImageRenderer.draw(self.mockImage, 0, 0, 100, 0, "fill")
  end)
end

function TestImageRenderer:testDrawWithNegativeOpacity()
  -- Should work but render with negative opacity
  ImageRenderer.draw(self.mockImage, 0, 0, 100, 100, "fill", "center center", -0.5)
  luaunit.assertTrue(true)
end

function TestImageRenderer:testDrawWithOpacityGreaterThanOne()
  -- Should work but render with >1 opacity
  ImageRenderer.draw(self.mockImage, 0, 0, 100, 100, "fill", "center center", 2.0)
  luaunit.assertTrue(true)
end

function TestImageRenderer:testDrawWithInvalidFitMode()
  -- Now uses 'fill' fallback with warning instead of error
  -- Should not throw an error, just use fill mode
  ImageRenderer.draw(self.mockImage, 0, 0, 100, 100, "invalid")
  luaunit.assertTrue(true) -- If we reach here, no error was thrown
end

function TestImageRenderer:testCalculateFitWithVerySmallBounds()
  local result = ImageRenderer.calculateFit(1000, 1000, 1, 1, "contain")
  luaunit.assertNotNil(result)
  -- Scale should be very small
  luaunit.assertTrue(result.scaleX < 0.01)
end

function TestImageRenderer:testCalculateFitWithVeryLargeBounds()
  local result = ImageRenderer.calculateFit(10, 10, 10000, 10000, "contain")
  luaunit.assertNotNil(result)
  -- Scale should be very large
  luaunit.assertTrue(result.scaleX > 100)
end

function TestImageRenderer:testCalculateFitWithAspectRatioMismatch()
  -- Wide image, tall bounds
  local result = ImageRenderer.calculateFit(200, 100, 100, 200, "contain")
  luaunit.assertNotNil(result)
  -- Should maintain aspect ratio
  luaunit.assertEquals(result.scaleX, result.scaleY)
end

function TestImageRenderer:testCalculateFitCoverWithAspectRatioMismatch()
  -- Wide image, tall bounds
  local result = ImageRenderer.calculateFit(200, 100, 100, 200, "cover")
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result.scaleX, result.scaleY)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
