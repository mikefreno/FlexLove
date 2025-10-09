-- Example demonstrating base scaling feature
-- Design your UI at a base resolution and it scales proportionally

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

print("=== Base Scaling Examples ===\n")

-- Example 1: Without base scaling (default behavior)
print("1. Without Base Scaling")
print("   Elements use actual pixel values")
local elem1 = Gui.new({
  x = 100,
  y = 50,
  width = 200,
  height = 100,
  text = "No Scaling",
  textSize = 16,
  autoScaleText = false,
  textColor = Color.new(1, 1, 1),
})
print("   At 800x600:")
print("   x=" .. elem1.x .. ", y=" .. elem1.y .. ", width=" .. elem1.width .. ", height=" .. elem1.height .. ", textSize=" .. elem1.textSize)
love.window.setMode(1600, 1200)
elem1:resize(1600, 1200)
print("   After resize to 1600x1200:")
print("   x=" .. elem1.x .. ", y=" .. elem1.y .. ", width=" .. elem1.width .. ", height=" .. elem1.height .. ", textSize=" .. elem1.textSize)
print("   (No scaling applied)\n")

-- Example 2: With base scaling
print("2. With Base Scaling (baseScale = {width=800, height=600})")
print("   Design at 800x600, scales to any resolution")
love.window.setMode(800, 600)
Gui.destroy()
Gui.init({
  baseScale = { width = 800, height = 600 }
})

local scaleX, scaleY = Gui.getScaleFactors()
print("   Initial scale factors: x=" .. scaleX .. ", y=" .. scaleY)

local elem2 = Gui.new({
  x = 100,      -- Designed for 800x600
  y = 50,
  width = 200,
  height = 100,
  text = "Scaled UI",
  textSize = 16,
  autoScaleText = false,
  textColor = Color.new(1, 1, 1),
})
print("   At 800x600 (base resolution):")
print("   x=" .. elem2.x .. ", y=" .. elem2.y .. ", width=" .. elem2.width .. ", height=" .. elem2.height .. ", textSize=" .. elem2.textSize)

love.window.setMode(1600, 1200)
elem2:resize(1600, 1200)
scaleX, scaleY = Gui.getScaleFactors()
print("   After resize to 1600x1200:")
print("   Scale factors: x=" .. scaleX .. ", y=" .. scaleY)
print("   x=" .. elem2.x .. ", y=" .. elem2.y .. ", width=" .. elem2.width .. ", height=" .. elem2.height .. ", textSize=" .. elem2.textSize)
print("   (Everything scaled 2x!)\n")

-- Example 3: Padding and margins are NOT scaled
print("3. Padding/Margins NOT Scaled")
love.window.setMode(800, 600)
Gui.destroy()
Gui.init({
  baseScale = { width = 800, height = 600 }
})

local elem3 = Gui.new({
  x = 100,
  y = 50,
  width = 200,
  height = 100,
  padding = { horizontal = 10, vertical = 5 },
  text = "Padding Test",
  autoScaleText = false,
  textColor = Color.new(1, 1, 1),
})
print("   At 800x600:")
print("   width=" .. elem3.width .. ", padding.left=" .. elem3.padding.left .. ", padding.top=" .. elem3.padding.top)

love.window.setMode(1600, 1200)
elem3:resize(1600, 1200)
print("   After resize to 1600x1200:")
print("   width=" .. elem3.width .. " (scaled 2x), padding.left=" .. elem3.padding.left .. ", padding.top=" .. elem3.padding.top .. " (NOT scaled)")
print()

-- Example 4: Percentage units still work
print("4. Percentage Units with Base Scaling")
love.window.setMode(800, 600)
Gui.destroy()
Gui.init({
  baseScale = { width = 800, height = 600 }
})

local elem4 = Gui.new({
  x = "10%",     -- Percentage of viewport
  y = "10%",
  width = "50%",
  height = "20%",
  text = "Percentage",
  autoScaleText = false,
  textColor = Color.new(1, 1, 1),
})
print("   At 800x600:")
print("   x=" .. elem4.x .. ", y=" .. elem4.y .. ", width=" .. elem4.width .. ", height=" .. elem4.height)

love.window.setMode(1600, 1200)
elem4:resize(1600, 1200)
print("   After resize to 1600x1200:")
print("   x=" .. elem4.x .. ", y=" .. elem4.y .. ", width=" .. elem4.width .. ", height=" .. elem4.height)
print("   (Percentage units scale with viewport, not base scale)\n")

-- Example 5: Designing for 1920x1080 and scaling down
print("5. Design for 1920x1080, Scale to 800x600")
love.window.setMode(800, 600)
Gui.destroy()
Gui.init({
  baseScale = { width = 1920, height = 1080 }
})

scaleX, scaleY = Gui.getScaleFactors()
print("   Scale factors at 800x600: x=" .. string.format("%.3f", scaleX) .. ", y=" .. string.format("%.3f", scaleY))

local elem5 = Gui.new({
  x = 960,      -- Center of 1920x1080
  y = 540,
  width = 400,
  height = 200,
  text = "HD Design",
  textSize = 24,
  autoScaleText = false,
  textColor = Color.new(1, 1, 1),
})
print("   Designed for 1920x1080 (x=960, y=540, width=400, textSize=24)")
print("   At 800x600:")
print("   x=" .. string.format("%.1f", elem5.x) .. ", y=" .. string.format("%.1f", elem5.y) .. ", width=" .. string.format("%.1f", elem5.width) .. ", textSize=" .. string.format("%.1f", elem5.textSize))
print("   (Scaled down proportionally)\n")

print("=== Summary ===")
print("• Call Gui.init({baseScale = {width=W, height=H}}) in love.load()")
print("• Design your UI at the base resolution")
print("• All pixel values (x, y, width, height, textSize) scale proportionally")
print("• Padding and margins do NOT scale (stay at designed pixel values)")
print("• Percentage/viewport units work independently of base scaling")
print("• Perfect for responsive UIs that maintain proportions")
