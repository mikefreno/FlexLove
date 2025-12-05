local FlexLove = require("FlexLove")
local PerformanceProfiler = require("profiling.utils.PerformanceProfiler")

local profile = {}

local profiler = PerformanceProfiler.new()
local elementCount = 100
local elements = {}
local currentPhase = "warmup"
local phaseFrames = 0
local targetFrames = 300 -- Collect 300 frames per phase

-- Test phases
local phases = {
  { count = 50, label = "50 Elements" },
  { count = 100, label = "100 Elements" },
  { count = 200, label = "200 Elements" },
  { count = 500, label = "500 Elements" },
  { count = 1000, label = "1000 Elements" },
}
local currentPhaseIndex = 0

function profile.init()
  -- Initialize FlexLove with performance monitoring
  FlexLove.init({
    performanceMonitoring = true,
    immediateMode = false,
  })

  profile.reset()
  currentPhase = "warmup"
  phaseFrames = 0
  currentPhaseIndex = 0
end

function profile.update(dt)
  profiler:beginFrame()

  -- Mark layout timing
  profiler:markBegin("layout")
  FlexLove.update(dt)
  profiler:markEnd("layout")

  profiler:endFrame()

  -- Phase management
  if currentPhase == "warmup" then
    phaseFrames = phaseFrames + 1
    if phaseFrames >= 60 then -- 1 second warmup
      currentPhase = "testing"
      phaseFrames = 0
      currentPhaseIndex = currentPhaseIndex + 1
      if currentPhaseIndex <= #phases then
        local phase = phases[currentPhaseIndex]
        elementCount = phase.count
        profile.reset()
        profiler:reset()
      end
    end
  elseif currentPhase == "testing" then
    phaseFrames = phaseFrames + 1
    if phaseFrames >= targetFrames then
      -- Take snapshot
      local phase = phases[currentPhaseIndex]
      local ffiEnabled = FlexLove._FFI and FlexLove._FFI.enabled
      profiler:createSnapshot(phase.label, {
        elementCount = phase.count,
        ffiEnabled = ffiEnabled,
        ffiStatus = ffiEnabled and "LuaJIT FFI" or "Standard Lua",
      })

      -- Move to next phase
      currentPhaseIndex = currentPhaseIndex + 1
      if currentPhaseIndex <= #phases then
        currentPhase = "warmup"
        phaseFrames = 0
      else
        currentPhase = "complete"
      end
    end
  end
end

function profile.draw()
  FlexLove.draw()

  -- Draw profiler overlay
  profiler:draw(10, 10, 400, 320)

  -- Draw phase info
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", 10, 340, 400, 140)

  love.graphics.setColor(1, 1, 1, 1)
  local y = 350
  local lineHeight = 18

  -- FFI Status
  local ffiStatus = "Standard Lua (No FFI)"
  if FlexLove._FFI and FlexLove._FFI.enabled then
    ffiStatus = "LuaJIT FFI Enabled ✓"
    love.graphics.setColor(0, 1, 0, 1)
  else
    love.graphics.setColor(1, 0.5, 0, 1)
  end
  love.graphics.print("Status: " .. ffiStatus, 20, y)
  y = y + lineHeight + 5

  -- Phase info
  love.graphics.setColor(1, 1, 1, 1)
  if currentPhase == "warmup" then
    love.graphics.print(string.format("Phase: Warmup (%d/%d frames)", phaseFrames, 60), 20, y)
  elseif currentPhase == "testing" then
    local phase = phases[currentPhaseIndex]
    love.graphics.print(string.format("Phase: %s (%d/%d frames)", phase.label, phaseFrames, targetFrames), 20, y)

    -- Progress bar
    local progress = phaseFrames / targetFrames
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", 20, y + 20, 360, 10)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", 20, y + 20, 360 * progress, 10)
  elseif currentPhase == "complete" then
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("Testing Complete!", 20, y)
    y = y + lineHeight
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Press 'S' to save report", 20, y)
    y = y + lineHeight
    love.graphics.print("Press 'R' to restart", 20, y)
  end
  y = y + lineHeight + 10

  -- Snapshot count
  love.graphics.setColor(0.7, 0.7, 1, 1)
  local snapshots = profiler:getSnapshots()
  love.graphics.print(string.format("Snapshots: %d/%d", #snapshots, #phases), 20, y)
  y = y + lineHeight

  -- Controls
  love.graphics.setColor(0.5, 0.5, 0.5, 1)
  love.graphics.print("S: Save | R: Restart | ESC: Exit", 20, y)
end

function profile.keypressed(key)
  if key == "s" then
    if currentPhase == "complete" then
      local success, filepath = profiler:saveReport("ffi_comparison_report")
      if success then
        print("Report saved to: " .. filepath)
      else
        print("Failed to save report: " .. tostring(filepath))
      end
    end
  elseif key == "r" then
    profile.init()
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
end

function profile.reset()
  -- Clean up old elements
  for _, elem in ipairs(elements) do
    elem:destroy()
  end
  elements = {}

  -- Create new elements
  local container = FlexLove.new({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    flexDirection = "horizontal",
    flexWrap = "wrap",
    gap = 5,
    padding = { all = 10 },
  })

  for i = 1, elementCount do
    local hue = (i / elementCount) * 360
    local r, g, b = profile.hsvToRgb(hue, 0.8, 0.9)

    local elem = FlexLove.new({
      parent = container,
      width = 60,
      height = 60,
      backgroundColor = FlexLove.Color.new(r, g, b, 1),
      cornerRadius = { all = 8 },
      text = tostring(i),
      textColor = FlexLove.Color.new(1, 1, 1, 1),
      textAlign = "center",
      textSize = 12,
    })

    table.insert(elements, elem)
  end

  table.insert(elements, container)
end

function profile.cleanup()
  for _, elem in ipairs(elements) do
    elem:destroy()
  end
  elements = {}
  FlexLove.destroy()
end

-- Helper function to convert HSV to RGB
function profile.hsvToRgb(h, s, v)
  local c = v * s
  local x = c * (1 - math.abs((h / 60) % 2 - 1))
  local m = v - c

  local r, g, b = 0, 0, 0
  if h < 60 then
    r, g, b = c, x, 0
  elseif h < 120 then
    r, g, b = x, c, 0
  elseif h < 180 then
    r, g, b = 0, c, x
  elseif h < 240 then
    r, g, b = 0, x, c
  elseif h < 300 then
    r, g, b = x, 0, c
  else
    r, g, b = c, 0, x
  end

  return r + m, g + m, b + m
end

return profile
