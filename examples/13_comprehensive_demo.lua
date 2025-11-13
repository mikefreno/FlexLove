--[[
  FlexLove Example 13: Comprehensive Demo
  
  This example combines multiple FlexLove features into a polished demo:
  - Flex and grid layouts
  - Themed components
  - Animations
  - Event handling
  - Responsive design
  
  Run with: love /path/to/libs/examples/13_comprehensive_demo.lua
]]

local Lv = love

local FlexLove = require("../FlexLove")
local Color = FlexLove.Color
local Animation = FlexLove.Animation
local enums = FlexLove.enums

function Lv.load()
  FlexLove.init({
    baseScale = { width = 1920, height = 1080 },
    theme = "space"
  })
  
  -- Header
  local header = FlexLove.new({
    x = 0,
    y = 0,
    width = "100vw",
    height = "12vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.SPACE_BETWEEN,
    alignItems = enums.AlignItems.CENTER,
    backgroundColor = Color.new(0.1, 0.1, 0.15, 1),
    padding = { top = 10, right = 20, bottom = 10, left = 20 },
    border = { bottom = true },
    borderColor = Color.new(0.3, 0.3, 0.4, 1),
  })
  
  -- Logo/Title
  FlexLove.new({
    parent = header,
    width = "auto",
    height = "auto",
    text = "FlexLove Demo",
    textSize = "4vh",
    textColor = Color.new(0.8, 0.9, 1, 1),
  })
  
  -- Header buttons
  local headerButtons = FlexLove.new({
    parent = header,
    width = "auto",
    height = "auto",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    gap = 10,
  })
  
  local buttonNames = { "Home", "Features", "About" }
  for _, name in ipairs(buttonNames) do
    FlexLove.new({
      parent = headerButtons,
      width = "8vw",
      height = "6vh",
      backgroundColor = Color.new(0.3, 0.4, 0.6, 1),
      text = name,
      textSize = "2vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 5,
      themeComponent = "button",
    })
  end
  
  -- Main content area
  local mainContent = FlexLove.new({
    x = 0,
    y = "12vh",
    width = "100vw",
    height = "88vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    backgroundColor = Color.new(0.05, 0.05, 0.08, 1),
  })
  
  -- Sidebar
  local sidebar = FlexLove.new({
    parent = mainContent,
    width = "20vw",
    height = "88vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
    padding = { top = 20, right = 10, bottom = 20, left = 10 },
    gap = 10,
    border = { right = true },
    borderColor = Color.new(0.2, 0.2, 0.3, 1),
  })
  
  -- Sidebar menu items
  local menuItems = {
    { icon = "◆", label = "Dashboard" },
    { icon = "◇", label = "Analytics" },
    { icon = "○", label = "Settings" },
    { icon = "□", label = "Profile" },
    { icon = "△", label = "Help" },
  }
  
  for _, item in ipairs(menuItems) do
    local menuButton = FlexLove.new({
      parent = sidebar,
      width = "auto",
      height = "7vh",
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.HORIZONTAL,
      alignItems = enums.AlignItems.CENTER,
      backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
      padding = { top = 10, right = 15, bottom = 10, left = 15 },
      cornerRadius = 5,
    })
    
    FlexLove.new({
      parent = menuButton,
      width = "auto",
      height = "auto",
      text = item.icon .. "  " .. item.label,
      textSize = "2vh",
      textColor = Color.new(0.9, 0.9, 0.9, 1),
    })
  end
  
  -- Content panel
  local contentPanel = FlexLove.new({
    parent = mainContent,
    width = "80vw",
    height = "88vh",
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
    gap = 15,
  })
  
  -- Welcome section
  FlexLove.new({
    parent = contentPanel,
    width = "auto",
    height = "auto",
    text = "Welcome to FlexLove!",
    textSize = "3.5vh",
    textColor = Color.new(1, 1, 1, 1),
  })
  
  -- Stats grid
  local statsGrid = FlexLove.new({
    parent = contentPanel,
    width = "auto",
    height = "20vh",
    positioning = enums.Positioning.GRID,
    gridRows = 1,
    gridColumns = 4,
    columnGap = 15,
  })
  
  local stats = {
    { label = "Projects", value = "24", color = Color.new(0.3, 0.6, 0.8, 1) },
    { label = "Users", value = "1.2K", color = Color.new(0.6, 0.3, 0.8, 1) },
    { label = "Revenue", value = "$45K", color = Color.new(0.8, 0.6, 0.3, 1) },
    { label = "Growth", value = "+12%", color = Color.new(0.3, 0.8, 0.6, 1) },
  }
  
  for _, stat in ipairs(stats) do
    local statCard = FlexLove.new({
      parent = statsGrid,
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.VERTICAL,
      justifyContent = enums.JustifyContent.CENTER,
      alignItems = enums.AlignItems.CENTER,
      backgroundColor = stat.color,
      cornerRadius = 8,
      padding = { top = 15, right = 15, bottom = 15, left = 15 },
    })
    
    FlexLove.new({
      parent = statCard,
      width = "auto",
      height = "auto",
      text = stat.value,
      textSize = "4vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
    })
    
    FlexLove.new({
      parent = statCard,
      width = "auto",
      height = "auto",
      text = stat.label,
      textSize = "1.8vh",
      textColor = Color.new(0.9, 0.9, 0.9, 1),
      textAlign = enums.TextAlign.CENTER,
    })
  end
  
  -- Feature cards
  local cardsContainer = FlexLove.new({
    parent = contentPanel,
    width = "auto",
    height = "auto",
    positioning = enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 3,
    rowGap = 15,
    columnGap = 15,
  })
  
  local features = {
    "Flexbox Layout",
    "Grid System",
    "Theming",
    "Animations",
    "Events",
    "Responsive"
  }
  
  for i, feature in ipairs(features) do
    local card = FlexLove.new({
      parent = cardsContainer,
      positioning = enums.Positioning.FLEX,
      justifyContent = enums.JustifyContent.CENTER,
      alignItems = enums.AlignItems.CENTER,
      backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
      cornerRadius = 10,
      padding = { top = 20, right = 20, bottom = 20, left = 20 },
    })
    
    FlexLove.new({
      parent = card,
      width = "auto",
      height = "auto",
      text = feature,
      textSize = "2.5vh",
      textColor = Color.new(0.9, 0.9, 0.9, 1),
      textAlign = enums.TextAlign.CENTER,
    })
    
    -- Add hover animation
    card.onEvent = function(element)
      local anim = Animation.new({
        duration = 0.2,
        start = { opacity = 1 },
        final = { opacity = 0.8 },
      })
      anim:apply(element)
    end
  end
end

function Lv.update(dt)
  FlexLove.update(dt)
end

function Lv.draw()
  Lv.graphics.clear(0.05, 0.05, 0.08, 1)
  FlexLove.draw()
end

function Lv.resize(w, h)
  FlexLove.resize(w, h)
end
