local Color = require("libs.FlexLove").Color

return {
  name = "Metal Theme",
  contentAutoSizingMultiplier = { width = 1.05, height = 1.1 },
  components = {
    framev1 = {
      atlas = "themes/metal/Frame/Frame01a.9.png",
    },
    framev2 = {
      atlas = "themes/metal/Frame/Frame01b.9.png",
    },
    framev3 = {
      atlas = "themes/metal/Frame/Frame02a.9.png",
    },
    framev4 = {
      atlas = "themes/metal/Frame/Frame02b.9.png",
    },
    framev5 = {
      atlas = "themes/metal/Frame/Frame03a.9.png",
    },
    framev6 = {
      atlas = "themes/metal/Frame/Frame03b.9.png",
    },
    buttonv1 = {
      atlas = "themes/metal/Button/Button01a_1.9.png",
      states = {
        hover = {
          atlas = "themes/metal/Button/Button01a_4.9.png",
        },
        pressed = {
          atlas = "themes/metal/Button/Button01a_2.9.png",
        },
        disabled = {
          atlas = "themes/metal/Button/Button01a_4.9.png",
        },
      },
    },
    buttonv2 = {
      atlas = "themes/metal/Button/Button02a_1.9.png",
      states = {
        hover = {
          atlas = "themes/metal/Button/Button02a_4.9.png",
        },
        pressed = {
          atlas = "themes/metal/Button/Button02a_2.9.png",
        },
        disabled = {
          atlas = "themes/metal/Button/Button02a_4.9.png",
        },
      },
    },
  },

  -- Optional: Theme colors
  colors = {
    primary = Color.new(),
    secondary = Color.new(),
    text = Color.new(),
    textDark = Color.new(),
  },

  -- Optional: Theme fonts
  -- Define font families that can be referenced by name
  -- Paths are relative to FlexLove location or absolute
  fonts = {
    default = "themes/space/VT323-Regular.ttf",
  },
}
