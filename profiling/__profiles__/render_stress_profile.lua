-- Render Stress Profile
-- Tests rendering with heavy draw operations

local FlexLove = require("FlexLove")

local profile = {
  elementCount = 200,
  maxElements = 2000,
  minElements = 50,
  root = nil,
  showRounded = true,
  showText = true,
  showLayering = true,
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

  -- Render container
  local renderContainer = FlexLove.new({
    width = "100%",
    flexDirection = "row",
    flexWrap = "wrap",
    gap = 5,
    marginBottom = 20,
  })

  for i = 1, profile.elementCount do
    local hue = (i / profile.elementCount) * 360
    local color = {
      0.3 + 0.5 * math.sin(hue * math.pi / 180),
      0.3 + 0.5 * math.sin((hue + 120) * math.pi / 180),
      0.3 + 0.5 * math.sin((hue + 240) * math.pi / 180),
      1
    }

    local box = FlexLove.new({
      width = 50,
      height = 50,
      backgroundColor = color,
      borderRadius = profile.showRounded and (5 + math.random(20)) or 0,
      margin = 2,
    })

    -- Add text rendering if enabled
    if profile.showText then
      box:addChild(FlexLove.new({
        textContent = tostring(i),
        fontSize = 12,
        color = {1, 1, 1, 0.8},
      }))
    end

    -- Add layering (nested elements) if enabled
    if profile.showLayering and i % 3 == 0 then
      local innerBox = FlexLove.new({
        width = "80%",
        height = "80%",
        backgroundColor = {color[1] * 0.5, color[2] * 0.5, color[3] * 0.5, 0.7},
        borderRadius = profile.showRounded and 8 or 0,
        justifyContent = "center",
        alignItems = "center",
      })
      box:addChild(innerBox)
    end

    renderContainer:addChild(box)
  end

  profile.root:addChild(renderContainer)

  -- Controls panel
  local controlsPanel = FlexLove.new({
    width = "100%",
    padding = 15,
    backgroundColor = {0.1, 0.1, 0.2, 0.9},
    borderRadius = 8,
    flexDirection = "column",
    gap = 8,
  })

  controlsPanel:addChild(FlexLove.new({
    textContent = string.format("Render Elements: %d (Press +/- to adjust)", profile.elementCount),
    fontSize = 18,
    color = {1, 1, 1, 1},
  }))

  controlsPanel:addChild(FlexLove.new({
    textContent = string.format("[R] Rounded Rectangles: %s", profile.showRounded and "ON" or "OFF"),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  controlsPanel:addChild(FlexLove.new({
    textContent = string.format("[T] Text Rendering: %s", profile.showText and "ON" or "OFF"),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  controlsPanel:addChild(FlexLove.new({
    textContent = string.format("[L] Layering/Overdraw: %s", profile.showLayering and "ON" or "OFF"),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  profile.root:addChild(controlsPanel)
end

function profile.update(dt)
end

function profile.draw()
  if profile.root then
    profile.root:draw()
  end

  -- Overlay info
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Render Stress Test", 10, love.graphics.getHeight() - 120)
  love.graphics.print(
    string.format("Elements: %d | Range: %d-%d",
      profile.elementCount,
      profile.minElements,
      profile.maxElements
    ),
    10,
    love.graphics.getHeight() - 100
  )
  love.graphics.print("Press + to add 50 elements", 10, love.graphics.getHeight() - 80)
  love.graphics.print("Press - to remove 50 elements", 10, love.graphics.getHeight() - 65)
  love.graphics.print("Press R/T/L to toggle features", 10, love.graphics.getHeight() - 50)
end

function profile.keypressed(key)
  if key == "=" or key == "+" then
    profile.elementCount = math.min(profile.maxElements, profile.elementCount + 50)
    profile.buildLayout()
  elseif key == "-" or key == "_" then
    profile.elementCount = math.max(profile.minElements, profile.elementCount - 50)
    profile.buildLayout()
  elseif key == "r" then
    profile.showRounded = not profile.showRounded
    profile.buildLayout()
  elseif key == "t" then
    profile.showText = not profile.showText
    profile.buildLayout()
  elseif key == "l" then
    profile.showLayering = not profile.showLayering
    profile.buildLayout()
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
  profile.buildLayout()
end

function profile.reset()
  profile.elementCount = 200
  profile.showRounded = true
  profile.showText = true
  profile.showLayering = true
  profile.buildLayout()
end

function profile.cleanup()
  profile.root = nil
end

return profile
