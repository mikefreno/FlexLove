-- Animation Stress Profile
-- Tests animation system with many concurrent animations

local FlexLove = require("FlexLove")

local profile = {
  animationCount = 100,
  maxAnimations = 1000,
  minAnimations = 10,
  root = nil,
  animations = {},
  elements = {},
  easingFunctions = {
    "linear",
    "easeInQuad",
    "easeOutQuad",
    "easeInOutQuad",
    "easeInCubic",
    "easeOutCubic",
    "easeInOutCubic",
  },
}

function profile.init()
  FlexLove.init({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
  })

  profile.buildLayout()
end

function profile.buildLayout()
  profile.root = FlexLove.new({
    width = "100%",
    height = "100%",
    backgroundColor = {0.05, 0.05, 0.1, 1},
    flexDirection = "column",
    overflow = "scroll",
    padding = 20,
    gap = 10,
  })

  -- Create animated elements container
  local animationContainer = FlexLove.new({
    width = "100%",
    flexDirection = "row",
    flexWrap = "wrap",
    gap = 10,
    marginBottom = 20,
  })

  profile.animations = {}
  profile.elements = {}

  for i = 1, profile.animationCount do
    local hue = (i / profile.animationCount) * 360
    local baseColor = {
      0.3 + 0.5 * math.sin(hue * math.pi / 180),
      0.3 + 0.5 * math.sin((hue + 120) * math.pi / 180),
      0.3 + 0.5 * math.sin((hue + 240) * math.pi / 180),
      1
    }

    -- Choose random easing function
    local easingFunc = profile.easingFunctions[math.random(#profile.easingFunctions)]

    local box = FlexLove.new({
      width = 60,
      height = 60,
      backgroundColor = baseColor,
      borderRadius = 8,
      margin = 5,
    })

    -- Store base values for animation
    box._baseY = box.y
    box._baseOpacity = 1
    box._baseBorderRadius = 8
    box._baseColor = baseColor

    -- Create animations manually since elements may not support automatic animation
    local animDuration = 1 + math.random() * 2 -- 1-3 seconds
    
    -- Y position animation
    local yAnim = FlexLove.Animation.new({
      duration = animDuration,
      start = { offset = 0 },
      final = { offset = 20 + math.random() * 40 },
      easing = easingFunc,
    }):yoyo(true):repeatCount(0) -- 0 = infinite loop

    -- Opacity animation
    local opacityAnim = FlexLove.Animation.new({
      duration = animDuration * 0.8,
      start = { opacity = 1 },
      final = { opacity = 0.3 },
      easing = easingFunc,
    }):yoyo(true):repeatCount(0)

    -- Border radius animation
    local radiusAnim = FlexLove.Animation.new({
      duration = animDuration * 1.2,
      start = { borderRadius = 8 },
      final = { borderRadius = 30 },
      easing = easingFunc,
    }):yoyo(true):repeatCount(0)

    -- Store animations with element reference
    table.insert(profile.animations, { element = box, animation = yAnim, property = "y" })
    table.insert(profile.animations, { element = box, animation = opacityAnim, property = "opacity" })
    table.insert(profile.animations, { element = box, animation = radiusAnim, property = "borderRadius" })

    table.insert(profile.elements, box)
    animationContainer:addChild(box)
  end

  profile.root:addChild(animationContainer)

  -- Info panel
  local infoPanel = FlexLove.new({
    width = "100%",
    padding = 15,
    backgroundColor = {0.1, 0.1, 0.2, 0.9},
    borderRadius = 8,
    flexDirection = "column",
    gap = 5,
  })

  infoPanel:addChild(FlexLove.new({
    textContent = string.format("Animated Elements: %d (Press +/- to adjust)", profile.animationCount),
    fontSize = 18,
    color = {1, 1, 1, 1},
  }))

  infoPanel:addChild(FlexLove.new({
    textContent = string.format("Active Animations: %d", #profile.animations),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  infoPanel:addChild(FlexLove.new({
    textContent = "Animating: position, opacity, borderRadius",
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  infoPanel:addChild(FlexLove.new({
    textContent = string.format("Easing Functions: %d variations", #profile.easingFunctions),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  profile.root:addChild(infoPanel)
end

function profile.update(dt)
  -- Update all animations and apply to elements
  for _, animData in ipairs(profile.animations) do
    animData.animation:update(dt)
    local values = animData.animation:interpolate()
    
    if animData.property == "y" and values.offset then
      animData.element.y = (animData.element._baseY or animData.element.y) + values.offset
    elseif animData.property == "opacity" and values.opacity then
      animData.element.opacity = values.opacity
    elseif animData.property == "borderRadius" and values.borderRadius then
      animData.element.borderRadius = values.borderRadius
    end
  end
end

function profile.draw()
  if profile.root then
    profile.root:draw()
  end

  -- Overlay info
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Animation Stress Test", 10, love.graphics.getHeight() - 100)
  love.graphics.print(
    string.format("Animations: %d | Range: %d-%d",
      #profile.animations,
      profile.minAnimations * 3,
      profile.maxAnimations * 3
    ),
    10,
    love.graphics.getHeight() - 80
  )
  love.graphics.print("Press + to add 10 animated elements", 10, love.graphics.getHeight() - 60)
  love.graphics.print("Press - to remove 10 animated elements", 10, love.graphics.getHeight() - 45)
end

function profile.keypressed(key)
  if key == "=" or key == "+" then
    profile.animationCount = math.min(profile.maxAnimations, profile.animationCount + 10)
    profile.buildLayout()
  elseif key == "-" or key == "_" then
    profile.animationCount = math.max(profile.minAnimations, profile.animationCount - 10)
    profile.buildLayout()
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
  profile.buildLayout()
end

function profile.reset()
  profile.animationCount = 100
  profile.buildLayout()
end

function profile.cleanup()
  profile.animations = {}
  profile.elements = {}
  profile.root = nil
end

return profile
