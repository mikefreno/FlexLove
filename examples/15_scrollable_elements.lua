-- Example 15: Scrollable Elements
-- Demonstrates scrollable containers with overflow detection and visual scrollbars

local FlexLove = require("FlexLove")
local Gui = FlexLove.Gui
local Color = FlexLove.Color
local enums = FlexLove.enums
local Lv = love

function Lv.load()
  Gui.init({
    baseScale = { width = 1920, height = 1080 },
  })

  -- Title
  Gui.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 15: Scrollable Elements",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })

  -- Example 1: Vertical scroll with auto scrollbars
  local verticalScroll = Gui.new({
    x = "5vw",
    y = "12vh",
    width = "25vw",
    height = "35vh",
    overflow = "auto",
    backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
    cornerRadius = 8,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 5,
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  -- Add many items to create overflow
  for i = 1, 20 do
    Gui.new({
      parent = verticalScroll,
      height = "5vh",
      backgroundColor = Color.new(0.3 + (i % 3) * 0.1, 0.4, 0.6, 1),
      cornerRadius = 4,
      text = "Item " .. i,
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end

  -- Example 2: Custom styled scrollbar
  local customScroll = Gui.new({
    x = "35vw",
    y = "12vh",
    width = "60vw",
    height = "35vh",
    overflow = "auto",
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    cornerRadius = 8,
    scrollbarWidth = 16,
    scrollbarColor = Color.new(0.3, 0.6, 0.9, 1),
    scrollbarTrackColor = Color.new(0.15, 0.15, 0.2, 0.8),
    scrollbarRadius = 8,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 10,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })

  -- Add content
  for i = 1, 25 do
    Gui.new({
      parent = customScroll,
      height = "6vh",
      backgroundColor = Color.new(0.2, 0.25, 0.3, 1),
      cornerRadius = 6,
      text = "Custom Scrollbar Item " .. i,
      textColor = Color.new(0.9, 0.9, 1, 1),
      textSize = "2vh",
    })
  end

  -- Instructions
  Gui.new({
    x = "5vw",
    y = "52vh",
    width = "90vw",
    height = "40vh",
    backgroundColor = Color.new(0.1, 0.15, 0.2, 0.9),
    cornerRadius = 8,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
    text = [[Instructions:
• Use mouse wheel to scroll elements under cursor
• Click and drag scrollbar thumb to scroll
• Click on scrollbar track to jump to position
• Scrollbars automatically appear when content overflows
• overflow="auto" shows scrollbars only when needed
• overflow="scroll" always shows scrollbars
• overflow="hidden" clips without scrollbars
• overflow="visible" shows all content (default)

Scrollbar colors change on hover and when dragging!]],
    textColor = Color.new(0.9, 0.9, 1, 1),
    textSize = "2vh",
  })
end

function Lv.update(dt)
  Gui.update(dt)
end

function Lv.draw()
  love.graphics.clear(0.05, 0.05, 0.08, 1)
  Gui.draw()
end

function Lv.resize(w, h)
  Gui.resize(w, h)
end

function Lv.wheelmoved(x, y)
  Gui.wheelmoved(x, y)
end
