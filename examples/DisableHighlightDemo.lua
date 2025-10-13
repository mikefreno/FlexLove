-- Demo showing disableHighlight property

local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Theme = FlexLove.Theme
local Color = FlexLove.Color

function love.load()
  Gui.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Try to load space theme (optional)
  pcall(function()
    Theme.load("space")
    Theme.setActive("space")
  end)
  
  -- Create main container
  local container = Gui.new({
    x = 50,
    y = 50,
    width = 900,
    height = 550,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    cornerRadius = 20,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.5, 0.5, 0.6, 1),
    positioning = "flex",
    flexDirection = "vertical",
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })
  
  -- Title
  Gui.new({
    parent = container,
    height = 50,
    text = "disableHighlight Property Demo",
    textSize = 24,
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    cornerRadius = 10,
  })
  
  -- Description
  Gui.new({
    parent = container,
    height = 70,
    text = "Click buttons to see the difference.\nButtons with themeComponent automatically disable highlight (can be overridden).\nRegular buttons show highlight by default.",
    textSize = 13,
    textAlign = "center",
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0.15, 0.15, 0.2, 0.8),
    cornerRadius = 8,
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  -- Row 1: Regular buttons
  local row1 = Gui.new({
    parent = container,
    height = 130,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    cornerRadius = 8,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  
  Gui.new({
    parent = row1,
    height = 20,
    text = "Regular Buttons (no theme):",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  local regularRow = Gui.new({
    parent = row1,
    height = 80,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  Gui.new({
    parent = regularRow,
    width = 250,
    height = 70,
    text = "Default\n(shows highlight)",
    textAlign = "center",
    textSize = 14,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.6, 0.9, 1),
    cornerRadius = 12,
    callback = function(element, event)
      if event.type == "click" then
        print("Regular button with highlight clicked!")
      end
    end
  })
  
  Gui.new({
    parent = regularRow,
    width = 250,
    height = 70,
    text = "disableHighlight = true\n(no highlight)",
    textAlign = "center",
    textSize = 14,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.9, 0.3, 0.4, 1),
    cornerRadius = 12,
    disableHighlight = true,
    callback = function(element, event)
      if event.type == "click" then
        print("Regular button without highlight clicked!")
      end
    end
  })
  
  -- Row 2: Themed buttons
  local row2 = Gui.new({
    parent = container,
    height = 150,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    cornerRadius = 8,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  
  Gui.new({
    parent = row2,
    height = 20,
    text = "Themed Buttons (with themeComponent):",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  local themedRow = Gui.new({
    parent = row2,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  Gui.new({
    parent = themedRow,
    width = 250,
    height = 80,
    text = "Default\n(auto-disables highlight)",
    textAlign = "center",
    textSize = 14,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.6, 0.9, 0.3),
    cornerRadius = 12,
    themeComponent = "button",
    callback = function(element, event)
      if event.type == "click" then
        print("Themed button (auto-disabled highlight) clicked!")
      end
    end
  })
  
  Gui.new({
    parent = themedRow,
    width = 250,
    height = 80,
    text = "disableHighlight = false\n(forced highlight)",
    textAlign = "center",
    textSize = 14,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.9, 0.3, 0.4, 0.3),
    cornerRadius = 12,
    themeComponent = "button",
    disableHighlight = false,
    callback = function(element, event)
      if event.type == "click" then
        print("Themed button (forced highlight) clicked!")
      end
    end
  })
  
  -- Summary
  local summary = Gui.new({
    parent = container,
    height = 70,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 5,
    backgroundColor = Color.new(0.15, 0.2, 0.15, 0.8),
    cornerRadius = 8,
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  Gui.new({
    parent = summary,
    height = 18,
    text = "Summary:",
    textSize = 14,
    textColor = Color.new(0.8, 1, 0.8, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  Gui.new({
    parent = summary,
    height = 40,
    text = "• Regular buttons: highlight enabled by default\n• Themed buttons: highlight disabled by default (themes provide their own feedback)\n• Both can be explicitly overridden with disableHighlight property",
    textSize = 11,
    textColor = Color.new(0.9, 0.9, 0.9, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
end

function love.update(dt)
  Gui.update(dt)
end

function love.draw()
  love.graphics.clear(0.05, 0.05, 0.1, 1)
  Gui.draw()
  
  -- Draw instructions
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("disableHighlight Property Demo", 10, 10)
  love.graphics.print("Press and hold buttons to see the difference", 10, 30)
end

function love.resize(w, h)
  Gui.resize()
end
