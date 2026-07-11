package.path = package.path
  .. ";./?.lua;./modules/?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

_G.RUNNING_ALL_TESTS = true

local verbose = false
local enableCoverage = true
local filteredArgs = {}
for i, v in ipairs(arg) do
  if v == "--no-coverage" then
    enableCoverage = false
  elseif v == "--verbose" or v == "-v" then
    verbose = true
  else
    table.insert(filteredArgs, v)
  end
end
arg = filteredArgs

-- Suppress print/write during loading and test execution
local old_print = _G.print
local old_io_write = io.write
local old_stdout = io.stdout
local old_stderr = io.stderr
local dev_null = { write = function() end, flush = function() end }
local function silence()
  _G.print = function() end
  io.write = function() end
  io.stdout = dev_null
  io.stderr = dev_null
end
local function unsilence()
  _G.print = old_print
  io.write = old_io_write
  io.stdout = old_stdout
  io.stderr = old_stderr
end

local function eprint(...)
  old_print(...)
end

local status, luacov = false, nil
if enableCoverage then
  status, luacov = pcall(require, "luacov")
  if status then
    eprint("========================================")
    eprint("Code coverage tracking enabled")
    eprint("Use --no-coverage flag to disable")
    eprint("========================================")
  else
    eprint("Warning: luacov not found, coverage tracking disabled")
  end
else
  eprint("========================================")
  eprint("Code coverage tracking disabled")
  eprint("========================================")
end

silence()

local luaunit = require("testing.luaunit")

local testFiles = {
  "testing/__tests__/absolute_positioning_test.lua",
  "testing/__tests__/animated_behavior_test.lua",
  "testing/__tests__/animation_chaining_test.lua",
  "testing/__tests__/animation_group_test.lua",
  "testing/__tests__/animation_test.lua",
  "testing/__tests__/apply_props_test.lua",
  "testing/__tests__/behavior_test.lua",
  "testing/__tests__/clickable_behavior_test.lua",
  "testing/__tests__/blur_test.lua",
  "testing/__tests__/calc_test.lua",
  "testing/__tests__/critical_failures_test.lua",
  "testing/__tests__/deferred_image_loading_test.lua",
  "testing/__tests__/element_test.lua",
  "testing/__tests__/element_mode_override_test.lua",
  "testing/__tests__/event_handler_test.lua",
  "testing/__tests__/font_cache_test.lua",
  "testing/__tests__/flex_grow_shrink_test.lua",
  "testing/__tests__/flexlove_test.lua",
  "testing/__tests__/grid_test.lua",
  "testing/__tests__/image_cache_test.lua",
  "testing/__tests__/image_renderer_test.lua",
  "testing/__tests__/image_scaler_test.lua",
  "testing/__tests__/init_queue_test.lua",
  "testing/__tests__/input_event_test.lua",
  "testing/__tests__/layout_engine_test.lua",
  "testing/__tests__/module_loader_test.lua",
  "testing/__tests__/number_validation_test.lua",
  "testing/__tests__/ninepatch_test.lua",
  "testing/__tests__/path_validator_test.lua",
  "testing/__tests__/performance_test.lua",
  "testing/__tests__/property_schema_test.lua",
  "testing/__tests__/renderer_test.lua",
  "testing/__tests__/release_variants_test.lua",
  "testing/__tests__/roundedrect_test.lua",
  "testing/__tests__/staged_initializers_test.lua",
  "testing/__tests__/scroll_manager_test.lua",
  "testing/__tests__/scrollable_behavior_test.lua",
  "testing/__tests__/subsystem_delegation_test.lua",
  "testing/__tests__/scrollbar_placement_test.lua",
  "testing/__tests__/select_test.lua",
  "testing/__tests__/setproperty_dispatch_test.lua",
  "testing/__tests__/test_children_prop.lua",
  "testing/__tests__/themed_imageable_behavior_test.lua",
  "testing/__tests__/test_display.lua",
  "testing/__tests__/texteditable_behavior_test.lua",
  "testing/__tests__/text_editor_test.lua",
  "testing/__tests__/text_sanitizer_test.lua",
  "testing/__tests__/theme_test.lua",
  "testing/__tests__/touch_test.lua",
  "testing/__tests__/transition_test.lua",
  "testing/__tests__/units_test.lua",
  "testing/__tests__/utils_test.lua",
}

-- Verbose mode: original full output
if verbose then
  local loadOk = true
  for _, testFile in ipairs(testFiles) do
    local ok, err = pcall(dofile, testFile)
    if not ok then
      print("ERROR running test " .. testFile .. ": " .. tostring(err))
      loadOk = false
    else
      print("Successfully loaded " .. testFile)
    end
  end
  local result = luaunit.LuaUnit.run()
  if enableCoverage and status then
    print("\n========================================")
    print("Generating coverage report...")
    print("========================================")
    luacov.save_stats()
    os.execute("luacov 2>/dev/null")
    local report_file = io.open("luacov.report.out", "r")
    if report_file then
      local report_content = report_file:read("*all")
      report_file:close()
      local summary = report_content:match("Summary\n=+\n(.-)$")
      if summary then
        print("\nSummary")
        print("==============================================================================")
        print(summary)
      end
    end
    print("Full coverage report: luacov.report.out")
    print("========================================")
  end
  os.exit(loadOk and result or 1)
end

-- Non-verbose mode
local red = function(s) return "\027[31m" .. s .. "\027[0m" end
local green = function(s) return "\027[32m" .. s .. "\027[0m" end
local yellow = function(s) return "\027[33m" .. s .. "\027[0m" end
local bold = function(s) return "\027[1m" .. s .. "\027[0m" end

local RED_X = red("\226\156\151")
local GREEN_CHECK = green("\226\156\147")
local YELLOW_DASH = yellow("-")

local function extractLineNum(stackTrace)
  if not stackTrace then return "?" end
  for line in stackTrace:gmatch("[^\n]+") do
    local _, _, ln = line:find(":(%d+):")
    if ln then return ln end
  end
  return "?"
end

-- Phase 1: Load all files, mapping test classes to their source file
local classToFile = {}
local fileToClasses = {}
local loadFailures = {}

for _, testFile in ipairs(testFiles) do
  local before = {}
  for k, _ in pairs(_G) do
    if type(k) == "string" and luaunit.LuaUnit.isTestName(k) then
      before[k] = true
    end
  end

  local ok, err = pcall(dofile, testFile)
  if not ok then
    table.insert(loadFailures, { file = testFile, err = err })
    goto continue
  end

  local classes = {}
  for k, _ in pairs(_G) do
    if type(k) == "string" and luaunit.LuaUnit.isTestName(k) and not before[k] then
      table.insert(classes, k)
      classToFile[k] = testFile
    end
  end
  fileToClasses[testFile] = classes

  ::continue::
end

-- Phase 2: Run all tests together
local runner = luaunit.LuaUnit.new()
runner:setOutputType("nil")
runner.verbosity = 0
runner:registerSuite()
runner:internalRunSuiteByNames(luaunit.LuaUnit.collectTests())
runner:unregisterSuite()

unsilence()

-- Phase 3: Group results by file
local fileResults = {}
for _, node in ipairs(runner.result.allTests) do
  local className = node.className
  local srcFile = classToFile[className] or "unknown"
  if not fileResults[srcFile] then
    fileResults[srcFile] = { failures = {}, errors = {}, total = 0, pass = 0 }
  end
  fileResults[srcFile].total = fileResults[srcFile].total + 1
  if node:isSuccess() then
    fileResults[srcFile].pass = fileResults[srcFile].pass + 1
  elseif node:isFailure() then
    table.insert(fileResults[srcFile].failures, node)
  elseif node:isError() then
    table.insert(fileResults[srcFile].errors, node)
  end
end

-- Report load failures
for _, lf in ipairs(loadFailures) do
  print("  " .. lf.file .. " ... " .. RED_X)
  print("      " .. red("Failed to load: " .. tostring(lf.err):gsub("\n", "\n      ")))
end

-- Phase 4: Print per-file summary
local allPassed = true
local totalTests = 0
local totalFail = 0
local totalErr = 0

for _, testFile in ipairs(testFiles) do
  local result = fileResults[testFile]
  if not result then
    -- File had no tests or failed to load (already reported above)
    if not loadFailures[testFile] then
      print("  " .. testFile .. " ... " .. YELLOW_DASH)
    end
    goto next_file
  end

  totalTests = totalTests + result.total
  local hasFails = #result.failures > 0 or #result.errors > 0

  if hasFails then
    allPassed = false
    print("  " .. testFile .. " ... " .. RED_X)
    totalFail = totalFail + #result.failures
    totalErr = totalErr + #result.errors
    for _, node in ipairs(result.failures) do
      local line = extractLineNum(node.stackTrace)
      local msg = node.msg:gsub("\n", "\n            ")
      print(string.format("      FAIL  %s (line %s)", node.testName, line))
      print("            " .. msg)
    end
    for _, node in ipairs(result.errors) do
      local line = extractLineNum(node.stackTrace)
      local msg = node.msg:gsub("\n", "\n            ")
      print(string.format("      ERROR %s (line %s)", node.testName, line))
      print("            " .. msg)
    end
  else
    print("  " .. testFile .. " ... " .. GREEN_CHECK)
  end

  ::next_file::
end

-- Summary
local duration = string.format("%.3f", os.clock() - runner.result.startTime)
print()
if allPassed then
  print(string.format("  %s Ran %d tests in %s seconds, 0 failures",
    green(bold("All tests passed")), totalTests, duration))
else
  local parts = {}
  if totalFail > 0 then table.insert(parts, string.format("%d failures", totalFail)) end
  if totalErr > 0 then table.insert(parts, string.format("%d errors", totalErr)) end
  print(string.format("  %s Ran %d tests in %s seconds - %s",
    red(bold("Some tests FAILED")), totalTests, duration, table.concat(parts, ", ")))
end

if enableCoverage and status then
  print("\n========================================")
  print("Generating coverage report...")
  print("========================================")
  luacov.save_stats()
  os.execute("luacov 2>/dev/null")
  local report_file = io.open("luacov.report.out", "r")
  if report_file then
    local report_content = report_file:read("*all")
    report_file:close()
    local summary = report_content:match("Summary\n=+\n(.-)$")
    if summary then
      print("\nSummary")
      print("==============================================================================")
      print(summary)
    end
  end
  print("Full coverage report: luacov.report.out")
  print("========================================")
end

os.exit(allPassed and 0 or 1)
