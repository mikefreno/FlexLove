package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, Color, enums = FlexLove.GUI, FlexLove.Color, FlexLove.enums

TestAuxiliaryFunctions = {}

function TestAuxiliaryFunctions:setUp()
  -- Clear any existing GUI elements
  Gui.destroy()
end

function TestAuxiliaryFunctions:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- ============================================
-- Color Utility Functions Tests
-- ============================================

function TestAuxiliaryFunctions:testColorNewBasic()
  local color = Color.new(1, 0.5, 0.2, 0.8)
  luaunit.assertEquals(color.r, 1)
  luaunit.assertEquals(color.g, 0.5)
  luaunit.assertEquals(color.b, 0.2)
  luaunit.assertEquals(color.a, 0.8)
end

function TestAuxiliaryFunctions:testColorNewDefaults()
  -- Test default values when parameters are nil or missing
  local color = Color.new()
  luaunit.assertEquals(color.r, 0)
  luaunit.assertEquals(color.g, 0)
  luaunit.assertEquals(color.b, 0)
  luaunit.assertEquals(color.a, 1) -- Alpha defaults to 1
end

function TestAuxiliaryFunctions:testColorNewPartialDefaults()
  local color = Color.new(0.7, 0.3)
  luaunit.assertEquals(color.r, 0.7)
  luaunit.assertEquals(color.g, 0.3)
  luaunit.assertEquals(color.b, 0)
  luaunit.assertEquals(color.a, 1)
end

function TestAuxiliaryFunctions:testColorFromHex6Digit()
  local color = Color.fromHex("#FF8040")
  -- Note: Color.fromHex actually returns values in 0-255 range, not 0-1
  luaunit.assertEquals(color.r, 255)
  luaunit.assertEquals(color.g, 128)
  luaunit.assertEquals(color.b, 64)
  luaunit.assertEquals(color.a, 1)
end

function TestAuxiliaryFunctions:testColorFromHex8Digit()
  local color = Color.fromHex("#FF8040CC")
  luaunit.assertEquals(color.r, 255)
  luaunit.assertEquals(color.g, 128)
  luaunit.assertEquals(color.b, 64)
  luaunit.assertAlmostEquals(color.a, 204/255, 0.01) -- CC hex = 204 decimal
end

function TestAuxiliaryFunctions:testColorFromHexWithoutHash()
  local color = Color.fromHex("FF8040")
  luaunit.assertEquals(color.r, 255)
  luaunit.assertEquals(color.g, 128)
  luaunit.assertEquals(color.b, 64)
  luaunit.assertEquals(color.a, 1)
end

function TestAuxiliaryFunctions:testColorFromHexInvalid()
  luaunit.assertError(function()
    Color.fromHex("#INVALID")
  end)
  
  luaunit.assertError(function()
    Color.fromHex("#FF80") -- Too short
  end)
  
  luaunit.assertError(function()
    Color.fromHex("#FF8040CC99") -- Too long
  end)
end

function TestAuxiliaryFunctions:testColorToRGBA()
  local color = Color.new(0.8, 0.6, 0.4, 0.9)
  local r, g, b, a = color:toRGBA()
  luaunit.assertEquals(r, 0.8)
  luaunit.assertEquals(g, 0.6)
  luaunit.assertEquals(b, 0.4)
  luaunit.assertEquals(a, 0.9)
end

-- ============================================
-- Element Calculation Utility Tests
-- ============================================

function TestAuxiliaryFunctions:testCalculateTextWidthWithText()
  local element = Gui.new({
    text = "Test Text",
    textSize = 16
  })
  
  local width = element:calculateTextWidth()
  print("Text: '" .. (element.text or "nil") .. "', TextSize: " .. (element.textSize or "nil") .. ", Width: " .. width)
  luaunit.assertTrue(width > 0, "Text width should be greater than 0, got: " .. width)
end

function TestAuxiliaryFunctions:testCalculateTextWidthNoText()
  local element = Gui.new({})
  
  local width = element:calculateTextWidth()
  luaunit.assertEquals(width, 0, "Text width should be 0 when no text")
end

function TestAuxiliaryFunctions:testCalculateTextHeightWithSize()
  local element = Gui.new({
    text = "Test",
    textSize = 24
  })
  
  local height = element:calculateTextHeight()
  luaunit.assertTrue(height > 0, "Text height should be greater than 0")
end

function TestAuxiliaryFunctions:testCalculateAutoWidthNoChildren()
  local element = Gui.new({
    text = "Hello"
  })
  
  local width = element:calculateAutoWidth()
  local textWidth = element:calculateTextWidth()
  luaunit.assertEquals(width, textWidth, "Auto width should equal text width when no children")
end

function TestAuxiliaryFunctions:testCalculateAutoWidthWithChildren()
  local parent = Gui.new({
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL
  })
  
  local child1 = Gui.new({
    parent = parent,
    w = 50,
    h = 30
  })
  
  local child2 = Gui.new({
    parent = parent, 
    w = 40,
    h = 25
  })
  
  local width = parent:calculateAutoWidth()
  luaunit.assertTrue(width > 90, "Auto width should account for children and gaps")
end

function TestAuxiliaryFunctions:testCalculateAutoHeightNoChildren()
  local element = Gui.new({
    text = "Hello"
  })
  
  local height = element:calculateAutoHeight()
  local textHeight = element:calculateTextHeight()
  luaunit.assertEquals(height, textHeight, "Auto height should equal text height when no children")
end

function TestAuxiliaryFunctions:testCalculateAutoHeightWithChildren()
  local parent = Gui.new({
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL
  })
  
  local child1 = Gui.new({
    parent = parent,
    w = 50,
    h = 30
  })
  
  local child2 = Gui.new({
    parent = parent,
    w = 40, 
    h = 25
  })
  
  local height = parent:calculateAutoHeight()
  luaunit.assertTrue(height > 55, "Auto height should account for children and gaps")
end

-- ============================================
-- Element Utility Methods Tests
-- ============================================

function TestAuxiliaryFunctions:testGetBounds()
  local element = Gui.new({
    x = 10,
    y = 20,
    w = 100,
    h = 80
  })
  
  local bounds = element:getBounds()
  luaunit.assertEquals(bounds.x, 10)
  luaunit.assertEquals(bounds.y, 20)
  luaunit.assertEquals(bounds.width, 100)
  luaunit.assertEquals(bounds.height, 80)
end

function TestAuxiliaryFunctions:testUpdateText()
  local element = Gui.new({
    text = "Original Text",
    w = 100,
    h = 50
  })
  
  element:updateText("New Text")
  luaunit.assertEquals(element.text, "New Text")
  luaunit.assertEquals(element.width, 100) -- Should not change without autoresize
  luaunit.assertEquals(element.height, 50)
end

function TestAuxiliaryFunctions:testUpdateTextWithAutoresize()
  local element = Gui.new({
    text = "Short",
    textSize = 16
  })
  
  local originalWidth = element.width
  element:updateText("Much Longer Text That Should Change Width", true)
  
  -- Debug: let's see what the values are
  -- print("Original width: " .. originalWidth .. ", New width: " .. element.width)
  luaunit.assertEquals(element.text, "Much Longer Text That Should Change Width")
  luaunit.assertTrue(element.width > originalWidth, "Width should increase with longer text and autoresize. Original: " .. originalWidth .. ", New: " .. element.width)
end

function TestAuxiliaryFunctions:testUpdateTextKeepOriginalWhenNil()
  local element = Gui.new({
    text = "Original Text"
  })

  element:updateText(nil)
  luaunit.assertEquals(element.text, "Original Text", "Text should remain unchanged when nil is passed")
end

function TestAuxiliaryFunctions:testUpdateOpacitySingle()
  local element = Gui.new({
    opacity = 1.0
  })
  
  element:updateOpacity(0.5)
  luaunit.assertEquals(element.opacity, 0.5)
end

function TestAuxiliaryFunctions:testUpdateOpacityPropagateToChildren()
  local parent = Gui.new({
    opacity = 1.0
  })
  
  local child1 = Gui.new({
    parent = parent,
    opacity = 1.0
  })
  
  local child2 = Gui.new({
    parent = parent,
    opacity = 1.0
  })
  
  parent:updateOpacity(0.3)
  
  luaunit.assertEquals(parent.opacity, 0.3)
  luaunit.assertEquals(child1.opacity, 0.3)
  luaunit.assertEquals(child2.opacity, 0.3)
end

-- ============================================
-- Animation Utility Functions Tests  
-- ============================================

function TestAuxiliaryFunctions:testAnimationFadeFactory()
  local fadeAnim = Gui.Animation.fade(2.0, 1.0, 0.0)
  
  luaunit.assertEquals(fadeAnim.duration, 2.0)
  luaunit.assertEquals(fadeAnim.start.opacity, 1.0)
  luaunit.assertEquals(fadeAnim.final.opacity, 0.0)
  luaunit.assertNotNil(fadeAnim.transform)
  luaunit.assertNotNil(fadeAnim.transition)
end

function TestAuxiliaryFunctions:testAnimationScaleFactory()
  local scaleAnim = Gui.Animation.scale(1.5, {width = 100, height = 50}, {width = 200, height = 100})
  
  luaunit.assertEquals(scaleAnim.duration, 1.5)
  luaunit.assertEquals(scaleAnim.start.width, 100)
  luaunit.assertEquals(scaleAnim.start.height, 50)
  luaunit.assertEquals(scaleAnim.final.width, 200)
  luaunit.assertEquals(scaleAnim.final.height, 100)
end

function TestAuxiliaryFunctions:testAnimationInterpolation()
  local fadeAnim = Gui.Animation.fade(1.0, 1.0, 0.0)
  fadeAnim.elapsed = 0.5 -- 50% through animation
  
  local result = fadeAnim:interpolate()
  luaunit.assertAlmostEquals(result.opacity, 0.5, 0.01) -- Should be halfway
end

function TestAuxiliaryFunctions:testAnimationUpdate()
  local fadeAnim = Gui.Animation.fade(1.0, 1.0, 0.0)
  
  -- Animation should not be finished initially
  local finished = fadeAnim:update(0.5)
  luaunit.assertFalse(finished)
  luaunit.assertEquals(fadeAnim.elapsed, 0.5)
  
  -- Animation should be finished after full duration
  finished = fadeAnim:update(0.6) -- Total 1.1 seconds > 1.0 duration
  luaunit.assertTrue(finished)
end

function TestAuxiliaryFunctions:testAnimationApplyToElement()
  local element = Gui.new({
    w = 100,
    h = 50
  })
  
  local fadeAnim = Gui.Animation.fade(1.0, 1.0, 0.0)
  fadeAnim:apply(element)
  
  luaunit.assertEquals(element.animation, fadeAnim)
end

function TestAuxiliaryFunctions:testAnimationReplaceExisting()
  local element = Gui.new({
    w = 100,
    h = 50
  })
  
  local fadeAnim1 = Gui.Animation.fade(1.0, 1.0, 0.0)
  local fadeAnim2 = Gui.Animation.fade(2.0, 0.5, 1.0)
  
  fadeAnim1:apply(element)
  fadeAnim2:apply(element)
  
  luaunit.assertEquals(element.animation, fadeAnim2, "Second animation should replace the first")
end

-- ============================================
-- GUI Management Utility Tests
-- ============================================

function TestAuxiliaryFunctions:testGuiDestroyEmptyState()
  -- Should not error when destroying empty GUI
  Gui.destroy()
  luaunit.assertEquals(#Gui.topElements, 0)
end

function TestAuxiliaryFunctions:testGuiDestroyWithElements()
  local element1 = Gui.new({
    x = 10,
    y = 10,
    w = 100,
    h = 50
  })
  
  local element2 = Gui.new({
    x = 20,
    y = 20,
    w = 80,
    h = 40
  })
  
  luaunit.assertEquals(#Gui.topElements, 2)
  
  Gui.destroy()
  luaunit.assertEquals(#Gui.topElements, 0)
end

function TestAuxiliaryFunctions:testGuiDestroyWithNestedElements()
  local parent = Gui.new({
    w = 200,
    h = 100
  })
  
  local child1 = Gui.new({
    parent = parent,
    w = 50,
    h = 30
  })
  
  local child2 = Gui.new({
    parent = parent,
    w = 40,
    h = 25
  })
  
  luaunit.assertEquals(#Gui.topElements, 1)
  luaunit.assertEquals(#parent.children, 2)
  
  Gui.destroy()
  luaunit.assertEquals(#Gui.topElements, 0)
end

function TestAuxiliaryFunctions:testElementDestroyRemovesFromParent()
  local parent = Gui.new({
    w = 200,
    h = 100
  })
  
  local child = Gui.new({
    parent = parent,
    w = 50,
    h = 30
  })
  
  luaunit.assertEquals(#parent.children, 1)
  
  child:destroy()
  
  luaunit.assertEquals(#parent.children, 0)
  luaunit.assertNil(child.parent)
end

function TestAuxiliaryFunctions:testElementDestroyRemovesFromTopElements()
  local element = Gui.new({
    x = 10,
    y = 10,
    w = 100,
    h = 50
  })
  
  luaunit.assertEquals(#Gui.topElements, 1)
  
  element:destroy()
  
  luaunit.assertEquals(#Gui.topElements, 0)
end

function TestAuxiliaryFunctions:testElementDestroyNestedChildren()
  local parent = Gui.new({
    w = 200,
    h = 150
  })
  
  local child = Gui.new({
    parent = parent,
    w = 100,
    h = 75
  })
  
  local grandchild = Gui.new({
    parent = child,
    w = 50,
    h = 30
  })
  
  luaunit.assertEquals(#parent.children, 1)
  luaunit.assertEquals(#child.children, 1)
  
  parent:destroy()
  
  luaunit.assertEquals(#Gui.topElements, 0)
  luaunit.assertEquals(#child.children, 0, "Grandchildren should be destroyed")
end

-- ============================================
-- Edge Cases and Error Handling Tests
-- ============================================

function TestAuxiliaryFunctions:testColorFromHexEmptyString()
  luaunit.assertError(function()
    Color.fromHex("")
  end)
end

function TestAuxiliaryFunctions:testColorFromHexNoHashInvalidLength()
  luaunit.assertError(function()
    Color.fromHex("FF80")
  end)
end

function TestAuxiliaryFunctions:testAnimationInterpolationAtBoundaries()
  local scaleAnim = Gui.Animation.scale(1.0, {width = 100, height = 50}, {width = 200, height = 100})
  
  -- At start (elapsed = 0)
  scaleAnim.elapsed = 0
  local result = scaleAnim:interpolate()
  luaunit.assertEquals(result.width, 100)
  luaunit.assertEquals(result.height, 50)
  
  -- At end (elapsed = duration)
  scaleAnim.elapsed = 1.0
  result = scaleAnim:interpolate()
  luaunit.assertEquals(result.width, 200)
  luaunit.assertEquals(result.height, 100)
  
  -- Beyond end (elapsed > duration) - should clamp to end values
  scaleAnim.elapsed = 1.5
  result = scaleAnim:interpolate()
  luaunit.assertEquals(result.width, 200)
  luaunit.assertEquals(result.height, 100)
end

function TestAuxiliaryFunctions:testAutoSizingWithZeroChildren()
  local element = Gui.new({
    text = ""
  })
  
  local width = element:calculateAutoWidth()
  local height = element:calculateAutoHeight() 
  
  luaunit.assertTrue(width >= 0, "Auto width should be non-negative")
  luaunit.assertTrue(height >= 0, "Auto height should be non-negative")
end

function TestAuxiliaryFunctions:testUpdateOpacityBoundaryValues()
  local element = Gui.new({
    opacity = 0.5
  })
  
  -- Test minimum boundary
  element:updateOpacity(0.0)
  luaunit.assertEquals(element.opacity, 0.0)
  
  -- Test maximum boundary  
  element:updateOpacity(1.0)
  luaunit.assertEquals(element.opacity, 1.0)
  
  -- Test beyond boundaries (should still work, implementation may clamp)
  element:updateOpacity(1.5)
  luaunit.assertEquals(element.opacity, 1.5) -- FlexLove doesn't appear to clamp
  
  element:updateOpacity(-0.2)
  luaunit.assertEquals(element.opacity, -0.2) -- FlexLove doesn't appear to clamp
end

-- Run the tests
os.exit(luaunit.LuaUnit.run())