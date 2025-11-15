-- Test suite for LayoutEngine.lua module
-- Tests layout engine initialization and basic layout calculations

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local LayoutEngine = require("modules.LayoutEngine")
local Units = require("modules.Units")
local utils = require("modules.utils")

-- Mock dependencies
local mockContext = {
  getScaleFactors = function()
    return 1, 1
  end,
  baseScale = nil,
  _cachedViewport = nil,
}

local mockErrorHandler = {
  error = function(module, msg) end,
  warn = function(module, msg) end,
}

local mockGrid = {
  layoutGridItems = function(element) end,
}

local deps = {
  utils = utils,
  Grid = mockGrid,
  Units = Units,
  Context = mockContext,
  ErrorHandler = mockErrorHandler,
}

-- Test suite for LayoutEngine.new()
TestLayoutEngineNew = {}

function TestLayoutEngineNew:testNewWithDefaults()
  local layout = LayoutEngine.new({}, deps)
  luaunit.assertNotNil(layout)
  luaunit.assertEquals(layout.positioning, utils.enums.Positioning.FLEX)
  luaunit.assertEquals(layout.flexDirection, utils.enums.FlexDirection.HORIZONTAL)
  luaunit.assertEquals(layout.justifyContent, utils.enums.JustifyContent.FLEX_START)
  luaunit.assertEquals(layout.alignItems, utils.enums.AlignItems.STRETCH)
  luaunit.assertEquals(layout.alignContent, utils.enums.AlignContent.STRETCH)
  luaunit.assertEquals(layout.flexWrap, utils.enums.FlexWrap.NOWRAP)
  luaunit.assertEquals(layout.gap, 10)
end

function TestLayoutEngineNew:testNewWithCustomProps()
  local layout = LayoutEngine.new({
    positioning = utils.enums.Positioning.GRID,
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    justifyContent = utils.enums.JustifyContent.CENTER,
    alignItems = utils.enums.AlignItems.CENTER,
    gap = 20,
    gridRows = 3,
    gridColumns = 4,
  }, deps)

  luaunit.assertEquals(layout.positioning, utils.enums.Positioning.GRID)
  luaunit.assertEquals(layout.flexDirection, utils.enums.FlexDirection.VERTICAL)
  luaunit.assertEquals(layout.justifyContent, utils.enums.JustifyContent.CENTER)
  luaunit.assertEquals(layout.alignItems, utils.enums.AlignItems.CENTER)
  luaunit.assertEquals(layout.gap, 20)
  luaunit.assertEquals(layout.gridRows, 3)
  luaunit.assertEquals(layout.gridColumns, 4)
end

function TestLayoutEngineNew:testNewStoresDependencies()
  local layout = LayoutEngine.new({}, deps)
  luaunit.assertNotNil(layout._Grid)
  luaunit.assertNotNil(layout._Units)
  luaunit.assertNotNil(layout._Context)
  luaunit.assertNotNil(layout._ErrorHandler)
end

-- Test suite for LayoutEngine:initialize()
TestLayoutEngineInitialize = {}

function TestLayoutEngineInitialize:testInitialize()
  local layout = LayoutEngine.new({}, deps)
  local mockElement = { id = "test" }

  layout:initialize(mockElement)
  luaunit.assertEquals(layout.element, mockElement)
end

-- Test suite for LayoutEngine:calculateAutoWidth()
TestLayoutEngineAutoWidth = {}

function TestLayoutEngineAutoWidth:testAutoWidthNoElement()
  local layout = LayoutEngine.new({}, deps)
  local width = layout:calculateAutoWidth()
  luaunit.assertEquals(width, 0)
end

function TestLayoutEngineAutoWidth:testAutoWidthNoChildren()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
  }, deps)

  local mockElement = {
    children = {},
    calculateTextWidth = function()
      return 100
    end,
  }
  layout:initialize(mockElement)

  local width = layout:calculateAutoWidth()
  luaunit.assertEquals(width, 100) -- Just text width
end

function TestLayoutEngineAutoWidth:testAutoWidthHorizontalWithGap()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    gap = 10,
  }, deps)

  local mockChild1 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 50
    end,
  }
  local mockChild2 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 60
    end,
  }
  local mockChild3 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 70
    end,
  }

  local mockElement = {
    children = { mockChild1, mockChild2, mockChild3 },
    calculateTextWidth = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local width = layout:calculateAutoWidth()
  -- 50 + 60 + 70 = 180, plus 2 gaps (10 each) = 200
  luaunit.assertEquals(width, 200)
end

function TestLayoutEngineAutoWidth:testAutoWidthVerticalTakesMax()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 10,
  }, deps)

  local mockChild1 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 50
    end,
  }
  local mockChild2 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 150
    end,
  }
  local mockChild3 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 75
    end,
  }

  local mockElement = {
    children = { mockChild1, mockChild2, mockChild3 },
    calculateTextWidth = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local width = layout:calculateAutoWidth()
  -- Should take maximum width (150)
  luaunit.assertEquals(width, 150)
end

function TestLayoutEngineAutoWidth:testAutoWidthSkipsAbsoluteChildren()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    gap = 10,
  }, deps)

  local mockChild1 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 50
    end,
  }
  local mockChild2 = {
    _explicitlyAbsolute = true, -- Should be skipped
    getBorderBoxWidth = function()
      return 1000
    end,
  }
  local mockChild3 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 60
    end,
  }

  local mockElement = {
    children = { mockChild1, mockChild2, mockChild3 },
    calculateTextWidth = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local width = layout:calculateAutoWidth()
  -- 50 + 60 = 110, plus 1 gap (10) = 120 (mockChild2 is skipped)
  luaunit.assertEquals(width, 120)
end

-- Test suite for LayoutEngine:calculateAutoHeight()
TestLayoutEngineAutoHeight = {}

function TestLayoutEngineAutoHeight:testAutoHeightNoElement()
  local layout = LayoutEngine.new({}, deps)
  local height = layout:calculateAutoHeight()
  luaunit.assertEquals(height, 0)
end

function TestLayoutEngineAutoHeight:testAutoHeightNoChildren()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.VERTICAL,
  }, deps)

  local mockElement = {
    children = {},
    calculateTextHeight = function()
      return 50
    end,
  }
  layout:initialize(mockElement)

  local height = layout:calculateAutoHeight()
  luaunit.assertEquals(height, 50) -- Just text height
end

function TestLayoutEngineAutoHeight:testAutoHeightVerticalWithGap()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 5,
  }, deps)

  local mockChild1 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 30
    end,
  }
  local mockChild2 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 40
    end,
  }
  local mockChild3 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 50
    end,
  }

  local mockElement = {
    children = { mockChild1, mockChild2, mockChild3 },
    calculateTextHeight = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local height = layout:calculateAutoHeight()
  -- 30 + 40 + 50 = 120, plus 2 gaps (5 each) = 130
  luaunit.assertEquals(height, 130)
end

function TestLayoutEngineAutoHeight:testAutoHeightHorizontalTakesMax()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    gap = 5,
  }, deps)

  local mockChild1 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 30
    end,
  }
  local mockChild2 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 100
    end,
  }
  local mockChild3 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 50
    end,
  }

  local mockElement = {
    children = { mockChild1, mockChild2, mockChild3 },
    calculateTextHeight = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local height = layout:calculateAutoHeight()
  -- Should take maximum height (100)
  luaunit.assertEquals(height, 100)
end

function TestLayoutEngineAutoHeight:testAutoHeightSkipsAbsoluteChildren()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 5,
  }, deps)

  local mockChild1 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 30
    end,
  }
  local mockChild2 = {
    _explicitlyAbsolute = true, -- Should be skipped
    getBorderBoxHeight = function()
      return 1000
    end,
  }
  local mockChild3 = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 40
    end,
  }

  local mockElement = {
    children = { mockChild1, mockChild2, mockChild3 },
    calculateTextHeight = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local height = layout:calculateAutoHeight()
  -- 30 + 40 = 70, plus 1 gap (5) = 75 (mockChild2 is skipped)
  luaunit.assertEquals(height, 75)
end

-- Test suite for LayoutEngine:applyPositioningOffsets()
TestLayoutEnginePositioningOffsets = {}

function TestLayoutEnginePositioningOffsets:testApplyOffsetsNilChild()
  local layout = LayoutEngine.new({}, deps)
  -- Should not error
  layout:applyPositioningOffsets(nil)
end

function TestLayoutEnginePositioningOffsets:testApplyOffsetsNoParent()
  local layout = LayoutEngine.new({}, deps)
  local mockChild = {
    parent = nil,
    top = 10,
  }
  -- Should not error, just return early
  layout:applyPositioningOffsets(mockChild)
end

function TestLayoutEnginePositioningOffsets:testApplyTopOffset()
  local layout = LayoutEngine.new({}, deps)

  local mockParent = {
    x = 100,
    y = 200,
    padding = { left = 10, top = 20, right = 10, bottom = 20 },
  }

  local mockChild = {
    parent = mockParent,
    positioning = utils.enums.Positioning.ABSOLUTE,
    _explicitlyAbsolute = true,
    x = 0,
    y = 0,
    top = 30,
  }

  layout:applyPositioningOffsets(mockChild)
  -- y should be parent.y + parent.padding.top + top
  -- 200 + 20 + 30 = 250
  luaunit.assertEquals(mockChild.y, 250)
end

function TestLayoutEnginePositioningOffsets:testApplyLeftOffset()
  local layout = LayoutEngine.new({}, deps)

  local mockParent = {
    x = 100,
    y = 200,
    padding = { left = 10, top = 20, right = 10, bottom = 20 },
  }

  local mockChild = {
    parent = mockParent,
    positioning = utils.enums.Positioning.ABSOLUTE,
    _explicitlyAbsolute = true,
    x = 0,
    y = 0,
    left = 40,
  }

  layout:applyPositioningOffsets(mockChild)
  -- x should be parent.x + parent.padding.left + left
  -- 100 + 10 + 40 = 150
  luaunit.assertEquals(mockChild.x, 150)
end

function TestLayoutEnginePositioningOffsets:testApplyBottomOffset()
  local layout = LayoutEngine.new({}, deps)

  local mockParent = {
    x = 100,
    y = 200,
    width = 400,
    height = 300,
    padding = { left = 10, top = 20, right = 10, bottom = 20 },
  }

  local mockChild = {
    parent = mockParent,
    positioning = utils.enums.Positioning.ABSOLUTE,
    _explicitlyAbsolute = true,
    x = 0,
    y = 0,
    bottom = 50,
    getBorderBoxHeight = function()
      return 80
    end,
  }

  layout:applyPositioningOffsets(mockChild)
  -- y should be parent.y + parent.padding.top + parent.height - bottom - childHeight
  -- 200 + 20 + 300 - 50 - 80 = 390
  luaunit.assertEquals(mockChild.y, 390)
end

function TestLayoutEnginePositioningOffsets:testApplyRightOffset()
  local layout = LayoutEngine.new({}, deps)

  local mockParent = {
    x = 100,
    y = 200,
    width = 400,
    height = 300,
    padding = { left = 10, top = 20, right = 10, bottom = 20 },
  }

  local mockChild = {
    parent = mockParent,
    positioning = utils.enums.Positioning.ABSOLUTE,
    _explicitlyAbsolute = true,
    x = 0,
    y = 0,
    right = 60,
    getBorderBoxWidth = function()
      return 100
    end,
  }

  layout:applyPositioningOffsets(mockChild)
  -- x should be parent.x + parent.padding.left + parent.width - right - childWidth
  -- 100 + 10 + 400 - 60 - 100 = 350
  luaunit.assertEquals(mockChild.x, 350)
end

function TestLayoutEnginePositioningOffsets:testSkipsFlexChildren()
  local layout = LayoutEngine.new({}, deps)

  local mockParent = {
    x = 100,
    y = 200,
    padding = { left = 10, top = 20, right = 10, bottom = 20 },
  }

  local mockChild = {
    parent = mockParent,
    positioning = utils.enums.Positioning.ABSOLUTE,
    _explicitlyAbsolute = false, -- Participates in flex layout
    x = 500,
    y = 600,
    top = 30,
    left = 40,
  }

  layout:applyPositioningOffsets(mockChild)
  -- Should not apply offsets for flex children
  luaunit.assertEquals(mockChild.x, 500) -- Unchanged
  luaunit.assertEquals(mockChild.y, 600) -- Unchanged
end

-- Test suite for LayoutEngine:layoutChildren()
TestLayoutEngineLayoutChildren = {}

function TestLayoutEngineLayoutChildren:testLayoutChildrenNoElement()
  local layout = LayoutEngine.new({}, deps)
  -- Should not error
  layout:layoutChildren()
end

function TestLayoutEngineLayoutChildren:testLayoutChildrenNoChildren()
  local layout = LayoutEngine.new({}, deps)
  local mockElement = {
    children = {},
  }
  layout:initialize(mockElement)
  -- Should not error
  layout:layoutChildren()
end

function TestLayoutEngineLayoutChildren:testLayoutChildrenAbsolutePositioning()
  local layout = LayoutEngine.new({
    positioning = utils.enums.Positioning.ABSOLUTE,
  }, deps)

  local mockElement = {
    children = {},
    padding = { left = 0, top = 0, right = 0, bottom = 0 },
  }
  layout:initialize(mockElement)

  -- Should handle absolute positioning (doesn't layout children, just applies offsets)
  layout:layoutChildren()
end

function TestLayoutEngineLayoutChildren:testLayoutChildrenRelativePositioning()
  local layout = LayoutEngine.new({
    positioning = utils.enums.Positioning.RELATIVE,
  }, deps)

  local mockElement = {
    children = {},
    padding = { left = 0, top = 0, right = 0, bottom = 0 },
  }
  layout:initialize(mockElement)

  -- Should handle relative positioning (doesn't layout children, just applies offsets)
  layout:layoutChildren()
end

-- Edge cases
TestLayoutEngineEdgeCases = {}

function TestLayoutEngineEdgeCases:testAutoWidthWithZeroGap()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    gap = 0,
  }, deps)

  local mockChild1 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 50
    end,
  }
  local mockChild2 = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 60
    end,
  }

  local mockElement = {
    children = { mockChild1, mockChild2 },
    calculateTextWidth = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local width = layout:calculateAutoWidth()
  luaunit.assertEquals(width, 110) -- 50 + 60, no gaps
end

function TestLayoutEngineEdgeCases:testAutoHeightWithSingleChild()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 10,
  }, deps)

  local mockChild = {
    _explicitlyAbsolute = false,
    getBorderBoxHeight = function()
      return 100
    end,
  }

  local mockElement = {
    children = { mockChild },
    calculateTextHeight = function()
      return 0
    end,
  }
  layout:initialize(mockElement)

  local height = layout:calculateAutoHeight()
  luaunit.assertEquals(height, 100) -- No gaps with single child
end

function TestLayoutEngineEdgeCases:testAutoWidthWithTextAndChildren()
  local layout = LayoutEngine.new({
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    gap = 10,
  }, deps)

  local mockChild = {
    _explicitlyAbsolute = false,
    getBorderBoxWidth = function()
      return 50
    end,
  }

  local mockElement = {
    children = { mockChild },
    calculateTextWidth = function()
      return 100
    end, -- Has text
  }
  layout:initialize(mockElement)

  local width = layout:calculateAutoWidth()
  -- Text width (100) + child width (50) = 150
  luaunit.assertEquals(width, 150)
end

local Units = require("modules.Units")
local utils = require("modules.utils")

-- Mock dependencies
local mockContext = {
  getScaleFactors = function()
    return 1, 1
  end,
  baseScale = 1,
  _cachedViewport = { width = 1920, height = 1080 },
}

local mockErrorHandler = {
  error = function(module, msg) end,
  warn = function(module, msg) end,
}

local mockGrid = {
  layoutGridItems = function(element) end,
}

local deps = {
  utils = utils,
  Grid = mockGrid,
  Units = Units,
  Context = mockContext,
  ErrorHandler = mockErrorHandler,
}

-- Helper function to create mock element
local function createMockElement(props)
  return {
    id = props.id or "mock",
    x = props.x or 0,
    y = props.y or 0,
    width = props.width or 100,
    height = props.height or 100,
    absoluteX = props.absoluteX or 0,
    absoluteY = props.absoluteY or 0,
    marginLeft = props.marginLeft or 0,
    marginTop = props.marginTop or 0,
    marginRight = props.marginRight or 0,
    marginBottom = props.marginBottom or 0,
    children = props.children or {},
    parent = props.parent,
    isHidden = props.isHidden or false,
    flexGrow = props.flexGrow or 0,
    flexShrink = props.flexShrink or 1,
    flexBasis = props.flexBasis or "auto",
    alignSelf = props.alignSelf,
    minWidth = props.minWidth,
    maxWidth = props.maxWidth,
    minHeight = props.minHeight,
    maxHeight = props.maxHeight,
    text = props.text,
    _layout = nil,
    recalculateUnits = function() end,
    layoutChildren = function() end,
  }
end


-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
