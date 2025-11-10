-- Test: Stable ID Generation in Immediate Mode
package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")
require("testing.loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local Gui = FlexLove.Gui

TestStableIDGeneration = {}

function TestStableIDGeneration:setUp()
  -- Reset GUI state
  if Gui.destroy then
    Gui.destroy()
  end

  -- Initialize with immediate mode enabled
  Gui.init({
    baseScale = { width = 1920, height = 1080 },
    immediateMode = true,
  })
end

function TestStableIDGeneration:tearDown()
  -- Clear all states
  if Gui.clearAllStates then
    Gui.clearAllStates()
  end

  -- Reset immediate mode state
  if Gui._immediateModeState then
    Gui._immediateModeState.reset()
  end

  if Gui.destroy then
    Gui.destroy()
  end

  -- Reset immediate mode flag
  Gui._immediateMode = false
  Gui._frameNumber = 0
end

function TestStableIDGeneration:test_child_ids_stable_across_frames()
  -- Frame 1: Create parent with children
  Gui.beginFrame()

  local parent = Gui.new({
    id = "test_parent",
    width = 400,
    height = 300,
  })

  local child1 = Gui.new({
    parent = parent,
    width = 100,
    height = 50,
    text = "Child 1",
  })

  local child2 = Gui.new({
    parent = parent,
    width = 100,
    height = 50,
    text = "Child 2",
  })

  local child1Id = child1.id
  local child2Id = child2.id

  Gui.endFrame()

  -- Frame 2: Recreate same structure
  Gui.beginFrame()

  local parent2 = Gui.new({
    id = "test_parent",
    width = 400,
    height = 300,
  })

  local child1_2 = Gui.new({
    parent = parent2,
    width = 100,
    height = 50,
    text = "Child 1",
  })

  local child2_2 = Gui.new({
    parent = parent2,
    width = 100,
    height = 50,
    text = "Child 2",
  })

  Gui.endFrame()

  -- IDs should be stable
  luaunit.assertEquals(child1_2.id, child1Id, "Child 1 ID should be stable across frames")
  luaunit.assertEquals(child2_2.id, child2Id, "Child 2 ID should be stable across frames")
end

function TestStableIDGeneration:test_conditional_rendering_does_not_affect_siblings()
  -- Frame 1: Create parent with 3 children
  Gui.beginFrame()

  local parent1 = Gui.new({
    id = "test_parent2",
    width = 400,
    height = 300,
  })

  local child1 = Gui.new({
    parent = parent1,
    width = 100,
    height = 50,
    text = "Child 1",
  })

  local child2 = Gui.new({
    parent = parent1,
    width = 100,
    height = 50,
    text = "Child 2",
  })

  local child3 = Gui.new({
    parent = parent1,
    width = 100,
    height = 50,
    text = "Child 3",
  })

  local child1Id = child1.id
  local child3Id = child3.id

  Gui.endFrame()

  -- Frame 2: Skip child 2 (conditional rendering)
  Gui.beginFrame()

  local parent2 = Gui.new({
    id = "test_parent2",
    width = 400,
    height = 300,
  })

  local child1_2 = Gui.new({
    parent = parent2,
    width = 100,
    height = 50,
    text = "Child 1",
  })

  -- Child 2 not rendered this frame

  local child3_2 = Gui.new({
    parent = parent2,
    width = 100,
    height = 50,
    text = "Child 3",
  })

  Gui.endFrame()

  -- Child 1 should keep its ID
  luaunit.assertEquals(child1_2.id, child1Id, "Child 1 ID should remain stable")
  
  -- Child 3 will have a different ID because it's now at sibling index 1 instead of 2
  -- This is EXPECTED behavior - the position in the tree changed
  luaunit.assertNotEquals(child3_2.id, child3Id, "Child 3 ID changes because its sibling position changed")
end

function TestStableIDGeneration:test_input_field_maintains_state_across_frames()
  -- Frame 1: Create input field and simulate text entry
  Gui.beginFrame()

  local container = Gui.new({
    id = "test_container",
    width = 400,
    height = 300,
  })

  local input1 = Gui.new({
    parent = container,
    width = 200,
    height = 40,
    editable = true,
    text = "",
  })

  -- Simulate text input
  input1._textBuffer = "Hello World"
  input1._focused = true

  local inputId = input1.id

  Gui.endFrame()

  -- Frame 2: Recreate same structure
  Gui.beginFrame()

  local container2 = Gui.new({
    id = "test_container",
    width = 400,
    height = 300,
  })

  local input2 = Gui.new({
    parent = container2,
    width = 200,
    height = 40,
    editable = true,
    text = "",
  })

  Gui.endFrame()

  -- Input should have same ID and restored state
  luaunit.assertEquals(input2.id, inputId, "Input field ID should be stable")
  luaunit.assertEquals(input2._textBuffer, "Hello World", "Input text should be restored")
  luaunit.assertTrue(input2._focused, "Input focus state should be restored")
end

function TestStableIDGeneration:test_nested_children_stable_ids()
  -- Frame 1: Create nested hierarchy
  Gui.beginFrame()

  local root = Gui.new({
    id = "test_root",
    width = 400,
    height = 300,
  })

  local level1 = Gui.new({
    parent = root,
    width = 300,
    height = 200,
  })

  local level2 = Gui.new({
    parent = level1,
    width = 200,
    height = 100,
  })

  local deepChild = Gui.new({
    parent = level2,
    width = 100,
    height = 50,
    text = "Deep Child",
  })

  local deepChildId = deepChild.id

  Gui.endFrame()

  -- Frame 2: Recreate same nested structure
  Gui.beginFrame()

  local root2 = Gui.new({
    id = "test_root",
    width = 400,
    height = 300,
  })

  local level1_2 = Gui.new({
    parent = root2,
    width = 300,
    height = 200,
  })

  local level2_2 = Gui.new({
    parent = level1_2,
    width = 200,
    height = 100,
  })

  local deepChild2 = Gui.new({
    parent = level2_2,
    width = 100,
    height = 50,
    text = "Deep Child",
  })

  Gui.endFrame()

  -- Deep child ID should be stable
  luaunit.assertEquals(deepChild2.id, deepChildId, "Deeply nested child ID should be stable")
end

function TestStableIDGeneration:test_siblings_with_different_props_have_different_ids()
  -- Frame 1: Create siblings with different properties
  Gui.beginFrame()

  local parent = Gui.new({
    width = 400,
    height = 300,
  })

  local child1 = Gui.new({
    parent = parent,
    width = 100,
    height = 50,
    text = "Button 1",
  })

  local child2 = Gui.new({
    parent = parent,
    width = 100,
    height = 50,
    text = "Button 2",
  })

  Gui.endFrame()

  -- Siblings should have different IDs due to different sibling indices and props
  luaunit.assertNotEquals(child1.id, child2.id, "Siblings should have different IDs")
end

-- Helper function to create elements from consistent location (simulates real usage)
local function createTopLevelElements()
  local elements = {}
  for i = 1, 3 do
    elements[i] = Gui.new({ width = 100, height = 50, text = "Element " .. i })
  end
  return elements
end

function TestStableIDGeneration:test_top_level_elements_use_call_site_counter()
  -- Frame 1: Create multiple top-level elements at same location (in loop)
  Gui.beginFrame()

  local elements = createTopLevelElements()

  local ids = {}
  for i = 1, 3 do
    ids[i] = elements[i].id
  end

  Gui.endFrame()

  -- Frame 2: Recreate same elements from SAME line (via helper)
  Gui.beginFrame()

  local elements2 = createTopLevelElements()

  Gui.endFrame()

  -- IDs should be stable for top-level elements when called from same location
  for i = 1, 3 do
    luaunit.assertEquals(elements2[i].id, ids[i], "Top-level element " .. i .. " ID should be stable")
  end
end

function TestStableIDGeneration:test_mixed_conditional_and_stable_elements()
  -- Simulate a real-world scenario: navigation with conditional screens
  
  -- Frame 1: Screen A with input field
  Gui.beginFrame()

  local backdrop1 = Gui.new({
    id = "backdrop",
    width = "100%",
    height = "100%",
  })

  local window1 = Gui.new({
    parent = backdrop1,
    width = "80%",
    height = "80%",
  })

  -- Screen A content
  local inputA = Gui.new({
    parent = window1,
    width = 200,
    height = 40,
    editable = true,
    text = "Screen A Input",
  })

  inputA._textBuffer = "User typed this"
  inputA._focused = true

  local inputAId = inputA.id

  Gui.endFrame()

  -- Frame 2: Same screen structure (user is still on Screen A)
  Gui.beginFrame()

  local backdrop2 = Gui.new({
    id = "backdrop",
    width = "100%",
    height = "100%",
  })

  local window2 = Gui.new({
    parent = backdrop2,
    width = "80%",
    height = "80%",
  })

  -- Screen A content (same position in tree)
  local inputA2 = Gui.new({
    parent = window2,
    width = 200,
    height = 40,
    editable = true,
    text = "Screen A Input",
  })

  Gui.endFrame()

  -- Input field should maintain ID and state
  luaunit.assertEquals(inputA2.id, inputAId, "Input field ID should be stable within same screen")
  luaunit.assertEquals(inputA2._textBuffer, "User typed this", "Input text should be preserved")
  luaunit.assertTrue(inputA2._focused, "Input focus should be preserved")
end

luaunit.LuaUnit.run()
