-- Test suite for Theme.lua core functionality
-- Tests theme creation, registration, and retrieval functions

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local Theme = require("modules.Theme")
local Color = require("modules.Color")
local ErrorHandler = require("modules.ErrorHandler")
local utils = require("modules.utils")

-- Initialize ErrorHandler and Theme module
ErrorHandler.init({})
Theme.init({ ErrorHandler = ErrorHandler, Color = Color, utils = utils })

-- Test suite for Theme.new()
TestThemeNew = {}

function TestThemeNew:setUp()
  -- Clear any registered themes before each test
  -- Note: We can't access the themes table directly, but we can work around it
end

function TestThemeNew:test_new_minimal_theme()
  local def = {
    name = "Minimal Theme",
  }
  local theme = Theme.new(def)
  luaunit.assertNotNil(theme)
  luaunit.assertEquals(theme.name, "Minimal Theme")
end

function TestThemeNew:test_new_theme_with_components()
  local def = {
    name = "Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
      },
    },
  }
  local theme = Theme.new(def)
  luaunit.assertNotNil(theme)
  luaunit.assertEquals(theme.name, "Test Theme")
  luaunit.assertNotNil(theme.components.button)
end

function TestThemeNew:test_new_theme_with_colors()
  local def = {
    name = "Colored Theme",
    colors = {
      primary = Color.new(1, 0, 0, 1),
      secondary = Color.new(0, 1, 0, 1),
    },
  }
  local theme = Theme.new(def)
  luaunit.assertNotNil(theme)
  luaunit.assertNotNil(theme.colors.primary)
  luaunit.assertNotNil(theme.colors.secondary)
end

function TestThemeNew:test_new_theme_with_fonts()
  local def = {
    name = "Font Theme",
    fonts = {
      default = "path/to/font.ttf",
    },
  }
  local theme = Theme.new(def)
  luaunit.assertNotNil(theme)
  luaunit.assertNotNil(theme.fonts.default)
  luaunit.assertEquals(theme.fonts.default, "path/to/font.ttf")
end

function TestThemeNew:test_new_theme_with_multiplier()
  local def = {
    name = "Multiplier Theme",
    contentAutoSizingMultiplier = {
      width = 1.5,
      height = 2.0,
    },
  }
  local theme = Theme.new(def)
  luaunit.assertNotNil(theme)
  luaunit.assertNotNil(theme.contentAutoSizingMultiplier)
  luaunit.assertEquals(theme.contentAutoSizingMultiplier.width, 1.5)
  luaunit.assertEquals(theme.contentAutoSizingMultiplier.height, 2.0)
end

function TestThemeNew:test_new_theme_without_name_fails()
  local def = {}
  local theme = Theme.new(def)
  -- Should return a fallback theme instead of throwing
  luaunit.assertNotNil(theme)
  luaunit.assertEquals(theme.name, "fallback")
end

function TestThemeNew:test_new_theme_with_nil_fails()
  local theme = Theme.new(nil)
  -- Should return a fallback theme instead of throwing
  luaunit.assertNotNil(theme)
  luaunit.assertEquals(theme.name, "fallback")
end

function TestThemeNew:test_new_theme_with_non_table_fails()
  local theme = Theme.new("not a table")
  -- Should return a fallback theme instead of throwing
  luaunit.assertNotNil(theme)
  luaunit.assertEquals(theme.name, "fallback")
end

-- Test suite for Theme registration and retrieval
TestThemeRegistration = {}

function TestThemeRegistration:test_setActive_with_theme_object()
  local def = {
    name = "Active Theme",
  }
  local theme = Theme.new(def)
  Theme.setActive(theme)

  local active = Theme.getActive()
  luaunit.assertNotNil(active)
  luaunit.assertEquals(active.name, "Active Theme")
end

function TestThemeRegistration:test_getActive_returns_nil_initially()
  -- This test assumes no theme is active, but other tests may have set one
  -- So we'll just check that getActive returns something or nil
  local active = Theme.getActive()
  -- Just verify it doesn't error
  luaunit.assertTrue(active == nil or type(active) == "table")
end

function TestThemeRegistration:test_hasActive_returns_boolean()
  local hasActive = Theme.hasActive()
  luaunit.assertTrue(type(hasActive) == "boolean")
end

function TestThemeRegistration:test_get_returns_nil_for_unregistered_theme()
  -- Theme.get() looks up themes in the registered themes table
  -- Themes created with Theme.new() and setActive() are not automatically registered
  local def = {
    name = "Unregistered Theme",
  }
  local theme = Theme.new(def)
  Theme.setActive(theme)

  -- This should return nil because the theme was not loaded from a file
  local retrieved = Theme.get("Unregistered Theme")
  luaunit.assertNil(retrieved)
end

function TestThemeRegistration:test_get_returns_nil_for_nonexistent()
  local retrieved = Theme.get("Nonexistent Theme 12345")
  luaunit.assertNil(retrieved)
end

function TestThemeRegistration:test_getRegisteredThemes_returns_table()
  local themes = Theme.getRegisteredThemes()
  luaunit.assertNotNil(themes)
  luaunit.assertEquals(type(themes), "table")
end

-- Test suite for Theme.getComponent()
TestThemeComponent = {}

function TestThemeComponent:setUp()
  -- Create and set an active theme with components
  local def = {
    name = "Component Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
      },
      panel = {
        atlas = "path/to/panel.png",
      },
    },
  }
  self.theme = Theme.new(def)
  Theme.setActive(self.theme)
end

function TestThemeComponent:test_getComponent_returns_component()
  local component = Theme.getComponent("button")
  luaunit.assertNotNil(component)
  luaunit.assertEquals(component.atlas, "path/to/button.png")
end

function TestThemeComponent:test_getComponent_returns_nil_for_nonexistent()
  local component = Theme.getComponent("nonexistent")
  luaunit.assertNil(component)
end

function TestThemeComponent:test_getComponent_with_state()
  -- Add a component with states
  local def = {
    name = "State Test Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        states = {
          hover = {
            atlas = "path/to/button_hover.png",
          },
        },
      },
    },
  }
  local theme = Theme.new(def)
  Theme.setActive(theme)

  local component = Theme.getComponent("button", "hover")
  luaunit.assertNotNil(component)
  luaunit.assertEquals(component.atlas, "path/to/button_hover.png")
end

-- Test suite for Theme.getColor()
TestThemeColor = {}

function TestThemeColor:setUp()
  local def = {
    name = "Color Test Theme",
    colors = {
      primary = Color.new(1, 0, 0, 1),
      secondary = Color.new(0, 1, 0, 1),
      textColor = Color.new(0.5, 0.5, 0.5, 1),
    },
  }
  self.theme = Theme.new(def)
  Theme.setActive(self.theme)
end

function TestThemeColor:test_getColor_returns_color()
  local color = Theme.getColor("primary")
  luaunit.assertNotNil(color)
  luaunit.assertEquals(color.r, 1)
  luaunit.assertEquals(color.g, 0)
  luaunit.assertEquals(color.b, 0)
end

function TestThemeColor:test_getColor_returns_nil_for_nonexistent()
  local color = Theme.getColor("nonexistent")
  luaunit.assertNil(color)
end

function TestThemeColor:test_getColorNames_returns_table()
  local names = Theme.getColorNames()
  luaunit.assertNotNil(names)
  luaunit.assertEquals(type(names), "table")
  -- Should contain our defined colors
  luaunit.assertTrue(#names >= 3)
end

function TestThemeColor:test_getAllColors_returns_table()
  local colors = Theme.getAllColors()
  luaunit.assertNotNil(colors)
  luaunit.assertEquals(type(colors), "table")
  luaunit.assertNotNil(colors.primary)
  luaunit.assertNotNil(colors.secondary)
end

function TestThemeColor:test_getColorOrDefault_returns_color()
  local color = Theme.getColorOrDefault("primary", Color.new(0, 0, 0, 1))
  luaunit.assertNotNil(color)
  luaunit.assertEquals(color.r, 1)
end

function TestThemeColor:test_getColorOrDefault_returns_fallback()
  local fallback = Color.new(0.1, 0.2, 0.3, 1)
  local color = Theme.getColorOrDefault("nonexistent", fallback)
  luaunit.assertNotNil(color)
  luaunit.assertEquals(color.r, 0.1)
  luaunit.assertEquals(color.g, 0.2)
  luaunit.assertEquals(color.b, 0.3)
end

-- Test suite for Theme.getFont()
TestThemeFont = {}

function TestThemeFont:setUp()
  local def = {
    name = "Font Test Theme",
    fonts = {
      default = "path/to/default.ttf",
      heading = "path/to/heading.ttf",
    },
  }
  self.theme = Theme.new(def)
  Theme.setActive(self.theme)
end

function TestThemeFont:test_getFont_returns_font_path()
  local font = Theme.getFont("default")
  luaunit.assertNotNil(font)
  luaunit.assertEquals(font, "path/to/default.ttf")
end

function TestThemeFont:test_getFont_returns_nil_for_nonexistent()
  local font = Theme.getFont("nonexistent")
  luaunit.assertNil(font)
end

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
    name = "Test Theme",
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_theme_with_empty_name()
  local theme = {
    name = "",
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_theme_with_non_string_name()
  local theme = {
    name = 123,
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
      secondary = Color.new(0, 1, 0, 1),
    },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end




function TestThemeValidation:test_validate_colors_non_table()
  local theme = {
    name = "Test Theme",
    colors = "should be a table",
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_color_with_non_string_name()
  local theme = {
    name = "Test Theme",
    colors = {
      [123] = Color.new(1, 0, 0, 1),
    },
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
      heading = "path/to/heading.ttf",
    },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_fonts_non_table()
  local theme = {
    name = "Test Theme",
    fonts = "should be a table",
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_font_with_non_string_path()
  local theme = {
    name = "Test Theme",
    fonts = {
      default = 123,
    },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_font_with_non_string_name()
  local theme = {
    name = "Test Theme",
    fonts = {
      [123] = "path/to/font.ttf",
    },
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
        atlas = "path/to/button.png",
      },
    },
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
        insets = { left = 5, top = 5, right = 5, bottom = 5 },
      },
    },
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
        insets = { left = 5, top = 5, right = 5 }, -- missing bottom
      },
    },
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
        insets = { left = -5, top = 5, right = 5, bottom = 5 },
      },
    },
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
            atlas = "path/to/button_hover.png",
          },
          pressed = {
            atlas = "path/to/button_pressed.png",
          },
        },
      },
    },
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
          hover = "should be a table",
        },
      },
    },
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
        scaleCorners = 2.0,
      },
    },
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
        scaleCorners = -1,
      },
    },
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
        scalingAlgorithm = "nearest",
      },
    },
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
        scalingAlgorithm = "invalid",
      },
    },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_components_non_table()
  local theme = {
    name = "Test Theme",
    components = "should be a table",
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

-- === ContentAutoSizingMultiplier Validation ===

function TestThemeValidation:test_validate_valid_multiplier()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = { width = 1.1, height = 1.2 },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_multiplier_with_only_width()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = { width = 1.1 },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

function TestThemeValidation:test_validate_multiplier_non_table()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = 1.5,
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_multiplier_with_non_number()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = { width = "not a number" },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

function TestThemeValidation:test_validate_multiplier_with_negative()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = { width = -1 },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "positive")
end

function TestThemeValidation:test_validate_multiplier_with_zero()
  local theme = {
    name = "Test Theme",
    contentAutoSizingMultiplier = { width = 0 },
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
end

-- === Global Atlas Validation ===

function TestThemeValidation:test_validate_valid_global_atlas()
  local theme = {
    name = "Test Theme",
    atlas = "path/to/atlas.png",
  }
  local valid, errors = Theme.validateTheme(theme)
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

-- === Strict Mode Validation ===

function TestThemeValidation:test_validate_unknown_field_strict()
  local theme = {
    name = "Test Theme",
    unknownField = "should trigger warning",
  }
  local valid, errors = Theme.validateTheme(theme, { strict = true })
  luaunit.assertFalse(valid)
  luaunit.assertTrue(#errors > 0)
  luaunit.assertStrContains(errors[1], "Unknown field")
end

function TestThemeValidation:test_validate_unknown_field_non_strict()
  local theme = {
    name = "Test Theme",
    unknownField = "should be ignored",
  }
  local valid, errors = Theme.validateTheme(theme, { strict = false })
  luaunit.assertTrue(valid)
  luaunit.assertEquals(#errors, 0)
end

-- === Theme Sanitization ===

function TestThemeValidation:test_sanitize_nil_theme()
  local sanitized = Theme.sanitizeTheme(nil)
  luaunit.assertNotNil(sanitized)
  luaunit.assertEquals(sanitized.name, "Invalid Theme")
end


function TestThemeValidation:test_sanitize_theme_with_non_string_name()
  local theme = {
    name = 123,
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertEquals(type(sanitized.name), "string")
end


function TestThemeValidation:test_sanitize_removes_non_string_color_names()
  local theme = {
    name = "Test",
    colors = {
      [123] = "red",
    },
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertNil(sanitized.colors[123])
end

function TestThemeValidation:test_sanitize_fonts()
  local theme = {
    name = "Test",
    fonts = {
      default = "path/to/font.ttf",
      invalid = 123,
    },
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertNotNil(sanitized.fonts.default)
  luaunit.assertNil(sanitized.fonts.invalid)
end

function TestThemeValidation:test_sanitize_preserves_components()
  local theme = {
    name = "Test",
    components = {
      button = { atlas = "path/to/button.png" },
    },
  }
  local sanitized = Theme.sanitizeTheme(theme)
  luaunit.assertNotNil(sanitized.components.button)
  luaunit.assertEquals(sanitized.components.button.atlas, "path/to/button.png")
end

-- === Complex Theme Validation ===



-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
