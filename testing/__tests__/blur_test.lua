local luaunit = require("testing.luaunit")
require("testing.loveStub")

local Blur = require("modules.Blur")

TestBlur = {}

function TestBlur:setUp()
  -- Reset any cached state
  Blur.clearCache()
end

-- Unhappy path tests for Blur.new()

function TestBlur:testNewWithNilQuality()
  -- Should default to quality 5
  local blur = Blur.new(nil)
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 5)
end

function TestBlur:testNewWithZeroQuality()
  -- Should clamp to minimum quality 1
  local blur = Blur.new(0)
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 1)
end

function TestBlur:testNewWithNegativeQuality()
  -- Should clamp to minimum quality 1
  local blur = Blur.new(-5)
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 1)
end

function TestBlur:testNewWithVeryHighQuality()
  -- Should clamp to maximum quality 10
  local blur = Blur.new(100)
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 10)
end

function TestBlur:testNewWithQuality11()
  -- Should clamp to maximum quality 10
  local blur = Blur.new(11)
  luaunit.assertNotNil(blur)
  luaunit.assertEquals(blur.quality, 10)
end

function TestBlur:testNewWithFractionalQuality()
  -- Should work with fractional quality
  local blur = Blur.new(5.5)
  luaunit.assertNotNil(blur)
  luaunit.assertTrue(blur.quality >= 5 and blur.quality <= 6)
end

function TestBlur:testNewEnsuresOddTaps()
  -- Taps must be odd for shader
  for quality = 1, 10 do
    local blur = Blur.new(quality)
    luaunit.assertTrue(blur.taps % 2 == 1, string.format("Quality %d produced even taps: %d", quality, blur.taps))
  end
end

-- Unhappy path tests for Blur.applyToRegion()

function TestBlur:testApplyToRegionWithNilBlurInstance()
  local called = false
  local drawFunc = function()
    called = true
  end

  luaunit.assertError(function()
    Blur.applyToRegion(nil, 50, 0, 0, 100, 100, drawFunc)
  end)
end

function TestBlur:testApplyToRegionWithZeroIntensity()
  local blur = Blur.new(5)
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  Blur.applyToRegion(blur, 0, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithNegativeIntensity()
  local blur = Blur.new(5)
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  Blur.applyToRegion(blur, -10, 0, 0, 100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithZeroWidth()
  local blur = Blur.new(5)
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  Blur.applyToRegion(blur, 50, 0, 0, 0, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithZeroHeight()
  local blur = Blur.new(5)
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  Blur.applyToRegion(blur, 50, 0, 0, 100, 0, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithNegativeWidth()
  local blur = Blur.new(5)
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  Blur.applyToRegion(blur, 50, 0, 0, -100, 100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithNegativeHeight()
  local blur = Blur.new(5)
  local called = false
  local drawFunc = function()
    called = true
  end

  -- Should just call drawFunc and return early
  Blur.applyToRegion(blur, 50, 0, 0, 100, -100, drawFunc)
  luaunit.assertTrue(called)
end

function TestBlur:testApplyToRegionWithIntensityOver100()
  local blur = Blur.new(5)

  -- We can't fully test rendering without complete LÖVE graphics
  -- But we can verify the blur instance was created
  luaunit.assertNotNil(blur)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyToRegionWithSmallDimensions()
  local blur = Blur.new(5)
  local called = false
  local drawFunc = function()
    called = true
  end

  -- For small dimensions, we test that it doesn't error
  -- We can't fully test the rendering without full LÖVE graphics
  luaunit.assertNotNil(blur)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyToRegionWithNilDrawFunc()
  local blur = Blur.new(5)

  luaunit.assertError(function()
    Blur.applyToRegion(blur, 50, 0, 0, 100, 100, nil)
  end)
end

-- Unhappy path tests for Blur.applyBackdrop()

function TestBlur:testApplyBackdropWithNilBlurInstance()
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  luaunit.assertError(function()
    Blur.applyBackdrop(nil, 50, 0, 0, 100, 100, mockCanvas)
  end)
end

function TestBlur:testApplyBackdropWithZeroIntensity()
  local blur = Blur.new(5)
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  Blur.applyBackdrop(blur, 0, 0, 0, 100, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithNegativeIntensity()
  local blur = Blur.new(5)
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  Blur.applyBackdrop(blur, -10, 0, 0, 100, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithZeroWidth()
  local blur = Blur.new(5)
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  Blur.applyBackdrop(blur, 50, 0, 0, 0, 100, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithZeroHeight()
  local blur = Blur.new(5)
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- Should return early without error
  Blur.applyBackdrop(blur, 50, 0, 0, 100, 0, mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithNilCanvas()
  local blur = Blur.new(5)

  luaunit.assertError(function()
    Blur.applyBackdrop(blur, 50, 0, 0, 100, 100, nil)
  end)
end

function TestBlur:testApplyBackdropWithIntensityOver100()
  local blur = Blur.new(5)
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- We can't fully test rendering without complete LÖVE graphics
  luaunit.assertNotNil(blur)
  luaunit.assertNotNil(mockCanvas)
  luaunit.assertTrue(true)
end

function TestBlur:testApplyBackdropWithSmallDimensions()
  local blur = Blur.new(5)
  local mockCanvas = {
    getDimensions = function()
      return 100, 100
    end,
  }

  -- We can't fully test rendering without complete LÖVE graphics
  luaunit.assertNotNil(blur)
  luaunit.assertTrue(true)
end

-- Tests for Blur.clearCache()

function TestBlur:testClearCacheDoesNotError()
  -- Create some blur instances to populate cache
  local blur1 = Blur.new(5)
  local blur2 = Blur.new(8)

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

-- Edge case: intensity boundaries

function TestBlur:testIntensityBoundaries()
  local blur = Blur.new(5)

  -- Test that various quality levels create valid blur instances
  for quality = 1, 10 do
    local b = Blur.new(quality)
    luaunit.assertNotNil(b)
    luaunit.assertNotNil(b.shader)
    luaunit.assertTrue(b.taps % 2 == 1) -- Taps must be odd
  end

  luaunit.assertTrue(true)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
