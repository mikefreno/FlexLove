-- Release variant tests: simulate each release profile by blocking excluded modules,
-- then verify FlexLove initializes and operates correctly without crashing.
--
-- Profile blacklists mirror create-profile-packages.sh:
--   minimal: Animation, NinePatch, ImageRenderer, ImageScaler, ImageCache,
--            Theme, Blur, GestureRecognizer, Performance, MemoryScanner,
--            KeyboardNavigation, FocusIndicator
--   slim:    Theme, Blur, GestureRecognizer, Performance, MemoryScanner
--   default: Performance, MemoryScanner
--   full:    (nothing excluded)

if not _G.RUNNING_ALL_TESTS then
  package.path = package.path .. ";./?.lua;./modules/?.lua"
  local originalSearchers = package.searchers or package.loaders
  table.insert(originalSearchers, 2, function(modname)
    if modname:match("^FlexLove%.modules%.") then
      local moduleName = modname:gsub("^FlexLove%.modules%.", "")
      return function()
        return require("modules." .. moduleName)
      end
    end
  end)
end

local luaunit = require("testing.luaunit")
require("testing.loveStub")

-- ---------------------------------------------------------------------------
-- Profile definitions
-- ---------------------------------------------------------------------------

local PROFILES = {
  minimal = {
    "Animation",
    "NinePatch",
    "ImageRenderer",
    "ImageScaler",
    "ImageCache",
    "Theme",
    "Blur",
    "GestureRecognizer",
    "Performance",
    "MemoryScanner",
    "KeyboardNavigation",
    "FocusIndicator",
  },
  slim = {
    "Theme",
    "Blur",
    "GestureRecognizer",
    "Performance",
    "MemoryScanner",
  },
  default = {
    "Performance",
    "MemoryScanner",
  },
  full = {},
}

-- Full module path prefix used by FlexLove.safeReq
local MODULE_PREFIX = "FlexLove.modules."

local REQUESTED_PROFILE = os.getenv("FLEXLOVE_RELEASE_PROFILE")

-- ---------------------------------------------------------------------------
-- Package state helpers
-- ---------------------------------------------------------------------------

--- Collect all FlexLove-related keys currently in package.loaded / package.preload.
local function collectFlexLoveKeys()
  local keys = {}
  for k in pairs(package.loaded) do
    if k == "FlexLove" or k:match("^FlexLove%.") then
      keys[k] = true
    end
  end
  for k in pairs(package.preload) do
    if k == "FlexLove" or k:match("^FlexLove%.") then
      keys[k] = true
    end
  end
  return keys
end

--- Save the current state of all FlexLove-related package entries.
local function savePackageState()
  local state = {
    loaded = {},
    preload = {},
  }
  for k in pairs(package.loaded) do
    if k == "FlexLove" or k:match("^FlexLove%.") or k:match("^modules%.") then
      state.loaded[k] = package.loaded[k]
    end
  end
  for k in pairs(package.preload) do
    if k == "FlexLove" or k:match("^FlexLove%.") then
      state.preload[k] = package.preload[k]
    end
  end
  return state
end

--- Restore package state from a previously saved snapshot.
local function restorePackageState(state)
  -- Remove any keys that were not in the original state
  for k in pairs(package.loaded) do
    if k == "FlexLove" or k:match("^FlexLove%.") or k:match("^modules%.") then
      if state.loaded[k] == nil then
        package.loaded[k] = nil
      end
    end
  end
  for k in pairs(package.preload) do
    if k == "FlexLove" or k:match("^FlexLove%.") then
      if state.preload[k] == nil then
        package.preload[k] = nil
      end
    end
  end
  -- Restore original values
  for k, v in pairs(state.loaded) do
    package.loaded[k] = v
  end
  for k, v in pairs(state.preload) do
    package.preload[k] = v
  end
end

--- Block a module so that safeReq will get a stub for it.
--- We install a failing loader in package.preload and clear any cached loaded value.
local function blockModule(name)
  local fullPath = MODULE_PREFIX .. name
  package.preload[fullPath] = function()
    error(string.format("Module '%s' is excluded in this release profile", fullPath))
  end
  package.loaded[fullPath] = nil
  -- Also clear the bare modules.X path so the custom searcher can't bypass the block
  local barePath = "modules." .. name
  package.loaded[barePath] = nil
end

--- Load FlexLove fresh under the given profile's module exclusions.
--- Returns the FlexLove module.
local function loadProfileFlexLove(profileName)
  local excluded = PROFILES[profileName]

  -- Block excluded modules
  for _, name in ipairs(excluded) do
    blockModule(name)
  end

  -- Clear FlexLove from the loaded cache so it re-initialises
  package.loaded["FlexLove"] = nil

  -- Clear ModuleLoader registry so it doesn't serve cached real modules
  local ModuleLoader = require("modules.ModuleLoader")
  ModuleLoader._clearRegistry()

  -- Re-require FlexLove; it will call safeReq for optional modules and get stubs
  local FlexLove = require("FlexLove")
  return FlexLove
end

-- ---------------------------------------------------------------------------
-- Helper: create a handful of nested elements in retained mode
-- ---------------------------------------------------------------------------
local function createRetainedElements(FlexLove)
  local parent = FlexLove.new({
    width = 400,
    height = 300,
    flexDirection = "column",
    padding = 10,
  })
  for i = 1, 5 do
    FlexLove.new({
      width = 100,
      height = 40,
      margin = 4,
      parent = parent,
    })
  end
  return parent
end

-- ---------------------------------------------------------------------------
-- Helper: run one immediate-mode frame
-- ---------------------------------------------------------------------------
local function runImmediateFrame(FlexLove)
  FlexLove.beginFrame()
  for i = 1, 5 do
    FlexLove.new({
      width = 80,
      height = 30,
    })
  end
  FlexLove.endFrame()
end

-- ---------------------------------------------------------------------------
-- Child-process tests – run a single profile in an isolated Lua VM
-- ---------------------------------------------------------------------------
local function makeProfileTestClass(profileName)
  local cls = {}
  local savedState = nil

  function cls:setUp()
    savedState = savePackageState()
    local FlexLove = loadProfileFlexLove(profileName)
    -- Store on self for use in test methods
    self.FlexLove = FlexLove
    self.FlexLove.destroy()
    self.FlexLove.init()
  end

  function cls:tearDown()
    if self.FlexLove then
      self.FlexLove.destroy()
    end
    -- Restore package state so other test files are unaffected
    if savedState then
      restorePackageState(savedState)
      savedState = nil
    end
    -- Clear ModuleLoader registry
    local ok, ModuleLoader = pcall(require, "modules.ModuleLoader")
    if ok then
      ModuleLoader._clearRegistry()
    end
    -- Reload FlexLove for subsequent tests that expect the full build
    package.loaded["FlexLove"] = nil
  end

  -- Test: FlexLove module loads and exposes version info
  function cls:testModuleLoads()
    luaunit.assertNotNil(self.FlexLove)
    luaunit.assertNotNil(self.FlexLove._VERSION)
  end

  -- Test: init() with no config does not crash
  function cls:testInitNoConfig()
    self.FlexLove.destroy()
    self.FlexLove.init()
    luaunit.assertTrue(true)
  end

  -- Test: init() with baseScale does not crash
  function cls:testInitWithBaseScale()
    self.FlexLove.destroy()
    self.FlexLove.init({
      baseScale = { width = 1920, height = 1080 },
    })
    luaunit.assertNotNil(self.FlexLove.baseScale)
    luaunit.assertEquals(self.FlexLove.baseScale.width, 1920)
    luaunit.assertEquals(self.FlexLove.baseScale.height, 1080)
  end

  -- Test: retained mode element creation does not crash
  function cls:testRetainedModeElementCreation()
    self.FlexLove.setMode("retained")
    local parent = createRetainedElements(self.FlexLove)
    luaunit.assertNotNil(parent)
    -- Parent should have 5 children
    luaunit.assertEquals(#parent.children, 5)
  end

  -- Test: immediate mode frame does not crash
  function cls:testImmediateModeElementCreation()
    self.FlexLove.setMode("immediate")
    runImmediateFrame(self.FlexLove)
    luaunit.assertTrue(true)
  end

  -- Test: multiple immediate mode frames do not crash
  function cls:testMultipleFrames()
    self.FlexLove.setMode("immediate")
    for _ = 1, 10 do
      runImmediateFrame(self.FlexLove)
    end
    luaunit.assertTrue(true)
  end

  -- Test: draw() does not crash
  function cls:testDrawCycle()
    self.FlexLove.setMode("immediate")
    runImmediateFrame(self.FlexLove)
    self.FlexLove.draw()
    luaunit.assertTrue(true)
  end

  -- Test: update() does not crash
  function cls:testUpdateCycle()
    self.FlexLove.setMode("immediate")
    runImmediateFrame(self.FlexLove)
    self.FlexLove.update(1 / 60)
    luaunit.assertTrue(true)
  end

  -- Test: resize() does not crash
  function cls:testResizeCycle()
    self.FlexLove.setMode("retained")
    createRetainedElements(self.FlexLove)
    self.FlexLove.resize(1280, 720)
    luaunit.assertTrue(true)
  end

  -- Test: keypressed() with common keys does not crash
  function cls:testKeypressed()
    self.FlexLove.setMode("retained")
    createRetainedElements(self.FlexLove)
    local keys = { "tab", "return", "escape", "up", "down", "left", "right", "space" }
    for _, key in ipairs(keys) do
      self.FlexLove.keypressed(key)
    end
    luaunit.assertTrue(true)
  end

  -- Test: enableKeyboardNavigation() does not crash when module may be absent
  function cls:testEnableKeyboardNavigation()
    self.FlexLove.enableKeyboardNavigation({})
    luaunit.assertTrue(true)
  end

  -- Test: stress – create 100 elements in immediate mode
  function cls:testStressElements()
    self.FlexLove.setMode("immediate")
    self.FlexLove.beginFrame()
    for i = 1, 100 do
      self.FlexLove.new({ width = 10, height = 10 })
    end
    self.FlexLove.endFrame()
    luaunit.assertTrue(true)
  end

  -- Test: ModuleLoader.isModuleLoaded returns false for excluded modules
  function cls:testExcludedModulesAreStubs()
    local ModuleLoader = require("modules.ModuleLoader")
    local excluded = PROFILES[profileName]
    for _, name in ipairs(excluded) do
      local fullPath = MODULE_PREFIX .. name
      local isLoaded = ModuleLoader.isModuleLoaded(fullPath)
      luaunit.assertFalse(
        isLoaded,
        string.format("[%s] Expected '%s' to be a stub, but isModuleLoaded returned true", profileName, fullPath)
      )
    end
  end

  -- Test: ModuleLoader.isModuleLoaded returns true for optional modules present in this profile
  function cls:testIncludedOptionalModulesAreLoaded()
    local ModuleLoader = require("modules.ModuleLoader")
    local excluded = PROFILES[profileName]
    -- Build a set of excluded names for quick lookup
    local excludedSet = {}
    for _, name in ipairs(excluded) do
      excludedSet[name] = true
    end
    -- All optional modules that safeReq registers
    local optionalModules = {
      "Animation",
      "NinePatch",
      "ImageRenderer",
      "ImageScaler",
      "ImageCache",
      "Theme",
      "Blur",
      "GestureRecognizer",
      "Performance",
      "KeyboardNavigation",
      "FocusIndicator",
    }
    for _, name in ipairs(optionalModules) do
      if not excludedSet[name] then
        local path = MODULE_PREFIX .. name
        luaunit.assertTrue(
          ModuleLoader.isModuleLoaded(path),
          string.format("[%s] Expected included optional module '%s' to be loaded, but got stub", profileName, path)
        )
      end
    end
  end

  return cls
end

-- ---------------------------------------------------------------------------
-- Profile-specific extra tests
-- ---------------------------------------------------------------------------

local function registerChildProfileTests(profileName)
  local className = "TestReleaseProfile" .. profileName:gsub("^%l", string.upper)
  _G[className] = makeProfileTestClass(profileName)
  local cls = _G[className]

  if profileName == "minimal" then
    function cls:testKeyboardNavAbsent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertFalse(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "KeyboardNavigation"))
      luaunit.assertFalse(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "FocusIndicator"))
    end

    function cls:testAnimationAbsent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertFalse(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "Animation"))
    end

    function cls:testThemeAbsent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertFalse(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "Theme"))
    end
  elseif profileName == "slim" then
    function cls:testThemeAbsent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertFalse(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "Theme"))
    end

    function cls:testAnimationPresent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertTrue(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "Animation"))
    end

    function cls:testKeyboardNavPresent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertTrue(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "KeyboardNavigation"))
    end
  elseif profileName == "default" then
    function cls:testPerformanceAbsent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertFalse(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "Performance"))
      luaunit.assertFalse(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "MemoryScanner"))
    end

    function cls:testAnimationAndThemePresent()
      local ModuleLoader = require("modules.ModuleLoader")
      luaunit.assertTrue(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "Animation"))
      luaunit.assertTrue(ModuleLoader.isModuleLoaded(MODULE_PREFIX .. "Theme"))
    end
  elseif profileName == "full" then
    function cls:testAllOptionalModulesPresent()
      local ModuleLoader = require("modules.ModuleLoader")
      local optionalModules = {
        "Animation",
        "NinePatch",
        "ImageRenderer",
        "ImageScaler",
        "ImageCache",
        "Theme",
        "Blur",
        "GestureRecognizer",
        "Performance",
        "KeyboardNavigation",
        "FocusIndicator",
      }
      for _, name in ipairs(optionalModules) do
        local path = MODULE_PREFIX .. name
        luaunit.assertTrue(
          ModuleLoader.isModuleLoaded(path),
          string.format("[full] Expected '%s' to be loaded, but got stub", path)
        )
      end
    end
  end
end

if REQUESTED_PROFILE then
  registerChildProfileTests(REQUESTED_PROFILE)
else
  TestReleaseVariantsSubprocess = {}

  local function runProfileSubprocess(profileName)
    local quotedFile = '"testing/__tests__/release_variants_test.lua"'
    local className = "TestReleaseProfile" .. profileName:gsub("^%l", string.upper)
    local command = string.format("FLEXLOVE_RELEASE_PROFILE=%s lua %s %s", profileName, quotedFile, className)
    local ok = os.execute(command)

    if type(ok) == "number" then
      return ok == 0
    end

    return ok == true
  end

  function TestReleaseVariantsSubprocess:testMinimalProfile()
    luaunit.assertTrue(runProfileSubprocess("minimal"))
  end

  function TestReleaseVariantsSubprocess:testSlimProfile()
    luaunit.assertTrue(runProfileSubprocess("slim"))
  end

  function TestReleaseVariantsSubprocess:testDefaultProfile()
    luaunit.assertTrue(runProfileSubprocess("default"))
  end

  function TestReleaseVariantsSubprocess:testFullProfile()
    luaunit.assertTrue(runProfileSubprocess("full"))
  end
end

-- ---------------------------------------------------------------------------
-- Runner (standalone mode)
-- ---------------------------------------------------------------------------

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
