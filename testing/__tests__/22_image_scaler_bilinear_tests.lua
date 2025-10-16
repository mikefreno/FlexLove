package.path = package.path .. ";?.lua"
local luaunit = require("testing.luaunit")
local loveStub = require("testing.loveStub")
_G.love = loveStub

local FlexLove = require("FlexLove")

TestImageScalerBilinear = {}

function TestImageScalerBilinear:setUp()
  -- Create a simple test image (2x2 with distinct colors)
  self.testImage2x2 = love.image.newImageData(2, 2)
  -- Top-left: red
  self.testImage2x2:setPixel(0, 0, 1, 0, 0, 1)
  -- Top-right: green
  self.testImage2x2:setPixel(1, 0, 0, 1, 0, 1)
  -- Bottom-left: blue
  self.testImage2x2:setPixel(0, 1, 0, 0, 1, 1)
  -- Bottom-right: white
  self.testImage2x2:setPixel(1, 1, 1, 1, 1, 1)
end

function TestImageScalerBilinear:test2xScaling()
  -- Scale 2x2 to 4x4 (2x factor)
  local scaled = FlexLove.ImageScaler.scaleBilinear(self.testImage2x2, 0, 0, 2, 2, 4, 4)

  luaunit.assertEquals(scaled:getWidth(), 4)
  luaunit.assertEquals(scaled:getHeight(), 4)

  -- Corner pixels should match original (no interpolation at exact positions)
  local r, g, b, a = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(r, 1, 0.01) -- Red
  luaunit.assertAlmostEquals(g, 0, 0.01)
  luaunit.assertAlmostEquals(b, 0, 0.01)

  -- Center pixel at (1,1) should be blend of all 4 corners
  -- At (0.5, 0.5) in source space -> blend of all 4 colors
  r, g, b, a = scaled:getPixel(1, 1)
  -- Should be approximately (0.5, 0.5, 0.5) - average of red, green, blue, white
  luaunit.assertTrue(r > 0.3 and r < 0.7, "Center pixel should be blended")
  luaunit.assertTrue(g > 0.3 and g < 0.7, "Center pixel should be blended")
  luaunit.assertTrue(b > 0.3 and b < 0.7, "Center pixel should be blended")
end

function TestImageScalerBilinear:testGradientSmoothing()
  -- Create a simple gradient: black to white horizontally
  local gradient = love.image.newImageData(2, 1)
  gradient:setPixel(0, 0, 0, 0, 0, 1) -- Black
  gradient:setPixel(1, 0, 1, 1, 1, 1) -- White

  -- Scale to 4 pixels wide
  local scaled = FlexLove.ImageScaler.scaleBilinear(gradient, 0, 0, 2, 1, 4, 1)

  luaunit.assertEquals(scaled:getWidth(), 4)
  luaunit.assertEquals(scaled:getHeight(), 1)

  -- Check smooth gradient progression
  local r0 = scaled:getPixel(0, 0)
  local r1 = scaled:getPixel(1, 0)
  local r2 = scaled:getPixel(2, 0)
  local r3 = scaled:getPixel(3, 0)

  -- Should be monotonically increasing (or equal at end due to clamping)
  luaunit.assertTrue(r0 < r1, "Gradient should increase")
  luaunit.assertTrue(r1 < r2, "Gradient should increase")
  luaunit.assertTrue(r2 <= r3, "Gradient should increase or stay same")

  -- First should be close to black, last close to white
  luaunit.assertAlmostEquals(r0, 0, 0.15)
  luaunit.assertAlmostEquals(r3, 1, 0.15)
end

function TestImageScalerBilinear:testSameSizeScaling()
  -- Scale 2x2 to 2x2 (should be identical)
  local scaled = FlexLove.ImageScaler.scaleBilinear(self.testImage2x2, 0, 0, 2, 2, 2, 2)

  luaunit.assertEquals(scaled:getWidth(), 2)
  luaunit.assertEquals(scaled:getHeight(), 2)

  -- Verify all pixels match original
  for y = 0, 1 do
    for x = 0, 1 do
      local r1, g1, b1, a1 = self.testImage2x2:getPixel(x, y)
      local r2, g2, b2, a2 = scaled:getPixel(x, y)
      luaunit.assertAlmostEquals(r1, r2, 0.01)
      luaunit.assertAlmostEquals(g1, g2, 0.01)
      luaunit.assertAlmostEquals(b1, b2, 0.01)
      luaunit.assertAlmostEquals(a1, a2, 0.01)
    end
  end
end

function TestImageScalerBilinear:test1x1Scaling()
  -- Create 1x1 image
  local img1x1 = love.image.newImageData(1, 1)
  img1x1:setPixel(0, 0, 0.5, 0.5, 0.5, 1)

  -- Scale to 4x4
  local scaled = FlexLove.ImageScaler.scaleBilinear(img1x1, 0, 0, 1, 1, 4, 4)

  luaunit.assertEquals(scaled:getWidth(), 4)
  luaunit.assertEquals(scaled:getHeight(), 4)

  -- All pixels should be the same color (no neighbors to interpolate with)
  for y = 0, 3 do
    for x = 0, 3 do
      local r, g, b = scaled:getPixel(x, y)
      luaunit.assertAlmostEquals(r, 0.5, 0.01)
      luaunit.assertAlmostEquals(g, 0.5, 0.01)
      luaunit.assertAlmostEquals(b, 0.5, 0.01)
    end
  end
end

function TestImageScalerBilinear:testPureColorMaintenance()
  -- Create pure white image
  local whiteImg = love.image.newImageData(2, 2)
  for y = 0, 1 do
    for x = 0, 1 do
      whiteImg:setPixel(x, y, 1, 1, 1, 1)
    end
  end

  local scaled = FlexLove.ImageScaler.scaleBilinear(whiteImg, 0, 0, 2, 2, 4, 4)

  -- All pixels should remain pure white
  for y = 0, 3 do
    for x = 0, 3 do
      local r, g, b = scaled:getPixel(x, y)
      luaunit.assertAlmostEquals(r, 1, 0.01)
      luaunit.assertAlmostEquals(g, 1, 0.01)
      luaunit.assertAlmostEquals(b, 1, 0.01)
    end
  end

  -- Test pure black
  local blackImg = love.image.newImageData(2, 2)
  for y = 0, 1 do
    for x = 0, 1 do
      blackImg:setPixel(x, y, 0, 0, 0, 1)
    end
  end

  scaled = FlexLove.ImageScaler.scaleBilinear(blackImg, 0, 0, 2, 2, 4, 4)

  for y = 0, 3 do
    for x = 0, 3 do
      local r, g, b = scaled:getPixel(x, y)
      luaunit.assertAlmostEquals(r, 0, 0.01)
      luaunit.assertAlmostEquals(g, 0, 0.01)
      luaunit.assertAlmostEquals(b, 0, 0.01)
    end
  end
end

function TestImageScalerBilinear:testAlphaInterpolation()
  -- Create image with varying alpha
  local img = love.image.newImageData(2, 2)
  img:setPixel(0, 0, 1, 0, 0, 1.0) -- Opaque red
  img:setPixel(1, 0, 1, 0, 0, 0.0) -- Transparent red
  img:setPixel(0, 1, 1, 0, 0, 1.0) -- Opaque red
  img:setPixel(1, 1, 1, 0, 0, 0.0) -- Transparent red

  local scaled = FlexLove.ImageScaler.scaleBilinear(img, 0, 0, 2, 2, 4, 2)

  -- Check that alpha is interpolated smoothly
  local r, g, b, a0 = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(a0, 1.0, 0.01)

  local r, g, b, a1 = scaled:getPixel(1, 0)
  -- Should be between 1.0 and 0.0
  luaunit.assertTrue(a1 > 0.3 and a1 < 0.7, "Alpha should be interpolated")

  local r, g, b, a3 = scaled:getPixel(3, 0)
  luaunit.assertAlmostEquals(a3, 0.0, 0.15)
end

function TestImageScalerBilinear:testSubregionScaling()
  -- Create 4x4 image with different quadrants
  local img4x4 = love.image.newImageData(4, 4)

  -- Fill with pattern: top-left red, rest black
  for y = 0, 3 do
    for x = 0, 3 do
      if x < 2 and y < 2 then
        img4x4:setPixel(x, y, 1, 0, 0, 1) -- red
      else
        img4x4:setPixel(x, y, 0, 0, 0, 1) -- black
      end
    end
  end

  -- Scale only the top-left 2x2 red quadrant to 4x4
  local scaled = FlexLove.ImageScaler.scaleBilinear(img4x4, 0, 0, 2, 2, 4, 4)

  luaunit.assertEquals(scaled:getWidth(), 4)
  luaunit.assertEquals(scaled:getHeight(), 4)

  -- All pixels should be red (from source quadrant)
  for y = 0, 3 do
    for x = 0, 3 do
      local r, g, b = scaled:getPixel(x, y)
      luaunit.assertAlmostEquals(r, 1, 0.01)
      luaunit.assertAlmostEquals(g, 0, 0.01)
      luaunit.assertAlmostEquals(b, 0, 0.01)
    end
  end
end

function TestImageScalerBilinear:testEdgePixelHandling()
  -- Create 3x3 checkerboard
  local checkerboard = love.image.newImageData(3, 3)
  for y = 0, 2 do
    for x = 0, 2 do
      if (x + y) % 2 == 0 then
        checkerboard:setPixel(x, y, 1, 1, 1, 1) -- white
      else
        checkerboard:setPixel(x, y, 0, 0, 0, 1) -- black
      end
    end
  end

  -- Scale to 9x9
  local scaled = FlexLove.ImageScaler.scaleBilinear(checkerboard, 0, 0, 3, 3, 9, 9)

  luaunit.assertEquals(scaled:getWidth(), 9)
  luaunit.assertEquals(scaled:getHeight(), 9)

  -- Verify corners are correct (no out-of-bounds access)
  local r, g, b = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(r, 1, 0.01) -- Top-left should be white

  r, g, b = scaled:getPixel(8, 8)
  luaunit.assertAlmostEquals(r, 1, 0.01) -- Bottom-right should be white
end

function TestImageScalerBilinear:testNonUniformScaling()
  -- Scale 2x2 to 6x4 (3x horizontal, 2x vertical)
  local scaled = FlexLove.ImageScaler.scaleBilinear(self.testImage2x2, 0, 0, 2, 2, 6, 4)

  luaunit.assertEquals(scaled:getWidth(), 6)
  luaunit.assertEquals(scaled:getHeight(), 4)

  -- Top-left corner should be red
  local r, g, b = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(r, 1, 0.01)
  luaunit.assertAlmostEquals(g, 0, 0.01)

  -- Should have smooth interpolation in between
  r, g, b = scaled:getPixel(2, 1)
  -- Middle area should have blended colors
  luaunit.assertTrue(r > 0.1, "Should have some red component")
  luaunit.assertTrue(g > 0.1, "Should have some green component")
  luaunit.assertTrue(b > 0.1, "Should have some blue component")
end

function TestImageScalerBilinear:testComparison_SmootherThanNearest()
  -- Create gradient
  local gradient = love.image.newImageData(2, 1)
  gradient:setPixel(0, 0, 0, 0, 0, 1)
  gradient:setPixel(1, 0, 1, 1, 1, 1)

  local bilinear = FlexLove.ImageScaler.scaleBilinear(gradient, 0, 0, 2, 1, 8, 1)
  local nearest = FlexLove.ImageScaler.scaleNearest(gradient, 0, 0, 2, 1, 8, 1)

  -- Count unique values (nearest should have fewer due to blocky nature)
  local bilinearValues = {}
  local nearestValues = {}

  for x = 0, 7 do
    local rb = bilinear:getPixel(x, 0)
    local rn = nearest:getPixel(x, 0)
    bilinearValues[string.format("%.2f", rb)] = true
    nearestValues[string.format("%.2f", rn)] = true
  end

  local bilinearCount = 0
  for _ in pairs(bilinearValues) do
    bilinearCount = bilinearCount + 1
  end

  local nearestCount = 0
  for _ in pairs(nearestValues) do
    nearestCount = nearestCount + 1
  end

  -- Bilinear should have more unique values (smoother gradient)
  luaunit.assertTrue(bilinearCount >= nearestCount, "Bilinear should produce smoother gradient with more unique values")
end

luaunit.LuaUnit.run()
