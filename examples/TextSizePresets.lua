-- Example demonstrating text size presets
-- FlexLove provides convenient size presets that automatically scale with viewport

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

print("=== Text Size Presets Examples ===\n")

-- Example 1: All size presets
print("1. All Text Size Presets")
print("   Demonstrating all available size presets\n")

local presets = {
  { name = "xxs", vh = 0.75 },
  { name = "xs", vh = 1.0 },
  { name = "sm", vh = 1.25 },
  { name = "md", vh = 1.5 },
  { name = "lg", vh = 2.0 },
  { name = "xl", vh = 2.5 },
  { name = "xxl", vh = 3.0 },
  { name = "3xl", vh = 4.0 },
  { name = "4xl", vh = 5.0 },
}

print("At viewport height 600px:")
for _, preset in ipairs(presets) do
  local element = Gui.new({
    text = "Sample Text (" .. preset.name .. ")",
    textSize = preset.name,
    textColor = Color.new(1, 1, 1),
  })

  local expectedSize = (preset.vh / 100) * 600
  print(string.format("   %4s: textSize = %.2fpx (expected: %.2fpx = %.2fvh)",
    preset.name, element.textSize, expectedSize, preset.vh))

  -- Verify it matches expected size
  assert(math.abs(element.textSize - expectedSize) < 0.01,
    string.format("Size mismatch for %s: got %.2f, expected %.2f", preset.name, element.textSize, expectedSize))

  element:destroy()
end

print("\n2. Auto-Scaling Behavior")
print("   Text size presets automatically scale with viewport\n")

Gui.destroy()
local mdElement = Gui.new({
  text = "Medium Text",
  textSize = "md",
  textColor = Color.new(1, 1, 1),
})

print("   'md' preset at 600px viewport: " .. mdElement.textSize .. "px")
mdElement:resize(1200, 1200)
print("   'md' preset at 1200px viewport: " .. mdElement.textSize .. "px")
print("   Scaling factor: " .. (mdElement.textSize / 9.0) .. "x\n")

-- Example 3: Combining presets with other properties
print("3. Presets with Flex Layout")
print("   Using presets in a practical layout\n")

Gui.destroy()
local container = Gui.new({
  x = 10,
  y = 10,
  width = 400,
  height = 300,
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
  padding = { horizontal = 20, vertical = 20 },
  background = Color.new(0.1, 0.1, 0.1),
})

local title = Gui.new({
  parent = container,
  text = "Title (xl)",
  textSize = "xl",
  textColor = Color.new(1, 1, 1),
})

local subtitle = Gui.new({
  parent = container,
  text = "Subtitle (lg)",
  textSize = "lg",
  textColor = Color.new(0.8, 0.8, 0.8),
})

local body = Gui.new({
  parent = container,
  text = "Body text (md)",
  textSize = "md",
  textColor = Color.new(0.7, 0.7, 0.7),
})

local caption = Gui.new({
  parent = container,
  text = "Caption (sm)",
  textSize = "sm",
  textColor = Color.new(0.5, 0.5, 0.5),
})

print("   Title: " .. title.textSize .. "px")
print("   Subtitle: " .. subtitle.textSize .. "px")
print("   Body: " .. body.textSize .. "px")
print("   Caption: " .. caption.textSize .. "px\n")

-- Example 4: Presets vs Custom Units
print("4. Presets vs Custom Units")
print("   Comparing preset convenience with custom units\n")

Gui.destroy()
local preset = Gui.new({
  text = "Using preset 'lg'",
  textSize = "lg",
  textColor = Color.new(1, 1, 1),
})

local custom = Gui.new({
  text = "Using custom '2vh'",
  textSize = "2vh",
  textColor = Color.new(1, 1, 1),
})

print("   Preset 'lg': " .. preset.textSize .. "px (2vh)")
print("   Custom '2vh': " .. custom.textSize .. "px")
print("   Both are equivalent!\n")

-- Example 5: Responsive Typography
print("5. Responsive Typography Scale")
print("   Building a complete type scale with presets\n")

Gui.destroy()
local typeScale = {
  { label = "Display", preset = "4xl" },
  { label = "Heading 1", preset = "3xl" },
  { label = "Heading 2", preset = "xxl" },
  { label = "Heading 3", preset = "xl" },
  { label = "Heading 4", preset = "lg" },
  { label = "Body Large", preset = "md" },
  { label = "Body", preset = "sm" },
  { label = "Caption", preset = "xs" },
  { label = "Fine Print", preset = "xxs" },
}

print("   Typography Scale at 600px viewport:")
for _, item in ipairs(typeScale) do
  local element = Gui.new({
    text = item.label,
    textSize = item.preset,
    textColor = Color.new(1, 1, 1),
  })
  print(string.format("   %-15s (%4s): %.2fpx", item.label, item.preset, element.textSize))
  element:destroy()
end

print("\n=== Summary ===")
print("• Text size presets: xxs, xs, sm, md, lg, xl, xxl, 3xl, 4xl")
print("• All presets use viewport-relative units (vh)")
print("• Automatically scale with window size")
print("• Provide consistent typography scales")
print("• Can be mixed with custom units (px, vh, vw, %, ew, eh)")
print("• Default preset when no textSize specified: md (1.5vh)")
