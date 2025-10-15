package.path = package.path .. ";?.lua"
local luaunit = require("testing.luaunit")
local loveStub = require("testing.loveStub")
_G.love = loveStub

local FlexLove = require("FlexLove")

TestImageScalerNearest = {}

function TestImageScalerNearest:setUp()
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

function TestImageScalerNearest:test2xScaling()
  -- Scale 2x2 to 4x4 (2x factor)
  local scaled = FlexLove.ImageScaler.scaleNearest(self.testImage2x2, 0, 0, 2, 2, 4, 4)

  luaunit.assertEquals(scaled:getWidth(), 4)
  luaunit.assertEquals(scaled:getHeight(), 4)

  -- Top-left quadrant should be red (0,0 -> 1,1)
  local r, g, b, a = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(r, 1, 0.01)
  luaunit.assertAlmostEquals(g, 0, 0.01)
  luaunit.assertAlmostEquals(b, 0, 0.01)

  r, g, b, a = scaled:getPixel(1, 1)
  luaunit.assertAlmostEquals(r, 1, 0.01)
  luaunit.assertAlmostEquals(g, 0, 0.01)
  luaunit.assertAlmostEquals(b, 0, 0.01)

  -- Top-right quadrant should be green (2,0 -> 3,1)
  r, g, b, a = scaled:getPixel(2, 0)
  luaunit.assertAlmostEquals(r, 0, 0.01)
  luaunit.assertAlmostEquals(g, 1, 0.01)
  luaunit.assertAlmostEquals(b, 0, 0.01)

  r, g, b, a = scaled:getPixel(3, 1)
  luaunit.assertAlmostEquals(r, 0, 0.01)
  luaunit.assertAlmostEquals(g, 1, 0.01)
  luaunit.assertAlmostEquals(b, 0, 0.01)

  -- Bottom-left quadrant should be blue (0,2 -> 1,3)
  r, g, b, a = scaled:getPixel(0, 2)
  luaunit.assertAlmostEquals(r, 0, 0.01)
  luaunit.assertAlmostEquals(g, 0, 0.01)
  luaunit.assertAlmostEquals(b, 1, 0.01)

  -- Bottom-right quadrant should be white (2,2 -> 3,3)
  r, g, b, a = scaled:getPixel(3, 3)
  luaunit.assertAlmostEquals(r, 1, 0.01)
  luaunit.assertAlmostEquals(g, 1, 0.01)
  luaunit.assertAlmostEquals(b, 1, 0.01)
end

function TestImageScalerNearest:test3xScaling()
  -- Scale 2x2 to 6x6 (3x factor)
  local scaled = FlexLove.ImageScaler.scaleNearest(self.testImage2x2, 0, 0, 2, 2, 6, 6)

  luaunit.assertEquals(scaled:getWidth(), 6)
  luaunit.assertEquals(scaled:getHeight(), 6)

  -- Verify nearest-neighbor: each source pixel should map to 3x3 block
  -- Top-left (red) should cover 0-2, 0-2
  local r, g, b = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(r, 1, 0.01)
  r, g, b = scaled:getPixel(2, 2)
  luaunit.assertAlmostEquals(r, 1, 0.01)

  -- Top-right (green) should cover 3-5, 0-2
  r, g, b = scaled:getPixel(3, 0)
  luaunit.assertAlmostEquals(g, 1, 0.01)
  r, g, b = scaled:getPixel(5, 2)
  luaunit.assertAlmostEquals(g, 1, 0.01)
end

function TestImageScalerNearest:testNonUniformScaling()
  -- Scale 2x2 to 6x4 (3x horizontal, 2x vertical)
  local scaled = FlexLove.ImageScaler.scaleNearest(self.testImage2x2, 0, 0, 2, 2, 6, 4)

  luaunit.assertEquals(scaled:getWidth(), 6)
  luaunit.assertEquals(scaled:getHeight(), 4)

  -- Top-left red should cover 0-2 horizontally, 0-1 vertically
  local r, g, b = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(r, 1, 0.01)
  r, g, b = scaled:getPixel(2, 1)
  luaunit.assertAlmostEquals(r, 1, 0.01)

  -- Top-right green should cover 3-5 horizontally, 0-1 vertically
  r, g, b = scaled:getPixel(3, 0)
  luaunit.assertAlmostEquals(g, 1, 0.01)
end

function TestImageScalerNearest:testSameSizeScaling()
  -- Scale 2x2 to 2x2 (should be identical)
  local scaled = FlexLove.ImageScaler.scaleNearest(self.testImage2x2, 0, 0, 2, 2, 2, 2)

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

function TestImageScalerNearest:test1x1Scaling()
  -- Create 1x1 image
  local img1x1 = love.image.newImageData(1, 1)
  img1x1:setPixel(0, 0, 0.5, 0.5, 0.5, 1)

  -- Scale to 4x4
  local scaled = FlexLove.ImageScaler.scaleNearest(img1x1, 0, 0, 1, 1, 4, 4)

  luaunit.assertEquals(scaled:getWidth(), 4)
  luaunit.assertEquals(scaled:getHeight(), 4)

  -- All pixels should be the same color
  for y = 0, 3 do
    for x = 0, 3 do
      local r, g, b = scaled:getPixel(x, y)
      luaunit.assertAlmostEquals(r, 0.5, 0.01)
      luaunit.assertAlmostEquals(g, 0.5, 0.01)
      luaunit.assertAlmostEquals(b, 0.5, 0.01)
    end
  end
end

function TestImageScalerNearest:testSubregionScaling()
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
  local scaled = FlexLove.ImageScaler.scaleNearest(img4x4, 0, 0, 2, 2, 4, 4)

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

function TestImageScalerNearest:testAlphaChannel()
  -- Create image with varying alpha
  local img = love.image.newImageData(2, 2)
  img:setPixel(0, 0, 1, 0, 0, 1.0) -- Opaque red
  img:setPixel(1, 0, 0, 1, 0, 0.5) -- Semi-transparent green
  img:setPixel(0, 1, 0, 0, 1, 0.25) -- More transparent blue
  img:setPixel(1, 1, 1, 1, 1, 0.0) -- Fully transparent white

  local scaled = FlexLove.ImageScaler.scaleNearest(img, 0, 0, 2, 2, 4, 4)

  -- Check alpha values are preserved
  local r, g, b, a = scaled:getPixel(0, 0)
  luaunit.assertAlmostEquals(a, 1.0, 0.01)

  r, g, b, a = scaled:getPixel(2, 0)
  luaunit.assertAlmostEquals(a, 0.5, 0.01)

  r, g, b, a = scaled:getPixel(0, 2)
  luaunit.assertAlmostEquals(a, 0.25, 0.01)

  r, g, b, a = scaled:getPixel(3, 3)
  luaunit.assertAlmostEquals(a, 0.0, 0.01)
end

luaunit.LuaUnit.run()
