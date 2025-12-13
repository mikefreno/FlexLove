package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")
ErrorHandler.init({})
require("testing.loveStub")
local ImageRenderer = require("modules.ImageRenderer")
local Color = require("modules.Color")
local utils = require("modules.utils")
ImageRenderer.init({ ErrorHandler = ErrorHandler, utils = utils })

-- ============================================================================
-- Test Suite 1: calculateFit - Input Validation
-- ============================================================================
TestImageRendererInputValidation = {}

function TestImageRendererInputValidation:setUp()
  self.mockImage = {
    getDimensions = function()
      return 100, 100
    end,
  }
end

function TestImageRendererInputValidation:testCalculateFitWithZeroImageWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(0, 100, 200, 200, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithZeroImageHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 0, 200, 200, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithNegativeImageWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(-100, 100, 200, 200, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithNegativeImageHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, -100, 200, 200, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithZeroBoundsWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, 0, 200, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithZeroBoundsHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, 200, 0, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithNegativeBoundsWidth()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, -200, 200, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithNegativeBoundsHeight()
  luaunit.assertError(function()
    ImageRenderer.calculateFit(100, 100, 200, -200, "fill")
  end)
end

function TestImageRendererInputValidation:testCalculateFitWithInvalidFitMode()
  -- Now uses 'fill' fallback with warning instead of error
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "invalid-mode")
  luaunit.assertNotNil(result)
  -- Should fall back to 'fill' mode behavior (scales to fill bounds)
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRendererInputValidation:testCalculateFitWithNilFitMode()
  -- Should default to "fill"
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, nil)
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result.dw, 200)
  luaunit.assertEquals(result.dh, 200)
end

-- ============================================================================
-- Test Suite 2: calculateFit - Fit Modes
-- ============================================================================
TestImageRendererFitModes = {}

function TestImageRendererFitModes:testCalculateFitFillMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "fill")
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRendererFitModes:testCalculateFitContainMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "contain")
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRendererFitModes:testCalculateFitCoverMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "cover")
  luaunit.assertEquals(result.scaleX, 2)
  luaunit.assertEquals(result.scaleY, 2)
end

function TestImageRendererFitModes:testCalculateFitNoneMode()
  local result = ImageRenderer.calculateFit(100, 100, 200, 200, "none")
  luaunit.assertEquals(result.scaleX, 1)
  luaunit.assertEquals(result.scaleY, 1)
end

function TestImageRendererFitModes:testCalculateFitScaleDownModeWithLargeImage()
  local result = ImageRenderer.calculateFit(300, 300, 200, 200, "scale-down")
  -- Should behave like contain for larger images
  luaunit.assertNotNil(result)
end

function TestImageRendererFitModes:testCalculateFitScaleDownModeWithSmallImage()
  local result = ImageRenderer.calculateFit(50, 50, 200, 200, "scale-down")
  -- Should behave like none for smaller images
  luaunit.assertEquals(result.scaleX, 1)
  luaunit.assertEquals(result.scaleY, 1)
end

-- ============================================================================
-- Test Suite 3: calculateFit - Edge Cases
-- ============================================================================
TestImageRendererEdgeCases = {}

function TestImageRendererEdgeCases:testCalculateFitWithVerySmallBounds()
  local result = ImageRenderer.calculateFit(1000, 1000, 1, 1, "contain")
  luaunit.assertNotNil(result)
  -- Scale should be very small
  luaunit.assertTrue(result.scaleX < 0.01)
end

function TestImageRendererEdgeCases:testCalculateFitWithVeryLargeBounds()
  local result = ImageRenderer.calculateFit(10, 10, 10000, 10000, "contain")
  luaunit.assertNotNil(result)
  -- Scale should be very large
  luaunit.assertTrue(result.scaleX > 100)
end

function TestImageRendererEdgeCases:testCalculateFitWithAspectRatioMismatch()
  -- Wide image, tall bounds
  local result = ImageRenderer.calculateFit(200, 100, 100, 200, "contain")
  luaunit.assertNotNil(result)
  -- Should maintain aspect ratio
  luaunit.assertEquals(result.scaleX, result.scaleY)
end

function TestImageRendererEdgeCases:testCalculateFitCoverWithAspectRatioMismatch()
  -- Wide image, tall bounds
  local result = ImageRenderer.calculateFit(200, 100, 100, 200, "cover")
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result.scaleX, result.scaleY)
end

-- ============================================================================
-- Test Suite 4: Position Parsing
-- ============================================================================
TestImageRendererPositionParsing = {}

function TestImageRendererPositionParsing:testParsePositionWithNil()
  local x, y = ImageRenderer._parsePosition(nil)
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRendererPositionParsing:testParsePositionWithEmptyString()
  local x, y = ImageRenderer._parsePosition("")
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRendererPositionParsing:testParsePositionWithInvalidType()
  local x, y = ImageRenderer._parsePosition(123)
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRendererPositionParsing:testParsePositionWithInvalidKeyword()
  local x, y = ImageRenderer._parsePosition("invalid keyword")
  -- Should default to center
  luaunit.assertEquals(x, 0.5)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRendererPositionParsing:testParsePositionWithMixedValid()
  local x, y = ImageRenderer._parsePosition("left top")
  luaunit.assertEquals(x, 0)
  luaunit.assertEquals(y, 0)
end

function TestImageRendererPositionParsing:testParsePositionWithPercentage()
  local x, y = ImageRenderer._parsePosition("75% 25%")
  luaunit.assertAlmostEquals(x, 0.75, 0.01)
  luaunit.assertAlmostEquals(y, 0.25, 0.01)
end

function TestImageRendererPositionParsing:testParsePositionWithOutOfRangePercentage()
  local x, y = ImageRenderer._parsePosition("150% -50%")
  -- 150% clamps to 1, but -50% doesn't match pattern so defaults to 0.5
  luaunit.assertEquals(x, 1)
  luaunit.assertEquals(y, 0.5)
end

function TestImageRendererPositionParsing:testParsePositionWithSingleValue()
  local x, y = ImageRenderer._parsePosition("left")
  luaunit.assertEquals(x, 0)
  luaunit.assertEquals(y, 0.5) -- Should use center for Y
end

function TestImageRendererPositionParsing:testParsePositionWithSinglePercentage()
  local x, y = ImageRenderer._parsePosition("25%")
  luaunit.assertAlmostEquals(x, 0.25, 0.01)
  luaunit.assertAlmostEquals(y, 0.25, 0.01)
end

-- ============================================================================
-- Test Suite 5: Draw Function
-- ============================================================================
TestImageRendererDraw = {}

function TestImageRendererDraw:setUp()
  self.mockImage = {
    getDimensions = function()
      return 100, 100
    end,
  }
end

function TestImageRendererDraw:testDrawWithNilImage()
  -- Should not crash, just return early
  ImageRenderer.draw(nil, 0, 0, 100, 100, "fill")
  -- If we get here without error, test passes
  luaunit.assertTrue(true)
end

function TestImageRendererDraw:testDrawWithZeroWidth()
  -- Should error in calculateFit
  luaunit.assertError(function()
    ImageRenderer.draw(self.mockImage, 0, 0, 0, 100, "fill")
  end)
end

function TestImageRendererDraw:testDrawWithZeroHeight()
  luaunit.assertError(function()
    ImageRenderer.draw(self.mockImage, 0, 0, 100, 0, "fill")
  end)
end

function TestImageRendererDraw:testDrawWithNegativeOpacity()
  -- Should work but render with negative opacity
  ImageRenderer.draw(self.mockImage, 0, 0, 100, 100, "fill", "center center", -0.5)
  luaunit.assertTrue(true)
end

function TestImageRendererDraw:testDrawWithOpacityGreaterThanOne()
  -- Should work but render with >1 opacity
  ImageRenderer.draw(self.mockImage, 0, 0, 100, 100, "fill", "center center", 2.0)
  luaunit.assertTrue(true)
end

function TestImageRendererDraw:testDrawWithInvalidFitMode()
  -- Now uses 'fill' fallback with warning instead of error
  -- Should not throw an error, just use fill mode
  ImageRenderer.draw(self.mockImage, 0, 0, 100, 100, "invalid")
  luaunit.assertTrue(true) -- If we reach here, no error was thrown
end

-- ============================================================================
-- Test Suite 6: Tiling - Basic Modes
-- ============================================================================
TestImageRendererTiling = {}

function TestImageRendererTiling:setUp()
  self.mockImage = {
    getDimensions = function()
      return 64, 64
    end,
    type = function()
      return "Image"
    end,
  }
end

function TestImageRendererTiling:tearDown()
  self.mockImage = nil
end

function TestImageRendererTiling:testDrawTiledNoRepeat()
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

function TestImageRendererTiling:testDrawTiledRepeat()
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

function TestImageRendererTiling:testDrawTiledRepeatX()
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

function TestImageRendererTiling:testDrawTiledRepeatY()
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

function TestImageRendererTiling:testDrawTiledSpace()
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

function TestImageRendererTiling:testDrawTiledRound()
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

-- ============================================================================
-- Test Suite 7: Tiling - Opacity and Tint
-- ============================================================================
TestImageRendererTilingEffects = {}

function TestImageRendererTilingEffects:setUp()
  self.mockImage = {
    getDimensions = function()
      return 64, 64
    end,
    type = function()
      return "Image"
    end,
  }
end

function TestImageRendererTilingEffects:tearDown()
  self.mockImage = nil
end

function TestImageRendererTilingEffects:testDrawTiledWithOpacity()
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

function TestImageRendererTilingEffects:testDrawTiledWithTint()
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

-- ============================================================================
-- Test Suite 8: Element Integration
-- ============================================================================
TestImageRendererElementIntegration = {}

function TestImageRendererElementIntegration:setUp()
  self.Flexlove = require("FlexLove")
  self.Flexlove.init({})
end

function TestImageRendererElementIntegration:testElementImageRepeatProperty()
  -- Test that Element accepts imageRepeat property
  local element = self.Flexlove.new({
    width = 200,
    height = 200,
    imageRepeat = "repeat",
  })

  luaunit.assertEquals(element.imageRepeat, "repeat")
end

function TestImageRendererElementIntegration:testElementImageRepeatDefault()
  -- Test that imageRepeat defaults to "no-repeat"
  local element = self.Flexlove.new({
    width = 200,
    height = 200,
  })

  luaunit.assertEquals(element.imageRepeat, "no-repeat")
end

function TestImageRendererElementIntegration:testElementSetImageRepeat()
  -- Test setImageRepeat method
  local element = self.Flexlove.new({
    width = 200,
    height = 200,
  })

  element:setImageRepeat("repeat-x")
  luaunit.assertEquals(element.imageRepeat, "repeat-x")
end

function TestImageRendererElementIntegration:testElementImageTintProperty()
  -- Test that Element accepts imageTint property
  local redTint = Color.new(1, 0, 0, 1)

  local element = self.Flexlove.new({
    width = 200,
    height = 200,
    imageTint = redTint,
  })

  luaunit.assertEquals(element.imageTint, redTint)
end

function TestImageRendererElementIntegration:testElementSetImageTint()
  -- Test setImageTint method
  local element = self.Flexlove.new({
    width = 200,
    height = 200,
  })

  local blueTint = Color.new(0, 0, 1, 1)
  element:setImageTint(blueTint)
  luaunit.assertEquals(element.imageTint, blueTint)
end

function TestImageRendererElementIntegration:testElementSetImageOpacity()
  -- Test setImageOpacity method
  local element = self.Flexlove.new({
    width = 200,
    height = 200,
  })

  element:setImageOpacity(0.7)
  luaunit.assertEquals(element.imageOpacity, 0.7)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
