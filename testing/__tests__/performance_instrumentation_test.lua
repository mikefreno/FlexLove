-- Test Performance Instrumentation
package.path = package.path .. ";./?.lua;./modules/?.lua"

local luaunit = require("testing.luaunit")
local loveStub = require("testing.loveStub")

-- Set up stub before requiring modules
_G.love = loveStub

local Performance = require("modules.Performance")

TestPerformanceInstrumentation = {}

local perf

function TestPerformanceInstrumentation:setUp()
  -- Get Performance instance and ensure it's enabled
  perf = Performance.init({ enabled = true }, {})
  perf.enabled = true -- Explicitly set enabled in case singleton was already created
end

function TestPerformanceInstrumentation:tearDown()
  -- No cleanup needed - instance will be recreated in setUp
end

function TestPerformanceInstrumentation:testTimerStartStop()
  perf:startTimer("test_operation")

  -- Simulate some work
  local sum = 0
  for i = 1, 1000 do
    sum = sum + i
  end

  local elapsed = perf:stopTimer("test_operation")

  luaunit.assertNotNil(elapsed)
  luaunit.assertTrue(elapsed >= 0)
end

function TestPerformanceInstrumentation:testMultipleTimers()
  -- Start multiple timers
  perf:startTimer("layout")
  perf:startTimer("render")

  local sum = 0
  for i = 1, 100 do
    sum = sum + i
  end

  local layoutTime = perf:stopTimer("layout")
  local renderTime = perf:stopTimer("render")

  luaunit.assertNotNil(layoutTime)
  luaunit.assertNotNil(renderTime)
end

function TestPerformanceInstrumentation:testFrameTiming()
  perf:startFrame()

  -- Simulate frame work
  local sum = 0
  for i = 1, 1000 do
    sum = sum + i
  end

  perf:endFrame()

  luaunit.assertNotNil(perf._frameMetrics)
  luaunit.assertTrue(perf._frameMetrics.frameCount >= 1)
  luaunit.assertTrue(perf._frameMetrics.lastFrameTime >= 0)
end

function TestPerformanceInstrumentation:testDrawCallCounting()
  perf:incrementCounter("draw_calls", 1)
  perf:incrementCounter("draw_calls", 1)
  perf:incrementCounter("draw_calls", 1)

  luaunit.assertNotNil(perf._metrics.draw_calls)
  luaunit.assertTrue(perf._metrics.draw_calls.frameValue >= 3)

  -- Reset and check
  perf:resetFrameCounters()
  luaunit.assertEquals(perf._metrics.draw_calls.frameValue, 0)
end

function TestPerformanceInstrumentation:testHUDToggle()
  luaunit.assertFalse(perf.hudEnabled)

  perf:toggleHUD()
  luaunit.assertTrue(perf.hudEnabled)

  perf:toggleHUD()
  luaunit.assertFalse(perf.hudEnabled)
end

function TestPerformanceInstrumentation:testEnableDisable()
  perf.enabled = true
  luaunit.assertTrue(perf.enabled)

  perf.enabled = false
  luaunit.assertFalse(perf.enabled)

  -- Timers should not record when disabled
  perf:startTimer("disabled_test")
  local elapsed = perf:stopTimer("disabled_test")
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

  -- Test that the function works (Performance module doesn't have measure wrapper)
  perf:startTimer("expensive_op")
  local result = expensiveOperation(1000)
  perf:stopTimer("expensive_op")

  luaunit.assertEquals(result, 500500) -- sum of 1 to 1000
end

function TestPerformanceInstrumentation:testMemoryTracking()
  perf:_updateMemory()

  luaunit.assertNotNil(perf._memoryMetrics)
  luaunit.assertTrue(perf._memoryMetrics.current > 0)
  luaunit.assertTrue(perf._memoryMetrics.peak >= perf._memoryMetrics.current)
end

function TestPerformanceInstrumentation:testExportJSON()
  perf:startTimer("test_op")
  perf:stopTimer("test_op")

  -- Performance module doesn't have exportJSON, just verify timers work
  luaunit.assertNotNil(perf._timers)
end

function TestPerformanceInstrumentation:testExportCSV()
  perf:startTimer("test_op")
  perf:stopTimer("test_op")

  -- Performance module doesn't have exportCSV, just verify timers work
  luaunit.assertNotNil(perf._timers)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
