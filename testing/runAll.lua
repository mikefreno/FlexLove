package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

-- Set global flag to prevent individual test files from running luaunit
_G.RUNNING_ALL_TESTS = true

local luaunit = require("testing.luaunit")

-- Run all tests in the __tests__ directory
local testFiles = {}

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

local result = luaunit.LuaUnit.run()
os.exit(success and result or 1)
