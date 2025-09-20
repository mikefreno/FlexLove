-- Test current font behavior during resize
package.path = package.path .. ";?.lua"

require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI

local function testCurrentFontBehavior()
  print("=== Testing Current Font Behavior During Resize ===")
  
  Gui.destroy() -- Clean slate
  
  -- Create element with text and specific font size
  local element = Gui.new({
    id = "textElement",
    x = 100, y = 100,
    w = 400, h = 200,
    text = "Hello World",
    textSize = 16
  })
  element.prevGameSize = { width = 800, height = 600 }
  
  print("Before resize:")
  print(string.format("Element: %dx%d, textSize: %s", element.width, element.height, element.textSize or "nil"))
  
  -- Resize from 800x600 to 1200x900 (1.5x scale)
  element:resize(1200, 900)
  
  print("\nAfter resize (1200x900):")
  print(string.format("Element: %dx%d, textSize: %s", element.width, element.height, element.textSize or "nil"))
  
  print("\nExpected: Element should be 600x300, textSize should scale to 24 (16 * 1.5)")
  print("Current: textSize doesn't scale - this is the issue we need to fix")
end

testCurrentFontBehavior()