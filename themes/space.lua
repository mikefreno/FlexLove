-- Space Theme
-- Panel is 882x687 with 110px border
-- All other components are 189x189 with 31px/127px regions

-- Define Color inline to avoid circular dependency
local Color = {}
Color.__index = Color

function Color.new(r, g, b, a)
  local self = setmetatable({}, Color)
  self.r = r or 0
  self.g = g or 0
  self.b = b or 0
  self.a = a or 1
  return self
end

return {
  name = "Space Theme",
  contentAutoSizingMultiplier = { height = 1.1, width = 1.05 },
  components = {
    card = {
      atlas = "themes/space/card.png",
      regions = {
        topLeft = { x = 0, y = 0, width = 100, height = 100 },
        topCenter = { x = 100, y = 0, width = 205, height = 100 },
        topRight = { x = 305, y = 0, width = 100, height = 100 },
        middleLeft = { x = 0, y = 100, width = 100, height = 178 },
        middleCenter = { x = 100, y = 100, width = 205, height = 178 },
        middleRight = { x = 305, y = 100, width = 100, height = 178 },
        bottomLeft = { x = 0, y = 278, width = 100, height = 100 },
        bottomCenter = { x = 100, y = 278, width = 205, height = 100 },
        bottomRight = { x = 305, y = 278, width = 100, height = 100 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
    },
    cardv2 = {
      atlas = "themes/space/card-v2.png",
      regions = {
        topLeft = { x = 0, y = 0, width = 100, height = 100 },
        topCenter = { x = 100, y = 0, width = 205, height = 100 },
        topRight = { x = 305, y = 0, width = 100, height = 100 },
        middleLeft = { x = 0, y = 100, width = 100, height = 178 },
        middleCenter = { x = 100, y = 100, width = 205, height = 178 },
        middleRight = { x = 305, y = 100, width = 100, height = 178 },
        bottomLeft = { x = 0, y = 278, width = 100, height = 100 },
        bottomCenter = { x = 100, y = 278, width = 205, height = 100 },
        bottomRight = { x = 305, y = 278, width = 100, height = 100 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
    },
    panel = {
      atlas = "themes/space/panel.png",
      regions = {
        topLeft = { x = 0, y = 0, width = 38, height = 30 },
        topCenter = { x = 38, y = 0, width = 53, height = 30 },
        topRight = { x = 91, y = 0, width = 22, height = 30 },
        middleLeft = { x = 0, y = 30, width = 38, height = 5 },
        middleCenter = { x = 38, y = 30, width = 53, height = 5 },
        middleRight = { x = 91, y = 30, width = 22, height = 5 },
        bottomLeft = { x = 0, y = 35, width = 38, height = 30 },
        bottomCenter = { x = 38, y = 35, width = 53, height = 30 },
        bottomRight = { x = 91, y = 35, width = 22, height = 30 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
    },
    panelred = {
      atlas = "themes/space/panel-red.png",
      regions = {
        topLeft = { x = 0, y = 0, width = 38, height = 30 },
        topCenter = { x = 38, y = 0, width = 53, height = 30 },
        topRight = { x = 91, y = 0, width = 22, height = 30 },
        middleLeft = { x = 0, y = 30, width = 38, height = 5 },
        middleCenter = { x = 38, y = 30, width = 53, height = 5 },
        middleRight = { x = 91, y = 30, width = 22, height = 5 },
        bottomLeft = { x = 0, y = 35, width = 38, height = 30 },
        bottomCenter = { x = 38, y = 35, width = 53, height = 30 },
        bottomRight = { x = 91, y = 35, width = 22, height = 30 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
    },
    panelgreen = {
      atlas = "themes/space/panel-green.png",
      regions = {
        topLeft = { x = 0, y = 0, width = 38, height = 30 },
        topCenter = { x = 38, y = 0, width = 53, height = 30 },
        topRight = { x = 91, y = 0, width = 22, height = 30 },
        middleLeft = { x = 0, y = 30, width = 38, height = 5 },
        middleCenter = { x = 38, y = 30, width = 53, height = 5 },
        middleRight = { x = 91, y = 30, width = 22, height = 5 },
        bottomLeft = { x = 0, y = 35, width = 38, height = 30 },
        bottomCenter = { x = 38, y = 35, width = 53, height = 30 },
        bottomRight = { x = 91, y = 35, width = 22, height = 30 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
    },
    button = {
      atlas = "themes/space/button.png",
      regions = {
        topLeft = { x = 0, y = 0, width = 14, height = 14 },
        topCenter = { x = 14, y = 0, width = 86, height = 14 },
        topRight = { x = 100, y = 0, width = 14, height = 14 },
        middleLeft = { x = 0, y = 14, width = 14, height = 10 },
        middleCenter = { x = 14, y = 14, width = 86, height = 10 },
        middleRight = { x = 100, y = 14, width = 14, height = 10 },
        bottomLeft = { x = 0, y = 24, width = 14, height = 14 },
        bottomCenter = { x = 14, y = 24, width = 86, height = 14 },
        bottomRight = { x = 100, y = 24, width = 14, height = 14 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
      states = {
        hover = {
          atlas = "themes/space/button-hover.png",
          regions = {
            topLeft = { x = 0, y = 0, width = 14, height = 14 },
            topCenter = { x = 14, y = 0, width = 86, height = 14 },
            topRight = { x = 100, y = 0, width = 14, height = 14 },
            middleLeft = { x = 0, y = 14, width = 14, height = 10 },
            middleCenter = { x = 14, y = 14, width = 86, height = 10 },
            middleRight = { x = 100, y = 14, width = 14, height = 10 },
            bottomLeft = { x = 0, y = 24, width = 14, height = 14 },
            bottomCenter = { x = 14, y = 24, width = 86, height = 14 },
            bottomRight = { x = 100, y = 24, width = 14, height = 14 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        pressed = {
          atlas = "themes/space/button-pressed.png",
          regions = {
            topLeft = { x = 0, y = 0, width = 14, height = 14 },
            topCenter = { x = 14, y = 0, width = 86, height = 14 },
            topRight = { x = 100, y = 0, width = 14, height = 14 },
            middleLeft = { x = 0, y = 14, width = 14, height = 10 },
            middleCenter = { x = 14, y = 14, width = 86, height = 10 },
            middleRight = { x = 100, y = 14, width = 14, height = 10 },
            bottomLeft = { x = 0, y = 24, width = 14, height = 14 },
            bottomCenter = { x = 14, y = 24, width = 86, height = 14 },
            bottomRight = { x = 100, y = 24, width = 14, height = 14 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        disabled = {
          atlas = "themes/space/button-disabled.png",
          regions = {
            topLeft = { x = 0, y = 0, width = 14, height = 14 },
            topCenter = { x = 14, y = 0, width = 86, height = 14 },
            topRight = { x = 100, y = 0, width = 14, height = 14 },
            middleLeft = { x = 0, y = 14, width = 14, height = 10 },
            middleCenter = { x = 14, y = 14, width = 86, height = 10 },
            middleRight = { x = 100, y = 14, width = 14, height = 10 },
            bottomLeft = { x = 0, y = 24, width = 14, height = 14 },
            bottomCenter = { x = 14, y = 24, width = 86, height = 14 },
            bottomRight = { x = 100, y = 24, width = 14, height = 14 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
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
