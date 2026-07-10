-- Test suite for TextSanitizer.lua (extracted from utils.lua)
-- Verifies the focused module produces identical output to the old utils
-- text-sanitization functions.

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")
ErrorHandler.init({})

local utils = require("modules.utils")
local TextSanitizer = require("modules.TextSanitizer")
utils.init({ ErrorHandler = ErrorHandler })

TestTextSanitizer = {}

function TestTextSanitizer:testSanitizeText_Nil()
  luaunit.assertEquals(TextSanitizer.sanitizeText(nil), "")
end

function TestTextSanitizer:testSanitizeText_StripsControls()
  luaunit.assertEquals(TextSanitizer.sanitizeText("a\0b"), "ab")
  luaunit.assertEquals(TextSanitizer.sanitizeText("a\1b"), "ab")
end

function TestTextSanitizer:testSanitizeText_KeepsInnerNewlinesAndTabs()
  -- control stripping preserves \t \n \r but trims outer whitespace
  luaunit.assertEquals(TextSanitizer.sanitizeText("\thi\n"), "hi")
  luaunit.assertEquals(TextSanitizer.sanitizeText("a\tb\nc"), "a\tb\nc")
  luaunit.assertEquals(TextSanitizer.sanitizeText("  x  "), "x")
end

function TestTextSanitizer:testSanitizeText_Trims()
  luaunit.assertEquals(TextSanitizer.sanitizeText("  hello  "), "hello")
end

function TestTextSanitizer:testSanitizeText_MaxLength()
  local out = TextSanitizer.sanitizeText("abcdef", { maxLength = 3 })
  luaunit.assertEquals(out, "abc")
end

function TestTextSanitizer:testValidateTextInput_MinLength()
  local ok, err = TextSanitizer.validateTextInput("ab", { minLength = 5 })
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(err)
end

function TestTextSanitizer:testValidateTextInput_MaxLength()
  local ok, err = TextSanitizer.validateTextInput("abcdef", { maxLength = 3 })
  luaunit.assertFalse(ok)
  luaunit.assertNotNil(err)
end

function TestTextSanitizer:testValidateTextInput_Pattern()
  local ok = TextSanitizer.validateTextInput("12345", { pattern = "^%d+$" })
  luaunit.assertTrue(ok)
  local ok2, err = TextSanitizer.validateTextInput("abc", { pattern = "^%d+$" })
  luaunit.assertFalse(ok2)
  luaunit.assertNotNil(err)
end

function TestTextSanitizer:testValidateTextInput_AllowedChars()
  local ok = TextSanitizer.validateTextInput("abc", { allowedChars = "a-z" })
  luaunit.assertTrue(ok)
  local ok2 = TextSanitizer.validateTextInput("ab1", { allowedChars = "a-z" })
  luaunit.assertFalse(ok2)
end

function TestTextSanitizer:testValidateTextInput_ForbiddenChars()
  local ok = TextSanitizer.validateTextInput("hello", { forbiddenChars = "0-9" })
  luaunit.assertTrue(ok)
  local ok2 = TextSanitizer.validateTextInput("hel5o", { forbiddenChars = "0-9" })
  luaunit.assertFalse(ok2)
end

function TestTextSanitizer:testValidateTextRange_Alias()
  local ok, _ = TextSanitizer.validateTextRange("abcdef", { maxLength = 3 })
  luaunit.assertFalse(ok)
end

function TestTextSanitizer:testEscapeHtml()
  luaunit.assertEquals(
    TextSanitizer.escapeHtml('<a href="x">&\'</a>'),
    "&lt;a href=&quot;x&quot;&gt;&amp;&#39;&lt;/a&gt;"
  )
  luaunit.assertEquals(TextSanitizer.escapeHtml(nil), "")
end

function TestTextSanitizer:testEscapeLuaPattern()
  luaunit.assertEquals(TextSanitizer.escapeLuaPattern("a.b*c"), "a%.b%*c")
  luaunit.assertEquals(TextSanitizer.escapeLuaPattern(nil), "")
end

function TestTextSanitizer:testStripNonPrintable()
  luaunit.assertEquals(TextSanitizer.stripNonPrintable("a\1b\tc\nd"), "ab\tc\nd")
  luaunit.assertEquals(TextSanitizer.stripNonPrintable(nil), "")
end

function TestTextSanitizer:testAliasParity()
  luaunit.assertEquals(utils.sanitizeText, TextSanitizer.sanitizeText)
  luaunit.assertEquals(utils.escapeHtml, TextSanitizer.escapeHtml)
  luaunit.assertEquals(utils.escapeLuaPattern, TextSanitizer.escapeLuaPattern)
  luaunit.assertEquals(utils.stripNonPrintable, TextSanitizer.stripNonPrintable)
  luaunit.assertEquals(utils.validateTextInput, TextSanitizer.validateTextInput)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
