--[[
  FlexLove Example 01: Flex Positioning

  This example demonstrates flexbox layouts in FlexLove:
  - Flex direction (horizontal/vertical)
  - Justify content (main axis alignment)
  - Align items (cross axis alignment)
  - Flex wrap behavior

  Run with: love /path/to/libs/examples/01_flex_positioning.lua
]]

-- Map Love to Lv to avoid duplicate definitions
local Lv = love

-- Load FlexLove from parent directory
local FlexLove = require("../FlexLove")
local Color = FlexLove.Color
local enums = FlexLove.enums

function Lv.load()
  -- Initialize FlexLove with base scaling
  FlexLove.init({
    baseScale = { width = 1920, height = 1080 },
  })

  -- Title
  FlexLove.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 01: Flex Positioning",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })

  -- ========================================
  -- Section 1: Horizontal Flex with Different JustifyContent Values
  -- ========================================

  local yOffset = 10

  -- Label for justify-content section
  FlexLove.new({
    x = "2vw",
    y = yOffset .. "vh",
    width = "96vw",
    height = "3vh",
    text = "Horizontal Flex - JustifyContent Options",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })

  yOffset = yOffset + 4

  -- Demonstrate each justify-content option
  local justifyOptions = {
    { name = "flex-start", value = enums.JustifyContent.FLEX_START },
    { name = "center", value = enums.JustifyContent.CENTER },
    { name = "flex-end", value = enums.JustifyContent.FLEX_END },
    { name = "space-between", value = enums.JustifyContent.SPACE_BETWEEN },
    { name = "space-around", value = enums.JustifyContent.SPACE_AROUND },
    { name = "space-evenly", value = enums.JustifyContent.SPACE_EVENLY },
  }

  for _, option in ipairs(justifyOptions) do
    -- Label for this justify option
    FlexLove.new({
      x = "2vw",
      y = yOffset .. "vh",
      width = "15vw",
      height = "3vh",
      text = option.name,
      textSize = "1.8vh",
      textColor = Color.new(0.8, 0.8, 1, 1),
      textAlign = enums.TextAlign.START,
    })

    -- Container demonstrating this justify-content value
    local container = FlexLove.new({
      x = "18vw",
      y = yOffset .. "vh",
      width = "78vw",
      height = "8vh",
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.HORIZONTAL,
      justifyContent = option.value,
      alignItems = enums.AlignItems.CENTER,
      backgroundColor = Color.new(0.15, 0.15, 0.2, 1),
      border = { top = true, right = true, bottom = true, left = true },
      borderColor = Color.new(0.3, 0.3, 0.4, 1),
    })

    -- Add child elements
    local colors = {
      Color.new(0.8, 0.3, 0.3, 1),
      Color.new(0.3, 0.8, 0.3, 1),
      Color.new(0.3, 0.3, 0.8, 1),
      Color.new(0.8, 0.8, 0.3, 1),
    }

    for j = 1, 4 do
      FlexLove.new({
        parent = container,
        width = "8vw",
        height = "5vh",
        backgroundColor = colors[j],
        text = tostring(j),
        textSize = "2vh",
        textColor = Color.new(1, 1, 1, 1),
        textAlign = enums.TextAlign.CENTER,
      })
    end

    yOffset = yOffset + 9
  end

  -- ========================================
  -- Section 2: Vertical Flex with Different AlignItems Values
  -- ========================================

  yOffset = yOffset + 2

  -- Label for align-items section
  FlexLove.new({
    x = "2vw",
    y = yOffset .. "vh",
    width = "96vw",
    height = "3vh",
    text = "Vertical Flex - AlignItems Options",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })

  yOffset = yOffset + 4

  -- Note: Due to space constraints, we'll show a subset in a horizontal layout
  local alignOptions = {
    { name = "stretch", value = enums.AlignItems.STRETCH },
    { name = "flex-start", value = enums.AlignItems.FLEX_START },
    { name = "center", value = enums.AlignItems.CENTER },
    { name = "flex-end", value = enums.AlignItems.FLEX_END },
  }

  local xOffset = 2
  local containerWidth = 22

  for _, option in ipairs(alignOptions) do
    -- Label for this align option
    FlexLove.new({
      x = xOffset .. "vw",
      y = yOffset .. "vh",
      width = containerWidth .. "vw",
      height = "2.5vh",
      text = option.name,
      textSize = "1.8vh",
      textColor = Color.new(0.8, 1, 0.8, 1),
      textAlign = enums.TextAlign.CENTER,
    })

    -- Container demonstrating this align-items value
    local container = FlexLove.new({
      x = xOffset .. "vw",
      y = (yOffset + 3) .. "vh",
      width = containerWidth .. "vw",
      height = "20vh",
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.VERTICAL,
      justifyContent = enums.JustifyContent.FLEX_START,
      alignItems = option.value,
      gap = 5,
      backgroundColor = Color.new(0.15, 0.2, 0.15, 1),
      border = { top = true, right = true, bottom = true, left = true },
      borderColor = Color.new(0.3, 0.4, 0.3, 1),
    })

    -- Add child elements with varying widths
    local widths = { "8vw", "12vw", "6vw" }
    local colors = {
      Color.new(0.9, 0.4, 0.4, 1),
      Color.new(0.4, 0.9, 0.4, 1),
      Color.new(0.4, 0.4, 0.9, 1),
    }

    for j = 1, 3 do
      FlexLove.new({
        parent = container,
        width = option.value == enums.AlignItems.STRETCH and "auto" or widths[j],
        height = "4vh",
        backgroundColor = colors[j],
        text = tostring(j),
        textSize = "1.8vh",
        textColor = Color.new(1, 1, 1, 1),
        textAlign = enums.TextAlign.CENTER,
      })
    end

    xOffset = xOffset + containerWidth + 2
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
