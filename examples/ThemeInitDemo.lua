-- Example: Setting theme in Gui.init()
-- NOTE: This should be called in love.load() after LÖVE graphics is initialized
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color
local Theme = FlexLove.Theme

-- In love.load():
-- Initialize GUI with theme
Gui.init({
  baseScale = { width = 1920, height = 1080 },
  theme = "space"  -- Load and activate the space theme
})

-- Alternative: Load theme manually if Gui.init() is called before love.load()
-- Theme.load("space")
-- Theme.setActive("space")

-- Now all elements can use the theme
local panel = Gui.new({
  x = 100,
  y = 100,
  width = 400,
  height = 300,
  themeComponent = "panel",
  padding = { top = 20, right = 20, bottom = 20, left = 20 },
})

local button1 = Gui.new({
  parent = panel,
  x = 20,
  y = 20,
  width = 150,
  height = 50,
  text = "Normal Button",
  textAlign = "center",
  textColor = Color.new(1, 1, 1, 1),
  themeComponent = "button",
  callback = function(element, event)
    if event.type == "click" then
      print("Button clicked!")
    end
  end
})

local button2 = Gui.new({
  parent = panel,
  x = 20,
  y = 80,
  width = 150,
  height = 50,
  text = "Disabled",
  textAlign = "center",
  textColor = Color.new(0.6, 0.6, 0.6, 1),
  themeComponent = "button",
  disabled = true,  -- Shows disabled state
  callback = function(element, event)
    print("This won't fire!")
  end
})

local input1 = Gui.new({
  parent = panel,
  x = 20,
  y = 140,
  width = 200,
  height = 40,
  text = "Type here...",
  textColor = Color.new(1, 1, 1, 1),
  themeComponent = "input",
})

local input2 = Gui.new({
  parent = panel,
  x = 20,
  y = 190,
  width = 200,
  height = 40,
  text = "Active input",
  textColor = Color.new(1, 1, 1, 1),
  themeComponent = "input",
  active = true,  -- Shows active/focused state
})

local input3 = Gui.new({
  parent = panel,
  x = 20,
  y = 240,
  width = 200,
  height = 40,
  text = "Disabled input",
  textColor = Color.new(0.6, 0.6, 0.6, 1),
  themeComponent = "input",
  disabled = true,  -- Shows disabled state
})

return {
  panel = panel,
  button1 = button1,
  button2 = button2,
  input1 = input1,
  input2 = input2,
  input3 = input3,
}
