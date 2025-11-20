---@class PerformanceProfiler
---@field _frameCount number
---@field _startTime number
---@field _frameTimes table
---@field _fpsHistory table
---@field _memoryHistory table
---@field _customMetrics table
---@field _markers table
---@field _currentFrameStart number?
---@field _maxHistorySize number
---@field _lastGcCount number
local PerformanceProfiler = {}
PerformanceProfiler.__index = PerformanceProfiler

---@param config {maxHistorySize: number?}?
---@return PerformanceProfiler
function PerformanceProfiler.new(config)
  local self = setmetatable({}, PerformanceProfiler)

  config = config or {}
  self._maxHistorySize = config.maxHistorySize or 300

  self._frameCount = 0
  self._startTime = love.timer.getTime()
  self._frameTimes = {}
  self._fpsHistory = {}
  self._memoryHistory = {}
  self._customMetrics = {}
  self._markers = {}
  self._currentFrameStart = nil
  self._lastGcCount = collectgarbage("count")

  return self
end

---@return nil
function PerformanceProfiler:beginFrame()
  local now = love.timer.getTime()
  
  -- Calculate actual frame time from previous frame start to current frame start
  if self._currentFrameStart then
    local frameTime = (now - self._currentFrameStart) * 1000
    
    table.insert(self._frameTimes, frameTime)
    if #self._frameTimes > self._maxHistorySize then
      table.remove(self._frameTimes, 1)
    end
    
    local fps = 1000 / frameTime
    table.insert(self._fpsHistory, fps)
    if #self._fpsHistory > self._maxHistorySize then
      table.remove(self._fpsHistory, 1)
    end
    
    local memKb = collectgarbage("count")
    table.insert(self._memoryHistory, memKb / 1024)
    if #self._memoryHistory > self._maxHistorySize then
      table.remove(self._memoryHistory, 1)
    end
    
    self._lastGcCount = memKb
  end
  
  self._currentFrameStart = now
  self._frameCount = self._frameCount + 1
end

---@return nil
function PerformanceProfiler:endFrame()
  -- No longer needed - frame timing is done in beginFrame()
  -- Keeping this method for API compatibility
end

---@param name string
---@return nil
function PerformanceProfiler:markBegin(name)
  if not self._markers[name] then
    self._markers[name] = {
      times = {},
      totalTime = 0,
      count = 0,
      minTime = math.huge,
      maxTime = 0,
    }
  end

  self._markers[name].startTime = love.timer.getTime()
end

---@param name string
---@return number?
function PerformanceProfiler:markEnd(name)
  local marker = self._markers[name]
  if not marker or not marker.startTime then
    return nil
  end

  local elapsed = (love.timer.getTime() - marker.startTime) * 1000
  marker.startTime = nil

  table.insert(marker.times, elapsed)
  if #marker.times > self._maxHistorySize then
    table.remove(marker.times, 1)
  end

  marker.totalTime = marker.totalTime + elapsed
  marker.count = marker.count + 1
  marker.minTime = math.min(marker.minTime, elapsed)
  marker.maxTime = math.max(marker.maxTime, elapsed)

  return elapsed
end

---@param name string
---@param value number
---@return nil
function PerformanceProfiler:recordMetric(name, value)
  if not self._customMetrics[name] then
    self._customMetrics[name] = {
      values = {},
      total = 0,
      count = 0,
      min = math.huge,
      max = -math.huge,
    }
  end

  local metric = self._customMetrics[name]
  table.insert(metric.values, value)
  if #metric.values > self._maxHistorySize then
    table.remove(metric.values, 1)
  end

  metric.total = metric.total + value
  metric.count = metric.count + 1
  metric.min = math.min(metric.min, value)
  metric.max = math.max(metric.max, value)
end

---@param values table
---@return number
local function calculateMean(values)
  if #values == 0 then
    return 0
  end
  local sum = 0
  for _, v in ipairs(values) do
    sum = sum + v
  end
  return sum / #values
end

---@param values table
---@return number
local function calculateMedian(values)
  if #values == 0 then
    return 0
  end

  local sorted = {}
  for _, v in ipairs(values) do
    table.insert(sorted, v)
  end
  table.sort(sorted)

  local mid = math.floor(#sorted / 2) + 1
  if #sorted % 2 == 0 then
    return (sorted[mid - 1] + sorted[mid]) / 2
  else
    return sorted[mid]
  end
end

---@param values table
---@param percentile number
---@return number
local function calculatePercentile(values, percentile)
  if #values == 0 then
    return 0
  end

  local sorted = {}
  for _, v in ipairs(values) do
    table.insert(sorted, v)
  end
  table.sort(sorted)

  local index = math.ceil(#sorted * percentile / 100)
  index = math.max(1, math.min(index, #sorted))
  return sorted[index]
end

---@return table
function PerformanceProfiler:getReport()
  local now = love.timer.getTime()
  local totalTime = now - self._startTime

  local report = {
    totalTime = totalTime,
    frameCount = self._frameCount,
    averageFps = self._frameCount / totalTime,

    frameTime = {
      current = self._frameTimes[#self._frameTimes] or 0,
      average = calculateMean(self._frameTimes),
      median = calculateMedian(self._frameTimes),
      min = math.huge,
      max = 0,
      p95 = calculatePercentile(self._frameTimes, 95),
      p99 = calculatePercentile(self._frameTimes, 99),
      p99_9 = calculatePercentile(self._frameTimes, 99.9),
    },

    fps = {
      current = self._fpsHistory[#self._fpsHistory] or 0,
      average = calculateMean(self._fpsHistory),
      median = calculateMedian(self._fpsHistory),
      min = math.huge,
      max = 0,
      -- For FPS, 1% and 0.1% worst are the LOWEST values (inverse of percentile)
      worst_1_percent = calculatePercentile(self._fpsHistory, 1),
      worst_0_1_percent = calculatePercentile(self._fpsHistory, 0.1),
    },

    memory = {
      current = self._memoryHistory[#self._memoryHistory] or 0,
      average = calculateMean(self._memoryHistory),
      peak = -math.huge,
      min = math.huge,
      p95 = calculatePercentile(self._memoryHistory, 95),
      p99 = calculatePercentile(self._memoryHistory, 99),
      p99_9 = calculatePercentile(self._memoryHistory, 99.9),
    },

    markers = {},
    customMetrics = {},
  }

  -- Calculate frame time min/max
  for _, ft in ipairs(self._frameTimes) do
    report.frameTime.min = math.min(report.frameTime.min, ft)
    report.frameTime.max = math.max(report.frameTime.max, ft)
  end

  -- Calculate FPS min/max
  for _, fps in ipairs(self._fpsHistory) do
    report.fps.min = math.min(report.fps.min, fps)
    report.fps.max = math.max(report.fps.max, fps)
  end

  -- Calculate memory min/max/peak
  for _, mem in ipairs(self._memoryHistory) do
    report.memory.min = math.min(report.memory.min, mem)
    report.memory.peak = math.max(report.memory.peak, mem)
  end

  -- Add marker statistics
  for name, marker in pairs(self._markers) do
    report.markers[name] = {
      average = marker.count > 0 and (marker.totalTime / marker.count) or 0,
      median = calculateMedian(marker.times),
      min = marker.minTime,
      max = marker.maxTime,
      count = marker.count,
      p95 = calculatePercentile(marker.times, 95),
      p99 = calculatePercentile(marker.times, 99),
    }
  end

  -- Add custom metrics
  for name, metric in pairs(self._customMetrics) do
    report.customMetrics[name] = {
      average = metric.count > 0 and (metric.total / metric.count) or 0,
      median = calculateMedian(metric.values),
      min = metric.min,
      max = metric.max,
      count = metric.count,
    }
  end

  return report
end

---@param x number?
---@param y number?
---@param width number?
---@param height number?
---@return nil
function PerformanceProfiler:draw(x, y, width, height)
  x = x or 10
  y = y or 10
  width = width or 320
  height = height or 280

  local report = self:getReport()

  love.graphics.setColor(0, 0, 0, 0.85)
  love.graphics.rectangle("fill", x, y, width, height)

  love.graphics.setColor(1, 1, 1, 1)
  local lineHeight = 18
  local currentY = y + 10
  local padding = 10

  -- Title
  love.graphics.setColor(0.3, 0.8, 1, 1)
  love.graphics.print("Performance Profiler", x + padding, currentY)
  currentY = currentY + lineHeight + 5

  -- FPS
  local fpsColor = { 1, 1, 1 }
  if report.frameTime.current > 16.67 then
    fpsColor = { 1, 0, 0 }
  elseif report.frameTime.current > 13.0 then
    fpsColor = { 1, 1, 0 }
  else
    fpsColor = { 0, 1, 0 }
  end
  love.graphics.setColor(fpsColor)
  love.graphics.print(string.format("FPS: %.0f (%.2fms)", report.fps.current, report.frameTime.current), x + padding, currentY)
  currentY = currentY + lineHeight

  -- Average FPS
  love.graphics.setColor(0.8, 0.8, 0.8, 1)
  love.graphics.print(string.format("Avg: %.0f fps (%.2fms)", report.fps.average, report.frameTime.average), x + padding, currentY)
  currentY = currentY + lineHeight

  -- Frame time stats
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(string.format("Min/Max: %.2f/%.2fms", report.frameTime.min, report.frameTime.max), x + padding, currentY)
  currentY = currentY + lineHeight
  love.graphics.print(string.format("P95/P99: %.2f/%.2fms", report.frameTime.p95, report.frameTime.p99), x + padding, currentY)
  currentY = currentY + lineHeight + 3

  -- Memory
  love.graphics.setColor(0.5, 1, 0.5, 1)
  love.graphics.print(string.format("Memory: %.2f MB", report.memory.current), x + padding, currentY)
  currentY = currentY + lineHeight
  love.graphics.setColor(0.8, 0.8, 0.8, 1)
  love.graphics.print(string.format("Peak: %.2f MB | Avg: %.2f MB", report.memory.peak, report.memory.average), x + padding, currentY)
  currentY = currentY + lineHeight + 3

  -- Total time and frames
  love.graphics.setColor(0.7, 0.7, 1, 1)
  love.graphics.print(string.format("Frames: %d | Time: %.1fs", report.frameCount, report.totalTime), x + padding, currentY)
  currentY = currentY + lineHeight + 5

  -- Markers (top 5 by average time)
  if next(report.markers) then
    love.graphics.setColor(1, 0.8, 0.4, 1)
    love.graphics.print("Top Markers:", x + padding, currentY)
    currentY = currentY + lineHeight

    local sortedMarkers = {}
    for name, data in pairs(report.markers) do
      table.insert(sortedMarkers, { name = name, average = data.average })
    end
    table.sort(sortedMarkers, function(a, b)
      return a.average > b.average
    end)

    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    for i = 1, math.min(3, #sortedMarkers) do
      local m = sortedMarkers[i]
      love.graphics.print(string.format("  %s: %.3fms", m.name, m.average), x + padding, currentY)
      currentY = currentY + lineHeight
    end
  end
end

---@return nil
function PerformanceProfiler:reset()
  self._frameCount = 0
  self._startTime = love.timer.getTime()
  self._frameTimes = {}
  self._fpsHistory = {}
  self._memoryHistory = {}
  self._customMetrics = {}
  self._markers = {}
  self._currentFrameStart = nil
  self._lastGcCount = collectgarbage("count")
end

---@return string
function PerformanceProfiler:exportJSON()
  local report = self:getReport()

  local function serializeValue(val, indent)
    indent = indent or ""
    local t = type(val)

    if t == "table" then
      local items = {}
      local isArray = true
      local count = 0

      for k, _ in pairs(val) do
        count = count + 1
        if type(k) ~= "number" or k ~= count then
          isArray = false
          break
        end
      end

      if isArray then
        for _, v in ipairs(val) do
          table.insert(items, serializeValue(v, indent .. "  "))
        end
        return "[\n" .. indent .. "  " .. table.concat(items, ",\n" .. indent .. "  ") .. "\n" .. indent .. "]"
      else
        for k, v in pairs(val) do
          table.insert(items, string.format('%s"%s": %s', indent .. "  ", k, serializeValue(v, indent .. "  ")))
        end
        return "{\n" .. table.concat(items, ",\n") .. "\n" .. indent .. "}"
      end
    elseif t == "string" then
      return string.format('"%s"', val)
    elseif t == "number" then
      if val == math.huge then
        return "null"
      elseif val == -math.huge then
        return "null"
      elseif val ~= val then -- NaN
        return "null"
      else
        return tostring(val)
      end
    elseif t == "boolean" then
      return tostring(val)
    else
      return "null"
    end
  end

  return serializeValue(report, "")
end

---@param profileName string
---@return boolean, string?
function PerformanceProfiler:saveReport(profileName)
  local report = self:getReport()
  local timestamp = os.date("%Y-%m-%d_%H-%M:%S")
  local filename = string.format("%s.md", timestamp)

  -- Get the actual project directory (where the profiling folder is)
  local sourceDir = love.filesystem.getSource()
  local profileDir, filepath
  
  if sourceDir:match("%.love$") then
    -- If running from a .love file, fall back to save directory
    sourceDir = love.filesystem.getSaveDirectory()
    profileDir = sourceDir .. "/reports/" .. profileName
    filepath = profileDir .. "/" .. filename

    -- Create profile-specific directory if it doesn't exist
    love.filesystem.createDirectory("reports/" .. profileName)
    
    return self:_saveWithLoveFS(filepath, profileName)
  else
    -- Running from source - sourceDir is the profiling directory
    -- We want to save to profiling/reports/{profileName}/
    profileDir = sourceDir .. "/reports/" .. profileName
    filepath = profileDir .. "/" .. filename

    -- Create profile-specific directory if it doesn't exist (using io module)
    os.execute('mkdir -p "' .. profileDir .. '"')

    return self:_saveWithIO(filepath, profileName)
  end
end

---@param filepath string
---@param profileName string
---@return boolean, string?
function PerformanceProfiler:_saveWithIO(filepath, profileName)
  local report = self:getReport()
  local profileDir = filepath:match("(.*/)") -- Extract directory from path

  -- Generate Markdown report
  local lines = {}
  table.insert(lines, "# Performance Profile Report: " .. profileName)
  table.insert(lines, "")
  table.insert(lines, "**Generated:** " .. os.date("%Y-%m-%d %H:%M:%S"))
  table.insert(lines, "")
  table.insert(lines, "---")
  table.insert(lines, "")

  -- Summary
  table.insert(lines, "## Summary")
  table.insert(lines, "")
  table.insert(lines, string.format("- **Total Duration:** %.2f seconds", report.totalTime))
  table.insert(lines, string.format("- **Total Frames:** %d", report.frameCount))
  table.insert(lines, "")

  -- FPS Statistics
  table.insert(lines, "## FPS Statistics")
  table.insert(lines, "")
  table.insert(lines, "| Metric | Value |")
  table.insert(lines, "|--------|-------|")
  table.insert(lines, string.format("| Average FPS | %.2f |", report.fps.average))
  table.insert(lines, string.format("| Median FPS | %.2f |", report.fps.median))
  table.insert(lines, string.format("| Min FPS | %.2f |", report.fps.min))
  table.insert(lines, string.format("| Max FPS | %.2f |", report.fps.max))
  table.insert(lines, string.format("| **1%% Worst FPS** | **%.2f** |", report.fps.worst_1_percent))
  table.insert(lines, string.format("| **0.1%% Worst FPS** | **%.2f** |", report.fps.worst_0_1_percent))
  table.insert(lines, "")
  table.insert(lines, "> 1% and 0.1% worst represent the FPS threshold at which 1% and 0.1% of frames performed at or below.")
  table.insert(lines, "")

  -- Frame Time Statistics
  table.insert(lines, "## Frame Time Statistics")
  table.insert(lines, "")
  table.insert(lines, "| Metric | Value (ms) |")
  table.insert(lines, "|--------|------------|")
  table.insert(lines, string.format("| Average | %.2f |", report.frameTime.average))
  table.insert(lines, string.format("| Median | %.2f |", report.frameTime.median))
  table.insert(lines, string.format("| Min | %.2f |", report.frameTime.min))
  table.insert(lines, string.format("| Max | %.2f |", report.frameTime.max))
  table.insert(lines, string.format("| 95th Percentile | %.2f |", report.frameTime.p95))
  table.insert(lines, string.format("| 99th Percentile | %.2f |", report.frameTime.p99))
  table.insert(lines, string.format("| 99.9th Percentile | %.2f |", report.frameTime.p99_9))
  table.insert(lines, "")

  -- Memory Statistics
  table.insert(lines, "## Memory Usage")
  table.insert(lines, "")
  table.insert(lines, "| Metric | Value (MB) |")
  table.insert(lines, "|--------|------------|")
  table.insert(lines, string.format("| Current | %.2f |", report.memory.current))
  table.insert(lines, string.format("| Average | %.2f |", report.memory.average))
  table.insert(lines, string.format("| Peak | %.2f |", report.memory.peak))
  table.insert(lines, string.format("| Min | %.2f |", report.memory.min))
  table.insert(lines, string.format("| 95th Percentile | %.2f |", report.memory.p95))
  table.insert(lines, string.format("| 99th Percentile | %.2f |", report.memory.p99))
  table.insert(lines, string.format("| 99.9th Percentile | %.2f |", report.memory.p99_9))
  table.insert(lines, "")

  -- Markers (if any)
  if next(report.markers) then
    table.insert(lines, "## Custom Markers")
    table.insert(lines, "")
    for name, data in pairs(report.markers) do
      table.insert(lines, string.format("### %s", name))
      table.insert(lines, "")
      table.insert(lines, "| Metric | Value (ms) |")
      table.insert(lines, "|--------|------------|")
      table.insert(lines, string.format("| Average | %.3f |", data.average))
      table.insert(lines, string.format("| Median | %.3f |", data.median))
      table.insert(lines, string.format("| Min | %.3f |", data.min))
      table.insert(lines, string.format("| Max | %.3f |", data.max))
      table.insert(lines, string.format("| Count | %d |", data.count))
      table.insert(lines, "")
    end
  end

  -- Custom Metrics (if any)
  if next(report.customMetrics) then
    table.insert(lines, "## Custom Metrics")
    table.insert(lines, "")
    for name, data in pairs(report.customMetrics) do
      table.insert(lines, string.format("### %s", name))
      table.insert(lines, "")
      table.insert(lines, "| Metric | Value |")
      table.insert(lines, "|--------|-------|")
      table.insert(lines, string.format("| Average | %.2f |", data.average))
      table.insert(lines, string.format("| Median | %.2f |", data.median))
      table.insert(lines, string.format("| Min | %.2f |", data.min))
      table.insert(lines, string.format("| Max | %.2f |", data.max))
      table.insert(lines, string.format("| Count | %d |", data.count))
      table.insert(lines, "")
    end
  end

  table.insert(lines, "---")
  table.insert(lines, "")

  -- Save to file using io module (writes to actual directory, not sandboxed)
  local content = table.concat(lines, "\n")
  local file, err = io.open(filepath, "w")

  if not file then
    return false, "Failed to open file: " .. tostring(err)
  end

  local success, writeErr = pcall(function()
    file:write(content)
    file:close()
  end)

  if not success then
    return false, "Failed to write report: " .. tostring(writeErr)
  end

  -- Also save JSON version
  local jsonFilepath = filepath:gsub("%.md$", ".json")
  local jsonFile = io.open(jsonFilepath, "w")
  if jsonFile then
    pcall(function()
      jsonFile:write(self:exportJSON())
      jsonFile:close()
    end)
  end

  -- Save as "latest" for easy access
  local latestMarkdownPath = profileDir .. "/latest.md"
  local latestJsonPath = profileDir .. "/latest.json"
  
  local latestMdFile = io.open(latestMarkdownPath, "w")
  if latestMdFile then
    pcall(function()
      latestMdFile:write(content)
      latestMdFile:close()
    end)
  end
  
  local latestJsonFile = io.open(latestJsonPath, "w")
  if latestJsonFile then
    pcall(function()
      latestJsonFile:write(self:exportJSON())
      latestJsonFile:close()
    end)
  end

  return true, filepath
end

return PerformanceProfiler
