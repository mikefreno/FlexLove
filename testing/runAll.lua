package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

-- Check for --no-coverage flag and filter it out
local enableCoverage = true
local filteredArgs = {}
for i, v in ipairs(arg) do
  if v == "--no-coverage" then
    enableCoverage = false
  else
    table.insert(filteredArgs, v)
  end
end
arg = filteredArgs

-- Enable code coverage tracking BEFORE loading any modules (if not disabled)
local status, luacov = false, nil
if enableCoverage then
  status, luacov = pcall(require, "luacov")
  if status then
    print("========================================")
    print("Code coverage tracking enabled")
    print("Use --no-coverage flag to disable")
    print("========================================")
  else
    print("Warning: luacov not found, coverage tracking disabled")
  end
else
  print("========================================")
  print("Code coverage tracking disabled")
  print("========================================")
end

-- Set global flag to prevent individual test files from running luaunit
_G.RUNNING_ALL_TESTS = true

local luaunit = require("testing.luaunit")

local testFiles = {
  "testing/__tests__/animation_test.lua",
  "testing/__tests__/blur_test.lua",
  "testing/__tests__/element_test.lua",
  "testing/__tests__/event_handler_test.lua",
  "testing/__tests__/grid_test.lua",
  "testing/__tests__/image_cache_test.lua",
  "testing/__tests__/image_renderer_test.lua",
  "testing/__tests__/image_scaler_test.lua",
  "testing/__tests__/input_event_test.lua",
  "testing/__tests__/layout_engine_test.lua",
  "testing/__tests__/module_loader_test.lua",
  "testing/__tests__/ninepatch_test.lua",
  "testing/__tests__/performance_test.lua",
  "testing/__tests__/renderer_test.lua",
  "testing/__tests__/roundedrect_test.lua",
  "testing/__tests__/scroll_manager_test.lua",
  "testing/__tests__/text_editor_test.lua",
  "testing/__tests__/theme_test.lua",
  "testing/__tests__/units_test.lua",
  "testing/__tests__/utils_test.lua",
  "testing/__tests__/calc_test.lua",
  -- Feature/Integration tests
  "testing/__tests__/critical_failures_test.lua",
  "testing/__tests__/flexlove_test.lua",
  "testing/__tests__/touch_events_test.lua",
}

local success = true
print("========================================")
print("Running ALL tests")
print("========================================")
for i, testFile in ipairs(testFiles) do
  print("========================================")
  print("Running test file " .. i .. "/" .. #testFiles .. ": " .. testFile)
  print("========================================")
  local status, err = pcall(dofile, testFile)
  if not status then
    print("ERROR running test " .. testFile .. ": " .. tostring(err))
    success = false
  else
    print("Successfully loaded " .. testFile)
  end
end

print("========================================")
print("All tests completed")
print("========================================")

local result = luaunit.LuaUnit.run()

-- Generate and display coverage report
if status then
  print("\n========================================")
  print("Generating coverage report...")
  print("========================================")

  -- Save coverage stats
  luacov.save_stats()

  -- Run luacov command to generate report (silent)
  os.execute("luacov 2>/dev/null")

  -- Read and display the summary section from the report
  local report_file = io.open("luacov.report.out", "r")
  if report_file then
    local content = report_file:read("*all")
    report_file:close()

    -- Extract just the Summary section
    local summary = content:match("Summary\n=+\n(.-)$")
    if summary then
      print("\nSummary")
      print("==============================================================================")
      print(summary)
    end
  end

  print("Full coverage report: luacov.report.out")
  print("========================================")
end

os.exit(success and result or 1)
