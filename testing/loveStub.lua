-- Stub implementations for LOVE functions to enable testing of FlexLove
-- This file provides mock implementations of LOVE functions used in FlexLove

local love_helper = {}

-- Mock window state
local mockWindowWidth = 800
local mockWindowHeight = 600

-- Mock window functions
love_helper.window = {}
function love_helper.window.getMode()
  return mockWindowWidth, mockWindowHeight
end

function love_helper.window.setMode(width, height)
  mockWindowWidth = width
  mockWindowHeight = height
  return true
end

-- Mock graphics functions
love_helper.graphics = {}

function love_helper.graphics.getDimensions()
  return mockWindowWidth, mockWindowHeight
end

function love_helper.graphics.newFont(size)
  -- Ensure size is a number
  local fontSize = tonumber(size) or 12
  -- Return a mock font object with basic methods
  return {
    getWidth = function(self, text)
      -- Handle both colon and dot syntax
      if type(self) == "string" then
        -- Called with dot syntax: font.getWidth(text)
        return #self * fontSize / 2
      else
        -- Called with colon syntax: font:getWidth(text)
        return #text * fontSize / 2
      end
    end,
    getHeight = function()
      return fontSize
    end,
  }
end

function love_helper.graphics.getFont()
  -- Return a mock default font
  return {
    getWidth = function(self, text)
      -- Handle both colon and dot syntax
      if type(self) == "string" then
        -- Called with dot syntax: font.getWidth(text)
        return #self * 12 / 2
      else
        -- Called with colon syntax: font:getWidth(text)
        return #text * 12 / 2
      end
    end,
    getHeight = function()
      return 12
    end,
  }
end

function love_helper.graphics.setColor(r, g, b, a)
  -- Mock color setting
end

function love_helper.graphics.setFont(font)
  -- Mock font setting
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

-- Mock mouse state
local mockMouseX = 0
local mockMouseY = 0
local mockMouseButtons = {} -- Table to track button states

function love_helper.mouse.getPosition()
  return mockMouseX, mockMouseY
end

function love_helper.mouse.setPosition(x, y)
  mockMouseX = x
  mockMouseY = y
end

function love_helper.mouse.isDown(button)
  return mockMouseButtons[button] or false
end

function love_helper.mouse.setDown(button, isDown)
  mockMouseButtons[button] = isDown
end

-- Mock timer functions
love_helper.timer = {}

-- Mock time state
local mockTime = 0

function love_helper.timer.getTime()
  return mockTime
end

function love_helper.timer.setTime(time)
  mockTime = time
end

function love_helper.timer.step(dt)
  mockTime = mockTime + dt
end

-- Mock keyboard functions
love_helper.keyboard = {}

-- Mock keyboard state
local mockKeyboardKeys = {} -- Table to track key states

function love_helper.keyboard.isDown(key)
  return mockKeyboardKeys[key] or false
end

function love_helper.keyboard.setDown(key, isDown)
  mockKeyboardKeys[key] = isDown
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
