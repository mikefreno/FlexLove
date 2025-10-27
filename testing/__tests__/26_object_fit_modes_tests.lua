local lu = require("testing.luaunit")
local FlexLove = require("FlexLove")
local ImageRenderer = FlexLove.ImageRenderer

TestObjectFitModes = {}

function TestObjectFitModes:setUp()
  -- Test dimensions
  self.imageWidth = 400
  self.imageHeight = 300
  self.boundsWidth = 200
  self.boundsHeight = 200
end

-- ====================
-- Fill Mode Tests
-- ====================

function TestObjectFitModes:testFillModeStretchesToExactBounds()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "fill")

  lu.assertEquals(params.dw, self.boundsWidth)
  lu.assertEquals(params.dh, self.boundsHeight)
  lu.assertEquals(params.dx, 0)
  lu.assertEquals(params.dy, 0)
end

function TestObjectFitModes:testFillModeUsesFullSourceImage()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "fill")

  lu.assertEquals(params.sx, 0)
  lu.assertEquals(params.sy, 0)
  lu.assertEquals(params.sw, self.imageWidth)
  lu.assertEquals(params.sh, self.imageHeight)
end

-- ====================
-- Contain Mode Tests
-- ====================

function TestObjectFitModes:testContainModePreservesAspectRatio()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "contain")

  -- Image is 4:3, bounds are 1:1
  -- Should scale to fit width (200), height becomes 150
  local expectedScale = self.boundsWidth / self.imageWidth
  local expectedHeight = self.imageHeight * expectedScale

  lu.assertAlmostEquals(params.dw, self.boundsWidth, 0.01)
  lu.assertAlmostEquals(params.dh, expectedHeight, 0.01)
end

function TestObjectFitModes:testContainModeFitsWithinBounds()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "contain")

  lu.assertTrue(params.dw <= self.boundsWidth)
  lu.assertTrue(params.dh <= self.boundsHeight)
end

function TestObjectFitModes:testContainModeCentersImage()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "contain")

  -- Image should be centered in letterbox
  -- With default "center center" position
  lu.assertTrue(params.dx >= 0)
  lu.assertTrue(params.dy >= 0)
end

-- ====================
-- Cover Mode Tests
-- ====================

function TestObjectFitModes:testCoverModePreservesAspectRatio()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "cover")

  -- Check that aspect ratio is preserved in source crop
  local sourceAspect = params.sw / params.sh
  local boundsAspect = self.boundsWidth / self.boundsHeight

  lu.assertAlmostEquals(sourceAspect, boundsAspect, 0.01)
end

function TestObjectFitModes:testCoverModeCoversEntireBounds()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "cover")

  lu.assertEquals(params.dw, self.boundsWidth)
  lu.assertEquals(params.dh, self.boundsHeight)
end

function TestObjectFitModes:testCoverModeCropsImage()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "cover")

  -- Source should be cropped (not full image)
  lu.assertTrue(params.sw < self.imageWidth or params.sh < self.imageHeight)
end

-- ====================
-- None Mode Tests
-- ====================

function TestObjectFitModes:testNoneModeUsesNaturalSize()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "none")

  lu.assertEquals(params.dw, self.imageWidth)
  lu.assertEquals(params.dh, self.imageHeight)
  lu.assertEquals(params.scaleX, 1)
  lu.assertEquals(params.scaleY, 1)
end

function TestObjectFitModes:testNoneModeUsesFullSourceImage()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "none")

  lu.assertEquals(params.sx, 0)
  lu.assertEquals(params.sy, 0)
  lu.assertEquals(params.sw, self.imageWidth)
  lu.assertEquals(params.sh, self.imageHeight)
end

-- ====================
-- Scale-Down Mode Tests
-- ====================

function TestObjectFitModes:testScaleDownUsesNoneWhenImageFits()
  -- Image smaller than bounds
  local smallWidth = 100
  local smallHeight = 75

  local params = ImageRenderer.calculateFit(smallWidth, smallHeight, self.boundsWidth, self.boundsHeight, "scale-down")

  -- Should use natural size (none mode)
  lu.assertEquals(params.dw, smallWidth)
  lu.assertEquals(params.dh, smallHeight)
end

function TestObjectFitModes:testScaleDownUsesContainWhenImageTooBig()
  local params = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "scale-down")

  -- Should use contain mode
  lu.assertTrue(params.dw <= self.boundsWidth)
  lu.assertTrue(params.dh <= self.boundsHeight)

  -- Should preserve aspect ratio
  local scale = params.dw / self.imageWidth
  lu.assertAlmostEquals(params.dh, self.imageHeight * scale, 0.01)
end

-- ====================
-- Edge Cases
-- ====================

function TestObjectFitModes:testLandscapeImageInPortraitBounds()
  local params = ImageRenderer.calculateFit(
    400,
    200, -- Landscape image (2:1)
    200,
    400, -- Portrait bounds (1:2)
    "contain"
  )

  -- Should fit width
  lu.assertEquals(params.dw, 200)
  lu.assertTrue(params.dh < 400)
end

function TestObjectFitModes:testPortraitImageInLandscapeBounds()
  local params = ImageRenderer.calculateFit(
    200,
    400, -- Portrait image (1:2)
    400,
    200, -- Landscape bounds (2:1)
    "contain"
  )

  -- Should fit height
  lu.assertEquals(params.dh, 200)
  lu.assertTrue(params.dw < 400)
end

function TestObjectFitModes:testSquareImageInNonSquareBounds()
  local params = ImageRenderer.calculateFit(
    300,
    300, -- Square image
    200,
    400, -- Non-square bounds
    "contain"
  )

  -- Should fit to smaller dimension (width)
  lu.assertEquals(params.dw, 200)
  lu.assertEquals(params.dh, 200)
end

function TestObjectFitModes:testImageSmallerThanBounds()
  local params = ImageRenderer.calculateFit(100, 100, 200, 200, "contain")

  -- Should scale up to fit
  lu.assertEquals(params.dw, 200)
  lu.assertEquals(params.dh, 200)
end

function TestObjectFitModes:testImageLargerThanBounds()
  local params = ImageRenderer.calculateFit(800, 600, 200, 200, "contain")

  -- Should scale down to fit
  lu.assertTrue(params.dw <= 200)
  lu.assertTrue(params.dh <= 200)
end

-- ====================
-- Invalid Input Tests
-- ====================

function TestObjectFitModes:testInvalidFitModeThrowsError()
  lu.assertErrorMsgContains("Invalid fit mode", ImageRenderer.calculateFit, 100, 100, 200, 200, "invalid-mode")
end

function TestObjectFitModes:testZeroDimensionsThrowsError()
  lu.assertErrorMsgContains("Dimensions must be positive", ImageRenderer.calculateFit, 0, 100, 200, 200, "fill")
end

function TestObjectFitModes:testNegativeDimensionsThrowsError()
  lu.assertErrorMsgContains("Dimensions must be positive", ImageRenderer.calculateFit, 100, -100, 200, 200, "fill")
end

-- ====================
-- Default Mode Test
-- ====================

function TestObjectFitModes:testDefaultModeIsFill()
  local params1 = ImageRenderer.calculateFit(
    self.imageWidth,
    self.imageHeight,
    self.boundsWidth,
    self.boundsHeight,
    nil -- No mode specified
  )

  local params2 = ImageRenderer.calculateFit(self.imageWidth, self.imageHeight, self.boundsWidth, self.boundsHeight, "fill")

  lu.assertEquals(params1.dw, params2.dw)
  lu.assertEquals(params1.dh, params2.dh)
end

lu.LuaUnit.run()
