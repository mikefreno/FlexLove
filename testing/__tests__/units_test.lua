-- Test suite for Units.lua module
-- Tests unit parsing, resolution, and conversion functions

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local Units = require("modules.Units")
local Context = require("modules.Context")

-- Initialize Units module with Context
Units.init({ Context = Context })

-- Mock viewport dimensions for consistent tests
local MOCK_VIEWPORT_WIDTH = 1920
local MOCK_VIEWPORT_HEIGHT = 1080

-- Test suite for Units.parse()
TestUnitsParse = {}

function TestUnitsParse:testParseNumber()
  local value, unit = Units.parse(100)
  luaunit.assertEquals(value, 100)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParsePixels()
  local value, unit = Units.parse("100px")
  luaunit.assertEquals(value, 100)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParsePixelsNoUnit()
  local value, unit = Units.parse("100")
  luaunit.assertEquals(value, 100)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParsePercentage()
  local value, unit = Units.parse("50%")
  luaunit.assertEquals(value, 50)
  luaunit.assertEquals(unit, "%")
end

function TestUnitsParse:testParseViewportWidth()
  local value, unit = Units.parse("10vw")
  luaunit.assertEquals(value, 10)
  luaunit.assertEquals(unit, "vw")
end

function TestUnitsParse:testParseViewportHeight()
  local value, unit = Units.parse("20vh")
  luaunit.assertEquals(value, 20)
  luaunit.assertEquals(unit, "vh")
end

function TestUnitsParse:testParseElementWidth()
  local value, unit = Units.parse("15ew")
  luaunit.assertEquals(value, 15)
  luaunit.assertEquals(unit, "ew")
end

function TestUnitsParse:testParseElementHeight()
  local value, unit = Units.parse("25eh")
  luaunit.assertEquals(value, 25)
  luaunit.assertEquals(unit, "eh")
end

function TestUnitsParse:testParseDecimal()
  local value, unit = Units.parse("10.5px")
  luaunit.assertEquals(value, 10.5)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParseNegative()
  local value, unit = Units.parse("-50px")
  luaunit.assertEquals(value, -50)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParseNegativeDecimal()
  local value, unit = Units.parse("-10.5%")
  luaunit.assertEquals(value, -10.5)
  luaunit.assertEquals(unit, "%")
end

function TestUnitsParse:testParseZero()
  local value, unit = Units.parse("0")
  luaunit.assertEquals(value, 0)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParseInvalidType()
  -- Now returns fallback value (0, "px") with warning instead of error
  local value, unit = Units.parse(nil)
  luaunit.assertEquals(value, 0)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParseInvalidString()
  -- Now returns fallback value (0, "px") with warning instead of error
  local value, unit = Units.parse("abc")
  luaunit.assertEquals(value, 0)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParseInvalidUnit()
  -- Now extracts the number and treats as pixels with warning instead of error
  -- "100xyz" -> extracts 100, ignores invalid unit "xyz", treats as "100px"
  local value, unit = Units.parse("100xyz")
  luaunit.assertEquals(value, 100)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsParse:testParseWithSpace()
  -- Spaces between number and unit should be invalid
  -- Now returns fallback value (0, "px") with warning instead of error
  local value, unit = Units.parse("100 px")
  luaunit.assertEquals(value, 0)
  luaunit.assertEquals(unit, "px")
end

-- Test suite for Units.resolve()
TestUnitsResolve = {}

function TestUnitsResolve:testResolvePixels()
  local result = Units.resolve(100, "px", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, 100)
end

function TestUnitsResolve:testResolvePercentage()
  local result = Units.resolve(50, "%", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT, 200)
  luaunit.assertEquals(result, 100) -- 50% of 200
end

function TestUnitsResolve:testResolveViewportWidth()
  local result = Units.resolve(10, "vw", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, 192) -- 10% of 1920
end

function TestUnitsResolve:testResolveViewportHeight()
  local result = Units.resolve(20, "vh", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, 216) -- 20% of 1080
end

function TestUnitsResolve:testResolvePercentageZero()
  local result = Units.resolve(0, "%", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT, 200)
  luaunit.assertEquals(result, 0)
end

function TestUnitsResolve:testResolvePercentage100()
  local result = Units.resolve(100, "%", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT, 200)
  luaunit.assertEquals(result, 200)
end

function TestUnitsResolve:testResolveNegativePixels()
  local result = Units.resolve(-50, "px", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, -50)
end

function TestUnitsResolve:testResolveDecimalPercentage()
  local result = Units.resolve(33.33, "%", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT, 300)
  luaunit.assertAlmostEquals(result, 99.99, 0.01)
end

-- Test suite for Units.parse() + Units.resolve() combination
TestUnitsParseAndResolve = {}

function TestUnitsParseAndResolve:testParseAndResolvePixels()
  local numValue, unit = Units.parse("100px")
  local result = Units.resolve(numValue, unit, MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, 100)
end

function TestUnitsParseAndResolve:testParseAndResolveNumber()
  local numValue, unit = Units.parse(100)
  local result = Units.resolve(numValue, unit, MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, 100)
end

function TestUnitsParseAndResolve:testParseAndResolvePercentage()
  local numValue, unit = Units.parse("50%")
  local result = Units.resolve(numValue, unit, MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT, 400)
  luaunit.assertEquals(result, 200)
end

function TestUnitsParseAndResolve:testParseAndResolveViewportWidth()
  local numValue, unit = Units.parse("10vw")
  local result = Units.resolve(numValue, unit, MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, 192)
end

function TestUnitsParseAndResolve:testParseAndResolveViewportHeight()
  local numValue, unit = Units.parse("50vh")
  local result = Units.resolve(numValue, unit, MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT)
  luaunit.assertEquals(result, 540)
end

-- Test suite for Units.isValid()
TestUnitsIsValid = {}

function TestUnitsIsValid:testIsValidPixels()
  luaunit.assertTrue(Units.isValid("100px"))
end

function TestUnitsIsValid:testIsValidPercentage()
  luaunit.assertTrue(Units.isValid("50%"))
end

function TestUnitsIsValid:testIsValidViewportWidth()
  luaunit.assertTrue(Units.isValid("10vw"))
end

function TestUnitsIsValid:testIsValidViewportHeight()
  luaunit.assertTrue(Units.isValid("20vh"))
end

function TestUnitsIsValid:testIsValidElementWidth()
  luaunit.assertTrue(Units.isValid("15ew"))
end

function TestUnitsIsValid:testIsValidElementHeight()
  luaunit.assertTrue(Units.isValid("25eh"))
end

function TestUnitsIsValid:testIsValidNumber()
  luaunit.assertTrue(Units.isValid("100"))
end

function TestUnitsIsValid:testIsValidNegative()
  luaunit.assertTrue(Units.isValid("-50px"))
end

function TestUnitsIsValid:testIsValidDecimal()
  luaunit.assertTrue(Units.isValid("10.5px"))
end

function TestUnitsIsValid:testIsInvalidString()
  luaunit.assertFalse(Units.isValid("abc"))
end

function TestUnitsIsValid:testIsInvalidNil()
  luaunit.assertFalse(Units.isValid(nil))
end

function TestUnitsIsValid:testIsInvalidNumber()
  luaunit.assertFalse(Units.isValid(100))
end

-- Test suite for Units.resolveSpacing()
TestUnitsResolveSpacing = {}

function TestUnitsResolveSpacing:testResolveSpacingNil()
  local result = Units.resolveSpacing(nil, 800, 600)
  luaunit.assertEquals(result.top, 0)
  luaunit.assertEquals(result.right, 0)
  luaunit.assertEquals(result.bottom, 0)
  luaunit.assertEquals(result.left, 0)
end

function TestUnitsResolveSpacing:testResolveSpacingAllSides()
  local spacing = {
    top = "10px",
    right = "20px",
    bottom = "30px",
    left = "40px",
  }
  local result = Units.resolveSpacing(spacing, 800, 600)
  luaunit.assertEquals(result.top, 10)
  luaunit.assertEquals(result.right, 20)
  luaunit.assertEquals(result.bottom, 30)
  luaunit.assertEquals(result.left, 40)
end

function TestUnitsResolveSpacing:testResolveSpacingVerticalHorizontal()
  local spacing = {
    vertical = "10px",
    horizontal = "20px",
  }
  local result = Units.resolveSpacing(spacing, 800, 600)
  luaunit.assertEquals(result.top, 10)
  luaunit.assertEquals(result.right, 20)
  luaunit.assertEquals(result.bottom, 10)
  luaunit.assertEquals(result.left, 20)
end

function TestUnitsResolveSpacing:testResolveSpacingVerticalHorizontalNumbers()
  local spacing = {
    vertical = 10,
    horizontal = 20,
  }
  local result = Units.resolveSpacing(spacing, 800, 600)
  luaunit.assertEquals(result.top, 10)
  luaunit.assertEquals(result.right, 20)
  luaunit.assertEquals(result.bottom, 10)
  luaunit.assertEquals(result.left, 20)
end

function TestUnitsResolveSpacing:testResolveSpacingMixedPercentage()
  local spacing = {
    top = "10%",
    right = "5%",
    bottom = "10%",
    left = "5%",
  }
  local result = Units.resolveSpacing(spacing, 800, 600)
  luaunit.assertEquals(result.top, 60) -- 10% of 600 (height)
  luaunit.assertEquals(result.right, 40) -- 5% of 800 (width)
  luaunit.assertEquals(result.bottom, 60) -- 10% of 600 (height)
  luaunit.assertEquals(result.left, 40) -- 5% of 800 (width)
end

function TestUnitsResolveSpacing:testResolveSpacingOverride()
  -- Individual sides should override vertical/horizontal
  local spacing = {
    vertical = "10px",
    horizontal = "20px",
    top = "50px",
  }
  local result = Units.resolveSpacing(spacing, 800, 600)
  luaunit.assertEquals(result.top, 50) -- Overridden
  luaunit.assertEquals(result.right, 20)
  luaunit.assertEquals(result.bottom, 10)
  luaunit.assertEquals(result.left, 20)
end

-- Test suite for Units.applyBaseScale()
TestUnitsApplyBaseScale = {}

function TestUnitsApplyBaseScale:testApplyBaseScaleX()
  local scaleFactors = { x = 2, y = 3 }
  local result = Units.applyBaseScale(100, "x", scaleFactors)
  luaunit.assertEquals(result, 200)
end

function TestUnitsApplyBaseScale:testApplyBaseScaleY()
  local scaleFactors = { x = 2, y = 3 }
  local result = Units.applyBaseScale(100, "y", scaleFactors)
  luaunit.assertEquals(result, 300)
end

function TestUnitsApplyBaseScale:testApplyBaseScaleIdentity()
  local scaleFactors = { x = 1, y = 1 }
  local result = Units.applyBaseScale(100, "x", scaleFactors)
  luaunit.assertEquals(result, 100)
end

function TestUnitsApplyBaseScale:testApplyBaseScaleZero()
  local scaleFactors = { x = 0, y = 0 }
  local result = Units.applyBaseScale(100, "x", scaleFactors)
  luaunit.assertEquals(result, 0)
end

function TestUnitsApplyBaseScale:testApplyBaseScaleDecimal()
  local scaleFactors = { x = 0.5, y = 1.5 }
  local result = Units.applyBaseScale(100, "x", scaleFactors)
  luaunit.assertEquals(result, 50)
end

-- Test suite for Units.getViewport()
TestUnitsGetViewport = {}

function TestUnitsGetViewport:testGetViewportReturnsValues()
  local width, height = Units.getViewport()
  luaunit.assertIsNumber(width)
  luaunit.assertIsNumber(height)
  luaunit.assertTrue(width > 0)
  luaunit.assertTrue(height > 0)
end

-- Test edge cases
TestUnitsEdgeCases = {}

function TestUnitsEdgeCases:testParseVeryLargeNumber()
  local value, unit = Units.parse("999999px")
  luaunit.assertEquals(value, 999999)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsEdgeCases:testParseVerySmallDecimal()
  local value, unit = Units.parse("0.001px")
  luaunit.assertEquals(value, 0.001)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsEdgeCases:testResolveZeroParentSize()
  local result = Units.resolve(50, "%", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT, 0)
  luaunit.assertEquals(result, 0)
end

function TestUnitsEdgeCases:testParseEmptyString()
  -- Now returns fallback value (0, "px") with warning instead of error
  local value, unit = Units.parse("")
  luaunit.assertEquals(value, 0)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsEdgeCases:testParseOnlyUnit()
  -- Now returns fallback value (0, "px") with warning instead of error
  local value, unit = Units.parse("px")
  luaunit.assertEquals(value, 0)
  luaunit.assertEquals(unit, "px")
end

function TestUnitsEdgeCases:testResolveNegativePercentage()
  local result = Units.resolve(-50, "%", MOCK_VIEWPORT_WIDTH, MOCK_VIEWPORT_HEIGHT, 200)
  luaunit.assertEquals(result, -100)
end

-- Run tests if not running as part of a suite
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
