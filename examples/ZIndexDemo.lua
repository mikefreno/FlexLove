-- Example demonstrating z-index functionality
-- Elements with higher z-index appear on top (drawn last)

package.path = package.path .. ";?.lua"
require("testing/loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

print("=== Z-Index Demo ===\n")

-- Example 1: Top-level elements with different z-indices
print("1. Top-Level Elements")
print("   Creating 3 overlapping elements with different z-indices\n")

local back = Gui.new({
  id = "back",
  x = 10,
  y = 10,
  width = 100,
  height = 100,
  z = 1,
  background = Color.new(1, 0, 0, 0.8),
  text = "Z=1 (Back)",
  textColor = Color.new(1, 1, 1),
})

local middle = Gui.new({
  id = "middle",
  x = 50,
  y = 50,
  width = 100,
  height = 100,
  z = 2,
  background = Color.new(0, 1, 0, 0.8),
  text = "Z=2 (Middle)",
  textColor = Color.new(1, 1, 1),
})

local front = Gui.new({
  id = "front",
  x = 90,
  y = 90,
  width = 100,
  height = 100,
  z = 3,
  background = Color.new(0, 0, 1, 0.8),
  text = "Z=3 (Front)",
  textColor = Color.new(1, 1, 1),
})

print("Before draw:")
for i, elem in ipairs(Gui.topElements) do
  print(string.format("  %d. %s (z=%d)", i, elem.id, elem.z))
end

-- Trigger sorting by calling draw
Gui.draw()

print("\nAfter draw (sorted by z-index):")
for i, elem in ipairs(Gui.topElements) do
  print(string.format("  %d. %s (z=%d)", i, elem.id, elem.z))
end
print("   Draw order: back → middle → front ✓")

-- Example 2: Children with z-indices
print("\n2. Children with Z-Indices")
print("   Children are also sorted by z-index within parent\n")

Gui.destroy()

local parent = Gui.new({
  id = "parent",
  x = 0,
  y = 0,
  width = 300,
  height = 300,
  background = Color.new(0.1, 0.1, 0.1, 1),
})

-- Create children in random z-order
local child3 = Gui.new({
  parent = parent,
  id = "child3",
  x = 150,
  y = 150,
  width = 80,
  height = 80,
  z = 3,
  background = Color.new(0, 0, 1, 0.8),
  text = "Z=3",
  textColor = Color.new(1, 1, 1),
})

local child1 = Gui.new({
  parent = parent,
  id = "child1",
  x = 50,
  y = 50,
  width = 80,
  height = 80,
  z = 1,
  background = Color.new(1, 0, 0, 0.8),
  text = "Z=1",
  textColor = Color.new(1, 1, 1),
})

local child2 = Gui.new({
  parent = parent,
  id = "child2",
  x = 100,
  y = 100,
  width = 80,
  height = 80,
  z = 2,
  background = Color.new(0, 1, 0, 0.8),
  text = "Z=2",
  textColor = Color.new(1, 1, 1),
})

print("Children added in order: child3, child1, child2")
print("Children z-indices: child3.z=3, child1.z=1, child2.z=2")
print("\nDuring draw, children will be sorted and drawn:")
print("  1. child1 (z=1) - drawn first (back)")
print("  2. child2 (z=2) - drawn second (middle)")
print("  3. child3 (z=3) - drawn last (front) ✓")

-- Example 3: Negative z-indices
print("\n3. Negative Z-Indices")
print("   Z-index can be negative for background elements\n")

Gui.destroy()

local background = Gui.new({
  id = "background",
  x = 0,
  y = 0,
  width = 200,
  height = 200,
  z = -1,
  background = Color.new(0.2, 0.2, 0.2, 1),
  text = "Background (z=-1)",
  textColor = Color.new(1, 1, 1),
})

local normal = Gui.new({
  id = "normal",
  x = 50,
  y = 50,
  width = 100,
  height = 100,
  z = 0,
  background = Color.new(0.5, 0.5, 0.5, 1),
  text = "Normal (z=0)",
  textColor = Color.new(1, 1, 1),
})

Gui.draw()

print("Elements sorted by z-index:")
for i, elem in ipairs(Gui.topElements) do
  print(string.format("  %d. %s (z=%d)", i, elem.id, elem.z))
end
print("   Background element drawn first ✓")

-- Example 4: Default z-index
print("\n4. Default Z-Index")
print("   Elements without explicit z-index default to 0\n")

Gui.destroy()

local default1 = Gui.new({
  id = "default1",
  x = 10,
  y = 10,
  width = 50,
  height = 50,
  background = Color.new(1, 0, 0, 1),
})

local explicit = Gui.new({
  id = "explicit",
  x = 30,
  y = 30,
  width = 50,
  height = 50,
  z = 1,
  background = Color.new(0, 1, 0, 1),
})

local default2 = Gui.new({
  id = "default2",
  x = 50,
  y = 50,
  width = 50,
  height = 50,
  background = Color.new(0, 0, 1, 1),
})

print("default1.z =", default1.z, "(default)")
print("explicit.z =", explicit.z, "(explicit)")
print("default2.z =", default2.z, "(default)")

Gui.draw()

print("\nAfter sorting:")
for i, elem in ipairs(Gui.topElements) do
  print(string.format("  %d. %s (z=%d)", i, elem.id, elem.z))
end
print("   Elements with z=0 drawn first, then z=1 ✓")

print("\n=== Summary ===")
print("• Z-index controls draw order (lower z drawn first, appears behind)")
print("• Top-level elements are sorted by z-index in Gui.draw()")
print("• Children are sorted by z-index within parent.draw()")
print("• Default z-index is 0")
print("• Negative z-indices are supported")
print("• Higher z-index = drawn later = appears on top")
