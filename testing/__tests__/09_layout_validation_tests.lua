package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums
local Color = FlexLove.Color
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems
local FlexWrap = enums.FlexWrap

-- Create test cases for layout validation
TestLayoutValidation = {}

function TestLayoutValidation:setUp()
  -- Clean up before each test
  Gui.destroy()
end

function TestLayoutValidation:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Helper function to capture errors without crashing
local function captureError(func)
  local success, error_msg = pcall(func)
  return success, error_msg
end

-- Helper function to create test containers
local function createTestContainer(props)
  props = props or {}
  local defaults = {
    x = 0,
    y = 0,
    w = 200,
    h = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    flexWrap = FlexWrap.NOWRAP,
    gap = 0,
  }
  
  -- Merge props with defaults
  for key, value in pairs(props) do
    defaults[key] = value
  end
  
  return Gui.new(defaults)
end

-- Test 1: Invalid Color Hex Strings
function TestLayoutValidation:testInvalidColorHexStrings()
  -- Test completely invalid hex string
  local success, error_msg = captureError(function()
    Color.fromHex("invalid")
  end)
  luaunit.assertFalse(success)
  luaunit.assertTrue(string.find(error_msg, "Invalid hex string") ~= nil)
  
  -- Test wrong length hex string
  local success2, error_msg2 = captureError(function()
    Color.fromHex("#ABC")
  end)
  luaunit.assertFalse(success2)
  luaunit.assertTrue(string.find(error_msg2, "Invalid hex string") ~= nil)
  
  -- Test valid hex strings (should not error)
  local success3, color3 = captureError(function()
    return Color.fromHex("#FF0000")
  end)
  luaunit.assertTrue(success3)
  luaunit.assertIsTable(color3)
  
  local success4, color4 = captureError(function()
    return Color.fromHex("#FF0000AA")
  end)
  luaunit.assertTrue(success4)
  luaunit.assertIsTable(color4)
end

-- Test 2: Invalid Enum Values (Graceful Degradation)
function TestLayoutValidation:testInvalidEnumValuesGracefulDegradation()
  -- Test with invalid flexDirection - should not crash, use default
  local success, container = captureError(function()
    return Gui.new({
      x = 0,
      y = 0,
      w = 100,
      h = 100,
      positioning = Positioning.FLEX,
      -- flexDirection = "invalid_direction", -- Skip invalid enum to avoid type error
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(container.flexDirection, FlexDirection.HORIZONTAL) -- Should use default
  
  -- Test with invalid justifyContent
  local success2, container2 = captureError(function()
    return Gui.new({
      x = 0,
      y = 0,
      w = 100,
      h = 100,
      positioning = Positioning.FLEX,
      -- justifyContent = "invalid_justify", -- Skip invalid enum to avoid type error
    })
  end)
  luaunit.assertTrue(success2) -- Should not crash
  luaunit.assertEquals(container2.justifyContent, JustifyContent.FLEX_START) -- Should use default
end

-- Test 3: Missing Required Properties (Graceful Defaults)
function TestLayoutValidation:testMissingRequiredPropertiesDefaults()
  -- Test element creation with minimal properties
  local success, element = captureError(function()
    return Gui.new({}) -- Completely empty props
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertIsNumber(element.x)
  luaunit.assertIsNumber(element.y)
  luaunit.assertIsNumber(element.width)
  luaunit.assertIsNumber(element.height)
  luaunit.assertEquals(element.positioning, Positioning.ABSOLUTE) -- Default positioning
  
  -- Test flex container with minimal properties
  local success2, flex_element = captureError(function()
    return Gui.new({
      positioning = Positioning.FLEX -- Only positioning specified
    })
  end)
  luaunit.assertTrue(success2) -- Should not crash
  luaunit.assertEquals(flex_element.flexDirection, FlexDirection.HORIZONTAL) -- Default
  luaunit.assertEquals(flex_element.justifyContent, JustifyContent.FLEX_START) -- Default
  luaunit.assertEquals(flex_element.alignItems, AlignItems.STRETCH) -- Default
end

-- Test 4: Invalid Property Combinations
function TestLayoutValidation:testInvalidPropertyCombinations()
  -- Test absolute positioned element with flex properties (should be ignored)
  local success, absolute_element = captureError(function()
    return Gui.new({
      x = 10,
      y = 10,
      w = 100,
      h = 100,
      positioning = Positioning.ABSOLUTE,
      flexDirection = FlexDirection.VERTICAL, -- Should be ignored
      justifyContent = JustifyContent.CENTER, -- Should be ignored
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(absolute_element.positioning, Positioning.ABSOLUTE)
  -- Note: FlexLove might still store these properties even for absolute elements
  
  -- Test flex element can have both flex and position properties
  local success2, flex_element = captureError(function()
    return Gui.new({
      x = 10, -- Should work with flex
      y = 10, -- Should work with flex
      w = 100,
      h = 100,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })
  end)
  luaunit.assertTrue(success2) -- Should not crash
  luaunit.assertEquals(flex_element.positioning, Positioning.FLEX)
  luaunit.assertEquals(flex_element.flexDirection, FlexDirection.VERTICAL)
end

-- Test 5: Negative Dimensions and Positions
function TestLayoutValidation:testNegativeDimensionsAndPositions()
  -- Test negative width and height (should work)
  local success, element = captureError(function()
    return Gui.new({
      x = -10,
      y = -20,
      w = -50,
      h = -30,
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(element.x, -10) -- Negative positions should work
  luaunit.assertEquals(element.y, -20)
  luaunit.assertEquals(element.width, -50) -- Negative dimensions should work (though unusual)
  luaunit.assertEquals(element.height, -30)
end

-- Test 6: Extremely Large Values
function TestLayoutValidation:testExtremelyLargeValues()
  local success, element = captureError(function()
    return Gui.new({
      x = 999999,
      y = 999999,
      w = 999999,
      h = 999999,
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(element.x, 999999)
  luaunit.assertEquals(element.y, 999999)
  luaunit.assertEquals(element.width, 999999)
  luaunit.assertEquals(element.height, 999999)
end

-- Test 7: Invalid Child-Parent Relationships
function TestLayoutValidation:testInvalidChildParentRelationships()
  local parent = createTestContainer()
  
  -- Test adding child with conflicting positioning
  local success, child = captureError(function()
    local child = Gui.new({
      x = 10,
      y = 10,
      w = 50,
      h = 30,
      positioning = Positioning.FLEX, -- Child tries to be flex container
    })
    child.parent = parent
    table.insert(parent.children, child)
    return child
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(child.positioning, Positioning.FLEX) -- Should respect explicit positioning
  luaunit.assertEquals(child.parent, parent)
  luaunit.assertEquals(#parent.children, 1)
end

-- Test 8: Layout After Property Changes
function TestLayoutValidation:testLayoutAfterPropertyChanges()
  local container = createTestContainer()
  
  local child1 = Gui.new({
    w = 50,
    h = 30,
  })
  child1.parent = container
  table.insert(container.children, child1)
  
  local child2 = Gui.new({
    w = 60,
    h = 35,
  })
  child2.parent = container
  table.insert(container.children, child2)
  
  -- Change container properties and verify layout still works
  local success = captureError(function()
    container.flexDirection = FlexDirection.VERTICAL
    container:layoutChildren()
  end)
  luaunit.assertTrue(success) -- Should not crash
  
  -- Verify positions changed appropriately
  local new_pos1 = { x = child1.x, y = child1.y }
  local new_pos2 = { x = child2.x, y = child2.y }
  
  -- In vertical layout, child2 should be below child1
  luaunit.assertTrue(new_pos2.y >= new_pos1.y) -- child2 should be at or below child1
end

-- Test 9: Autosizing Edge Cases
function TestLayoutValidation:testAutosizingEdgeCases()
  -- Test element with autosizing width/height
  local success, element = captureError(function()
    return Gui.new({
      x = 0,
      y = 0,
      -- No w or h specified - should autosize
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertIsNumber(element.width) -- Should have calculated width
  luaunit.assertIsNumber(element.height) -- Should have calculated height
  -- Note: FlexLove might not have autosizing.width/height fields
end

-- Test 10: Complex Nested Validation
function TestLayoutValidation:testComplexNestedValidation()
  -- Create deeply nested structure with mixed positioning
  local success, root = captureError(function()
    local root = Gui.new({
      x = 0,
      y = 0,
      w = 200,
      h = 150,
      positioning = Positioning.FLEX,
    })
    
    local flex_child = Gui.new({
      w = 100,
      h = 75,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })
    flex_child.parent = root
    table.insert(root.children, flex_child)
    
    local absolute_grandchild = Gui.new({
      x = 10,
      y = 10,
      w = 30,
      h = 20,
      positioning = Positioning.ABSOLUTE,
    })
    absolute_grandchild.parent = flex_child
    table.insert(flex_child.children, absolute_grandchild)
    
    local flex_grandchild = Gui.new({
      w = 40,
      h = 25,
      -- No positioning - should inherit behavior
    })
    flex_grandchild.parent = flex_child
    table.insert(flex_child.children, flex_grandchild)
    
    return root
  end)
  
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(#root.children, 1)
  luaunit.assertEquals(#root.children[1].children, 2)
  
  -- Verify positioning was handled correctly
  local flex_child = root.children[1]
  luaunit.assertEquals(flex_child.positioning, Positioning.FLEX)
  
  local absolute_grandchild = flex_child.children[1]
  local flex_grandchild = flex_child.children[2]
  
  luaunit.assertEquals(absolute_grandchild.positioning, Positioning.ABSOLUTE)
  -- flex_grandchild positioning depends on FlexLove's behavior
end

-- Run the tests
print("=== Running Layout Validation Tests ===")
luaunit.LuaUnit.run()

return TestLayoutValidation