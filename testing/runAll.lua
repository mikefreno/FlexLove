package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

-- Enable code coverage tracking BEFORE loading any modules
local coverage_enabled = os.getenv("COVERAGE") == "1"
if coverage_enabled then
  local status, luacov = pcall(require, "luacov")
  if status then
    print("========================================")
    print("Code coverage tracking enabled")
    print("========================================")
  else
    print("Warning: luacov not found, coverage tracking disabled")
  end
end

-- Set global flag to prevent individual test files from running luaunit
_G.RUNNING_ALL_TESTS = true

local luaunit = require("testing.luaunit")

-- Run all tests in the __tests__ directory
local testFiles = {
  "testing/__tests__/utils_test.lua",
  "testing/__tests__/sanitization_test.lua",
  "testing/__tests__/path_validation_test.lua",
  "testing/__tests__/color_validation_test.lua",
  "testing/__tests__/texteditor_sanitization_test.lua",
  "testing/__tests__/theme_validation_test.lua",
  "testing/__tests__/theme_core_test.lua",
  "testing/__tests__/units_test.lua",
  "testing/__tests__/layout_engine_test.lua",
  "testing/__tests__/element_test.lua",
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
os.exit(success and result or 1)
