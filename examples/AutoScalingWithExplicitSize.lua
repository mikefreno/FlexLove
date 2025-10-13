-- Example: Auto-scaling with explicit textSize values
-- By default, even explicit pixel sizes will auto-scale with window

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

print("=== Auto-Scaling with Explicit textSize ===\n")

-- Example 1: Default behavior - auto-scales even with explicit pixel size
print("1. Default: textSize=40 auto-scales")
local elem1 = Gui.new({
  text = "Pause Menu",
  textSize = 40,  -- Explicit pixel size
  textColor = Color.new(1, 1, 1),
})
print("   At 800x600: textSize = " .. elem1.textSize)
print("   (Converted to " .. string.format("%.2f", elem1.units.textSize.value) .. "vh internally)")

love.window.setMode(1600, 1200)
Gui.resize()
print("   At 1600x1200: textSize = " .. elem1.textSize)
print("   (Scales proportionally!)\n")

-- Example 2: Disable auto-scaling for truly fixed size
print("2. Fixed: textSize=40 with autoScaleText=false")
Gui.destroy()
love.window.setMode(800, 600)
local elem2 = Gui.new({
  text = "Fixed Size",
  textSize = 40,
  autoScaleText = false,  -- Disable auto-scaling
  textColor = Color.new(1, 1, 1),
})
print("   At 800x600: textSize = " .. elem2.textSize)

love.window.setMode(1600, 1200)
Gui.resize()
print("   At 1600x1200: textSize = " .. elem2.textSize)
print("   (Stays fixed)\n")

-- Example 3: Use viewport units explicitly
print("3. Explicit viewport units: textSize='5vh'")
Gui.destroy()
love.window.setMode(800, 600)
local elem3 = Gui.new({
  text = "Large Title",
  textSize = "5vh",  -- 5% of viewport height
  textColor = Color.new(1, 1, 1),
})
print("   At 800x600: textSize = " .. elem3.textSize .. " (5% of 600)")

love.window.setMode(1600, 1200)
Gui.resize()
print("   At 1600x1200: textSize = " .. elem3.textSize .. " (5% of 1200)\n")

-- Example 4: Your Pause Menu use case
print("4. Pause Menu Example")
Gui.destroy()
love.window.setMode(800, 600)

local pauseMenu = Gui.new({
  x = "25%",
  y = "25%",
  width = "50%",
  height = "50%",
  positioning = "flex",
  flexDirection = "vertical",
  justifyContent = "center",
  alignItems = "center",
  backgroundColor = Color.new(0.1, 0.1, 0.1, 0.9),
})

local title = Gui.new({
  parent = pauseMenu,
  text = "Pause Menu",
  textSize = 40,  -- Auto-scales by default!
  textColor = Color.new(1, 1, 1),
})

local closeButton = Gui.new({
  parent = pauseMenu,
  text = "X",
  textSize = 40,  -- Auto-scales by default!
  padding = { horizontal = 8 },
  textColor = Color.new(1, 1, 1),
})

print("   At 800x600:")
print("   Title textSize: " .. title.textSize)
print("   Button textSize: " .. closeButton.textSize)

love.window.setMode(1600, 1200)
Gui.resize()
print("   At 1600x1200:")
print("   Title textSize: " .. title.textSize .. " (scaled 2x!)")
print("   Button textSize: " .. closeButton.textSize .. " (scaled 2x!)")
print()

print("=== Summary ===")
print("• textSize with pixel values NOW AUTO-SCALES by default")
print("• To disable: set autoScaleText = false")
print("• Pixel values are converted to viewport units (vh) internally")
print("• This makes text responsive without any extra configuration!")
print("• Your Pause Menu will now scale perfectly at any resolution")
