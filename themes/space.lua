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
  components = {
    -- Panel component (882x687 with 110px border)
    panel = {
      atlas = "themes/space/panel.png",
      regions = {
        -- 9-slice regions for 882x687 image (110-662-110 split)
        -- Top row
        topLeft = { x = 0, y = 0, w = 110, h = 110 },
        topCenter = { x = 110, y = 0, w = 662, h = 110 },
        topRight = { x = 772, y = 0, w = 110, h = 110 },
        -- Middle row (stretchable)
        middleLeft = { x = 0, y = 110, w = 110, h = 467 },
        middleCenter = { x = 110, y = 110, w = 662, h = 467 },
        middleRight = { x = 772, y = 110, w = 110, h = 467 },
        -- Bottom row
        bottomLeft = { x = 0, y = 577, w = 110, h = 110 },
        bottomCenter = { x = 110, y = 577, w = 662, h = 110 },
        bottomRight = { x = 772, y = 577, w = 110, h = 110 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
    },

    button = {
      atlas = "themes/space/interactive.png",
      regions = {
        topLeft = { x = 0, y = 0, w = 31, h = 31 },
        topCenter = { x = 31, y = 0, w = 127, h = 31 },
        topRight = { x = 158, y = 0, w = 31, h = 31 },
        middleLeft = { x = 0, y = 31, w = 31, h = 127 },
        middleCenter = { x = 31, y = 31, w = 127, h = 127 },
        middleRight = { x = 158, y = 31, w = 31, h = 127 },
        bottomLeft = { x = 0, y = 158, w = 31, h = 31 },
        bottomCenter = { x = 31, y = 158, w = 127, h = 31 },
        bottomRight = { x = 158, y = 158, w = 31, h = 31 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
      states = {
        hover = {
          atlas = "themes/space/interactive-hover.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 31, h = 31 },
            topCenter = { x = 31, y = 0, w = 127, h = 31 },
            topRight = { x = 158, y = 0, w = 31, h = 31 },
            middleLeft = { x = 0, y = 31, w = 31, h = 127 },
            middleCenter = { x = 31, y = 31, w = 127, h = 127 },
            middleRight = { x = 158, y = 31, w = 31, h = 127 },
            bottomLeft = { x = 0, y = 158, w = 31, h = 31 },
            bottomCenter = { x = 31, y = 158, w = 127, h = 31 },
            bottomRight = { x = 158, y = 158, w = 31, h = 31 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        pressed = {
          atlas = "themes/space/interactive-pressed.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 31, h = 31 },
            topCenter = { x = 31, y = 0, w = 127, h = 31 },
            topRight = { x = 158, y = 0, w = 31, h = 31 },
            middleLeft = { x = 0, y = 31, w = 31, h = 127 },
            middleCenter = { x = 31, y = 31, w = 127, h = 127 },
            middleRight = { x = 158, y = 31, w = 31, h = 127 },
            bottomLeft = { x = 0, y = 158, w = 31, h = 31 },
            bottomCenter = { x = 31, y = 158, w = 127, h = 31 },
            bottomRight = { x = 158, y = 158, w = 31, h = 31 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        disabled = {
          atlas = "themes/space/interactive-disabled.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 31, h = 31 },
            topCenter = { x = 31, y = 0, w = 127, h = 31 },
            topRight = { x = 158, y = 0, w = 31, h = 31 },
            middleLeft = { x = 0, y = 31, w = 31, h = 127 },
            middleCenter = { x = 31, y = 31, w = 127, h = 127 },
            middleRight = { x = 158, y = 31, w = 31, h = 127 },
            bottomLeft = { x = 0, y = 158, w = 31, h = 31 },
            bottomCenter = { x = 31, y = 158, w = 127, h = 31 },
            bottomRight = { x = 158, y = 158, w = 31, h = 31 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
      },
    },

    -- Input component with active and disabled states
    input = {
      atlas = "themes/space/interactive.png",
      regions = {
        topLeft = { x = 0, y = 0, w = 31, h = 31 },
        topCenter = { x = 31, y = 0, w = 127, h = 31 },
        topRight = { x = 158, y = 0, w = 31, h = 31 },
        middleLeft = { x = 0, y = 31, w = 31, h = 127 },
        middleCenter = { x = 31, y = 31, w = 127, h = 127 },
        middleRight = { x = 158, y = 31, w = 31, h = 127 },
        bottomLeft = { x = 0, y = 158, w = 31, h = 31 },
        bottomCenter = { x = 31, y = 158, w = 127, h = 31 },
        bottomRight = { x = 158, y = 158, w = 31, h = 31 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
      states = {
        active = {
          atlas = "themes/space/interactive-hover.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 31, h = 31 },
            topCenter = { x = 31, y = 0, w = 127, h = 31 },
            topRight = { x = 158, y = 0, w = 31, h = 31 },
            middleLeft = { x = 0, y = 31, w = 31, h = 127 },
            middleCenter = { x = 31, y = 31, w = 127, h = 127 },
            middleRight = { x = 158, y = 31, w = 31, h = 127 },
            bottomLeft = { x = 0, y = 158, w = 31, h = 31 },
            bottomCenter = { x = 31, y = 158, w = 127, h = 31 },
            bottomRight = { x = 158, y = 158, w = 31, h = 31 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        disabled = {
          atlas = "themes/space/interactive-disabled.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 31, h = 31 },
            topCenter = { x = 31, y = 0, w = 127, h = 31 },
            topRight = { x = 158, y = 0, w = 31, h = 31 },
            middleLeft = { x = 0, y = 31, w = 31, h = 127 },
            middleCenter = { x = 31, y = 31, w = 127, h = 127 },
            middleRight = { x = 158, y = 31, w = 31, h = 127 },
            bottomLeft = { x = 0, y = 158, w = 31, h = 31 },
            bottomCenter = { x = 31, y = 158, w = 127, h = 31 },
            bottomRight = { x = 158, y = 158, w = 31, h = 31 },
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
