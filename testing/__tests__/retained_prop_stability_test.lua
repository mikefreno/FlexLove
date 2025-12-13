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
require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")
local Color = require("modules.Color")

TestRetainedPropStability = {}

function TestRetainedPropStability:setUp()
  -- Initialize in IMMEDIATE mode
  FlexLove.init({ immediateMode = true })
end

function TestRetainedPropStability:tearDown()
  if FlexLove.getMode() == "immediate" then
    FlexLove.endFrame()
  end
  FlexLove.init({ immediateMode = false })
end

-- Test that retained elements persist despite creating new Color instances
function TestRetainedPropStability:test_retainedElementIgnoresColorInstanceChanges()
  FlexLove.beginFrame()

  -- Frame 1: Create retained element with Color instance
  local backdrop1 = FlexLove.new({
    mode = "retained",
    width = "100%",
    height = "100%",
    backgroundColor = Color.new(1, 1, 1, 0.1), -- NEW Color instance
  })

  local id1 = backdrop1.id

  FlexLove.endFrame()

  -- Frame 2: Same props but NEW Color instance (common pattern in user code)
  FlexLove.beginFrame()

  local backdrop2 = FlexLove.new({
    mode = "retained",
    width = "100%",
    height = "100%",
    backgroundColor = Color.new(1, 1, 1, 0.1), -- NEW Color instance (different table)
  })

  -- Should return SAME element despite different Color instance
  luaunit.assertEquals(backdrop2.id, id1, "ID should be stable across frames")
  luaunit.assertEquals(backdrop2, backdrop1, "Should return same element instance")

  FlexLove.endFrame()
end

-- Test that retained elements with complex props persist
function TestRetainedPropStability:test_retainedElementWithComplexProps()
  local function createWindow()
    return FlexLove.new({
      mode = "retained",
      z = 100,
      x = "5%",
      y = "5%",
      width = "90%",
      height = "90%",
      themeComponent = "framev3",
      positioning = "flex",
      flexDirection = "vertical",
      justifySelf = "center",
      justifyContent = "flex-start",
      alignItems = "center",
      scaleCorners = 3,
      padding = { horizontal = "5%", vertical = "3%" },
      gap = 10,
    })
  end

  FlexLove.beginFrame()

  local window1 = createWindow()
  local id1 = window1.id

  FlexLove.endFrame()

  -- Frame 2: Same function, same props
  FlexLove.beginFrame()

  local window2 = createWindow()

  -- Should return same element
  luaunit.assertEquals(window2.id, id1)
  --luaunit.assertEquals(window2, window1)

  FlexLove.endFrame()
end

-- Test that retained elements with backdrop blur persist
function TestRetainedPropStability:test_retainedElementWithBackdropBlur()
  local function createBackdrop()
    return FlexLove.new({
      mode = "retained",
      width = "100%",
      height = "100%",
      backdropBlur = { radius = 10 }, -- Table prop
      backgroundColor = Color.new(1, 1, 1, 0.1),
    })
  end

  FlexLove.beginFrame()

  local backdrop1 = createBackdrop()
  local id1 = backdrop1.id

  FlexLove.endFrame()

  -- Frame 2
  FlexLove.beginFrame()

  local backdrop2 = createBackdrop()

  -- Should return same element
  luaunit.assertEquals(backdrop2.id, id1)
  luaunit.assertEquals(backdrop2, backdrop1)

  FlexLove.endFrame()
end

-- Test that multiple retained elements persist independently
function TestRetainedPropStability:test_multipleRetainedElementsWithVaryingProps()
  local function createUI()
    local backdrop = FlexLove.new({
      mode = "retained",
      z = 50,
      width = "100%",
      height = "100%",
      backdropBlur = { radius = 10 },
      backgroundColor = Color.new(1, 1, 1, 0.1),
    })

    local window = FlexLove.new({
      mode = "retained",
      z = 100,
      x = "5%",
      y = "5%",
      width = "90%",
      height = "90%",
      themeComponent = "framev3",
      padding = { horizontal = "5%", vertical = "3%" },
    })

    return backdrop, window
  end

  FlexLove.beginFrame()

  local backdrop1, window1 = createUI()
  local backdropId = backdrop1.id
  local windowId = window1.id

  FlexLove.endFrame()

  -- Frame 2: New Color instances, new table instances for props
  FlexLove.beginFrame()

  local backdrop2, window2 = createUI()

  -- Both should return existing elements
  luaunit.assertEquals(backdrop2.id, backdropId)
  luaunit.assertEquals(window2.id, windowId)

  FlexLove.endFrame()
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
