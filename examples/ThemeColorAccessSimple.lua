-- Simple Theme Color Access Demo
-- Shows how to access theme colors without creating GUI elements

package.path = package.path .. ";./?.lua;../?.lua"

local FlexLove = require("FlexLove")
local Theme = FlexLove.Theme
local Color = FlexLove.Color

-- Initialize minimal love stubs
love = {
  graphics = {
    newFont = function(size) return { getHeight = function() return size end } end,
    newImage = function() return {} end,
    newQuad = function() return {} end,
  },
}

print("=== Theme Color Access - Simple Demo ===\n")

-- Load and activate the space theme
Theme.load("space")
Theme.setActive("space")

print("✓ Theme 'space' loaded and activated\n")

-- ============================================
-- METHOD 1: Basic Color Access (Recommended)
-- ============================================
print("METHOD 1: Theme.getColor(colorName)")
print("------------------------------------")

local primaryColor = Theme.getColor("primary")
local secondaryColor = Theme.getColor("secondary")
local textColor = Theme.getColor("text")
local textDarkColor = Theme.getColor("textDark")

print(string.format("primary   = Color(r=%.2f, g=%.2f, b=%.2f, a=%.2f)", 
  primaryColor.r, primaryColor.g, primaryColor.b, primaryColor.a))
print(string.format("secondary = Color(r=%.2f, g=%.2f, b=%.2f, a=%.2f)", 
  secondaryColor.r, secondaryColor.g, secondaryColor.b, secondaryColor.a))
print(string.format("text      = Color(r=%.2f, g=%.2f, b=%.2f, a=%.2f)", 
  textColor.r, textColor.g, textColor.b, textColor.a))
print(string.format("textDark  = Color(r=%.2f, g=%.2f, b=%.2f, a=%.2f)", 
  textDarkColor.r, textDarkColor.g, textDarkColor.b, textDarkColor.a))

-- ============================================
-- METHOD 2: Get All Color Names
-- ============================================
print("\nMETHOD 2: Theme.getColorNames()")
print("--------------------------------")

local colorNames = Theme.getColorNames()
print("Available colors:")
for i, name in ipairs(colorNames) do
  print(string.format("  %d. %s", i, name))
end

-- ============================================
-- METHOD 3: Get All Colors at Once
-- ============================================
print("\nMETHOD 3: Theme.getAllColors()")
print("-------------------------------")

local allColors = Theme.getAllColors()
print("All colors with values:")
for name, color in pairs(allColors) do
  print(string.format("  %-10s = (%.2f, %.2f, %.2f, %.2f)", 
    name, color.r, color.g, color.b, color.a))
end

-- ============================================
-- METHOD 4: Safe Access with Fallback
-- ============================================
print("\nMETHOD 4: Theme.getColorOrDefault(colorName, fallback)")
print("-------------------------------------------------------")

-- Try to get a color that exists
local existingColor = Theme.getColorOrDefault("primary", Color.new(1, 0, 0, 1))
print(string.format("Existing color 'primary': (%.2f, %.2f, %.2f) ✓", 
  existingColor.r, existingColor.g, existingColor.b))

-- Try to get a color that doesn't exist (will use fallback)
local missingColor = Theme.getColorOrDefault("accent", Color.new(1, 0, 0, 1))
print(string.format("Missing color 'accent' (fallback): (%.2f, %.2f, %.2f) ✓", 
  missingColor.r, missingColor.g, missingColor.b))

-- ============================================
-- PRACTICAL EXAMPLES
-- ============================================
print("\n=== Practical Usage Examples ===\n")

print("Example 1: Using colors in element creation")
print("--------------------------------------------")
print([[
local button = Gui.new({
  width = 200,
  height = 50,
  backgroundColor = Theme.getColor("primary"),
  textColor = Theme.getColor("text"),
  text = "Click Me!"
})
]])

print("\nExample 2: Creating color variations")
print("-------------------------------------")
print([[
local primary = Theme.getColor("primary")

-- Darker version (70% brightness)
local primaryDark = Color.new(
  primary.r * 0.7,
  primary.g * 0.7,
  primary.b * 0.7,
  primary.a
)

-- Lighter version (130% brightness)
local primaryLight = Color.new(
  math.min(1, primary.r * 1.3),
  math.min(1, primary.g * 1.3),
  math.min(1, primary.b * 1.3),
  primary.a
)

-- Semi-transparent version
local primaryTransparent = Color.new(
  primary.r,
  primary.g,
  primary.b,
  0.5  -- 50% opacity
)
]])

print("\nExample 3: Safe color access")
print("-----------------------------")
print([[
-- With fallback to white if color doesn't exist
local bgColor = Theme.getColorOrDefault("background", Color.new(1, 1, 1, 1))

-- With fallback to theme's secondary color
local borderColor = Theme.getColorOrDefault(
  "border", 
  Theme.getColor("secondary")
)
]])

print("\nExample 4: Dynamic color selection")
print("-----------------------------------")
print([[
-- Get all available colors
local colors = Theme.getAllColors()

-- Pick a random color
local colorNames = {}
for name in pairs(colors) do
  table.insert(colorNames, name)
end
local randomColorName = colorNames[math.random(#colorNames)]
local randomColor = colors[randomColorName]
]])

print("\n=== Quick Reference ===\n")
print("Theme.getColor(name)              -- Get a specific color")
print("Theme.getColorOrDefault(n, fb)    -- Get color with fallback")
print("Theme.getAllColors()              -- Get all colors as table")
print("Theme.getColorNames()             -- Get array of color names")
print("Theme.hasActive()                 -- Check if theme is active")
print("Theme.getActive()                 -- Get active theme object")

print("\n=== Available Colors in 'space' Theme ===\n")
for i, name in ipairs(colorNames) do
  local color = allColors[name]
  print(string.format("%-10s  RGB(%.0f, %.0f, %.0f)", 
    name, 
    color.r * 255, 
    color.g * 255, 
    color.b * 255))
end

print("\n=== Demo Complete ===")
