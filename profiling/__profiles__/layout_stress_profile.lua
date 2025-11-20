-- Layout Stress Profile
-- Tests layout engine performance with large element hierarchies

local FlexLove = require("FlexLove")

local profile = {
  elementCount = 100,
  maxElements = 5000,
  nestingDepth = 5,
  root = nil,
}

function profile.init()
  FlexLove.init({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
  })

  profile.buildLayout()
end

function profile.buildLayout()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  profile.root = FlexLove.new({
    width = "100%",
    height = "100%",
    backgroundColor = FlexLove.Color.new(0.05, 0.05, 0.1, 1),
    positioning = "flex",
    flexDirection = "vertical",
    overflowY = "scroll",
    padding = { horizontal = 20, vertical = 20 },
    gap = 10,
  })

  local elementsPerRow = math.floor(math.sqrt(profile.elementCount))
  local rows = math.ceil(profile.elementCount / elementsPerRow)

  for r = 1, rows do
    local row = FlexLove.new({
      positioning = "flex",
    flexDirection = "horizontal",
      gap = 10,
      flexWrap = "wrap",
    })

    local itemsInRow = math.min(elementsPerRow, profile.elementCount - (r - 1) * elementsPerRow)
    for c = 1, itemsInRow do
      local hue = ((r - 1) * elementsPerRow + c) / profile.elementCount
      local color = FlexLove.Color.new(
        0.3 + 0.5 * math.sin(hue * math.pi * 2),
        0.3 + 0.5 * math.sin((hue + 0.33) * math.pi * 2),
        0.3 + 0.5 * math.sin((hue + 0.66) * math.pi * 2),
        1
      )

      local box = FlexLove.new({
        width = 80,
        height = 80,
        backgroundColor = color,
        borderRadius = 8,
        positioning = "flex",
      justifyContent = "center",
        alignItems = "center",
      })

      local nested = box
      for d = 1, math.min(profile.nestingDepth, 3) do
        local innerBox = FlexLove.new({
          width = "80%",
          height = "80%",
          backgroundColor = FlexLove.Color.new(color.r * 0.8, color.g * 0.8, color.b * 0.8, color.a),
          borderRadius = 6,
          positioning = "flex",
      justifyContent = "center",
          alignItems = "center",
        })
        nested:addChild(innerBox)
        nested = innerBox
      end

      row:addChild(box)
    end

    profile.root:addChild(row)
  end

  local infoPanel = FlexLove.new({
    width = "100%",
    padding = { horizontal = 15, vertical = 15 },
    backgroundColor = FlexLove.Color.new(0.1, 0.1, 0.2, 0.9),
    borderRadius = 8,
    marginTop = 20,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 5,
  })

  infoPanel:addChild(FlexLove.new({
    text = string.format("Elements: %d (Press +/- to adjust)", profile.elementCount),
    fontSize = 18,
    textColor = FlexLove.Color.new(1, 1, 1, 1),
  }))

  infoPanel:addChild(FlexLove.new({
    text = string.format("Nesting Depth: %d", profile.nestingDepth),
    fontSize = 14,
    textColor = FlexLove.Color.new(0.8, 0.8, 0.8, 1),
  }))

  profile.root:addChild(infoPanel)
end

function profile.update(dt)
end

function profile.draw()
  if profile.root then
    profile.root:draw()
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Layout Stress Test", 10, love.graphics.getHeight() - 100)
  love.graphics.print(string.format("Elements: %d | Max: %d", profile.elementCount, profile.maxElements), 10, love.graphics.getHeight() - 80)
  love.graphics.print("Press + to add 50 elements", 10, love.graphics.getHeight() - 60)
  love.graphics.print("Press - to remove 50 elements", 10, love.graphics.getHeight() - 45)
end

function profile.keypressed(key)
  if key == "=" or key == "+" then
    profile.elementCount = math.min(profile.maxElements, profile.elementCount + 50)
    profile.buildLayout()
  elseif key == "-" or key == "_" then
    profile.elementCount = math.max(10, profile.elementCount - 50)
    profile.buildLayout()
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
  profile.buildLayout()
end

function profile.reset()
  profile.elementCount = 100
  profile.buildLayout()
end

function profile.cleanup()
  profile.root = nil
end

return profile
