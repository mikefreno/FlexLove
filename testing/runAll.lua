package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")

-- Run all tests in the __tests__ directory
local testFiles = {
  "testing/__tests__/01_absolute_positioning_basic_tests.lua",
  "testing/__tests__/02_absolute_positioning_child_layout_tests.lua",
  "testing/__tests__/03_flex_direction_horizontal_tests.lua",
  "testing/__tests__/04_flex_direction_vertical_tests.lua",
  "testing/__tests__/05_justify_content_tests.lua",
  "testing/__tests__/06_align_items_tests.lua",
  "testing/__tests__/07_flex_wrap_tests.lua",
  "testing/__tests__/08_comprehensive_flex_tests.lua",
  "testing/__tests__/09_layout_validation_tests.lua",
  "testing/__tests__/10_performance_tests.lua",
  "testing/__tests__/11_auxiliary_functions_tests.lua",
  "testing/__tests__/12_units_system_tests.lua",
  "testing/__tests__/13_relative_positioning_tests.lua",
  "testing/__tests__/14_text_scaling_basic_tests.lua",
  "testing/__tests__/15_grid_layout_tests.lua",
  "testing/__tests__/16_event_system_tests.lua",
}

-- testingun all tests, but don't exit on error
local success = true
print("========================================")
print("Running ALL tests")
print("========================================")
for _, testFile in ipairs(testFiles) do
  print("========================================")
  print("Running test file: " .. testFile)
  print("========================================")
  local status, err = pcall(dofile, testFile)
  if not status then
    print("Error running test " .. testFile .. ": " .. tostring(err))
    success = false
  end
end

print("========================================")
print("All tests completed")
print("========================================")

-- Run the tests and exit with appropriate code
local result = luaunit.LuaUnit.run()
os.exit(success and result or 1)
