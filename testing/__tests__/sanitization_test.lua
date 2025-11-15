-- Test suite for text sanitization functions
-- Tests sanitizeText, validateTextInput, escapeHtml, escapeLuaPattern, stripNonPrintable

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local utils = require("modules.utils")

-- Test suite for sanitizeText
TestSanitizeText = {}

function TestSanitizeText:testSanitizeText_NilInput()
  local result = utils.sanitizeText(nil)
  luaunit.assertEquals(result, "")
end

function TestSanitizeText:testSanitizeText_NonStringInput()
  local result = utils.sanitizeText(123)
  luaunit.assertEquals(result, "123")

  result = utils.sanitizeText(true)
  luaunit.assertEquals(result, "true")
end

function TestSanitizeText:testSanitizeText_NullBytes()
  local result = utils.sanitizeText("Hello\0World")
  luaunit.assertEquals(result, "HelloWorld")
end

function TestSanitizeText:testSanitizeText_ControlCharacters()
  -- Test removal of various control characters
  local result = utils.sanitizeText("Hello\1\2\3World")
  luaunit.assertEquals(result, "HelloWorld")
end

function TestSanitizeText:testSanitizeText_AllowNewlines()
  local result = utils.sanitizeText("Hello\nWorld", { allowNewlines = true })
  luaunit.assertEquals(result, "Hello\nWorld")

  result = utils.sanitizeText("Hello\nWorld", { allowNewlines = false })
  luaunit.assertEquals(result, "HelloWorld")
end

function TestSanitizeText:testSanitizeText_AllowTabs()
  local result = utils.sanitizeText("Hello\tWorld", { allowTabs = true })
  luaunit.assertEquals(result, "Hello\tWorld")

  result = utils.sanitizeText("Hello\tWorld", { allowTabs = false })
  luaunit.assertEquals(result, "HelloWorld")
end

function TestSanitizeText:testSanitizeText_TrimWhitespace()
  local result = utils.sanitizeText("  Hello World  ", { trimWhitespace = true })
  luaunit.assertEquals(result, "Hello World")

  result = utils.sanitizeText("  Hello World  ", { trimWhitespace = false })
  luaunit.assertEquals(result, "  Hello World  ")
end

function TestSanitizeText:testSanitizeText_MaxLength()
  local longText = string.rep("a", 100)
  local result = utils.sanitizeText(longText, { maxLength = 50 })
  luaunit.assertEquals(#result, 50)
  luaunit.assertEquals(result, string.rep("a", 50))
end

function TestSanitizeText:testSanitizeText_DefaultOptions()
  -- Test with default options
  local result = utils.sanitizeText("  Hello\nWorld\t  ")
  luaunit.assertEquals(result, "Hello\nWorld")
end

function TestSanitizeText:testSanitizeText_EmptyString()
  local result = utils.sanitizeText("")
  luaunit.assertEquals(result, "")
end

function TestSanitizeText:testSanitizeText_OnlyWhitespace()
  local result = utils.sanitizeText("   \n  \t  ", { trimWhitespace = true })
  luaunit.assertEquals(result, "")
end

-- Test suite for validateTextInput
TestValidateTextInput = {}

function TestValidateTextInput:testValidateTextInput_MinLength()
  local valid, err = utils.validateTextInput("abc", { minLength = 3 })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)

  valid, err = utils.validateTextInput("ab", { minLength = 3 })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "at least")
end

function TestValidateTextInput:testValidateTextInput_MaxLength()
  local valid, err = utils.validateTextInput("abc", { maxLength = 5 })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)

  valid, err = utils.validateTextInput("abcdef", { maxLength = 5 })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "at most")
end

function TestValidateTextInput:testValidateTextInput_Pattern()
  local valid, err = utils.validateTextInput("123", { pattern = "^%d+$" })
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)

  valid, err = utils.validateTextInput("abc", { pattern = "^%d+$" })
  luaunit.assertFalse(valid)
  luaunit.assertNotNil(err)
end

function TestValidateTextInput:testValidateTextInput_AllowedChars()
  local valid, err = utils.validateTextInput("abc123", { allowedChars = "a-z0-9" })
  luaunit.assertTrue(valid)

  valid, err = utils.validateTextInput("abc123!", { allowedChars = "a-z0-9" })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "invalid characters")
end

function TestValidateTextInput:testValidateTextInput_ForbiddenChars()
  local valid, err = utils.validateTextInput("hello world", { forbiddenChars = "@#$%%" })
  luaunit.assertTrue(valid)

  valid, err = utils.validateTextInput("hello@world", { forbiddenChars = "@#$%%" })
  luaunit.assertFalse(valid)
  luaunit.assertStrContains(err, "forbidden characters")
end

function TestValidateTextInput:testValidateTextInput_NoRules()
  local valid, err = utils.validateTextInput("anything goes")
  luaunit.assertTrue(valid)
  luaunit.assertNil(err)
end

-- Test suite for escapeHtml
TestEscapeHtml = {}

function TestEscapeHtml:testEscapeHtml_BasicChars()
  local result = utils.escapeHtml("<script>alert('xss')</script>")
  luaunit.assertEquals(result, "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;")
end

function TestEscapeHtml:testEscapeHtml_Ampersand()
  local result = utils.escapeHtml("Tom & Jerry")
  luaunit.assertEquals(result, "Tom &amp; Jerry")
end

function TestEscapeHtml:testEscapeHtml_Quotes()
  local result = utils.escapeHtml('Hello "World"')
  luaunit.assertEquals(result, "Hello &quot;World&quot;")

  result = utils.escapeHtml("It's fine")
  luaunit.assertEquals(result, "It&#39;s fine")
end

function TestEscapeHtml:testEscapeHtml_NilInput()
  local result = utils.escapeHtml(nil)
  luaunit.assertEquals(result, "")
end

function TestEscapeHtml:testEscapeHtml_EmptyString()
  local result = utils.escapeHtml("")
  luaunit.assertEquals(result, "")
end

-- Test suite for escapeLuaPattern
TestEscapeLuaPattern = {}

function TestEscapeLuaPattern:testEscapeLuaPattern_SpecialChars()
  local result = utils.escapeLuaPattern("^$()%.[]*+-?")
  luaunit.assertEquals(result, "%^%$%(%)%%%.%[%]%*%+%-%?")
end

function TestEscapeLuaPattern:testEscapeLuaPattern_NormalText()
  local result = utils.escapeLuaPattern("Hello World")
  luaunit.assertEquals(result, "Hello World")
end

function TestEscapeLuaPattern:testEscapeLuaPattern_NilInput()
  local result = utils.escapeLuaPattern(nil)
  luaunit.assertEquals(result, "")
end

function TestEscapeLuaPattern:testEscapeLuaPattern_UsageInMatch()
  -- Test that escaped pattern can be used safely
  local text = "The price is $10.50"
  local escaped = utils.escapeLuaPattern("$10.50")
  local found = text:match(escaped)
  luaunit.assertEquals(found, "$10.50")
end

-- Test suite for stripNonPrintable
TestStripNonPrintable = {}

function TestStripNonPrintable:testStripNonPrintable_BasicText()
  local result = utils.stripNonPrintable("Hello World")
  luaunit.assertEquals(result, "Hello World")
end

function TestStripNonPrintable:testStripNonPrintable_KeepNewlines()
  local result = utils.stripNonPrintable("Hello\nWorld")
  luaunit.assertEquals(result, "Hello\nWorld")
end

function TestStripNonPrintable:testStripNonPrintable_KeepTabs()
  local result = utils.stripNonPrintable("Hello\tWorld")
  luaunit.assertEquals(result, "Hello\tWorld")
end

function TestStripNonPrintable:testStripNonPrintable_RemoveControlChars()
  local result = utils.stripNonPrintable("Hello\1\2\3World")
  luaunit.assertEquals(result, "HelloWorld")
end

function TestStripNonPrintable:testStripNonPrintable_NilInput()
  local result = utils.stripNonPrintable(nil)
  luaunit.assertEquals(result, "")
end

function TestStripNonPrintable:testStripNonPrintable_EmptyString()
  local result = utils.stripNonPrintable("")
  luaunit.assertEquals(result, "")
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
