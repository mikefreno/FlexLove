package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

ErrorHandler.init({})
require("testing.loveStub")

local ImageScaler = require("modules.ImageScaler")

ImageScaler.init({ ErrorHandler = ErrorHandler })

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
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 0, 10, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleNearestWithZeroSourceHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 0, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleNearestWithNegativeSourceWidth()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, -10, 10, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleNearestWithNegativeSourceHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, -10, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleNearestWithZeroDestWidth()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, 0, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleNearestWithZeroDestHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, 20, 0)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleNearestWithNegativeDestWidth()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, -20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleNearestWithNegativeDestHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleNearest(self.mockImageData, 0, 0, 10, 10, 20, -20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

-- Unhappy path tests for scaleBilinear

function TestImageScaler:testScaleBilinearWithNilSource()
  luaunit.assertError(function()
    ImageScaler.scaleBilinear(nil, 0, 0, 10, 10, 20, 20)
  end)
end

function TestImageScaler:testScaleBilinearWithZeroSourceWidth()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 0, 10, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleBilinearWithZeroSourceHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 0, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleBilinearWithNegativeSourceWidth()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, -10, 10, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleBilinearWithNegativeSourceHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, -10, 20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleBilinearWithZeroDestWidth()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, 0, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleBilinearWithZeroDestHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, 20, 0)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleBilinearWithNegativeDestWidth()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, -20, 20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
end

function TestImageScaler:testScaleBilinearWithNegativeDestHeight()
  -- Now returns 1x1 transparent fallback with warning instead of error
  local result = ImageScaler.scaleBilinear(self.mockImageData, 0, 0, 10, 10, 20, -20)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result:getWidth(), 1)
  luaunit.assertEquals(result:getHeight(), 1)
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
