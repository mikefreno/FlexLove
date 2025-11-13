--[[
  FlexLove Example 03: Theming System
  
  This example demonstrates the theming system in FlexLove:
  - Loading and applying themes
  - Theme components (button, panel, card)
  - Theme states (normal, hover, pressed, disabled, active)
  - Theme colors and fonts
  
  Run with: love /path/to/libs/examples/03_theming_system.lua
]]

local Lv = love

local FlexLove = require("../FlexLove")
local Color = FlexLove.Color
local enums = FlexLove.enums

function Lv.load()
  FlexLove.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Load the space theme
  FlexLove.loadTheme("space", "../themes/space")
  
  -- Title
  FlexLove.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 03: Theming System",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: Theme Components
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "10vh",
    width = "96vw",
    height = "3vh",
    text = "Theme Components - Space Theme",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Card component
  FlexLove.new({
    x = "2vw",
    y = "14vh",
    width = "30vw",
    height = "20vh",
    theme = "space",
    themeComponent = "card",
    text = "Card Component",
    textSize = "2.5vh",
    textColor = Color.new(0.8, 0.9, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Panel component
  FlexLove.new({
    x = "34vw",
    y = "14vh",
    width = "30vw",
    height = "20vh",
    theme = "space",
    themeComponent = "panel",
    text = "Panel Component",
    textSize = "2.5vh",
    textColor = Color.new(0.8, 0.9, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- Panel red component
  FlexLove.new({
    x = "66vw",
    y = "14vh",
    width = "32vw",
    height = "20vh",
    theme = "space",
    themeComponent = "panelred",
    text = "Panel Red Component",
    textSize = "2.5vh",
    textColor = Color.new(1, 0.8, 0.8, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 2: Button States
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "36vh",
    width = "96vw",
    height = "3vh",
    text = "Button States - Hover and Click to See State Changes",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Normal button (hover to see hover state, click to see pressed state)
  FlexLove.new({
    x = "2vw",
    y = "40vh",
    width = "22vw",
    height = "8vh",
    theme = "space",
    themeComponent = "button",
    text = "Normal Button",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    onEvent = function(element, event)
      if event.type == "click" then
        print("Normal button clicked!")
      end
    end,
  })
  
  -- Active button (simulating active state)
  local activeButton = FlexLove.new({
    x = "26vw",
    y = "40vh",
    width = "22vw",
    height = "8vh",
    theme = "space",
    themeComponent = "button",
    text = "Active Button",
    textSize = "2vh",
    textColor = Color.new(0.3, 1, 0.3, 1),
    textAlign = enums.TextAlign.CENTER,
    active = true,
    onEvent = function(element, event)
      if event.type == "click" then
        element.active = not element.active
        print("Active button toggled:", element.active)
      end
    end,
  })
  
  -- Disabled button
  FlexLove.new({
    x = "50vw",
    y = "40vh",
    width = "22vw",
    height = "8vh",
    theme = "space",
    themeComponent = "button",
    text = "Disabled Button",
    textSize = "2vh",
    textColor = Color.new(0.5, 0.5, 0.5, 1),
    textAlign = enums.TextAlign.CENTER,
    disabled = true,
    onEvent = function(element, event)
      -- This won't be called because button is disabled
      print("This shouldn't print!")
    end,
  })
  
  -- Button with callback feedback
  local clickCount = 0
  local counterButton = FlexLove.new({
    x = "74vw",
    y = "40vh",
    width = "24vw",
    height = "8vh",
    theme = "space",
    themeComponent = "button",
    text = "Click Me! (0)",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    onEvent = function(element, event)
      if event.type == "click" then
        clickCount = clickCount + 1
        element.text = "Click Me! (" .. clickCount .. ")"
      end
    end,
  })
  
  -- ========================================
  -- Section 3: Theme Colors and Fonts
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "50vh",
    width = "96vw",
    height = "3vh",
    text = "Theme Colors and Fonts",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Container showing theme colors
  local colorContainer = FlexLove.new({
    x = "2vw",
    y = "54vh",
    width = "96vw",
    height = "20vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.CENTER,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })
  
  -- Primary color swatch
  FlexLove.new({
    parent = colorContainer,
    width = "20vw",
    height = "15vh",
    backgroundColor = Color.new(0.08, 0.75, 0.95, 1), -- Theme primary color
    text = "Primary Color",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  -- Secondary color swatch
  FlexLove.new({
    parent = colorContainer,
    width = "20vw",
    height = "15vh",
    backgroundColor = Color.new(0.15, 0.20, 0.25, 1), -- Theme secondary color
    text = "Secondary Color",
    textSize = "2vh",
    textColor = Color.new(0.8, 0.9, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  -- Text color swatch
  FlexLove.new({
    parent = colorContainer,
    width = "20vw",
    height = "15vh",
    backgroundColor = Color.new(0.2, 0.2, 0.25, 1),
    text = "Text Color",
    textSize = "2vh",
    textColor = Color.new(0.80, 0.90, 1.00, 1), -- Theme text color
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  -- Text dark color swatch
  FlexLove.new({
    parent = colorContainer,
    width = "20vw",
    height = "15vh",
    backgroundColor = Color.new(0.25, 0.25, 0.3, 1),
    text = "Text Dark Color",
    textSize = "2vh",
    textColor = Color.new(0.35, 0.40, 0.45, 1), -- Theme textDark color
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
  })
  
  -- ========================================
  -- Section 4: Font Family from Theme
  -- ========================================
  
  FlexLove.new({
    x = "2vw",
    y = "76vh",
    width = "96vw",
    height = "18vh",
    theme = "space",
    themeComponent = "card",
    text = "This text uses the theme's default font (VT323)",
    textSize = "3vh",
    textColor = Color.new(0.8, 0.9, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    fontFamily = "default", -- References theme font
  })
end

function Lv.update(dt)
  FlexLove.update(dt)
end

function Lv.draw()
  Lv.graphics.clear(0.05, 0.05, 0.08, 1)
  FlexLove.draw()
end

function Lv.resize(w, h)
  FlexLove.resize(w, h)
end
