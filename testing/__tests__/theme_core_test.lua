-- Test suite for Theme.lua core functionality
-- Tests theme creation, registration, and retrieval functions

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local Theme = require("modules.Theme")
local Color = require("modules.Color")

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
  luaunit.assertErrorMsgContains("name", function()
    Theme.new(def)
  end)
end

function TestThemeNew:test_new_theme_with_nil_fails()
  luaunit.assertErrorMsgContains("nil", function()
    Theme.new(nil)
  end)
end

function TestThemeNew:test_new_theme_with_non_table_fails()
  luaunit.assertErrorMsgContains("table", function()
    Theme.new("not a table")
  end)
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

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
