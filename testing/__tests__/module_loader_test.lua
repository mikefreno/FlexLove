local lu = require("testing.luaunit")
local loveStub = require("testing.loveStub")

-- Set up love stub globally
_G.love = loveStub

-- Load modules
local function req(name)
  return require("modules." .. name)
end

local ErrorHandler = req("ErrorHandler")
local ModuleLoader = req("ModuleLoader")

-- Module path for testing
local modulePath = ""

TestModuleLoader = {}

function TestModuleLoader:setUp()
  -- Initialize ErrorHandler
  ErrorHandler.init({})

  -- Initialize ModuleLoader
  ModuleLoader.init({ ErrorHandler = ErrorHandler })

  -- Clear registry before each test
  ModuleLoader._clearRegistry()
end

function TestModuleLoader:tearDown()
  -- Clear registry after each test
  ModuleLoader._clearRegistry()
end

function TestModuleLoader:test_safeRequire_loads_existing_module()
  -- Test loading an existing required module
  local utils = ModuleLoader.safeRequire(modulePath .. "modules.utils", false)

  lu.assertNotNil(utils)
  lu.assertIsTable(utils)
  lu.assertIsNil(utils._isStub)
end

function TestModuleLoader:test_safeRequire_returns_stub_for_missing_optional_module()
  -- Test loading a non-existent optional module
  local fakeModule = ModuleLoader.safeRequire(modulePath .. "modules.NonExistentModule", true)

  lu.assertNotNil(fakeModule)
  lu.assertIsTable(fakeModule)
  lu.assertTrue(fakeModule._isStub)
  lu.assertEquals(fakeModule._moduleName, modulePath .. "modules.NonExistentModule")
end

function TestModuleLoader:test_safeRequire_throws_error_for_missing_required_module()
  -- Test loading a non-existent required module should throw error
  lu.assertErrorMsgContains(
    "Required module",
    function()
      ModuleLoader.safeRequire(modulePath .. "modules.NonExistentModule", false)
    end
  )
end

function TestModuleLoader:test_stub_has_safe_init_method()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertIsFunction(stub.init)
  local result = stub.init()
  lu.assertEquals(result, stub)
end

function TestModuleLoader:test_stub_has_safe_new_method()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertIsFunction(stub.new)
  local result = stub.new()
  lu.assertEquals(result, stub)
end

function TestModuleLoader:test_stub_has_safe_draw_method()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertIsFunction(stub.draw)
  -- Should not throw error
  stub.draw()
end

function TestModuleLoader:test_stub_has_safe_update_method()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertIsFunction(stub.update)
  -- Should not throw error
  stub.update()
end

function TestModuleLoader:test_stub_has_safe_clear_method()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertIsFunction(stub.clear)
  -- Should not throw error
  stub.clear()
end

function TestModuleLoader:test_stub_has_safe_clearCache_method()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertIsFunction(stub.clearCache)
  local result = stub.clearCache()
  lu.assertIsTable(result)
end

function TestModuleLoader:test_stub_returns_nil_for_unknown_properties()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertIsNil(stub.unknownProperty)
  lu.assertIsNil(stub.anotherUnknownProperty)
end

function TestModuleLoader:test_stub_callable_returns_itself()
  local stub = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  local result = stub()
  lu.assertEquals(result, stub)
end

function TestModuleLoader:test_isModuleLoaded_returns_true_for_loaded_module()
  ModuleLoader.safeRequire(modulePath .. "modules.utils", false)

  lu.assertTrue(ModuleLoader.isModuleLoaded(modulePath .. "modules.utils"))
end

function TestModuleLoader:test_isModuleLoaded_returns_false_for_stub_module()
  ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  lu.assertFalse(ModuleLoader.isModuleLoaded(modulePath .. "modules.FakeModule"))
end

function TestModuleLoader:test_isModuleLoaded_returns_false_for_unloaded_module()
  lu.assertFalse(ModuleLoader.isModuleLoaded(modulePath .. "modules.NeverLoaded"))
end

function TestModuleLoader:test_getLoadedModules_returns_only_real_modules()
  ModuleLoader.safeRequire(modulePath .. "modules.utils", false)
  ModuleLoader.safeRequire(modulePath .. "modules.FakeModule1", true)
  ModuleLoader.safeRequire(modulePath .. "modules.FakeModule2", true)

  local loaded = ModuleLoader.getLoadedModules()

  lu.assertIsTable(loaded)
  -- Should only contain utils (real module)
  local hasUtils = false
  for _, path in ipairs(loaded) do
    if path == modulePath .. "modules.utils" then
      hasUtils = true
    end
  end
  lu.assertTrue(hasUtils)
end

function TestModuleLoader:test_getStubModules_returns_only_stubs()
  ModuleLoader.safeRequire(modulePath .. "modules.utils", false)
  ModuleLoader.safeRequire(modulePath .. "modules.FakeModule1", true)
  ModuleLoader.safeRequire(modulePath .. "modules.FakeModule2", true)

  local stubs = ModuleLoader.getStubModules()

  lu.assertIsTable(stubs)
  -- Should contain 2 stubs
  lu.assertEquals(#stubs, 2)
end

function TestModuleLoader:test_safeRequire_caches_modules()
  -- Load module twice
  local module1 = ModuleLoader.safeRequire(modulePath .. "modules.utils", false)
  local module2 = ModuleLoader.safeRequire(modulePath .. "modules.utils", false)

  -- Should return same instance
  lu.assertEquals(module1, module2)
end

function TestModuleLoader:test_safeRequire_caches_stubs()
  -- Load stub twice
  local stub1 = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)
  local stub2 = ModuleLoader.safeRequire(modulePath .. "modules.FakeModule", true)

  -- Should return same instance
  lu.assertEquals(stub1, stub2)
end

-- Run tests if executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(lu.LuaUnit.run())
end

return TestModuleLoader
