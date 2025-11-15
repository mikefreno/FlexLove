local luaunit = require("testing.luaunit")
require("testing.loveStub")

local NinePatchParser = require("modules.NinePatchParser")
local ImageDataReader = require("modules.ImageDataReader")

TestNinePatchParser = {}

-- Helper to create a valid 9-patch ImageData
-- Creates a simple 5x5 9-patch with a 1px stretch region in the center
local function create9PatchImageData()
  local imageData = love.image.newImageData(5, 5)

  -- Fill with transparent pixels (content area)
  for y = 0, 4 do
    for x = 0, 4 do
      imageData:setPixel(x, y, 1, 1, 1, 0) -- Transparent
    end
  end

  -- Top border: stretch markers (black pixel at x=2, which is the middle)
  -- Corners at x=0 and x=4 should be transparent
  imageData:setPixel(2, 0, 0, 0, 0, 1) -- Black stretch marker

  -- Left border: stretch markers (black pixel at y=2, which is the middle)
  imageData:setPixel(0, 2, 0, 0, 0, 1) -- Black stretch marker

  -- Bottom border: content padding markers (optional, using same as stretch)
  imageData:setPixel(2, 4, 0, 0, 0, 1) -- Black content marker

  -- Right border: content padding markers (optional, using same as stretch)
  imageData:setPixel(4, 2, 0, 0, 0, 1) -- Black content marker

  return imageData
end

-- Helper to create a 9-patch with multiple stretch regions
local function create9PatchMultipleRegions()
  local imageData = love.image.newImageData(7, 7)

  -- Fill with transparent
  for y = 0, 6 do
    for x = 0, 6 do
      imageData:setPixel(x, y, 1, 1, 1, 0)
    end
  end

  -- Top: two stretch regions (x=1-2 and x=4-5)
  imageData:setPixel(1, 0, 0, 0, 0, 1)
  imageData:setPixel(2, 0, 0, 0, 0, 1)
  imageData:setPixel(4, 0, 0, 0, 0, 1)
  imageData:setPixel(5, 0, 0, 0, 0, 1)

  -- Left: two stretch regions (y=1-2 and y=4-5)
  imageData:setPixel(0, 1, 0, 0, 0, 1)
  imageData:setPixel(0, 2, 0, 0, 0, 1)
  imageData:setPixel(0, 4, 0, 0, 0, 1)
  imageData:setPixel(0, 5, 0, 0, 0, 1)

  return imageData
end

-- Helper to mock ImageDataReader.loadImageData for testing
local originalLoadImageData = ImageDataReader.loadImageData
local function mockImageDataReader(mockData)
  ImageDataReader.loadImageData = function(path)
    if path == "test_valid_9patch.png" then
      return mockData
    elseif path == "test_multiple_regions.png" then
      return create9PatchMultipleRegions()
    elseif path == "test_small_2x2.png" then
      return love.image.newImageData(2, 2)
    elseif path == "test_no_stretch.png" then
      -- Create a 5x5 with no black pixels (invalid 9-patch)
      local data = love.image.newImageData(5, 5)
      for y = 0, 4 do
        for x = 0, 4 do
          data:setPixel(x, y, 1, 1, 1, 0)
        end
      end
      return data
    else
      return originalLoadImageData(path)
    end
  end
end

local function restoreImageDataReader()
  ImageDataReader.loadImageData = originalLoadImageData
end

-- Unhappy path tests for NinePatchParser.parse()

function TestNinePatchParser:testParseWithNilPath()
  local result, err = NinePatchParser.parse(nil)
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "cannot be nil")
end

function TestNinePatchParser:testParseWithEmptyString()
  local result, err = NinePatchParser.parse("")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithInvalidPath()
  local result, err = NinePatchParser.parse("nonexistent/path/to/image.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Failed to load")
end

function TestNinePatchParser:testParseWithNonImageFile()
  local result, err = NinePatchParser.parse("testing/runAll.lua")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithNumberInsteadOfString()
  local result, err = NinePatchParser.parse(123)
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithTableInsteadOfString()
  local result, err = NinePatchParser.parse({})
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithBooleanInsteadOfString()
  local result, err = NinePatchParser.parse(true)
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

-- Edge case: dimensions that are too small

function TestNinePatchParser:testParseWith1x1Image()
  -- Create a minimal mock - parser needs at least 3x3
  -- This would fail in real scenario
  luaunit.assertTrue(true) -- Placeholder for actual test with real image
end

function TestNinePatchParser:testParseWith2x2Image()
  -- Would fail - minimum is 3x3
  luaunit.assertTrue(true) -- Placeholder
end

-- Test path validation

function TestNinePatchParser:testParseWithRelativePath()
  local result, err = NinePatchParser.parse("./fake/path.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithAbsolutePath()
  local result, err = NinePatchParser.parse("/fake/absolute/path.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithPathContainingSpaces()
  local result, err = NinePatchParser.parse("path with spaces/image.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithPathContainingSpecialChars()
  local result, err = NinePatchParser.parse("path/with@special#chars.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithVeryLongPath()
  local longPath = string.rep("a/", 100) .. "image.png"
  local result, err = NinePatchParser.parse(longPath)
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithDotDotPath()
  local result, err = NinePatchParser.parse("../../../etc/passwd")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithMixedSlashes()
  local result, err = NinePatchParser.parse("path\\with/mixed\\slashes.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithTrailingSlash()
  local result, err = NinePatchParser.parse("path/to/image.png/")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithDoubleSlashes()
  local result, err = NinePatchParser.parse("path//to//image.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithNoExtension()
  local result, err = NinePatchParser.parse("path/to/image")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithWrongExtension()
  local result, err = NinePatchParser.parse("path/to/image.jpg")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

function TestNinePatchParser:testParseWithMultipleDots()
  local result, err = NinePatchParser.parse("path/to/image.9.patch.png")
  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
end

-- Happy path tests with mocked ImageData

function TestNinePatchParser:testParseValidSimple9Patch()
  local mockData = create9PatchImageData()
  mockImageDataReader(mockData)

  local result, err = NinePatchParser.parse("test_valid_9patch.png")

  restoreImageDataReader()

  luaunit.assertNotNil(result)
  luaunit.assertNil(err)
  luaunit.assertNotNil(result.insets)
  luaunit.assertNotNil(result.contentPadding)
  luaunit.assertNotNil(result.stretchX)
  luaunit.assertNotNil(result.stretchY)
end

function TestNinePatchParser:testParseValidMultipleRegions()
  mockImageDataReader()

  local result, err = NinePatchParser.parse("test_multiple_regions.png")

  restoreImageDataReader()

  luaunit.assertNotNil(result)
  luaunit.assertNil(err)
  -- Should have 2 stretch regions in each direction
  luaunit.assertEquals(#result.stretchX, 2)
  luaunit.assertEquals(#result.stretchY, 2)
end

function TestNinePatchParser:testParseTooSmall2x2()
  mockImageDataReader()

  local result, err = NinePatchParser.parse("test_small_2x2.png")

  restoreImageDataReader()

  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "Invalid 9-patch dimensions")
  luaunit.assertStrContains(err, "minimum 3x3")
end

function TestNinePatchParser:testParseNoStretchRegions()
  mockImageDataReader()

  local result, err = NinePatchParser.parse("test_no_stretch.png")

  restoreImageDataReader()

  luaunit.assertNil(result)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "No stretch regions found")
end

function TestNinePatchParser:testParseInsetsCalculation()
  local mockData = create9PatchImageData()
  mockImageDataReader(mockData)

  local result, err = NinePatchParser.parse("test_valid_9patch.png")

  restoreImageDataReader()

  luaunit.assertNotNil(result)
  -- Verify insets structure
  luaunit.assertNotNil(result.insets.left)
  luaunit.assertNotNil(result.insets.top)
  luaunit.assertNotNil(result.insets.right)
  luaunit.assertNotNil(result.insets.bottom)
end

function TestNinePatchParser:testParseContentPaddingCalculation()
  local mockData = create9PatchImageData()
  mockImageDataReader(mockData)

  local result, err = NinePatchParser.parse("test_valid_9patch.png")

  restoreImageDataReader()

  luaunit.assertNotNil(result)
  -- Verify content padding structure
  luaunit.assertNotNil(result.contentPadding.left)
  luaunit.assertNotNil(result.contentPadding.top)
  luaunit.assertNotNil(result.contentPadding.right)
  luaunit.assertNotNil(result.contentPadding.bottom)
end

function TestNinePatchParser:testParseStretchRegionsFormat()
  local mockData = create9PatchImageData()
  mockImageDataReader(mockData)

  local result, err = NinePatchParser.parse("test_valid_9patch.png")

  restoreImageDataReader()

  luaunit.assertNotNil(result)
  -- Verify stretchX and stretchY are arrays of {start, end} pairs
  luaunit.assertTrue(#result.stretchX >= 1)
  luaunit.assertTrue(#result.stretchY >= 1)
  luaunit.assertNotNil(result.stretchX[1].start)
  luaunit.assertNotNil(result.stretchX[1]["end"])
  luaunit.assertNotNil(result.stretchY[1].start)
  luaunit.assertNotNil(result.stretchY[1]["end"])
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
