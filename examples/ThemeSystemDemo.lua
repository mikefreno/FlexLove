local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Theme = FlexLove.Theme
local Color = FlexLove.Color

---@class ThemeDemo
---@field window Element
---@field statusText Element
local ThemeDemo = {}
ThemeDemo.__index = ThemeDemo

function ThemeDemo.init()
  local self = setmetatable({}, ThemeDemo)

  -- Try to load and set the default theme
  -- Note: This will fail if the atlas image doesn't exist yet
  -- For now, we'll demonstrate the API without actually loading a theme
  local themeLoaded = false
  local themeError = nil

  pcall(function()
    Theme.load("default")
    Theme.setActive("default")
    themeLoaded = true
  end)

  -- Create main demo window (without theme for now)
  self.window = Gui.new({
    x = 50,
    y = 50,
    width = 700,
    height = 550,
    background = Color.new(0.15, 0.15, 0.2, 0.95),
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
    text = "Theme System Demo",
    textSize = 20,
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    background = Color.new(0.2, 0.2, 0.3, 1),
  })

  -- Status message
  self.statusText = Gui.new({
    parent = self.window,
    height = 60,
    text = themeLoaded and "✓ Theme loaded successfully!\nTheme system is ready to use."
      or "⚠ Theme not loaded (atlas image missing)\nShowing API demonstration without actual theme rendering.",
    textSize = 14,
    textAlign = "center",
    textColor = themeLoaded and Color.new(0.3, 0.9, 0.3, 1) or Color.new(0.9, 0.7, 0.3, 1),
    background = Color.new(0.1, 0.1, 0.15, 0.8),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  -- Info section
  local infoSection = Gui.new({
    parent = self.window,
    height = 350,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 15,
    background = Color.new(0.1, 0.1, 0.15, 0.5),
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })

  -- Example 1: Basic themed button
  local example1 = Gui.new({
    parent = infoSection,
    height = 80,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    background = Color.new(0.12, 0.12, 0.17, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  Gui.new({
    parent = example1,
    height = 20,
    text = "Example 1: Basic Themed Button",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    background = Color.new(0, 0, 0, 0),
  })

  -- This button would use theme if loaded
  local themedButton = Gui.new({
    parent = example1,
    width = 150,
    height = 40,
    text = "Themed Button",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    background = Color.new(0.2, 0.6, 0.9, 0.8),
    -- theme = "button", -- Uncomment when theme atlas exists
    callback = function(element, event)
      if event.type == "click" then
        print("Themed button clicked!")
      end
    end,
  })

  -- Example 2: Button with states
  local example2 = Gui.new({
    parent = infoSection,
    height = 100,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    background = Color.new(0.12, 0.12, 0.17, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  Gui.new({
    parent = example2,
    height = 20,
    text = "Example 2: Button with Hover/Pressed States",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    background = Color.new(0, 0, 0, 0),
  })

  Gui.new({
    parent = example2,
    height = 15,
    text = "Hover over or click the button to see state changes (when theme is loaded)",
    textSize = 11,
    textColor = Color.new(0.6, 0.7, 0.8, 1),
    background = Color.new(0, 0, 0, 0),
  })

  local stateButton = Gui.new({
    parent = example2,
    width = 200,
    height = 40,
    text = "Interactive Button",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    background = Color.new(0.3, 0.7, 0.4, 0.8),
    -- theme = "button", -- Will automatically handle hover/pressed states
    callback = function(element, event)
      if event.type == "click" then
        print("State button clicked! State was:", element._themeState)
      end
    end,
  })

  -- Example 3: Themed panel
  local example3 = Gui.new({
    parent = infoSection,
    height = 120,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    background = Color.new(0.12, 0.12, 0.17, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  Gui.new({
    parent = example3,
    height = 20,
    text = "Example 3: Themed Panel/Container",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    background = Color.new(0, 0, 0, 0),
  })

  local themedPanel = Gui.new({
    parent = example3,
    width = 300,
    height = 80,
    background = Color.new(0.25, 0.25, 0.35, 0.9),
    -- theme = "panel", -- Would use panel theme component
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  Gui.new({
    parent = themedPanel,
    text = "This is a themed panel container.\nIt would have a 9-slice border when theme is loaded.",
    textSize = 12,
    textColor = Color.new(0.9, 0.9, 1, 1),
    textAlign = "center",
    background = Color.new(0, 0, 0, 0),
  })

  -- Code example section
  local codeSection = Gui.new({
    parent = self.window,
    height = 40,
    background = Color.new(0.08, 0.08, 0.12, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  Gui.new({
    parent = codeSection,
    text = 'Usage: element = Gui.new({ theme = "button", ... })',
    textSize = 12,
    textColor = Color.new(0.5, 0.9, 0.5, 1),
    background = Color.new(0, 0, 0, 0),
  })

  return self
end

return ThemeDemo.init()
