-- The pngs are intentionally not being included, but this can still be used as a reference for how to set up a theme.
local Color = require("libs.FlexLove").Color

return {
  name = "Space Theme",
  contentAutoSizingMultiplier = { width = 1.05, height = 1.1 },
  components = {
    card = {
      atlas = "themes/space/card.png",
      insets = { left = 66, top = 66, right = 66, bottom = 66 },
    },
    cardv2 = {
      atlas = "themes/space/card-v2.png",
      insets = { left = 66, top = 66, right = 66, bottom = 66 },
    },
    cardv3 = {
      atlas = "themes/space/card-v3.png",
      insets = { left = 286, top = 100, right = 286, bottom = 100 },
    },
    panel = {
      atlas = "themes/space/panel.png",
      insets = { left = 38, top = 30, right = 22, bottom = 30 },
    },
    panelred = {
      atlas = "themes/space/panel-red.png",
      insets = { left = 38, top = 30, right = 22, bottom = 30 },
    },
    panelgreen = {
      atlas = "themes/space/panel-green.png",
      insets = { left = 38, top = 30, right = 22, bottom = 30 },
    },
    button = {
      atlas = "themes/space/button.png",
      insets = { left = 14, top = 14, right = 14, bottom = 14 },
      states = {
        hover = {
          atlas = "themes/space/button-hover.png",
          insets = { left = 14, top = 14, right = 14, bottom = 14 },
        },
        pressed = {
          atlas = "themes/space/button-pressed.png",
          insets = { left = 14, top = 14, right = 14, bottom = 14 },
        },
        disabled = {
          atlas = "themes/space/button-disabled.png",
          insets = { left = 14, top = 14, right = 14, bottom = 14 },
        },
      },
    },
  },

  -- Optional: Theme colors
  colors = {
    primary = Color.new(0.08, 0.75, 0.95), -- bright cyan-blue glow for accents and highlights
    secondary = Color.new(0.15, 0.20, 0.25), -- deep steel-gray background for panels
    text = Color.new(0.80, 0.90, 1.00), -- soft cool-white for general text
    textDark = Color.new(0.35, 0.40, 0.45), -- dimmed gray-blue for secondary text
  },

  -- Optional: Theme fonts
  -- Define font families that can be referenced by name
  -- Paths are relative to FlexLove location or absolute
  fonts = {
    default = "themes/space/VT323-Regular.ttf",
  },
}
