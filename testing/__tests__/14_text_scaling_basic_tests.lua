-- Test file for comprehensive text scaling functionality
-- This tests all text scaling scenarios including edge cases and multiple resize events

package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI

-- Test suite for comprehensive text scaling
TestTextScaling = {}

-- Basic functionality tests
function TestTextScaling.testFixedTextSize()
  -- Create an element with fixed textSize in pixels
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = 16, -- Fixed size in pixels
    text = "Hello World",
  })

  -- Check initial state
  luaunit.assertEquals(element.textSize, 16)
  luaunit.assertEquals(element.units.textSize.unit, "px")

  -- Simulate multiple resizes
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 16) -- Should remain unchanged

  element:resize(400, 300)
  luaunit.assertEquals(element.textSize, 16) -- Should remain unchanged
end

function TestTextScaling.testPercentageTextSize()
  -- Create an element with percentage textSize (relative to viewport height)
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "5%", -- Percentage of viewport height
    text = "Hello World",
  })

  -- Check initial state (5% of 600px = 30px)
  luaunit.assertEquals(element.units.textSize.unit, "%")
  luaunit.assertEquals(element.units.textSize.value, 5)
  luaunit.assertEquals(element.textSize, 30.0)

  -- Simulate resize to larger viewport (5% of 1200px = 60px)
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 60.0)

  -- Simulate resize to smaller viewport (5% of 300px = 15px)
  element:resize(400, 300)
  luaunit.assertEquals(element.textSize, 15.0)
end

function TestTextScaling.testVwTextSize()
  -- Create an element with vw textSize
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "2vw", -- 2% of viewport width
    text = "Hello World",
  })

  -- Check initial state (2% of 800px = 16px)
  luaunit.assertEquals(element.units.textSize.unit, "vw")
  luaunit.assertEquals(element.units.textSize.value, 2)
  luaunit.assertEquals(element.textSize, 16.0)

  -- Simulate resize to larger viewport (2% of 1600px = 32px)
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 32.0)

  -- Simulate resize to smaller viewport (2% of 400px = 8px)
  element:resize(400, 300)
  luaunit.assertEquals(element.textSize, 8.0)
end

function TestTextScaling.testVhTextSize()
  -- Create an element with vh textSize
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "3vh", -- 3% of viewport height
    text = "Hello World",
  })

  -- Check initial state (3% of 600px = 18px)
  luaunit.assertEquals(element.units.textSize.unit, "vh")
  luaunit.assertEquals(element.units.textSize.value, 3)
  luaunit.assertEquals(element.textSize, 18.0)

  -- Simulate resize to larger viewport (3% of 1200px = 36px)
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 36.0)

  -- Simulate resize to smaller viewport (3% of 300px = 9px)
  element:resize(400, 300)
  luaunit.assertEquals(element.textSize, 9.0)
end

function TestTextScaling.testNoTextSize()
  -- Create an element without textSize specified
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    text = "Hello World",
  })

  -- Check initial state - should default to some value
  luaunit.assertEquals(element.units.textSize.value, nil)
  luaunit.assertEquals(element.textSize, 12) -- Default fallback

  -- Resize should not affect default textSize
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 12)
end

-- Edge case tests
function TestTextScaling.testZeroPercentageTextSize()
  -- Create an element with 0% textSize
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "0%",
    text = "Hello World",
  })

  luaunit.assertEquals(element.textSize, 0.0)

  -- Should remain 0 after resize
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 0.0)
end

function TestTextScaling.testVerySmallTextSize()
  -- Create an element with very small textSize
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "0.1vh",
    text = "Hello World",
  })

  -- Check initial state (0.1% of 600px = 0.6px)
  luaunit.assertEquals(element.textSize, 0.6)

  -- Should scale proportionally
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 1.2) -- 0.1% of 1200px = 1.2px
end

function TestTextScaling.testVeryLargeTextSize()
  -- Create an element with very large textSize
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "50vh",
    text = "Hello World",
  })

  -- Check initial state (50% of 600px = 300px)
  luaunit.assertEquals(element.textSize, 300.0)

  -- Should scale proportionally
  element:resize(1600, 1200)
  luaunit.assertEquals(element.textSize, 600.0) -- 50% of 1200px = 600px
end

function TestTextScaling.testDecimalUnits()
  -- Create an element with decimal units
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "2.5vw",
    text = "Hello World",
  })

  -- Check initial state (2.5% of 800px = 20px)
  luaunit.assertEquals(element.textSize, 20.0)

  -- Should handle decimal precision
  element:resize(1000, 800)
  luaunit.assertEquals(element.textSize, 25.0) -- 2.5% of 1000px = 25px
end

-- Multiple resize tests
function TestTextScaling.testMultipleResizes()
  -- Create an element and perform multiple resize operations
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "4vh",
    text = "Hello World",
  })

  -- Initial: 4% of 600px = 24px
  luaunit.assertEquals(element.textSize, 24.0)

  -- First resize: 4% of 800px = 32px
  element:resize(1000, 800)
  luaunit.assertEquals(element.textSize, 32.0)

  -- Second resize: 4% of 400px = 16px
  element:resize(500, 400)
  luaunit.assertEquals(element.textSize, 16.0)

  -- Third resize: 4% of 1000px = 40px
  element:resize(1200, 1000)
  luaunit.assertEquals(element.textSize, 40.0)

  -- Return to original: 4% of 600px = 24px
  element:resize(800, 600)
  luaunit.assertEquals(element.textSize, 24.0)
end

-- Mixed unit tests
function TestTextScaling.testMixedUnitsInDifferentElements()
  -- Create multiple elements with different unit types
  local elements = {
    Gui.new({ id = "px", textSize = 20, text = "Fixed" }),
    Gui.new({ id = "percent", textSize = "5%", text = "Percent" }),
    Gui.new({ id = "vw", textSize = "3vw", text = "ViewWidth" }),
    Gui.new({ id = "vh", textSize = "4vh", text = "ViewHeight" }),
  }

  -- Check initial states
  luaunit.assertEquals(elements[1].textSize, 20) -- Fixed
  luaunit.assertEquals(elements[2].textSize, 30.0) -- 5% of 600px
  luaunit.assertEquals(elements[3].textSize, 24.0) -- 3% of 800px
  luaunit.assertEquals(elements[4].textSize, 24.0) -- 4% of 600px

  -- Resize all elements
  for _, element in ipairs(elements) do
    element:resize(1200, 900)
  end

  -- Check after resize
  luaunit.assertEquals(elements[1].textSize, 20) -- Fixed (unchanged)
  luaunit.assertEquals(elements[2].textSize, 45.0) -- 5% of 900px
  luaunit.assertEquals(elements[3].textSize, 36.0) -- 3% of 1200px
  luaunit.assertEquals(elements[4].textSize, 36.0) -- 4% of 900px
end

-- Test invalid units handling
function TestTextScaling.testInvalidUnits()
  -- Test that invalid units are handled gracefully
  local success, err = pcall(function()
    local element = Gui.new({
      id = "testElement",
      width = 100,
      height = 50,
      textSize = "5invalidunit",
      text = "Hello World",
    })
  end)

  -- Should handle invalid units gracefully (might error or default)
  -- The exact behavior depends on implementation, but shouldn't crash
  luaunit.assertTrue(success or string.find(tostring(err), "Unknown unit"))
end

-- Performance test for many resizes
function TestTextScaling.testPerformanceWithManyResizes()
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "2vh",
    text = "Hello World",
  })

  -- Perform many resize operations
  local startTime = os.clock()
  for i = 1, 100 do
    local width = 800 + (i * 2)
    local height = 600 + (i * 2)
    element:resize(width, height)

    -- Verify the calculation is still correct
    local expected = (2 / 100) * height
    luaunit.assertEquals(element.textSize, expected)
  end
  local endTime = os.clock()

  -- Should complete in reasonable time (less than 1 second for 100 resizes)
  local duration = endTime - startTime
  luaunit.assertTrue(duration < 1.0, "Performance test took too long: " .. duration .. " seconds")
end

-- Element-relative unit tests
function TestTextScaling.testElementWidthUnits()
  -- Create an element with textSize relative to element width
  local element = Gui.new({
    id = "testElement",
    width = 200,
    height = 100,
    textSize = "10ew", -- 10% of element width
    text = "Hello World",
  })

  -- Check initial state (10% of 200px = 20px)
  luaunit.assertEquals(element.units.textSize.unit, "ew")
  luaunit.assertEquals(element.units.textSize.value, 10)
  luaunit.assertEquals(element.textSize, 20.0)
  luaunit.assertEquals(element.width, 200)

  -- Change element width and recalculate
  element.width = 300
  element:resize(800, 600)
  luaunit.assertEquals(element.textSize, 30.0) -- 10% of 300px = 30px
end

function TestTextScaling.testElementHeightUnits()
  -- Create an element with textSize relative to element height
  local element = Gui.new({
    id = "testElement",
    width = 200,
    height = 100,
    textSize = "15eh", -- 15% of element height
    text = "Hello World",
  })

  -- Check initial state (15% of 100px = 15px)
  luaunit.assertEquals(element.units.textSize.unit, "eh")
  luaunit.assertEquals(element.units.textSize.value, 15)
  luaunit.assertEquals(element.textSize, 15.0)
  luaunit.assertEquals(element.height, 100)

  -- Change element height and recalculate
  element.height = 200
  element:resize(800, 600)
  luaunit.assertEquals(element.textSize, 30.0) -- 15% of 200px = 30px
end

function TestTextScaling.testElementRelativeWithViewportUnits()
  -- Create an element with viewport-based size and element-relative textSize
  local element = Gui.new({
    id = "testElement",
    width = "25%", -- 25% of viewport width = 200px (800px * 0.25)
    height = "20%", -- 20% of viewport height = 120px (600px * 0.20)
    textSize = "8ew", -- 8% of element width
    text = "Hello World",
  })

  -- Check initial state
  luaunit.assertEquals(element.width, 200.0) -- 25% of 800px
  luaunit.assertEquals(element.height, 120.0) -- 20% of 600px
  luaunit.assertEquals(element.textSize, 16.0) -- 8% of 200px

  -- Resize viewport
  element:resize(1600, 1200)

  -- Element size should update with viewport, textSize should update with element size
  luaunit.assertEquals(element.width, 400.0) -- 25% of 1600px
  luaunit.assertEquals(element.height, 240.0) -- 20% of 1200px
  luaunit.assertEquals(element.textSize, 32.0) -- 8% of 400px
end

-- Min/Max constraint tests
function TestTextScaling.testMinTextSizeConstraint()
  -- Create element with textSize that would be smaller than minimum
  local element = Gui.new({
    id = "testElement",
    width = 200,
    height = 100,
    textSize = "2vh", -- 2% of 600px = 12px
    minTextSize = 16, -- Minimum 16px
    text = "Hello World",
  })

  -- Should be clamped to minimum
  luaunit.assertEquals(element.textSize, 16)

  -- Test with very small viewport
  element:resize(400, 300) -- 2% of 300px = 6px, should stay at 16px
  luaunit.assertEquals(element.textSize, 16)
end

function TestTextScaling.testMaxTextSizeConstraint()
  -- Create element with textSize that would be larger than maximum
  local element = Gui.new({
    id = "testElement",
    width = 200,
    height = 100,
    textSize = "4vh", -- 4% of 600px = 24px
    maxTextSize = 20, -- Maximum 20px
    text = "Hello World",
  })

  -- Should be clamped to maximum
  luaunit.assertEquals(element.textSize, 20)

  -- Test with very large viewport
  element:resize(1600, 1200) -- 4% of 1200px = 48px, should stay at 20px
  luaunit.assertEquals(element.textSize, 20)
end

function TestTextScaling.testBothMinMaxConstraints()
  -- Create element with both min and max constraints
  local element = Gui.new({
    id = "testElement",
    width = 200,
    height = 100,
    textSize = "3vh", -- 3% of 600px = 18px (within bounds)
    minTextSize = 12,
    maxTextSize = 24,
    text = "Hello World",
  })

  -- Should be within bounds
  luaunit.assertEquals(element.textSize, 18.0)

  -- Test small viewport (should hit min)
  element:resize(400, 300) -- 3% of 300px = 9px, should be clamped to 12px
  luaunit.assertEquals(element.textSize, 12)

  -- Test large viewport (should hit max)
  element:resize(1600, 1200) -- 3% of 1200px = 36px, should be clamped to 24px
  luaunit.assertEquals(element.textSize, 24)
end

function TestTextScaling.testConstraintsWithElementUnits()
  -- Test constraints with element-relative units
  local element = Gui.new({
    id = "testElement",
    width = 100,
    height = 50,
    textSize = "20ew", -- 20% of 100px = 20px
    minTextSize = 8,
    maxTextSize = 15,
    text = "Hello World",
  })

  -- Should be clamped to maximum
  luaunit.assertEquals(element.textSize, 15)

  -- Change width to trigger minimum
  element.width = 30 -- 20% of 30px = 6px, should be clamped to 8px
  element:resize(800, 600)
  luaunit.assertEquals(element.textSize, 8)
end

function TestTextScaling.testConstraintsWithFixedTextSize()
  -- Test that constraints work with fixed pixel textSize too
  local element = Gui.new({
    id = "testElement",
    width = 200,
    height = 100,
    textSize = 25, -- Fixed 25px
    minTextSize = 12,
    maxTextSize = 20,
    text = "Hello World",
  })

  -- Should be clamped to maximum even for fixed sizes
  luaunit.assertEquals(element.textSize, 20)
end

luaunit.LuaUnit.run()
