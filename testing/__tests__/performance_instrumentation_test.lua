-- Test Performance Instrumentation
package.path = package.path .. ";./?.lua;./modules/?.lua"

local luaunit = require("testing.luaunit")
local loveStub = require("testing.loveStub")

-- Set up stub before requiring modules
_G.love = loveStub

local Performance = require("modules.Performance")

TestPerformanceInstrumentation = {}

function TestPerformanceInstrumentation:setUp()
  Performance.reset()
  Performance.enable()
end

function TestPerformanceInstrumentation:tearDown()
  Performance.disable()
  Performance.reset()
end

function TestPerformanceInstrumentation:testTimerStartStop()
  Performance.startTimer("test_operation")
  
  -- Simulate some work
  local sum = 0
  for i = 1, 1000 do
    sum = sum + i
  end
  
  local elapsed = Performance.stopTimer("test_operation")
  
  luaunit.assertNotNil(elapsed)
  luaunit.assertTrue(elapsed >= 0)
  
  local metrics = Performance.getMetrics()
  luaunit.assertNotNil(metrics.timings["test_operation"])
  luaunit.assertEquals(metrics.timings["test_operation"].count, 1)
end

function TestPerformanceInstrumentation:testMultipleTimers()
  -- Start multiple timers
  Performance.startTimer("layout")
  Performance.startTimer("render")
  
  local sum = 0
  for i = 1, 100 do sum = sum + i end
  
  Performance.stopTimer("layout")
  Performance.stopTimer("render")
  
  local metrics = Performance.getMetrics()
  luaunit.assertNotNil(metrics.timings["layout"])
  luaunit.assertNotNil(metrics.timings["render"])
end

function TestPerformanceInstrumentation:testFrameTiming()
  Performance.startFrame()
  
  -- Simulate frame work
  local sum = 0
  for i = 1, 1000 do
    sum = sum + i
  end
  
  Performance.endFrame()
  
  local frameMetrics = Performance.getFrameMetrics()
  luaunit.assertNotNil(frameMetrics)
  luaunit.assertEquals(frameMetrics.frameCount, 1)
  luaunit.assertTrue(frameMetrics.lastFrameTime >= 0)
end

function TestPerformanceInstrumentation:testDrawCallCounting()
  Performance.incrementCounter("draw_calls", 1)
  Performance.incrementCounter("draw_calls", 1)
  Performance.incrementCounter("draw_calls", 1)
  
  local counter = Performance.getFrameCounter("draw_calls")
  luaunit.assertEquals(counter, 3)
  
  -- Reset and check
  Performance.resetFrameCounters()
  counter = Performance.getFrameCounter("draw_calls")
  luaunit.assertEquals(counter, 0)
end

function TestPerformanceInstrumentation:testHUDToggle()
  luaunit.assertFalse(Performance.getConfig().hudEnabled)
  
  Performance.toggleHUD()
  luaunit.assertTrue(Performance.getConfig().hudEnabled)
  
  Performance.toggleHUD()
  luaunit.assertFalse(Performance.getConfig().hudEnabled)
end

function TestPerformanceInstrumentation:testEnableDisable()
  Performance.enable()
  luaunit.assertTrue(Performance.isEnabled())
  
  Performance.disable()
  luaunit.assertFalse(Performance.isEnabled())
  
  -- Timers should not record when disabled
  Performance.startTimer("disabled_test")
  local elapsed = Performance.stopTimer("disabled_test")
  luaunit.assertNil(elapsed)
end

function TestPerformanceInstrumentation:testMeasureFunction()
  local function expensiveOperation(n)
    local sum = 0
    for i = 1, n do
      sum = sum + i
    end
    return sum
  end
  
  local wrapped = Performance.measure("expensive_op", expensiveOperation)
  local result = wrapped(1000)
  
  luaunit.assertEquals(result, 500500) -- sum of 1 to 1000
  
  local metrics = Performance.getMetrics()
  luaunit.assertNotNil(metrics.timings["expensive_op"])
  luaunit.assertEquals(metrics.timings["expensive_op"].count, 1)
end

function TestPerformanceInstrumentation:testMemoryTracking()
  Performance.updateMemory()
  
  local memMetrics = Performance.getMemoryMetrics()
  luaunit.assertNotNil(memMetrics)
  luaunit.assertTrue(memMetrics.currentKb > 0)
  luaunit.assertTrue(memMetrics.currentMb > 0)
  luaunit.assertTrue(memMetrics.peakKb >= memMetrics.currentKb)
end

function TestPerformanceInstrumentation:testExportJSON()
  Performance.startTimer("test_op")
  Performance.stopTimer("test_op")
  
  local json = Performance.exportJSON()
  luaunit.assertNotNil(json)
  luaunit.assertTrue(string.find(json, "fps") ~= nil)
  luaunit.assertTrue(string.find(json, "test_op") ~= nil)
end

function TestPerformanceInstrumentation:testExportCSV()
  Performance.startTimer("test_op")
  Performance.stopTimer("test_op")
  
  local csv = Performance.exportCSV()
  luaunit.assertNotNil(csv)
  luaunit.assertTrue(string.find(csv, "Name,Average") ~= nil)
  luaunit.assertTrue(string.find(csv, "test_op") ~= nil)
end

-- Run tests if executed directly
if arg and arg[0]:find("performance_instrumentation_test%.lua$") then
  os.exit(luaunit.LuaUnit.run())
end

return TestPerformanceInstrumentation
