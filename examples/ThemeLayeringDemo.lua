-- Demo showing the new layering system:
-- backgroundColor -> theme -> borders -> text

local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Theme = FlexLove.Theme
local Color = FlexLove.Color

function love.load()
  -- Initialize FlexLove with the space theme
  Gui.init({
    baseScale = { width = 1920, height = 1080 },
    theme = "space"
  })
  
  -- Create main container
  local container = Gui.new({
    x = 50,
    y = 50,
    width = 700,
    height = 500,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
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
    height = 40,
    text = "Theme Layering Demo",
    textSize = 24,
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
  })
  
  -- Description
  Gui.new({
    parent = container,
    height = 60,
    text = "Layering order: backgroundColor -> theme -> borders -> text\nAll layers are always rendered when specified",
    textSize = 14,
    textAlign = "center",
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0.15, 0.15, 0.2, 0.8),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  -- Example 1: Theme with backgroundColor
  local example1 = Gui.new({
    parent = container,
    height = 100,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  Gui.new({
    parent = example1,
    height = 20,
    text = "Example 1: Theme with backgroundColor (red tint behind)",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  Gui.new({
    parent = example1,
    width = 200,
    height = 50,
    text = "Themed Button",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.8, 0.2, 0.2, 0.5), -- Red tint behind theme
    themeComponent = "button",
    callback = function(element, event)
      if event.type == "click" then
        print("Button with backgroundColor clicked!")
      end
    end
  })
  
  -- Example 2: Theme with borders
  local example2 = Gui.new({
    parent = container,
    height = 100,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  Gui.new({
    parent = example2,
    height = 20,
    text = "Example 2: Theme with borders (yellow borders on top)",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  Gui.new({
    parent = example2,
    width = 200,
    height = 50,
    text = "Bordered Button",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.3, 0.5),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 0, 1), -- Yellow border on top of theme
    themeComponent = "button",
    callback = function(element, event)
      if event.type == "click" then
        print("Button with borders clicked!")
      end
    end
  })
  
  -- Example 3: Theme with both backgroundColor and borders
  local example3 = Gui.new({
    parent = container,
    height = 120,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })
  
  Gui.new({
    parent = example3,
    height = 20,
    text = "Example 3: Theme with backgroundColor AND borders",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  Gui.new({
    parent = example3,
    width = 250,
    height = 60,
    text = "Full Layering",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.6, 0.8, 0.3), -- Blue tint behind
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0, 1, 0, 1), -- Green border on top
    themeComponent = "button",
    callback = function(element, event)
      if event.type == "click" then
        print("Full layering button clicked!")
      end
    end
  })
  
  -- Example 4: Panel with backgroundColor
  Gui.new({
    x = 800,
    y = 50,
    width = 300,
    height = 200,
    backgroundColor = Color.new(0.3, 0.1, 0.3, 0.5), -- Purple tint
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 0.5, 0, 1), -- Orange border
    themeComponent = "panel",
    padding = { top = 20, right = 20, bottom = 20, left = 20 }
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
  love.graphics.print("Theme Layering System", 10, 10)
  love.graphics.print("Hover over buttons to see state changes", 10, 30)
end

function love.resize(w, h)
  Gui.resize()
end
