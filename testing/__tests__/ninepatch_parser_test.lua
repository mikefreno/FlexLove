local luaunit = require("testing.luaunit")
require("testing.loveStub")

-- Note: NinePatchParser and ImageDataReader modules were folded into the NinePatch module
-- This test file is kept for backwards compatibility but effectively disabled
-- The parsing logic is now covered by ninepatch_test.lua which tests the public API

TestNinePatchParser = {}

-- Single stub test to indicate the module was refactored
function TestNinePatchParser:testModuleWasRefactored()
  luaunit.assertTrue(true, "NinePatchParser was folded into NinePatch module - see ninepatch_test.lua")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
