local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Theme = FlexLove.Theme
local Color = FlexLove.Color

---@class ProportionalScalingDemo
---@field window Element
local ProportionalScalingDemo = {}
ProportionalScalingDemo.__index = ProportionalScalingDemo

function ProportionalScalingDemo.init()
  local self = setmetatable({}, ProportionalScalingDemo)

  -- Load space theme
  Theme.load("space")
  Theme.setActive("space")

  -- Create main demo window
  self.window = Gui.new({
    x = 50,
    y = 50,
    width = 900,
    height = 700,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 0.95),
    positioning = "flex",
    flexDirection = "vertical",
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Title
  Gui.new({
    parent = self.window,
    height = 40,
    text = "Proportional 9-Slice Scaling Demo",
    textSize = 24,
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.2, 0.3, 1),
  })

  -- Description
  Gui.new({
    parent = self.window,
    height = 80,
    text = "Theme borders render ONLY in the padding area!\nwidth/height = content area, padding = border thickness\nBorders scale to fit padding dimensions.",
    textSize = 14,
    textAlign = "center",
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0.15, 0.15, 0.2, 0.8),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  -- Small buttons section
  local smallSection = Gui.new({
    parent = self.window,
    height = 160,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })

  Gui.new({
    parent = smallSection,
    height = 20,
    text = "Different Padding Sizes (borders scale to padding)",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
  })

  local smallButtonRow = Gui.new({
    parent = smallSection,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    justifyContent = "center",
    alignItems = "center",
  })

  -- Buttons with different padding - borders scale to fit
  Gui.new({
    parent = smallButtonRow,
    text = "Thin Border",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    padding = { horizontal = 8, vertical = 4 },
    themeComponent = "button",
    callback = function()
      print("Thin border button clicked!")
    end,
  })

  Gui.new({
    parent = smallButtonRow,
    text = "Medium Border",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    padding = { horizontal = 16, vertical = 8 },
    themeComponent = "button",
    callback = function()
      print("Medium border button clicked!")
    end,
  })

  Gui.new({
    parent = smallButtonRow,
    text = "Thick Border",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    padding = { horizontal = 24, vertical = 12 },
    themeComponent = "button",
    callback = function()
      print("Thick border button clicked!")
    end,
  })

  Gui.new({
    parent = smallButtonRow,
    text = "Extra Thick",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    padding = { horizontal = 32, vertical = 16 },
    themeComponent = "button",
    callback = function()
      print("Extra thick border button clicked!")
    end,
  })

  -- Content area demonstration
  local contentSection = Gui.new({
    parent = self.window,
    height = 180,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })

  Gui.new({
    parent = contentSection,
    height = 20,
    text = "Content Area = width x height (padding adds border space)",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
  })

  local contentRow = Gui.new({
    parent = contentSection,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    justifyContent = "center",
    alignItems = "center",
  })

  -- Same content size, different padding
  Gui.new({
    parent = contentRow,
    width = 100,
    height = 40,
    text = "100x40\n+5px pad",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    textSize = 10,
    padding = { horizontal = 5, vertical = 5 },
    themeComponent = "button",
    callback = function()
      print("Small padding clicked!")
    end,
  })

  Gui.new({
    parent = contentRow,
    width = 100,
    height = 40,
    text = "100x40\n+15px pad",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    textSize = 10,
    padding = { horizontal = 15, vertical = 15 },
    themeComponent = "button",
    callback = function()
      print("Large padding clicked!")
    end,
  })

  Gui.new({
    parent = contentRow,
    width = 100,
    height = 40,
    text = "100x40\n+25px pad",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    textSize = 10,
    padding = { horizontal = 25, vertical = 25 },
    themeComponent = "button",
    callback = function()
      print("Extra large padding clicked!")
    end,
  })

  -- Panel section
  local panelSection = Gui.new({
    parent = self.window,
    height = 250,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    backgroundColor = Color.new(0.12, 0.12, 0.17, 0.5),
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })

  Gui.new({
    parent = panelSection,
    height = 20,
    text = "Themed Panels (different sizes)",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
  })

  local panelRow = Gui.new({
    parent = panelSection,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    justifyContent = "center",
    alignItems = "flex-start",
  })

  -- Small panel
  local smallPanel = Gui.new({
    parent = panelRow,
    width = 150,
    height = 100,
    themeComponent = "panel",
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })

  Gui.new({
    parent = smallPanel,
    text = "Small\nPanel",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
  })

  -- Medium panel
  local mediumPanel = Gui.new({
    parent = panelRow,
    width = 200,
    height = 150,
    themeComponent = "panel",
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  Gui.new({
    parent = mediumPanel,
    text = "Medium Panel\nwith more content",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
  })

  -- Large panel
  local largePanel = Gui.new({
    parent = panelRow,
    width = 250,
    height = 180,
    themeComponent = "panel",
    padding = { top = 25, right = 25, bottom = 25, left = 25 },
  })

  Gui.new({
    parent = largePanel,
    text = "Large Panel\nScales proportionally\nBorders maintain aspect",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
  })

  return self
end

return ProportionalScalingDemo.init()
