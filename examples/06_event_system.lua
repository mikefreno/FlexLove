--[[
  FlexLove Example 06: Event System
  
  This example demonstrates the event system in FlexLove:
  - Click events (left, right, middle mouse buttons)
  - Press and release events
  - Event properties (position, modifiers, click count)
  - Double-click detection
  - Keyboard modifiers (Shift, Ctrl, Alt)
  
  Run with: love /path/to/libs/examples/06_event_system.lua
]]

local Lv = love

local FlexLove = require("../FlexLove")
local Gui = FlexLove.Gui
local Color = FlexLove.Color
local enums = FlexLove.enums

-- Event log
local eventLog = {}
local maxLogEntries = 15

local function addLogEntry(text)
  table.insert(eventLog, 1, text)
  if #eventLog > maxLogEntries then
    table.remove(eventLog)
  end
end

function Lv.load()
  Gui.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Title
  Gui.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 06: Event System",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: Click Events
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "10vh",
    width = "46vw",
    height = "3vh",
    text = "Click Events - Try left, right, middle mouse buttons",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local clickBox = Gui.new({
    x = "2vw",
    y = "14vh",
    width = "46vw",
    height = "20vh",
    backgroundColor = Color.new(0.3, 0.5, 0.7, 1),
    text = "Click me with different mouse buttons!",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
    callback = function(element, event)
      local buttonName = event.button == 1 and "Left" or (event.button == 2 and "Right" or "Middle")
      local eventTypeName = event.type:sub(1,1):upper() .. event.type:sub(2)
      
      if event.type == "click" or event.type == "rightclick" or event.type == "middleclick" then
        addLogEntry(string.format("%s Click at (%.0f, %.0f) - Count: %d", 
          buttonName, event.x, event.y, event.clickCount))
      elseif event.type == "press" then
        addLogEntry(string.format("%s Button Pressed at (%.0f, %.0f)", 
          buttonName, event.x, event.y))
      elseif event.type == "release" then
        addLogEntry(string.format("%s Button Released at (%.0f, %.0f)", 
          buttonName, event.x, event.y))
      end
    end,
  })
  
  -- ========================================
  -- Section 2: Keyboard Modifiers
  -- ========================================
  
  Gui.new({
    x = "50vw",
    y = "10vh",
    width = "48vw",
    height = "3vh",
    text = "Keyboard Modifiers - Hold Shift/Ctrl/Alt while clicking",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local modifierBox = Gui.new({
    x = "50vw",
    y = "14vh",
    width = "48vw",
    height = "20vh",
    backgroundColor = Color.new(0.7, 0.4, 0.5, 1),
    text = "Click with modifiers!",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
    callback = function(element, event)
      if event.type == "click" then
        local mods = {}
        if event.modifiers.shift then table.insert(mods, "Shift") end
        if event.modifiers.ctrl then table.insert(mods, "Ctrl") end
        if event.modifiers.alt then table.insert(mods, "Alt") end
        if event.modifiers.super then table.insert(mods, "Super") end
        
        local modText = #mods > 0 and table.concat(mods, "+") or "None"
        addLogEntry(string.format("Click with modifiers: %s", modText))
      end
    end,
  })
  
  -- ========================================
  -- Section 3: Double-Click Detection
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "36vh",
    width = "46vw",
    height = "3vh",
    text = "Double-Click Detection",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local doubleClickBox = Gui.new({
    x = "2vw",
    y = "40vh",
    width = "46vw",
    height = "15vh",
    backgroundColor = Color.new(0.5, 0.7, 0.4, 1),
    text = "Double-click me!",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
    callback = function(element, event)
      if event.type == "click" then
        if event.clickCount == 1 then
          addLogEntry("Single click detected")
        elseif event.clickCount == 2 then
          addLogEntry("DOUBLE CLICK detected!")
          -- Visual feedback for double-click
          element.backgroundColor = Color.new(0.9, 0.9, 0.3, 1)
        elseif event.clickCount >= 3 then
          addLogEntry(string.format("TRIPLE+ CLICK detected! (count: %d)", event.clickCount))
          element.backgroundColor = Color.new(0.9, 0.3, 0.9, 1)
        end
        
        -- Reset color after a delay (simulated in update)
        element._resetTime = Lv.timer.getTime() + 0.3
      end
    end,
  })
  
  -- ========================================
  -- Section 4: Event Log Display
  -- ========================================
  
  Gui.new({
    x = "50vw",
    y = "36vh",
    width = "48vw",
    height = "3vh",
    text = "Event Log (most recent first)",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  -- Event log container
  local logContainer = Gui.new({
    x = "50vw",
    y = "40vh",
    width = "48vw",
    height = "56vh",
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.25, 0.25, 0.35, 1),
    cornerRadius = 5,
  })
  
  -- ========================================
  -- Section 5: Interactive Buttons
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "57vh",
    width = "46vw",
    height = "3vh",
    text = "Interactive Buttons",
    textSize = "2vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local buttonContainer = Gui.new({
    x = "2vw",
    y = "61vh",
    width = "46vw",
    height = "35vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.SPACE_EVENLY,
    alignItems = enums.AlignItems.STRETCH,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
    gap = 10,
  })
  
  -- Button 1: Press/Release events
  Gui.new({
    parent = buttonContainer,
    height = "8vh",
    backgroundColor = Color.new(0.4, 0.5, 0.8, 1),
    text = "Press and Release Events",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
    callback = function(element, event)
      if event.type == "press" then
        addLogEntry("Button 1: PRESSED")
        element.backgroundColor = Color.new(0.2, 0.3, 0.6, 1)
      elseif event.type == "release" then
        addLogEntry("Button 1: RELEASED")
        element.backgroundColor = Color.new(0.4, 0.5, 0.8, 1)
      end
    end,
  })
  
  -- Button 2: Click counter
  local clickCounter = 0
  Gui.new({
    parent = buttonContainer,
    height = "8vh",
    backgroundColor = Color.new(0.8, 0.5, 0.4, 1),
    text = "Click Counter: 0",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
    callback = function(element, event)
      if event.type == "click" then
        clickCounter = clickCounter + 1
        element.text = "Click Counter: " .. clickCounter
        addLogEntry("Button 2: Click #" .. clickCounter)
      end
    end,
  })
  
  -- Button 3: Clear log
  Gui.new({
    parent = buttonContainer,
    height = "8vh",
    backgroundColor = Color.new(0.6, 0.4, 0.6, 1),
    text = "Clear Event Log",
    textSize = "1.8vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 5,
    callback = function(element, event)
      if event.type == "click" then
        eventLog = {}
        addLogEntry("Log cleared!")
      end
    end,
  })
end

function Lv.update(dt)
  -- Reset double-click box color
  if doubleClickBox and doubleClickBox._resetTime and Lv.timer.getTime() >= doubleClickBox._resetTime then
    doubleClickBox.backgroundColor = Color.new(0.5, 0.7, 0.4, 1)
    doubleClickBox._resetTime = nil
  end
  
  Gui.update(dt)
end

function Lv.draw()
  Lv.graphics.clear(0.05, 0.05, 0.08, 1)
  Gui.draw()
  
  -- Draw event log
  Lv.graphics.setColor(0.8, 0.9, 1, 1)
  local logX = Lv.graphics.getWidth() * 0.50 + 10
  local logY = Lv.graphics.getHeight() * 0.40 + 10
  local lineHeight = 20
  
  for i, entry in ipairs(eventLog) do
    local alpha = 1.0 - (i - 1) / maxLogEntries * 0.5
    Lv.graphics.setColor(0.8, 0.9, 1, alpha)
    Lv.graphics.print(entry, logX, logY + (i - 1) * lineHeight)
  end
end

function Lv.resize(w, h)
  Gui.resize(w, h)
end
