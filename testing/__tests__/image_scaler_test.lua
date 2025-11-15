local luaunit = require("testing.luaunit")
require("testing.loveStub")

local ImageScaler = require("modules.ImageScaler")

TestImageScaler = {}

function TestImageScaler:setUp()
  -- Create a minimal mock ImageData
  self.mockImageData = {
    getPixel = function(self, x, y)
      -- Return deterministic values based on position
      return (x % 256) / 255, (y % 256) / 255, 0.5, 1.0
    end,
  }
end

-- Unhappy path tests for scaleNearest

function TestImageScaler:testScaleNearestWithNilSource()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(nil, 0, 0, 10, 10, 20, 20)
  end)
end

function TestImageScaler:testScaleNearestWithZeroSourceWidth()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, 0, 10, 20, 20)
  end)
end

function TestImageScaler:testScaleNearestWithZeroSourceHeight()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 0, 20, 20)
  end)
end

function TestImageScaler:testScaleNearestWithNegativeSourceWidth()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, -10, 10, 20, 20)
  end)
end

function TestImageScaler:testScaleNearestWithNegativeSourceHeight()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, -10, 20, 20)
  end)
end

function TestImageScaler:testScaleNearestWithZeroDestWidth()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, 0, 20)
  end)
end

function TestImageScaler:testScaleNearestWithZeroDestHeight()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, 20, 0)
  end)
end

function TestImageScaler:testScaleNearestWithNegativeDestWidth()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, -20, 20)
  end)
end

function TestImageScaler:testScaleNearestWithNegativeDestHeight()
  luaunit.assertError(function()
    ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, 20, -20)
  end)
end

-- Unhappy path tests for scaleBilinear

function TestImageScaler:testScaleBilinearWithNilSource()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(nil, 0, 0, 10, 10, 20, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithZeroSourceWidth()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 0, 10, 20, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithZeroSourceHeight()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 0, 20, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithNegativeSourceWidth()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, -10, 10, 20, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithNegativeSourceHeight()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, -10, 20, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithZeroDestWidth()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, 0, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithZeroDestHeight()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, 20, 0)
  end)
end

function TestImageScaler:testScaleBilinearWithNegativeDestWidth()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, -20, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithNegativeDestHeight()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, 20, -20)
  end)
end

-- Edge case tests

function TestImageScaler:testScaleNearestWithVeryLargeUpscale()
  -- Scale 1x1 to 50x50 (extreme upscale, but fast for testing)
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 1, 1, 50, 50)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleNearestWithVeryLargeDownscale()
  -- Scale 50x50 to 1x1 (extreme downscale)
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 50, 50, 1, 1)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleBilinearWithVeryLargeUpscale()
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 1, 1, 50, 50)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleBilinearWithVeryLargeDownscale()
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 50, 50, 1, 1)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleNearestWithNonIntegerDimensions()
  -- Fractional source dimensions (should work with floor/ceil)
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 5.5, 5.5, 10, 10)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleBilinearWithNonIntegerDimensions()
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 5.5, 5.5, 10, 10)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleNearestWith1x1Source()
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 1, 1, 5, 5)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleBilinearWith1x1Source()
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 1, 1, 5, 5)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleNearestWith1x1Dest()
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 5, 5, 1, 1)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleBilinearWith1x1Dest()
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 5, 5, 1, 1)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleNearestWithNonZeroSourceOffset()
  -- Source region offset from 0,0
  local result = ImageScaler.scaleNearest(self.mockImageData, 10, 10, 5, 5, 10, 10)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleBilinearWithNonZeroSourceOffset()
  local result = ImageScaler.scaleBilinear(self.mockImageData, 10, 10, 5, 5, 10, 10)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleNearestWithAspectRatioChange()
  -- Change aspect ratio dramatically
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 5, 20, 20, 5)
  luaunit.assertNotNil(result)
end

function TestImageScaler:testScaleBilinearWithAspectRatioChange()
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 5, 20, 20, 5)
  luaunit.assertNotNil(result)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
