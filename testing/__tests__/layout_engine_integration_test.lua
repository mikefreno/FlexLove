-- Integration tests for LayoutEngine.lua
-- Tests actual layout calculations with mock element structures

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

-- Test suite for layoutChildren with flex layout
TestLayoutChildrenFlex = {}

function TestLayoutChildrenFlex:test_layoutChildren_horizontal_flex_start()
  local props = {
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    justifyContent = utils.enums.JustifyContent.FLEX_START,
    alignItems = utils.enums.AlignItems.FLEX_START,
    gap = 10,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    width = 300,
    height = 100,
  })

  local child1 = createMockElement({
    id = "child1",
    width = 50,
    height = 30,
    parent = parent,
  })

  local child2 = createMockElement({
    id = "child2",
    width = 60,
    height = 40,
    parent = parent,
  })

  parent.children = { child1, child2 }
  parent._layout = layout

  layout:initialize(parent)
  layout:layoutChildren()

  -- Verify layout was calculated (children positions should be set)
  -- Child1 should be at (0, 0)
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, 0)

  -- Child2 should be at (50 + gap, 0) = (60, 0)
  luaunit.assertEquals(child2.x, 60)
  luaunit.assertEquals(child2.y, 0)
end

function TestLayoutChildrenFlex:test_layoutChildren_vertical_flex_start()
  local props = {
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    justifyContent = utils.enums.JustifyContent.FLEX_START,
    alignItems = utils.enums.AlignItems.FLEX_START,
    gap = 5,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    width = 100,
    height = 200,
  })

  local child1 = createMockElement({
    id = "child1",
    width = 50,
    height = 30,
    parent = parent,
  })

  local child2 = createMockElement({
    id = "child2",
    width = 60,
    height = 40,
    parent = parent,
  })

  parent.children = { child1, child2 }
  parent._layout = layout

  layout:initialize(parent)
  layout:layoutChildren()

  -- Verify layout was calculated
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, 0)

  -- Child2 should be below child1 with gap
  luaunit.assertEquals(child2.x, 0)
  luaunit.assertEquals(child2.y, 35) -- 30 + 5
end

function TestLayoutChildrenFlex:test_layoutChildren_with_margins()
  local props = {
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    justifyContent = utils.enums.JustifyContent.FLEX_START,
    gap = 0,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    width = 300,
    height = 100,
  })

  local child1 = createMockElement({
    id = "child1",
    width = 50,
    height = 30,
    marginLeft = 10,
    marginRight = 5,
    parent = parent,
  })

  parent.children = { child1 }
  parent._layout = layout

  layout:initialize(parent)
  layout:layoutChildren()

  -- Child should be offset by left margin
  luaunit.assertEquals(child1.x, 10)
end

function TestLayoutChildrenFlex:test_layoutChildren_with_hidden_children()
  local props = {
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    gap = 10,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    width = 300,
    height = 100,
  })

  local child1 = createMockElement({
    id = "child1",
    width = 50,
    height = 30,
    parent = parent,
  })

  local child2 = createMockElement({
    id = "child2",
    width = 60,
    height = 40,
    isHidden = true,
    parent = parent,
  })

  local child3 = createMockElement({
    id = "child3",
    width = 70,
    height = 35,
    parent = parent,
  })

  parent.children = { child1, child2, child3 }
  parent._layout = layout

  layout:initialize(parent)
  layout:layoutChildren()

  -- Child2 should be skipped, so child3 should be positioned after child1
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child3.x, 60) -- 50 + gap (10)
end

function TestLayoutChildrenFlex:test_layoutChildren_center()
  local props = {
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    justifyContent = utils.enums.JustifyContent.CENTER,
    alignItems = utils.enums.AlignItems.CENTER,
    gap = 10,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    width = 300,
    height = 100,
  })

  local child1 = createMockElement({
    id = "child1",
    width = 50,
    height = 30,
    parent = parent,
  })

  local child2 = createMockElement({
    id = "child2",
    width = 60,
    height = 40,
    parent = parent,
  })

  parent.children = { child1, child2 }
  parent._layout = layout

  layout:initialize(parent)
  layout:layoutChildren()

  -- Children should be centered
  -- Total width needed: 50 + 10 + 60 = 120
  -- Remaining space: 300 - 120 = 180
  -- Center offset: 180 / 2 = 90
  luaunit.assertEquals(child1.x, 90)
  luaunit.assertEquals(child2.x, 150) -- 90 + 50 + 10

  -- Vertical centering
  -- Child1 height 30, container 100, offset = (100-30)/2 = 35
  luaunit.assertEquals(child1.y, 35)
  -- Child2 height 40, offset = (100-40)/2 = 30
  luaunit.assertEquals(child2.y, 30)
end

function TestLayoutChildrenFlex:test_layoutChildren_space_between()
  local props = {
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.HORIZONTAL,
    justifyContent = utils.enums.JustifyContent.SPACE_BETWEEN,
    gap = 0,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    width = 300,
    height = 100,
  })

  local child1 = createMockElement({
    id = "child1",
    width = 50,
    height = 30,
    parent = parent,
  })

  local child2 = createMockElement({
    id = "child2",
    width = 60,
    height = 40,
    parent = parent,
  })

  parent.children = { child1, child2 }
  parent._layout = layout

  layout:initialize(parent)
  layout:layoutChildren()

  -- First child at start
  luaunit.assertEquals(child1.x, 0)

  -- Last child at end: 300 - 60 = 240
  luaunit.assertEquals(child2.x, 240)
end

-- Test suite for applyPositioningOffsets
TestApplyPositioningOffsets = {}

function TestApplyPositioningOffsets:test_applyPositioningOffsets_relative()
  local props = {
    positioning = utils.enums.Positioning.FLEX,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    x = 100,
    y = 50,
  })

  local child = createMockElement({
    id = "child",
    x = 20,
    y = 30,
    parent = parent,
  })

  layout:initialize(parent)
  layout:applyPositioningOffsets(child)

  -- Relative positioning: child keeps its x, y
  luaunit.assertEquals(child.x, 20)
  luaunit.assertEquals(child.y, 30)
end

function TestApplyPositioningOffsets:test_applyPositioningOffsets_absolute()
  local props = {
    positioning = utils.enums.Positioning.ABSOLUTE,
  }
  local layout = LayoutEngine.new(props, deps)

  local parent = createMockElement({
    id = "parent",
    absoluteX = 100,
    absoluteY = 50,
    width = 300,
    height = 200,
  })

  local child = createMockElement({
    id = "child",
    x = 20,
    y = 30,
    parent = parent,
  })

  layout:initialize(parent)
  layout:applyPositioningOffsets(child)

  -- Absolute positioning: child.x, child.y are relative to parent
  luaunit.assertEquals(child.absoluteX, 120) -- 100 + 20
  luaunit.assertEquals(child.absoluteY, 80) -- 50 + 30
end

-- Test suite for grid layout
TestLayoutChildrenGrid = {}

function TestLayoutChildrenGrid:test_layoutChildren_grid_delegates_to_Grid()
  local gridCalled = false
  local mockGridForTest = {
    layoutGridItems = function(element)
      gridCalled = true
    end,
  }

  local depsWithMockGrid = {
    utils = utils,
    Grid = mockGridForTest,
    Units = Units,
    Context = mockContext,
    ErrorHandler = mockErrorHandler,
  }

  local props = {
    positioning = utils.enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
  }
  local layout = LayoutEngine.new(props, depsWithMockGrid)

  local parent = createMockElement({
    id = "parent",
    width = 300,
    height = 200,
  })

  parent._layout = layout
  layout:initialize(parent)
  layout:layoutChildren()

  -- Verify Grid.layoutGridItems was called
  luaunit.assertTrue(gridCalled)
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
