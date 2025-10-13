local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

---@class AnimDemo
---@field window Element
---@field button Element
---@field fadeButton Element
---@field scaleButton Element
local OnClickAnimDemo = {}
OnClickAnimDemo.__index = OnClickAnimDemo

function OnClickAnimDemo.init()
  local self = setmetatable({}, OnClickAnimDemo)

  -- Create a demo window
  self.window = Gui.new({
    x = 100,
    y = 100,
    z = 10,
    w = 300,
    h = 200,
    backgroundColor = Color.new(0.1, 0.1, 0.3, 0.8),
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.7, 0.7, 0.7, 1),
  })

  -- Create a fade button
  self.fadeButton = Gui.new({
    parent = self.window,
    x = 20,
    y = 80,
    w = 100,
    h = 40,
    text = "Fade",
    backgroundColor = Color.new(0.2, 0.9, 0.6, 0.8),
    textColor = Color.new(1, 1, 1),
    borderColor = Color.new(0.4, 1, 0.8, 1),
    callback = function()
      -- Create a fade animation
      local fadeAnim = Gui.Animation.fade(1, 0.8, 0.2)
      fadeAnim:apply(self.window)
    end,
  })

  -- Create a scale button
  self.scaleButton = Gui.new({
    parent = self.window,
    x = 20,
    y = 140,
    w = 100,
    h = 40,
    text = "Scale",
    backgroundColor = Color.new(0.9, 0.6, 0.2, 0.8),
    textColor = Color.new(1, 1, 1),
    borderColor = Color.new(1, 0.8, 0.4, 1),
    callback = function()
      -- Create a scale animation
      local scaleAnim = Gui.Animation.scale(1.5, { width = 100, height = 40 }, { width = 200, height = 80 })
      scaleAnim:apply(self.button)
    end,
  })

  return self
end

return OnClickAnimDemo.init()
