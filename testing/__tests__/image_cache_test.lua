local luaunit = require("testing.luaunit")
require("testing.loveStub")

local ImageCache = require("modules.ImageCache")

TestImageCache = {}

function TestImageCache:setUp()
  -- Clear cache before each test
  ImageCache.clear()
end

function TestImageCache:tearDown()
  ImageCache.clear()
end

-- Unhappy path tests

function TestImageCache:testLoadWithNilPath()
  local img, err = ImageCache.load(nil)
  luaunit.assertNil(img)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid image path")
end

function TestImageCache:testLoadWithEmptyString()
  local img, err = ImageCache.load("")
  luaunit.assertNil(img)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid image path")
end

function TestImageCache:testLoadWithInvalidType()
  local img, err = ImageCache.load(123)
  luaunit.assertNil(img)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid image path")
end

function TestImageCache:testLoadWithInvalidPath()
  local img, err = ImageCache.load("nonexistent/path/to/image.png")
  luaunit.assertNil(img)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Failed to load image")
end

function TestImageCache:testLoadWithInvalidExtension()
  local img, err = ImageCache.load("test.txt")
  luaunit.assertNil(img)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Failed to load image")
end

function TestImageCache:testGetWithNilPath()
  local img = ImageCache.get(nil)
  luaunit.assertNil(img)
end

function TestImageCache:testGetWithEmptyString()
  local img = ImageCache.get("")
  luaunit.assertNil(img)
end

function TestImageCache:testGetWithInvalidType()
  local img = ImageCache.get({})
  luaunit.assertNil(img)
end

function TestImageCache:testGetWithNonCachedPath()
  local img = ImageCache.get("some/random/path.png")
  luaunit.assertNil(img)
end

function TestImageCache:testGetImageDataWithNilPath()
  local imgData = ImageCache.getImageData(nil)
  luaunit.assertNil(imgData)
end

function TestImageCache:testGetImageDataWithEmptyString()
  local imgData = ImageCache.getImageData("")
  luaunit.assertNil(imgData)
end

function TestImageCache:testGetImageDataWithInvalidType()
  local imgData = ImageCache.getImageData(123)
  luaunit.assertNil(imgData)
end

function TestImageCache:testGetImageDataWithNonCachedPath()
  local imgData = ImageCache.getImageData("some/path.png")
  luaunit.assertNil(imgData)
end

function TestImageCache:testRemoveWithNilPath()
  local removed = ImageCache.remove(nil)
  luaunit.assertFalse(removed)
end

function TestImageCache:testRemoveWithEmptyString()
  local removed = ImageCache.remove("")
  luaunit.assertFalse(removed)
end

function TestImageCache:testRemoveWithInvalidType()
  local removed = ImageCache.remove(123)
  luaunit.assertFalse(removed)
end

function TestImageCache:testRemoveWithNonCachedPath()
  local removed = ImageCache.remove("uncached/image.png")
  luaunit.assertFalse(removed)
end

function TestImageCache:testClearEmptyCache()
  -- Should not error on empty cache
  ImageCache.clear()
  local stats = ImageCache.getStats()
  luaunit.assertEquals(stats.count, 0)
  luaunit.assertEquals(stats.memoryEstimate, 0)
end

function TestImageCache:testGetStatsOnEmptyCache()
  ImageCache.clear()
  local stats = ImageCache.getStats()
  luaunit.assertNotNil(stats)
  luaunit.assertEquals(stats.count, 0)
  luaunit.assertEquals(stats.memoryEstimate, 0)
end

function TestImageCache:testPathNormalization()
  -- Test that paths with different slashes are normalized
  local path1 = "themes/space.png"
  local path2 = "themes\\space.png" -- Windows style

  -- Both should normalize to the same path
  -- (If first load fails, both should fail the same way)
  local img1, err1 = ImageCache.load(path1)
  local img2, err2 = ImageCache.load(path2)

  -- Both should have same result (either both nil or both same image)
  if img1 == nil then
    luaunit.assertNil(img2)
  else
    luaunit.assertEquals(img1, img2)
  end
end

function TestImageCache:testLoadWithImageDataFlag()
  -- Test loading with imageData flag on invalid path
  local img, err = ImageCache.load("invalid/path.png", true)
  luaunit.assertNil(img)
  luaunit.assertNotNil(err)
end

function TestImageCache:testMultipleClearCalls()
  -- Clear multiple times should not error
  ImageCache.clear()
  ImageCache.clear()
  ImageCache.clear()
  local stats = ImageCache.getStats()
  luaunit.assertEquals(stats.count, 0)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
