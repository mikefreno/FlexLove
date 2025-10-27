local lu = require("testing.luaunit")
local FlexLove = require("FlexLove")
local ImageCache = FlexLove.ImageCache

TestImageCache = {}

function TestImageCache:setUp()
  -- Clear cache before each test
  ImageCache.clear()

  -- Create a test image programmatically
  self.testImageData = love.image.newImageData(64, 64)
  -- Fill with a simple pattern
  for y = 0, 63 do
    for x = 0, 63 do
      local r = x / 63
      local g = y / 63
      local b = 0.5
      self.testImageData:setPixel(x, y, r, g, b, 1)
    end
  end

  -- Save to a temporary file (register in mock filesystem)
  self.testImagePath = "testing/temp_test_image.png"
  self.testImageData:encode("png", self.testImagePath)
  -- Register file in mock filesystem so love.graphics.newImage can find it
  love.filesystem.addMockFile(self.testImagePath, "mock_png_data")
end

function TestImageCache:tearDown()
  -- Clear cache after each test
  ImageCache.clear()

  -- Clean up temporary test file
  if love.filesystem.getInfo(self.testImagePath) then
    love.filesystem.remove(self.testImagePath)
  end
end

-- ====================
-- Basic Loading Tests
-- ====================

function TestImageCache:testLoadValidImage()
  local image, err = ImageCache.load(self.testImagePath)

  lu.assertNotNil(image)
  lu.assertNil(err)
  lu.assertEquals(type(image), "userdata") -- love.Image is userdata
end

function TestImageCache:testLoadInvalidPath()
  local image, err = ImageCache.load("nonexistent/path/to/image.png")

  lu.assertNil(image)
  lu.assertNotNil(err)
  lu.assertStrContains(err, "Failed to load image")
end

function TestImageCache:testLoadEmptyPath()
  local image, err = ImageCache.load("")

  lu.assertNil(image)
  lu.assertNotNil(err)
  lu.assertStrContains(err, "Invalid image path")
end

function TestImageCache:testLoadNilPath()
  local image, err = ImageCache.load(nil)

  lu.assertNil(image)
  lu.assertNotNil(err)
  lu.assertStrContains(err, "Invalid image path")
end

-- ====================
-- Caching Tests
-- ====================

function TestImageCache:testCachingSameImageReturnsSameReference()
  local image1, err1 = ImageCache.load(self.testImagePath)
  local image2, err2 = ImageCache.load(self.testImagePath)

  lu.assertNotNil(image1)
  lu.assertNotNil(image2)
  lu.assertEquals(image1, image2) -- Same reference
end

function TestImageCache:testCachingDifferentImages()
  -- Create a second test image
  local testImageData2 = love.image.newImageData(32, 32)
  for y = 0, 31 do
    for x = 0, 31 do
      testImageData2:setPixel(x, y, 1, 0, 0, 1)
    end
  end
  local testImagePath2 = "testing/temp_test_image2.png"
  testImageData2:encode("png", testImagePath2)

  local image1 = ImageCache.load(self.testImagePath)
  local image2 = ImageCache.load(testImagePath2)

  lu.assertNotNil(image1)
  lu.assertNotNil(image2)
  lu.assertNotEquals(image1, image2) -- Different images

  -- Cleanup
  love.filesystem.remove(testImagePath2)
end

function TestImageCache:testGetCachedImage()
  -- Load image first
  local loadedImage = ImageCache.load(self.testImagePath)

  -- Get from cache
  local cachedImage = ImageCache.get(self.testImagePath)

  lu.assertNotNil(cachedImage)
  lu.assertEquals(loadedImage, cachedImage)
end

function TestImageCache:testGetNonCachedImage()
  local image = ImageCache.get("nonexistent.png")

  lu.assertNil(image)
end

-- ====================
-- ImageData Loading Tests
-- ====================

function TestImageCache:testLoadWithImageData()
  local image, err = ImageCache.load(self.testImagePath, true)

  lu.assertNotNil(image)
  lu.assertNil(err)

  local imageData = ImageCache.getImageData(self.testImagePath)
  lu.assertNotNil(imageData)
  lu.assertEquals(type(imageData), "userdata") -- love.ImageData is userdata
end

function TestImageCache:testLoadWithoutImageData()
  local image, err = ImageCache.load(self.testImagePath, false)

  lu.assertNotNil(image)
  lu.assertNil(err)

  local imageData = ImageCache.getImageData(self.testImagePath)
  lu.assertNil(imageData) -- Should not be loaded
end

-- ====================
-- Cache Management Tests
-- ====================

function TestImageCache:testRemoveImage()
  ImageCache.load(self.testImagePath)

  local removed = ImageCache.remove(self.testImagePath)

  lu.assertTrue(removed)

  -- Verify it's no longer in cache
  local cachedImage = ImageCache.get(self.testImagePath)
  lu.assertNil(cachedImage)
end

function TestImageCache:testRemoveNonExistentImage()
  local removed = ImageCache.remove("nonexistent.png")

  lu.assertFalse(removed)
end

function TestImageCache:testClearCache()
  -- Load multiple images
  ImageCache.load(self.testImagePath)

  local stats1 = ImageCache.getStats()
  lu.assertEquals(stats1.count, 1)

  ImageCache.clear()

  local stats2 = ImageCache.getStats()
  lu.assertEquals(stats2.count, 0)
end

-- ====================
-- Statistics Tests
-- ====================

function TestImageCache:testCacheStats()
  local stats1 = ImageCache.getStats()
  lu.assertEquals(stats1.count, 0)
  lu.assertEquals(stats1.memoryEstimate, 0)

  ImageCache.load(self.testImagePath)

  local stats2 = ImageCache.getStats()
  lu.assertEquals(stats2.count, 1)
  lu.assertTrue(stats2.memoryEstimate > 0)

  -- Memory estimate should be approximately 64*64*4 bytes
  local expectedMemory = 64 * 64 * 4
  lu.assertEquals(stats2.memoryEstimate, expectedMemory)
end

-- ====================
-- Path Normalization Tests
-- ====================

function TestImageCache:testPathNormalization()
  -- Load with different path formats
  local image1 = ImageCache.load(self.testImagePath)
  local image2 = ImageCache.load("  " .. self.testImagePath .. "  ") -- With whitespace
  local image3 = ImageCache.load(self.testImagePath:gsub("/", "\\")) -- With backslashes

  lu.assertEquals(image1, image2)
  lu.assertEquals(image1, image3)

  -- Should only have one cache entry
  local stats = ImageCache.getStats()
  lu.assertEquals(stats.count, 1)
end

lu.LuaUnit.run()
