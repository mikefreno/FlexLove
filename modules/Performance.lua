--- Performance monitoring module for FlexLove
--- Provides timing, profiling, and performance metrics
---@class Performance
local Performance = {}

-- Load ErrorHandler (with fallback if not available)
local ErrorHandler = nil
local ErrorHandlerInitialized = false

local function getErrorHandler()
  if not ErrorHandler then
    local success, module = pcall(require, "modules.ErrorHandler")
    if success then
      ErrorHandler = module
      
      -- Initialize ErrorHandler with ErrorCodes if not already initialized
      if not ErrorHandlerInitialized then
        local successCodes, ErrorCodes = pcall(require, "modules.ErrorCodes")
        if successCodes and ErrorHandler.init then
          ErrorHandler.init({ErrorCodes = ErrorCodes})
        end
        ErrorHandlerInitialized = true
      end
    end
  end
  return ErrorHandler
end

-- Configuration
local config = {
  enabled = false,
  hudEnabled = false,
  hudToggleKey = "f3",
  hudPosition = { x = 10, y = 10 },
  warningThresholdMs = 13.0, -- Yellow warning
  criticalThresholdMs = 16.67, -- Red warning (60 FPS)
  logToConsole = false,
  logWarnings = true,
  warningsEnabled = true,
}

-- Metrics cleanup configuration
local METRICS_CLEANUP_INTERVAL = 30 -- Cleanup every 30 seconds (more aggressive)
local METRICS_RETENTION_TIME = 10 -- Keep metrics used in last 10 seconds
local MAX_METRICS_COUNT = 500 -- Maximum number of unique metrics
local CORE_METRICS = { frame = true, layout = true, render = true } -- Never cleanup these

-- State
local timers = {} -- Active timers {name -> startTime}
local metrics = {} -- Accumulated metrics {name -> {total, count, min, max, lastUsed}}
local lastMetricsCleanup = 0 -- Last time metrics were cleaned up
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
local shownWarnings = {} -- Track warnings that have been shown (dedupe)

-- Memory profiling state
local memoryProfiler = {
  enabled = false,
  sampleInterval = 60, -- Frames between samples
  framesSinceLastSample = 0,
  samples = {}, -- Array of {time, memory, tableSizes}
  maxSamples = 20, -- Keep last 20 samples (~20 seconds at 60fps)
  monitoredTables = {}, -- Tables to monitor (added via registerTable)
}

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
  shownWarnings = {}
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
      lastUsed = love.timer.getTime(),
    }
  end

  local m = metrics[name]
  m.total = m.total + elapsed
  m.count = m.count + 1
  m.min = math.min(m.min, elapsed)
  m.max = math.max(m.max, elapsed)
  m.average = m.total / m.count
  m.lastUsed = love.timer.getTime()

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

--- Update with actual delta time from LÖVE (call from love.update)
---@param dt number Delta time in seconds
function Performance.updateDeltaTime(dt)
  if not config.enabled then
    return
  end

  local now = love.timer.getTime()

  -- Update FPS from actual delta time (not processing time)
  if now - frameMetrics.lastFpsUpdate >= frameMetrics.fpsUpdateInterval then
    if dt > 0 then
      frameMetrics.fps = math.floor(1 / dt + 0.5)
    end
    frameMetrics.lastFpsUpdate = now
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

  -- Note: FPS is now calculated from actual delta time in updateDeltaTime()
  -- frameTime here represents processing time, not actual frame rate

  -- Check for frame drops
  if frameTime > config.criticalThresholdMs then
    Performance.addWarning("frame", frameTime, "critical")
  end

  -- Update memory profiling
  Performance.updateMemoryProfiling()

  -- Periodic metrics cleanup (every 30 seconds, more aggressive)
  if now - lastMetricsCleanup >= METRICS_CLEANUP_INTERVAL then
    local cleanupTime = now - METRICS_RETENTION_TIME
    for name, data in pairs(metrics) do
      -- Don't cleanup core metrics
      if not CORE_METRICS[name] and data.lastUsed and data.lastUsed < cleanupTime then
        metrics[name] = nil
      end
    end
    lastMetricsCleanup = now
  end

  -- Enforce max metrics limit
  local metricsCount = 0
  for _ in pairs(metrics) do
    metricsCount = metricsCount + 1
  end

  if metricsCount > MAX_METRICS_COUNT then
    -- Find and remove oldest non-core metrics
    local sortedMetrics = {}
    for name, data in pairs(metrics) do
      if not CORE_METRICS[name] then
        table.insert(sortedMetrics, { name = name, lastUsed = data.lastUsed or 0 })
      end
    end

    table.sort(sortedMetrics, function(a, b)
      return a.lastUsed < b.lastUsed
    end)

    -- Remove oldest metrics until we're under the limit
    local toRemove = metricsCount - MAX_METRICS_COUNT
    for i = 1, math.min(toRemove, #sortedMetrics) do
      metrics[sortedMetrics[i].name] = nil
    end
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

  local warning = {
    name = name,
    value = value,
    level = level,
    time = love.timer.getTime(),
  }

  table.insert(warnings, warning)

  -- Keep only last 100 warnings
  if #warnings > 100 then
    table.remove(warnings, 1)
  end

  -- Log to console if enabled (with deduplication per metric name)
  if config.logToConsole or config.warningsEnabled then
    local warningKey = name .. "_" .. level

    -- Only log each warning type once per 60 seconds to avoid spam
    local lastWarningTime = shownWarnings[warningKey] or 0
    local now = love.timer.getTime()

    if now - lastWarningTime >= 60 then
      -- Route through ErrorHandler for consistent logging
      local EH = getErrorHandler()
      
      if EH and EH.warn then
        local message = string.format("%s = %.2fms", name, value)
        local code = level == "critical" and "PERF_002" or "PERF_001"
        local suggestion = level == "critical" 
          and "This operation is causing frame drops. Consider optimizing or reducing frequency."
          or "This operation is taking longer than recommended. Monitor for patterns."
        
        EH.warn("Performance", code, message, {
          metric = name,
          value = string.format("%.2fms", value),
          threshold = level == "critical" and config.criticalThresholdMs or config.warningThresholdMs,
        }, suggestion)
      else
        -- Fallback to direct print if ErrorHandler not available
        local prefix = level == "critical" and "[CRITICAL]" or "[WARNING]"
        local message = string.format("%s Performance: %s = %.2fms", prefix, name, value)
        print(message)
      end
      
      shownWarnings[warningKey] = now
    end
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

  -- Use config position if x/y not provided
  x = x or config.hudPosition.x
  y = y or config.hudPosition.y

  local fm = Performance.getFrameMetrics()
  local mm = Performance.getMemoryMetrics()

  -- Background
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", x, y, 300, 220)

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

  -- Metrics count
  local metricsCount = 0
  for _ in pairs(metrics) do
    metricsCount = metricsCount + 1
  end
  local metricsColor = metricsCount > MAX_METRICS_COUNT * 0.8 and { 1, 0.5, 0 } or { 1, 1, 1 }
  love.graphics.setColor(metricsColor)
  love.graphics.print(string.format("Metrics: %d/%d", metricsCount, MAX_METRICS_COUNT), x + 10, currentY)
  currentY = currentY + lineHeight

  -- Separator
  love.graphics.setColor(1, 1, 1, 1)
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

--- Check if performance warnings are enabled
--- @return boolean enabled True if warnings are enabled
function Performance.areWarningsEnabled()
  return config.warningsEnabled
end

--- Log a performance warning (only once per warning key)
--- @param warningKey string Unique key for this warning type
--- @param module string Module name (e.g., "LayoutEngine", "Element")
--- @param message string Warning message
--- @param details table? Additional details
--- @param suggestion string? Optimization suggestion
function Performance.logWarning(warningKey, module, message, details, suggestion)
  if not config.warningsEnabled then
    return
  end

  -- Only show each warning once per session
  if shownWarnings[warningKey] then
    return
  end

  shownWarnings[warningKey] = true

  -- Limit shownWarnings size to prevent memory leak (keep last 1000 unique warnings)
  local count = 0
  for _ in pairs(shownWarnings) do
    count = count + 1
  end
  if count > 1000 then
    -- Reset when limit exceeded (simple approach - could be more sophisticated)
    shownWarnings = { [warningKey] = true }
  end

  -- Use ErrorHandler if available
  local EH = getErrorHandler()
  if EH and EH.warn then
    EH.warn(module, "PERF_001", message, details or {}, suggestion)
  else
    -- Fallback to print
    print(string.format("[FlexLove - %s] Performance Warning: %s", module, message))
    if suggestion then
      print(string.format("  Suggestion: %s", suggestion))
    end
  end
end

--- Reset shown warnings (useful for testing or session restart)
function Performance.resetShownWarnings()
  shownWarnings = {}
end

--- Track a counter metric (increments per frame)
--- @param name string Counter name
--- @param value number? Value to add (default: 1)
function Performance.incrementCounter(name, value)
  if not config.enabled then
    return
  end

  value = value or 1

  if not metrics[name] then
    metrics[name] = {
      total = 0,
      count = 0,
      min = math.huge,
      max = 0,
      average = 0,
      frameValue = 0, -- Current frame value
      lastUsed = love.timer.getTime(),
    }
  end

  local m = metrics[name]
  m.frameValue = (m.frameValue or 0) + value
  m.lastUsed = love.timer.getTime()
end

--- Reset frame counters (call at end of frame)
function Performance.resetFrameCounters()
  if not config.enabled then
    return
  end

  local now = love.timer.getTime()
  local toRemove = {}

  for name, data in pairs(metrics) do
    if data.frameValue then
      -- Update statistics only if value is non-zero
      if data.frameValue > 0 then
        data.total = data.total + data.frameValue
        data.count = data.count + 1
        data.min = math.min(data.min, data.frameValue)
        data.max = math.max(data.max, data.frameValue)
        data.average = data.total / data.count
        data.lastUsed = now
      end

      -- Reset frame value
      data.frameValue = 0

      -- Mark zero-count metrics for removal (non-core)
      if data.count == 0 and not CORE_METRICS[name] then
        table.insert(toRemove, name)
      end
    end
  end

  -- Remove zero-value counters
  for _, name in ipairs(toRemove) do
    metrics[name] = nil
  end
end

--- Get current frame counter value
--- @param name string Counter name
--- @return number value Current frame value
function Performance.getFrameCounter(name)
  if not config.enabled or not metrics[name] then
    return 0
  end
  return metrics[name].frameValue or 0
end

-- ====================
-- Memory Profiling
-- ====================

--- Enable memory profiling
function Performance.enableMemoryProfiling()
  memoryProfiler.enabled = true
end

--- Disable memory profiling
function Performance.disableMemoryProfiling()
  memoryProfiler.enabled = false
end

--- Register a table for memory leak monitoring
--- @param name string Friendly name for the table
--- @param tableRef table Reference to the table to monitor
function Performance.registerTableForMonitoring(name, tableRef)
  memoryProfiler.monitoredTables[name] = tableRef
end

--- Get table size (number of entries)
--- @param tbl table Table to measure
--- @return number count Number of entries
local function getTableSize(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

--- Sample memory and table sizes
local function sampleMemory()
  local sample = {
    time = love.timer.getTime(),
    memory = collectgarbage("count") / 1024, -- MB
    tableSizes = {},
  }

  for name, tableRef in pairs(memoryProfiler.monitoredTables) do
    sample.tableSizes[name] = getTableSize(tableRef)
  end

  table.insert(memoryProfiler.samples, sample)

  -- Keep only maxSamples
  if #memoryProfiler.samples > memoryProfiler.maxSamples then
    table.remove(memoryProfiler.samples, 1)
  end

  -- Check for memory leaks (consistent growth)
  if #memoryProfiler.samples >= 5 then
    for name, _ in pairs(memoryProfiler.monitoredTables) do
      local sizes = {}
      for i = math.max(1, #memoryProfiler.samples - 4), #memoryProfiler.samples do
        table.insert(sizes, memoryProfiler.samples[i].tableSizes[name])
      end

      -- Check if table is consistently growing
      local growing = true
      for i = 2, #sizes do
        if sizes[i] <= sizes[i - 1] then
          growing = false
          break
        end
      end

      if growing and sizes[#sizes] > sizes[1] * 1.5 then
        Performance.addWarning("memory_leak", sizes[#sizes], "warning")
        
        if not shownWarnings[name] then
          -- Route through ErrorHandler for consistent logging
          local EH = getErrorHandler()
          
          if EH and EH.warn then
            local message = string.format("Table '%s' growing consistently", name)
            EH.warn("Performance", "MEM_001", message, {
              table = name,
              initialSize = sizes[1],
              currentSize = sizes[#sizes],
              growthPercent = math.floor(((sizes[#sizes] / sizes[1]) - 1) * 100),
            }, "Check for memory leaks in this table. Review cache eviction policies and ensure objects are properly released.")
          else
            -- Fallback to direct print
            print(string.format("[FlexLove] MEMORY LEAK WARNING: Table '%s' growing consistently (%d -> %d)", name, sizes[1], sizes[#sizes]))
          end
          
          shownWarnings[name] = true
        end
      elseif not growing then
        -- Reset warning flag if table stopped growing
        shownWarnings[name] = nil
      end
    end
  end
end

--- Update memory profiling (call from endFrame)
function Performance.updateMemoryProfiling()
  if not memoryProfiler.enabled then
    return
  end

  memoryProfiler.framesSinceLastSample = memoryProfiler.framesSinceLastSample + 1

  if memoryProfiler.framesSinceLastSample >= memoryProfiler.sampleInterval then
    sampleMemory()
    memoryProfiler.framesSinceLastSample = 0
  end
end

--- Get memory profiling data
--- @return table profile {samples, monitoredTables}
function Performance.getMemoryProfile()
  return {
    samples = memoryProfiler.samples,
    monitoredTables = {},
    enabled = memoryProfiler.enabled,
  }
end

--- Reset memory profiling data
function Performance.resetMemoryProfile()
  memoryProfiler.samples = {}
  memoryProfiler.framesSinceLastSample = 0
  shownWarnings = {}
end

return Performance
