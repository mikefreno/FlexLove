-- Space Theme
-- All images are 256x256 with perfectly centered 9-slice regions

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
    -- Panel component
    panel = {
      atlas = "themes/space/panel-compressed.png",
      regions = {
        -- Equal-sized regions for 256x256 image (85-86-85 split)
        -- Top row
        topLeft = { x = 0, y = 0, w = 85, h = 85 },
        topCenter = { x = 85, y = 0, w = 86, h = 85 },
        topRight = { x = 171, y = 0, w = 85, h = 85 },
        -- Middle row (stretchable)
        middleLeft = { x = 0, y = 85, w = 85, h = 86 },
        middleCenter = { x = 85, y = 85, w = 86, h = 86 },
        middleRight = { x = 171, y = 85, w = 85, h = 86 },
        -- Bottom row
        bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
        bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
        bottomRight = { x = 171, y = 171, w = 85, h = 85 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
    },

    -- Button component with states
    button = {
      atlas = "themes/space/interactive-compressed.png",
      regions = {
        topLeft = { x = 0, y = 0, w = 85, h = 85 },
        topCenter = { x = 85, y = 0, w = 86, h = 85 },
        topRight = { x = 171, y = 0, w = 85, h = 85 },
        middleLeft = { x = 0, y = 85, w = 85, h = 86 },
        middleCenter = { x = 85, y = 85, w = 86, h = 86 },
        middleRight = { x = 171, y = 85, w = 85, h = 86 },
        bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
        bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
        bottomRight = { x = 171, y = 171, w = 85, h = 85 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
      states = {
        hover = {
          atlas = "themes/space/interactive-hovered-compressed.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 85, h = 85 },
            topCenter = { x = 85, y = 0, w = 86, h = 85 },
            topRight = { x = 171, y = 0, w = 85, h = 85 },
            middleLeft = { x = 0, y = 85, w = 85, h = 86 },
            middleCenter = { x = 85, y = 85, w = 86, h = 86 },
            middleRight = { x = 171, y = 85, w = 85, h = 86 },
            bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
            bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
            bottomRight = { x = 171, y = 171, w = 85, h = 85 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        pressed = {
          atlas = "themes/space/interactive-pressed-compressed.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 85, h = 85 },
            topCenter = { x = 85, y = 0, w = 86, h = 85 },
            topRight = { x = 171, y = 0, w = 85, h = 85 },
            middleLeft = { x = 0, y = 85, w = 85, h = 86 },
            middleCenter = { x = 85, y = 85, w = 86, h = 86 },
            middleRight = { x = 171, y = 85, w = 85, h = 86 },
            bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
            bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
            bottomRight = { x = 171, y = 171, w = 85, h = 85 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        disabled = {
          atlas = "themes/space/interactive-disabled-compressed.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 85, h = 85 },
            topCenter = { x = 85, y = 0, w = 86, h = 85 },
            topRight = { x = 171, y = 0, w = 85, h = 85 },
            middleLeft = { x = 0, y = 85, w = 85, h = 86 },
            middleCenter = { x = 85, y = 85, w = 86, h = 86 },
            middleRight = { x = 171, y = 85, w = 85, h = 86 },
            bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
            bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
            bottomRight = { x = 171, y = 171, w = 85, h = 85 },
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
      atlas = "themes/space/interactive-compressed.png",
      regions = {
        topLeft = { x = 0, y = 0, w = 85, h = 85 },
        topCenter = { x = 85, y = 0, w = 86, h = 85 },
        topRight = { x = 171, y = 0, w = 85, h = 85 },
        middleLeft = { x = 0, y = 85, w = 85, h = 86 },
        middleCenter = { x = 85, y = 85, w = 86, h = 86 },
        middleRight = { x = 171, y = 85, w = 85, h = 86 },
        bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
        bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
        bottomRight = { x = 171, y = 171, w = 85, h = 85 },
      },
      stretch = {
        horizontal = { "topCenter", "middleCenter", "bottomCenter" },
        vertical = { "middleLeft", "middleCenter", "middleRight" },
      },
      states = {
        active = {
          atlas = "themes/space/interactive-hovered-compressed.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 85, h = 85 },
            topCenter = { x = 85, y = 0, w = 86, h = 85 },
            topRight = { x = 171, y = 0, w = 85, h = 85 },
            middleLeft = { x = 0, y = 85, w = 85, h = 86 },
            middleCenter = { x = 85, y = 85, w = 86, h = 86 },
            middleRight = { x = 171, y = 85, w = 85, h = 86 },
            bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
            bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
            bottomRight = { x = 171, y = 171, w = 85, h = 85 },
          },
          stretch = {
            horizontal = { "topCenter", "middleCenter", "bottomCenter" },
            vertical = { "middleLeft", "middleCenter", "middleRight" },
          },
        },
        disabled = {
          atlas = "themes/space/interactive-disabled-compressed.png",
          regions = {
            topLeft = { x = 0, y = 0, w = 85, h = 85 },
            topCenter = { x = 85, y = 0, w = 86, h = 85 },
            topRight = { x = 171, y = 0, w = 85, h = 85 },
            middleLeft = { x = 0, y = 85, w = 85, h = 86 },
            middleCenter = { x = 85, y = 85, w = 86, h = 86 },
            middleRight = { x = 171, y = 85, w = 85, h = 86 },
            bottomLeft = { x = 0, y = 171, w = 85, h = 85 },
            bottomCenter = { x = 85, y = 171, w = 86, h = 85 },
            bottomRight = { x = 171, y = 171, w = 85, h = 85 },
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
}
