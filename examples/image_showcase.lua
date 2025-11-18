-- Image Showcase Example
-- Demonstrates all image features in FlexLove

local FlexLove = require("libs.FlexLove")
local Color = FlexLove.Color
-- I use this to avoid lsp warnings
local lv = love

-- Set to immediate mode for this example
FlexLove.setMode("immediate")

function lv.load()
  -- Set window size
  lv.window.setMode(1200, 800, { resizable = true })
  lv.window.setTitle("FlexLove Image Showcase")
end

function lv.draw()
  local container = FlexLove.new({
    width = "100vw",
    height = "100vh",
    flexDirection = "vertical",
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
    gap = 20,
    backgroundColor = Color.new(0.95, 0.95, 0.95, 1),
  })

  -- Title
  local title = FlexLove.new({
    parent = container,
    text = "FlexLove Image Showcase",
    textSize = "xxl",
    textColor = Color.new(0.2, 0.2, 0.2, 1),
    textAlign = "center",
    padding = { top = 0, right = 0, bottom = 20, left = 0 },
  })

  -- Section 1: Object-Fit Modes
  local fitSection = FlexLove.new({
    parent = container,
    flexDirection = "vertical",
    gap = 10,
  })

  local fitTitle = FlexLove.new({
    parent = fitSection,
    text = "Object-Fit Modes",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
  })

  local fitRow = FlexLove.new({
    parent = fitSection,
    flexDirection = "horizontal",
    gap = 10,
    justifyContent = "space-around",
  })

  local fitModes = { "fill", "contain", "cover", "scale-down", "none" }
  for _, mode in ipairs(fitModes) do
    local fitBox = FlexLove.new({
      parent = fitRow,
      width = 180,
      height = 120,
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    local fitImage = FlexLove.new({
      parent = fitBox,
      width = 160,
      height = 80,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      cornerRadius = 4,
      imagePath = "sample.jpg",
      objectFit = mode,
    })

    local fitLabel = FlexLove.new({
      parent = fitBox,
      text = mode,
      textSize = "sm",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
    })
  end

  local posSection = FlexLove.new({
    parent = container,
    flexDirection = "vertical",
    gap = 10,
  })

  local posTitle = FlexLove.new({
    parent = posSection,
    text = "Object-Position",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
  })

  local posRow = FlexLove.new({
    parent = posSection,
    flexDirection = "horizontal",
    gap = 10,
    justifyContent = "space-around",
  })

  local positions = { "top left", "center center", "bottom right", "50% 20%", "left center" }
  for _, pos in ipairs(positions) do
    local posBox = FlexLove.new({
      parent = posRow,
      width = 180,
      height = 120,
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    local posImage = FlexLove.new({
      parent = posBox,
      width = 160,
      height = 80,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      cornerRadius = 4,
      imagePath = "sample.jpg",
      objectFit = "none",
      objectPosition = pos,
    })

    local posLabel = FlexLove.new({
      parent = posBox,
      text = pos,
      textSize = "xs",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
    })
  end

  -- Section 3: Image Tiling/Repeat
  local tileSection = FlexLove.new({
    parent = container,
    flexDirection = "vertical",
    gap = 10,
  })

  local tileTitle = FlexLove.new({
    parent = tileSection,
    text = "Image Tiling (Repeat Modes)",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
  })

  local tileRow = FlexLove.new({
    parent = tileSection,
    flexDirection = "horizontal",
    gap = 10,
    justifyContent = "space-around",
  })

  local repeatModes = { "no-repeat", "repeat", "repeat-x", "repeat-y" }
  for _, mode in ipairs(repeatModes) do
    local tileBox = FlexLove.new({
      parent = tileRow,
      width = 240,
      height = 120,
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    local tileImage = FlexLove.new({
      parent = tileBox,
      width = 220,
      height = 80,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      cornerRadius = 4,
      -- imagePath = "assets/pattern.png",  -- Uncomment if you have a pattern image
      imageRepeat = mode,
    })

    local tileLabel = FlexLove.new({
      parent = tileBox,
      text = mode,
      textSize = "sm",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
    })
  end

  -- Section 4: Image Tinting and Opacity
  local tintSection = FlexLove.new({
    parent = container,
    flexDirection = "vertical",
    gap = 10,
  })

  local tintTitle = FlexLove.new({
    parent = tintSection,
    text = "Image Tinting & Opacity",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
  })

  local tintRow = FlexLove.new({
    parent = tintSection,
    flexDirection = "horizontal",
    gap = 10,
    justifyContent = "space-around",
  })

  local tints = {
    { name = "No Tint", color = nil, opacity = 1 },
    { name = "Red Tint", color = Color.new(1, 0.5, 0.5, 1), opacity = 1 },
    { name = "Blue Tint", color = Color.new(0.5, 0.5, 1, 1), opacity = 1 },
    { name = "50% Opacity", color = nil, opacity = 0.5 },
    { name = "Green + 70%", color = Color.new(0.5, 1, 0.5, 1), opacity = 0.7 },
  }

  for _, tint in ipairs(tints) do
    local tintBox = FlexLove.new({
      parent = tintRow,
      width = 180,
      height = 120,
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    local tintImage = FlexLove.new({
      parent = tintBox,
      width = 160,
      height = 80,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      cornerRadius = 4,
      imagePath = "sample.jpg",
      imageTint = tint.color,
      imageOpacity = tint.opacity,
    })

    local tintLabel = FlexLove.new({
      parent = tintBox,
      text = tint.name,
      textSize = "xs",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
    })
  end

  -- Footer note
  local note = FlexLove.new({
    parent = container,
    text = "Note: Uncomment imagePath properties in code to see actual images",
    textSize = "xs",
    textColor = Color.new(0.5, 0.5, 0.5, 1),
    textAlign = "center",
    padding = { top = 10, right = 0, bottom = 0, left = 0 },
  })
end

function lv.mousepressed(x, y, button)
  FlexLove.mousepressed(x, y, button)
end

function lv.mousereleased(x, y, button)
  FlexLove.mousereleased(x, y, button)
end

function lv.mousemoved(x, y, dx, dy)
  FlexLove.mousemoved(x, y, dx, dy)
end
