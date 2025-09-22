-- Test file for basic text scaling functionality
-- This tests simple cases where elements scale text appropriately during resize

package.path = './testing/?.lua;./?.lua;' .. package.path
local luaunit = require("luaunit")

-- Mock love module for testing
love = {
  graphics = {
    getDimensions = function() return 800, 600 end,
    newFont = function(size) return { getWidth = function(text) return size * #text end, getHeight = function() return size end } end,
    getFont = function() return { getWidth = function(text) return 12 * #text end, getHeight = function() return 12 end } end,
  },
  window = {
    getMode = function() return 800, 600 end
  }
}

-- Import the FlexLove library
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI

-- Test suite for basic text scaling
local BasicTextScalingTests = {}

function BasicTextScalingTests.testFixedTextSize()
  -- Create an element with fixed textSize in pixels
  local element = Gui.new({
    id = "testElement",
    w = 100,
    h = 50,
    textSize = 16, -- Fixed size in pixels
    text = "Hello World"
  })

  -- Check initial state
  luaunit.assertEquals(element.textSize, 16)
  
  -- Simulate a resize with larger viewport
  local newWidth, newHeight = 800, 600
  element:resize(newWidth, newHeight)
  
  -- Fixed textSize should remain unchanged
  luaunit.assertEquals(element.textSize, 16)
end

function BasicTextScalingTests.testPercentageTextSize()
  -- Create an element with percentage textSize
  local element = Gui.new({
    id = "testElement",
    w = 100,
    h = 50,
    textSize = "5%", -- Percentage of viewport height
    text = "Hello World"
  })

  -- Check initial state
  luaunit.assertEquals(element.units.textSize.unit, "%")
  
  -- Simulate a resize with larger viewport
  local newWidth, newHeight = 800, 600
  element:resize(newWidth, newHeight)
  
  -- Percentage textSize should be recalculated
  luaunit.assertEquals(element.textSize, 30) -- 5% of 600 height = 30
end

function BasicTextScalingTests.testVwTextSize()
  -- Create an element with vw textSize
  local element = Gui.new({
    id = "testElement",
    w = 100,
    h = 50,
    textSize = "2vw", -- 2% of viewport width
    text = "Hello World"
  })

  -- Check initial state
  luaunit.assertEquals(element.units.textSize.unit, "vw")
  
  -- Simulate a resize with larger viewport
  local newWidth, newHeight = 800, 600
  element:resize(newWidth, newHeight)
  
  -- vw textSize should be recalculated
  luaunit.assertEquals(element.textSize, 16) -- 2% of 800 width = 16
end

function BasicTextScalingTests.testVhTextSize()
  -- Create an element with vh textSize
  local element = Gui.new({
    id = "testElement",
    w = 100,
    h = 50,
    textSize = "3vh", -- 3% of viewport height
    text = "Hello World"
  })

  -- Check initial state
  luaunit.assertEquals(element.units.textSize.unit, "vh")
  
  -- Simulate a resize with larger viewport
  local newWidth, newHeight = 800, 600
  element:resize(newWidth, newHeight)
  
  -- vh textSize should be recalculated
  luaunit.assertEquals(element.textSize, 18) -- 3% of 600 height = 18
end

function BasicTextScalingTests.testNoTextSize()
  -- Create an element without textSize specified
  local element = Gui.new({
    id = "testElement",
    w = 100,
    h = 50,
    text = "Hello World"
  })

  -- Check initial state - should default to some value
  luaunit.assertEquals(element.units.textSize.value, nil)
  luaunit.assertEquals(element.textSize, 12) -- Default fallback
end

return BasicTextScalingTests