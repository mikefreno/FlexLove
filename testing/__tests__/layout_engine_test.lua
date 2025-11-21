-- Comprehensive test suite for LayoutEngine.lua module
-- Consolidated from layout_engine_test.lua, layout_edge_cases_test.lua, 
-- overflow_test.lua, and transform_test.lua

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local LayoutEngine = require("modules.LayoutEngine")
local Units = require("modules.Units")
local utils = require("modules.utils")
local FlexLove = require("FlexLove")
local ErrorHandler = require("modules.ErrorHandler")
local Animation = require("modules.Animation")
local Transform = Animation.Transform

-- ============================================================================
-- Mock Dependencies
-- ============================================================================

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

-- ============================================================================
-- Test Suite 1: LayoutEngine Initialization and Constructor
-- ============================================================================

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

-- ============================================================================
-- Test Suite 2: LayoutEngine Initialization
-- ============================================================================

TestLayoutEngineInitialize = {}

function TestLayoutEngineInitialize:testInitialize()
  local layout = LayoutEngine.new({}, deps)
  local mockElement = { id = "test" }

  layout:initialize(mockElement)
  luaunit.assertEquals(layout.element, mockElement)
end

-- ============================================================================
-- Test Suite 3: Auto Width Calculation
-- ============================================================================

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

function TestLayoutEngineAutoWidth:testAutoWidthWithZeroGap()
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

function TestLayoutEngineAutoWidth:testAutoWidthWithTextAndChildren()
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

-- ============================================================================
-- Test Suite 4: Auto Height Calculation
-- ============================================================================

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

function TestLayoutEngineAutoHeight:testAutoHeightWithSingleChild()
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

-- ============================================================================
-- Test Suite 5: CSS Positioning Offsets
-- ============================================================================

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

-- ============================================================================
-- Test Suite 6: Layout Children
-- ============================================================================

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

-- ============================================================================
-- Test Suite 7: Layout Edge Cases and CSS Positioning (Immediate Mode)
-- ============================================================================

TestLayoutEdgeCases = {}

function TestLayoutEdgeCases:setUp()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  -- Capture warnings
  self.warnings = {}
  self.originalWarn = ErrorHandler.warn
  ErrorHandler.warn = function(module, message)
    table.insert(self.warnings, { module = module, message = message })
  end
end

function TestLayoutEdgeCases:tearDown()
  -- Restore original warn function
  ErrorHandler.warn = self.originalWarn
  FlexLove.endFrame()
end

-- Percentage sizing warnings (placeholders for future implementation)
function TestLayoutEdgeCases:test_percentage_width_with_auto_parent_warns()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    -- width not specified - auto-sizing width
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
  })

  FlexLove.new({
    id = "child_with_percentage",
    parent = container,
    width = "50%", -- Percentage width with auto-sizing parent - should warn
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Check that a warning was issued
  luaunit.assertTrue(#self.warnings > 0, "Should issue warning for percentage width with auto-sizing parent")

  -- Note: This warning feature is not yet implemented
  luaunit.assertTrue(true, "Placeholder - percentage width warning not implemented yet")
end

function TestLayoutEdgeCases:test_percentage_height_with_auto_parent_warns()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    -- height not specified - auto-sizing height
    positioning = "flex",
    flexDirection = "vertical",
  })

  FlexLove.new({
    id = "child_with_percentage",
    parent = container,
    width = 100,
    height = "50%", -- Percentage height with auto-sizing parent - should warn
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Check that a warning was issued
  luaunit.assertTrue(#self.warnings > 0, "Should issue warning for percentage height with auto-sizing parent")

  -- Note: This warning feature is not yet implemented
  luaunit.assertTrue(true, "Placeholder - percentage height warning not implemented yet")
end

function TestLayoutEdgeCases:test_pixel_width_with_auto_parent_no_warn()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    -- width not specified - auto-sizing
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
  })

  FlexLove.new({
    id = "child_with_pixels",
    parent = container,
    width = 100, -- Pixel width - should NOT warn
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Check that NO warning was issued about percentage sizing
  for _, warning in ipairs(self.warnings) do
    local hasPercentageWarning = warning.message:match("percentage") and warning.message:match("auto%-sizing")
    luaunit.assertFalse(hasPercentageWarning, "Should not warn for pixel-sized children")
  end
end

-- CSS positioning tests
function TestLayoutEdgeCases:test_css_positioning_top_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 50, -- 50px from top
    left = 0,
    width = 100,
    height = 100,
  })

  -- Trigger layout by ending and restarting frame
  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Child should be positioned 50px from container's top edge (accounting for padding)
  local expectedY = container.y + container.padding.top + 50
  luaunit.assertEquals(child.y, expectedY, "Child should be positioned with top offset")
end

function TestLayoutEdgeCases:test_css_positioning_bottom_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    bottom = 50, -- 50px from bottom
    left = 0,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Child should be positioned 50px from container's bottom edge
  local expectedY = container.y + container.padding.top + container.height - 50 - child:getBorderBoxHeight()
  luaunit.assertEquals(child.y, expectedY, "Child should be positioned with bottom offset")
end

function TestLayoutEdgeCases:test_css_positioning_left_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 0,
    left = 50, -- 50px from left
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Child should be positioned 50px from container's left edge
  local expectedX = container.x + container.padding.left + 50
  luaunit.assertEquals(child.x, expectedX, "Child should be positioned with left offset")
end

function TestLayoutEdgeCases:test_css_positioning_right_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 0,
    right = 50, -- 50px from right
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Child should be positioned 50px from container's right edge
  local expectedX = container.x + container.padding.left + container.width - 50 - child:getBorderBoxWidth()
  luaunit.assertEquals(child.x, expectedX, "Child should be positioned with right offset")
end

function TestLayoutEdgeCases:test_css_positioning_top_and_bottom()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 10,
    bottom = 20, -- Both specified - last one wins in current implementation
    left = 0,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Bottom should override top
  local expectedY = container.y + container.padding.top + container.height - 20 - child:getBorderBoxHeight()
  luaunit.assertEquals(child.y, expectedY, "Bottom offset should override top when both specified")
end

function TestLayoutEdgeCases:test_css_positioning_left_and_right()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 0,
    left = 10,
    right = 20, -- Both specified - last one wins in current implementation
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Right should override left
  local expectedX = container.x + container.padding.left + container.width - 20 - child:getBorderBoxWidth()
  luaunit.assertEquals(child.x, expectedX, "Right offset should override left when both specified")
end

function TestLayoutEdgeCases:test_css_positioning_with_padding()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
    positioning = "absolute",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 10,
    left = 10,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Offsets should be relative to content area (after padding)
  local expectedX = container.x + container.padding.left + 10
  local expectedY = container.y + container.padding.top + 10

  luaunit.assertEquals(child.x, expectedX, "Left offset should account for container padding")
  luaunit.assertEquals(child.y, expectedY, "Top offset should account for container padding")
end

function TestLayoutEdgeCases:test_css_positioning_ignored_in_flex()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "flex",
    flexDirection = "horizontal",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    top = 100, -- This should be IGNORED in flex layout
    left = 100, -- This should be IGNORED in flex layout
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- In flex layout, child should be positioned by flex rules, not CSS offsets
  -- Child should be at (0, 0) relative to container content area
  luaunit.assertEquals(child.x, 0, "CSS offsets should be ignored in flex layout")
  luaunit.assertEquals(child.y, 0, "CSS offsets should be ignored in flex layout")
end

function TestLayoutEdgeCases:test_css_positioning_in_relative_container()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "relative",
  })

  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 30,
    left = 30,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame()

  -- Should work the same as absolute container
  local expectedX = container.x + container.padding.left + 30
  local expectedY = container.y + container.padding.top + 30

  luaunit.assertEquals(child.x, expectedX, "CSS positioning should work in relative containers")
  luaunit.assertEquals(child.y, expectedY, "CSS positioning should work in relative containers")
end

-- ============================================================================
-- Test Suite 8: Overflow Detection and Scrolling
-- ============================================================================

TestOverflowDetection = {}

function TestOverflowDetection:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestOverflowDetection:tearDown()
  FlexLove.endFrame()
end

function TestOverflowDetection:test_vertical_overflow_detected()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    overflow = "scroll",
  })

  -- Add child that exceeds container height
  FlexLove.new({
    id = "tall_child",
    parent = container,
    x = 0,
    y = 0,
    width = 100,
    height = 200, -- Taller than container (100)
  })

  -- Force layout to trigger detectOverflow
  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  -- Check if overflow was detected
  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertTrue(maxScrollY > 0, "Should detect vertical overflow")
  luaunit.assertEquals(maxScrollX, 0, "Should not have horizontal overflow")
end

function TestOverflowDetection:test_horizontal_overflow_detected()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 100,
    height = 200,
    overflow = "scroll",
  })

  -- Add child that exceeds container width
  FlexLove.new({
    id = "wide_child",
    parent = container,
    x = 0,
    y = 0,
    width = 300, -- Wider than container (100)
    height = 50,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertTrue(maxScrollX > 0, "Should detect horizontal overflow")
  luaunit.assertEquals(maxScrollY, 0, "Should not have vertical overflow")
end

function TestOverflowDetection:test_both_axes_overflow()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    overflow = "scroll",
  })

  -- Add child that exceeds both dimensions
  FlexLove.new({
    id = "large_child",
    parent = container,
    x = 0,
    y = 0,
    width = 200,
    height = 200,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertTrue(maxScrollX > 0, "Should detect horizontal overflow")
  luaunit.assertTrue(maxScrollY > 0, "Should detect vertical overflow")
end

function TestOverflowDetection:test_no_overflow_when_content_fits()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
  })

  -- Add child that fits within container
  FlexLove.new({
    id = "small_child",
    parent = container,
    x = 0,
    y = 0,
    width = 100,
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertEquals(maxScrollX, 0, "Should not have horizontal overflow")
  luaunit.assertEquals(maxScrollY, 0, "Should not have vertical overflow")
end

function TestOverflowDetection:test_overflow_with_multiple_children()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    positioning = "flex",
    flexDirection = "vertical",
  })

  -- Add multiple children that together exceed container
  for i = 1, 5 do
    FlexLove.new({
      id = "child_" .. i,
      parent = container,
      width = 150,
      height = 60, -- 5 * 60 = 300, exceeds container height of 200
    })
  end

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertTrue(maxScrollY > 0, "Should detect overflow from multiple children")
end

function TestOverflowDetection:test_overflow_with_padding()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
    overflow = "scroll",
  })

  -- Child that fits in container but exceeds available content area (200 - 20 = 180)
  FlexLove.new({
    id = "child",
    parent = container,
    x = 0,
    y = 0,
    width = 190, -- Exceeds content width (180)
    height = 100,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertTrue(maxScrollX > 0, "Should detect overflow accounting for padding")
end

function TestOverflowDetection:test_overflow_with_margins()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    overflow = "scroll",
  })

  -- Child with margins that contribute to overflow
  -- In flex layout, margins are properly accounted for in positioning
  FlexLove.new({
    id = "child",
    parent = container,
    width = 180,
    height = 180,
    margin = { top = 5, right = 20, bottom = 5, left = 5 }, -- Total width: 5+180+20=205, overflows 200px container
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertTrue(maxScrollX > 0, "Should include child margins in overflow calculation")
end

function TestOverflowDetection:test_visible_overflow_skips_detection()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    overflow = "visible", -- Should not clip or calculate overflow
  })

  -- Add oversized child
  FlexLove.new({
    id = "large_child",
    parent = container,
    x = 0,
    y = 0,
    width = 300,
    height = 300,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  -- With overflow="visible", maxScroll should be 0 (no scrolling)
  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertEquals(maxScrollX, 0, "visible overflow should not enable scrolling")
  luaunit.assertEquals(maxScrollY, 0, "visible overflow should not enable scrolling")
end

function TestOverflowDetection:test_empty_container_no_overflow()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
    -- No children
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  luaunit.assertEquals(maxScrollX, 0, "Empty container should have no overflow")
  luaunit.assertEquals(maxScrollY, 0, "Empty container should have no overflow")
end

function TestOverflowDetection:test_absolute_children_ignored_in_overflow()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    height = 200,
    overflow = "scroll",
  })

  -- Regular child that fits
  FlexLove.new({
    id = "normal_child",
    parent = container,
    x = 0,
    y = 0,
    width = 150,
    height = 150,
  })

  -- Absolutely positioned child that extends beyond (should NOT cause overflow)
  FlexLove.new({
    id = "absolute_child",
    parent = container,
    positioning = "absolute",
    top = 0,
    left = 0,
    width = 400,
    height = 400,
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  local maxScrollX, maxScrollY = container:getMaxScroll()
  -- Should not have overflow because absolute children are ignored
  luaunit.assertEquals(maxScrollX, 0, "Absolute children should not cause overflow")
  luaunit.assertEquals(maxScrollY, 0, "Absolute children should not cause overflow")
end

function TestOverflowDetection:test_scroll_clamped_to_max()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    overflow = "scroll",
  })

  FlexLove.new({
    id = "child",
    parent = container,
    x = 0,
    y = 0,
    width = 100,
    height = 300, -- Creates 200px of vertical overflow
  })

  FlexLove.endFrame()
  FlexLove.beginFrame(1920, 1080)

  -- Try to scroll beyond max
  container:setScrollPosition(0, 999999)
  local scrollX, scrollY = container:getScrollPosition()
  local maxScrollX, maxScrollY = container:getMaxScroll()

  luaunit.assertEquals(scrollY, maxScrollY, "Scroll should be clamped to maximum")
  luaunit.assertTrue(scrollY < 999999, "Should not scroll beyond content")
end

-- ============================================================================
-- Test Suite 9: Transform (from Animation module)
-- ============================================================================

TestTransform = {}

function TestTransform:setUp()
  -- Reset state before each test
end

-- Transform.new() tests
function TestTransform:testNew_DefaultValues()
  local transform = Transform.new()

  luaunit.assertNotNil(transform)
  luaunit.assertEquals(transform.rotate, 0)
  luaunit.assertEquals(transform.scaleX, 1)
  luaunit.assertEquals(transform.scaleY, 1)
  luaunit.assertEquals(transform.translateX, 0)
  luaunit.assertEquals(transform.translateY, 0)
  luaunit.assertEquals(transform.skewX, 0)
  luaunit.assertEquals(transform.skewY, 0)
  luaunit.assertEquals(transform.originX, 0.5)
  luaunit.assertEquals(transform.originY, 0.5)
end

function TestTransform:testNew_CustomValues()
  local transform = Transform.new({
    rotate = math.pi / 4,
    scaleX = 2,
    scaleY = 3,
    translateX = 100,
    translateY = 200,
    skewX = 0.1,
    skewY = 0.2,
    originX = 0,
    originY = 1,
  })

  luaunit.assertAlmostEquals(transform.rotate, math.pi / 4, 0.01)
  luaunit.assertEquals(transform.scaleX, 2)
  luaunit.assertEquals(transform.scaleY, 3)
  luaunit.assertEquals(transform.translateX, 100)
  luaunit.assertEquals(transform.translateY, 200)
  luaunit.assertAlmostEquals(transform.skewX, 0.1, 0.01)
  luaunit.assertAlmostEquals(transform.skewY, 0.2, 0.01)
  luaunit.assertEquals(transform.originX, 0)
  luaunit.assertEquals(transform.originY, 1)
end

function TestTransform:testNew_PartialValues()
  local transform = Transform.new({
    rotate = math.pi,
    scaleX = 2,
  })

  luaunit.assertAlmostEquals(transform.rotate, math.pi, 0.01)
  luaunit.assertEquals(transform.scaleX, 2)
  luaunit.assertEquals(transform.scaleY, 1) -- default
  luaunit.assertEquals(transform.translateX, 0) -- default
end

function TestTransform:testNew_EmptyProps()
  local transform = Transform.new({})

  -- Should use all defaults
  luaunit.assertEquals(transform.rotate, 0)
  luaunit.assertEquals(transform.scaleX, 1)
  luaunit.assertEquals(transform.originX, 0.5)
end

function TestTransform:testNew_NilProps()
  local transform = Transform.new(nil)

  -- Should use all defaults
  luaunit.assertEquals(transform.rotate, 0)
  luaunit.assertEquals(transform.scaleX, 1)
end

-- Transform.lerp() tests
function TestTransform:testLerp_MidPoint()
  local from = Transform.new({ rotate = 0, scaleX = 1, scaleY = 1 })
  local to = Transform.new({ rotate = math.pi, scaleX = 2, scaleY = 3 })

  local result = Transform.lerp(from, to, 0.5)

  luaunit.assertAlmostEquals(result.rotate, math.pi / 2, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 1.5, 0.01)
  luaunit.assertAlmostEquals(result.scaleY, 2, 0.01)
end

function TestTransform:testLerp_StartPoint()
  local from = Transform.new({ rotate = 0, scaleX = 1 })
  local to = Transform.new({ rotate = math.pi, scaleX = 2 })

  local result = Transform.lerp(from, to, 0)

  luaunit.assertAlmostEquals(result.rotate, 0, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 1, 0.01)
end

function TestTransform:testLerp_EndPoint()
  local from = Transform.new({ rotate = 0, scaleX = 1 })
  local to = Transform.new({ rotate = math.pi, scaleX = 2 })

  local result = Transform.lerp(from, to, 1)

  luaunit.assertAlmostEquals(result.rotate, math.pi, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 2, 0.01)
end

function TestTransform:testLerp_AllProperties()
  local from = Transform.new({
    rotate = 0,
    scaleX = 1,
    scaleY = 1,
    translateX = 0,
    translateY = 0,
    skewX = 0,
    skewY = 0,
    originX = 0,
    originY = 0,
  })

  local to = Transform.new({
    rotate = math.pi,
    scaleX = 2,
    scaleY = 3,
    translateX = 100,
    translateY = 200,
    skewX = 0.2,
    skewY = 0.4,
    originX = 1,
    originY = 1,
  })

  local result = Transform.lerp(from, to, 0.5)

  luaunit.assertAlmostEquals(result.rotate, math.pi / 2, 0.01)
  luaunit.assertAlmostEquals(result.scaleX, 1.5, 0.01)
  luaunit.assertAlmostEquals(result.scaleY, 2, 0.01)
  luaunit.assertAlmostEquals(result.translateX, 50, 0.01)
  luaunit.assertAlmostEquals(result.translateY, 100, 0.01)
  luaunit.assertAlmostEquals(result.skewX, 0.1, 0.01)
  luaunit.assertAlmostEquals(result.skewY, 0.2, 0.01)
  luaunit.assertAlmostEquals(result.originX, 0.5, 0.01)
  luaunit.assertAlmostEquals(result.originY, 0.5, 0.01)
end

function TestTransform:testLerp_InvalidInputs()
  -- Should handle nil gracefully
  local result = Transform.lerp(nil, nil, 0.5)

  luaunit.assertNotNil(result)
  luaunit.assertEquals(result.rotate, 0)
  luaunit.assertEquals(result.scaleX, 1)
end

function TestTransform:testLerp_ClampT()
  local from = Transform.new({ scaleX = 1 })
  local to = Transform.new({ scaleX = 2 })

  -- Test t > 1
  local result1 = Transform.lerp(from, to, 1.5)
  luaunit.assertAlmostEquals(result1.scaleX, 2, 0.01)

  -- Test t < 0
  local result2 = Transform.lerp(from, to, -0.5)
  luaunit.assertAlmostEquals(result2.scaleX, 1, 0.01)
end

function TestTransform:testLerp_InvalidT()
  local from = Transform.new({ scaleX = 1 })
  local to = Transform.new({ scaleX = 2 })

  -- Test NaN
  local result1 = Transform.lerp(from, to, 0 / 0)
  luaunit.assertAlmostEquals(result1.scaleX, 1, 0.01) -- Should default to 0

  -- Test Infinity
  local result2 = Transform.lerp(from, to, math.huge)
  luaunit.assertAlmostEquals(result2.scaleX, 2, 0.01) -- Should clamp to 1
end

-- Transform.isIdentity() tests
function TestTransform:testIsIdentity_True()
  local transform = Transform.new()
  luaunit.assertTrue(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_Nil()
  luaunit.assertTrue(Transform.isIdentity(nil))
end

function TestTransform:testIsIdentity_FalseRotate()
  local transform = Transform.new({ rotate = 0.1 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_FalseScale()
  local transform = Transform.new({ scaleX = 2 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_FalseTranslate()
  local transform = Transform.new({ translateX = 10 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

function TestTransform:testIsIdentity_FalseSkew()
  local transform = Transform.new({ skewX = 0.1 })
  luaunit.assertFalse(Transform.isIdentity(transform))
end

-- Transform.clone() tests
function TestTransform:testClone_AllProperties()
  local original = Transform.new({
    rotate = math.pi / 4,
    scaleX = 2,
    scaleY = 3,
    translateX = 100,
    translateY = 200,
    skewX = 0.1,
    skewY = 0.2,
    originX = 0.25,
    originY = 0.75,
  })

  local clone = Transform.clone(original)

  luaunit.assertAlmostEquals(clone.rotate, math.pi / 4, 0.01)
  luaunit.assertEquals(clone.scaleX, 2)
  luaunit.assertEquals(clone.scaleY, 3)
  luaunit.assertEquals(clone.translateX, 100)
  luaunit.assertEquals(clone.translateY, 200)
  luaunit.assertAlmostEquals(clone.skewX, 0.1, 0.01)
  luaunit.assertAlmostEquals(clone.skewY, 0.2, 0.01)
  luaunit.assertAlmostEquals(clone.originX, 0.25, 0.01)
  luaunit.assertAlmostEquals(clone.originY, 0.75, 0.01)

  -- Ensure it's a different object (use raw comparison)
  luaunit.assertFalse(rawequal(clone, original), "Clone should be a different table instance")
end

function TestTransform:testClone_Nil()
  local clone = Transform.clone(nil)

  luaunit.assertNotNil(clone)
  luaunit.assertEquals(clone.rotate, 0)
  luaunit.assertEquals(clone.scaleX, 1)
end

function TestTransform:testClone_Mutation()
  local original = Transform.new({ rotate = 0 })
  local clone = Transform.clone(original)

  -- Mutate clone
  clone.rotate = math.pi

  -- Original should be unchanged
  luaunit.assertEquals(original.rotate, 0)
  luaunit.assertAlmostEquals(clone.rotate, math.pi, 0.01)
end

-- Integration tests
function TestTransform:testTransformAnimation()
  local anim = Animation.new({
    duration = 1,
    start = { transform = Transform.new({ rotate = 0, scaleX = 1 }) },
    final = { transform = Transform.new({ rotate = math.pi, scaleX = 2 }) },
  })

  anim:update(0.5)

  local result = anim:interpolate()

  luaunit.assertNotNil(result.transform)
  luaunit.assertAlmostEquals(result.transform.rotate, math.pi / 2, 0.01)
  luaunit.assertAlmostEquals(result.transform.scaleX, 1.5, 0.01)
end

-- ============================================================================
-- Run Tests
-- ============================================================================

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
