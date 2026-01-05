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

FlexLove.init()

--[[
================================================================================
KNOWN BUGS IN COMMIT 157b932 - Tests will fail until these are fixed
================================================================================

BUG #1: FLEX BASIS AUTO USES MODIFIED WIDTH
Location: LayoutEngine.lua:247-253
Problem: When flexBasis="auto", the implementation uses getBorderBoxWidth() which
         returns the CURRENT width (already modified by previous layouts), not the
         ORIGINAL width specified in props.
         
Impact:  Incorrect flex calculations when layout runs multiple times
         Example: child with width=100, flexGrow=1 added alone grows to 600px.
         When second child added, first child's flexBasis uses 600px not 100px.

Fix:     Use element.units.width to recalculate original size from stored value/unit
         instead of getBorderBoxWidth()

Tests affected: Most TestFlexGrow tests will fail due to this bug


BUG #2: SHRINKING NOT TRIGGERED WITHOUT FLEXGROW
Location: LayoutEngine.lua:524-530
Problem: needsFlexSizing only checks if (flexGrow > 0 OR flexBasis != "auto")
         This means items with default flexShrink=1 won't shrink in overflow
         situations unless they also have flexGrow > 0 or explicit flexBasis.
         
Impact:  Items don't shrink by default like CSS flexbox behavior
         CSS default: flex-shrink: 1 (items shrink to prevent overflow)

Fix:     Also check if shrinking might be needed (items overflow container)
         Or always run flex sizing algorithm for flex containers

Tests affected: All TestFlexShrink tests will fail due to this bug

================================================================================
]]

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function roundToDecimal(num, decimals)
  local mult = 10 ^ (decimals or 2)
  return math.floor(num * mult + 0.5) / mult
end

-- ============================================================================
-- Test Suite 1: Flex Shorthand Parsing
-- ============================================================================

TestFlexShorthand = {}

function TestFlexShorthand:setUp()
  FlexLove.beginFrame()
end

function TestFlexShorthand:tearDown()
  FlexLove.endFrame()
end

function TestFlexShorthand:test_flex_number_shorthand()
  -- flex: 1 should set flexGrow=1, flexShrink=1, flexBasis=0
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flex = 1,
  })

  luaunit.assertEquals(element.flexGrow, 1)
  luaunit.assertEquals(element.flexShrink, 1)
  luaunit.assertEquals(element.flexBasis, 0)
end

function TestFlexShorthand:test_flex_auto_shorthand()
  -- flex: "auto" should set flexGrow=1, flexShrink=1, flexBasis="auto"
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flex = "auto",
  })

  luaunit.assertEquals(element.flexGrow, 1)
  luaunit.assertEquals(element.flexShrink, 1)
  luaunit.assertEquals(element.flexBasis, "auto")
end

function TestFlexShorthand:test_flex_none_shorthand()
  -- flex: "none" should set flexGrow=0, flexShrink=0, flexBasis="auto"
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flex = "none",
  })

  luaunit.assertEquals(element.flexGrow, 0)
  luaunit.assertEquals(element.flexShrink, 0)
  luaunit.assertEquals(element.flexBasis, "auto")
end

function TestFlexShorthand:test_flex_two_values_numbers()
  -- flex: "2 0" should set flexGrow=2, flexShrink=0, flexBasis=0
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flex = "2 0",
  })

  luaunit.assertEquals(element.flexGrow, 2)
  luaunit.assertEquals(element.flexShrink, 0)
  luaunit.assertEquals(element.flexBasis, 0)
end

function TestFlexShorthand:test_flex_grow_with_basis()
  -- flex: "1 200px" should set flexGrow=1, flexShrink=1, flexBasis="200px"
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flex = "1 200px",
  })

  luaunit.assertEquals(element.flexGrow, 1)
  luaunit.assertEquals(element.flexShrink, 1)
  luaunit.assertEquals(element.flexBasis, "200px")
end

function TestFlexShorthand:test_flex_three_values()
  -- flex: "2 1 150px" should set all three values
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flex = "2 1 150px",
  })

  luaunit.assertEquals(element.flexGrow, 2)
  luaunit.assertEquals(element.flexShrink, 1)
  luaunit.assertEquals(element.flexBasis, "150px")
end

function TestFlexShorthand:test_explicit_props_override_shorthand()
  -- Explicit properties should override flex shorthand
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flex = 1,
    flexGrow = 3,
    flexShrink = 0,
  })

  luaunit.assertEquals(element.flexGrow, 3)
  luaunit.assertEquals(element.flexShrink, 0)
  luaunit.assertEquals(element.flexBasis, 0)
end

-- ============================================================================
-- Test Suite 2: Flex Property Validation
-- ============================================================================

TestFlexPropertyValidation = {}

function TestFlexPropertyValidation:setUp()
  FlexLove.beginFrame()
end

function TestFlexPropertyValidation:tearDown()
  FlexLove.endFrame()
end

function TestFlexPropertyValidation:test_default_flex_values()
  local element = FlexLove.new({
    width = 100,
    height = 100,
  })

  luaunit.assertEquals(element.flexGrow, 0)
  luaunit.assertEquals(element.flexShrink, 1)
  luaunit.assertEquals(element.flexBasis, "auto")
end

function TestFlexPropertyValidation:test_valid_flexGrow()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexGrow = 2,
  })

  luaunit.assertEquals(element.flexGrow, 2)
end

function TestFlexPropertyValidation:test_invalid_flexGrow_negative()
  -- Negative flexGrow should default to 0 with warning
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexGrow = -1,
  })

  luaunit.assertEquals(element.flexGrow, 0)
end

function TestFlexPropertyValidation:test_invalid_flexGrow_string()
  -- String flexGrow should default to 0 with warning
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexGrow = "invalid",
  })

  luaunit.assertEquals(element.flexGrow, 0)
end

function TestFlexPropertyValidation:test_valid_flexShrink()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexShrink = 0,
  })

  luaunit.assertEquals(element.flexShrink, 0)
end

function TestFlexPropertyValidation:test_invalid_flexShrink_negative()
  -- Negative flexShrink should default to 1 with warning
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexShrink = -1,
  })

  luaunit.assertEquals(element.flexShrink, 1)
end

function TestFlexPropertyValidation:test_flexBasis_auto()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexBasis = "auto",
  })

  luaunit.assertEquals(element.flexBasis, "auto")
end

function TestFlexPropertyValidation:test_flexBasis_number()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexBasis = 200,
  })

  luaunit.assertEquals(element.flexBasis, 200)
end

function TestFlexPropertyValidation:test_flexBasis_with_units()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    flexBasis = "50%",
  })

  luaunit.assertEquals(element.flexBasis, "50%")
  luaunit.assertNotNil(element.units.flexBasis)
end

-- ============================================================================
-- Test Suite 3: Flex Grow - Distributing Extra Space
-- ============================================================================

TestFlexGrow = {}

function TestFlexGrow:setUp()
  FlexLove.beginFrame()
end

function TestFlexGrow:tearDown()
  FlexLove.endFrame()
end

function TestFlexGrow:test_single_item_with_flex_grow()
  local container = FlexLove.new({
    width = 500,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Child should grow to fill container: 500px
  luaunit.assertEquals(child.width, 500)
end

function TestFlexGrow:test_two_items_equal_flex_grow()
  local container = FlexLove.new({
    width = 600,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Both children should grow equally: (600 - 200) / 2 = 200 extra each
  luaunit.assertEquals(child1.width, 300)
  luaunit.assertEquals(child2.width, 300)
end

function TestFlexGrow:test_proportional_flex_grow()
  local container = FlexLove.new({
    width = 700,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 2,
    parent = container,
  })

  container:layoutChildren()

  -- Free space: 700 - 200 = 500
  -- child1 gets: 100 + (1/3 * 500) = 266.67
  -- child2 gets: 100 + (2/3 * 500) = 433.33
  luaunit.assertEquals(roundToDecimal(child1.width, 1), 266.7)
  luaunit.assertEquals(roundToDecimal(child2.width, 1), 433.3)
end

function TestFlexGrow:test_flex_grow_with_gap()
  local container = FlexLove.new({
    width = 620,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 20,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Available space: 620 - 20(gap) = 600
  -- Free space: 600 - 200 = 400, divided equally = 200 each
  luaunit.assertEquals(child1.width, 300)
  luaunit.assertEquals(child2.width, 300)
end

function TestFlexGrow:test_flex_grow_vertical()
  local container = FlexLove.new({
    width = 100,
    height = 500,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 50,
    height = 100,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 50,
    height = 100,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Both children should grow equally in vertical direction
  luaunit.assertEquals(child1.height, 250)
  luaunit.assertEquals(child2.height, 250)
end

function TestFlexGrow:test_flex_grow_with_margins()
  local container = FlexLove.new({
    width = 640,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    margin = { left = 10, right = 10, top = 0, bottom = 0 },
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    margin = { left = 10, right = 10, top = 0, bottom = 0 },
    parent = container,
  })

  container:layoutChildren()

  -- Total margins: 40px (10+10 for each child)
  -- Basis sizes with margins: 120 + 120 = 240
  -- Free space: 640 - 240 = 400
  -- Each child grows by 200, so final width = 300
  luaunit.assertEquals(child1.width, 300)
  luaunit.assertEquals(child2.width, 300)
end

-- ============================================================================
-- Test Suite 4: Flex Shrink - Handling Overflow
-- ============================================================================

TestFlexShrink = {}

function TestFlexShrink:setUp()
  FlexLove.beginFrame()
end

function TestFlexShrink:tearDown()
  FlexLove.endFrame()
end

function TestFlexShrink:test_items_shrink_equally()
  -- CSS behavior: Items with flex-shrink: 1 (default) should shrink when overflow
  local container = FlexLove.new({
    width = 300,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 200,
    height = 50,
    flexShrink = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 200,
    height = 50,
    flexShrink = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Overflow: 400 - 300 = 100
  -- Both shrink equally (same flex-shrink and flex-basis)
  -- Expected CSS behavior: 150px each
  luaunit.assertEquals(child1.width, 150)
  luaunit.assertEquals(child2.width, 150)
end

function TestFlexShrink:test_proportional_shrink()
  local container = FlexLove.new({
    width = 300,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 200,
    height = 50,
    flexShrink = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 200,
    height = 50,
    flexShrink = 2,
    parent = container,
  })

  container:layoutChildren()

  -- Overflow: 400 - 300 = 100
  -- Scaled shrink factors: 1*200=200, 2*200=400, total=600
  -- child1 shrinks: (200/600) * 100 = 33.33, final = 166.67
  -- child2 shrinks: (400/600) * 100 = 66.67, final = 133.33
  luaunit.assertEquals(roundToDecimal(child1.width, 1), 166.7)
  luaunit.assertEquals(roundToDecimal(child2.width, 1), 133.3)
end

function TestFlexShrink:test_flex_shrink_zero_prevents_shrinking()
  local container = FlexLove.new({
    width = 300,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 150,
    height = 50,
    flexShrink = 0,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 200,
    height = 50,
    flexShrink = 1,
    parent = container,
  })

  container:layoutChildren()

  -- child1 should not shrink (flexShrink = 0)
  -- child2 absorbs all overflow: 200 - 50 = 150
  luaunit.assertEquals(child1.width, 150)
  luaunit.assertEquals(child2.width, 150)
end

function TestFlexShrink:test_different_basis_affects_shrink()
  local container = FlexLove.new({
    width = 300,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexShrink = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 300,
    height = 50,
    flexShrink = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Overflow: 400 - 300 = 100
  -- Scaled shrink factors: 1*100=100, 1*300=300, total=400
  -- child1 shrinks: (100/400) * 100 = 25, final = 75
  -- child2 shrinks: (300/400) * 100 = 75, final = 225
  luaunit.assertEquals(child1.width, 75)
  luaunit.assertEquals(child2.width, 225)
end

function TestFlexShrink:test_shrink_with_margins()
  local container = FlexLove.new({
    width = 300,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 200,
    height = 50,
    flexShrink = 1,
    margin = { left = 10, right = 10, top = 0, bottom = 0 },
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 200,
    height = 50,
    flexShrink = 1,
    margin = { left = 10, right = 10, top = 0, bottom = 0 },
    parent = container,
  })

  container:layoutChildren()

  -- Basis sizes with margins: 220 + 220 = 440
  -- Overflow: 440 - 300 = 140
  -- Both shrink equally: 70 each
  luaunit.assertEquals(child1.width, 130)
  luaunit.assertEquals(child2.width, 130)
end

-- ============================================================================
-- Test Suite 5: Flex Basis
-- ============================================================================

TestFlexBasis = {}

function TestFlexBasis:setUp()
  FlexLove.beginFrame()
end

function TestFlexBasis:tearDown()
  FlexLove.endFrame()
end

function TestFlexBasis:test_flexBasis_auto_uses_element_width()
  local container = FlexLove.new({
    width = 500,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child = FlexLove.new({
    width = 150,
    height = 50,
    flexBasis = "auto",
    flexGrow = 0,
    parent = container,
  })

  container:layoutChildren()

  -- flexBasis "auto" should use element's width
  luaunit.assertEquals(child.width, 150)
end

function TestFlexBasis:test_flexBasis_numeric_overrides_width()
  local container = FlexLove.new({
    width = 500,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child = FlexLove.new({
    width = 150,
    height = 50,
    flexBasis = 200,
    flexGrow = 0,
    parent = container,
  })

  container:layoutChildren()

  -- flexBasis should override width as the starting point
  luaunit.assertEquals(child.width, 200)
end

function TestFlexBasis:test_flexBasis_percentage()
  local container = FlexLove.new({
    width = 600,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child = FlexLove.new({
    width = 100,
    height = 50,
    flexBasis = "50%",
    flexGrow = 0,
    parent = container,
  })

  container:layoutChildren()

  -- flexBasis 50% of container = 300px
  luaunit.assertEquals(child.width, 300)
end

function TestFlexBasis:test_flexBasis_with_grow()
  local container = FlexLove.new({
    width = 600,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexBasis = 100,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 200,
    height = 50,
    flexBasis = 200,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Total basis: 300, free space: 300
  -- Each grows by 150
  luaunit.assertEquals(child1.width, 250)
  luaunit.assertEquals(child2.width, 350)
end

function TestFlexBasis:test_flexBasis_zero_with_grow()
  local container = FlexLove.new({
    width = 600,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexBasis = 0,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 200,
    height = 50,
    flexBasis = 0,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Total basis: 0, all space is free space
  -- Distributed equally: 300 each
  luaunit.assertEquals(child1.width, 300)
  luaunit.assertEquals(child2.width, 300)
end

-- ============================================================================
-- Test Suite 6: Complex Scenarios
-- ============================================================================

TestFlexComplexScenarios = {}

function TestFlexComplexScenarios:setUp()
  FlexLove.beginFrame()
end

function TestFlexComplexScenarios:tearDown()
  FlexLove.endFrame()
end

function TestFlexComplexScenarios:test_mixed_grow_no_grow()
  local container = FlexLove.new({
    width = 700,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 150,
    height = 50,
    flexGrow = 0,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 150,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  local child3 = FlexLove.new({
    width = 150,
    height = 50,
    flexGrow = 2,
    parent = container,
  })

  container:layoutChildren()

  -- child1 doesn't grow: 150
  -- Free space: 700 - 450 = 250
  -- child2 grows: 150 + (1/3 * 250) = 233.33
  -- child3 grows: 150 + (2/3 * 250) = 316.67
  luaunit.assertEquals(child1.width, 150)
  luaunit.assertEquals(roundToDecimal(child2.width, 1), 233.3)
  luaunit.assertEquals(roundToDecimal(child3.width, 1), 316.7)
end

function TestFlexComplexScenarios:test_wrapping_with_flex_grow()
  local container = FlexLove.new({
    width = 400,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    flexWrap = "wrap",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 150,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 150,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  local child3 = FlexLove.new({
    width = 150,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- First line: child1, child2 (300px basis, 100px free space)
  -- Each grows by 50px -> 200px each
  -- Second line: child3 (150px basis, 250px free space)
  -- child3 grows to fill line -> 400px
  luaunit.assertEquals(child1.width, 200)
  luaunit.assertEquals(child2.width, 200)
  luaunit.assertEquals(child3.width, 400)
end

function TestFlexComplexScenarios:test_exact_fit_no_grow_no_shrink()
  local container = FlexLove.new({
    width = 400,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local child1 = FlexLove.new({
    width = 200,
    height = 50,
    flexGrow = 1,
    flexShrink = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 200,
    height = 50,
    flexGrow = 1,
    flexShrink = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Perfect fit: no growing or shrinking needed
  luaunit.assertEquals(child1.width, 200)
  luaunit.assertEquals(child2.width, 200)
end

function TestFlexComplexScenarios:test_nested_flex_containers()
  local outer = FlexLove.new({
    width = 800,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
  })

  local inner = FlexLove.new({
    width = 400,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    flexGrow = 1,
    gap = 0,
    parent = outer,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = inner,
  })

  local child2 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = inner,
  })

  outer:layoutChildren()

  -- Inner container grows from 400 to 800
  luaunit.assertEquals(inner.width, 800)
  -- Children of inner should each get 400
  luaunit.assertEquals(child1.width, 400)
  luaunit.assertEquals(child2.width, 400)
end

function TestFlexComplexScenarios:test_flex_with_padding()
  local container = FlexLove.new({
    width = 600,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 0,
    padding = { left = 20, right = 20, top = 10, bottom = 10 },
  })

  local child1 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  local child2 = FlexLove.new({
    width = 100,
    height = 50,
    flexGrow = 1,
    parent = container,
  })

  container:layoutChildren()

  -- Available space: 600 - 40 (padding) = 560
  -- Free space: 560 - 200 = 360, divided equally = 180 each
  luaunit.assertEquals(child1.width, 280)
  luaunit.assertEquals(child2.width, 280)
end

-- Run tests only if not part of runAll.lua
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
