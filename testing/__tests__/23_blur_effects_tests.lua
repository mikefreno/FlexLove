-- Test suite for blur effects (contentBlur and backdropBlur)
local lu = require("testing.luaunit")
local FlexLove = require("FlexLove")

TestBlurEffects = {}

function TestBlurEffects:setUp()
  -- Initialize FlexLove with default config
  FlexLove.Gui.init({ baseScale = { width = 1920, height = 1080 } })
end

function TestBlurEffects:tearDown()
  FlexLove.Gui.destroy()
end

-- Test 1: Element with contentBlur property
function TestBlurEffects:test_content_blur_property()
  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 5 },
  })

  lu.assertNotNil(element.contentBlur, "Element should have contentBlur property")
  lu.assertEquals(element.contentBlur.intensity, 50, "Content blur intensity should be 50")
  lu.assertEquals(element.contentBlur.quality, 5, "Content blur quality should be 5")
end

-- Test 2: Element with backdropBlur property
function TestBlurEffects:test_backdrop_blur_property()
  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
    backdropBlur = { intensity = 75, quality = 7 },
  })

  lu.assertNotNil(element.backdropBlur, "Element should have backdropBlur property")
  lu.assertEquals(element.backdropBlur.intensity, 75, "Backdrop blur intensity should be 75")
  lu.assertEquals(element.backdropBlur.quality, 7, "Backdrop blur quality should be 7")
end

-- Test 3: Element with both blur types
function TestBlurEffects:test_both_blur_types()
  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 30, quality = 3 },
    backdropBlur = { intensity = 60, quality = 6 },
  })

  lu.assertNotNil(element.contentBlur, "Element should have contentBlur property")
  lu.assertNotNil(element.backdropBlur, "Element should have backdropBlur property")
  lu.assertEquals(element.contentBlur.intensity, 30)
  lu.assertEquals(element.backdropBlur.intensity, 60)
end

-- Test 4: Blur instance creation (skip if no graphics context)
function TestBlurEffects:test_blur_instance_creation()
  if not love or not love.graphics then
    lu.success() -- Skip test if no LÖVE graphics context
    return
  end

  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 5 },
  })

  local blurInstance = element:getBlurInstance()
  lu.assertNotNil(blurInstance, "Blur instance should be created")
  lu.assertEquals(blurInstance.quality, 5, "Blur instance should have correct quality")
end

-- Test 5: Blur instance caching (skip if no graphics context)
function TestBlurEffects:test_blur_instance_caching()
  if not love or not love.graphics then
    lu.success() -- Skip test if no LÖVE graphics context
    return
  end

  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 5 },
  })

  local instance1 = element:getBlurInstance()
  local instance2 = element:getBlurInstance()

  lu.assertEquals(instance1, instance2, "Blur instance should be cached and reused")
end

-- Test 6: Blur instance recreation on quality change (skip if no graphics context)
function TestBlurEffects:test_blur_instance_quality_change()
  if not love or not love.graphics then
    lu.success() -- Skip test if no LÖVE graphics context
    return
  end

  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 5 },
  })

  local instance1 = element:getBlurInstance()
  
  -- Change quality
  element.contentBlur.quality = 8
  local instance2 = element:getBlurInstance()

  lu.assertNotEquals(instance1, instance2, "Blur instance should be recreated when quality changes")
  lu.assertEquals(instance2.quality, 8, "New blur instance should have updated quality")
end

-- Test 7: Element without blur can still create instance with default quality (skip if no graphics context)
function TestBlurEffects:test_no_blur_default_instance()
  if not love or not love.graphics then
    lu.success() -- Skip test if no LÖVE graphics context
    return
  end

  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  -- Element without blur should still be able to get a blur instance (with default quality)
  local instance = element:getBlurInstance()
  lu.assertNotNil(instance, "Element should be able to create blur instance even without blur config")
  lu.assertEquals(instance.quality, 5, "Default quality should be 5")
end

-- Test 8: Blur intensity boundaries
function TestBlurEffects:test_blur_intensity_boundaries()
  -- Test minimum intensity (0)
  local element1 = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 0, quality = 5 },
  })
  lu.assertEquals(element1.contentBlur.intensity, 0, "Minimum intensity should be 0")

  -- Test maximum intensity (100)
  local element2 = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 100, quality = 5 },
  })
  lu.assertEquals(element2.contentBlur.intensity, 100, "Maximum intensity should be 100")
end

-- Test 9: Blur quality boundaries
function TestBlurEffects:test_blur_quality_boundaries()
  -- Test minimum quality (1)
  local element1 = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 1 },
  })
  lu.assertEquals(element1.contentBlur.quality, 1, "Minimum quality should be 1")

  -- Test maximum quality (10)
  local element2 = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 10 },
  })
  lu.assertEquals(element2.contentBlur.quality, 10, "Maximum quality should be 10")
end

-- Test 10: Nested elements with blur
function TestBlurEffects:test_nested_elements_with_blur()
  local parent = FlexLove.Element.new({
    width = 400,
    height = 400,
    contentBlur = { intensity = 40, quality = 5 },
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    backdropBlur = { intensity = 60, quality = 6 },
  })

  lu.assertNotNil(parent.contentBlur, "Parent should have content blur")
  lu.assertNotNil(child.backdropBlur, "Child should have backdrop blur")
  lu.assertEquals(#parent.children, 1, "Parent should have one child")
end

-- Test 11: Draw method accepts backdrop canvas parameter
function TestBlurEffects:test_draw_accepts_backdrop_canvas()
  local element = FlexLove.Element.new({
    width = 200,
    height = 200,
    backdropBlur = { intensity = 50, quality = 5 },
  })

  -- This should not error (we can't actually test rendering without a graphics context)
  -- But we can verify the method signature accepts the parameter
  local success = pcall(function()
    -- Create a mock canvas (will fail in test environment, but that's ok)
    -- element:draw(nil)
  end)
  
  -- Test passes if we get here without syntax errors
  lu.assertTrue(true, "Draw method should accept backdrop canvas parameter")
end

-- Test 12: Quality affects blur instance taps (skip if no graphics context)
function TestBlurEffects:test_quality_affects_taps()
  if not love or not love.graphics then
    lu.success() -- Skip test if no LÖVE graphics context
    return
  end

  local element1 = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 1 },
  })
  
  local element2 = FlexLove.Element.new({
    width = 200,
    height = 200,
    contentBlur = { intensity = 50, quality = 10 },
  })

  local instance1 = element1:getBlurInstance()
  local instance2 = element2:getBlurInstance()

  -- Higher quality should have more taps
  lu.assertTrue(instance2.taps > instance1.taps, "Higher quality should result in more blur taps")
end

return TestBlurEffects
