local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

---@class EventSystemDemo
---@field window Element
---@field eventLog table<integer, string>
---@field logDisplay Element
local EventSystemDemo = {}
EventSystemDemo.__index = EventSystemDemo

function EventSystemDemo.init()
  local self = setmetatable({}, EventSystemDemo)
  self.eventLog = {}

  -- Create main demo window
  self.window = Gui.new({
    x = 50,
    y = 50,
    width = 700,
    height = 500,
    backgroundColor = Color.new(0.15, 0.15, 0.2, 0.95),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.8, 0.8, 0.8, 1),
    positioning = "flex",
    flexDirection = "vertical",
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Title
  local title = Gui.new({
    parent = self.window,
    height = 40,
    text = "Event System Demo - Try different clicks and modifiers!",
    textSize = 18,
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
  })

  -- Button container
  local buttonContainer = Gui.new({
    parent = self.window,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 0.5),
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })

  -- Helper function to add event to log
  local function logEvent(message)
    table.insert(self.eventLog, 1, message) -- Add to beginning
    if #self.eventLog > 10 then
      table.remove(self.eventLog) -- Keep only last 10 events
    end
    self:updateLogDisplay()
  end

  -- Left Click Button
  local leftClickBtn = Gui.new({
    parent = buttonContainer,
    width = 150,
    height = 80,
    text = "Left Click Me",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.6, 0.9, 0.8),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.4, 0.8, 1, 1),
    callback = function(element, event)
      local msg = string.format("[%s] Button: %d, Clicks: %d", 
        event.type, event.button, event.clickCount)
      logEvent(msg)
    end,
  })

  -- Right Click Button
  local rightClickBtn = Gui.new({
    parent = buttonContainer,
    width = 150,
    height = 80,
    text = "Right Click Me",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.9, 0.4, 0.4, 0.8),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 0.6, 0.6, 1),
    callback = function(element, event)
      if event.type == "rightclick" then
        logEvent("RIGHT CLICK detected!")
      elseif event.type == "click" then
        logEvent("Left click (try right click!)")
      end
    end,
  })

  -- Modifier Button
  local modifierBtn = Gui.new({
    parent = buttonContainer,
    width = 150,
    height = 80,
    text = "Try Shift/Ctrl",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.6, 0.9, 0.4, 0.8),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.8, 1, 0.6, 1),
    callback = function(element, event)
      if event.type == "click" then
        local mods = {}
        if event.modifiers.shift then table.insert(mods, "SHIFT") end
        if event.modifiers.ctrl then table.insert(mods, "CTRL") end
        if event.modifiers.alt then table.insert(mods, "ALT") end
        if event.modifiers.cmd then table.insert(mods, "CMD") end
        
        if #mods > 0 then
          logEvent("Modifiers: " .. table.concat(mods, "+"))
        else
          logEvent("No modifiers (try holding Shift/Ctrl)")
        end
      end
    end,
  })

  -- Multi-Event Button (shows all event types)
  local multiEventBtn = Gui.new({
    parent = buttonContainer,
    width = 150,
    height = 80,
    text = "All Events",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.9, 0.7, 0.3, 0.8),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 0.9, 0.5, 1),
    callback = function(element, event)
      local msg = string.format("[%s] Btn:%d at (%d,%d)", 
        event.type, event.button, math.floor(event.x), math.floor(event.y))
      logEvent(msg)
    end,
  })

  -- Event log display area
  self.logDisplay = Gui.new({
    parent = self.window,
    height = 200,
    text = "Event log will appear here...",
    textSize = 14,
    textAlign = "start",
    textColor = Color.new(0.9, 0.9, 1, 1),
    backgroundColor = Color.new(0.05, 0.05, 0.1, 1),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  return self
end

function EventSystemDemo:updateLogDisplay()
  if #self.eventLog == 0 then
    self.logDisplay.text = "Event log will appear here..."
  else
    self.logDisplay.text = table.concat(self.eventLog, "\n")
  end
end

return EventSystemDemo.init()
