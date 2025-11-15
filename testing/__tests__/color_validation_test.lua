-- Import test framework
package.path = package.path .. ";../../?.lua"
local luaunit = require("testing.luaunit")

-- Set up LÖVE stub environment
require("testing.loveStub")

-- Import the Color module
local Color = require("modules.Color")

-- Test Suite for Color Validation
TestColorValidation = {}

-- === validateColorChannel Tests ===

function TestColorValidation:test_validateColorChannel_valid_0to1()
  local valid, clamped = Color.validateColorChannel(0.5, 1)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(clamped, 0.5)
end

function TestColorValidation:test_validateColorChannel_valid_0to255()
  local valid, clamped = Color.validateColorChannel(128, 255)
  luaunit.assertTrue(valid)
  luaunit.assertAlmostEquals(clamped, 128 / 255, 0.001)
end

function TestColorValidation:test_validateColorChannel_clamp_below_min()
  local valid, clamped = Color.validateColorChannel(-0.5, 1)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(clamped, 0)
end

function TestColorValidation:test_validateColorChannel_clamp_above_max()
  local valid, clamped = Color.validateColorChannel(1.5, 1)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(clamped, 1)
end

function TestColorValidation:test_validateColorChannel_clamp_above_255()
  local valid, clamped = Color.validateColorChannel(300, 255)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(clamped, 1)
end

function TestColorValidation:test_validateColorChannel_nan()
  local valid, clamped = Color.validateColorChannel(0 / 0, 1)
  luaunit.assertFalse(valid)
  luaunit.assertNil(clamped)
end

function TestColorValidation:test_validateColorChannel_infinity()
  local valid, clamped = Color.validateColorChannel(math.huge, 1)
  luaunit.assertFalse(valid)
  luaunit.assertNil(clamped)
end

function TestColorValidation:test_validateColorChannel_negative_infinity()
  local valid, clamped = Color.validateColorChannel(-math.huge, 1)
  luaunit.assertFalse(valid)
  luaunit.assertNil(clamped)
end

function TestColorValidation:test_validateColorChannel_non_number()
  local valid, clamped = Color.validateColorChannel("0.5", 1)
  luaunit.assertFalse(valid)
  luaunit.assertNil(clamped)
end

-- === validateHexColor Tests ===

function TestColorValidation:test_validateHexColor_valid_6digit()
  local valid, err = Color.validateHexColor("#FF0000")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateHexColor_valid_6digit_no_hash()
  local valid, err = Color.validateHexColor("FF0000")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateHexColor_valid_8digit()
  local valid, err = Color.validateHexColor("#FF0000AA")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateHexColor_valid_3digit()
  local valid, err = Color.validateHexColor("#F00")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateHexColor_valid_lowercase()
  local valid, err = Color.validateHexColor("#ff0000")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateHexColor_valid_mixed_case()
  local valid, err = Color.validateHexColor("#Ff00Aa")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateHexColor_invalid_length()
  local valid, err = Color.validateHexColor("#FF00")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid hex length")
end

function TestColorValidation:test_validateHexColor_invalid_characters()
  local valid, err = Color.validateHexColor("#GG0000")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid hex characters")
end

function TestColorValidation:test_validateHexColor_not_string()
  local valid, err = Color.validateHexColor(123)
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "must be a string")
end

-- === validateRGBColor Tests ===

function TestColorValidation:test_validateRGBColor_valid_0to1()
  local valid, err = Color.validateRGBColor(0.5, 0.5, 0.5, 1.0, 1)
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateRGBColor_valid_0to255()
  local valid, err = Color.validateRGBColor(128, 128, 128, 255, 255)
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateRGBColor_valid_no_alpha()
  local valid, err = Color.validateRGBColor(0.5, 0.5, 0.5, nil, 1)
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateRGBColor_invalid_red()
  local valid, err = Color.validateRGBColor("red", 0.5, 0.5, 1.0, 1)
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid red channel")
end

function TestColorValidation:test_validateRGBColor_invalid_green()
  local valid, err = Color.validateRGBColor(0.5, nil, 0.5, 1.0, 1)
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid green channel")
end

function TestColorValidation:test_validateRGBColor_invalid_blue()
  local valid, err = Color.validateRGBColor(0.5, 0.5, {}, 1.0, 1)
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid blue channel")
end

function TestColorValidation:test_validateRGBColor_invalid_alpha()
  local valid, err = Color.validateRGBColor(0.5, 0.5, 0.5, 0 / 0, 1)
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid alpha channel")
end

-- === validateNamedColor Tests ===

function TestColorValidation:test_validateNamedColor_valid_lowercase()
  local valid, err = Color.validateNamedColor("red")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateNamedColor_valid_uppercase()
  local valid, err = Color.validateNamedColor("RED")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateNamedColor_valid_mixed_case()
  local valid, err = Color.validateNamedColor("BlUe")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateNamedColor_invalid_name()
  local valid, err = Color.validateNamedColor("notacolor")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Unknown color name")
end

function TestColorValidation:test_validateNamedColor_not_string()
  local valid, err = Color.validateNamedColor(123)
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "must be a string")
end

-- === isValidColorFormat Tests ===

function TestColorValidation:test_isValidColorFormat_hex_6digit()
  local format = Color.isValidColorFormat("#FF0000")
  luaunit.assertEquals(format, "hex")
end

function TestColorValidation:test_isValidColorFormat_hex_8digit()
  local format = Color.isValidColorFormat("#FF0000AA")
  luaunit.assertEquals(format, "hex")
end

function TestColorValidation:test_isValidColorFormat_hex_3digit()
  local format = Color.isValidColorFormat("#F00")
  luaunit.assertEquals(format, "hex")
end

function TestColorValidation:test_isValidColorFormat_named()
  local format = Color.isValidColorFormat("red")
  luaunit.assertEquals(format, "named")
end

function TestColorValidation:test_isValidColorFormat_table_array()
  local format = Color.isValidColorFormat({ 0.5, 0.5, 0.5, 1.0 })
  luaunit.assertEquals(format, "table")
end

function TestColorValidation:test_isValidColorFormat_table_named()
  local format = Color.isValidColorFormat({ r = 0.5, g = 0.5, b = 0.5, a = 1.0 })
  luaunit.assertEquals(format, "table")
end

function TestColorValidation:test_isValidColorFormat_table_color_instance()
  local color = Color.new(0.5, 0.5, 0.5, 1.0)
  local format = Color.isValidColorFormat(color)
  luaunit.assertEquals(format, "table")
end

function TestColorValidation:test_isValidColorFormat_invalid_string()
  local format = Color.isValidColorFormat("not-a-color")
  luaunit.assertNil(format)
end

function TestColorValidation:test_isValidColorFormat_invalid_table()
  local format = Color.isValidColorFormat({ invalid = true })
  luaunit.assertNil(format)
end

function TestColorValidation:test_isValidColorFormat_nil()
  local format = Color.isValidColorFormat(nil)
  luaunit.assertNil(format)
end

function TestColorValidation:test_isValidColorFormat_number()
  local format = Color.isValidColorFormat(12345)
  luaunit.assertNil(format)
end

-- === validateColor Tests ===

function TestColorValidation:test_validateColor_hex()
  local valid, err = Color.validateColor("#FF0000")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateColor_named()
  local valid, err = Color.validateColor("blue")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateColor_table_array()
  local valid, err = Color.validateColor({ 0.5, 0.5, 0.5, 1.0 })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateColor_table_named()
  local valid, err = Color.validateColor({ r = 0.5, g = 0.5, b = 0.5, a = 1.0 })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateColor_named_disallowed()
  local valid, err = Color.validateColor("red", { allowNamed = false })
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Named colors not allowed")
end

function TestColorValidation:test_validateColor_require_alpha_8digit()
  local valid, err = Color.validateColor("#FF0000AA", { requireAlpha = true })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

function TestColorValidation:test_validateColor_require_alpha_6digit()
  local valid, err = Color.validateColor("#FF0000", { requireAlpha = true })
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Alpha channel required")
end

function TestColorValidation:test_validateColor_nil()
  local valid, err = Color.validateColor(nil)
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "nil")
end

function TestColorValidation:test_validateColor_invalid()
  local valid, err = Color.validateColor("not-a-color")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid color format")
end

-- === sanitizeColor Tests ===

function TestColorValidation:test_sanitizeColor_hex_6digit()
  local color = Color.sanitizeColor("#FF0000")
  luaunit.assertAlmostEquals(color.r, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_hex_8digit()
  local color = Color.sanitizeColor("#FF000080")
  luaunit.assertAlmostEquals(color.r, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 0.5, 0.01)
end

function TestColorValidation:test_sanitizeColor_hex_3digit()
  local color = Color.sanitizeColor("#F00")
  luaunit.assertAlmostEquals(color.r, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_named_red()
  local color = Color.sanitizeColor("red")
  luaunit.assertAlmostEquals(color.r, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_named_blue_uppercase()
  local color = Color.sanitizeColor("BLUE")
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_named_transparent()
  local color = Color.sanitizeColor("transparent")
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 0.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_table_array()
  local color = Color.sanitizeColor({ 0.5, 0.6, 0.7, 0.8 })
  luaunit.assertAlmostEquals(color.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.6, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.7, 0.01)
  luaunit.assertAlmostEquals(color.a, 0.8, 0.01)
end

function TestColorValidation:test_sanitizeColor_table_named()
  local color = Color.sanitizeColor({ r = 0.5, g = 0.6, b = 0.7, a = 0.8 })
  luaunit.assertAlmostEquals(color.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.6, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.7, 0.01)
  luaunit.assertAlmostEquals(color.a, 0.8, 0.01)
end

function TestColorValidation:test_sanitizeColor_table_array_clamp_high()
  local color = Color.sanitizeColor({ 1.5, 1.5, 1.5, 1.5 })
  luaunit.assertAlmostEquals(color.r, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_table_array_clamp_low()
  local color = Color.sanitizeColor({ -0.5, -0.5, -0.5, -0.5 })
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 0.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_table_no_alpha()
  local color = Color.sanitizeColor({ 0.5, 0.6, 0.7 })
  luaunit.assertAlmostEquals(color.r, 0.5, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.6, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.7, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_color_instance()
  local original = Color.new(0.5, 0.6, 0.7, 0.8)
  local color = Color.sanitizeColor(original)
  luaunit.assertEquals(color, original)
end

function TestColorValidation:test_sanitizeColor_invalid_returns_default()
  local color = Color.sanitizeColor("invalid-color")
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

function TestColorValidation:test_sanitizeColor_invalid_custom_default()
  local defaultColor = Color.new(1.0, 1.0, 1.0, 1.0)
  local color = Color.sanitizeColor("invalid-color", defaultColor)
  luaunit.assertEquals(color, defaultColor)
end

function TestColorValidation:test_sanitizeColor_nil_returns_default()
  local color = Color.sanitizeColor(nil)
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 1.0, 0.01)
end

-- === Color.parse Tests ===

function TestColorValidation:test_parse_hex()
  local color = Color.parse("#00FF00")
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 1.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
end

function TestColorValidation:test_parse_named()
  local color = Color.parse("green")
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.502, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
end

function TestColorValidation:test_parse_table()
  local color = Color.parse({ 0.25, 0.50, 0.75, 1.0 })
  luaunit.assertAlmostEquals(color.r, 0.25, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.50, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.75, 0.01)
end

function TestColorValidation:test_parse_invalid()
  local color = Color.parse("not-a-color")
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
end

-- === Edge Case Tests ===

function TestColorValidation:test_edge_empty_string()
  local valid, err = Color.validateColor("")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
end

function TestColorValidation:test_edge_whitespace()
  local valid, err = Color.validateColor("  ")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
end

function TestColorValidation:test_edge_empty_table()
  local valid, err = Color.validateColor({})
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
end

function TestColorValidation:test_edge_hex_with_spaces()
  local valid, err = Color.validateColor(" #FF0000 ")
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
end

function TestColorValidation:test_edge_negative_values_clamped()
  local color = Color.sanitizeColor({ -1, -2, -3, -4 })
  luaunit.assertAlmostEquals(color.r, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.g, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.b, 0.0, 0.01)
  luaunit.assertAlmostEquals(color.a, 0.0, 0.01)
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
