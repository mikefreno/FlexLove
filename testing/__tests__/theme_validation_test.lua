-- Import test framework
package.path = package.path .. ";./?.lua;./game/?.lua"
local luaunit = require("testing.luaunit")

-- Set up LÖVE stub environment
require("testing.loveStub")

-- Import the Theme module
local Theme = require("modules.Theme")
local Color = require("modules.Color")

-- Test Suite for Theme Validation
TestThemeValidation = {}

-- === Basic Theme Validation ===

function TestThemeValidation:test_validate_nil_theme()
  local valid, errors = Theme.validateTheme(nil)
  luaunit.assertFalse(valid)
  luaunit.assertEquals(#errors, 1)
  luaunit.assertStrContains(errors[1], "nil")
end

function TestThemeValidation:test_validate_non_table_theme()
  local valid, errors = Theme.validateTheme("not a table")
  luaunit.assertFalse(valid)
  luaunit.assertEquals(#errors, 1)
  luaunit.assertStrContains(errors[1], "must be a table")
end

function TestThemeValidation:test_validate_empty_theme()
  local valid, errors = Theme.validateTheme({})
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  -- Should have error about missing name
end

function TestThemeValidation:test_validate_minimal_valid_theme()
  local theme = {
    name = "Test Theme"
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_theme_with_empty_name()
  local theme = {
    name = ""
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_theme_with_non_string_name()
  local theme = {
    name = 123
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

-- === Color Validation ===

function TestThemeValidation:test_validate_valid_colors()
  local theme = {
    name = "Test Theme",
    colors = {
      primary = Color.new(1, 0, 0, 1),
      secondary = Color.new(0, 1, 0, 1)
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_colors_with_hex()
  local theme = {
    name = "Test Theme",
    colors = {
      primary = "#FF0000"
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_colors_with_named()
  local theme = {
    name = "Test Theme",
    colors = {
      primary = "red",
      secondary = "blue"
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_invalid_color()
  local theme = {
    name = "Test Theme",
    colors = {
      primary = "not-a-color"
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "primary")
end

function TestThemeValidation:test_validate_colors_non_table()
  local theme = {
    name = "Test Theme",
    colors = "should be a table"
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_color_with_non_string_name()
  local theme = {
    name = "Test Theme",
    colors = {
      [123] = Color.new(1, 0, 0, 1)
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

-- === Font Validation ===

function TestThemeValidation:test_validate_valid_fonts()
  local theme = {
    name = "Test Theme",
    fonts = {
      default = "path/to/font.ttf",
      heading = "path/to/heading.ttf"
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_fonts_non_table()
  local theme = {
    name = "Test Theme",
    fonts = "should be a table"
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_font_with_non_string_path()
  local theme = {
    name = "Test Theme",
    fonts = {
      default = 123
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_font_with_non_string_name()
  local theme = {
    name = "Test Theme",
    fonts = {
      [123] = "path/to/font.ttf"
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

-- === Component Validation ===

function TestThemeValidation:test_validate_valid_component()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png"
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_component_with_insets()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        insets = {left = 5, top = 5, right = 5, bottom = 5}
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_component_with_missing_inset()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        insets = {left = 5, top = 5, right = 5} -- missing bottom
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "bottom")
end

function TestThemeValidation:test_validate_component_with_negative_inset()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        insets = {left = -5, top = 5, right = 5, bottom = 5}
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "non-negative")
end

function TestThemeValidation:test_validate_component_with_states()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        states = {
          hover = {
            atlas = "path/to/button_hover.png"
          },
          pressed = {
            atlas = "path/to/button_pressed.png"
          }
        }
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_component_with_invalid_state()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        states = {
          hover = "should be a table"
        }
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_component_with_scaleCorners()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        scaleCorners = 2.0
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_component_with_invalid_scaleCorners()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        scaleCorners = -1
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "positive")
end

function TestThemeValidation:test_validate_component_with_valid_scalingAlgorithm()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        scalingAlgorithm = "nearest"
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_component_with_invalid_scalingAlgorithm()
  local theme = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        scalingAlgorithm = "invalid"
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_components_non_table()
  local theme = {
    name = "Test Theme",
    components = "should be a table"
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

-- === ContentAutoSizingMultiplier Validation ===

function TestThemeValidation:test_validate_valid_multiplier()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = {width = 1.1, height = 1.2}
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_multiplier_with_only_width()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = {width = 1.1}
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_multiplier_non_table()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = 1.5
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_multiplier_with_non_number()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = {width = "not a number"}
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_multiplier_with_negative()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = {width = -1}
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "positive")
end

function TestThemeValidation:test_validate_multiplier_with_zero()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = {width = 0}
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

-- === Global Atlas Validation ===

function TestThemeValidation:test_validate_valid_global_atlas()
  local theme = {
    name = "Test Theme",
    atlas = "path/to/atlas.png"
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

-- === Strict Mode Validation ===

function TestThemeValidation:test_validate_unknown_field_strict()
  local theme = {
    name = "Test Theme",
    unknownField = "should trigger warning"
  }
  local valid, errors = Theme.validateTheme(theme, {strict = true})
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "Unknown field")
end

function TestThemeValidation:test_validate_unknown_field_non_strict()
  local theme = {
    name = "Test Theme",
    unknownField = "should be ignored"
  }
  local valid, errors = Theme.validateTheme(theme, {strict = false})
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

-- === Theme Sanitization ===

function TestThemeValidation:test_sanitize_nil_theme()
  local sanitized = Theme.sanitizeTheme(nil)
  luaunit.assertNotNil(sanitized)
  luaunit.assertEquals(sanitized.name, "Invalid Theme")
end

function TestThemeValidation:test_sanitize_theme_without_name()
  local theme = {
    colors = {primary = "red"}
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertEquals(sanitized.name, "Unnamed Theme")
end

function TestThemeValidation:test_sanitize_theme_with_non_string_name()
  local theme = {
    name = 123
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertEquals(type(sanitized.name), "string")
end

function TestThemeValidation:test_sanitize_colors()
  local theme = {
    name = "Test",
    colors = {
      valid = "red",
      invalid = "not-a-color"
    }
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertNotNil(sanitized.colors.valid)
  luaunit.assertNotNil(sanitized.colors.invalid) -- Should have fallback
end

function TestThemeValidation:test_sanitize_removes_non_string_color_names()
  local theme = {
    name = "Test",
    colors = {
      [123] = "red"
    }
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertNil(sanitized.colors[123])
end

function TestThemeValidation:test_sanitize_fonts()
  local theme = {
    name = "Test",
    fonts = {
      default = "path/to/font.ttf",
      invalid = 123
    }
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertNotNil(sanitized.fonts.default)
  luaunit.assertNil(sanitized.fonts.invalid)
end

function TestThemeValidation:test_sanitize_preserves_components()
  local theme = {
    name = "Test",
    components = {
      button = {atlas = "path/to/button.png"}
    }
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertNotNil(sanitized.components.button)
  luaunit.assertEquals(sanitized.components.button.atlas, "path/to/button.png")
end

-- === Complex Theme Validation ===

function TestThemeValidation:test_validate_complete_theme()
  local theme = {
    name = "Complete Theme",
    atlas = "path/to/atlas.png",
    contentAutoSizingMultiplier = {width = 1.05, height = 1.1},
    colors = {
      primary = Color.new(1, 0, 0, 1),
      secondary = "#00FF00",
      tertiary = "blue"
    },
    fonts = {
      default = "path/to/font.ttf",
      heading = "path/to/heading.ttf"
    },
    components = {
      button = {
        atlas = "path/to/button.png",
        insets = {left = 5, top = 5, right = 5, bottom = 5},
        scaleCorners = 2,
        scalingAlgorithm = "nearest",
        states = {
          hover = {
            atlas = "path/to/button_hover.png"
          },
          pressed = {
            atlas = "path/to/button_pressed.png"
          }
        }
      },
      panel = {
        atlas = "path/to/panel.png"
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_theme_with_multiple_errors()
  local theme = {
    name = "",
    colors = {
      invalid1 = "not-a-color",
      invalid2 = 123
    },
    fonts = {
      bad = 456
    },
    components = {
      button = {
        insets = {left = -5} -- missing fields and negative
      }
    }
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors >= 5) -- Should have multiple errors
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
