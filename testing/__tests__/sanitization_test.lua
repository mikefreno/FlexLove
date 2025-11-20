-- Test suite for text sanitization functions
-- Tests sanitizeText, validateTextInput, escapeHtml, escapeLuaPattern, stripNonPrintable

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

-- Mock dependencies
local mockContext = {
  _immediateMode = false,
  _focusedElement = nil,
}

local mockStateManager = {
  getState = function()
    return nil
  end,
  setState = function() end,
}

-- Test Suite for TextEditor Sanitization
TestTextEditorSanitization = {}

---Helper to create a TextEditor instance
function TestTextEditorSanitization:_createEditor(config)
  local TextEditor = require("modules.TextEditor")
  config = config or {}
  local deps = {
    Context = mockContext,
    StateManager = mockStateManager,
    Color = Color,
    utils = utils,
  }
  return TextEditor.new(config, deps)
end

-- === Sanitization Enabled Tests ===

function TestTextEditorSanitization:test_sanitization_enabled_by_default()
  local editor = self:_createEditor({ editable = true })
  luaunit.assertTrue(editor.sanitize)
end

function TestTextEditorSanitization:test_sanitization_can_be_disabled()
  local editor = self:_createEditor({ editable = true, sanitize = false })
  luaunit.assertFalse(editor.sanitize)
end

function TestTextEditorSanitization:test_setText_removes_control_characters()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello\x00World\x01Test")
  luaunit.assertEquals(editor:getText(), "HelloWorldTest")
end

function TestTextEditorSanitization:test_setText_preserves_valid_text()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello World! 123")
  luaunit.assertEquals(editor:getText(), "Hello World! 123")
end

function TestTextEditorSanitization:test_setText_removes_multiple_control_chars()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Test\x00\x01\x02\x03\x04Data")
  luaunit.assertEquals(editor:getText(), "TestData")
end

function TestTextEditorSanitization:test_setText_with_sanitization_disabled()
  local editor = self:_createEditor({ editable = true, sanitize = false })
  editor:setText("Hello\x00World")
  luaunit.assertEquals(editor:getText(), "Hello\x00World")
end

function TestTextEditorSanitization:test_setText_skip_sanitization_parameter()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello\x00World", true) -- skipSanitization = true
  luaunit.assertEquals(editor:getText(), "Hello\x00World")
end

-- === Initial Text Sanitization ===

function TestTextEditorSanitization:test_initial_text_is_sanitized()
  local editor = self:_createEditor({
    editable = true,
    text = "Initial\x00Text\x01",
  })
  luaunit.assertEquals(editor:getText(), "InitialText")
end

function TestTextEditorSanitization:test_initial_text_preserved_when_disabled()
  local editor = self:_createEditor({
    editable = true,
    sanitize = false,
    text = "Initial\x00Text",
  })
  luaunit.assertEquals(editor:getText(), "Initial\x00Text")
end

-- === insertText Sanitization ===

function TestTextEditorSanitization:test_insertText_sanitizes_input()
  local editor = self:_createEditor({ editable = true, text = "Hello" })
  editor:insertText("\x00World", 5)
  luaunit.assertEquals(editor:getText(), "HelloWorld")
end

function TestTextEditorSanitization:test_insertText_with_valid_text()
  local editor = self:_createEditor({ editable = true, text = "Hello" })
  editor:insertText(" World", 5)
  luaunit.assertEquals(editor:getText(), "Hello World")
end

function TestTextEditorSanitization:test_insertText_empty_after_sanitization()
  local editor = self:_createEditor({ editable = true, text = "Hello" })
  editor:insertText("\x00\x01\x02", 5) -- Only control chars
  luaunit.assertEquals(editor:getText(), "Hello") -- Should remain unchanged
end

-- === Length Limiting ===

function TestTextEditorSanitization:test_maxLength_enforced_on_setText()
  local editor = self:_createEditor({ editable = true, maxLength = 10 })
  editor:setText("This is a very long text")
  luaunit.assertEquals(#editor:getText(), 10)
end

function TestTextEditorSanitization:test_maxLength_enforced_on_insertText()
  local editor = self:_createEditor({ editable = true, text = "12345", maxLength = 10 })
  editor:insertText("67890", 5) -- This would make it exactly 10
  luaunit.assertEquals(editor:getText(), "1234567890")
end

function TestTextEditorSanitization:test_maxLength_truncates_excess()
  local editor = self:_createEditor({ editable = true, text = "12345", maxLength = 10 })
  editor:insertText("67890EXTRA", 5) -- Would exceed limit
  luaunit.assertEquals(editor:getText(), "1234567890")
end

function TestTextEditorSanitization:test_maxLength_prevents_insert_when_full()
  local editor = self:_createEditor({ editable = true, text = "1234567890", maxLength = 10 })
  editor:insertText("X", 10)
  luaunit.assertEquals(editor:getText(), "1234567890") -- Should not change
end

-- === Newline Handling ===

function TestTextEditorSanitization:test_newlines_allowed_in_multiline()
  local editor = self:_createEditor({ editable = true, multiline = true })
  editor:setText("Line1\nLine2")
  luaunit.assertEquals(editor:getText(), "Line1\nLine2")
end

function TestTextEditorSanitization:test_newlines_removed_in_singleline()
  local editor = self:_createEditor({ editable = true, multiline = false })
  editor:setText("Line1\nLine2")
  luaunit.assertEquals(editor:getText(), "Line1Line2")
end

function TestTextEditorSanitization:test_allowNewlines_explicit_false()
  local editor = self:_createEditor({
    editable = true,
    multiline = true,
    allowNewlines = false,
  })
  editor:setText("Line1\nLine2")
  luaunit.assertEquals(editor:getText(), "Line1Line2")
end

-- === Tab Handling ===

function TestTextEditorSanitization:test_tabs_allowed_by_default()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello\tWorld")
  luaunit.assertEquals(editor:getText(), "Hello\tWorld")
end

function TestTextEditorSanitization:test_tabs_removed_when_disabled()
  local editor = self:_createEditor({
    editable = true,
    allowTabs = false,
  })
  editor:setText("Hello\tWorld")
  luaunit.assertEquals(editor:getText(), "HelloWorld")
end

-- === Custom Sanitizer ===

function TestTextEditorSanitization:test_custom_sanitizer_used()
  local customSanitizer = function(text)
    return text:upper()
  end

  local editor = self:_createEditor({
    editable = true,
    customSanitizer = customSanitizer,
  })
  editor:setText("hello world")
  luaunit.assertEquals(editor:getText(), "HELLO WORLD")
end

function TestTextEditorSanitization:test_custom_sanitizer_with_control_chars()
  local customSanitizer = function(text)
    -- Custom sanitizer that replaces control chars with *
    return text:gsub("[\x00-\x1F]", "*")
  end

  local editor = self:_createEditor({
    editable = true,
    customSanitizer = customSanitizer,
  })
  editor:setText("Hello\x00World\x01")
  luaunit.assertEquals(editor:getText(), "Hello*World*")
end

-- === Unicode and Special Characters ===

function TestTextEditorSanitization:test_unicode_preserved()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello 世界 🌍")
  luaunit.assertEquals(editor:getText(), "Hello 世界 🌍")
end

function TestTextEditorSanitization:test_emoji_preserved()
  local editor = self:_createEditor({ editable = true })
  editor:setText("😀😃😄😁")
  luaunit.assertEquals(editor:getText(), "😀😃😄😁")
end

function TestTextEditorSanitization:test_special_chars_preserved()
  local editor = self:_createEditor({ editable = true })
  editor:setText("!@#$%^&*()_+-=[]{}|;':\",./<>?")
  luaunit.assertEquals(editor:getText(), "!@#$%^&*()_+-=[]{}|;':\",./<>?")
end

-- === Edge Cases ===

function TestTextEditorSanitization:test_empty_string()
  local editor = self:_createEditor({ editable = true })
  editor:setText("")
  luaunit.assertEquals(editor:getText(), "")
end

function TestTextEditorSanitization:test_only_control_characters()
  local editor = self:_createEditor({ editable = true })
  editor:setText("\x00\x01\x02\x03")
  luaunit.assertEquals(editor:getText(), "")
end

function TestTextEditorSanitization:test_nil_text()
  local editor = self:_createEditor({ editable = true })
  editor:setText(nil)
  luaunit.assertEquals(editor:getText(), "")
end

function TestTextEditorSanitization:test_very_long_text_with_control_chars()
  local editor = self:_createEditor({ editable = true })
  local longText = string.rep("Hello\x00World", 100)
  editor:setText(longText)
  luaunit.assertStrContains(editor:getText(), "Hello")
  luaunit.assertStrContains(editor:getText(), "World")
  luaunit.assertNotStrContains(editor:getText(), "\x00")
end

function TestTextEditorSanitization:test_mixed_valid_and_invalid()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Valid\x00Text\x01With\x02Control\x03Chars")
  luaunit.assertEquals(editor:getText(), "ValidTextWithControlChars")
end

-- === Whitespace Handling ===

function TestTextEditorSanitization:test_spaces_preserved()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello   World")
  luaunit.assertEquals(editor:getText(), "Hello   World")
end

function TestTextEditorSanitization:test_leading_trailing_spaces_preserved()
  local editor = self:_createEditor({ editable = true })
  editor:setText("  Hello World  ")
  luaunit.assertEquals(editor:getText(), "  Hello World  ")
end

-- === Integration Tests ===

function TestTextEditorSanitization:test_cursor_position_after_sanitization()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello")
  editor:insertText("\x00World", 5)
  -- Cursor should be at end of "HelloWorld" = position 10
  luaunit.assertEquals(editor._cursorPosition, 10)
end

function TestTextEditorSanitization:test_multiple_operations()
  local editor = self:_createEditor({ editable = true })
  editor:setText("Hello")
  editor:insertText(" ", 5)
  editor:insertText("World\x00", 6)
  luaunit.assertEquals(editor:getText(), "Hello World")
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
