package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")

local Blur = require("modules.Blur")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
Blur.init({ ErrorHandler = ErrorHandler })

TestBlur = {}

function TestBlur:setUp()
  -- Reset any cached state
  Blur.clearCache()
end

-- ============================================================================
-- Constructor Tests: Blur.new()
-- ============================================================================

function TestBlur:testNewWithNilQuality()
  -- Should default to quality 5
  local blur = Blur.new({quality = nil})
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 5)
end

function TestBlur:testNewWithZeroQuality()
  -- Should clamp to minimum quality 1
  local blur = Blur.new({quality = 0})
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 1)
end

function TestBlur:testNewWithNegativeQuality()
  -- Should clamp to minimum quality 1
  local blur = Blur.new({quality = -5})
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 1)
end

function TestBlur:testNewWithVeryHighQuality()
  -- Should clamp to maximum quality 10
  local blur = Blur.new({quality = 100})
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 10)
end

function TestBlur:testNewWithQuality11()
  -- Should clamp to maximum quality 10
  local blur = Blur.new({quality = 11})
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 10)
end

function TestBlur:testNewWithFractionalQuality()
  -- Should work with fractional quality
  local blur = Blur.new({quality = 5.5})
  luaunit.assertNotNil(blur)
  luaunit.assertTrue(blur.quality >= 5 and blur.quality <= 6)
end

function TestBlur:testNewEnsuresOddTaps()
  -- Taps must be odd for shader
  for quality = 1, 10 do
    local blur = Blur.new({quality = quality})
    luaunit.assertTrue(blur.taps % 2 == 1, string.format("Quality %d produced even taps: %d", quality, blur.taps))
  end
end

function TestBlur:testNewWithEmptyProps()
  -- Should work with no props table
  local blur = Blur.new()
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 5)
end

function TestBlur:testNewWithNilProps()
  -- Should work with explicit nil
  local blur = Blur.new(nil)
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 5)
end

function TestBlur:testNewCreatesUniqueShaders()
  -- Blur instances with same quality should share cached shaders (optimization)
  local blur1 = Blur.new({quality = 5})
  local blur2 = Blur.new({quality = 5})
  
  luaunit.assertNotNil(blur1.shader)
  luaunit.assertNotNil(blur2.shader)
  -- Shaders should be the same object when quality matches (cached)
  luaunit.assertEquals(blur1.shader, blur2.shader)
  
  -- Different quality should result in different shaders
  local blur3 = Blur.new({quality = 7})
  luaunit.assertNotEquals(blur1.shader, blur3.shader)
end

-- ============================================================================
-- applyToRegion() Edge Cases
-- ============================================================================

function TestBlur:testApplyToRegionWithZeroRadius()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  blur:applyToRegion(0, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithNegativeRadius()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  blur:applyToRegion(-10, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithZeroWidth()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  blur:applyToRegion(50, 0, 0, 0, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithZeroHeight()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  blur:applyToRegion(50, 0, 0, 100, 0, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithNegativeWidth()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  blur:applyToRegion(50, 0, 0, -100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithNegativeHeight()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  blur:applyToRegion(50, 0, 0, 100, -100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithLargeRadius()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should work with large radius values
  blur:applyToRegion(150, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithNonFunctionDrawFunc()
  local blur = Blur.new({quality = 5})

  -- Should not error but warn through ErrorHandler
  blur:applyToRegion(50, 0, 0, 100, 100, "not a function")
  luaunit.assertTrue(true) -- Should reach here without crash
end

function TestBlur:testApplyToRegionWithNilDrawFunc()
  local blur = Blur.new({quality = 5})

  -- Should not error but warn through ErrorHandler
  blur:applyToRegion(50, 0, 0, 100, 100, nil)
  luaunit.assertTrue(true) -- Should reach here without crash
end

function TestBlur:testApplyToRegionWithNegativeCoordinates()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Negative coordinates should work (off-screen rendering)
  blur:applyToRegion(50, -100, -100, 100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithVerySmallDimensions()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Very small dimensions (1x1)
  blur:applyToRegion(50, 0, 0, 1, 1, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithVeryLargeDimensions()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Very large dimensions (might stress cache)
  blur:applyToRegion(50, 0, 0, 4096, 4096, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionRadiusValues()
  local blur = Blur.new({quality = 5})
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Test various radius values
  -- Small radius
  blur:applyToRegion(5, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
  
  called = false
  -- Medium radius
  blur:applyToRegion(10, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
  
  called = false
  -- Large radius
  blur:applyToRegion(20, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
  
  called = false
  -- Very large radius
  blur:applyToRegion(50, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
  
  called = false
  -- Fractional radius
  blur:applyToRegion(2.5, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
end

-- ============================================================================
-- applyBackdrop() Edge Cases
-- ============================================================================

function TestBlur:testApplyBackdropWithZeroRadius()
  local blur = Blur.new({quality = 5})
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  blur:applyBackdrop(0, 0, 0, 100, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithNegativeRadius()
  local blur = Blur.new({quality = 5})
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  blur:applyBackdrop(-10, 0, 0, 100, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithZeroWidth()
  local blur = Blur.new({quality = 5})
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  blur:applyBackdrop(50, 0, 0, 0, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithZeroHeight()
  local blur = Blur.new({quality = 5})
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  blur:applyBackdrop(50, 0, 0, 100, 0, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithNilCanvas()
  local blur = Blur.new({quality = 5})

  -- Should not error but warn through ErrorHandler
  blur:applyBackdrop(50, 0, 0, 100, 100, nil)
  luaunit.assertTrue(true) -- Should reach here without crash
end

function TestBlur:testApplyBackdropWithLargeRadius()
  local blur = Blur.new({quality = 5})
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should work with large radius values
  blur:applyBackdrop(200, 0, 0, 100, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithInvalidCanvas()
  local blur = Blur.new({quality = 5})
  local invalidCanvas = "not a canvas"

  -- Should error when trying to call getDimensions
  luaunit.assertErrorMsgContains("attempt", function()
    blur:applyBackdrop(50, 0, 0, 100, 100, invalidCanvas)
  end)
end

function TestBlur:testApplyBackdropRegionBeyondCanvas()
  local blur = Blur.new({quality = 5})
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Region starts beyond canvas bounds
  blur:applyBackdrop(50, 150, 150, 100, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithNegativeCoordinates()
  local blur = Blur.new({quality = 5})
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Negative coordinates (region partially off-screen)
  blur:applyBackdrop(50, -50, -50, 100, 100, mockCanvas)
  luaunit.assertTrue(true)
end

-- ============================================================================
-- Getter Methods
-- ============================================================================

function TestBlur:testGetQuality()
  local blur = Blur.new({quality = 7})
  luaunit.assertEquals(blur:getQuality(), 7)
end

function TestBlur:testGetTaps()
  local blur = Blur.new({quality = 5})
  luaunit.assertIsNumber(blur:getTaps())
  luaunit.assertTrue(blur:getTaps() > 0)
  luaunit.assertTrue(blur:getTaps() % 2 == 1) -- Must be odd
end

-- ============================================================================
-- Cache Tests
-- ============================================================================

function TestBlur:testClearCacheDoesNotError()
  -- Create some blur instances to populate cache
  local blur1 = Blur.new({quality = 5})
  local blur2 = Blur.new({quality = 8})

  -- Should not error
  Blur.clearCache()
  luaunit.assertTrue(true)
end

function TestBlur:testClearCacheMultipleTimes()
  Blur.clearCache()
  Blur.clearCache()
  Blur.clearCache()
  luaunit.assertTrue(true)
end

function TestBlur:testCacheAccessMethods()
  -- Test that Cache is accessible
  luaunit.assertNotNil(Blur.Cache)
  luaunit.assertNotNil(Blur.Cache.getCanvas)
  luaunit.assertNotNil(Blur.Cache.releaseCanvas)
  luaunit.assertNotNil(Blur.Cache.getQuad)
  luaunit.assertNotNil(Blur.Cache.releaseQuad)
  luaunit.assertNotNil(Blur.Cache.clear)
end

function TestBlur:testReleaseNonExistentCanvas()
  -- Should not error when releasing canvas that's not in cache
  local fakeCanvas = {}
  Blur.Cache.releaseCanvas(fakeCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testReleaseNonExistentQuad()
  -- Should not error when releasing quad that's not in cache
  local fakeQuad = {}
  Blur.Cache.releaseQuad(fakeQuad)
  luaunit.assertTrue(true)
end

-- ============================================================================
-- ShaderBuilder Edge Cases
-- ============================================================================

function TestBlur:testShaderBuilderAccessible()
  luaunit.assertNotNil(Blur.ShaderBuilder)
  luaunit.assertNotNil(Blur.ShaderBuilder.build)
end

function TestBlur:testShaderBuilderWithMinimalTaps()
  -- Should work with minimum taps (3)
  local shader = Blur.ShaderBuilder.build(3, 1.0, "weighted", -1)
  luaunit.assertNotNil(shader)
end

function TestBlur:testShaderBuilderWithFractionalTaps()
  -- Should floor fractional taps to nearest odd number
  local shader = Blur.ShaderBuilder.build(4.7, 1.0, "weighted", -1)
  luaunit.assertNotNil(shader)
end

function TestBlur:testShaderBuilderWithCenterOffset()
  -- Should work with center offset type
  local shader = Blur.ShaderBuilder.build(7, 1.0, "center", -1)
  luaunit.assertNotNil(shader)
end

function TestBlur:testShaderBuilderWithZeroSigma()
  -- Should clamp sigma to minimum 1
  local shader = Blur.ShaderBuilder.build(7, 1.0, "weighted", 0)
  luaunit.assertNotNil(shader)
end

function TestBlur:testShaderBuilderWithNegativeSigma()
  -- Should auto-calculate sigma when negative
  local shader = Blur.ShaderBuilder.build(7, 1.0, "weighted", -1)
  luaunit.assertNotNil(shader)
end

function TestBlur:testShaderBuilderWithLargeTaps()
  -- Should work with large tap count
  local shader = Blur.ShaderBuilder.build(21, 1.0, "weighted", -1)
  luaunit.assertNotNil(shader)
end

function TestBlur:testShaderBuilderWithZeroOffset()
  -- Should work with zero offset
  local shader = Blur.ShaderBuilder.build(7, 0.0, "weighted", -1)
  luaunit.assertNotNil(shader)
end

function TestBlur:testShaderBuilderWithLargeOffset()
  -- Should work with large offset
  local shader = Blur.ShaderBuilder.build(7, 10.0, "weighted", -1)
  luaunit.assertNotNil(shader)
end

-- ============================================================================
-- Initialization Tests
-- ============================================================================

function TestBlur:testInitWithErrorHandler()
  -- Should accept ErrorHandler dependency
  Blur.init({ ErrorHandler = ErrorHandler })
  luaunit.assertNotNil(Blur._ErrorHandler)
end

function TestBlur:testInitWithNilDeps()
  -- Should handle nil deps gracefully
  Blur.init(nil)
  luaunit.assertTrue(true) -- Should not crash
end

function TestBlur:testInitWithEmptyTable()
  -- Should handle empty deps table
  Blur.init({})
  luaunit.assertTrue(true) -- Should not crash
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
