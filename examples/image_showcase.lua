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
    positioning = "flex",
    flexDirection = "vertical",
    gap = 20,
    backgroundColor = Color.new(0.95, 0.95, 0.95, 1),
    overflow = "scroll",
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Title
  FlexLove.new({
    parent = container,
    text = "FlexLove Image Showcase",
    textSize = "xxl",
    textColor = Color.new(0.2, 0.2, 0.2, 1),
    textAlign = "center",
    textWrap = "word",
    width = "100%",
    z = 1000,
    padding = { top = 0, right = 0, bottom = 20, left = 0 },
  })

  -- Section 1: Object-Fit Modes
  local fitSection = FlexLove.new({
    parent = container,
    width = "100%",
    flexDirection = "vertical",
    gap = 10,
  })

  FlexLove.new({
    parent = fitSection,
    text = "Object-Fit Modes",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
    textWrap = "word",
    width = "100%",
    z = 1000,
    padding = { top = 5, right = 0, bottom = 5, left = 0 },
  })

  local fitRow = FlexLove.new({
    parent = fitSection,
    width = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    justifyContent = "space-between",
    alignItems = "flex-start",
    padding = { top = 30 },
  })

  local fitModes = { "fill", "contain", "cover", "scale-down", "none" }
  local fitSizes = {
    { width = 200, height = 140, imgWidth = 180, imgHeight = 100 },
    { width = 160, height = 120, imgWidth = 140, imgHeight = 80 },
    { width = 220, height = 160, imgWidth = 200, imgHeight = 120 },
    { width = 180, height = 130, imgWidth = 160, imgHeight = 90 },
    { width = 190, height = 150, imgWidth = 170, imgHeight = 110 },
  }

  for i, mode in ipairs(fitModes) do
    local size = fitSizes[i]
    local fitBox = FlexLove.new({
      parent = fitRow,
      width = size.width,
      height = size.height,
      positioning = "flex",
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    FlexLove.new({
      parent = fitBox,
      width = size.imgWidth,
      height = size.imgHeight,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      imagePath = "sample.jpg",
      objectFit = mode,
    })

    FlexLove.new({
      parent = fitBox,
      text = mode,
      textSize = "sm",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
      textWrap = "word",
      width = "100%",
      z = 1000,
      padding = { top = 3, right = 0, bottom = 3, left = 0 },
    })
  end

  -- Section 2: Object-Position
  local posSection = FlexLove.new({
    parent = container,
    width = "100%",
    flexDirection = "vertical",
    gap = 10,
  })

  FlexLove.new({
    parent = posSection,
    text = "Object-Position",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
    textWrap = "word",
    width = "100%",
    z = 1000,
    padding = { top = 5, right = 0, bottom = 5, left = 0 },
  })

  local posRow = FlexLove.new({
    parent = posSection,
    width = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    justifyContent = "space-between",
    alignItems = "flex-start",
    padding = { top = 30 },
  })

  local positions = { "top left", "center center", "bottom right", "50% 20%", "left center" }
  local posSizes = {
    { width = 170, height = 130, imgWidth = 150, imgHeight = 90 },
    { width = 210, height = 150, imgWidth = 190, imgHeight = 110 },
    { width = 180, height = 140, imgWidth = 160, imgHeight = 100 },
    { width = 195, height = 135, imgWidth = 175, imgHeight = 95 },
    { width = 185, height = 145, imgWidth = 165, imgHeight = 105 },
  }

  for i, pos in ipairs(positions) do
    local size = posSizes[i]
    local posBox = FlexLove.new({
      parent = posRow,
      width = size.width,
      height = size.height,
      positioning = "flex",
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    FlexLove.new({
      parent = posBox,
      width = size.imgWidth,
      height = size.imgHeight,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      imagePath = "sample.jpg",
      objectFit = "none",
      objectPosition = pos,
    })

    FlexLove.new({
      parent = posBox,
      text = pos,
      textSize = "xs",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
      textWrap = "word",
      width = "100%",
      z = 1000,
      padding = { top = 3, right = 0, bottom = 3, left = 0 },
    })
  end

  -- Section 3: Image Tiling/Repeat
  local tileSection = FlexLove.new({
    parent = container,
    width = "100%",
    flexDirection = "vertical",
    gap = 10,
  })

  FlexLove.new({
    parent = tileSection,
    text = "Image Tiling (Repeat Modes)",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
    textWrap = "word",
    width = "100%",
    z = 1000,
    padding = { top = 5, right = 0, bottom = 5, left = 0 },
  })

  local tileRow = FlexLove.new({
    parent = tileSection,
    width = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 20,
    justifyContent = "space-between",
    alignItems = "flex-start",
    padding = { top = 30 },
  })

  local repeatModes = { "no-repeat", "repeat", "repeat-x", "repeat-y" }
  local tileSizes = {
    { width = 260, height = 140, imgWidth = 240, imgHeight = 100 },
    { width = 240, height = 130, imgWidth = 220, imgHeight = 90 },
    { width = 280, height = 150, imgWidth = 260, imgHeight = 110 },
    { width = 250, height = 135, imgWidth = 230, imgHeight = 95 },
  }

  for i, mode in ipairs(repeatModes) do
    local size = tileSizes[i]
    local tileBox = FlexLove.new({
      parent = tileRow,
      width = size.width,
      height = size.height,
      positioning = "flex",
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    FlexLove.new({
      parent = tileBox,
      width = size.imgWidth,
      height = size.imgHeight,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      imagePath = "sample.jpg",
      imageRepeat = mode,
    })

    FlexLove.new({
      parent = tileBox,
      text = mode,
      textSize = "sm",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
      textWrap = "word",
      width = "100%",
      z = 1000,
      padding = { top = 3, right = 0, bottom = 3, left = 0 },
    })
  end

  -- Section 4: Image Tinting and Opacity
  local tintSection = FlexLove.new({
    parent = container,
    width = "100%",
    flexDirection = "vertical",
    gap = 10,
  })

  FlexLove.new({
    parent = tintSection,
    text = "Image Tinting & Opacity",
    textSize = "lg",
    textColor = Color.new(0.3, 0.3, 0.3, 1),
    textWrap = "word",
    width = "100%",
    z = 1000,
    padding = { top = 5, right = 0, bottom = 5, left = 0 },
  })

  local tintRow = FlexLove.new({
    parent = tintSection,
    width = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 15,
    justifyContent = "space-between",
    alignItems = "flex-start",
    padding = { top = 30 },
  })

  local tints = {
    { name = "No Tint", color = nil, opacity = 1 },
    { name = "Red Tint", color = Color.new(1, 0.5, 0.5, 1), opacity = 1 },
    { name = "Blue Tint", color = Color.new(0.5, 0.5, 1, 1), opacity = 1 },
    { name = "50% Opacity", color = nil, opacity = 0.5 },
    { name = "Green + 70%", color = Color.new(0.5, 1, 0.5, 1), opacity = 0.7 },
  }

  local tintSizes = {
    { width = 185, height = 135, imgWidth = 165, imgHeight = 95 },
    { width = 200, height = 145, imgWidth = 180, imgHeight = 105 },
    { width = 175, height = 130, imgWidth = 155, imgHeight = 90 },
    { width = 195, height = 140, imgWidth = 175, imgHeight = 100 },
    { width = 190, height = 150, imgWidth = 170, imgHeight = 110 },
  }

  for i, tint in ipairs(tints) do
    local size = tintSizes[i]
    local tintBox = FlexLove.new({
      parent = tintRow,
      width = size.width,
      height = size.height,
      positioning = "flex",
      flexDirection = "vertical",
      gap = 5,
      backgroundColor = Color.new(1, 1, 1, 1),
      cornerRadius = 8,
      padding = { top = 10, right = 10, bottom = 10, left = 10 },
    })

    FlexLove.new({
      parent = tintBox,
      width = size.imgWidth,
      height = size.imgHeight,
      backgroundColor = Color.new(0.9, 0.9, 0.9, 1),
      imagePath = "sample.jpg",
      imageTint = tint.color,
      imageOpacity = tint.opacity,
    })

    FlexLove.new({
      parent = tintBox,
      text = tint.name,
      textSize = "xs",
      textColor = Color.new(0.4, 0.4, 0.4, 1),
      textAlign = "center",
      textWrap = "word",
      width = "100%",
      z = 1000,
      padding = { top = 3, right = 0, bottom = 3, left = 0 },
    })
  end

  -- Footer note
  FlexLove.new({
    parent = container,
    text = "Image showcase demonstrating various FlexLove image properties",
    textSize = "xs",
    textColor = Color.new(0.5, 0.5, 0.5, 1),
    textAlign = "center",
    textWrap = "word",
    width = "100%",
    z = 1000,
    padding = { top = 10, right = 0, bottom = 10, left = 0 },
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
