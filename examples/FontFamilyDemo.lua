-- Font Family Demo
-- Demonstrates how to use custom fonts with FlexLove theme system

local FlexLove = require("libs.FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color
local Theme = FlexLove.Theme

-- Initialize FlexLove with base scaling and theme
Gui.init({
  baseScale = { width = 1920, height = 1080 },
  theme = "space",
})

-- Create a simple theme with custom fonts
local customTheme = Theme.new({
  name = "Custom Font Theme",
  
  -- Define font families
  -- Note: These paths are examples - replace with your actual font files
  fonts = {
    -- You can reference fonts by name in your elements
    -- default = "path/to/your/font.ttf",
    -- heading = "path/to/your/heading-font.ttf",
    -- mono = "path/to/your/monospace-font.ttf",
  },
  
  colors = {
    background = Color.new(0.1, 0.1, 0.15, 1),
    text = Color.new(0.9, 0.9, 0.95, 1),
  },
})

-- Set the custom theme as active
-- Theme.setActive(customTheme)

-- Create main container
local container = Gui.new({
  x = 100,
  y = 100,
  width = 1720,
  height = 880,
  backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
  cornerRadius = 10,
  positioning = "flex",
  flexDirection = "vertical",
  padding = { top = 40, horizontal = 40, bottom = 40 },
  gap = 30,
})

-- Title
Gui.new({
  parent = container,
  text = "Font Family Demo",
  textSize = "3xl",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = "center",
  -- fontFamily = "heading", -- Uncomment to use custom heading font from theme
})

-- Description
Gui.new({
  parent = container,
  text = "FlexLove supports custom font families through the theme system",
  textSize = "md",
  textColor = Color.new(0.8, 0.8, 0.9, 1),
  textAlign = "center",
  -- fontFamily = "default", -- Uncomment to use custom default font from theme
})

-- Example 1: Default System Font
local example1 = Gui.new({
  parent = container,
  width = "100%",
  backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
  cornerRadius = 8,
  padding = { top = 20, horizontal = 20, bottom = 20 },
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
})

Gui.new({
  parent = example1,
  text = "1. Default System Font",
  textSize = "lg",
  textColor = Color.new(0.3, 0.7, 1, 1),
})

Gui.new({
  parent = example1,
  text = "This text uses the default system font (no fontFamily specified)",
  textSize = "md",
  textColor = Color.new(0.9, 0.9, 0.95, 1),
})

-- Example 2: Font from Theme
local example2 = Gui.new({
  parent = container,
  width = "100%",
  backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
  cornerRadius = 8,
  padding = { top = 20, horizontal = 20, bottom = 20 },
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
})

Gui.new({
  parent = example2,
  text = "2. Font from Theme",
  textSize = "lg",
  textColor = Color.new(0.3, 0.7, 1, 1),
})

Gui.new({
  parent = example2,
  text = "Use fontFamily='default' to reference fonts defined in your theme",
  textSize = "md",
  textColor = Color.new(0.9, 0.9, 0.95, 1),
  -- fontFamily = "default", -- Uncomment when you have fonts defined in theme
})

-- Example 3: Direct Font Path
local example3 = Gui.new({
  parent = container,
  width = "100%",
  backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
  cornerRadius = 8,
  padding = { top = 20, horizontal = 20, bottom = 20 },
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
})

Gui.new({
  parent = example3,
  text = "3. Direct Font Path",
  textSize = "lg",
  textColor = Color.new(0.3, 0.7, 1, 1),
})

Gui.new({
  parent = example3,
  text = "You can also specify a direct path: fontFamily='path/to/font.ttf'",
  textSize = "md",
  textColor = Color.new(0.9, 0.9, 0.95, 1),
  -- fontFamily = "path/to/your/font.ttf", -- Uncomment with actual font path
})

-- Example 4: Different Sizes with Same Font
local example4 = Gui.new({
  parent = container,
  width = "100%",
  backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
  cornerRadius = 8,
  padding = { top = 20, horizontal = 20, bottom = 20 },
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
})

Gui.new({
  parent = example4,
  text = "4. Multiple Sizes",
  textSize = "lg",
  textColor = Color.new(0.3, 0.7, 1, 1),
})

local sizeContainer = Gui.new({
  parent = example4,
  positioning = "flex",
  flexDirection = "vertical",
  gap = 5,
})

local sizes = { "xs", "sm", "md", "lg", "xl", "xxl" }
for _, size in ipairs(sizes) do
  Gui.new({
    parent = sizeContainer,
    text = "Text size: " .. size,
    textSize = size,
    textColor = Color.new(0.9, 0.9, 0.95, 1),
    -- fontFamily = "default", -- Same font, different sizes
  })
end

-- Instructions
Gui.new({
  parent = container,
  text = "To use custom fonts: 1) Add font files to your project, 2) Define them in theme.fonts, 3) Reference by name in elements",
  textSize = "sm",
  textColor = Color.new(0.6, 0.6, 0.7, 1),
  textAlign = "center",
})

-- LÖVE callbacks
function love.load()
  print("Font Family Demo loaded")
  print("Add your custom font files and update the theme definition to see custom fonts in action")
end

function love.update(dt)
  Gui.update(dt)
end

function love.draw()
  love.graphics.clear(0.05, 0.05, 0.08, 1)
  Gui.draw()
end

function love.resize(w, h)
  Gui.resize()
end
