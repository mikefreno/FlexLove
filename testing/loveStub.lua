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

function love_helper.graphics.polygon(mode, ...)
  -- Mock polygon drawing
end

function love_helper.graphics.print(text, x, y)
  -- Mock text printing
end

function love_helper.graphics.newShader(shaderCode)
  -- Mock shader creation - return a mock shader object
  return {
    send = function(self, name, value)
      -- Mock shader uniform setting
    end,
  }
end

function love_helper.graphics.newCanvas(width, height)
  -- Mock canvas creation
  return {
    getDimensions = function()
      return width or mockWindowWidth, height or mockWindowHeight
    end,
    release = function()
      -- Mock canvas release
    end,
  }
end

function love_helper.graphics.setCanvas(canvas)
  -- Mock canvas setting
end

function love_helper.graphics.getCanvas()
  -- Mock getting current canvas
  return nil
end

function love_helper.graphics.clear()
  -- Mock clear
end

function love_helper.graphics.draw(drawable, x, y, r, sx, sy)
  -- Mock draw
end

function love_helper.graphics.setShader(shader)
  -- Mock shader setting
end

function love_helper.graphics.getShader()
  -- Mock getting current shader
  return nil
end

function love_helper.graphics.setBlendMode(mode, alphamode)
  -- Mock blend mode setting
end

function love_helper.graphics.getBlendMode()
  -- Mock getting blend mode
  return "alpha", "alphamultiply"
end

function love_helper.graphics.getColor()
  -- Mock getting color
  return 1, 1, 1, 1
end

function love_helper.graphics.push()
  -- Mock graphics state push
end

function love_helper.graphics.pop()
  -- Mock graphics state pop
end

function love_helper.graphics.origin()
  -- Mock origin reset
end

function love_helper.graphics.translate(x, y)
  -- Mock translate
end

function love_helper.graphics.rotate(angle)
  -- Mock rotate
end

function love_helper.graphics.scale(sx, sy)
  -- Mock scale
end

function love_helper.graphics.shear(kx, ky)
  -- Mock shear
end

function love_helper.graphics.newQuad(x, y, width, height, sw, sh)
  -- Mock quad creation
  return {
    x = x,
    y = y,
    width = width,
    height = height,
    sw = sw,
    sh = sh,
  }
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

function love_helper.keyboard.isDown(...)
  local keys = {...}
  for _, key in ipairs(keys) do
    if mockKeyboardKeys[key] then
      return true
    end
  end
  return false
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

-- Mock image functions
love_helper.image = {}

-- Mock ImageData object
local ImageData = {}
ImageData.__index = ImageData

function ImageData.new(width, height)
  local self = setmetatable({}, ImageData)
  self.width = width
  self.height = height
  -- Store pixel data as a 2D array [y][x] = {r, g, b, a}
  self.pixels = {}
  for y = 0, height - 1 do
    self.pixels[y] = {}
    for x = 0, width - 1 do
      self.pixels[y][x] = {0, 0, 0, 0} -- Default to transparent black
    end
  end
  return self
end

function ImageData:getWidth()
  return self.width
end

function ImageData:getHeight()
  return self.height
end

function ImageData:setPixel(x, y, r, g, b, a)
  if x >= 0 and x < self.width and y >= 0 and y < self.height then
    self.pixels[y][x] = {r, g, b, a or 1}
  end
end

function ImageData:getPixel(x, y)
  if x >= 0 and x < self.width and y >= 0 and y < self.height then
    local pixel = self.pixels[y][x]
    return pixel[1], pixel[2], pixel[3], pixel[4]
  end
  return 0, 0, 0, 0
end

function ImageData:encode(format, filename)
  -- Mock encode - just return success
  return true
end

function ImageData:release()
  -- Mock release
end

function love_helper.image.newImageData(width, height)
  return ImageData.new(width, height)
end

-- Mock Image object
local Image = {}
Image.__index = Image

function Image.new(imageData)
  local self = setmetatable({}, Image)
  self.imageData = imageData
  self.width = imageData and imageData.width or 100
  self.height = imageData and imageData.height or 100
  return self
end

function Image:getDimensions()
  return self.width, self.height
end

function Image:getWidth()
  return self.width
end

function Image:getHeight()
  return self.height
end

function Image:release()
  -- Mock release
end

function love_helper.graphics.newImage(source)
  -- If source is ImageData, create Image from it
  if type(source) == "table" and source.width and source.height then
    return Image.new(source)
  end
  -- If source is a string (path), check if file exists in mock filesystem
  if type(source) == "string" then
    local fileInfo = love_helper.filesystem.getInfo(source)
    if fileInfo then
      -- File exists in mock filesystem, create image with default dimensions
      return Image.new(ImageData.new(100, 100))
    else
      -- File doesn't exist, throw error like real LÖVE would
      error("Could not open file " .. source)
    end
  end
  -- Default
  return Image.new(ImageData.new(100, 100))
end

function love_helper.graphics.stencil(func, action, value)
  -- Mock stencil function - just call the function
  if func then
    func()
  end
end

function love_helper.graphics.setStencilTest(comparemode, comparevalue)
  -- Mock stencil test setting
end

-- Mock filesystem functions
love_helper.filesystem = {}

-- Mock filesystem state
local mockFiles = {}

function love_helper.filesystem.getInfo(path)
  -- Check if file exists in mock filesystem
  if mockFiles[path] then
    return {
      type = "file",
      size = mockFiles[path].size or 0,
    }
  end
  return nil
end

function love_helper.filesystem.write(path, data)
  -- Mock write to filesystem
  mockFiles[path] = {
    data = data,
    size = #data,
  }
  return true
end

function love_helper.filesystem.read(path)
  -- Mock read from filesystem
  if mockFiles[path] then
    return mockFiles[path].data, nil
  end
  return nil, "File not found"
end

function love_helper.filesystem.remove(path)
  -- Mock remove from filesystem
  if mockFiles[path] then
    mockFiles[path] = nil
    return true
  end
  return false
end

-- Helper to add mock files for testing
function love_helper.filesystem.addMockFile(path, data)
  mockFiles[path] = {
    data = data or "",
    size = data and #data or 0,
  }
end

-- Mock system clipboard
love_helper.system = {}
local mockClipboard = ""

function love_helper.system.getClipboardText()
  return mockClipboard
end

function love_helper.system.setClipboardText(text)
  mockClipboard = text or ""
end

_G.love = love_helper
return love_helper
