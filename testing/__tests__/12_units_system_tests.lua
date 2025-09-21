package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection

-- Test the Units system functionality
TestUnitsSystem = {}

function TestUnitsSystem:setUp()
  -- Clear any existing GUI elements and reset viewport
  Gui.destroy()
  -- Set a consistent viewport size for testing
  love.graphics.getDimensions = function() return 1200, 800 end
end

function TestUnitsSystem:tearDown()
  Gui.destroy()
end

-- ============================================
-- Units Parsing Tests
-- ============================================

function TestUnitsSystem:testUnitsParsePx()
  -- Test pixel unit parsing
  local container = Gui.new({
    id = "container",
    w = "100px",
    h = "200px",
    x = "50px",
    y = "75px",
  })
  
  luaunit.assertEquals(container.width, 100)
  luaunit.assertEquals(container.height, 200)
  luaunit.assertEquals(container.x, 50)
  luaunit.assertEquals(container.y, 75)
  luaunit.assertEquals(container.units.width.unit, "px")
  luaunit.assertEquals(container.units.height.unit, "px")
  luaunit.assertEquals(container.units.x.unit, "px")
  luaunit.assertEquals(container.units.y.unit, "px")
end

function TestUnitsSystem:testUnitsParsePercentage()
  -- Test percentage unit parsing
  local parent = Gui.new({
    id = "parent",
    w = 400,
    h = 300,
  })
  
  local child = Gui.new({
    id = "child",
    w = "50%",
    h = "25%",
    parent = parent,
  })
  
  luaunit.assertEquals(child.width, 200) -- 50% of 400
  luaunit.assertEquals(child.height, 75)  -- 25% of 300
  luaunit.assertEquals(child.units.width.unit, "%")
  luaunit.assertEquals(child.units.height.unit, "%")
  luaunit.assertEquals(child.units.width.value, 50)
  luaunit.assertEquals(child.units.height.value, 25)
end

function TestUnitsSystem:testUnitsParseViewportWidth()
  -- Test viewport width units (1200px viewport)
  local container = Gui.new({
    id = "container",
    w = "50vw",
    h = "100px",
  })
  
  luaunit.assertEquals(container.width, 600) -- 50% of 1200
  luaunit.assertEquals(container.units.width.unit, "vw")
  luaunit.assertEquals(container.units.width.value, 50)
end

function TestUnitsSystem:testUnitsParseViewportHeight()
  -- Test viewport height units (800px viewport)
  local container = Gui.new({
    id = "container",
    w = "100px",
    h = "25vh",
  })
  
  luaunit.assertEquals(container.height, 200) -- 25% of 800
  luaunit.assertEquals(container.units.height.unit, "vh")
  luaunit.assertEquals(container.units.height.value, 25)
end

function TestUnitsSystem:testUnitsAutoSizing()
  -- Test that auto-sized elements use "auto" unit
  local autoContainer = Gui.new({
    id = "autoContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
  })
  
  luaunit.assertEquals(autoContainer.units.width.unit, "auto")
  luaunit.assertEquals(autoContainer.units.height.unit, "auto")
  luaunit.assertTrue(autoContainer.autosizing.width)
  luaunit.assertTrue(autoContainer.autosizing.height)
end

function TestUnitsSystem:testMixedUnits()
  -- Test elements with different unit types
  local container = Gui.new({
    id = "container",
    w = "80vw",      -- viewport width
    h = "400px",     -- pixels
    x = "10%",       -- percentage of viewport
    y = "5vh",       -- viewport height
    gap = "2vw",     -- viewport width for gap
    textSize = "16px" -- pixel font size
  })
  
  luaunit.assertEquals(container.width, 960)   -- 80% of 1200
  luaunit.assertEquals(container.height, 400)  -- 400px
  luaunit.assertEquals(container.x, 120)       -- 10% of 1200
  luaunit.assertEquals(container.y, 40)        -- 5% of 800
  luaunit.assertEquals(container.gap, 24)      -- 2% of 1200
  luaunit.assertEquals(container.textSize, 16) -- 16px
end

-- ============================================
-- Resize and Unit Recalculation Tests
-- ============================================

function TestUnitsSystem:testResizeViewportUnits()
  -- Test that viewport units recalculate on resize
  local container = Gui.new({
    id = "container",
    w = "50vw",
    h = "25vh",
  })
  
  luaunit.assertEquals(container.width, 600)  -- 50% of 1200
  luaunit.assertEquals(container.height, 200) -- 25% of 800
  
  -- Simulate viewport resize
  love.graphics.getDimensions = function() return 1600, 1000 end
  container:resize(1600, 1000)
  
  luaunit.assertEquals(container.width, 800)  -- 50% of 1600
  luaunit.assertEquals(container.height, 250) -- 25% of 1000
end

function TestUnitsSystem:testResizePercentageUnits()
  -- Test percentage units during parent resize
  local parent = Gui.new({
    id = "parent",
    w = 400,
    h = 300,
  })
  
  local child = Gui.new({
    id = "child",
    w = "75%",
    h = "50%",
    parent = parent,
  })
  
  luaunit.assertEquals(child.width, 300)   -- 75% of 400
  luaunit.assertEquals(child.height, 150)  -- 50% of 300
  
  -- Resize parent
  parent.width = 600
  parent.height = 500
  child:resize(1200, 800)
  
  luaunit.assertEquals(child.width, 450)   -- 75% of 600
  luaunit.assertEquals(child.height, 250)  -- 50% of 500
end

function TestUnitsSystem:testResizePixelUnitsNoChange()
  -- Test that pixel units don't change during resize
  local container = Gui.new({
    id = "container",
    w = "300px",
    h = "200px",
  })
  
  luaunit.assertEquals(container.width, 300)
  luaunit.assertEquals(container.height, 200)
  
  -- Resize viewport - pixel values should stay the same
  container:resize(1600, 1000)
  
  luaunit.assertEquals(container.width, 300)
  luaunit.assertEquals(container.height, 200)
end

-- ============================================
-- Spacing (Padding/Margin) Units Tests
-- ============================================

function TestUnitsSystem:testPaddingUnits()
  -- Test different unit types for padding
  local container = Gui.new({
    id = "container",
    w = 400,
    h = 300,
    padding = {
      top = "10px",
      right = "5%",
      bottom = "2vh", 
      left = "1vw"
    }
  })
  
  luaunit.assertEquals(container.padding.top, 10)    -- 10px
  luaunit.assertEquals(container.padding.right, 20)  -- 5% of 400
  luaunit.assertEquals(container.padding.bottom, 16) -- 2% of 800
  luaunit.assertEquals(container.padding.left, 12)   -- 1% of 1200
  
  luaunit.assertEquals(container.units.padding.top.unit, "px")
  luaunit.assertEquals(container.units.padding.right.unit, "%")
  luaunit.assertEquals(container.units.padding.bottom.unit, "vh")
  luaunit.assertEquals(container.units.padding.left.unit, "vw")
end

function TestUnitsSystem:testMarginUnits()
  -- Test different unit types for margin
  local container = Gui.new({
    id = "container",
    w = 400,
    h = 300,
    margin = {
      top = "8px",
      right = "3%",
      bottom = "1vh",
      left = "2vw"
    }
  })
  
  luaunit.assertEquals(container.margin.top, 8)      -- 8px
  luaunit.assertEquals(container.margin.right, 12)   -- 3% of 400
  luaunit.assertEquals(container.margin.bottom, 8)   -- 1% of 800
  luaunit.assertEquals(container.margin.left, 24)    -- 2% of 1200
  
  luaunit.assertEquals(container.units.margin.top.unit, "px")
  luaunit.assertEquals(container.units.margin.right.unit, "%")
  luaunit.assertEquals(container.units.margin.bottom.unit, "vh")
  luaunit.assertEquals(container.units.margin.left.unit, "vw")
end

-- ============================================
-- Gap and TextSize Units Tests
-- ============================================

function TestUnitsSystem:testGapUnits()
  -- Test gap with different unit types
  local flexContainer = Gui.new({
    id = "flexContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    w = 600,
    h = 400,
    gap = "2%", -- 2% of container width
  })
  
  luaunit.assertEquals(flexContainer.gap, 12) -- 2% of 600
  luaunit.assertEquals(flexContainer.units.gap.unit, "%")
  luaunit.assertEquals(flexContainer.units.gap.value, 2)
  
  -- Test with viewport units
  local viewportGapContainer = Gui.new({
    id = "viewportGapContainer", 
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 400,
    h = 300,
    gap = "1vw",
  })
  
  luaunit.assertEquals(viewportGapContainer.gap, 12) -- 1% of 1200 viewport width
  luaunit.assertEquals(viewportGapContainer.units.gap.unit, "vw")
end

function TestUnitsSystem:testTextSizeUnits()
  -- Test textSize with different units
  local textElement = Gui.new({
    id = "textElement",
    w = 200,
    h = 100,
    textSize = "16px"
  })
  
  luaunit.assertEquals(textElement.textSize, 16)
  luaunit.assertEquals(textElement.units.textSize.unit, "px")
  luaunit.assertEquals(textElement.units.textSize.value, 16)
  
  -- Test with viewport units
  local viewportTextElement = Gui.new({
    id = "viewportTextElement",
    w = 200,
    h = 100,
    textSize = "2vw"
  })
  
  luaunit.assertEquals(viewportTextElement.textSize, 24) -- 2% of 1200
  luaunit.assertEquals(viewportTextElement.units.textSize.unit, "vw")
end

-- ============================================
-- Error Handling and Edge Cases
-- ============================================

function TestUnitsSystem:testInvalidUnits()
  -- Test handling of invalid unit specifications (should default to pixels)
  local container = Gui.new({
    id = "container",
    w = "100invalid", -- Should be treated as 100px
    h = "50badunit"   -- Should be treated as 50px
  })
  
  -- Should fallback to pixel values
  luaunit.assertEquals(container.width, 100)
  luaunit.assertEquals(container.height, 50)
  luaunit.assertEquals(container.units.width.unit, "px")
  luaunit.assertEquals(container.units.height.unit, "px")
end

function TestUnitsSystem:testZeroAndNegativeValues()
  -- Test zero and negative values with units
  local container = Gui.new({
    id = "container",
    w = "0px",
    h = "0vh",
    x = "-10px",
    y = "-5%"
  })
  
  luaunit.assertEquals(container.width, 0)
  luaunit.assertEquals(container.height, 0)
  luaunit.assertEquals(container.x, -10)
  luaunit.assertEquals(container.y, -40) -- -5% of 800 viewport height for y positioning
end

function TestUnitsSystem:testVeryLargeValues()
  -- Test very large percentage values
  local container = Gui.new({
    id = "container",
    w = "200%",  -- 200% of viewport
    h = "150vh"  -- 150% of viewport height
  })
  
  luaunit.assertEquals(container.width, 2400) -- 200% of 1200
  luaunit.assertEquals(container.height, 1200) -- 150% of 800
end

-- Run the tests
os.exit(luaunit.LuaUnit.run())