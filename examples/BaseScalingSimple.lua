-- Simple example demonstrating base scaling

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

print("=== Base Scaling Demo ===\n")

-- Initialize with base scale (call this in love.load())
Gui.init({
  baseScale = { width = 800, height = 600 }
})

print("Designing UI for 800x600 base resolution\n")

-- Create UI elements using base resolution coordinates
local button = Gui.new({
  x = 100,
  y = 50,
  width = 200,
  height = 60,
  text = "Click Me!",
  textSize = 20,
  autoScaleText = false,
  padding = { horizontal = 16, vertical = 8 },
  textAlign = "center",
  border = { top = true, right = true, bottom = true, left = true },
  borderColor = Color.new(1, 1, 1),
  textColor = Color.new(1, 1, 1),
})

print("At 800x600 (base resolution):")
print(string.format("  Button: x=%d, y=%d, width=%d, height=%d, textSize=%d", 
  button.x, button.y, button.width, button.height, button.textSize))
print(string.format("  Padding: left=%d, top=%d (NOT scaled)", 
  button.padding.left, button.padding.top))

-- Simulate window resize to 1600x1200 (2x scale)
print("\nResizing window to 1600x1200...")
love.window.setMode(1600, 1200)
Gui.resize()  -- This updates all elements

local sx, sy = Gui.getScaleFactors()
print(string.format("Scale factors: x=%.1f, y=%.1f", sx, sy))
print(string.format("  Button: x=%d, y=%d, width=%d, height=%d, textSize=%d", 
  button.x, button.y, button.width, button.height, button.textSize))
print(string.format("  Padding: left=%d, top=%d (NOT scaled)", 
  button.padding.left, button.padding.top))

-- Simulate window resize to 400x300 (0.5x scale)
print("\nResizing window to 400x300...")
love.window.setMode(400, 300)
Gui.resize()

sx, sy = Gui.getScaleFactors()
print(string.format("Scale factors: x=%.1f, y=%.1f", sx, sy))
print(string.format("  Button: x=%d, y=%d, width=%d, height=%d, textSize=%d", 
  button.x, button.y, button.width, button.height, button.textSize))
print(string.format("  Padding: left=%d, top=%d (NOT scaled)", 
  button.padding.left, button.padding.top))

print("\n=== Usage ===")
print("In your main.lua:")
print([[
function love.load()
  local FlexLove = require("game.libs.FlexLove")
  local Gui = FlexLove.GUI
  
  -- Initialize with your design resolution
  Gui.init({ baseScale = { width = 800, height = 600 } })
  
  -- Create UI using base resolution coordinates
  -- Everything will scale automatically!
end

function love.resize(w, h)
  Gui.resize()  -- Update all elements for new window size
end
]])
