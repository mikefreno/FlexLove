-- Example: Varying Border Widths
-- Demonstrates how to use different border widths on each side of an element

local FlexLove = require("FlexLove")

function love.load()
  FlexLove.init({
    baseScale = { width = 1920, height = 1080 },
  })

  -- Example 1: Different width on each side
  FlexLove.Element.new({
    x = 50,
    y = 50,
    width = 200,
    height = 150,
    backgroundColor = FlexLove.Color.new(0.95, 0.95, 0.95, 1),
    border = {
      top = 1,    -- Thin top border
      right = 2,  -- Medium right border
      bottom = 3, -- Thick bottom border
      left = 4,   -- Very thick left border
    },
    borderColor = FlexLove.Color.new(0.2, 0.4, 0.8, 1),
    text = "Different width\non each side",
    textSize = 16,
    textAlign = "center",
    padding = 20,
  })

  -- Example 2: Using boolean values (true = 1px)
  FlexLove.Element.new({
    x = 300,
    y = 50,
    width = 200,
    height = 150,
    backgroundColor = FlexLove.Color.new(0.95, 0.95, 0.95, 1),
    border = {
      top = true,   -- true becomes 1px
      right = 8,    -- Thick border
      bottom = true,-- true becomes 1px
      left = false, -- No border
    },
    borderColor = FlexLove.Color.new(0.8, 0.2, 0.2, 1),
    text = "Boolean borders\ntrue = 1px\nfalse = none",
    textSize = 16,
    textAlign = "center",
    padding = 20,
  })

  -- Example 3: Uniform border with single number
  FlexLove.Element.new({
    x = 550,
    y = 50,
    width = 200,
    height = 150,
    backgroundColor = FlexLove.Color.new(0.95, 0.95, 0.95, 1),
    border = 5, -- All sides 5px
    borderColor = FlexLove.Color.new(0.2, 0.8, 0.2, 1),
    cornerRadius = 10,
    text = "Uniform 5px\nall around\nwith rounded\ncorners",
    textSize = 16,
    textAlign = "center",
    padding = 20,
  })

  -- Example 4: Decorative card with emphasis on one side
  FlexLove.Element.new({
    x = 50,
    y = 250,
    width = 700,
    height = 100,
    backgroundColor = FlexLove.Color.new(1, 1, 1, 1),
    border = {
      top = 1,
      right = 1,
      bottom = 1,
      left = 8, -- Thick accent border on left
    },
    borderColor = FlexLove.Color.new(0.9, 0.5, 0.1, 1),
    text = "Card with accent border on the left side",
    textSize = 18,
    padding = { left = 20, top = 10, right = 10, bottom = 10 },
  })

  -- Instructions
  FlexLove.Element.new({
    x = 50,
    y = 400,
    width = 700,
    height = "auto",
    backgroundColor = FlexLove.Color.new(0.1, 0.1, 0.1, 0.8),
    text = "Border Width Options:\n• Use numbers for specific pixel widths (1, 2, 3, etc.)\n• Use true for 1px border\n• Use false for no border\n• Use a single number for uniform borders on all sides\n• Combine with cornerRadius for rounded uniform borders",
    textSize = 14,
    textColor = FlexLove.Color.new(1, 1, 1, 1),
    padding = 20,
    cornerRadius = 5,
  })
end

function love.draw()
  love.graphics.clear(0.15, 0.15, 0.2, 1)
  FlexLove.draw()
end

function love.update(dt)
  FlexLove.update(dt)
end

function love.mousepressed(x, y, button)
  FlexLove.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  FlexLove.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  FlexLove.mousemoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
  FlexLove.wheelmoved(x, y)
end
