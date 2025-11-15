--- Performance monitoring module for FlexLove
--- Provides timing, profiling, and performance metrics
---@class Performance
local Performance = {}

-- Configuration
local config = {
  enabled = false,
  hudEnabled = false,
  hudToggleKey = "f3",
  warningThresholdMs = 13.0, -- Yellow warning
  criticalThresholdMs = 16.67, -- Red warning (60 FPS)
  logToConsole = false,
  logWarnings = true,
}

-- State
local timers = {} -- Active timers {name -> startTime}
local metrics = {} -- Accumulated metrics {name -> {total, count, min, max}}
local frameMetrics = {
  frameCount = 0,
  totalTime = 0,
  lastFrameTime = 0,
  minFrameTime = math.huge,
  maxFrameTime = 0,
  fps = 0,
  lastFpsUpdate = 0,
  fpsUpdateInterval = 0.5, -- Update FPS every 0.5s
}
local memoryMetrics = {
  current = 0,
  peak = 0,
  gcCount = 0,
  lastGcCheck = 0,
}
local warnings = {}
local lastFrameStart = nil

--- Initialize performance monitoring
--- @param options table? Optional configuration overrides
function Performance.init(options)
  if options then
    for k, v in pairs(options) do
      config[k] = v
    end
  end
  Performance.reset()
end

--- Enable performance monitoring
function Performance.enable()
  config.enabled = true
end

--- Disable performance monitoring
function Performance.disable()
  config.enabled = false
end

--- Check if performance monitoring is enabled
--- @return boolean
function Performance.isEnabled()
  return config.enabled
end

--- Toggle performance HUD
function Performance.toggleHUD()
  config.hudEnabled = not config.hudEnabled
end

--- Reset all metrics
function Performance.reset()
  timers = {}
  metrics = {}
  warnings = {}
  frameMetrics.frameCount = 0
  frameMetrics.totalTime = 0
  frameMetrics.lastFrameTime = 0
  frameMetrics.minFrameTime = math.huge
  frameMetrics.maxFrameTime = 0
  memoryMetrics.current = 0
  memoryMetrics.peak = 0
  memoryMetrics.gcCount = 0
end

--- Start a named timer
--- @param name string Timer name
function Performance.startTimer(name)
  if not config.enabled then
    return
  end
  timers[name] = love.timer.getTime()
end

--- Stop a named timer and record the elapsed time
--- @param name string Timer name
--- @return number? elapsedMs Elapsed time in milliseconds, or nil if timer not found
function Performance.stopTimer(name)
  if not config.enabled then
    return nil
  end

  local startTime = timers[name]
  if not startTime then
    if config.logWarnings then
      print(string.format("[Performance] Warning: Timer '%s' was not started", name))
    end
    return nil
  end

  local elapsed = (love.timer.getTime() - startTime) * 1000 -- Convert to ms
  timers[name] = nil

  -- Update metrics
  if not metrics[name] then
    metrics[name] = {
      total = 0,
      count = 0,
      min = math.huge,
      max = 0,
      average = 0,
    }
  end

  local m = metrics[name]
  m.total = m.total + elapsed
  m.count = m.count + 1
  m.min = math.min(m.min, elapsed)
  m.max = math.max(m.max, elapsed)
  m.average = m.total / m.count

  -- Check for warnings
  if elapsed > config.criticalThresholdMs then
    Performance.addWarning(name, elapsed, "critical")
  elseif elapsed > config.warningThresholdMs then
    Performance.addWarning(name, elapsed, "warning")
  end

  if config.logToConsole then
    print(string.format("[Performance] %s: %.3fms", name, elapsed))
  end

  return elapsed
end

--- Wrap a function with performance timing
--- @param name string Metric name
--- @param fn function Function to measure
--- @return function Wrapped function
function Performance.measure(name, fn)
  if not config.enabled then
    return fn
  end

  return function(...)
    Performance.startTimer(name)
    local results = table.pack(fn(...))
    Performance.stopTimer(name)
    return table.unpack(results, 1, results.n)
  end
end

--- Start frame timing (call at beginning of frame)
function Performance.startFrame()
  if not config.enabled then
    return
  end
  lastFrameStart = love.timer.getTime()
  Performance.updateMemory()
end

--- End frame timing (call at end of frame)
function Performance.endFrame()
  if not config.enabled or not lastFrameStart then
    return
  end

  local now = love.timer.getTime()
  local frameTime = (now - lastFrameStart) * 1000 -- ms

  frameMetrics.lastFrameTime = frameTime
  frameMetrics.totalTime = frameMetrics.totalTime + frameTime
  frameMetrics.frameCount = frameMetrics.frameCount + 1
  frameMetrics.minFrameTime = math.min(frameMetrics.minFrameTime, frameTime)
  frameMetrics.maxFrameTime = math.max(frameMetrics.maxFrameTime, frameTime)

  -- Update FPS
  if now - frameMetrics.lastFpsUpdate >= frameMetrics.fpsUpdateInterval then
    frameMetrics.fps = math.floor(1000 / frameTime + 0.5)
    frameMetrics.lastFpsUpdate = now
  end

  -- Check for frame drops
  if frameTime > config.criticalThresholdMs then
    Performance.addWarning("frame", frameTime, "critical")
  end
end

--- Update memory metrics
function Performance.updateMemory()
  if not config.enabled then
    return
  end

  local memKb = collectgarbage("count")
  memoryMetrics.current = memKb
  memoryMetrics.peak = math.max(memoryMetrics.peak, memKb)

  -- Track GC cycles
  local now = love.timer.getTime()
  if now - memoryMetrics.lastGcCheck >= 1.0 then
    memoryMetrics.gcCount = memoryMetrics.gcCount + 1
    memoryMetrics.lastGcCheck = now
  end
end

--- Add a performance warning
--- @param name string Metric name
--- @param value number Metric value
--- @param level "warning"|"critical" Warning level
function Performance.addWarning(name, value, level)
  if not config.logWarnings then
    return
  end

  table.insert(warnings, {
    name = name,
    value = value,
    level = level,
    time = love.timer.getTime(),
  })

  -- Keep only last 100 warnings
  if #warnings > 100 then
    table.remove(warnings, 1)
  end
end

--- Get current FPS
--- @return number fps Frames per second
function Performance.getFPS()
  return frameMetrics.fps
end

--- Get frame metrics
--- @return table frameMetrics Frame timing data
function Performance.getFrameMetrics()
  return {
    fps = frameMetrics.fps,
    lastFrameTime = frameMetrics.lastFrameTime,
    minFrameTime = frameMetrics.minFrameTime,
    maxFrameTime = frameMetrics.maxFrameTime,
    averageFrameTime = frameMetrics.frameCount > 0 and frameMetrics.totalTime / frameMetrics.frameCount or 0,
    frameCount = frameMetrics.frameCount,
  }
end

--- Get memory metrics
--- @return table memoryMetrics Memory usage data
function Performance.getMemoryMetrics()
  Performance.updateMemory()
  return {
    currentKb = memoryMetrics.current,
    currentMb = memoryMetrics.current / 1024,
    peakKb = memoryMetrics.peak,
    peakMb = memoryMetrics.peak / 1024,
    gcCount = memoryMetrics.gcCount,
  }
end

--- Get all performance metrics
--- @return table metrics All collected metrics
function Performance.getMetrics()
  local result = {
    frame = Performance.getFrameMetrics(),
    memory = Performance.getMemoryMetrics(),
    timings = {},
  }

  for name, data in pairs(metrics) do
    result.timings[name] = {
      average = data.average,
      min = data.min,
      max = data.max,
      total = data.total,
      count = data.count,
    }
  end

  return result
end

--- Get recent warnings
--- @param count number? Number of warnings to return (default: 10)
--- @return table warnings Recent warnings
function Performance.getWarnings(count)
  count = count or 10
  local result = {}
  local start = math.max(1, #warnings - count + 1)
  for i = start, #warnings do
    table.insert(result, warnings[i])
  end
  return result
end

--- Export metrics to JSON format
--- @return string json JSON string of metrics
function Performance.exportJSON()
  local allMetrics = Performance.getMetrics()
  -- Simple JSON encoding (for more complex needs, use a JSON library)
  local json = "{\n"
  json = json .. string.format('  "fps": %d,\n', allMetrics.frame.fps)
  json = json .. string.format('  "averageFrameTime": %.3f,\n', allMetrics.frame.averageFrameTime)
  json = json .. string.format('  "memoryMb": %.2f,\n', allMetrics.memory.currentMb)
  json = json .. '  "timings": {\n'

  local timingPairs = {}
  for name, data in pairs(allMetrics.timings) do
    table.insert(
      timingPairs,
      string.format('    "%s": {"average": %.3f, "min": %.3f, "max": %.3f, "count": %d}', name, data.average, data.min, data.max, data.count)
    )
  end
  json = json .. table.concat(timingPairs, ",\n") .. "\n"

  json = json .. "  }\n"
  json = json .. "}"
  return json
end

--- Export metrics to CSV format
--- @return string csv CSV string of metrics
function Performance.exportCSV()
  local csv = "Name,Average (ms),Min (ms),Max (ms),Count\n"
  for name, data in pairs(metrics) do
    csv = csv .. string.format("%s,%.3f,%.3f,%.3f,%d\n", name, data.average, data.min, data.max, data.count)
  end
  return csv
end

--- Render performance HUD
--- @param x number? X position (default: 10)
--- @param y number? Y position (default: 10)
function Performance.renderHUD(x, y)
  if not config.hudEnabled then
    return
  end

  x = x or 10
  y = y or 10

  local fm = Performance.getFrameMetrics()
  local mm = Performance.getMemoryMetrics()

  -- Background
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", x, y, 300, 200)

  -- Text
  love.graphics.setColor(1, 1, 1, 1)
  local lineHeight = 18
  local currentY = y + 10

  -- FPS
  local fpsColor = { 1, 1, 1 }
  if fm.lastFrameTime > config.criticalThresholdMs then
    fpsColor = { 1, 0, 0 } -- Red
  elseif fm.lastFrameTime > config.warningThresholdMs then
    fpsColor = { 1, 1, 0 } -- Yellow
  end
  love.graphics.setColor(fpsColor)
  love.graphics.print(string.format("FPS: %d (%.2fms)", fm.fps, fm.lastFrameTime), x + 10, currentY)
  currentY = currentY + lineHeight

  -- Frame times
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(string.format("Avg Frame: %.2fms", fm.averageFrameTime), x + 10, currentY)
  currentY = currentY + lineHeight
  love.graphics.print(string.format("Min/Max: %.2f/%.2fms", fm.minFrameTime, fm.maxFrameTime), x + 10, currentY)
  currentY = currentY + lineHeight

  -- Memory
  love.graphics.print(string.format("Memory: %.2f MB (peak: %.2f MB)", mm.currentMb, mm.peakMb), x + 10, currentY)
  currentY = currentY + lineHeight

  -- Separator
  currentY = currentY + 5

  -- Top timings
  local sortedMetrics = {}
  for name, data in pairs(metrics) do
    table.insert(sortedMetrics, { name = name, average = data.average })
  end
  table.sort(sortedMetrics, function(a, b)
    return a.average > b.average
  end)

  love.graphics.print("Top Timings:", x + 10, currentY)
  currentY = currentY + lineHeight

  for i = 1, math.min(5, #sortedMetrics) do
    local m = sortedMetrics[i]
    love.graphics.print(string.format("  %s: %.3fms", m.name, m.average), x + 10, currentY)
    currentY = currentY + lineHeight
  end

  -- Warnings count
  if #warnings > 0 then
    love.graphics.setColor(1, 0.5, 0, 1)
    love.graphics.print(string.format("Warnings: %d", #warnings), x + 10, currentY)
  end
end

--- Handle keyboard input for HUD toggle
--- @param key string Key pressed
function Performance.keypressed(key)
  if key == config.hudToggleKey then
    Performance.toggleHUD()
  end
end

--- Get configuration
--- @return table config Current configuration
function Performance.getConfig()
  return config
end

--- Set configuration option
--- @param key string Configuration key
--- @param value any Configuration value
function Performance.setConfig(key, value)
  config[key] = value
end

return Performance
