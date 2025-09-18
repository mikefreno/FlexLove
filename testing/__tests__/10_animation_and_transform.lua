package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

-- Create test cases
TestAnimationAndTransform = {}

function TestAnimationAndTransform:setUp()
  self.GUI = FlexLove.GUI
end

function TestAnimationAndTransform:testBasicTranslation()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test translate transformation
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.translate)
  element:translate(50, 30)
  luaunit.assertEquals(element.x, 50)
  luaunit.assertEquals(element.y, 30)
end

function TestAnimationAndTransform:testScale()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test scale transformation
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.scale)
  element:scale(2, 1.5)
  luaunit.assertEquals(element.width, 200)
  luaunit.assertEquals(element.height, 150)
end

function TestAnimationAndTransform:testRotation()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test rotation transformation (in radians)
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.rotate)
  local angle = math.pi / 4 -- 45 degrees
  element:rotate(angle)
  luaunit.assertNotNil(element.rotation)
  luaunit.assertEquals(element.rotation, angle)
end

function TestAnimationAndTransform:testAnimationTweening()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Start position animation
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.animate)
  luaunit.assertNotNil(element.update)
  element:animate({
    x = 200,
    y = 150,
    duration = 1.0,
    easing = "linear",
  })

  -- Test initial state
  luaunit.assertEquals(element.x, 0)
  luaunit.assertEquals(element.y, 0)

  -- Simulate time passing (0.5 seconds)
  element:update(0.5)

  -- Test mid-animation state (linear interpolation)
  luaunit.assertEquals(element.x, 100) -- Half way there
  luaunit.assertEquals(element.y, 75) -- Half way there
end

function TestAnimationAndTransform:testChainedTransformations()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Apply multiple transformations in sequence
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.translate)
  luaunit.assertNotNil(element.scale)
  luaunit.assertNotNil(element.rotate)
  element:translate(50, 50):scale(2, 2):rotate(math.pi / 2)

  -- Verify final state
  luaunit.assertEquals(element.x, 50)
  luaunit.assertEquals(element.y, 50)
  luaunit.assertEquals(element.width, 200)
  luaunit.assertEquals(element.height, 200)
  luaunit.assertNotNil(element.rotation)
  luaunit.assertEquals(element.rotation, math.pi / 2)
end

function TestAnimationAndTransform:testAnimationCancellation()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Start animation
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.animate)
  luaunit.assertNotNil(element.update)
  luaunit.assertNotNil(element.stopAnimation)
  element:animate({
    x = 200,
    y = 200,
    duration = 2.0,
  })

  -- Update partially
  element:update(0.5)

  -- Cancel animation
  element:stopAnimation()

  -- Position should remain at last updated position
  local x = element.x
  local y = element.y

  -- Update again to ensure animation stopped
  element:update(0.5)

  luaunit.assertEquals(element.x, x)
  luaunit.assertEquals(element.y, y)
end

function TestAnimationAndTransform:testMultiplePropertyAnimation()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    alpha = 1.0,
  })

  -- Animate multiple properties simultaneously
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.animate)
  luaunit.assertNotNil(element.update)
  element:animate({
    x = 200,
    y = 200,
    width = 200,
    height = 200,
    alpha = 0.5,
    duration = 1.0,
    easing = "linear",
  })

  -- Update halfway
  element:update(0.5)

  -- Test all properties at midpoint
  luaunit.assertEquals(element.x, 100)
  luaunit.assertEquals(element.y, 100)
  luaunit.assertEquals(element.width, 150)
  luaunit.assertEquals(element.height, 150)
  luaunit.assertNotNil(element.alpha)
  luaunit.assertEquals(element.alpha, 0.75)
end

function TestAnimationAndTransform:testEasingFunctions()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test different easing functions
  local easings = { "linear", "easeInQuad", "easeOutQuad", "easeInOutQuad" }

  for _, easing in ipairs(easings) do
    element.x = 0
    luaunit.assertNotNil(element.animate)
    element:animate({
      x = 100,
      duration = 1.0,
      easing = easing,
    })

    element:update(0.5)

    -- Ensure animation is progressing (exact values depend on easing function)
    luaunit.assertTrue(element.x > 0 and element.x < 100)
  end
end

luaunit.LuaUnit.run()
