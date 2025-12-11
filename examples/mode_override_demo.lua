-- Mode Override Demo
-- Demonstrates per-element mode override in FlexLöve
-- Shows how to mix immediate and retained mode elements in the same application

package.path = package.path .. ";../?.lua;../modules/?.lua"
local FlexLove = require("FlexLove")
local Color = require("modules.Color")

-- Global state
local frameCount = 0
local clickCount = 0
local retainedPanelCreated = false
local retainedPanel = nil

function love.load()
  -- Initialize FlexLove in immediate mode globally
  FlexLove.init({
    immediateMode = true,
    theme = "space",
  })
  
  love.window.setTitle("Mode Override Demo - FlexLöve")
  love.window.setMode(1200, 800)
end

function love.update(dt)
  FlexLove.update(dt)
  frameCount = frameCount + 1
end

function love.draw()
  love.graphics.clear(0.1, 0.1, 0.15, 1)
  
  FlexLove.beginFrame()
  
  -- Title - Immediate mode (default, recreated every frame)
  FlexLove.new({
    text = "Mode Override Demo",
    textSize = 32,
    textColor = Color.new(1, 1, 1, 1),
    width = "100vw",
    height = 60,
    textAlign = "center",
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    padding = { top = 15, bottom = 15 },
  })
  
  -- Container for demo panels
  local container = FlexLove.new({
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "center",
    alignItems = "flex-start",
    gap = 20,
    width = "100vw",
    height = "calc(100vh - 60px)",
    padding = { top = 20, left = 20, right = 20, bottom = 20 },
  })
  
  -- LEFT PANEL: Immediate Mode (Dynamic, recreated every frame)
  local leftPanel = FlexLove.new({
    mode = "immediate", -- Explicit immediate mode (would be default anyway)
    parent = container,
    width = "45vw",
    height = "calc(100vh - 100px)",
    backgroundColor = Color.new(0.15, 0.15, 0.2, 0.95),
    cornerRadius = 8,
    padding = { top = 20, left = 20, right = 20, bottom = 20 },
    positioning = "flex",
    flexDirection = "vertical",
    gap = 15,
  })
  
  -- Panel title
  FlexLove.new({
    parent = leftPanel,
    text = "Immediate Mode Panel",
    textSize = 24,
    textColor = Color.new(0.4, 0.8, 1, 1),
    width = "100%",
    height = 40,
  })
  
  -- Description
  FlexLove.new({
    parent = leftPanel,
    text = "Elements in this panel are recreated every frame.\nState is preserved by StateManager.",
    textSize = 14,
    textColor = Color.new(0.8, 0.8, 0.8, 1),
    width = "100%",
    height = 60,
  })
  
  -- Live frame counter (updates automatically)
  FlexLove.new({
    parent = leftPanel,
    text = string.format("Frame: %d", frameCount),
    textSize = 18,
    textColor = Color.new(1, 1, 0.5, 1),
    width = "100%",
    height = 30,
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    padding = { top = 5, left = 10, right = 10, bottom = 5 },
    cornerRadius = 4,
  })
  
  -- Click counter (updates automatically)
  FlexLove.new({
    parent = leftPanel,
    text = string.format("Clicks: %d", clickCount),
    textSize = 18,
    textColor = Color.new(0.5, 1, 0.5, 1),
    width = "100%",
    height = 30,
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    padding = { top = 5, left = 10, right = 10, bottom = 5 },
    cornerRadius = 4,
  })
  
  -- Interactive button (state preserved across frames)
  FlexLove.new({
    parent = leftPanel,
    text = "Click Me! (Immediate Mode)",
    textSize = 16,
    textColor = Color.new(1, 1, 1, 1),
    width = "100%",
    height = 50,
    themeComponent = "button",
    onEvent = function(element, event)
      if event.type == "release" then
        clickCount = clickCount + 1
      end
    end,
  })
  
  -- Info box
  FlexLove.new({
    parent = leftPanel,
    text = "Notice how the frame counter updates\nautomatically without any manual updates.\n\nThis is the power of immediate mode:\nUI reflects application state automatically.",
    textSize = 13,
    textColor = Color.new(0.7, 0.7, 0.7, 1),
    width = "100%",
    height = "auto",
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    padding = { top = 10, left = 10, right = 10, bottom = 10 },
    cornerRadius = 4,
  })
  
  -- RIGHT PANEL: Retained Mode (Static, created once)
  -- Only create on first frame
  if not retainedPanelCreated then
    retainedPanel = FlexLove.new({
      mode = "retained", -- Explicit retained mode override
      parent = container,
      width = "45vw",
      height = "calc(100vh - 100px)",
      backgroundColor = Color.new(0.2, 0.15, 0.15, 0.95),
      cornerRadius = 8,
      padding = { top = 20, left = 20, right = 20, bottom = 20 },
      positioning = "flex",
      flexDirection = "vertical",
      gap = 15,
    })
    
    -- Panel title (retained)
    FlexLove.new({
      mode = "retained",
      parent = retainedPanel,
      text = "Retained Mode Panel",
      textSize = 24,
      textColor = Color.new(1, 0.6, 0.4, 1),
      width = "100%",
      height = 40,
    })
    
    -- Description (retained)
    FlexLove.new({
      mode = "retained",
      parent = retainedPanel,
      text = "Elements in this panel are created once\nand persist across frames.",
      textSize = 14,
      textColor = Color.new(0.8, 0.8, 0.8, 1),
      width = "100%",
      height = 60,
    })
    
    -- Static frame counter (won't update)
    local staticCounter = FlexLove.new({
      mode = "retained",
      parent = retainedPanel,
      text = string.format("Created at frame: %d", frameCount),
      textSize = 18,
      textColor = Color.new(1, 1, 0.5, 1),
      width = "100%",
      height = 30,
      backgroundColor = Color.new(0.3, 0.2, 0.2, 1),
      padding = { top = 5, left = 10, right = 10, bottom = 5 },
      cornerRadius = 4,
    })
    
    -- Click counter placeholder (must be manually updated)
    local retainedClickCounter = FlexLove.new({
      mode = "retained",
      parent = retainedPanel,
      text = string.format("Clicks: %d (manual update needed)", clickCount),
      textSize = 18,
      textColor = Color.new(0.5, 1, 0.5, 1),
      width = "100%",
      height = 30,
      backgroundColor = Color.new(0.3, 0.2, 0.2, 1),
      padding = { top = 5, left = 10, right = 10, bottom = 5 },
      cornerRadius = 4,
    })
    
    -- Interactive button with manual update
    FlexLove.new({
      mode = "retained",
      parent = retainedPanel,
      text = "Click Me! (Retained Mode)",
      textSize = 16,
      textColor = Color.new(1, 1, 1, 1),
      width = "100%",
      height = 50,
      themeComponent = "button",
      onEvent = function(element, event)
        if event.type == "release" then
          clickCount = clickCount + 1
          -- In retained mode, we must manually update the UI
          retainedClickCounter.text = string.format("Clicks: %d (manual update needed)", clickCount)
        end
      end,
    })
    
    -- Info box (retained)
    FlexLove.new({
      mode = "retained",
      parent = retainedPanel,
      text = "Notice how this panel's elements\ndon't update automatically.\n\nIn retained mode, you must manually\nupdate element properties when state changes.\n\nThis gives better performance for\nstatic UI elements.",
      textSize = 13,
      textColor = Color.new(0.7, 0.7, 0.7, 1),
      width = "100%",
      height = "auto",
      backgroundColor = Color.new(0.15, 0.1, 0.1, 1),
      padding = { top = 10, left = 10, right = 10, bottom = 10 },
      cornerRadius = 4,
    })
    
    retainedPanelCreated = true
  end
  
  FlexLove.endFrame()
  
  -- Bottom instructions
  love.graphics.setColor(0.5, 0.5, 0.5, 1)
  love.graphics.print("Global mode: Immediate | Left panel: Immediate (explicit) | Right panel: Retained (override)", 10, love.graphics.getHeight() - 30)
  love.graphics.print("Press ESC to quit", 10, love.graphics.getHeight() - 15)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
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
