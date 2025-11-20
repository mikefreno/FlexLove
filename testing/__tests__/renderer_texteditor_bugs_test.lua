-- Bug-finding and error handling tests for Renderer and TextEditor
-- Tests edge cases, nil handling, division by zero, invalid inputs, etc.

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

local FlexLove = require("FlexLove")
FlexLove.init()

-- ============================================================================
-- Renderer Bug Tests
-- ============================================================================

TestRendererBugs = {}

function TestRendererBugs:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestRendererBugs:tearDown()
  FlexLove.endFrame()
end

function TestRendererBugs:test_nil_background_color()
  -- Should handle nil backgroundColor gracefully
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    backgroundColor = nil,
  })

  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.backgroundColor)
end

function TestRendererBugs:test_invalid_opacity()
  -- Opacity > 1
  local element = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    opacity = 5,
  })
  luaunit.assertNotNil(element)

  -- Negative opacity
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    opacity = -1,
  })
  luaunit.assertNotNil(element2)

  -- NaN opacity
  local element3 = FlexLove.new({
    id = "test3",
    width = 100,
    height = 100,
    opacity = 0 / 0,
  })
  luaunit.assertNotNil(element3)
end

function TestRendererBugs:test_invalid_corner_radius()
  -- Negative corner radius
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    cornerRadius = -10,
  })
  luaunit.assertNotNil(element)

  -- Huge corner radius (larger than element)
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    cornerRadius = 1000,
  })
  luaunit.assertNotNil(element2)
end

function TestRendererBugs:test_invalid_border_config()
  -- Non-boolean border values
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    border = {
      top = "yes",
      right = 1,
      bottom = nil,
      left = {},
    },
  })
  luaunit.assertNotNil(element)
end

function TestRendererBugs:test_missing_image_path()
  -- Non-existent image path
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    imagePath = "/nonexistent/path/to/image.png",
  })
  luaunit.assertNotNil(element)
end

function TestRendererBugs:test_invalid_object_fit()
  -- Invalid objectFit value
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    imagePath = "test.png",
    objectFit = "invalid-value",
  })
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.objectFit, "invalid-value") -- Should store but might break rendering
end

function TestRendererBugs:test_zero_dimensions()
  -- Zero width
  local element = FlexLove.new({
    id = "test1",
    width = 0,
    height = 100,
  })
  luaunit.assertNotNil(element)

  -- Zero height
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 0,
  })
  luaunit.assertNotNil(element2)

  -- Both zero
  local element3 = FlexLove.new({
    id = "test3",
    width = 0,
    height = 0,
  })
  luaunit.assertNotNil(element3)
end

function TestRendererBugs:test_negative_dimensions()
  -- Negative width
  local element = FlexLove.new({
    id = "test1",
    width = -100,
    height = 100,
  })
  luaunit.assertNotNil(element)

  -- Negative height
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = -100,
  })
  luaunit.assertNotNil(element2)
end

function TestRendererBugs:test_text_rendering_with_nil_text()
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    text = nil,
  })
  luaunit.assertNotNil(element)
end

function TestRendererBugs:test_text_rendering_with_empty_string()
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    text = "",
  })
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.text, "")
end

function TestRendererBugs:test_text_rendering_with_very_long_text()
  local longText = string.rep("A", 10000)
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    text = longText,
  })
  luaunit.assertNotNil(element)
end

function TestRendererBugs:test_text_rendering_with_special_characters()
  -- Newlines
  local element1 = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    text = "Line1\nLine2\nLine3",
  })
  luaunit.assertNotNil(element1)

  -- Tabs
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    text = "Col1\tCol2\tCol3",
  })
  luaunit.assertNotNil(element2)

  -- Unicode
  local element3 = FlexLove.new({
    id = "test3",
    width = 100,
    height = 100,
    text = "Hello 世界 🌍",
  })
  luaunit.assertNotNil(element3)
end

function TestRendererBugs:test_invalid_text_align()
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    text = "Test",
    textAlign = "invalid-alignment",
  })
  luaunit.assertNotNil(element)
end

function TestRendererBugs:test_invalid_text_size()
  -- Zero text size
  local element1 = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    text = "Test",
    textSize = 0,
  })
  luaunit.assertNotNil(element1)

  -- Negative text size
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    text = "Test",
    textSize = -10,
  })
  luaunit.assertNotNil(element2)

  -- Huge text size
  local element3 = FlexLove.new({
    id = "test3",
    width = 100,
    height = 100,
    text = "Test",
    textSize = 10000,
  })
  luaunit.assertNotNil(element3)
end

function TestRendererBugs:test_blur_with_invalid_intensity()
  -- Negative intensity
  local element1 = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    contentBlur = { intensity = -10, quality = 5 },
  })
  luaunit.assertNotNil(element1)

  -- Intensity > 100
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    backdropBlur = { intensity = 200, quality = 5 },
  })
  luaunit.assertNotNil(element2)
end

function TestRendererBugs:test_blur_with_invalid_quality()
  -- Quality < 1
  local element1 = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    contentBlur = { intensity = 10, quality = 0 },
  })
  luaunit.assertNotNil(element1)

  -- Quality > 10
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    contentBlur = { intensity = 10, quality = 100 },
  })
  luaunit.assertNotNil(element2)
end

function TestRendererBugs:test_theme_with_invalid_component()
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    theme = "nonexistent-theme",
    themeComponent = "nonexistent-component",
  })
  luaunit.assertNotNil(element)
end

-- ============================================================================
-- TextEditor Bug Tests
-- ============================================================================

TestTextEditorBugs = {}

function TestTextEditorBugs:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestTextEditorBugs:tearDown()
  FlexLove.endFrame()
end

function TestTextEditorBugs:test_editable_without_text()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
  })
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.text, "")
end

function TestTextEditorBugs:test_editable_with_nil_text()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = nil,
  })
  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_cursor_position_beyond_text_length()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Hello",
  })

  -- Try to set cursor beyond text length
  if element._textEditor then
    element._textEditor:setCursorPosition(1000)
    -- Should clamp to text length
    luaunit.assertTrue(element._textEditor:getCursorPosition() <= 5)
  end
end

function TestTextEditorBugs:test_cursor_position_negative()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Hello",
  })

  if element._textEditor then
    element._textEditor:setCursorPosition(-10)
    -- Should clamp to 0
    luaunit.assertEquals(element._textEditor:getCursorPosition(), 0)
  end
end

function TestTextEditorBugs:test_selection_with_invalid_range()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  if element._textEditor then
    -- Start > end
    element._textEditor:setSelection(10, 2)
    luaunit.assertNotNil(element._textEditor:getSelection())

    -- Both beyond text length
    element._textEditor:setSelection(100, 200)
    luaunit.assertNotNil(element._textEditor:getSelection())

    -- Negative values
    element._textEditor:setSelection(-5, -1)
    luaunit.assertNotNil(element._textEditor:getSelection())
  end
end

function TestTextEditorBugs:test_insert_text_at_invalid_position()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Hello",
  })

  if element._textEditor then
    -- Insert beyond text length
    element._textEditor:insertText(" World", 1000)
    luaunit.assertNotNil(element._textEditor:getText())

    -- Insert at negative position
    element._textEditor:insertText("X", -10)
    luaunit.assertNotNil(element._textEditor:getText())
  end
end

function TestTextEditorBugs:test_delete_text_with_invalid_range()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Hello World",
  })

  if element._textEditor then
    local originalText = element._textEditor:getText()

    -- Delete beyond text length
    element._textEditor:deleteText(5, 1000)
    luaunit.assertNotNil(element._textEditor:getText())

    -- Delete with negative positions
    element._textEditor:deleteText(-10, -5)
    luaunit.assertNotNil(element._textEditor:getText())

    -- Delete with start > end
    element._textEditor:deleteText(10, 5)
    luaunit.assertNotNil(element._textEditor:getText())
  end
end

function TestTextEditorBugs:test_max_length_zero()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "",
    maxLength = 0,
  })

  if element._textEditor then
    element._textEditor:setText("Should not appear")
    luaunit.assertEquals(element._textEditor:getText(), "")
  end
end

function TestTextEditorBugs:test_max_length_negative()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Test",
    maxLength = -10,
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_max_lines_zero()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 100,
    editable = true,
    multiline = true,
    text = "",
    maxLines = 0,
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_multiline_with_very_long_lines()
  local longLine = string.rep("A", 10000)
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 100,
    editable = true,
    multiline = true,
    text = longLine,
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_text_wrap_with_zero_width()
  local element = FlexLove.new({
    id = "test",
    width = 0,
    height = 100,
    editable = true,
    multiline = true,
    textWrap = "word",
    text = "This should wrap",
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_password_mode_with_empty_text()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    passwordMode = true,
    text = "",
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_input_type_number_with_non_numeric()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    inputType = "number",
    text = "abc123def",
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_cursor_blink_rate_zero()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    cursorBlinkRate = 0,
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_cursor_blink_rate_negative()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    cursorBlinkRate = -1,
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_text_editor_update_with_invalid_dt()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Test",
  })

  if element._textEditor then
    -- Negative dt
    element._textEditor:update(-1)

    -- NaN dt
    element._textEditor:update(0 / 0)

    -- Infinite dt
    element._textEditor:update(math.huge)

    -- All should handle gracefully
    luaunit.assertNotNil(element._textEditor)
  end
end

function TestTextEditorBugs:test_placeholder_with_text()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Actual text",
    placeholder = "Placeholder",
  })

  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.text, "Actual text")
end

function TestTextEditorBugs:test_sanitization_with_malicious_input()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "<script>alert('xss')</script>",
    sanitize = true,
  })

  luaunit.assertNotNil(element)
  -- Text should be sanitized
  luaunit.assertNotNil(element.text)
end

function TestTextEditorBugs:test_text_overflow_with_no_scrollable()
  local element = FlexLove.new({
    id = "test",
    width = 50,
    height = 30,
    editable = true,
    text = "This is a very long text that will overflow",
    textOverflow = "ellipsis",
    scrollable = false,
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_auto_grow_with_fixed_height()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    multiline = true,
    autoGrow = true,
    text = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5",
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_select_on_focus_with_empty_text()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    selectOnFocus = true,
    text = "",
  })

  luaunit.assertNotNil(element)

  if element._textEditor then
    element._textEditor:focus()
    -- Should not crash with empty text
    luaunit.assertNotNil(element._textEditor)
  end
end

function TestTextEditorBugs:test_word_navigation_with_no_words()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "     ", -- Only spaces
  })

  if element._textEditor then
    element._textEditor:moveCursorToNextWord()
    luaunit.assertNotNil(element._textEditor:getCursorPosition())

    element._textEditor:moveCursorToPreviousWord()
    luaunit.assertNotNil(element._textEditor:getCursorPosition())
  end
end

function TestTextEditorBugs:test_word_navigation_with_single_character()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "A",
  })

  if element._textEditor then
    element._textEditor:moveCursorToNextWord()
    luaunit.assertNotNil(element._textEditor:getCursorPosition())
  end
end

function TestTextEditorBugs:test_multiline_with_only_newlines()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 100,
    editable = true,
    multiline = true,
    text = "\n\n\n\n",
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_text_with_null_bytes()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Hello\0World",
  })

  luaunit.assertNotNil(element)
end

function TestTextEditorBugs:test_concurrent_focus_blur()
  local element = FlexLove.new({
    id = "test",
    width = 200,
    height = 30,
    editable = true,
    text = "Test",
  })

  if element._textEditor then
    element._textEditor:focus()
    element._textEditor:blur()
    element._textEditor:focus()
    element._textEditor:blur()

    luaunit.assertNotNil(element._textEditor)
  end
end

-- Run tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
