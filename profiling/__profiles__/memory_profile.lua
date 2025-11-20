-- Memory Profile
-- Tests memory usage and GC patterns

local FlexLove = require("FlexLove")

local profile = {
  elementCount = 100,
  maxElements = 500,
  minElements = 50,
  root = nil,
  memoryStats = {
    startMemory = 0,
    currentMemory = 0,
    peakMemory = 0,
    gcCount = 0,
    lastGCTime = 0,
  },
  updateTimer = 0,
  createDestroyTimer = 0,
  createDestroyInterval = 2, -- seconds between create/destroy cycles
}

function profile.init()
  FlexLove.init({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    gcStrategy = "manual", -- Manual GC for testing
  })

  -- Record starting memory
  collectgarbage("collect")
  collectgarbage("collect")
  profile.memoryStats.startMemory = collectgarbage("count") / 1024 -- MB
  profile.memoryStats.peakMemory = profile.memoryStats.startMemory

  profile.buildLayout()
end

function profile.buildLayout()
  -- Clear existing root
  if profile.root then
    profile.root = nil
  end

  profile.root = FlexLove.new({
    width = "100%",
    height = "100%",
    backgroundColor = {0.05, 0.05, 0.1, 1},
    flexDirection = "column",
    overflow = "scroll",
    padding = 20,
    gap = 10,
  })

  -- Create elements container
  local elementsContainer = FlexLove.new({
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
      borderRadius = 8,
      margin = 2,
    })

    elementsContainer:addChild(box)
  end

  profile.root:addChild(elementsContainer)

  -- Memory stats panel
  local statsPanel = FlexLove.new({
    width = "100%",
    padding = 15,
    backgroundColor = {0.1, 0.1, 0.2, 0.9},
    borderRadius = 8,
    flexDirection = "column",
    gap = 5,
  })

  local currentMem = collectgarbage("count") / 1024
  local memGrowth = currentMem - profile.memoryStats.startMemory

  statsPanel:addChild(FlexLove.new({
    textContent = string.format("Memory Profile | Elements: %d", profile.elementCount),
    fontSize = 18,
    color = {1, 1, 1, 1},
  }))

  statsPanel:addChild(FlexLove.new({
    textContent = string.format("Current: %.2f MB | Peak: %.2f MB", currentMem, profile.memoryStats.peakMemory),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  statsPanel:addChild(FlexLove.new({
    textContent = string.format("Growth: %.2f MB | GC Count: %d", memGrowth, profile.memoryStats.gcCount),
    fontSize = 14,
    color = {0.8, 0.8, 0.8, 1},
  }))

  statsPanel:addChild(FlexLove.new({
    textContent = "Press G to force GC | Press +/- to adjust elements",
    fontSize = 12,
    color = {0.7, 0.7, 0.7, 1},
  }))

  profile.root:addChild(statsPanel)
end

function profile.update(dt)
  profile.updateTimer = profile.updateTimer + dt
  profile.createDestroyTimer = profile.createDestroyTimer + dt

  -- Update memory stats every 0.5 seconds
  if profile.updateTimer >= 0.5 then
    profile.updateTimer = 0
    profile.memoryStats.currentMemory = collectgarbage("count") / 1024

    if profile.memoryStats.currentMemory > profile.memoryStats.peakMemory then
      profile.memoryStats.peakMemory = profile.memoryStats.currentMemory
    end

    -- Rebuild to update stats display
    profile.buildLayout()
  end

  -- Automatically create and destroy elements to stress GC
  if profile.createDestroyTimer >= profile.createDestroyInterval then
    profile.createDestroyTimer = 0

    -- Destroy old elements
    profile.root = nil

    -- Create new elements
    profile.buildLayout()
  end
end

function profile.draw()
  if profile.root then
    profile.root:draw()
  end

  -- Overlay info
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Memory Stress Test", 10, love.graphics.getHeight() - 140)
  love.graphics.print(
    string.format("Elements: %d | Range: %d-%d",
      profile.elementCount,
      profile.minElements,
      profile.maxElements
    ),
    10,
    love.graphics.getHeight() - 120
  )
  love.graphics.print(
    string.format("Memory: %.2f MB | Peak: %.2f MB",
      collectgarbage("count") / 1024,
      profile.memoryStats.peakMemory
    ),
    10,
    love.graphics.getHeight() - 100
  )
  love.graphics.print(
    string.format("GC Count: %d | Strategy: manual",
      profile.memoryStats.gcCount
    ),
    10,
    love.graphics.getHeight() - 80
  )
  love.graphics.print("Press G to force garbage collection", 10, love.graphics.getHeight() - 60)
  love.graphics.print("Press + to add 25 elements", 10, love.graphics.getHeight() - 45)
  love.graphics.print("Press - to remove 25 elements", 10, love.graphics.getHeight() - 30)
end

function profile.keypressed(key)
  if key == "=" or key == "+" then
    profile.elementCount = math.min(profile.maxElements, profile.elementCount + 25)
    profile.buildLayout()
  elseif key == "-" or key == "_" then
    profile.elementCount = math.max(profile.minElements, profile.elementCount - 25)
    profile.buildLayout()
  elseif key == "g" then
    -- Force garbage collection
    local beforeGC = collectgarbage("count") / 1024
    collectgarbage("collect")
    collectgarbage("collect") -- Run twice for thorough cleanup
    local afterGC = collectgarbage("count") / 1024
    profile.memoryStats.gcCount = profile.memoryStats.gcCount + 1
    profile.memoryStats.lastGCTime = love.timer.getTime()

    print(string.format("Manual GC: %.2f MB -> %.2f MB (freed %.2f MB)",
      beforeGC, afterGC, beforeGC - afterGC))

    profile.buildLayout() -- Update stats display
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
  profile.buildLayout()
end

function profile.reset()
  profile.elementCount = 100
  collectgarbage("collect")
  collectgarbage("collect")
  profile.memoryStats.startMemory = collectgarbage("count") / 1024
  profile.memoryStats.peakMemory = profile.memoryStats.startMemory
  profile.memoryStats.gcCount = 0
  profile.memoryStats.lastGCTime = 0
  profile.updateTimer = 0
  profile.createDestroyTimer = 0
  profile.buildLayout()
end

function profile.cleanup()
  profile.root = nil
  collectgarbage("collect")
  collectgarbage("collect")
end

return profile
