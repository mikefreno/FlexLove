package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")

-- Run all tests in the __tests__ directory
local testFiles = {
  "testing/__tests__/01_absolute_positioning.lua",
  "testing/__tests__/02_flex_direction.lua",
  "testing/__tests__/03_vertical_flex_direction.lua",
  "testing/__tests__/04_justify_content.lua",
  "testing/__tests__/05_align_items.lua",
  "testing/__tests__/06_flex_wrap.lua",
  "testing/__tests__/07_layout_validation.lua",
  "testing/__tests__/08_performance.lua",
  "testing/__tests__/09_element_properties.lua",
  "testing/__tests__/10_animation_and_transform.lua",
  "testing/__tests__/11_auxiliary_functions.lua",
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
