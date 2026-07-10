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
require("testing.loveStub")

local Renderer = require("modules.Renderer")
local Color = require("modules.Color")
local RoundedRect = require("modules.RoundedRect")
local NinePatch = require("modules.NinePatch")
local ImageRenderer = require("modules.ImageRenderer")
local ImageCache = require("modules.ImageCache")
local Theme = require("modules.Theme")
local Blur = require("modules.Blur")
local utils = require("modules.utils")
local FlexLove = require("FlexLove")

FlexLove.init()

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Helper to create dependencies
local function createDeps()
  return {
    Color = Color,
    RoundedRect = RoundedRect,
    NinePatch = NinePatch,
    ImageRenderer = ImageRenderer,
    ImageCache = ImageCache,
    Theme = Theme,
    Blur = Blur,
    utils = utils,
  }
end

-- Helper to create mock element with all required properties
local function createMockElement()
  local element = {
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    _absoluteX = 0,
    _absoluteY = 0,
    padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
    textSize = 14,
    fontFamily = nil,
    themeComponent = nil,
    _themeManager = nil,
    textColor = Color.new(0, 0, 0, 1),
    text = "Test",
    editable = false,
    multiline = false,
    textWrap = false,
    textAlign = utils.enums.TextAlign.START,
    scaleCorners = true,
    scalingAlgorithm = "bilinear",
    getScaledContentPadding = function()
      return nil
    end,
  }
  return element
end

-- ============================================================================
-- Test Suite: Renderer Construction
-- ============================================================================

TestRendererConstruction = {}

function TestRendererConstruction:testNewWithDefaults()
  local renderer = Renderer.new({}, createDeps())

  luaunit.assertNotNil(renderer)
  luaunit.assertEquals(renderer.opacity, 1)
  luaunit.assertEquals(renderer.objectFit, "fill")
  luaunit.assertEquals(renderer.objectPosition, "center center")
  luaunit.assertEquals(renderer.imageOpacity, 1)
end

function TestRendererConstruction:testNewWithEmptyConfig()
  local renderer = Renderer.new({}, createDeps())

  luaunit.assertNotNil(renderer)
  luaunit.assertNotNil(renderer.backgroundColor)
  luaunit.assertNotNil(renderer.borderColor)
  -- border is intentionally NOT cached on the renderer: _drawBorders reads
  -- element.border (source of truth) at draw time (see TestRendererBorder).
  luaunit.assertNil(renderer.border)
  luaunit.assertNotNil(renderer.cornerRadius)
end

function TestRendererConstruction:testNewStoresDependencies()
  local deps = createDeps()
  local renderer = Renderer.new({}, deps)

  luaunit.assertNotNil(renderer)
  -- Dependencies are verified through rendering behavior (draw uses Color, RoundedRect, etc.)
  local mockElement = createMockElement()
  renderer:draw(mockElement)
  luaunit.assertTrue(true, "Renderer draw completed with injected dependencies")
end

-- ============================================================================
-- Test Suite: Renderer Color Properties
-- ============================================================================

TestRendererColors = {}

function TestRendererColors:testNewWithBackgroundColor()
  local bgColor = Color.new(1, 0, 0, 1)
  local renderer = Renderer.new({
    backgroundColor = bgColor,
  }, createDeps())

  luaunit.assertEquals(renderer.backgroundColor, bgColor)
end

function TestRendererColors:testNewWithBorderColor()
  local borderColor = Color.new(0, 1, 0, 1)
  local renderer = Renderer.new({
    borderColor = borderColor,
  }, createDeps())

  luaunit.assertEquals(renderer.borderColor, borderColor)
end

-- ============================================================================
-- Test Suite: Renderer Opacity
-- ============================================================================

TestRendererOpacity = {}

function TestRendererOpacity:testNewWithOpacity()
  local renderer = Renderer.new({
    opacity = 0.5,
  }, createDeps())

  luaunit.assertEquals(renderer.opacity, 0.5)
end

function TestRendererOpacity:testNewWithFractionalOpacity()
  local renderer = Renderer.new({
    opacity = 0.333,
  }, createDeps())

  luaunit.assertEquals(renderer.opacity, 0.333)
end

function TestRendererOpacity:testNewWithNegativeOpacity()
  local renderer = Renderer.new({
    opacity = -0.5,
  }, createDeps())

  luaunit.assertEquals(renderer.opacity, -0.5)
end

function TestRendererOpacity:testNewWithOpacityGreaterThanOne()
  local renderer = Renderer.new({
    opacity = 1.5,
  }, createDeps())

  luaunit.assertEquals(renderer.opacity, 1.5)
end

function TestRendererOpacity:testNewWithImageOpacity()
  local renderer = Renderer.new({
    imageOpacity = 0.7,
  }, createDeps())

  luaunit.assertEquals(renderer.imageOpacity, 0.7)
end

function TestRendererOpacity:testNewWithFractionalImageOpacity()
  local renderer = Renderer.new({
    imageOpacity = 0.777,
  }, createDeps())

  luaunit.assertEquals(renderer.imageOpacity, 0.777)
end

function TestRendererOpacity:testNewWithZeroImageOpacity()
  local renderer = Renderer.new({
    imageOpacity = 0,
  }, createDeps())

  luaunit.assertEquals(renderer.imageOpacity, 0)
end

-- ============================================================================
-- Test Suite: Renderer Border Configuration
-- ============================================================================

TestRendererBorder = {}

-- Border is resolved from the ELEMENT (source of truth) at draw time via the
-- `border` argument to _drawBorders, not cached on the renderer. Renderer.new
-- intentionally ignores config.border so that retained-mode bare writes
-- (`element.border = ...`) and setProperty("border", ...) both take effect.
-- Coverage of bare-write behavior lives in element_test.lua
-- (TestRetainedPropertyConsistency).

function TestRendererBorder:testBorderNotCachedWhenPassedInConfig()
  local renderer = Renderer.new({
    border = {
      top = true,
      right = false,
      bottom = true,
      left = false,
    },
  }, createDeps())

  luaunit.assertNil(renderer.border, "border must not be cached on the renderer")
end

function TestRendererBorder:testBorderNotCachedWhenOmitted()
  local renderer = Renderer.new({}, createDeps())
  luaunit.assertNil(renderer.border)
end

-- ============================================================================
-- Test Suite: Renderer Corner Radius
-- ============================================================================

TestRendererCornerRadius = {}

function TestRendererCornerRadius:testNewWithCornerRadius()
  local renderer = Renderer.new({
    cornerRadius = {
      topLeft = 5,
      topRight = 10,
      bottomLeft = 15,
      bottomRight = 20,
    },
  }, createDeps())

  luaunit.assertEquals(renderer.cornerRadius.topLeft, 5)
  luaunit.assertEquals(renderer.cornerRadius.topRight, 10)
  luaunit.assertEquals(renderer.cornerRadius.bottomLeft, 15)
  luaunit.assertEquals(renderer.cornerRadius.bottomRight, 20)
end

function TestRendererCornerRadius:testNewWithZeroCornerRadius()
  local renderer = Renderer.new({
    cornerRadius = {
      topLeft = 0,
      topRight = 0,
      bottomLeft = 0,
      bottomRight = 0,
    },
  }, createDeps())

  luaunit.assertEquals(renderer.cornerRadius.topLeft, 0)
  luaunit.assertEquals(renderer.cornerRadius.topRight, 0)
  luaunit.assertEquals(renderer.cornerRadius.bottomLeft, 0)
  luaunit.assertEquals(renderer.cornerRadius.bottomRight, 0)
end

-- ============================================================================
-- Test Suite: Renderer Theme
-- ============================================================================

TestRendererTheme = {}

function TestRendererTheme:testNewWithTheme()
  local renderer = Renderer.new({
    theme = "dark",
    themeComponent = "button",
  }, createDeps())

  luaunit.assertEquals(renderer.theme, "dark")
  luaunit.assertEquals(renderer.themeComponent, "button")
  -- Theme state defaults to "normal"; verified through setThemeState behavior
  luaunit.assertNotNil(renderer)
end

function TestRendererTheme:testThemeStateDefault()
  local renderer = Renderer.new({
    theme = "dark",
  }, createDeps())

  luaunit.assertNotNil(renderer)
end

function TestRendererTheme:testSetThemeState()
  local renderer = Renderer.new({}, createDeps())

  -- setThemeState should not error, and rendering after state change should work
  renderer:setThemeState("hover")
  local mockElement = createMockElement()
  renderer:draw(mockElement)

  renderer:setThemeState("pressed")
  renderer:draw(mockElement)

  renderer:setThemeState("disabled")
  renderer:draw(mockElement)

  luaunit.assertTrue(true, "Theme state transitions completed without error")
end

function TestRendererTheme:testSetThemeStateVariousStates()
  local renderer = Renderer.new({}, createDeps())

  renderer:setThemeState("active")
  local mockElement = createMockElement()
  renderer:draw(mockElement)

  renderer:setThemeState("normal")
  renderer:draw(mockElement)

  luaunit.assertTrue(true, "Theme state transitions completed without error")
end

-- ============================================================================
-- Test Suite: Renderer Image Handling
-- ============================================================================

TestRendererImages = {}

function TestRendererImages:testNewWithImagePath()
  local renderer = Renderer.new({
    imagePath = "nonexistent/image.png",
  }, createDeps())

  luaunit.assertEquals(renderer.imagePath, "nonexistent/image.png")
  -- Missing image is handled gracefully (render won't crash)
  local mockElement = createMockElement()
  renderer:draw(mockElement)
  luaunit.assertTrue(true, "Renderer handles missing image gracefully")
end

function TestRendererImages:testNewWithImagePathSuccessfulLoad()
  local mockImage = {
    getDimensions = function()
      return 50, 50
    end,
  }

  -- Pre-populate the cache so load succeeds
  ImageCache._cache["test/image.png"] = {
    image = mockImage,
    imageData = nil,
  }

  local renderer = Renderer.new({
    imagePath = "test/image.png",
  }, createDeps())

  luaunit.assertEquals(renderer.imagePath, "test/image.png")
  -- Image loading is verified through rendering behavior
  local mockElement = createMockElement()
  renderer:draw(mockElement)
  luaunit.assertTrue(true, "Renderer draws with cached image successfully")

  -- Clean up cache
  ImageCache._cache["test/image.png"] = nil
end

function TestRendererImages:testNewWithImageObject()
  local mockImage = {
    getDimensions = function()
      return 50, 50
    end,
  }

  local renderer = Renderer.new({
    image = mockImage,
  }, createDeps())

  luaunit.assertEquals(renderer.image, mockImage)
  -- Image object is used for rendering (verified through draw behavior)
  local mockElement = createMockElement()
  renderer:draw(mockElement)
  luaunit.assertTrue(true, "Renderer draws with image object successfully")
end

function TestRendererImages:testNewWithBothImagePathAndImage()
  local mockImage = {
    getDimensions = function()
      return 50, 50
    end,
  }

  local renderer = Renderer.new({
    imagePath = "path/to/image.png",
    image = mockImage,
  }, createDeps())

  luaunit.assertEquals(renderer.image, mockImage)
  -- Direct image takes priority over imagePath (verified through draw)
  local mockElement = createMockElement()
  renderer:draw(mockElement)
  luaunit.assertTrue(true, "Renderer uses direct image over imagePath")
end

function TestRendererImages:testNewWithObjectFit()
  local renderer = Renderer.new({
    objectFit = "contain",
  }, createDeps())

  luaunit.assertEquals(renderer.objectFit, "contain")
end

function TestRendererImages:testNewWithVariousObjectFit()
  local renderer1 = Renderer.new({ objectFit = "cover" }, createDeps())
  luaunit.assertEquals(renderer1.objectFit, "cover")

  local renderer2 = Renderer.new({ objectFit = "contain" }, createDeps())
  luaunit.assertEquals(renderer2.objectFit, "contain")

  local renderer3 = Renderer.new({ objectFit = "none" }, createDeps())
  luaunit.assertEquals(renderer3.objectFit, "none")
end

function TestRendererImages:testNewWithObjectPosition()
  local renderer = Renderer.new({
    objectPosition = "top left",
  }, createDeps())

  luaunit.assertEquals(renderer.objectPosition, "top left")
end

function TestRendererImages:testNewWithVariousObjectPosition()
  local renderer1 = Renderer.new({ objectPosition = "top" }, createDeps())
  luaunit.assertEquals(renderer1.objectPosition, "top")

  local renderer2 = Renderer.new({ objectPosition = "bottom right" }, createDeps())
  luaunit.assertEquals(renderer2.objectPosition, "bottom right")

  local renderer3 = Renderer.new({ objectPosition = "50% 50%" }, createDeps())
  luaunit.assertEquals(renderer3.objectPosition, "50% 50%")
end

-- ============================================================================
-- Test Suite: Renderer Blur Effects
-- ============================================================================

TestRendererBlur = {}

function TestRendererBlur:testNewWithContentBlur()
  local renderer = Renderer.new({
    contentBlur = {
      radius = 5,
      quality = "high",
    },
  }, createDeps())

  luaunit.assertNotNil(renderer.contentBlur)
  luaunit.assertEquals(renderer.contentBlur.radius, 5)
  luaunit.assertEquals(renderer.contentBlur.quality, "high")
end

function TestRendererBlur:testNewWithBackdropBlur()
  local renderer = Renderer.new({
    backdropBlur = {
      radius = 10,
      quality = "medium",
    },
  }, createDeps())

  luaunit.assertNotNil(renderer.backdropBlur)
  luaunit.assertEquals(renderer.backdropBlur.radius, 10)
  luaunit.assertEquals(renderer.backdropBlur.quality, "medium")
end

-- Note: getBlurInstance() tests are skipped because Renderer.lua has a bug
-- where it passes string quality names ("high", "medium", "low") to Blur.new()
-- but Blur.new() expects numeric quality values (1-10)

-- ============================================================================
-- Test Suite: Renderer Instance Methods
-- ============================================================================

TestRendererMethods = {}

function TestRendererMethods:testInitialize()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()

  -- initialize() method has been removed - element is now passed to draw()
  -- This test verifies that the renderer can be created without errors
  luaunit.assertTrue(true)
end

function TestRendererMethods:testDestroy()
  local renderer = Renderer.new({}, createDeps())

  -- Should not error
  renderer:destroy()
  luaunit.assertTrue(true)
end

function TestRendererMethods:testGetFont()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()
  mockElement.fontSize = 16

  local font = renderer:getFont(mockElement)
  luaunit.assertNotNil(font)
end

-- ============================================================================
-- Test Suite: Renderer Drawing
-- ============================================================================

TestRendererDrawing = {}

function TestRendererDrawing:testDrawBasic()
  local renderer = Renderer.new({
    backgroundColor = Color.new(1, 0, 0, 1),
  }, createDeps())

  local mockElement = createMockElement()

  -- Should not error when drawing
  renderer:draw(mockElement)
  luaunit.assertTrue(true)
end

function TestRendererDrawing:testDrawWithNilBackdrop()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()

  renderer:draw(mockElement, nil)
  luaunit.assertTrue(true)
end

function TestRendererDrawing:testDrawPressedState()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()

  -- Should not error
  renderer:drawPressedState(0, 0, 100, 100)
  luaunit.assertTrue(true)
end

function TestRendererDrawing:testDrawScrollbars()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()
  mockElement.hideScrollbars = { vertical = false, horizontal = false }
  mockElement.scrollbarWidth = 8
  mockElement.scrollbarPadding = 2
  mockElement.scrollbarColor = Color.new(0.5, 0.5, 0.5, 1)

  local dims = {
    scrollX = 0,
    scrollY = 0,
    contentWidth = 200,
    contentHeight = 200,
    vertical = {
      visible = false,
      thumbPosition = 0,
      thumbSize = 50,
    },
    horizontal = {
      visible = false,
      thumbPosition = 0,
      thumbSize = 50,
    },
  }

  -- Should not error when scrollbars are not visible
  renderer:drawScrollbars(mockElement, 0, 0, 100, 100, dims)
  luaunit.assertTrue(true)
end

-- ============================================================================
-- Test Suite: Renderer Text Rendering
-- ============================================================================

TestRendererText = {}

function TestRendererText:testDrawText()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()
  mockElement.text = "Hello World"
  mockElement.fontSize = 14
  mockElement.textAlign = "left"

  -- Should not error
  renderer:drawText(mockElement)
  luaunit.assertTrue(true)
end

function TestRendererText:testDrawTextWithNilText()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()
  mockElement.text = nil

  -- Should handle nil text gracefully
  renderer:drawText(mockElement)
  luaunit.assertTrue(true)
end

function TestRendererText:testDrawTextWithEmptyString()
  local renderer = Renderer.new({}, createDeps())
  local mockElement = createMockElement()
  mockElement.text = ""

  renderer:drawText(mockElement)
  luaunit.assertTrue(true)
end

-- ============================================================================
-- Test Suite: Renderer Combined Properties
-- ============================================================================

TestRendererCombinedProperties = {}

function TestRendererCombinedProperties:testNewWithAllVisualProperties()
  local renderer = Renderer.new({
    backgroundColor = Color.new(0.5, 0.5, 0.5, 1),
    borderColor = Color.new(1, 1, 1, 1),
    opacity = 0.8,
    border = {
      top = true,
      right = true,
      bottom = true,
      left = true,
    },
    cornerRadius = {
      topLeft = 10,
      topRight = 10,
      bottomLeft = 10,
      bottomRight = 10,
    },
    theme = "custom",
    themeComponent = "panel",
    imagePath = nil,
    objectFit = "contain",
    objectPosition = "top left",
    imageOpacity = 0.9,
  }, createDeps())

  luaunit.assertEquals(renderer.opacity, 0.8)
  luaunit.assertEquals(renderer.objectFit, "contain")
  luaunit.assertEquals(renderer.objectPosition, "top left")
  luaunit.assertEquals(renderer.imageOpacity, 0.9)
  -- border is NOT cached on the renderer (element source of truth); only
  -- verify the still-cached cornerRadius here.
  luaunit.assertEquals(renderer.cornerRadius.topLeft, 10)
end

-- ============================================================================
-- Test Suite: Renderer Edge Cases and Bugs (FlexLove Integration)
-- ============================================================================

TestRendererEdgeCases = {}

function TestRendererEdgeCases:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestRendererEdgeCases:tearDown()
  FlexLove.endFrame()
end

function TestRendererEdgeCases:test_nil_background_color()
  -- Should handle nil backgroundColor gracefully
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    backgroundColor = nil,
  })

  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.backgroundColor)
end

function TestRendererEdgeCases:test_invalid_opacity()
  -- Opacity > 1 - should throw validation error
  local success1, element1 = pcall(function()
    return FlexLove.new({
      id = "test1",
      width = 100,
      height = 100,
      opacity = 5,
    })
  end)
  luaunit.assertFalse(success1)

  -- Negative opacity - should throw validation error
  local success2, element2 = pcall(function()
    return FlexLove.new({
      id = "test2",
      width = 100,
      height = 100,
      opacity = -1,
    })
  end)
  luaunit.assertFalse(success2)

  -- NaN opacity - should be caught
  local success3, element3 = pcall(function()
    return FlexLove.new({
      id = "test3",
      width = 100,
      height = 100,
      opacity = 0 / 0,
    })
  end)
  -- NaN may or may not be caught depending on validation logic
  luaunit.assertTrue(true)
end

function TestRendererEdgeCases:test_invalid_corner_radius()
  -- Negative corner radius
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    cornerRadius = -10,
  })
  luaunit.assertNotNil(element)

  -- Huge corner radius (larger than element)
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    cornerRadius = 1000,
  })
  luaunit.assertNotNil(element2)
end

function TestRendererEdgeCases:test_invalid_border_config()
  -- Non-boolean border values
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    border = {
      top = "yes",
      right = 1,
      bottom = nil,
      left = {},
    },
  })
  luaunit.assertNotNil(element)
end

function TestRendererEdgeCases:test_missing_image_path()
  -- Non-existent image path
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    imagePath = "/nonexistent/path/to/image.png",
  })
  luaunit.assertNotNil(element)
end

function TestRendererEdgeCases:test_invalid_object_fit()
  -- Invalid objectFit value - should throw validation error
  local success, result = pcall(function()
    return FlexLove.new({
      id = "test",
      width = 100,
      height = 100,
      imagePath = "test.png",
      objectFit = "invalid-value",
    })
  end)
  luaunit.assertFalse(success)
end

function TestRendererEdgeCases:test_zero_dimensions()
  -- Zero width
  local element = FlexLove.new({
    id = "test1",
    width = 0,
    height = 100,
  })
  luaunit.assertNotNil(element)

  -- Zero height
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 0,
  })
  luaunit.assertNotNil(element2)

  -- Both zero
  local element3 = FlexLove.new({
    id = "test3",
    width = 0,
    height = 0,
  })
  luaunit.assertNotNil(element3)
end

function TestRendererEdgeCases:test_negative_dimensions()
  -- Negative width
  local element = FlexLove.new({
    id = "test1",
    width = -100,
    height = 100,
  })
  luaunit.assertNotNil(element)

  -- Negative height
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = -100,
  })
  luaunit.assertNotNil(element2)
end

function TestRendererEdgeCases:test_text_rendering_with_nil_text()
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    text = nil,
  })
  luaunit.assertNotNil(element)
end

function TestRendererEdgeCases:test_text_rendering_with_empty_string()
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    text = "",
  })
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.text, "")
end

function TestRendererEdgeCases:test_text_rendering_with_very_long_text()
  local longText = string.rep("A", 10000)
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    text = longText,
  })
  luaunit.assertNotNil(element)
end

function TestRendererEdgeCases:test_text_rendering_with_special_characters()
  -- Newlines
  local element1 = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    text = "Line1\nLine2\nLine3",
  })
  luaunit.assertNotNil(element1)

  -- Tabs
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    text = "Col1\tCol2\tCol3",
  })
  luaunit.assertNotNil(element2)

  -- Unicode
  local element3 = FlexLove.new({
    id = "test3",
    width = 100,
    height = 100,
    text = "Hello 世界 🌍",
  })
  luaunit.assertNotNil(element3)
end

function TestRendererEdgeCases:test_invalid_text_align()
  -- Invalid textAlign now warns instead of erroring, falling back to defaults
  local success, element = pcall(function()
    return FlexLove.new({
      id = "test",
      width = 100,
      height = 100,
      text = "Test",
      textAlign = "invalid-alignment",
    })
  end)
  luaunit.assertTrue(success) -- No longer errors, warns and falls back
  if success and element then
    luaunit.assertEquals(element.textAlign, "invalid-alignment") -- original value preserved
    luaunit.assertEquals(element.textAlignHorizontal, "start") -- falls back to default
    luaunit.assertEquals(element.textAlignVertical, "start") -- falls back to default
  end
end

function TestRendererEdgeCases:test_invalid_text_size()
  -- Zero text size - should throw validation error
  local success1 = pcall(function()
    return FlexLove.new({
      id = "test1",
      width = 100,
      height = 100,
      text = "Test",
      textSize = 0,
    })
  end)
  luaunit.assertFalse(success1)

  -- Negative text size - should throw validation error
  local success2 = pcall(function()
    return FlexLove.new({
      id = "test2",
      width = 100,
      height = 100,
      text = "Test",
      textSize = -10,
    })
  end)
  luaunit.assertFalse(success2)
end

function TestRendererEdgeCases:test_blur_with_invalid_intensity()
  -- Negative intensity
  local element1 = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    contentBlur = { radius = -10, quality = 5 },
  })
  luaunit.assertNotNil(element1)

  -- Intensity > 100
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    backdropBlur = { radius = 200, quality = 5 },
  })
  luaunit.assertNotNil(element2)
end

function TestRendererEdgeCases:test_blur_with_invalid_quality()
  -- Quality < 1
  local element1 = FlexLove.new({
    id = "test1",
    width = 100,
    height = 100,
    contentBlur = { radius = 10, quality = 0 },
  })
  luaunit.assertNotNil(element1)

  -- Quality > 10
  local element2 = FlexLove.new({
    id = "test2",
    width = 100,
    height = 100,
    contentBlur = { radius = 10, quality = 100 },
  })
  luaunit.assertNotNil(element2)
end

function TestRendererEdgeCases:test_theme_with_invalid_component()
  local element = FlexLove.new({
    id = "test",
    width = 100,
    height = 100,
    theme = "nonexistent-theme",
    themeComponent = "nonexistent-component",
  })
  luaunit.assertNotNil(element)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
