-- Test suite for utils.lua module
-- Tests all 16+ utility functions with comprehensive edge cases

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local utils = require("modules.utils")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

-- Test suite for validation utilities
TestValidationUtils = {}

function TestValidationUtils:testValidateEnum_ValidValue()
  local testEnum = { VALUE1 = "value1", VALUE2 = "value2", VALUE3 = "value3" }
  luaunit.assertTrue(utils.validateEnum("value1", testEnum, "testProp"))
  luaunit.assertTrue(utils.validateEnum("value2", testEnum, "testProp"))
  luaunit.assertTrue(utils.validateEnum("value3", testEnum, "testProp"))
end

function TestValidationUtils:testValidateEnum_NilValue()
  local testEnum = { VALUE1 = "value1", VALUE2 = "value2" }
  luaunit.assertTrue(utils.validateEnum(nil, testEnum, "testProp"))
end

function TestValidationUtils:testValidateEnum_InvalidValue()
  local testEnum = { VALUE1 = "value1", VALUE2 = "value2" }
  luaunit.assertErrorMsgContains("must be one of", function()
    utils.validateEnum("invalid", testEnum, "testProp")
  end)
end

function TestValidationUtils:testValidateRange_InRange()
  luaunit.assertTrue(utils.validateRange(5, 0, 10, "testProp"))
  luaunit.assertTrue(utils.validateRange(0, 0, 10, "testProp"))
  luaunit.assertTrue(utils.validateRange(10, 0, 10, "testProp"))
end

function TestValidationUtils:testValidateRange_OutOfRange()
  luaunit.assertErrorMsgContains("must be between", function()
    utils.validateRange(-1, 0, 10, "testProp")
  end)
  luaunit.assertErrorMsgContains("must be between", function()
    utils.validateRange(11, 0, 10, "testProp")
  end)
end

function TestValidationUtils:testValidateRange_NilValue()
  luaunit.assertTrue(utils.validateRange(nil, 0, 10, "testProp"))
end

function TestValidationUtils:testValidateRange_WrongType()
  luaunit.assertErrorMsgContains("must be a number", function()
    utils.validateRange("not a number", 0, 10, "testProp")
  end)
end

function TestValidationUtils:testValidateType_CorrectType()
  luaunit.assertTrue(utils.validateType("hello", "string", "testProp"))
  luaunit.assertTrue(utils.validateType(123, "number", "testProp"))
  luaunit.assertTrue(utils.validateType(true, "boolean", "testProp"))
  luaunit.assertTrue(utils.validateType({}, "table", "testProp"))
  luaunit.assertTrue(utils.validateType(function() end, "function", "testProp"))
end

function TestValidationUtils:testValidateType_WrongType()
  luaunit.assertErrorMsgContains("must be string", function()
    utils.validateType(123, "string", "testProp")
  end)
  luaunit.assertErrorMsgContains("must be number", function()
    utils.validateType("hello", "number", "testProp")
  end)
end

function TestValidationUtils:testValidateType_NilValue()
  luaunit.assertTrue(utils.validateType(nil, "string", "testProp"))
end

-- Test suite for math utilities
TestMathUtils = {}

function TestMathUtils:testClamp_WithinRange()
  luaunit.assertEquals(utils.clamp(5, 0, 10), 5)
  luaunit.assertEquals(utils.clamp(0, 0, 10), 0)
  luaunit.assertEquals(utils.clamp(10, 0, 10), 10)
end

function TestMathUtils:testClamp_BelowMin()
  luaunit.assertEquals(utils.clamp(-5, 0, 10), 0)
  luaunit.assertEquals(utils.clamp(-100, 0, 10), 0)
end

function TestMathUtils:testClamp_AboveMax()
  luaunit.assertEquals(utils.clamp(15, 0, 10), 10)
  luaunit.assertEquals(utils.clamp(100, 0, 10), 10)
end

function TestMathUtils:testClamp_NegativeRange()
  luaunit.assertEquals(utils.clamp(-5, -10, -1), -5)
  luaunit.assertEquals(utils.clamp(-15, -10, -1), -10)
  luaunit.assertEquals(utils.clamp(0, -10, -1), -1)
end

function TestMathUtils:testLerp_Boundaries()
  luaunit.assertEquals(utils.lerp(0, 10, 0), 0)
  luaunit.assertEquals(utils.lerp(0, 10, 1), 10)
end

function TestMathUtils:testLerp_Midpoint()
  luaunit.assertEquals(utils.lerp(0, 10, 0.5), 5)
  luaunit.assertEquals(utils.lerp(10, 20, 0.5), 15)
end

function TestMathUtils:testLerp_NegativeValues()
  luaunit.assertEquals(utils.lerp(-10, 10, 0.5), 0)
  luaunit.assertEquals(utils.lerp(-20, -10, 0.5), -15)
end

function TestMathUtils:testLerp_BeyondRange()
  luaunit.assertEquals(utils.lerp(0, 10, 1.5), 15)
  luaunit.assertEquals(utils.lerp(0, 10, -0.5), -5)
end

function TestMathUtils:testRound_UpAndDown()
  luaunit.assertEquals(utils.round(0.4), 0)
  luaunit.assertEquals(utils.round(0.5), 1)
  luaunit.assertEquals(utils.round(0.6), 1)
end

function TestMathUtils:testRound_NegativeNumbers()
  luaunit.assertEquals(utils.round(-0.4), 0)
  luaunit.assertEquals(utils.round(-0.5), 0)
  luaunit.assertEquals(utils.round(-0.6), -1)
end

function TestMathUtils:testRound_WholeNumbers()
  luaunit.assertEquals(utils.round(5), 5)
  luaunit.assertEquals(utils.round(-5), -5)
  luaunit.assertEquals(utils.round(0), 0)
end

-- Test suite for path utilities
TestPathUtils = {}

function TestPathUtils:testNormalizePath_Whitespace()
  luaunit.assertEquals(utils.normalizePath("  /path/to/file  "), "/path/to/file")
  luaunit.assertEquals(utils.normalizePath("\t/path/to/file\t"), "/path/to/file")
  luaunit.assertEquals(utils.normalizePath(" /path/to/file "), "/path/to/file")
end

function TestPathUtils:testNormalizePath_Backslashes()
  luaunit.assertEquals(utils.normalizePath("C:\\path\\to\\file"), "C:/path/to/file")
  luaunit.assertEquals(utils.normalizePath("path\\to\\file"), "path/to/file")
end

function TestPathUtils:testNormalizePath_DuplicateSlashes()
  luaunit.assertEquals(utils.normalizePath("/path//to///file"), "/path/to/file")
  luaunit.assertEquals(utils.normalizePath("path//to//file"), "path/to/file")
end

function TestPathUtils:testNormalizePath_Combined()
  luaunit.assertEquals(utils.normalizePath("  C:\\path\\\\to///file  "), "C:/path/to/file")
end

function TestPathUtils:testResolveImagePath_AbsolutePath()
  local result = utils.resolveImagePath("/absolute/path/to/image.png")
  luaunit.assertEquals(result, "/absolute/path/to/image.png")
end

function TestPathUtils:testResolveImagePath_WindowsAbsolutePath()
  local result = utils.resolveImagePath("C:/path/to/image.png")
  luaunit.assertEquals(result, "C:/path/to/image.png")
end

function TestPathUtils:testResolveImagePath_RelativePath()
  local result = utils.resolveImagePath("themes/images/icon.png")
  -- Should prepend the FlexLove base path
  luaunit.assertStrContains(result, "themes/images/icon.png")
end

function TestPathUtils:testSafeLoadImage_InvalidPath()
  -- Test with an invalid path - should return nil and error message
  local image, imageData, errorMsg = utils.safeLoadImage("nonexistent/path/to/image.png")
  luaunit.assertNil(image)
  luaunit.assertNil(imageData)
  luaunit.assertNotNil(errorMsg)
  luaunit.assertStrContains(errorMsg, "Failed to load")
end

-- Test suite for color utilities
TestColorUtils = {}

function TestColorUtils:testBrightenColor_NormalFactor()
  local r, g, b, a = utils.brightenColor(0.5, 0.5, 0.5, 1.0, 1.5)
  luaunit.assertAlmostEquals(r, 0.75, 0.001)
  luaunit.assertAlmostEquals(g, 0.75, 0.001)
  luaunit.assertAlmostEquals(b, 0.75, 0.001)
  luaunit.assertAlmostEquals(a, 1.0, 0.001)
end

function TestColorUtils:testBrightenColor_ClampingAt1()
  local r, g, b, a = utils.brightenColor(0.8, 0.8, 0.8, 1.0, 2.0)
  luaunit.assertAlmostEquals(r, 1.0, 0.001)
  luaunit.assertAlmostEquals(g, 1.0, 0.001)
  luaunit.assertAlmostEquals(b, 1.0, 0.001)
  luaunit.assertAlmostEquals(a, 1.0, 0.001)
end

function TestColorUtils:testBrightenColor_FactorOne()
  local r, g, b, a = utils.brightenColor(0.5, 0.6, 0.7, 0.8, 1.0)
  luaunit.assertAlmostEquals(r, 0.5, 0.001)
  luaunit.assertAlmostEquals(g, 0.6, 0.001)
  luaunit.assertAlmostEquals(b, 0.7, 0.001)
  luaunit.assertAlmostEquals(a, 0.8, 0.001)
end

function TestColorUtils:testBrightenColor_AlphaUnchanged()
  local _, _, _, a = utils.brightenColor(0.5, 0.5, 0.5, 0.5, 2.0)
  luaunit.assertAlmostEquals(a, 0.5, 0.001) -- Alpha should remain unchanged
end

-- Test suite for property utilities
TestPropertyUtils = {}

function TestPropertyUtils:testNormalizeBooleanTable_Boolean()
  local result = utils.normalizeBooleanTable(true)
  luaunit.assertEquals(result.vertical, true)
  luaunit.assertEquals(result.horizontal, true)

  result = utils.normalizeBooleanTable(false)
  luaunit.assertEquals(result.vertical, false)
  luaunit.assertEquals(result.horizontal, false)
end

function TestPropertyUtils:testNormalizeBooleanTable_Nil()
  local result = utils.normalizeBooleanTable(nil)
  luaunit.assertEquals(result.vertical, false)
  luaunit.assertEquals(result.horizontal, false)
end

function TestPropertyUtils:testNormalizeBooleanTable_NilWithDefault()
  local result = utils.normalizeBooleanTable(nil, true)
  luaunit.assertEquals(result.vertical, true)
  luaunit.assertEquals(result.horizontal, true)
end

function TestPropertyUtils:testNormalizeBooleanTable_Table()
  local result = utils.normalizeBooleanTable({ vertical = true, horizontal = false })
  luaunit.assertEquals(result.vertical, true)
  luaunit.assertEquals(result.horizontal, false)
end

function TestPropertyUtils:testNormalizeBooleanTable_PartialTable()
  local result = utils.normalizeBooleanTable({ vertical = true })
  luaunit.assertEquals(result.vertical, true)
  luaunit.assertEquals(result.horizontal, false)

  result = utils.normalizeBooleanTable({ horizontal = true })
  luaunit.assertEquals(result.vertical, false)
  luaunit.assertEquals(result.horizontal, true)
end

function TestPropertyUtils:testNormalizeBooleanTable_EmptyTable()
  local result = utils.normalizeBooleanTable({})
  luaunit.assertEquals(result.vertical, false)
  luaunit.assertEquals(result.horizontal, false)
end

-- Test suite for font utilities
TestFontUtils = {}

function TestFontUtils:testResolveFontPath_DirectPath()
  local result = utils.resolveFontPath("path/to/font.ttf", nil, nil)
  luaunit.assertEquals(result, "path/to/font.ttf")
end

function TestFontUtils:testResolveFontPath_NilFontFamily()
  local result = utils.resolveFontPath(nil, nil, nil)
  luaunit.assertNil(result)
end

function TestFontUtils:testResolveFontPath_ThemeFont()
  -- Mock theme manager with font
  local mockThemeManager = {
    getTheme = function()
      return {
        fonts = {
          mainFont = "themes/fonts/main.ttf",
        },
      }
    end,
  }

  local result = utils.resolveFontPath("mainFont", "button", mockThemeManager)
  luaunit.assertEquals(result, "themes/fonts/main.ttf")
end

function TestFontUtils:testResolveFontPath_ThemeFontNotFound()
  -- Mock theme manager without the requested font
  local mockThemeManager = {
    getTheme = function()
      return {
        fonts = {},
      }
    end,
  }

  -- Should fall back to treating it as a direct path
  local result = utils.resolveFontPath("unknownFont", "button", mockThemeManager)
  luaunit.assertEquals(result, "unknownFont")
end

function TestFontUtils:testGetFont_WithTextSize()
  local font = utils.getFont(16, nil, nil, nil)
  luaunit.assertNotNil(font)
  -- Font height should match the requested size
  if font.getHeight then
    luaunit.assertEquals(font.getHeight(), 16)
  end
end

function TestFontUtils:testGetFont_WithoutTextSize()
  local font = utils.getFont(nil, nil, nil, nil)
  luaunit.assertNotNil(font)
  -- Should return the default font
end

function TestFontUtils:testApplyContentMultiplier_WithWidth()
  local result = utils.applyContentMultiplier(100, { width = 2.0, height = 1.5 }, "width")
  luaunit.assertEquals(result, 200)
end

function TestFontUtils:testApplyContentMultiplier_WithHeight()
  local result = utils.applyContentMultiplier(100, { width = 2.0, height = 1.5 }, "height")
  luaunit.assertEquals(result, 150)
end

function TestFontUtils:testApplyContentMultiplier_NilMultiplier()
  local result = utils.applyContentMultiplier(100, nil, "width")
  luaunit.assertEquals(result, 100)
end

function TestFontUtils:testApplyContentMultiplier_MissingAxis()
  local result = utils.applyContentMultiplier(100, { width = 2.0 }, "height")
  luaunit.assertEquals(result, 100)
end

-- Test suite for input utilities
TestInputUtils = {}

function TestInputUtils:testGetModifiers_NoModifiers()
  -- Reset all modifier keys
  love.keyboard.setDown("lshift", false)
  love.keyboard.setDown("rshift", false)
  love.keyboard.setDown("lctrl", false)
  love.keyboard.setDown("rctrl", false)
  love.keyboard.setDown("lalt", false)
  love.keyboard.setDown("ralt", false)
  love.keyboard.setDown("lgui", false)
  love.keyboard.setDown("rgui", false)

  local mods = utils.getModifiers()
  luaunit.assertFalse(mods.shift)
  luaunit.assertFalse(mods.ctrl)
  luaunit.assertFalse(mods.alt)
  luaunit.assertFalse(mods.super)
end

function TestInputUtils:testGetModifiers_ShiftKey()
  love.keyboard.setDown("lshift", true)
  local mods = utils.getModifiers()
  luaunit.assertTrue(mods.shift)
  love.keyboard.setDown("lshift", false)

  love.keyboard.setDown("rshift", true)
  mods = utils.getModifiers()
  luaunit.assertTrue(mods.shift)
  love.keyboard.setDown("rshift", false)
end

function TestInputUtils:testGetModifiers_CtrlKey()
  love.keyboard.setDown("lctrl", true)
  local mods = utils.getModifiers()
  luaunit.assertTrue(mods.ctrl)
  love.keyboard.setDown("lctrl", false)
end

function TestInputUtils:testGetModifiers_AltKey()
  love.keyboard.setDown("lalt", true)
  local mods = utils.getModifiers()
  luaunit.assertTrue(mods.alt)
  love.keyboard.setDown("lalt", false)
end

function TestInputUtils:testGetModifiers_SuperKey()
  love.keyboard.setDown("lgui", true)
  local mods = utils.getModifiers()
  luaunit.assertTrue(mods.super)
  love.keyboard.setDown("lgui", false)
end

function TestInputUtils:testGetModifiers_MultipleModifiers()
  love.keyboard.setDown("lshift", true)
  love.keyboard.setDown("lctrl", true)
  local mods = utils.getModifiers()
  luaunit.assertTrue(mods.shift)
  luaunit.assertTrue(mods.ctrl)
  luaunit.assertFalse(mods.alt)
  luaunit.assertFalse(mods.super)

  -- Clean up
  love.keyboard.setDown("lshift", false)
  love.keyboard.setDown("lctrl", false)
end

-- Test suite for text size presets
TestTextSizePresets = {}

function TestTextSizePresets:testResolveTextSizePreset_ValidPresets()
  local value, unit = utils.resolveTextSizePreset("xs")
  luaunit.assertEquals(value, 1.25)
  luaunit.assertEquals(unit, "vh")

  value, unit = utils.resolveTextSizePreset("md")
  luaunit.assertEquals(value, 2.25)
  luaunit.assertEquals(unit, "vh")

  value, unit = utils.resolveTextSizePreset("xl")
  luaunit.assertEquals(value, 3.5)
  luaunit.assertEquals(unit, "vh")
end

function TestTextSizePresets:testResolveTextSizePreset_NumericValue()
  local value, unit = utils.resolveTextSizePreset(20)
  luaunit.assertNil(value)
  luaunit.assertNil(unit)
end

function TestTextSizePresets:testResolveTextSizePreset_InvalidPreset()
  local value, unit = utils.resolveTextSizePreset("invalid")
  luaunit.assertNil(value)
  luaunit.assertNil(unit)
end

function TestTextSizePresets:testResolveTextSizePreset_AllPresets()
  -- Test all available presets
  local presets = { "xxs", "2xs", "xs", "sm", "md", "lg", "xl", "xxl", "2xl", "3xl", "4xl" }
  for _, preset in ipairs(presets) do
    local value, unit = utils.resolveTextSizePreset(preset)
    luaunit.assertNotNil(value, "Preset " .. preset .. " should return a value")
    luaunit.assertEquals(unit, "vh", "Preset " .. preset .. " should return 'vh' unit")
  end
end

-- Test suite for enums
TestEnums = {}

function TestEnums:testEnums_Exist()
  luaunit.assertNotNil(utils.enums)
  luaunit.assertNotNil(utils.enums.TextAlign)
  luaunit.assertNotNil(utils.enums.Positioning)
  luaunit.assertNotNil(utils.enums.FlexDirection)
  luaunit.assertNotNil(utils.enums.JustifyContent)
  luaunit.assertNotNil(utils.enums.AlignItems)
  luaunit.assertNotNil(utils.enums.FlexWrap)
  luaunit.assertNotNil(utils.enums.TextSize)
end

function TestEnums:testEnums_TextAlign()
  luaunit.assertEquals(utils.enums.TextAlign.START, "start")
  luaunit.assertEquals(utils.enums.TextAlign.CENTER, "center")
  luaunit.assertEquals(utils.enums.TextAlign.END, "end")
  luaunit.assertEquals(utils.enums.TextAlign.JUSTIFY, "justify")
end

function TestEnums:testEnums_Positioning()
  luaunit.assertEquals(utils.enums.Positioning.ABSOLUTE, "absolute")
  luaunit.assertEquals(utils.enums.Positioning.RELATIVE, "relative")
  luaunit.assertEquals(utils.enums.Positioning.FLEX, "flex")
  luaunit.assertEquals(utils.enums.Positioning.GRID, "grid")
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
