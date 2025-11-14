-- Example: Theming and Custom Components
-- This demonstrates how to use themes and create custom components

local FlexLove = require("libs.FlexLove")

local ThemeExample = {}

function ThemeExample:new()
  local obj = {
    themeIndex = 1,
    themes = { "space", "metal" },
  }
  setmetatable(obj, { __index = self })
  return obj
end

function ThemeExample:render()
  local flex = FlexLove.new({
    x = "10%",
    y = "10%",
    width = "80%",
    height = "80%",
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    padding = { horizontal = 10, vertical = 10 },
  })

  -- Title
  FlexLove.new({
    parent = flex,
    text = "Theming and Custom Components Example",
    textAlign = "center",
    textSize = "2xl",
    width = "100%",
    height = "10%",
  })

  -- Theme selector
  local themeSelector = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    width = "100%",
    height = "10%",
    backgroundColor = "#2d3748",
    borderRadius = 8,
    padding = { horizontal = 10 },
  })

  FlexLove.new({
    parent = themeSelector,
    text = "Current Theme: " .. self.themes[self.themeIndex],
    textAlign = "left",
    textSize = "md",
    width = "50%",
  })

  FlexLove.new({
    parent = themeSelector,
    themeComponent = "buttonv2",
    text = "Switch Theme",
    textAlign = "center",
    width = "30%",
    onEvent = function(_, event)
      if event.type == "release" then
        self.themeIndex = (self.themeIndex % #self.themes) + 1
        -- In a real app, you'd update the theme here
        print("Theme switched to: " .. self.themes[self.themeIndex])
      end
    end,
  })

  -- Custom component example - A styled card
  local customCard = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "vertical",
    justifyContent = "center",
    alignItems = "center",
    width = "100%",
    height = "40%",
    themeComponent = "cardv2", -- Uses theme styling
    padding = { horizontal = 20, vertical = 20 },
    margin = { top = 10 },
  })

  FlexLove.new({
    parent = customCard,
    text = "Custom Card Component",
    textAlign = "center",
    textSize = "lg",
    width = "100%",
    height = "30%",
  })

  FlexLove.new({
    parent = customCard,
    text = "This demonstrates how to create reusable components with theme support",
    textAlign = "center",
    textSize = "sm",
    width = "100%",
    height = "50%",
    color = "#a0aec0", -- Light gray text
  })

  -- Another custom component - Status indicator
  local statusIndicator = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    width = "100%",
    height = "20%",
    backgroundColor = "#4a5568",
    borderRadius = 8,
    padding = { horizontal = 15 },
  })

  FlexLove.new({
    parent = statusIndicator,
    text = "Status: Active",
    textAlign = "left",
    textSize = "md",
    width = "50%",
  })

  local statusDot = FlexLove.new({
    parent = statusIndicator,
    positioning = "flex",
    width = 20,
    height = 20,
    backgroundColor = "#48bb78", -- Green dot
    borderRadius = 10, -- Circle
  })

  return flex
end

return ThemeExample

