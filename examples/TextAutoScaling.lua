-- Example demonstrating text auto-scaling feature
-- Text automatically scales proportionally with window size by default

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

print("=== Text Auto-Scaling Examples ===\n")

-- Example 1: Default auto-scaling (enabled by default)
print("1. Default Auto-Scaling (no textSize specified)")
print("   Text will scale proportionally with window size")
local button1 = Gui.new({
  x = 10,
  y = 10,
  padding = { horizontal = 16, vertical = 8 },
  text = "Auto-Scaled Button",
  textAlign = "center",
  border = { top = true, right = true, bottom = true, left = true },
  borderColor = Color.new(1, 1, 1),
  textColor = Color.new(1, 1, 1),
})
print("   Initial size (800x600): textSize = " .. button1.textSize .. "px")
button1:resize(1600, 1200)
print("   After resize (1600x1200): textSize = " .. button1.textSize .. "px")
print("   Scaling factor: " .. (button1.textSize / 9.0) .. "x\n")

-- Example 2: Disable auto-scaling for fixed text size
print("2. Auto-Scaling Disabled (autoScaleText = false)")
print("   Text remains fixed at 12px regardless of window size")
Gui.destroy()
local button2 = Gui.new({
  x = 10,
  y = 60,
  padding = { horizontal = 16, vertical = 8 },
  text = "Fixed Size Button",
  textAlign = "center",
  autoScaleText = false,
  border = { top = true, right = true, bottom = true, left = true },
  borderColor = Color.new(1, 1, 1),
  textColor = Color.new(1, 1, 1),
})
print("   Initial size (800x600): textSize = " .. button2.textSize .. "px")
button2:resize(1600, 1200)
print("   After resize (1600x1200): textSize = " .. button2.textSize .. "px")
print("   No scaling applied\n")

-- Example 3: Custom auto-scaling with viewport units
print("3. Custom Auto-Scaling (textSize = '2vh')")
print("   Text scales at 2% of viewport height")
Gui.destroy()
local title = Gui.new({
  x = 10,
  y = 110,
  text = "Large Title",
  textSize = "2vh",
  textColor = Color.new(1, 1, 1),
})
print("   Initial size (800x600): textSize = " .. title.textSize .. "px")
title:resize(1600, 1200)
print("   After resize (1600x1200): textSize = " .. title.textSize .. "px")
print("   Scaling factor: " .. (title.textSize / 12.0) .. "x\n")

-- Example 4: Fixed pixel size (still auto-scales if using viewport units)
print("4. Fixed Pixel Size (textSize = 20)")
print("   Explicit pixel values don't scale")
Gui.destroy()
local button3 = Gui.new({
  x = 10,
  y = 160,
  padding = { horizontal = 16, vertical = 8 },
  text = "20px Button",
  textSize = 20,
  textAlign = "center",
  border = { top = true, right = true, bottom = true, left = true },
  borderColor = Color.new(1, 1, 1),
  textColor = Color.new(1, 1, 1),
})
print("   Initial size (800x600): textSize = " .. button3.textSize .. "px")
button3:resize(1600, 1200)
print("   After resize (1600x1200): textSize = " .. button3.textSize .. "px")
print("   Fixed at 20px\n")

-- Example 5: Element-relative scaling
print("5. Element-Relative Scaling (textSize = '10ew')")
print("   Text scales at 10% of element width")
Gui.destroy()
local box = Gui.new({
  x = 10,
  y = 210,
  width = 200,
  height = 100,
  text = "Responsive Box",
  textSize = "10ew",
  textAlign = "center",
  background = Color.new(0.2, 0.2, 0.2),
  textColor = Color.new(1, 1, 1),
})
print("   Initial (width=200): textSize = " .. box.textSize .. "px")
box.width = 400
box:resize(800, 600)
print("   After width change (width=400): textSize = " .. box.textSize .. "px")
print("   Scales with element size\n")

-- Example 6: Combining auto-scaling with min/max constraints
print("6. Auto-Scaling with Constraints")
print("   Text scales between 10px and 24px")
Gui.destroy()
local constrained = Gui.new({
  x = 10,
  y = 260,
  text = "Constrained Text",
  textSize = "3vh",
  minTextSize = 10,
  maxTextSize = 24,
  textColor = Color.new(1, 1, 1),
})
print("   Initial (3vh of 600): textSize = " .. constrained.textSize .. "px")
constrained:resize(1600, 1200)
print("   After resize (3vh of 1200 = 36px, clamped): textSize = " .. constrained.textSize .. "px")
print("   Clamped to maxTextSize = 24px\n")

print("=== Summary ===")
print("• Auto-scaling is ENABLED by default")
print("• Default scaling: 1.5vh (1.5% of viewport height)")
print("• Disable with: autoScaleText = false")
print("• Custom scaling: use vh, vw, %, ew, or eh units")
print("• Fixed sizes: use pixel values (e.g., textSize = 16)")
print("• Constraints: use minTextSize and maxTextSize")
