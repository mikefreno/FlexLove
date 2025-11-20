-- Image Tiling Tests
-- Tests for ImageRenderer tiling functionality

local luaunit = require("testing.luaunit")
require("testing.loveStub")

local ImageRenderer = require("modules.ImageRenderer")
local ErrorHandler = require("modules.ErrorHandler")
local Color = require("modules.Color")
local utils = require("modules.utils")

-- Initialize ImageRenderer with ErrorHandler and utils
ImageRenderer.init({ ErrorHandler = ErrorHandler, utils = utils })

TestImageTiling = {}

function TestImageTiling:setUp()
  -- Create a mock image
  self.mockImage = {
    getDimensions = function()
      return 64, 64
    end,
    type = function()
      return "Image"
    end,
  }
end

function TestImageTiling:tearDown()
  self.mockImage = nil
end

function TestImageTiling:testDrawTiledNoRepeat()
  -- Test no-repeat mode (single image)
  local drawCalls = {}
  local originalDraw = love.graphics.draw
  love.graphics.draw = function(...)
    table.insert(drawCalls, { ... })
  end

  ImageRenderer.drawTiled(self.mockImage, 100, 100, 200, 200, "no-repeat", 1, nil)

  -- Should draw once
  luaunit.assertEquals(#drawCalls, 1)
  luaunit.assertEquals(drawCalls[1][1], self.mockImage)
  luaunit.assertEquals(drawCalls[1][2], 100)
  luaunit.assertEquals(drawCalls[1][3], 100)

  love.graphics.draw = originalDraw
end

function TestImageTiling:testDrawTiledRepeat()
  -- Test repeat mode (tiles in both directions)
  local drawCalls = {}
  local originalDraw = love.graphics.draw
  local originalNewQuad = love.graphics.newQuad

  love.graphics.draw = function(...)
    table.insert(drawCalls, { ... })
  end

  love.graphics.newQuad = function(...)
    return { type = "quad", ... }
  end

  -- Image is 64x64, bounds are 200x200
  -- Should tile 4 times (4 tiles total: 2x2 with partials)
  ImageRenderer.drawTiled(self.mockImage, 100, 100, 200, 200, "repeat", 1, nil)

  -- 4 tiles: (0,0), (64,0), (0,64), (64,64)
  -- 2 full tiles + 2 partial tiles = 4 draws
  luaunit.assertTrue(#drawCalls >= 4)

  love.graphics.draw = originalDraw
  love.graphics.newQuad = originalNewQuad
end

function TestImageTiling:testDrawTiledRepeatX()
  -- Test repeat-x mode (tiles horizontally only)
  local drawCalls = {}
  local originalDraw = love.graphics.draw
  local originalNewQuad = love.graphics.newQuad

  love.graphics.draw = function(...)
    table.insert(drawCalls, { ... })
  end

  love.graphics.newQuad = function(...)
    return { type = "quad", ... }
  end

  -- Image is 64x64, bounds are 200x64
  -- Should tile 4 times horizontally: (0), (64), (128), (192)
  ImageRenderer.drawTiled(self.mockImage, 100, 100, 200, 64, "repeat-x", 1, nil)

  -- 3 full tiles + 1 partial tile = 4 draws
  luaunit.assertTrue(#drawCalls >= 3)

  love.graphics.draw = originalDraw
  love.graphics.newQuad = originalNewQuad
end

function TestImageTiling:testDrawTiledRepeatY()
  -- Test repeat-y mode (tiles vertically only)
  local drawCalls = {}
  local originalDraw = love.graphics.draw
  local originalNewQuad = love.graphics.newQuad

  love.graphics.draw = function(...)
    table.insert(drawCalls, { ... })
  end

  love.graphics.newQuad = function(...)
    return { type = "quad", ... }
  end

  -- Image is 64x64, bounds are 64x200
  -- Should tile 4 times vertically
  ImageRenderer.drawTiled(self.mockImage, 100, 100, 64, 200, "repeat-y", 1, nil)

  -- 3 full tiles + 1 partial tile = 4 draws
  luaunit.assertTrue(#drawCalls >= 3)

  love.graphics.draw = originalDraw
  love.graphics.newQuad = originalNewQuad
end

function TestImageTiling:testDrawTiledSpace()
  -- Test space mode (distributes tiles with even spacing)
  local drawCalls = {}
  local originalDraw = love.graphics.draw

  love.graphics.draw = function(...)
    table.insert(drawCalls, { ... })
  end

  -- Image is 64x64, bounds are 200x200
  ImageRenderer.drawTiled(self.mockImage, 100, 100, 200, 200, "space", 1, nil)

  -- Should draw multiple tiles with spacing
  luaunit.assertTrue(#drawCalls > 1)

  love.graphics.draw = originalDraw
end

function TestImageTiling:testDrawTiledRound()
  -- Test round mode (scales tiles to fit exactly)
  local drawCalls = {}
  local originalDraw = love.graphics.draw

  love.graphics.draw = function(...)
    table.insert(drawCalls, { ... })
  end

  -- Image is 64x64, bounds are 200x200
  ImageRenderer.drawTiled(self.mockImage, 100, 100, 200, 200, "round", 1, nil)

  -- Should draw tiles with scaling
  luaunit.assertTrue(#drawCalls > 1)

  love.graphics.draw = originalDraw
end

function TestImageTiling:testDrawTiledWithOpacity()
  -- Test tiling with opacity
  local setColorCalls = {}
  local originalSetColor = love.graphics.setColor

  love.graphics.setColor = function(...)
    table.insert(setColorCalls, { ... })
  end

  ImageRenderer.drawTiled(self.mockImage, 100, 100, 200, 200, "no-repeat", 0.5, nil)

  -- Should set color with opacity
  luaunit.assertTrue(#setColorCalls > 0)
  -- Check that opacity 0.5 was used
  local found = false
  for _, call in ipairs(setColorCalls) do
    if call[4] == 0.5 then
      found = true
      break
    end
  end
  luaunit.assertTrue(found)

  love.graphics.setColor = originalSetColor
end

function TestImageTiling:testDrawTiledWithTint()
  -- Test tiling with tint color
  local setColorCalls = {}
  local originalSetColor = love.graphics.setColor

  love.graphics.setColor = function(...)
    table.insert(setColorCalls, { ... })
  end

  local redTint = Color.new(1, 0, 0, 1)
  ImageRenderer.drawTiled(self.mockImage, 100, 100, 200, 200, "no-repeat", 1, redTint)

  -- Should set color with tint
  luaunit.assertTrue(#setColorCalls > 0)
  -- Check that red tint was used (r=1, g=0, b=0)
  local found = false
  for _, call in ipairs(setColorCalls) do
    if call[1] == 1 and call[2] == 0 and call[3] == 0 then
      found = true
      break
    end
  end
  luaunit.assertTrue(found)

  love.graphics.setColor = originalSetColor
end

function TestImageTiling:testElementImageRepeatProperty()
  -- Test that Element accepts imageRepeat property
  local Element = require("modules.Element")
  local utils = require("modules.utils")
  local Color = require("modules.Color")
  local Units = require("modules.Units")
  local LayoutEngine = require("modules.LayoutEngine")
  local Renderer = require("modules.Renderer")
  local EventHandler = require("modules.EventHandler")
  local ImageCache = require("modules.ImageCache")

  local deps = {
    utils = utils,
    Color = Color,
    Units = Units,
    LayoutEngine = LayoutEngine,
    Renderer = Renderer,
    EventHandler = EventHandler,
    ImageCache = ImageCache,
    ImageRenderer = ImageRenderer,
    ErrorHandler = ErrorHandler,
  }

  local element = Element.new({
    width = 200,
    height = 200,
    imageRepeat = "repeat",
  }, deps)

  luaunit.assertEquals(element.imageRepeat, "repeat")
end

function TestImageTiling:testElementImageRepeatDefault()
  -- Test that imageRepeat defaults to "no-repeat"
  local Element = require("modules.Element")
  local utils = require("modules.utils")
  local Color = require("modules.Color")
  local Units = require("modules.Units")
  local LayoutEngine = require("modules.LayoutEngine")
  local Renderer = require("modules.Renderer")
  local EventHandler = require("modules.EventHandler")
  local ImageCache = require("modules.ImageCache")

  local deps = {
    utils = utils,
    Color = Color,
    Units = Units,
    LayoutEngine = LayoutEngine,
    Renderer = Renderer,
    EventHandler = EventHandler,
    ImageCache = ImageCache,
    ImageRenderer = ImageRenderer,
    ErrorHandler = ErrorHandler,
  }

  local element = Element.new({
    width = 200,
    height = 200,
  }, deps)

  luaunit.assertEquals(element.imageRepeat, "no-repeat")
end

function TestImageTiling:testElementSetImageRepeat()
  -- Test setImageRepeat method
  local Element = require("modules.Element")
  local utils = require("modules.utils")
  local Color = require("modules.Color")
  local Units = require("modules.Units")
  local LayoutEngine = require("modules.LayoutEngine")
  local Renderer = require("modules.Renderer")
  local EventHandler = require("modules.EventHandler")
  local ImageCache = require("modules.ImageCache")

  local deps = {
    utils = utils,
    Color = Color,
    Units = Units,
    LayoutEngine = LayoutEngine,
    Renderer = Renderer,
    EventHandler = EventHandler,
    ImageCache = ImageCache,
    ImageRenderer = ImageRenderer,
    ErrorHandler = ErrorHandler,
  }

  local element = Element.new({
    width = 200,
    height = 200,
  }, deps)

  element:setImageRepeat("repeat-x")
  luaunit.assertEquals(element.imageRepeat, "repeat-x")
end

function TestImageTiling:testElementImageTintProperty()
  -- Test that Element accepts imageTint property
  local Element = require("modules.Element")
  local utils = require("modules.utils")
  local Units = require("modules.Units")
  local LayoutEngine = require("modules.LayoutEngine")
  local Renderer = require("modules.Renderer")
  local EventHandler = require("modules.EventHandler")
  local ImageCache = require("modules.ImageCache")

  local redTint = Color.new(1, 0, 0, 1)

  local deps = {
    utils = utils,
    Color = Color,
    Units = Units,
    LayoutEngine = LayoutEngine,
    Renderer = Renderer,
    EventHandler = EventHandler,
    ImageCache = ImageCache,
    ImageRenderer = ImageRenderer,
    ErrorHandler = ErrorHandler,
  }

  local element = Element.new({
    width = 200,
    height = 200,
    imageTint = redTint,
  }, deps)

  luaunit.assertEquals(element.imageTint, redTint)
end

function TestImageTiling:testElementSetImageTint()
  -- Test setImageTint method
  local Element = require("modules.Element")
  local utils = require("modules.utils")
  local Units = require("modules.Units")
  local LayoutEngine = require("modules.LayoutEngine")
  local Renderer = require("modules.Renderer")
  local EventHandler = require("modules.EventHandler")
  local ImageCache = require("modules.ImageCache")

  local deps = {
    utils = utils,
    Color = Color,
    Units = Units,
    LayoutEngine = LayoutEngine,
    Renderer = Renderer,
    EventHandler = EventHandler,
    ImageCache = ImageCache,
    ImageRenderer = ImageRenderer,
    ErrorHandler = ErrorHandler,
  }

  local element = Element.new({
    width = 200,
    height = 200,
  }, deps)

  local blueTint = Color.new(0, 0, 1, 1)
  element:setImageTint(blueTint)
  luaunit.assertEquals(element.imageTint, blueTint)
end

function TestImageTiling:testElementSetImageOpacity()
  -- Test setImageOpacity method
  local Element = require("modules.Element")
  local utils = require("modules.utils")
  local Color = require("modules.Color")
  local Units = require("modules.Units")
  local LayoutEngine = require("modules.LayoutEngine")
  local Renderer = require("modules.Renderer")
  local EventHandler = require("modules.EventHandler")
  local ImageCache = require("modules.ImageCache")

  local deps = {
    utils = utils,
    Color = Color,
    Units = Units,
    LayoutEngine = LayoutEngine,
    Renderer = Renderer,
    EventHandler = EventHandler,
    ImageCache = ImageCache,
    ImageRenderer = ImageRenderer,
    ErrorHandler = ErrorHandler,
  }

  local element = Element.new({
    width = 200,
    height = 200,
  }, deps)

  element:setImageOpacity(0.7)
  luaunit.assertEquals(element.imageOpacity, 0.7)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
