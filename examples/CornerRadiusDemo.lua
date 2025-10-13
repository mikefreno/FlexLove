-- Demo showing corner radius functionality

local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

function love.load()
  Gui.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Create main container
  local container = Gui.new({
    x = 50,
    y = 50,
    width = 1100,
    height = 600,
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
    text = "Corner Radius Demo",
    textSize = 28,
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    cornerRadius = 10,
  })
  
  -- Row 1: Uniform corner radius
  local row1 = Gui.new({
    parent = container,
    height = 150,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 20,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    cornerRadius = 8,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  
  Gui.new({
    parent = row1,
    width = 150,
    height = 100,
    text = "radius: 0",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.8, 0.2, 0.2, 1),
    cornerRadius = 0,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  Gui.new({
    parent = row1,
    width = 150,
    height = 100,
    text = "radius: 10",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.8, 0.2, 1),
    cornerRadius = 10,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  Gui.new({
    parent = row1,
    width = 150,
    height = 100,
    text = "radius: 25",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.8, 1),
    cornerRadius = 25,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  Gui.new({
    parent = row1,
    width = 150,
    height = 100,
    text = "radius: 50\n(pill)",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.8, 0.2, 0.8, 1),
    cornerRadius = 50,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  -- Row 2: Individual corner radii
  local row2 = Gui.new({
    parent = container,
    height = 150,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 20,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    cornerRadius = 8,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  
  Gui.new({
    parent = row2,
    width = 150,
    height = 100,
    text = "Top-Left\nOnly",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.9, 0.5, 0.2, 1),
    cornerRadius = { topLeft = 30, topRight = 0, bottomLeft = 0, bottomRight = 0 },
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  Gui.new({
    parent = row2,
    width = 150,
    height = 100,
    text = "Top\nCorners",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.9, 0.5, 1),
    cornerRadius = { topLeft = 25, topRight = 25, bottomLeft = 0, bottomRight = 0 },
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  Gui.new({
    parent = row2,
    width = 150,
    height = 100,
    text = "Diagonal\nCorners",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.5, 0.2, 0.9, 1),
    cornerRadius = { topLeft = 30, topRight = 0, bottomLeft = 0, bottomRight = 30 },
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  Gui.new({
    parent = row2,
    width = 150,
    height = 100,
    text = "Mixed\nRadii",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.9, 0.9, 0.2, 1),
    cornerRadius = { topLeft = 5, topRight = 15, bottomLeft = 25, bottomRight = 35 },
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.5),
  })
  
  -- Row 3: Interactive buttons with corner radius
  local row3 = Gui.new({
    parent = container,
    height = 180,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 15,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    cornerRadius = 8,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  
  Gui.new({
    parent = row3,
    height = 25,
    text = "Interactive Buttons with Corner Radius:",
    textSize = 16,
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  local buttonRow = Gui.new({
    parent = row3,
    height = 80,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  Gui.new({
    parent = buttonRow,
    width = 180,
    height = 60,
    text = "Click Me!",
    textAlign = "center",
    textSize = 18,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.6, 0.9, 1),
    cornerRadius = 15,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.3),
    callback = function(element, event)
      if event.type == "click" then
        print("Button 1 clicked!")
      end
    end
  })
  
  Gui.new({
    parent = buttonRow,
    width = 180,
    height = 60,
    text = "Pill Button",
    textAlign = "center",
    textSize = 18,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.9, 0.3, 0.4, 1),
    cornerRadius = 30,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.3),
    callback = function(element, event)
      if event.type == "click" then
        print("Button 2 clicked!")
      end
    end
  })
  
  Gui.new({
    parent = buttonRow,
    width = 180,
    height = 60,
    text = "Sharp Top",
    textAlign = "center",
    textSize = 18,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.3, 0.8, 0.4, 1),
    cornerRadius = { topLeft = 0, topRight = 0, bottomLeft = 20, bottomRight = 20 },
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(1, 1, 1, 0.3),
    callback = function(element, event)
      if event.type == "click" then
        print("Button 3 clicked!")
      end
    end
  })
  
  -- Clipping demo
  local clippingDemo = Gui.new({
    x = 50,
    y = 670,
    width = 500,
    height = 150,
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
    cornerRadius = 20,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.8, 0.8, 0.9, 1),
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  
  Gui.new({
    parent = clippingDemo,
    height = 25,
    text = "Clipping Demo: Children clipped to parent's rounded corners",
    textSize = 14,
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })
  
  -- Child that extends beyond parent (will be clipped)
  Gui.new({
    parent = clippingDemo,
    x = -10,
    y = 40,
    width = 520,
    height = 80,
    backgroundColor = Color.new(0.9, 0.5, 0.2, 0.8),
    text = "This element extends beyond parent but is clipped!",
    textAlign = "center",
    textSize = 14,
    textColor = Color.new(1, 1, 1, 1),
    positioning = "absolute",
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
  love.graphics.print("Corner Radius System", 10, 10)
  love.graphics.print("Supports uniform radius (number) or individual corners (table)", 10, 30)
end

function love.resize(w, h)
  Gui.resize()
end
