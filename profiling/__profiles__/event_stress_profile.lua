-- Event Stress Profile
-- Tests event handling at scale

local FlexLove = require("FlexLove")

local profile = {
  elementCount = 200,
  maxElements = 1000,
  minElements = 50,
  root = nil,
  eventMetrics = {
    hoverCount = 0,
    clickCount = 0,
    eventsThisFrame = 0,
  },
  metricsTimer = 0,
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

  -- Interactive elements container
  local interactiveContainer = FlexLove.new({
    width = "100%",
    flexDirection = "row",
    flexWrap = "wrap",
    gap = 5,
    marginBottom = 20,
  })

  for i = 1, profile.elementCount do
    local hue = (i / profile.elementCount) * 360
    local baseColor = {
      0.3 + 0.5 * math.sin(hue * math.pi / 180),
      0.3 + 0.5 * math.sin((hue + 120) * math.pi / 180),
      0.3 + 0.5 * math.sin((hue + 240) * math.pi / 180),
      1
    }

    -- Create nested interactive hierarchy
    local outerBox = FlexLove.new({
      width = 60,
      height = 60,
      backgroundColor = baseColor,
      borderRadius = 8,
      margin = 2,
      justifyContent = "center",
      alignItems = "center",
      onEvent = function(element, event)
        if event.type == "hover" then
          profile.eventMetrics.hoverCount = profile.eventMetrics.hoverCount + 1
          profile.eventMetrics.eventsThisFrame = profile.eventMetrics.eventsThisFrame + 1
          element.backgroundColor = {
            math.min(1, baseColor[1] * 1.3),
            math.min(1, baseColor[2] * 1.3),
            math.min(1, baseColor[3] * 1.3),
            1
          }
        elseif event.type == "unhover" then
          element.backgroundColor = baseColor
        elseif event.type == "press" then
          element.borderRadius = 15
        elseif event.type == "release" then
          profile.eventMetrics.clickCount = profile.eventMetrics.clickCount + 1
          profile.eventMetrics.eventsThisFrame = profile.eventMetrics.eventsThisFrame + 1
          element.borderRadius = 8
        end
      end,
    })

    -- Add nested button for event propagation testing
    local innerBox = FlexLove.new({
      width = "60%",
      height = "60%",
      backgroundColor = {baseColor[1] * 0.6, baseColor[2] * 0.6, baseColor[3] * 0.6, 1},
      borderRadius = 5,
      onEvent = function(element, event)
        if event.type == "hover" then
          profile.eventMetrics.eventsThisFrame = profile.eventMetrics.eventsThisFrame + 1
          element.backgroundColor = {
            math.min(1, baseColor[1] * 1.5),
            math.min(1, baseColor[2] * 1.5),
            math.min(1, baseColor[3] * 1.5),
            1
          }
        elseif event.type == "unhover" then
          element.backgroundColor = {baseColor[1] * 0.6, baseColor[2] * 0.6, baseColor[3] * 0.6, 1}
        elseif event.type == "release" then
          profile.eventMetrics.eventsThisFrame = profile.eventMetrics.eventsThisFrame + 1
        end
      end,
    })

    outerBox:addChild(innerBox)
    interactiveContainer:addChild(outerBox)
  end

  profile.root:addChild(interactiveContainer)

  -- Metrics panel
  local metricsPanel = FlexLove.new({
    width = "100%",
    padding = 15,
    backgroundColor = {0.1, 0.1, 0.2, 0.9},
    borderRadius = 8,
    flexDirection = "column",
    gap = 5,
  })

  metricsPanel:addChild(FlexLove.new({
    textContent = string.format("Interactive Elements: %d (Press +/- to adjust)", profile.elementCount),
    fontSize = 18,
    color = {1, 1, 1, 1},
  }))

  metricsPanel:addChild(FlexLove.new({
    textContent = string.format("Total Hovers: %d", profile.eventMetrics.hoverCount),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  metricsPanel:addChild(FlexLove.new({
    textContent = string.format("Total Clicks: %d", profile.eventMetrics.clickCount),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  metricsPanel:addChild(FlexLove.new({
    textContent = string.format("Events/Frame: %d", profile.eventMetrics.eventsThisFrame),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  profile.root:addChild(metricsPanel)
end

function profile.update(dt)
  -- Reset per-frame event counter
  profile.metricsTimer = profile.metricsTimer + dt
  if profile.metricsTimer >= 0.1 then -- Update metrics display every 100ms
    profile.eventMetrics.eventsThisFrame = 0
    profile.metricsTimer = 0
    -- Rebuild to update metrics display
    if profile.root then
      profile.buildLayout()
    end
  end
end

function profile.draw()
  if profile.root then
    profile.root:draw()
  end

  -- Overlay info
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Event Stress Test", 10, love.graphics.getHeight() - 120)
  love.graphics.print(
    string.format("Elements: %d | Range: %d-%d",
      profile.elementCount,
      profile.minElements,
      profile.maxElements
    ),
    10,
    love.graphics.getHeight() - 100
  )
  love.graphics.print("Press + to add 25 interactive elements", 10, love.graphics.getHeight() - 80)
  love.graphics.print("Press - to remove 25 interactive elements", 10, love.graphics.getHeight() - 65)
  love.graphics.print("Hover and click elements to test event handling", 10, love.graphics.getHeight() - 50)
end

function profile.keypressed(key)
  if key == "=" or key == "+" then
    profile.elementCount = math.min(profile.maxElements, profile.elementCount + 25)
    profile.buildLayout()
  elseif key == "-" or key == "_" then
    profile.elementCount = math.max(profile.minElements, profile.elementCount - 25)
    profile.buildLayout()
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
  profile.buildLayout()
end

function profile.reset()
  profile.elementCount = 200
  profile.eventMetrics = {
    hoverCount = 0,
    clickCount = 0,
    eventsThisFrame = 0,
  }
  profile.metricsTimer = 0
  profile.buildLayout()
end

function profile.cleanup()
  profile.root = nil
end

return profile
