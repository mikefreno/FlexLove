local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Theme = FlexLove.Theme
local Color = FlexLove.Color

---@class CornerScalingDemo
---@field window Element
---@field currentMode string
---@field modeButtons table
local CornerScalingDemo = {}
CornerScalingDemo.__index = CornerScalingDemo

function CornerScalingDemo.init()
  local self = setmetatable({}, CornerScalingDemo)
  
  self.currentMode = "none"
  self.modeButtons = {}

  -- Try to load theme
  local themeLoaded = pcall(function()
    Theme.load("space")
    Theme.setActive("space")
  end)

  -- Create main window
  self.window = Gui.new({
    x = 50,
    y = 50,
    width = 900,
    height = 650,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 0.95),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.6, 0.6, 0.7, 1),
    positioning = "flex",
    flexDirection = "vertical",
    gap = 20,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Title
  Gui.new({
    parent = self.window,
    height = 40,
    text = "NineSlice Corner Scaling Demo",
    textSize = 24,
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.15, 0.15, 0.25, 1),
  })

  -- Status
  Gui.new({
    parent = self.window,
    height = 30,
    text = themeLoaded and "✓ Theme loaded - Scaling demonstration active" 
      or "⚠ Theme not loaded - Please ensure theme assets exist",
    textSize = 14,
    textAlign = "center",
    textColor = themeLoaded and Color.new(0.3, 0.9, 0.3, 1) or Color.new(0.9, 0.6, 0.3, 1),
    backgroundColor = Color.new(0.08, 0.08, 0.12, 0.8),
  })

  -- Mode selector section
  local modeSection = Gui.new({
    parent = self.window,
    height = 80,
    backgroundColor = Color.new(0.12, 0.12, 0.18, 1),
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
  })

  Gui.new({
    parent = modeSection,
    height = 20,
    text = "Select Scaling Mode:",
    textSize = 14,
    textColor = Color.new(0.8, 0.9, 1, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })

  -- Button container
  local buttonContainer = Gui.new({
    parent = modeSection,
    height = 40,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    backgroundColor = Color.new(0, 0, 0, 0),
  })

  -- Helper to create mode button
  local function createModeButton(mode, label)
    local button = Gui.new({
      parent = buttonContainer,
      width = 180,
      height = 40,
      text = label,
      textAlign = "center",
      textSize = 14,
      textColor = Color.new(1, 1, 1, 1),
      backgroundColor = self.currentMode == mode and Color.new(0.3, 0.6, 0.9, 1) or Color.new(0.25, 0.25, 0.35, 1),
      callback = function(element, event)
        if event.type == "click" then
          self:setMode(mode)
        end
      end,
    })
    self.modeButtons[mode] = button
    return button
  end

  createModeButton("none", "No Scaling (Default)")
  createModeButton("nearest", "Nearest Neighbor")
  createModeButton("bilinear", "Bilinear Interpolation")

  -- Comparison section
  local comparisonSection = Gui.new({
    parent = self.window,
    height = 420,
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
    positioning = "flex",
    flexDirection = "vertical",
    gap = 15,
  })

  -- Description
  Gui.new({
    parent = comparisonSection,
    height = 60,
    text = "The panels below demonstrate different scaling modes.\n" ..
           "• No Scaling: Corners remain at original size (may appear small at high DPI)\n" ..
           "• Nearest Neighbor: Sharp, pixelated scaling (ideal for pixel art)\n" ..
           "• Bilinear: Smooth, filtered scaling (ideal for high-quality graphics)",
    textSize = 12,
    textColor = Color.new(0.7, 0.8, 0.9, 1),
    backgroundColor = Color.new(0, 0, 0, 0),
  })

  -- Demo panels container
  local panelsContainer = Gui.new({
    parent = comparisonSection,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 20,
    backgroundColor = Color.new(0, 0, 0, 0),
  })

  -- Helper to create demo panel
  local function createDemoPanel(size, label)
    local container = Gui.new({
      parent = panelsContainer,
      width = (900 - 80 - 40) / 3, -- Divide available space
      positioning = "flex",
      flexDirection = "vertical",
      gap = 10,
      backgroundColor = Color.new(0, 0, 0, 0),
    })

    Gui.new({
      parent = container,
      height = 20,
      text = label,
      textSize = 12,
      textAlign = "center",
      textColor = Color.new(0.8, 0.9, 1, 1),
      backgroundColor = Color.new(0, 0, 0, 0),
    })

    local panel = Gui.new({
      parent = container,
      width = size,
      height = size,
      backgroundColor = Color.new(0.2, 0.3, 0.4, 0.5),
      theme = themeLoaded and "panel" or nil,
      padding = { top = 15, right = 15, bottom = 15, left = 15 },
    })

    Gui.new({
      parent = panel,
      text = "Themed\nPanel",
      textSize = 14,
      textAlign = "center",
      textColor = Color.new(1, 1, 1, 1),
      backgroundColor = Color.new(0, 0, 0, 0),
    })

    return panel
  end

  createDemoPanel(120, "Small (120x120)")
  createDemoPanel(160, "Medium (160x160)")
  createDemoPanel(200, "Large (200x200)")

  -- Info footer
  Gui.new({
    parent = self.window,
    height = 30,
    text = "Resize the window to see how scaling adapts to different DPI settings",
    textSize = 11,
    textAlign = "center",
    textColor = Color.new(0.5, 0.6, 0.7, 1),
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
  })

  return self
end

function CornerScalingDemo:setMode(mode)
  self.currentMode = mode
  
  -- Update button colors
  for modeName, button in pairs(self.modeButtons) do
    button.backgroundColor = modeName == mode and Color.new(0.3, 0.6, 0.9, 1) or Color.new(0.25, 0.25, 0.35, 1)
  end

  -- Update theme components based on mode
  local activeTheme = Theme.getActive()
  if activeTheme and activeTheme.components then
    for componentName, component in pairs(activeTheme.components) do
      if mode == "none" then
        component.scaleCorners = false
      elseif mode == "nearest" then
        component.scaleCorners = true
        component.scalingAlgorithm = "nearest"
      elseif mode == "bilinear" then
        component.scaleCorners = true
        component.scalingAlgorithm = "bilinear"
      end
      
      -- Clear cache to force re-rendering
      if component._scaledRegionCache then
        component._scaledRegionCache = {}
      end
    end
  end

  print("Scaling mode changed to: " .. mode)
end

return CornerScalingDemo.init()
