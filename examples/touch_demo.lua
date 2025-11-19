-- Touch Interaction Examples for FlexLöve
-- Demonstrates multi-touch gestures, scrolling, and touch events

package.path = package.path .. ";../?.lua;../modules/?.lua"

local FlexLove = require("FlexLove")
local lv = love

FlexLove.init({
  theme = "metal",
  baseScale = { width = 800, height = 600 },
})

-- Application state
local app = {
  touchPoints = {}, -- Active touch points for visualization
  gestureLog = {}, -- Recent gestures
  selectedTab = "basic", -- Current tab: basic, gestures, scroll
}

-- Helper to add gesture to log
local function logGesture(gestureName, details)
  table.insert(app.gestureLog, 1, {
    name = gestureName,
    details = details or "",
    time = lv.timer.getTime(),
  })

  -- Keep only last 5 gestures
  while #app.gestureLog > 5 do
    table.remove(app.gestureLog)
  end
end

-- Create main container
function lv.load()
  -- Tab buttons container
  local tabContainer = FlexLove.new({
    flexDirection = "row",
    gap = 10,
    padding = { top = 10, left = 10, right = 10, bottom = 10 },
    width = "100vw",
  })

  -- Tab buttons
  local tabs = { "basic", "gestures", "scroll" }
  for _, tabName in ipairs(tabs) do
    FlexLove.new({
      parent = tabContainer,
      text = tabName:upper(),
      padding = { top = 10, left = 20, right = 20, bottom = 10 },
      backgroundColor = app.selectedTab == tabName and { 0.3, 0.6, 0.8, 1 } or { 0.2, 0.2, 0.2, 1 },
      color = { 1, 1, 1, 1 },
      onEvent = function(el, event)
        if event.type == "click" or event.type == "touchrelease" then
          app.selectedTab = tabName
          lv.load() -- Reload UI
        end
      end,
    })
  end

  -- Content area based on selected tab
  if app.selectedTab == "basic" then
    createBasicTouchDemo()
  elseif app.selectedTab == "gestures" then
    createGesturesDemo()
  elseif app.selectedTab == "scroll" then
    createScrollDemo()
  end

  -- Touch visualization overlay (always visible)
  createTouchVisualization()
end

-- Basic touch event demo
function createBasicTouchDemo()
  local container = FlexLove.new({
    width = "100vw",
    height = "80vh",
    padding = 20,
    gap = 10,
    flexDirection = "column",
  })

  FlexLove.new({
    parent = container,
    text = "Touch Events Demo",
    fontSize = 24,
    color = { 1, 1, 1, 1 },
  })

  local touchInfo = {
    lastEvent = "None",
    touchId = "None",
    position = { x = 0, y = 0 },
  }

  local touchArea = FlexLove.new({
    parent = container,
    width = "90vw",
    height = 300,
    backgroundColor = { 0.2, 0.2, 0.3, 1 },
    justifyContent = "center",
    alignItems = "center",
    onEvent = function(el, event)
      if event.type == "touchpress" then
        touchInfo.lastEvent = "Touch Press"
        touchInfo.touchId = event.touchId or "unknown"
        touchInfo.position = { x = event.x, y = event.y }
        logGesture("Touch Press", string.format("ID: %s", touchInfo.touchId))
      elseif event.type == "touchmove" then
        touchInfo.lastEvent = "Touch Move"
        touchInfo.position = { x = event.x, y = event.y }
      elseif event.type == "touchrelease" then
        touchInfo.lastEvent = "Touch Release"
        logGesture("Touch Release", string.format("ID: %s", touchInfo.touchId))
      end
    end,
  })

  FlexLove.new({
    parent = touchArea,
    text = "Touch or click this area",
    color = { 0.7, 0.7, 0.7, 1 },
    fontSize = 18,
  })

  -- Info display
  FlexLove.new({
    parent = container,
    text = string.format("Last Event: %s", touchInfo.lastEvent),
    color = { 1, 1, 1, 1 },
  })

  FlexLove.new({
    parent = container,
    text = string.format("Touch ID: %s", touchInfo.touchId),
    color = { 1, 1, 1, 1 },
  })

  FlexLove.new({
    parent = container,
    text = string.format("Position: (%.0f, %.0f)", touchInfo.position.x, touchInfo.position.y),
    color = { 1, 1, 1, 1 },
  })
end

-- Gesture recognition demo
function createGesturesDemo()
  local container = FlexLove.new({
    width = "100vw",
    height = "80vh",
    padding = 20,
    gap = 10,
    flexDirection = "column",
  })

  FlexLove.new({
    parent = container,
    text = "Gesture Recognition Demo",
    fontSize = 24,
    color = { 1, 1, 1, 1 },
  })

  FlexLove.new({
    parent = container,
    text = "Try: Tap, Double-tap, Long-press, Swipe",
    fontSize = 14,
    color = { 0.7, 0.7, 0.7, 1 },
  })

  local gestureArea = FlexLove.new({
    parent = container,
    width = "90vw",
    height = 300,
    backgroundColor = { 0.2, 0.3, 0.2, 1 },
    justifyContent = "center",
    alignItems = "center",
  })

  FlexLove.new({
    parent = gestureArea,
    text = "Perform gestures here",
    color = { 0.7, 0.7, 0.7, 1 },
    fontSize = 18,
  })

  -- Gesture log display
  FlexLove.new({
    parent = container,
    text = "Recent Gestures:",
    fontSize = 16,
    color = { 1, 1, 1, 1 },
  })

  for i, gesture in ipairs(app.gestureLog) do
    FlexLove.new({
      parent = container,
      text = string.format("%d. %s - %s", i, gesture.name, gesture.details),
      fontSize = 12,
      color = { 0.8, 0.8, 0.8, 1 },
    })
  end
end

-- Scrollable content demo
function createScrollDemo()
  local container = FlexLove.new({
    width = "100vw",
    height = "80vh",
    padding = 20,
    gap = 10,
    flexDirection = "column",
  })

  FlexLove.new({
    parent = container,
    text = "Touch Scrolling Demo",
    fontSize = 24,
    color = { 1, 1, 1, 1 },
  })

  FlexLove.new({
    parent = container,
    text = "Touch and drag to scroll • Momentum scrolling enabled",
    fontSize = 14,
    color = { 0.7, 0.7, 0.7, 1 },
  })

  local scrollContainer = FlexLove.new({
    parent = container,
    width = "90vw",
    height = 400,
    backgroundColor = { 0.15, 0.15, 0.2, 1 },
    overflow = "auto",
    padding = 10,
    gap = 5,
  })

  -- Add many items to make it scrollable
  for i = 1, 50 do
    FlexLove.new({
      parent = scrollContainer,
      text = string.format("Scrollable Item #%d - Touch and drag to scroll", i),
      padding = { top = 15, left = 10, right = 10, bottom = 15 },
      backgroundColor = i % 2 == 0 and { 0.2, 0.2, 0.3, 1 } or { 0.25, 0.25, 0.35, 1 },
      color = { 1, 1, 1, 1 },
      width = "100%",
    })
  end
end

-- Touch visualization overlay
function createTouchVisualization()
  -- This would need custom drawing in lv.draw() to show active touch points
end

function lv.update(dt)
  FlexLove.update(dt)

  -- Update active touch points for visualization
  app.touchPoints = {}
  local touches = lv.touch.getTouches()
  for _, id in ipairs(touches) do
    local x, y = lv.touch.getPosition(id)
    table.insert(app.touchPoints, { x = x, y = y, id = tostring(id) })
  end
end

function lv.draw()
  FlexLove.draw()

  -- Draw touch point visualization
  for _, touch in ipairs(app.touchPoints) do
    lv.graphics.setColor(1, 0, 0, 0.5)
    lv.graphics.circle("fill", touch.x, touch.y, 30)
    lv.graphics.setColor(1, 1, 1, 1)
    lv.graphics.circle("line", touch.x, touch.y, 30)

    -- Draw touch ID
    lv.graphics.setColor(1, 1, 1, 1)
    lv.graphics.print(touch.id, touch.x - 10, touch.y - 40)
  end
end
