-- Immediate Mode Profile
-- Tests immediate mode where UI recreates each frame

local FlexLove = require("FlexLove")

local profile = {
  elementCount = 50,
  maxElements = 300,
  minElements = 10,
  frameCount = 0,
}

function profile.init()
  FlexLove.init({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    immediateMode = true,
  })
end

function profile.buildUI()
  -- In immediate mode, we recreate the UI every frame
  local root = FlexLove.new({
    id = "root", -- ID required for state persistence
    width = "100%",
    height = "100%",
    backgroundColor = {0.05, 0.05, 0.1, 1},
    flexDirection = "column",
    overflow = "scroll",
    padding = 20,
    gap = 10,
  })

  -- Dynamic content container
  local content = FlexLove.new({
    id = "content",
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

    -- Each element needs a unique ID for state persistence
    local box = FlexLove.new({
      id = string.format("box_%d", i),
      width = 60,
      height = 60,
      backgroundColor = baseColor,
      borderRadius = 8,
      margin = 2,
      onEvent = function(element, event)
        if event.type == "hover" then
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
          element.borderRadius = 8
        end
      end,
    })

    content:addChild(box)
  end

  root:addChild(content)

  -- Info panel (also recreated each frame)
  local infoPanel = FlexLove.new({
    id = "infoPanel",
    width = "100%",
    padding = 15,
    backgroundColor = {0.1, 0.1, 0.2, 0.9},
    borderRadius = 8,
    flexDirection = "column",
    gap = 5,
  })

  infoPanel:addChild(FlexLove.new({
    id = "info_title",
    textContent = string.format("Immediate Mode: %d Elements", profile.elementCount),
    fontSize = 18,
    color = {1, 1, 1, 1},
  }))

  infoPanel:addChild(FlexLove.new({
    id = "info_frame",
    textContent = string.format("Frame: %d", profile.frameCount),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  infoPanel:addChild(FlexLove.new({
    id = "info_states",
    textContent = string.format("Active States: %d", FlexLove.getStateCount()),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  infoPanel:addChild(FlexLove.new({
    id = "info_help",
    textContent = "Press +/- to adjust element count",
    fontSize = 12,
    color = {0.7, 0.7, 0.7, 1},
  }))

  root:addChild(infoPanel)

  return root
end

function profile.update(dt)
  profile.frameCount = profile.frameCount + 1
end

function profile.draw()
  -- Immediate mode: rebuild UI every frame
  FlexLove.beginFrame()
  local root = profile.buildUI()
  FlexLove.endFrame()

  -- Draw the UI
  if root then
    root:draw()
  end

  -- Overlay info
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Immediate Mode Stress Test", 10, love.graphics.getHeight() - 120)
  love.graphics.print(
    string.format("Elements: %d | Range: %d-%d",
      profile.elementCount,
      profile.minElements,
      profile.maxElements
    ),
    10,
    love.graphics.getHeight() - 100
  )
  love.graphics.print(
    string.format("Frames: %d | States: %d",
      profile.frameCount,
      FlexLove.getStateCount()
    ),
    10,
    love.graphics.getHeight() - 80
  )
  love.graphics.print("Press + to add 10 elements", 10, love.graphics.getHeight() - 60)
  love.graphics.print("Press - to remove 10 elements", 10, love.graphics.getHeight() - 45)
end

function profile.keypressed(key)
  if key == "=" or key == "+" then
    profile.elementCount = math.min(profile.maxElements, profile.elementCount + 10)
  elseif key == "-" or key == "_" then
    profile.elementCount = math.max(profile.minElements, profile.elementCount - 10)
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
end

function profile.reset()
  profile.elementCount = 50
  profile.frameCount = 0
  FlexLove.clearAllStates()
end

function profile.cleanup()
  FlexLove.clearAllStates()
end

return profile
