-- Stub implementations for LOVE functions to enable testing of FlexLove
-- This file provides mock implementations of LOVE functions used in FlexLove

local love_helper = {}

-- Mock window functions
love_helper.window = {}
function love_helper.window.getMode()
  return 800, 600 -- Default resolution
end

-- Mock graphics functions
love_helper.graphics = {}
function love_helper.graphics.newFont(size)
  -- Return a mock font object with basic methods
  return {
    getWidth = function(text)
      return #text * size / 2
    end,
    getHeight = function()
      return size
    end,
  }
end

function love_helper.graphics.getFont()
  -- Return a mock default font
  return {
    getWidth = function(text)
      return #text * 12 / 2
    end,
    getHeight = function()
      return 12
    end,
  }
end

function love_helper.graphics.setColor(r, g, b, a)
  -- Mock color setting
end

function love_helper.graphics.rectangle(mode, x, y, width, height)
  -- Mock rectangle drawing
end

function love_helper.graphics.line(x1, y1, x2, y2)
  -- Mock line drawing
end

function love_helper.graphics.print(text, x, y)
  -- Mock text printing
end

-- Mock mouse functions
love_helper.mouse = {}
function love_helper.mouse.getPosition()
  return 0, 0 -- Default position
end

function love_helper.mouse.isDown(button)
  return false -- Default not pressed
end

-- Mock touch functions
love_helper.touch = {}
function love_helper.touch.getTouches()
  return {} -- Empty table of touches
end

function love_helper.touch.getPosition(id)
  return 0, 0 -- Default touch position
end

_G.love = love_helper
return love_helper
