-- Demo: Retained children with immediate parents
-- Shows how retained-mode children persist when immediate-mode parents recreate each frame

local FlexLove = require("FlexLove")

-- Track frame count for demo
local frameCount = 0

-- Retained button state (will persist across frames)
local buttonClicks = 0
local topLevelButtonClicks = 0

function love.load()
  love.window.setTitle("Mixed-Mode Demo: Retained Children + Immediate Parents")
  love.window.setMode(800, 600)
  
  FlexLove.init({
    immediateMode = true,
    performanceMonitoring = true,
  })
end

function love.update(dt)
  FlexLove.update(dt)
end

function love.draw()
  FlexLove.beginFrame()
  
  -- Frame counter (immediate mode - recreates each frame)
  local header = FlexLove.new({
    width = 800,
    height = 60,
    backgroundColor = { 0.1, 0.1, 0.15, 1 },
    padding = 20,
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
  })
  
  FlexLove.new({
    parent = header,
    text = "Frame: " .. frameCount,
    textColor = { 1, 1, 1, 1 },
    textSize = 20,
  })
  
  FlexLove.new({
    parent = header,
    text = "Mixed-Mode Element Tree Demo",
    textColor = { 0.8, 0.9, 1, 1 },
    textSize = 24,
  })
  
  -- Main content area (immediate parent)
  local container = FlexLove.new({
    id = "main_container",
    y = 60,
    width = 800,
    height = 540,
    padding = 30,
    gap = 20,
    backgroundColor = { 0.05, 0.05, 0.08, 1 },
    flexDirection = "vertical",
  })
  
  -- Section 1: Retained button in immediate parent
  FlexLove.new({
    parent = container,
    text = "1. Retained Button (persists across frames)",
    textColor = { 0.9, 0.9, 0.9, 1 },
    textSize = 18,
  })
  
  local retainedButton = FlexLove.new({
    id = "retained_button",
    mode = "retained", -- This button will persist!
    parent = container,
    width = 300,
    height = 50,
    backgroundColor = { 0.2, 0.6, 0.9, 1 },
    cornerRadius = 8,
    text = "Clicks: " .. buttonClicks,
    textColor = { 1, 1, 1, 1 },
    textSize = 16,
    textAlign = "center",
    onEvent = function(element, event)
      if event.type == "click" then
        buttonClicks = buttonClicks + 1
        -- Update button text
        element.text = "Clicks: " .. buttonClicks
      end
    end,
  })
  
  FlexLove.new({
    parent = container,
    text = "Note: Button state persists even though parent recreates every frame",
    textColor = { 0.6, 0.6, 0.6, 1 },
    textSize = 12,
  })
  
  -- Section 2: Top-level retained element
  FlexLove.new({
    parent = container,
    text = "2. Top-Level Retained Element (also persists)",
    textColor = { 0.9, 0.9, 0.9, 1 },
    textSize = 18,
    margin = { top = 20 },
  })
  
  FlexLove.new({
    parent = container,
    text = "Look at the bottom-left corner for a persistent panel",
    textColor = { 0.6, 0.6, 0.6, 1 },
    textSize = 12,
  })
  
  -- Section 3: Comparison with immediate button
  FlexLove.new({
    parent = container,
    text = "3. Immediate Button (recreates every frame)",
    textColor = { 0.9, 0.9, 0.9, 1 },
    textSize = 18,
    margin = { top = 20 },
  })
  
  FlexLove.new({
    parent = container,
    width = 300,
    height = 50,
    backgroundColor = { 0.9, 0.3, 0.3, 1 },
    cornerRadius = 8,
    text = "Can't track clicks (recreated)",
    textColor = { 1, 1, 1, 1 },
    textSize = 16,
    textAlign = "center",
    onEvent = function(element, event)
      if event.type == "click" then
        print("Immediate button clicked (but counter can't persist)")
      end
    end,
  })
  
  FlexLove.new({
    parent = container,
    text = "Note: This button is recreated every frame, so it can't maintain state",
    textColor = { 0.6, 0.6, 0.6, 1 },
    textSize = 12,
  })
  
  -- Top-level retained element (persists in immediate mode!)
  local topLevelPanel = FlexLove.new({
    id = "top_level_panel",
    mode = "retained",
    x = 10,
    y = 500,
    width = 250,
    height = 90,
    backgroundColor = { 0.15, 0.5, 0.3, 1 },
    cornerRadius = 10,
    padding = 15,
    gap = 10,
    flexDirection = "vertical",
  })
  
  FlexLove.new({
    id = "panel_title",
    mode = "retained",
    parent = topLevelPanel,
    text = "Persistent Panel",
    textColor = { 1, 1, 1, 1 },
    textSize = 16,
  })
  
  FlexLove.new({
    id = "panel_button",
    mode = "retained",
    parent = topLevelPanel,
    width = 220,
    height = 35,
    backgroundColor = { 1, 1, 1, 0.9 },
    cornerRadius = 5,
    text = "Panel Clicks: " .. topLevelButtonClicks,
    textColor = { 0.15, 0.5, 0.3, 1 },
    textSize = 14,
    textAlign = "center",
    onEvent = function(element, event)
      if event.type == "click" then
        topLevelButtonClicks = topLevelButtonClicks + 1
        element.text = "Panel Clicks: " .. topLevelButtonClicks
      end
    end,
  })
  
  FlexLove.endFrame()
  
  -- Increment frame counter AFTER drawing
  frameCount = frameCount + 1
  
  -- Draw all UI elements
  FlexLove.draw()
end

function love.mousepressed(x, y, button)
  FlexLove.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  FlexLove.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  FlexLove.mousemoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
  FlexLove.wheelmoved(x, y)
end
