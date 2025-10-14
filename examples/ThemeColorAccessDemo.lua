-- Theme Color Access Demo
-- Demonstrates various ways to access and use theme colors

package.path = package.path .. ";./?.lua;../?.lua"

local FlexLove = require("FlexLove")
local Theme = FlexLove.Theme
local Gui = FlexLove.Gui
local Color = FlexLove.Color

-- Initialize love stubs for testing
love = {
  graphics = {
    newFont = function(size) return { getHeight = function() return size end } end,
    getFont = function() return { getHeight = function() return 12 end } end,
    getWidth = function() return 1920 end,
    getHeight = function() return 1080 end,
    newImage = function() return {} end,
    newQuad = function() return {} end,
  },
}

print("=== Theme Color Access Demo ===\n")

-- Load and activate the space theme
Theme.load("space")
Theme.setActive("space")

print("1. Basic Color Access")
print("---------------------")

-- Method 1: Using Theme.getColor() (Recommended)
local primaryColor = Theme.getColor("primary")
local secondaryColor = Theme.getColor("secondary")
local textColor = Theme.getColor("text")
local textDarkColor = Theme.getColor("textDark")

print(string.format("Primary: r=%.2f, g=%.2f, b=%.2f", primaryColor.r, primaryColor.g, primaryColor.b))
print(string.format("Secondary: r=%.2f, g=%.2f, b=%.2f", secondaryColor.r, secondaryColor.g, secondaryColor.b))
print(string.format("Text: r=%.2f, g=%.2f, b=%.2f", textColor.r, textColor.g, textColor.b))
print(string.format("Text Dark: r=%.2f, g=%.2f, b=%.2f", textDarkColor.r, textDarkColor.g, textDarkColor.b))

print("\n2. Get All Available Colors")
print("----------------------------")

-- Method 2: Get all color names
local colorNames = Theme.getColorNames()
if colorNames then
  print("Available colors in theme:")
  for _, name in ipairs(colorNames) do
    print("  - " .. name)
  end
end

print("\n3. Get All Colors at Once")
print("-------------------------")

-- Method 3: Get all colors as a table
local allColors = Theme.getAllColors()
if allColors then
  print("All colors:")
  for name, color in pairs(allColors) do
    print(string.format("  %s: r=%.2f, g=%.2f, b=%.2f, a=%.2f", name, color.r, color.g, color.b, color.a))
  end
end

print("\n4. Safe Color Access with Fallback")
print("-----------------------------------")

-- Method 4: Get color with fallback
local accentColor = Theme.getColorOrDefault("accent", Color.new(1, 0, 0, 1)) -- Falls back to red
local primaryColor2 = Theme.getColorOrDefault("primary", Color.new(1, 0, 0, 1)) -- Uses theme color

print(string.format("Accent (fallback): r=%.2f, g=%.2f, b=%.2f", accentColor.r, accentColor.g, accentColor.b))
print(string.format("Primary (theme): r=%.2f, g=%.2f, b=%.2f", primaryColor2.r, primaryColor2.g, primaryColor2.b))

print("\n5. Using Colors in GUI Elements")
print("--------------------------------")

-- Create a container with theme colors
local container = Gui.new({
  width = 400,
  height = 300,
  backgroundColor = Theme.getColor("secondary"),
  positioning = FlexLove.enums.Positioning.FLEX,
  flexDirection = FlexLove.enums.FlexDirection.VERTICAL,
  gap = 10,
  padding = { top = 20, right = 20, bottom = 20, left = 20 },
})

-- Create a button with primary color
local button = Gui.new({
  parent = container,
  width = 360,
  height = 50,
  backgroundColor = Theme.getColor("primary"),
  textColor = Theme.getColor("text"),
  text = "Click Me!",
  textSize = 18,
})

-- Create a text label with dark text
local label = Gui.new({
  parent = container,
  width = 360,
  height = 30,
  backgroundColor = Theme.getColorOrDefault("background", Color.new(0.2, 0.2, 0.2, 1)),
  textColor = Theme.getColor("textDark"),
  text = "This is a label with dark text",
  textSize = 14,
})

print("Created GUI elements with theme colors:")
print(string.format("  Container: %d children", #container.children))
print(string.format("  Button background: r=%.2f, g=%.2f, b=%.2f", button.backgroundColor.r, button.backgroundColor.g, button.backgroundColor.b))
print(string.format("  Label text color: r=%.2f, g=%.2f, b=%.2f", label.textColor.r, label.textColor.g, label.textColor.b))

print("\n6. Creating Color Variations")
print("-----------------------------")

-- Create variations of theme colors
local primaryDark = Color.new(
  primaryColor.r * 0.7,
  primaryColor.g * 0.7,
  primaryColor.b * 0.7,
  primaryColor.a
)

local primaryLight = Color.new(
  math.min(1, primaryColor.r * 1.3),
  math.min(1, primaryColor.g * 1.3),
  math.min(1, primaryColor.b * 1.3),
  primaryColor.a
)

local primaryTransparent = Color.new(
  primaryColor.r,
  primaryColor.g,
  primaryColor.b,
  0.5
)

print(string.format("Primary (original): r=%.2f, g=%.2f, b=%.2f, a=%.2f", primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a))
print(string.format("Primary (dark):     r=%.2f, g=%.2f, b=%.2f, a=%.2f", primaryDark.r, primaryDark.g, primaryDark.b, primaryDark.a))
print(string.format("Primary (light):    r=%.2f, g=%.2f, b=%.2f, a=%.2f", primaryLight.r, primaryLight.g, primaryLight.b, primaryLight.a))
print(string.format("Primary (50%% alpha): r=%.2f, g=%.2f, b=%.2f, a=%.2f", primaryTransparent.r, primaryTransparent.g, primaryTransparent.b, primaryTransparent.a))

print("\n7. Quick Reference")
print("------------------")
print([[
// Basic usage:
local color = Theme.getColor("primary")

// With fallback:
local color = Theme.getColorOrDefault("accent", Color.new(1, 0, 0, 1))

// Get all colors:
local colors = Theme.getAllColors()

// Get color names:
local names = Theme.getColorNames()

// Use in elements:
local button = Gui.new({
  backgroundColor = Theme.getColor("primary"),
  textColor = Theme.getColor("text"),
})
]])

print("\n=== Demo Complete ===")
