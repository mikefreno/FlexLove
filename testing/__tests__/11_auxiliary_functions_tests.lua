package.path = package.path .. ";?.lua"

local luaunit = require("testing.luaunit")
require("testing.loveStub")
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
  luaunit.assertAlmostEquals(color.a, 204 / 255, 0.01) -- CC hex = 204 decimal
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
    textSize = 16,
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
    textSize = 24,
  })

  local height = element:calculateTextHeight()
  luaunit.assertTrue(height > 0, "Text height should be greater than 0")
end

function TestAuxiliaryFunctions:testCalculateAutoWidthNoChildren()
  local element = Gui.new({
    text = "Hello",
  })

  local width = element:calculateAutoWidth()
  local textWidth = element:calculateTextWidth()
  luaunit.assertEquals(width, textWidth, "Auto width should equal text width when no children")
end

function TestAuxiliaryFunctions:testCalculateAutoWidthWithChildren()
  local parent = Gui.new({
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    gap = 5, -- Add gap to test gap calculation
  })

  local child1 = Gui.new({
    parent = parent,
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    parent = parent,
    width = 40,
    height = 25,
  })

  local width = parent:calculateAutoWidth()
  luaunit.assertTrue(width > 90, "Auto width should account for children and gaps")
end

function TestAuxiliaryFunctions:testCalculateAutoHeightNoChildren()
  local element = Gui.new({
    text = "Hello",
  })

  local height = element:calculateAutoHeight()
  local textHeight = element:calculateTextHeight()
  luaunit.assertEquals(height, textHeight, "Auto height should equal text height when no children")
end

function TestAuxiliaryFunctions:testCalculateAutoHeightWithChildren()
  local parent = Gui.new({
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 5, -- Add gap to test gap calculation
  })

  local child1 = Gui.new({
    parent = parent,
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    parent = parent,
    width = 40,
    height = 25,
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
    width = 100,
    height = 80,
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
    width = 100,
    height = 50,
  })

  element:updateText("New Text")
  luaunit.assertEquals(element.text, "New Text")
  luaunit.assertEquals(element.width, 100) -- Should not change without autoresize
  luaunit.assertEquals(element.height, 50)
end

function TestAuxiliaryFunctions:testUpdateTextWithAutoresize()
  local element = Gui.new({
    text = "Short",
    textSize = 16,
  })

  local originalWidth = element.width
  element:updateText("Much Longer Text That Should Change Width", true)

  -- Debug: let's see what the values are
  -- print("Original width: " .. originalWidth .. ", New width: " .. element.width)
  luaunit.assertEquals(element.text, "Much Longer Text That Should Change Width")
  luaunit.assertTrue(
    element.width > originalWidth,
    "Width should increase with longer text and autoresize. Original: " .. originalWidth .. ", New: " .. element.width
  )
end

function TestAuxiliaryFunctions:testUpdateTextKeepOriginalWhenNil()
  local element = Gui.new({
    text = "Original Text",
  })

  element:updateText(nil)
  luaunit.assertEquals(element.text, "Original Text", "Text should remain unchanged when nil is passed")
end

function TestAuxiliaryFunctions:testUpdateOpacitySingle()
  local element = Gui.new({
    opacity = 1.0,
  })

  element:updateOpacity(0.5)
  luaunit.assertEquals(element.opacity, 0.5)
end

function TestAuxiliaryFunctions:testUpdateOpacityPropagateToChildren()
  local parent = Gui.new({
    opacity = 1.0,
  })

  local child1 = Gui.new({
    parent = parent,
    opacity = 1.0,
  })

  local child2 = Gui.new({
    parent = parent,
    opacity = 1.0,
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
  local scaleAnim = Gui.Animation.scale(1.5, { width = 100, height = 50 }, { width = 200, height = 100 })

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
    width = 100,
    height = 50,
  })

  local fadeAnim = Gui.Animation.fade(1.0, 1.0, 0.0)
  fadeAnim:apply(element)

  luaunit.assertEquals(element.animation, fadeAnim)
end

function TestAuxiliaryFunctions:testAnimationReplaceExisting()
  local element = Gui.new({
    width = 100,
    height = 50,
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
    width = 100,
    height = 50,
  })

  local element2 = Gui.new({
    x = 20,
    y = 20,
    width = 80,
    height = 40,
  })

  luaunit.assertEquals(#Gui.topElements, 2)

  Gui.destroy()
  luaunit.assertEquals(#Gui.topElements, 0)
end

function TestAuxiliaryFunctions:testGuiDestroyWithNestedElements()
  local parent = Gui.new({
    width = 200,
    height = 100,
  })

  local child1 = Gui.new({
    parent = parent,
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    parent = parent,
    width = 40,
    height = 25,
  })

  luaunit.assertEquals(#Gui.topElements, 1)
  luaunit.assertEquals(#parent.children, 2)

  Gui.destroy()
  luaunit.assertEquals(#Gui.topElements, 0)
end

function TestAuxiliaryFunctions:testElementDestroyRemovesFromParent()
  local parent = Gui.new({
    width = 200,
    height = 100,
  })

  local child = Gui.new({
    parent = parent,
    width = 50,
    height = 30,
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
    width = 100,
    height = 50,
  })

  luaunit.assertEquals(#Gui.topElements, 1)

  element:destroy()

  luaunit.assertEquals(#Gui.topElements, 0)
end

function TestAuxiliaryFunctions:testElementDestroyNestedChildren()
  local parent = Gui.new({
    width = 200,
    height = 150,
  })

  local child = Gui.new({
    parent = parent,
    width = 100,
    height = 75,
  })

  local grandchild = Gui.new({
    parent = child,
    width = 50,
    height = 30,
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
  local scaleAnim = Gui.Animation.scale(1.0, { width = 100, height = 50 }, { width = 200, height = 100 })

  -- At start (elapsed = 0)
  scaleAnim.elapsed = 0
  scaleAnim._resultDirty = true -- Mark dirty after changing elapsed
  local result = scaleAnim:interpolate()
  luaunit.assertEquals(result.width, 100)
  luaunit.assertEquals(result.height, 50)

  -- At end (elapsed = duration)
  scaleAnim.elapsed = 1.0
  scaleAnim._resultDirty = true -- Mark dirty after changing elapsed
  result = scaleAnim:interpolate()
  luaunit.assertEquals(result.width, 200)
  luaunit.assertEquals(result.height, 100)

  -- Beyond end (elapsed > duration) - should clamp to end values
  scaleAnim.elapsed = 1.5
  scaleAnim._resultDirty = true -- Mark dirty after changing elapsed
  result = scaleAnim:interpolate()
  luaunit.assertEquals(result.width, 200)
  luaunit.assertEquals(result.height, 100)
end

function TestAuxiliaryFunctions:testAutoSizingWithZeroChildren()
  local element = Gui.new({
    text = "",
  })

  local width = element:calculateAutoWidth()
  local height = element:calculateAutoHeight()

  luaunit.assertTrue(width >= 0, "Auto width should be non-negative")
  luaunit.assertTrue(height >= 0, "Auto height should be non-negative")
end

function TestAuxiliaryFunctions:testUpdateOpacityBoundaryValues()
  local element = Gui.new({
    opacity = 0.5,
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

-- ============================================
-- Test 11: Complex Color Management System
-- ============================================

function TestAuxiliaryFunctions:testComplexColorManagementSystem()
  print("\n=== Test 11: Complex Color Management System ===")

  -- Create color management system for UI theming
  local theme_colors = {}
  local color_variations = {}

  -- Test comprehensive color creation and conversion
  local base_colors = {
    { name = "primary", hex = "#2563EB", r = 0.145, g = 0.388, b = 0.922 },
    { name = "secondary", hex = "#7C3AED", r = 0.486, g = 0.227, b = 0.929 },
    { name = "success", hex = "#10B981", r = 0.063, g = 0.725, b = 0.506 },
    { name = "warning", hex = "#F59E0B", r = 0.961, g = 0.619, b = 0.043 },
    { name = "danger", hex = "#EF4444", r = 0.937, g = 0.267, b = 0.267 },
  }

  -- Test color creation from hex and manual RGB
  for _, color_def in ipairs(base_colors) do
    local hex_color = Color.fromHex(color_def.hex)
    local manual_color = Color.new(color_def.r, color_def.g, color_def.b, 1.0)

    theme_colors[color_def.name] = {
      hex = hex_color,
      manual = manual_color,
      name = color_def.name,
    }

    -- Verify hex parsing (FlexLove uses 0-255 range)
    luaunit.assertAlmostEquals(
      hex_color.r / 255,
      color_def.r,
      0.01,
      string.format("%s hex red component mismatch", color_def.name)
    )
    luaunit.assertAlmostEquals(
      hex_color.g / 255,
      color_def.g,
      0.01,
      string.format("%s hex green component mismatch", color_def.name)
    )
    luaunit.assertAlmostEquals(
      hex_color.b / 255,
      color_def.b,
      0.01,
      string.format("%s hex blue component mismatch", color_def.name)
    )
  end

  -- Test color variations (opacity, brightness adjustments)
  local opacities = { 0.1, 0.25, 0.5, 0.75, 0.9 }
  for color_name, color_set in pairs(theme_colors) do
    color_variations[color_name] = {}

    -- Create opacity variations
    for _, opacity in ipairs(opacities) do
      local variant_color = Color.new(color_set.manual.r, color_set.manual.g, color_set.manual.b, opacity)
      color_variations[color_name]["alpha_" .. tostring(opacity)] = variant_color

      luaunit.assertEquals(
        variant_color.a,
        opacity,
        string.format("%s opacity variant should have correct alpha", color_name)
      )
    end

    -- Create brightness variations
    local brightness_factors = { 0.3, 0.6, 1.0, 1.4, 1.8 }
    for _, factor in ipairs(brightness_factors) do
      local bright_r = math.min(1.0, color_set.manual.r * factor)
      local bright_g = math.min(1.0, color_set.manual.g * factor)
      local bright_b = math.min(1.0, color_set.manual.b * factor)

      local bright_color = Color.new(bright_r, bright_g, bright_b, 1.0)
      color_variations[color_name]["bright_" .. tostring(factor)] = bright_color

      luaunit.assertTrue(
        bright_r <= 1.0 and bright_g <= 1.0 and bright_b <= 1.0,
        "Brightness variations should not exceed 1.0"
      )
    end
  end

  -- Test color application to complex UI structure
  local ui_container = Gui.new({
    width = 800,
    height = 600,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 10,
  })

  -- Apply theme colors to different UI components
  local component_types = { "header", "content", "sidebar", "footer", "modal" }
  for i, comp_type in ipairs(component_types) do
    local component = Gui.new({
      width = 780,
      height = 100,
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.HORIZONTAL,
      justifyContent = enums.JustifyContent.SPACE_BETWEEN,
      alignItems = enums.AlignItems.CENTER,
      gap = 8,
    })
    component.parent = ui_container
    table.insert(ui_container.children, component)

    -- Apply color based on component type
    local color_name = base_colors[((i - 1) % #base_colors) + 1].name
    component.backgroundColor = theme_colors[color_name].manual
    component.textColor = Color.new(1, 1, 1, 1) -- White text

    -- Add sub-components with color variations
    for j = 1, 4 do
      local sub_component = Gui.new({
        width = 150,
        height = 80,
        positioning = enums.Positioning.FLEX,
        justifyContent = enums.JustifyContent.CENTER,
        alignItems = enums.AlignItems.CENTER,
      })
      sub_component.parent = component
      table.insert(component.children, sub_component)

      -- Apply color variation
      local opacity_key = "alpha_" .. tostring(opacities[((j - 1) % #opacities) + 1])
      sub_component.backgroundColor = color_variations[color_name][opacity_key]
    end
  end

  -- Verify color system integrity
  ui_container:layoutChildren()

  luaunit.assertEquals(#ui_container.children, 5, "Should have 5 themed components")

  -- Count theme_colors (it's a table with string keys, not an array)
  local theme_color_count = 0
  for _ in pairs(theme_colors) do
    theme_color_count = theme_color_count + 1
  end
  luaunit.assertEquals(theme_color_count, 5, "Should have 5 base theme colors")

  local total_variations = 0
  for _, variations in pairs(color_variations) do
    for _ in pairs(variations) do
      total_variations = total_variations + 1
    end
  end
  luaunit.assertTrue(total_variations >= 50, "Should have created numerous color variations")

  print(
    string.format(
      "Color Management System: %d base colors, %d variations, %d UI components",
      #base_colors,
      total_variations,
      #ui_container.children
    )
  )
end

-- ============================================
-- Test 12: Advanced Text and Auto-sizing Complex System
-- ============================================

function TestAuxiliaryFunctions:testAdvancedTextAndAutoSizingSystem()
  print("\n=== Test 12: Advanced Text and Auto-sizing System ===")

  -- Create dynamic text content management system
  local content_manager = {
    dynamic_texts = {},
    auto_sized_containers = {},
    text_metrics = {},
  }

  -- Test complex multi-language text scenarios
  local text_scenarios = {
    {
      id = "english_short",
      content = "Hello World",
      size = 14,
      expected_behavior = "compact",
    },
    {
      id = "english_long",
      content = "This is a much longer text that should demonstrate text wrapping and auto-sizing capabilities in various scenarios",
      size = 16,
      expected_behavior = "expanding",
    },
    {
      id = "mixed_content",
      content = "Product: Widget Pro™\nPrice: $299.99\nAvailability: In Stock ✓",
      size = 12,
      expected_behavior = "multiline",
    },
    {
      id = "special_chars",
      content = "Spéciál Chàracters: αβγδε • ★ ♦ ♠ → ∞",
      size = 18,
      expected_behavior = "unicode",
    },
    {
      id = "numbers_symbols",
      content = "Data: 123,456.78 | Progress: 85% | Status: [●●●○○]",
      size = 13,
      expected_behavior = "data_display",
    },
  }

  -- Create dynamic text containers with auto-sizing
  local main_container = Gui.new({
    width = 1000,
    height = 800,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 15,
  })

  for _, scenario in ipairs(text_scenarios) do
    local text_container = Gui.new({
      width = 900,
      height = 100,
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.HORIZONTAL,
      justifyContent = enums.JustifyContent.SPACE_BETWEEN,
      alignItems = enums.AlignItems.FLEX_START,
      gap = 20,
    })
    text_container.parent = main_container
    table.insert(main_container.children, text_container)

    -- Create auto-sized text element
    local text_element = Gui.new({
      text = scenario.content,
      textSize = scenario.size,
      width = 0,
      height = 0, -- Start with zero size for auto-sizing
    })
    text_element.parent = text_container
    table.insert(text_container.children, text_element)

    -- Calculate auto dimensions
    local auto_width = text_element:calculateAutoWidth()
    local auto_height = text_element:calculateAutoHeight()
    local text_width = text_element:calculateTextWidth()
    local text_height = text_element:calculateTextHeight()

    -- Store metrics
    content_manager.text_metrics[scenario.id] = {
      auto_width = auto_width,
      auto_height = auto_height,
      text_width = text_width,
      text_height = text_height,
      char_count = string.len(scenario.content),
      content = scenario.content,
    }

    -- Verify text calculations
    luaunit.assertTrue(auto_width >= 0, string.format("%s: Auto width should be non-negative", scenario.id))
    luaunit.assertTrue(auto_height >= 0, string.format("%s: Auto height should be non-negative", scenario.id))
    luaunit.assertTrue(text_width >= 0, string.format("%s: Text width should be non-negative", scenario.id))
    luaunit.assertTrue(text_height >= 0, string.format("%s: Text height should be non-negative", scenario.id))

    -- For single-line text, auto width should roughly match text width
    if not string.find(scenario.content, "\n") then
      luaunit.assertAlmostEquals(
        auto_width,
        text_width,
        text_width * 0.1,
        string.format("%s: Auto width should approximate text width for single-line", scenario.id)
      )
    end

    -- Apply auto-sizing
    text_element.w = auto_width
    text_element.h = auto_height

    content_manager.auto_sized_containers[scenario.id] = text_element

    -- Create comparison elements with fixed sizes
    local fixed_element = Gui.new({
      text = scenario.content,
      textSize = scenario.size,
      width = 200,
      height = 50, -- Fixed size
    })
    fixed_element.parent = text_container
    table.insert(text_container.children, fixed_element)

    -- Create adaptive element that changes based on content length
    local adaptive_element = Gui.new({
      text = scenario.content,
      textSize = scenario.size,
      width = math.max(150, auto_width * 0.8),
      height = math.max(30, auto_height * 1.2),
    })
    adaptive_element.parent = text_container
    table.insert(text_container.children, adaptive_element)
  end

  -- Test dynamic text updates with auto-resizing
  local dynamic_updates = {
    { target = "english_short", new_text = "Updated: Hello Universe!", autoresize = true },
    { target = "english_long", new_text = "Shortened text", autoresize = true },
    { target = "mixed_content", new_text = "Status: SOLD OUT ❌", autoresize = false },
    {
      target = "numbers_symbols",
      new_text = "Final Results: 999,999.99 | Complete: 100% | Status: [●●●●●]",
      autoresize = true,
    },
  }

  for _, update in ipairs(dynamic_updates) do
    local element = content_manager.auto_sized_containers[update.target]
    if element then
      local original_width = element.w
      local original_height = element.h

      element:updateText(update.new_text, update.autoresize)

      if update.autoresize then
        -- With autoresize, dimensions should potentially change
        local new_auto_width = element:calculateAutoWidth()
        local new_auto_height = element:calculateAutoHeight()

        luaunit.assertEquals(element.text, update.new_text, string.format("%s: Text should be updated", update.target))

        -- If autoresize is working, element dimensions should match auto calculations
        if new_auto_width ~= original_width or new_auto_height ~= original_height then
          content_manager.text_metrics[update.target .. "_updated"] = {
            auto_width = new_auto_width,
            auto_height = new_auto_height,
            original_width = original_width,
            original_height = original_height,
            text_changed = true,
          }
        end
      else
        -- Without autoresize, dimensions should remain the same
        luaunit.assertEquals(
          element.w,
          original_width,
          string.format("%s: Width should not change without autoresize", update.target)
        )
        luaunit.assertEquals(
          element.h,
          original_height,
          string.format("%s: Height should not change without autoresize", update.target)
        )
      end
    end
  end

  -- Test complex auto-sizing with nested structures
  local nested_container = Gui.new({
    width = 800,
    height = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 10,
  })
  nested_container.parent = main_container
  table.insert(main_container.children, nested_container)

  -- Create nested structure with auto-sizing children
  local prev_container = nested_container
  for level = 1, 3 do
    local level_container = Gui.new({
      width = 750 - (level * 50),
      height = 60,
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.HORIZONTAL,
      justifyContent = enums.JustifyContent.SPACE_AROUND,
      gap = 5,
    })
    level_container.parent = prev_container
    table.insert(prev_container.children, level_container)
    prev_container = level_container

    for item = 1, 4 do
      local item_text = string.format("L%d-Item%d: %s", level, item, string.rep("Text ", level))
      local text_item = Gui.new({
        text = item_text,
        textSize = 14 - level,
        width = 0,
        height = 0,
      })
      text_item.parent = level_container
      table.insert(level_container.children, text_item)

      -- Apply auto-sizing
      text_item.w = text_item:calculateAutoWidth()
      text_item.h = text_item:calculateAutoHeight()
    end
  end

  -- Perform layout and verify
  main_container:layoutChildren()

  luaunit.assertEquals(
    #main_container.children,
    #text_scenarios + 1,
    "Should have scenario containers plus nested container"
  )

  -- Count text_metrics (it's a table with string keys, not an array)
  local metrics_count = 0
  for _ in pairs(content_manager.text_metrics) do
    metrics_count = metrics_count + 1
  end
  luaunit.assertTrue(metrics_count >= #text_scenarios, "Should have metrics for all scenarios")

  print(
    string.format(
      "Text Management System: %d scenarios, %d metrics, %d updates",
      #text_scenarios,
      #content_manager.text_metrics,
      #dynamic_updates
    )
  )
end

-- ============================================
-- Test 13: Comprehensive Animation Engine Testing
-- ============================================

function TestAuxiliaryFunctions:testComprehensiveAnimationEngine()
  print("\n=== Test 13: Comprehensive Animation Engine ===")

  -- Create animation test environment
  local animation_system = {
    active_animations = {},
    completed_animations = {},
    animation_chains = {},
    performance_metrics = {},
  }

  -- Create container for animated elements
  local animation_container = Gui.new({
    width = 1200,
    height = 800,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    gap = 20,
  })

  -- Test various animation types and combinations
  local animation_test_cases = {
    {
      name = "fade_animations",
      elements = 8,
      animation_type = "fade",
      duration_range = { 0.5, 2.0 },
      properties = { opacity = { from = 1.0, to = 0.0 } },
    },
    {
      name = "scale_animations",
      elements = 6,
      animation_type = "scale",
      duration_range = { 1.0, 3.0 },
      properties = {
        width = { from = 100, to = 200 },
        height = { from = 50, to = 100 },
      },
    },
    {
      name = "complex_mixed",
      elements = 10,
      animation_type = "mixed",
      duration_range = { 0.8, 2.5 },
      properties = {
        opacity = { from = 0.2, to = 1.0 },
        width = { from = 80, to = 150 },
        height = { from = 40, to = 80 },
      },
    },
  }

  -- Create and configure animations for each test case
  for case_idx, test_case in ipairs(animation_test_cases) do
    local case_container = Gui.new({
      width = 1180,
      height = 200,
      positioning = enums.Positioning.FLEX,
      flexDirection = enums.FlexDirection.HORIZONTAL,
      flexWrap = enums.FlexWrap.WRAP,
      justifyContent = enums.JustifyContent.SPACE_AROUND,
      gap = 15,
    })
    case_container.parent = animation_container
    table.insert(animation_container.children, case_container)

    animation_system.animation_chains[test_case.name] = {}

    for elem_idx = 1, test_case.elements do
      local element = Gui.new({
        width = test_case.properties.width and test_case.properties.width.from or 120,
        height = test_case.properties.height and test_case.properties.height.from or 60,
        opacity = test_case.properties.opacity and test_case.properties.opacity.from or 1.0,
      })
      element.parent = case_container
      table.insert(case_container.children, element)

      -- Create animation based on type
      local duration = test_case.duration_range[1]
        + (math.random() * (test_case.duration_range[2] - test_case.duration_range[1]))

      local animation
      if test_case.animation_type == "fade" then
        animation = Gui.Animation.fade(duration, test_case.properties.opacity.from, test_case.properties.opacity.to)
      elseif test_case.animation_type == "scale" then
        animation = Gui.Animation.scale(duration, {
          width = test_case.properties.width.from,
          height = test_case.properties.height.from,
        }, {
          width = test_case.properties.width.to,
          height = test_case.properties.height.to,
        })
      elseif test_case.animation_type == "mixed" then
        -- Create complex animation with multiple properties
        animation = {
          duration = duration,
          elapsed = 0,
          start = {},
          final = {},
          element = element,
          properties = {},
        }

        -- Set up start and final values for all properties
        for prop, values in pairs(test_case.properties) do
          animation.start[prop] = values.from
          animation.final[prop] = values.to
          animation.properties[prop] = true
        end

        -- Add interpolation method
        animation.interpolate = function(self)
          local progress = math.min(1.0, self.elapsed / self.duration)
          local result = {}

          for prop in pairs(self.properties) do
            local start_val = self.start[prop]
            local final_val = self.final[prop]
            result[prop] = start_val + (final_val - start_val) * progress
          end

          return result
        end

        -- Add update method
        animation.update = function(self, dt)
          self.elapsed = self.elapsed + dt
          local finished = self.elapsed >= self.duration

          if finished then
            self.elapsed = self.duration
          end

          -- Apply interpolated values to element
          local values = self:interpolate()
          for prop, value in pairs(values) do
            if prop == "opacity" then
              self.element.opacity = value
            elseif prop == "width" then
              self.element.w = value
            elseif prop == "height" then
              self.element.h = value
            end
          end

          return finished
        end

        -- Add apply method
        animation.apply = function(self, element)
          self.element = element
          element.animation = self
        end
      end

      -- Verify animation creation
      luaunit.assertNotNil(animation, string.format("Animation should be created for %s", test_case.name))
      luaunit.assertTrue(animation.duration > 0, "Animation should have positive duration")
      luaunit.assertNotNil(animation.start, "Animation should have start properties")
      luaunit.assertNotNil(animation.final, "Animation should have final properties")

      -- Apply animation to element
      animation:apply(element)

      animation_system.active_animations[test_case.name .. "_" .. elem_idx] = {
        animation = animation,
        element = element,
        start_time = 0,
        test_case = test_case.name,
      }

      table.insert(animation_system.animation_chains[test_case.name], animation)
    end
  end

  -- Simulate animation updates over time
  local total_simulation_time = 4.0 -- 4 seconds
  local dt = 1 / 60 -- 60 FPS
  local frame_count = 0
  local active_count_over_time = {}

  for sim_time = 0, total_simulation_time, dt do
    frame_count = frame_count + 1
    local active_count = 0
    local completed_this_frame = {}

    -- Update all active animations
    for anim_id, anim_data in pairs(animation_system.active_animations) do
      if anim_data.animation then
        local finished = anim_data.animation:update(dt)

        if finished then
          table.insert(completed_this_frame, anim_id)
          animation_system.completed_animations[anim_id] = {
            animation = anim_data.animation,
            completion_time = sim_time,
            total_frames = frame_count,
          }
        else
          active_count = active_count + 1
        end
      end
    end

    -- Remove completed animations
    for _, anim_id in ipairs(completed_this_frame) do
      animation_system.active_animations[anim_id] = nil
    end

    active_count_over_time[frame_count] = active_count

    -- Test interpolation at specific progress points
    if frame_count % 60 == 0 then -- Every second
      for anim_id, anim_data in pairs(animation_system.active_animations) do
        if anim_data.animation.interpolate then
          local progress = anim_data.animation.elapsed / anim_data.animation.duration
          local interpolated = anim_data.animation:interpolate()

          luaunit.assertTrue(
            progress >= 0 and progress <= 1,
            string.format("Animation progress should be 0-1, got %.3f", progress)
          )
          luaunit.assertNotNil(interpolated, "Interpolation should return values")
        end
      end
    end
  end

  -- Analyze animation performance and correctness
  local total_animations = 0
  local total_completed = 0

  for test_case_name, animations in pairs(animation_system.animation_chains) do
    total_animations = total_animations + #animations
  end

  for _ in pairs(animation_system.completed_animations) do
    total_completed = total_completed + 1
  end

  animation_system.performance_metrics = {
    total_animations = total_animations,
    completed_animations = total_completed,
    completion_rate = total_completed / total_animations,
    simulation_frames = frame_count,
    simulation_time = total_simulation_time,
  }

  -- Verify animation system functionality
  luaunit.assertTrue(total_animations > 20, "Should have created substantial number of animations")
  luaunit.assertTrue(total_completed > 0, "Some animations should have completed")
  luaunit.assertTrue(
    animation_system.performance_metrics.completion_rate > 0.5,
    "Majority of animations should complete within simulation time"
  )

  -- Test animation chaining and sequencing
  local chain_element = Gui.new({ width = 100, height = 50, opacity = 1.0 })
  chain_element.parent = animation_container
  table.insert(animation_container.children, chain_element)

  -- Create animation chain: fade out -> scale up -> fade in
  local chain_animations = {
    Gui.Animation.fade(0.5, 1.0, 0.0),
    Gui.Animation.scale(0.8, { width = 100, height = 50 }, { width = 200, height = 100 }),
    Gui.Animation.fade(0.5, 0.0, 1.0),
  }

  -- Test each animation in the chain
  for i, chain_anim in ipairs(chain_animations) do
    luaunit.assertNotNil(chain_anim, string.format("Chain animation %d should exist", i))
    luaunit.assertTrue(chain_anim.duration > 0, string.format("Chain animation %d should have duration", i))

    -- Apply and test first few frames
    chain_anim:apply(chain_element)
    for frame = 1, 5 do
      local finished = chain_anim:update(0.1)
      if frame < 5 then
        luaunit.assertFalse(finished, string.format("Chain animation %d should not finish in %d frames", i, frame))
      end
    end
  end

  -- Perform final layout
  animation_container:layoutChildren()

  luaunit.assertEquals(
    #animation_container.children,
    #animation_test_cases + 1,
    "Should have containers for each test case plus chain element"
  )

  print(
    string.format(
      "Animation Engine: %d total animations, %d completed (%.1f%%), %d frames simulated",
      animation_system.performance_metrics.total_animations,
      animation_system.performance_metrics.completed_animations,
      animation_system.performance_metrics.completion_rate * 100,
      animation_system.performance_metrics.simulation_frames
    )
  )
end

-- ============================================
-- Test 14: Advanced GUI Management and Cleanup System
-- ============================================

function TestAuxiliaryFunctions:testAdvancedGUIManagementAndCleanup()
  print("\n=== Test 14: Advanced GUI Management and Cleanup ===")

  -- Create complex GUI hierarchy for testing management
  local gui_manager = {
    element_registry = {},
    destruction_log = {},
    memory_snapshots = {},
    hierarchy_metrics = {},
  }

  -- Test complex nested structure creation and management
  local application_structure = {
    {
      type = "main_window",
      children = {
        {
          type = "header",
          children = {
            { type = "logo", children = {} },
            {
              type = "nav_menu",
              children = {
                { type = "nav_item", children = {} },
                { type = "nav_item", children = {} },
                { type = "nav_item", children = {} },
              },
            },
            {
              type = "user_area",
              children = {
                { type = "avatar", children = {} },
                {
                  type = "dropdown",
                  children = {
                    { type = "menu_item", children = {} },
                    { type = "menu_item", children = {} },
                    { type = "divider", children = {} },
                    { type = "menu_item", children = {} },
                  },
                },
              },
            },
          },
        },
        {
          type = "main_content",
          children = {
            {
              type = "sidebar",
              children = {
                {
                  type = "sidebar_section",
                  children = {
                    { type = "section_header", children = {} },
                    { type = "section_item", children = {} },
                    { type = "section_item", children = {} },
                    { type = "section_item", children = {} },
                  },
                },
                {
                  type = "sidebar_section",
                  children = {
                    { type = "section_header", children = {} },
                    { type = "section_item", children = {} },
                    { type = "section_item", children = {} },
                  },
                },
              },
            },
            {
              type = "content_area",
              children = {
                {
                  type = "content_header",
                  children = {
                    { type = "breadcrumb", children = {} },
                    {
                      type = "actions",
                      children = {
                        { type = "action_button", children = {} },
                        { type = "action_button", children = {} },
                        { type = "action_dropdown", children = {} },
                      },
                    },
                  },
                },
                {
                  type = "content_body",
                  children = {
                    {
                      type = "data_grid",
                      children = {
                        { type = "grid_header", children = {} },
                        {
                          type = "grid_row",
                          children = {
                            { type = "grid_cell", children = {} },
                            { type = "grid_cell", children = {} },
                            { type = "grid_cell", children = {} },
                          },
                        },
                        {
                          type = "grid_row",
                          children = {
                            { type = "grid_cell", children = {} },
                            { type = "grid_cell", children = {} },
                            { type = "grid_cell", children = {} },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
        {
          type = "footer",
          children = {
            { type = "footer_links", children = {} },
            { type = "footer_info", children = {} },
          },
        },
      },
    },
  }

  -- Recursive function to create GUI structure
  local function createGUIHierarchy(structure, parent, level)
    level = level or 1
    local created_elements = {}

    for _, item in ipairs(structure) do
      local element = Gui.new({
        width = math.max(100, 300 - level * 20),
        height = math.max(30, 80 - level * 5),
        positioning = enums.Positioning.FLEX,
        flexDirection = level % 2 == 0 and enums.FlexDirection.HORIZONTAL or enums.FlexDirection.VERTICAL,
        justifyContent = enums.JustifyContent.FLEX_START,
        alignItems = enums.AlignItems.STRETCH,
        gap = math.max(2, 10 - level),
      })

      if parent then
        element.parent = parent
        table.insert(parent.children, element)
      end

      -- Register element in management system
      local element_id = item.type .. "_" .. tostring(level) .. "_" .. tostring(#created_elements + 1)
      gui_manager.element_registry[element_id] = {
        element = element,
        type = item.type,
        level = level,
        parent_id = parent and "parent_of_" .. element_id or nil,
        children_count = #item.children,
      }

      table.insert(created_elements, { id = element_id, element = element })

      -- Recursively create children
      if #item.children > 0 then
        local child_elements = createGUIHierarchy(item.children, element, level + 1)
        gui_manager.element_registry[element_id].child_elements = child_elements
      end
    end

    return created_elements
  end

  -- Create the complex structure
  local root_elements = createGUIHierarchy(application_structure)
  local root_element = root_elements[1].element

  -- Take initial memory snapshot
  gui_manager.memory_snapshots.initial = {
    element_count = 0,
    registry_size = 0,
  }

  for _ in pairs(gui_manager.element_registry) do
    gui_manager.memory_snapshots.initial.element_count = gui_manager.memory_snapshots.initial.element_count + 1
  end

  gui_manager.memory_snapshots.initial.registry_size = #gui_manager.element_registry
  gui_manager.memory_snapshots.initial.top_elements = #Gui.topElements

  -- Perform layout to establish structure
  root_element:layoutChildren()

  -- Calculate hierarchy metrics
  local function calculateHierarchyMetrics(element, depth)
    depth = depth or 1
    local metrics = {
      max_depth = depth,
      total_elements = 1,
      elements_by_level = {},
    }

    metrics.elements_by_level[depth] = 1

    for _, child in ipairs(element.children) do
      local child_metrics = calculateHierarchyMetrics(child, depth + 1)
      metrics.max_depth = math.max(metrics.max_depth, child_metrics.max_depth)
      metrics.total_elements = metrics.total_elements + child_metrics.total_elements

      for level, count in pairs(child_metrics.elements_by_level) do
        metrics.elements_by_level[level] = (metrics.elements_by_level[level] or 0) + count
      end
    end

    return metrics
  end

  gui_manager.hierarchy_metrics = calculateHierarchyMetrics(root_element)

  -- Test selective destruction (remove sidebar while keeping other elements)
  local sidebar_element = nil
  for element_id, element_data in pairs(gui_manager.element_registry) do
    if element_data.type == "sidebar" then
      sidebar_element = element_data.element
      break
    end
  end

  if sidebar_element then
    local sidebar_children_count = #sidebar_element.children
    local sidebar_parent = sidebar_element.parent
    local original_parent_children = sidebar_parent and #sidebar_parent.children or 0

    -- Destroy sidebar and track the process
    local destruction_start = os.clock()
    sidebar_element:destroy()
    local destruction_time = os.clock() - destruction_start

    gui_manager.destruction_log.sidebar = {
      destruction_time = destruction_time,
      children_destroyed = sidebar_children_count,
      parent_children_after = sidebar_parent and #sidebar_parent.children or 0,
    }

    -- Verify destruction
    luaunit.assertNil(sidebar_element.parent, "Destroyed element should have no parent")
    luaunit.assertEquals(#sidebar_element.children, 0, "Destroyed element should have no children")

    if sidebar_parent then
      luaunit.assertEquals(
        #sidebar_parent.children,
        original_parent_children - 1,
        "Parent should have one fewer child after destruction"
      )
    end
  end

  -- Test mass destruction and recreation cycle
  local destruction_cycles = 3
  for cycle = 1, destruction_cycles do
    -- Take pre-destruction snapshot
    gui_manager.memory_snapshots["pre_cycle_" .. cycle] = {
      top_elements = #Gui.topElements,
      registry_size = #gui_manager.element_registry,
    }

    -- Destroy all GUI elements
    local destruction_start = os.clock()
    Gui.destroy()
    local destruction_time = os.clock() - destruction_start

    -- Take post-destruction snapshot
    gui_manager.memory_snapshots["post_destruction_" .. cycle] = {
      top_elements = #Gui.topElements,
      destruction_time = destruction_time,
    }

    -- Verify complete destruction
    luaunit.assertEquals(#Gui.topElements, 0, string.format("Cycle %d: All top elements should be destroyed", cycle))

    -- Force garbage collection
    collectgarbage("collect")

    -- Recreate simplified structure for next cycle
    if cycle < destruction_cycles then
      local simple_structure = {
        {
          type = "test_container",
          children = {
            { type = "test_item", children = {} },
            { type = "test_item", children = {} },
            { type = "test_item", children = {} },
          },
        },
      }

      local recreation_start = os.clock()
      createGUIHierarchy(simple_structure)
      local recreation_time = os.clock() - recreation_start

      gui_manager.memory_snapshots["post_recreation_" .. cycle] = {
        top_elements = #Gui.topElements,
        recreation_time = recreation_time,
      }
    end
  end

  -- Test complex element retrieval and manipulation
  local final_container = Gui.new({
    width = 400,
    height = 300,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
  })

  -- Create elements with specific IDs for retrieval testing
  local managed_elements = {}
  for i = 1, 10 do
    local element = Gui.new({
      width = 350,
      height = 25,
      text = "Managed Element " .. i,
      textSize = 12,
    })
    element.parent = final_container
    table.insert(final_container.children, element)

    managed_elements["element_" .. i] = element
  end

  -- Test bounds calculation for all elements
  for element_id, element in pairs(managed_elements) do
    local bounds = element:getBounds()

    luaunit.assertNotNil(bounds, string.format("%s: Bounds should be calculable", element_id))
    luaunit.assertTrue(bounds.width > 0, string.format("%s: Bounds width should be positive", element_id))
    luaunit.assertTrue(bounds.height > 0, string.format("%s: Bounds height should be positive", element_id))
    luaunit.assertTrue(bounds.x >= 0, string.format("%s: Bounds x should be non-negative", element_id))
    luaunit.assertTrue(bounds.y >= 0, string.format("%s: Bounds y should be non-negative", element_id))
  end

  -- Test opacity management across hierarchy
  for element_id, element_pair in pairs(managed_elements) do
    -- Extract number from "element_N" key
    local num = tonumber(element_id:match("%d+"))
    if num and num % 2 == 0 then
      element_pair:updateOpacity(0.5)
      luaunit.assertEquals(element_pair.opacity, 0.5, "Even elements should have 0.5 opacity")
    end
  end

  -- Perform final layout
  final_container:layoutChildren()

  -- Verify final GUI state
  luaunit.assertTrue(#Gui.topElements >= 1, "Should have at least final container")
  luaunit.assertEquals(#final_container.children, 10, "Final container should have 10 managed elements")
  luaunit.assertTrue(gui_manager.hierarchy_metrics.max_depth >= 4, "Original hierarchy should have been deep")
  luaunit.assertTrue(gui_manager.hierarchy_metrics.total_elements >= 20, "Should have created substantial hierarchy")

  print(
    string.format(
      "GUI Management: %d elements, %d max depth, %d destruction cycles, %d managed elements",
      gui_manager.hierarchy_metrics.total_elements,
      gui_manager.hierarchy_metrics.max_depth,
      destruction_cycles,
      #managed_elements
    )
  )
end

-- ============================================
-- Test 15: Extreme Edge Cases and Error Resilience
-- ============================================

function TestAuxiliaryFunctions:testExtremeEdgeCasesAndErrorResilience()
  print("\n=== Test 15: Extreme Edge Cases and Error Resilience ===")

  -- Test boundary conditions and error handling
  local edge_case_results = {
    color_tests = {},
    text_tests = {},
    animation_tests = {},
    hierarchy_tests = {},
    performance_tests = {},
  }

  -- Extreme color value testing
  local extreme_color_tests = {
    { name = "negative_values", r = -1.0, g = -0.5, b = -2.0, a = -0.3 },
    { name = "huge_values", r = 999.0, g = 1000.0, b = 50000.0, a = 100.0 },
    { name = "zero_values", r = 0.0, g = 0.0, b = 0.0, a = 0.0 },
    { name = "fractional_extremes", r = 0.0001, g = 0.9999, b = 0.00001, a = 0.99999 },
    { name = "infinity_values", r = math.huge, g = -math.huge, b = 1 / 0, a = -1 / 0 },
  }

  for _, test in ipairs(extreme_color_tests) do
    local success, result = pcall(function()
      local color = Color.new(test.r, test.g, test.b, test.a)
      return {
        created = true,
        r = color.r,
        g = color.g,
        b = color.b,
        a = color.a,
        rgba = { color:toRGBA() },
      }
    end)

    edge_case_results.color_tests[test.name] = {
      success = success,
      result = result,
      expected_error = test.name == "infinity_values",
    }

    if test.name ~= "infinity_values" then
      luaunit.assertTrue(success, string.format("Color creation should handle %s", test.name))
    end
  end

  -- Extreme hex color testing
  local extreme_hex_tests = {
    { hex = "", should_error = true },
    { hex = "#", should_error = true },
    { hex = "#FF", should_error = true },
    { hex = "#FFFF", should_error = true },
    { hex = "#FFFFFF", should_error = false },
    { hex = "#FFFFFFFF", should_error = false },
    { hex = "#FFFFFFFFFF", should_error = true },
    { hex = "#GGGGGG", should_error = true },
    { hex = "#123456789", should_error = true },
    { hex = "FFFFFF", should_error = false }, -- without #
    { hex = "#ffffff", should_error = false }, -- lowercase
    { hex = "#FfFfFf", should_error = false }, -- mixed case
  }

  for _, test in ipairs(extreme_hex_tests) do
    local success, result = pcall(function()
      return Color.fromHex(test.hex)
    end)

    if test.should_error then
      luaunit.assertFalse(success, string.format("Hex '%s' should cause error", test.hex))
    else
      luaunit.assertTrue(success, string.format("Hex '%s' should be valid", test.hex))
    end
  end

  -- Extreme text and sizing tests
  local extreme_text_tests = {
    { name = "empty_string", text = "" },
    { name = "single_char", text = "A" },
    { name = "very_long", text = string.rep("Very long text that goes on and on and on. ", 100) },
    {
      name = "unicode_heavy",
      text = "🎉🚀⭐️🌟💫✨🎨🎯🎪🎭🎬🎮🎲🎳🎸🎹🎺🎻🥁🎤🎧🎼🎵🎶",
    },
    { name = "special_chars", text = "\n\t\r\b\f\v\\\"'`~!@#$%^&*()_+-=[]{}|;:,.<>?" },
    { name = "mixed_newlines", text = "Line 1\nLine 2\r\nLine 3\rLine 4\n\nLine 6" },
    { name = "numbers_symbols", text = "0123456789!@#$%^&*()_+-=[]{}|\\:;\";'<>?,./`~" },
  }

  for _, test in ipairs(extreme_text_tests) do
    local element = Gui.new({
      text = test.text,
      textSize = 14,
      width = 0,
      height = 0,
    })

    local text_width = element:calculateTextWidth()
    local text_height = element:calculateTextHeight()
    local auto_width = element:calculateAutoWidth()
    local auto_height = element:calculateAutoHeight()

    edge_case_results.text_tests[test.name] = {
      text_width = text_width,
      text_height = text_height,
      auto_width = auto_width,
      auto_height = auto_height,
      char_count = string.len(test.text),
    }

    -- All calculations should return non-negative values
    luaunit.assertTrue(text_width >= 0, string.format("%s: Text width should be non-negative", test.name))
    luaunit.assertTrue(text_height >= 0, string.format("%s: Text height should be non-negative", test.name))
    luaunit.assertTrue(auto_width >= 0, string.format("%s: Auto width should be non-negative", test.name))
    luaunit.assertTrue(auto_height >= 0, string.format("%s: Auto height should be non-negative", test.name))

    -- Test text updates with extreme values
    local success = pcall(function()
      element:updateText(test.text, true)
      element:updateText(nil) -- Should preserve existing text
      element:updateText("") -- Should set to empty
    end)

    luaunit.assertTrue(success, string.format("%s: Text updates should not crash", test.name))
  end

  -- Extreme animation testing
  local extreme_animation_tests = {
    { name = "zero_duration", duration = 0 },
    { name = "negative_duration", duration = -1.0 },
    { name = "huge_duration", duration = 999999.0 },
    { name = "tiny_duration", duration = 0.001 },
    { name = "infinity_duration", duration = math.huge },
  }

  for _, test in ipairs(extreme_animation_tests) do
    local success, result = pcall(function()
      local animation = Gui.Animation.fade(test.duration, 1.0, 0.0)
      return {
        created = true,
        duration = animation.duration,
        interpolated = animation:interpolate(),
      }
    end)

    edge_case_results.animation_tests[test.name] = {
      success = success,
      result = result,
    }

    -- Most duration values should be handled gracefully
    if test.name ~= "infinity_duration" then
      luaunit.assertTrue(success, string.format("Animation with %s should be created", test.name))
    end
  end

  -- Extreme hierarchy testing
  local max_depth = 20
  local extreme_hierarchy_element = Gui.new({ width = 1000, height = 800 })
  local current_parent = extreme_hierarchy_element

  -- Create extremely deep hierarchy
  for depth = 1, max_depth do
    local child = Gui.new({
      width = math.max(50, 1000 - depth * 45),
      height = math.max(30, 800 - depth * 35),
      positioning = enums.Positioning.FLEX,
      flexDirection = depth % 2 == 0 and enums.FlexDirection.HORIZONTAL or enums.FlexDirection.VERTICAL,
    })
    child.parent = current_parent
    table.insert(current_parent.children, child)
    current_parent = child
  end

  -- Test layout performance with extreme depth
  local deep_layout_start = os.clock()
  local layout_success = pcall(function()
    extreme_hierarchy_element:layoutChildren()
  end)
  local deep_layout_time = os.clock() - deep_layout_start

  edge_case_results.hierarchy_tests.extreme_depth = {
    success = layout_success,
    depth = max_depth,
    layout_time = deep_layout_time,
  }

  luaunit.assertTrue(layout_success, "Extremely deep hierarchy should layout without crashing")
  luaunit.assertTrue(deep_layout_time < 5.0, "Deep hierarchy layout should complete in reasonable time")

  -- Test extreme width hierarchy (many siblings)
  local wide_container = Gui.new({
    width = 2000,
    height = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    flexWrap = enums.FlexWrap.WRAP,
    gap = 2,
  })

  local max_siblings = 500
  for i = 1, max_siblings do
    local sibling = Gui.new({ width = 30, height = 25 })
    sibling.parent = wide_container
    table.insert(wide_container.children, sibling)
  end

  local wide_layout_start = os.clock()
  local wide_layout_success = pcall(function()
    wide_container:layoutChildren()
  end)
  local wide_layout_time = os.clock() - wide_layout_start

  edge_case_results.hierarchy_tests.extreme_width = {
    success = wide_layout_success,
    siblings = max_siblings,
    layout_time = wide_layout_time,
  }

  luaunit.assertTrue(wide_layout_success, "Extremely wide hierarchy should layout without crashing")
  luaunit.assertTrue(wide_layout_time < 10.0, "Wide hierarchy layout should complete in reasonable time")

  -- Test massive cleanup operations
  local cleanup_elements = {}
  for i = 1, 1000 do
    local element = Gui.new({ width = 50, height = 30 })
    table.insert(cleanup_elements, element)
  end

  local cleanup_start = os.clock()
  local cleanup_success = pcall(function()
    Gui.destroy()
  end)
  local cleanup_time = os.clock() - cleanup_start

  edge_case_results.performance_tests.massive_cleanup = {
    success = cleanup_success,
    elements = #cleanup_elements,
    cleanup_time = cleanup_time,
  }

  luaunit.assertTrue(cleanup_success, "Massive cleanup should complete without crashing")
  luaunit.assertTrue(cleanup_time < 5.0, "Massive cleanup should complete in reasonable time")
  luaunit.assertEquals(#Gui.topElements, 0, "All elements should be cleaned up")

  -- Test opacity boundary resilience
  local opacity_element = Gui.new({ width = 100, height = 50, opacity = 0.5 })
  local extreme_opacities = { -999, -1, 0, 0.5, 1, 2, 999, math.huge, -math.huge }

  for _, opacity in ipairs(extreme_opacities) do
    local success = pcall(function()
      opacity_element:updateOpacity(opacity)
    end)
    luaunit.assertTrue(success, string.format("Opacity update with value %s should not crash", tostring(opacity)))
  end

  -- Summary of edge case testing
  local total_tests = 0
  local successful_tests = 0

  for category, tests in pairs(edge_case_results) do
    for test_name, result in pairs(tests) do
      total_tests = total_tests + 1
      if result.success ~= false then
        successful_tests = successful_tests + 1
      end
    end
  end

  print(
    string.format(
      "Edge Case Testing: %d/%d tests handled gracefully (%.1f%%)",
      successful_tests,
      total_tests,
      (successful_tests / total_tests) * 100
    )
  )

  luaunit.assertTrue(successful_tests / total_tests > 0.8, "Should handle majority of edge cases gracefully")
end

luaunit.LuaUnit.run()
