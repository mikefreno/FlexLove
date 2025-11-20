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
  self._currentFrameStart = love.timer.getTime()
  self._frameCount = self._frameCount + 1
end

---@return nil
function PerformanceProfiler:endFrame()
  if not self._currentFrameStart then
    return
  end
  
  local now = love.timer.getTime()
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
  self._currentFrameStart = nil
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
  if #values == 0 then return 0 end
  local sum = 0
  for _, v in ipairs(values) do
    sum = sum + v
  end
  return sum / #values
end

---@param values table
---@return number
local function calculateMedian(values)
  if #values == 0 then return 0 end
  
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
  if #values == 0 then return 0 end
  
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
    },
    
    fps = {
      current = self._fpsHistory[#self._fpsHistory] or 0,
      average = calculateMean(self._fpsHistory),
      median = calculateMedian(self._fpsHistory),
      min = math.huge,
      max = 0,
    },
    
    memory = {
      current = self._memoryHistory[#self._memoryHistory] or 0,
      average = calculateMean(self._memoryHistory),
      peak = -math.huge,
      min = math.huge,
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
  local fpsColor = {1, 1, 1}
  if report.frameTime.current > 16.67 then
    fpsColor = {1, 0, 0}
  elseif report.frameTime.current > 13.0 then
    fpsColor = {1, 1, 0}
  else
    fpsColor = {0, 1, 0}
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
      table.insert(sortedMarkers, {name = name, average = data.average})
    end
    table.sort(sortedMarkers, function(a, b) return a.average > b.average end)
    
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

return PerformanceProfiler
