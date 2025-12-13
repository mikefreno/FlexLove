--[[
  Test: Retained Elements in Immediate Mode (No Duplication)

  This test verifies that retained-mode elements don't get recreated
  when the overall application is in immediate mode.
]]

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")

local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")
local Color = require("modules.Color")

TestRetainedInImmediateMode = {}

function TestRetainedInImmediateMode:setUp()
  -- Initialize in IMMEDIATE mode
  FlexLove.init({ immediateMode = true })
end

function TestRetainedInImmediateMode:tearDown()
  if FlexLove.getMode() == "immediate" then
    FlexLove.endFrame()
  end
  FlexLove.init({ immediateMode = false })
end

-- Test that top-level retained elements persist across frames
function TestRetainedInImmediateMode:test_topLevelRetainedElementPersists()
  -- Helper function that creates elements (simulates user code called each frame)
  local function createUI()
    local backdrop = FlexLove.new({
      mode = "retained",
      width = "100%",
      height = "100%",
      backgroundColor = Color.new(0.1, 0.2, 0.3, 0.5),
    })
    return backdrop
  end

  FlexLove.beginFrame()

  -- Frame 1: Create a retained element (no explicit ID)
  local backdrop = createUI()

  local backdropId = backdrop.id
  luaunit.assertNotNil(backdropId, "Backdrop should have auto-generated ID")
  luaunit.assertEquals(backdrop._elementMode, "retained")

  FlexLove.endFrame()

  -- Frame 2: Call createUI() again (same function, same line numbers)
  FlexLove.beginFrame()

  local backdrop2 = createUI()

  -- Should return the SAME element, not create a new one
  luaunit.assertEquals(backdrop2.id, backdropId, "Should return existing element with same ID")
  luaunit.assertEquals(backdrop2, backdrop, "Should return exact same element instance")

  FlexLove.endFrame()
end

-- Test that retained elements with explicit IDs can be recreated
function TestRetainedInImmediateMode:test_explicitIdAllowsNewElements()
  FlexLove.beginFrame()

  -- Create element with explicit ID
  local element1 = FlexLove.new({
    id = "my_custom_id",
    mode = "retained",
    width = 100,
    height = 100,
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  FlexLove.endFrame()

  FlexLove.beginFrame()

  -- Create another element with SAME explicit ID but different properties
  -- This should create a NEW element (user controls uniqueness)
  local element2 = FlexLove.new({
    id = "my_custom_id",
    mode = "retained",
    width = 200, -- Different properties
    height = 200,
    backgroundColor = Color.new(0, 1, 0, 1),
  })

  -- With explicit IDs, we allow duplicates (user responsibility)
  luaunit.assertEquals(element2.id, "my_custom_id")
  -- Properties should match NEW element, not old
  luaunit.assertEquals(element2.width, 200)

  FlexLove.endFrame()
end

-- Test that multiple retained elements persist independently
function TestRetainedInImmediateMode:test_multipleRetainedElementsPersist()
  local function createUI()
    local backdrop = FlexLove.new({
      mode = "retained",
      width = "100%",
      height = "100%",
    })

    local window = FlexLove.new({
      mode = "retained",
      width = "90%",
      height = "90%",
    })

    return backdrop, window
  end

  FlexLove.beginFrame()

  local backdrop, window = createUI()

  local backdropId = backdrop.id
  local windowId = window.id

  luaunit.assertNotEquals(backdropId, windowId, "Different elements should have different IDs")

  FlexLove.endFrame()

  -- Frame 2
  FlexLove.beginFrame()

  local backdrop2, window2 = createUI()

  -- Both should return existing elements
  luaunit.assertEquals(backdrop2.id, backdropId)
  luaunit.assertEquals(window2.id, windowId)
  luaunit.assertEquals(backdrop2, backdrop)
  luaunit.assertEquals(window2, window)

  FlexLove.endFrame()
end

-- Test that retained children of retained parents persist
function TestRetainedInImmediateMode:test_retainedChildOfRetainedParentPersists()
  local function createUI()
    local parent = FlexLove.new({
      mode = "retained",
      width = 400,
      height = 400,
    })

    local child = FlexLove.new({
      mode = "retained",
      parent = parent,
      width = 100,
      height = 100,
    })

    return parent, child
  end

  FlexLove.beginFrame()

  local parent, child = createUI()

  local parentId = parent.id
  local childId = child.id

  FlexLove.endFrame()

  -- Frame 2
  FlexLove.beginFrame()

  local parent2, child2 = createUI()

  -- Parent should be the same
  luaunit.assertEquals(parent2.id, parentId)
  luaunit.assertEquals(parent2, parent)

  -- Child should also be the same instance
  luaunit.assertEquals(child2.id, childId, "Child ID should match")
  luaunit.assertEquals(child2, child, "Child should be same instance")

  -- Child should still exist in parent's children
  luaunit.assertEquals(#parent2.children, 1, "Parent should have exactly 1 child")
  luaunit.assertEquals(parent2.children[1].id, childId)

  FlexLove.endFrame()
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
