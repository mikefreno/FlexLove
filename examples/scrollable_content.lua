local FlexLove = require("libs.FlexLove")
local Color = FlexLove.Color

---@class ScrollableContentExample
---@field window Element
---@field container Element
---@field scrollContainer Element
local ScrollableContentExample = {}
ScrollableContentExample.__index = ScrollableContentExample

function ScrollableContentExample.new()
  local self = setmetatable({}, ScrollableContentExample)

  -- Create main window with backdrop blur
  self.window = FlexLove.new({
    x = "25%",
    y = "10%",
    z = 1000,
    width = "50vw",
    height = "80vh",
    themeComponent = "framev3",
    scaleCorners = 3,
    positioning = "flex",
    flexDirection = "vertical",
    justifyContent = "center",
    alignItems = "center",
    gap = 10,
    backdropBlur = { intensity = 50, quality = 10 },
    backgroundColor = Color.new(0.1, 0.1, 0.1, 0.8),
  })

  -- Header
  FlexLove.new({
    parent = self.window,
    text = "Scrollable Content Example",
    textAlign = "center",
    textSize = "2xl",
    width = "100%",
    textColor = Color.new(1, 1, 1, 1),
    margin = { bottom = 10 },
  })

  -- Create scroll container with overflow handling
  self.scrollContainer = FlexLove.new({
    parent = self.window,
    width = "90%",
    height = "70%",
    positioning = "flex",
    flexDirection = "vertical",
    overflowY = "scroll",
    gap = 5,
    padding = { horizontal = 10, vertical = 5 },
    themeComponent = "framev3",
    backgroundColor = Color.new(0.2, 0.2, 0.2, 0.5),
  })

  -- Add multiple scrollable elements to demonstrate scrolling
  for i = 1, 30 do
    local text = string.format(
      "Item %d - This is a long line of content that should wrap and show how scrolling works in FlexLove when content exceeds the container bounds",
      i
    )

    FlexLove.new({
      parent = self.scrollContainer,
      text = text,
      textAlign = "start",
      textSize = "md",
      width = "100%",
      textColor = Color.new(0.9, 0.9, 0.9, 1),
      padding = { vertical = 5 },
      themeComponent = i % 3 == 0 and "panel" or "cardv2",
      backgroundColor = i % 3 == 0 and Color.new(0.3, 0.3, 0.3, 0.7) or Color.new(0.4, 0.4, 0.4, 0.5),
    })
  end

  -- Footer with instructions
  FlexLove.new({
    parent = self.window,
    text = "Scroll using the mouse wheel or drag the scrollbar",
    textAlign = "center",
    textSize = "sm",
    width = "100%",
    textColor = Color.new(0.7, 0.7, 0.7, 1),
    margin = { top = 10 },
  })

  return self
end

function ScrollableContentExample:destroy()
  if self.window then
    self.window:destroy()
    self.window = nil
  end
end

return ScrollableContentExample
