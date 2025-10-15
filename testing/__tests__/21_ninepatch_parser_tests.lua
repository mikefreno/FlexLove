-- Test Suite for NinePatch Parser
-- Tests ImageDataReader and NinePatchParser modules

package.path = package.path .. ";?.lua"
local lu = require("testing.luaunit")

-- Mock love.graphics for testing without LÖVE runtime
local love = love
if not love then
  love = {}
  love.graphics = {}
  love.timer = {}
  love.window = {}

  -- Mock functions
  function love.timer.getTime()
    return 0
  end

  function love.window.getMode()
    return 800, 600
  end
end

-- Load FlexLove
local FlexLove = require("FlexLove")

-- ====================
-- Test ImageDataReader
-- ====================

TestImageDataReader = {}

function TestImageDataReader:test_isBlackPixel_identifiesBlackCorrectly()
  -- Black pixel with full alpha should return true
  lu.assertTrue(FlexLove.ImageDataReader.isBlackPixel(0, 0, 0, 255))
end

function TestImageDataReader:test_isBlackPixel_rejectsNonBlack()
  -- Non-black colors should return false
  lu.assertFalse(FlexLove.ImageDataReader.isBlackPixel(255, 0, 0, 255)) -- Red
  lu.assertFalse(FlexLove.ImageDataReader.isBlackPixel(0, 255, 0, 255)) -- Green
  lu.assertFalse(FlexLove.ImageDataReader.isBlackPixel(0, 0, 255, 255)) -- Blue
  lu.assertFalse(FlexLove.ImageDataReader.isBlackPixel(128, 128, 128, 255)) -- Gray
end

function TestImageDataReader:test_isBlackPixel_rejectsTransparent()
  -- Black with no alpha should return false
  lu.assertFalse(FlexLove.ImageDataReader.isBlackPixel(0, 0, 0, 0))
  lu.assertFalse(FlexLove.ImageDataReader.isBlackPixel(0, 0, 0, 128))
end

-- ====================
-- Test NinePatchParser Helper Functions
-- ====================

TestNinePatchParserHelpers = {}

-- Note: findBlackPixelRuns is a local function, so we test it indirectly through parse()
-- We'll create mock image data to test the full parsing pipeline

-- ====================
-- Integration Tests
-- ====================

TestNinePatchIntegration = {}

function TestNinePatchIntegration:test_themeLoadsWithNinePatch()
  -- This test verifies that the space theme can load with 9-patch button
  local success, err = pcall(function()
    FlexLove.Theme.load("space")
  end)

  if not success then
    print("Theme load error: " .. tostring(err))
  end

  lu.assertTrue(success, "Space theme should load successfully")
end

function TestNinePatchIntegration:test_ninePatchButtonHasInsets()
  -- Load theme and verify button component has insets
  FlexLove.Theme.load("space")
  local theme = FlexLove.Theme.getActive()

  lu.assertNotNil(theme, "Theme should be active")
  lu.assertNotNil(theme.components, "Theme should have components")

  if theme.components and theme.components.button then
    -- Check if insets were auto-parsed or manually defined
    local hasInsets = theme.components.button.insets ~= nil or theme.components.button.regions ~= nil
    lu.assertTrue(hasInsets, "Button should have insets or regions defined")
  else
    lu.fail("Button component not found in theme")
  end
end

-- Run tests
lu.LuaUnit.run()
