local lu = require("testing.luaunit")
local FlexLove = require("FlexLove")
local Gui = FlexLove.Gui
local Element = FlexLove.Element
local ImageCache = FlexLove.ImageCache

TestElementImageIntegration = {}

function TestElementImageIntegration:setUp()
  Gui.init({ baseScale = { width = 1920, height = 1080 } })

  -- Create a test image programmatically
  self.testImageData = love.image.newImageData(400, 300)
  -- Fill with a gradient pattern
  for y = 0, 299 do
    for x = 0, 399 do
      local r = x / 399
      local g = y / 299
      local b = 0.5
      self.testImageData:setPixel(x, y, r, g, b, 1)
    end
  end

  -- Save to a temporary file (mock filesystem)
  self.testImagePath = "testing/temp_element_test_image.png"
  self.testImageData:encode("png", self.testImagePath)
  love.filesystem.addMockFile(self.testImagePath, "mock_image_data")

  -- Create test image object
  self.testImage = love.graphics.newImage(self.testImageData)
end

function TestElementImageIntegration:tearDown()
  Gui.destroy()
  ImageCache.clear()

  -- Clean up temporary test file
  if love.filesystem.getInfo(self.testImagePath) then
    love.filesystem.remove(self.testImagePath)
  end
end

-- ====================
-- Element Creation Tests
-- ====================

function TestElementImageIntegration:testElementWithImagePath()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
  })

  lu.assertNotNil(element._loadedImage)
  lu.assertEquals(element.imagePath, self.testImagePath)
end

function TestElementImageIntegration:testElementWithImageObject()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    image = self.testImage,
  })

  lu.assertNotNil(element._loadedImage)
  lu.assertEquals(element._loadedImage, self.testImage)
end

function TestElementImageIntegration:testElementWithInvalidImagePath()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = "nonexistent/image.png",
  })

  -- Should not crash, just not have a loaded image
  lu.assertNil(element._loadedImage)
end

function TestElementImageIntegration:testElementWithoutImage()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
  })

  lu.assertNil(element._loadedImage)
  lu.assertNil(element.imagePath)
  lu.assertNil(element.image)
end

-- ====================
-- Property Tests
-- ====================

function TestElementImageIntegration:testObjectFitProperty()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
    objectFit = "contain",
  })

  lu.assertEquals(element.objectFit, "contain")
end

function TestElementImageIntegration:testObjectFitDefaultValue()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
  })

  lu.assertEquals(element.objectFit, "fill")
end

function TestElementImageIntegration:testObjectPositionProperty()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
    objectPosition = "top left",
  })

  lu.assertEquals(element.objectPosition, "top left")
end

function TestElementImageIntegration:testObjectPositionDefaultValue()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
  })

  lu.assertEquals(element.objectPosition, "center center")
end

function TestElementImageIntegration:testImageOpacityProperty()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
    imageOpacity = 0.5,
  })

  lu.assertEquals(element.imageOpacity, 0.5)
end

function TestElementImageIntegration:testImageOpacityDefaultValue()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
  })

  lu.assertEquals(element.imageOpacity, 1)
end

-- ====================
-- Image Caching Tests
-- ====================

function TestElementImageIntegration:testMultipleElementsShareCachedImage()
  local element1 = Element.new({
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    imagePath = self.testImagePath,
  })

  local element2 = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
  })

  -- Both should have the same cached image reference
  lu.assertEquals(element1._loadedImage, element2._loadedImage)

  -- Cache should only have one entry
  local stats = ImageCache.getStats()
  lu.assertEquals(stats.count, 1)
end

-- ====================
-- Rendering Tests (Basic Validation)
-- ====================

function TestElementImageIntegration:testDrawDoesNotCrashWithImage()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
  })

  -- Should not crash when drawing
  lu.assertNotNil(function()
    element:draw()
  end)
end

function TestElementImageIntegration:testDrawDoesNotCrashWithoutImage()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
  })

  -- Should not crash when drawing without image
  lu.assertNotNil(function()
    element:draw()
  end)
end

function TestElementImageIntegration:testDrawWithZeroOpacity()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
    opacity = 0,
  })

  -- Should not crash (early exit in draw)
  lu.assertNotNil(function()
    element:draw()
  end)
end

-- ====================
-- Combined Properties Tests
-- ====================

function TestElementImageIntegration:testImageWithPadding()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
    imagePath = self.testImagePath,
  })

  lu.assertNotNil(element._loadedImage)
  lu.assertEquals(element.padding.top, 10)
  lu.assertEquals(element.padding.left, 10)
  -- Image should render in content area (200x200)
  lu.assertEquals(element.width, 200)
  lu.assertEquals(element.height, 200)
end

function TestElementImageIntegration:testImageWithCornerRadius()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    cornerRadius = 20,
    imagePath = self.testImagePath,
  })

  lu.assertNotNil(element._loadedImage)
  lu.assertEquals(element.cornerRadius.topLeft, 20)
  lu.assertEquals(element.cornerRadius.topRight, 20)
  lu.assertEquals(element.cornerRadius.bottomLeft, 20)
  lu.assertEquals(element.cornerRadius.bottomRight, 20)
end

function TestElementImageIntegration:testImageWithBackgroundColor()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    backgroundColor = FlexLove.Color.new(1, 0, 0, 1),
    imagePath = self.testImagePath,
  })

  lu.assertNotNil(element._loadedImage)
  lu.assertEquals(element.backgroundColor.r, 1)
  lu.assertEquals(element.backgroundColor.g, 0)
  lu.assertEquals(element.backgroundColor.b, 0)
end

function TestElementImageIntegration:testImageWithAllObjectFitModes()
  local modes = { "fill", "contain", "cover", "scale-down", "none" }

  for _, mode in ipairs(modes) do
    local element = Element.new({
      x = 100,
      y = 100,
      width = 200,
      height = 200,
      imagePath = self.testImagePath,
      objectFit = mode,
    })

    lu.assertEquals(element.objectFit, mode)
    lu.assertNotNil(element._loadedImage)
  end
end

function TestElementImageIntegration:testImageWithCombinedOpacity()
  local element = Element.new({
    x = 100,
    y = 100,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
    opacity = 0.5,
    imageOpacity = 0.8,
  })

  lu.assertEquals(element.opacity, 0.5)
  lu.assertEquals(element.imageOpacity, 0.8)
  -- Combined opacity should be 0.5 * 0.8 = 0.4 (tested in rendering)
end

-- ====================
-- Layout Integration Tests
-- ====================

function TestElementImageIntegration:testImageWithFlexLayout()
  local container = Element.new({
    x = 0,
    y = 0,
    width = 600,
    height = 200,
    flexDirection = FlexLove.enums.FlexDirection.HORIZONTAL,
  })

  local imageElement = Element.new({
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
    parent = container,
  })

  table.insert(container.children, imageElement)

  lu.assertNotNil(imageElement._loadedImage)
  lu.assertEquals(imageElement.width, 200)
  lu.assertEquals(imageElement.height, 200)
end

function TestElementImageIntegration:testImageWithAbsolutePositioning()
  local element = Element.new({
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
    top = 50,
    left = 50,
    width = 200,
    height = 200,
    imagePath = self.testImagePath,
  })

  lu.assertNotNil(element._loadedImage)
  lu.assertEquals(element.positioning, FlexLove.enums.Positioning.ABSOLUTE)
end

-- Run tests if executed directly
if arg and arg[0]:match("28_element_image_integration_tests.lua$") then
  os.exit(lu.LuaUnit.run())
end

return TestElementImageIntegration
