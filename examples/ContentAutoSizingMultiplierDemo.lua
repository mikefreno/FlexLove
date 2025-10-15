-- ContentAutoSizingMultiplier Demo
-- Demonstrates how to use contentAutoSizingMultiplier to add padding/spacing
-- to auto-sized text elements without using explicit padding

local FlexLove = require("libs.FlexLove")

function love.load()
  -- Initialize with space theme (has contentAutoSizingMultiplier: width=1.05, height=1.1)
  FlexLove.Gui.init({
    baseScale = { width = 1920, height = 1080 },
    theme = "space",
  })

  -- Example 1: Text element with theme's default multiplier
  -- The space theme has width=1.05 (5% wider) and height=1.1 (10% taller)
  FlexLove.Element.new({
    x = "10vw",
    y = "10vh",
    text = "Theme Default Multiplier",
    textSize = "lg",
    textColor = FlexLove.Color.new(1, 1, 1, 1),
    backgroundColor = FlexLove.Color.new(0.2, 0.2, 0.8, 0.8),
    themeComponent = "button", -- Uses theme's contentAutoSizingMultiplier
  })

  -- Example 2: Text element with custom multiplier (override theme)
  -- This will be 20% wider and 30% taller than the actual text
  FlexLove.Element.new({
    x = "10vw",
    y = "25vh",
    text = "Custom Multiplier (1.2x, 1.3x)",
    textSize = "lg",
    textColor = FlexLove.Color.new(1, 1, 1, 1),
    backgroundColor = FlexLove.Color.new(0.8, 0.2, 0.2, 0.8),
    themeComponent = "button",
    contentAutoSizingMultiplier = { width = 1.2, height = 1.3 },
  })

  -- Example 3: Text element with no multiplier
  -- This will be exactly the size of the text (no extra space)
  FlexLove.Element.new({
    x = "10vw",
    y = "40vh",
    text = "No Multiplier (exact fit)",
    textSize = "lg",
    textColor = FlexLove.Color.new(1, 1, 1, 1),
    backgroundColor = FlexLove.Color.new(0.2, 0.8, 0.2, 0.8),
    contentAutoSizingMultiplier = { width = 1.0, height = 1.0 },
  })

  -- Example 4: Container with multiple text elements
  -- Shows how multiplier affects layout in flex containers
  local container = FlexLove.Element.new({
    x = "10vw",
    y = "55vh",
    positioning = FlexLove.Positioning.FLEX,
    flexDirection = FlexLove.FlexDirection.HORIZONTAL,
    gap = 10,
    backgroundColor = FlexLove.Color.new(0.1, 0.1, 0.1, 0.8),
    padding = { horizontal = 20, vertical = 10 },
  })

  for i = 1, 3 do
    FlexLove.Element.new({
      parent = container,
      text = "Item " .. i,
      textSize = "md",
      textColor = FlexLove.Color.new(1, 1, 1, 1),
      backgroundColor = FlexLove.Color.new(0.3, 0.3, 0.6, 0.8),
      themeComponent = "button", -- Uses theme's multiplier
    })
  end

  -- Example 5: Width-only multiplier
  -- Useful for creating horizontal padding without vertical padding
  FlexLove.Element.new({
    x = "10vw",
    y = "75vh",
    text = "Wide Button (1.5x width, 1.0x height)",
    textSize = "lg",
    textColor = FlexLove.Color.new(1, 1, 1, 1),
    backgroundColor = FlexLove.Color.new(0.6, 0.3, 0.6, 0.8),
    contentAutoSizingMultiplier = { width = 1.5, height = 1.0 },
  })

  -- Info text
  FlexLove.Element.new({
    x = "50vw",
    y = "10vh",
    text = "contentAutoSizingMultiplier Demo\n\n"
      .. "This feature multiplies auto-sized dimensions:\n"
      .. "- Theme default: width=1.05, height=1.1\n"
      .. "- Can be overridden per element\n"
      .. "- Useful for adding visual breathing room\n"
      .. "- Works with text and child-based sizing",
    textSize = "sm",
    textColor = FlexLove.Color.new(0.9, 0.9, 0.9, 1),
    backgroundColor = FlexLove.Color.new(0.15, 0.15, 0.15, 0.9),
    padding = { horizontal = 20, vertical = 15 },
  })
end

function love.update(dt)
  FlexLove.Gui.update(dt)
end

function love.draw()
  -- Dark background
  love.graphics.clear(0.05, 0.05, 0.1, 1)
  FlexLove.Gui.draw()
end

function love.resize()
  FlexLove.Gui.resize()
end
