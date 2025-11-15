--- Performance Monitoring Example
--- Demonstrates how to use the Performance module

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub and Performance module
require("testing.loveStub")
local Performance = require("modules.Performance")

print("=== Performance Module Example ===\n")

-- 1. Initialize and enable performance monitoring
print("1. Initializing Performance monitoring...")
Performance.init({
  enabled = true,
  logToConsole = true,
  logWarnings = true,
})
print("   Enabled: " .. tostring(Performance.isEnabled()))
print()

-- 2. Test basic timer functionality
print("2. Testing timers...")
Performance.startTimer("test_operation")
-- Simulate some work
local sum = 0
for i = 1, 1000000 do
  sum = sum + i
end
local elapsed = Performance.stopTimer("test_operation")
print(string.format("   Test operation completed in %.3fms", elapsed))
print()

-- 3. Test measure wrapper
print("3. Testing measure wrapper...")
local expensiveFunction = function(n)
  local result = 0
  for i = 1, n do
    result = result + math.sqrt(i)
  end
  return result
end

local measuredFunction = Performance.measure("expensive_calculation", expensiveFunction)
local result = measuredFunction(100000)
print(string.format("   Expensive calculation result: %.2f", result))
print()

-- 4. Simulate frame timing
print("4. Simulating frame timing...")
for _ = 1, 10 do
  Performance.startFrame()

  -- Simulate frame work
  Performance.startTimer("frame_layout")
  local layoutSum = 0
  for i = 1, 50000 do
    layoutSum = layoutSum + i
  end
  Performance.stopTimer("frame_layout")

  Performance.startTimer("frame_render")
  local renderSum = 0
  for i = 1, 30000 do
    renderSum = renderSum + i
  end
  Performance.stopTimer("frame_render")

  Performance.endFrame()
end
print(string.format("   Simulated %d frames", 10))
print()

-- 5. Get and display metrics
print("5. Performance Metrics:")
local metrics = Performance.getMetrics()
print(string.format("   FPS: %d", metrics.frame.fps))
print(string.format("   Average Frame Time: %.3fms", metrics.frame.averageFrameTime))
print(string.format("   Min/Max Frame Time: %.3f/%.3fms", metrics.frame.minFrameTime, metrics.frame.maxFrameTime))
print(string.format("   Memory: %.2f MB (peak: %.2f MB)", metrics.memory.currentMb, metrics.memory.peakMb))
print()

print("6. Top Timings:")
for name, data in pairs(metrics.timings) do
  print(string.format("   %s:", name))
  print(string.format("     Average: %.3fms", data.average))
  print(string.format("     Min/Max: %.3f/%.3fms", data.min, data.max))
  print(string.format("     Count: %d", data.count))
end
print()

-- 7. Export metrics
print("7. Exporting metrics...")
local json = Performance.exportJSON()
print("   JSON Export:")
print(json)
print()

local csv = Performance.exportCSV()
print("   CSV Export:")
print(csv)
print()

-- 8. Test warnings
print("8. Recent Warnings:")
local warnings = Performance.getWarnings(5)
if #warnings > 0 then
  for _, warning in ipairs(warnings) do
    print(string.format("   [%s] %s: %.3fms", warning.level, warning.name, warning.value))
  end
else
  print("   No warnings")
end
print()

-- 9. Reset and verify
print("9. Testing reset...")
Performance.reset()
local newMetrics = Performance.getMetrics()
print(string.format("   Frame count after reset: %d", newMetrics.frame.frameCount))
print(string.format("   Timings count after reset: %d", #newMetrics.timings))
print()

print("=== Performance Module Example Complete ===")
