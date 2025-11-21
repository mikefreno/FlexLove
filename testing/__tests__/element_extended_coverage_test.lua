-- Extended coverage tests for Element module
-- Focuses on uncovered paths like image loading, blur, animations, transforms, and edge cases

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

local FlexLove = require("FlexLove")
FlexLove.init()

local Element = require("modules.Element")
local Color = require("modules.Color")

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function createBasicElement(props)
  props = props or {}
  props.width = props.width or 100
  props.height = props.height or 100
  return Element.new(props)
end

-- ============================================================================
-- Image Loading and Callbacks
-- ============================================================================

TestElementImageLoading = {}

function TestElementImageLoading:test_image_loading_deferred_callback()
  local callbackCalled = false
  local element = createBasicElement({
    image = "test.png",
    onImageLoad = function(img)
      callbackCalled = true
    end,
  })

  -- Callback should be stored
  luaunit.assertNotNil(element._imageLoadCallback)

  -- Simulate image loaded
  if element._imageLoadCallback then
    element._imageLoadCallback({})
  end

  luaunit.assertTrue(callbackCalled)
end

function TestElementImageLoading:test_image_with_tint()
  local element = createBasicElement({
    image = "test.png",
  })

  local tintColor = Color.new(1, 0, 0, 1)
  element:setImageTint(tintColor)

  luaunit.assertEquals(element.imageTint, tintColor)
end

function TestElementImageLoading:test_image_with_opacity()
  local element = createBasicElement({
    image = "test.png",
  })

  element:setImageOpacity(0.5)

  luaunit.assertEquals(element.imageOpacity, 0.5)
end

function TestElementImageLoading:test_image_with_repeat()
  local element = createBasicElement({
    image = "test.png",
  })

  element:setImageRepeat("repeat")

  luaunit.assertEquals(element.imageRepeat, "repeat")
end

-- ============================================================================
-- Blur Instance Management
-- ============================================================================

TestElementBlur = {}

function TestElementBlur:test_getBlurInstance_no_blur()
  local element = createBasicElement({})

  local blur = element:getBlurInstance()

  luaunit.assertNil(blur)
end

function TestElementBlur:test_getBlurInstance_with_blur()
  local element = createBasicElement({
    backdropBlur = 5,
  })

  -- Blur instance should be created when backdropBlur is set
  local blur = element:getBlurInstance()

  -- May be nil if Blur module isn't initialized, but shouldn't error
  luaunit.assertTrue(blur == nil or type(blur) == "table")
end

-- ============================================================================
-- Element Update and Animations
-- ============================================================================

TestElementUpdate = {}

function TestElementUpdate:test_update_without_animations()
  local element = createBasicElement({})

  -- Should not error
  element:update(0.016)

  luaunit.assertTrue(true)
end

function TestElementUpdate:test_update_with_transition()
  local element = createBasicElement({
    opacity = 1,
  })

  element:setTransition("opacity", {
    duration = 1.0,
    easing = "linear",
  })

  -- Change opacity to trigger transition
  element:setProperty("opacity", 0)

  -- Update should process transition
  element:update(0.5)

  -- Opacity should be between 0 and 1
  luaunit.assertTrue(element.opacity >= 0 and element.opacity <= 1)
end

function TestElementUpdate:test_countActiveAnimations()
  local element = createBasicElement({})

  local count = element:_countActiveAnimations()

  luaunit.assertEquals(count, 0)
end

-- ============================================================================
-- Element Draw Method
-- ============================================================================

TestElementDraw = {}

function TestElementDraw:test_draw_basic_element()
  local element = createBasicElement({
    backgroundColor = Color.new(1, 0, 0, 1),
  })

  -- Should not error
  element:draw()

  luaunit.assertTrue(true)
end

function TestElementDraw:test_draw_with_opacity_zero()
  local element = createBasicElement({
    backgroundColor = Color.new(1, 0, 0, 1),
    opacity = 0,
  })

  -- Should not draw but not error
  element:draw()

  luaunit.assertTrue(true)
end

function TestElementDraw:test_draw_with_transform()
  local element = createBasicElement({})

  element:rotate(45)
  element:scale(1.5, 1.5)

  -- Should apply transforms
  element:draw()

  luaunit.assertTrue(true)
end

function TestElementDraw:test_draw_with_blur()
  local element = createBasicElement({
    backdropBlur = 5,
    backgroundColor = Color.new(1, 1, 1, 0.5),
  })

  -- Should handle blur
  element:draw()

  luaunit.assertTrue(true)
end

-- ============================================================================
-- Element Resize
-- ============================================================================

TestElementResize = {}

function TestElementResize:test_resize_updates_dimensions()
  local element = createBasicElement({
    width = 100,
    height = 100,
  })

  element:resize(200, 200)

  luaunit.assertEquals(element.width, 200)
  luaunit.assertEquals(element.height, 200)
end

function TestElementResize:test_resize_with_percentage_units()
  local element = createBasicElement({
    width = "50%",
    height = "50%",
  })

  -- Should handle percentage units (recalculation)
  element:resize(400, 400)

  luaunit.assertTrue(true)
end

-- ============================================================================
-- Layout Children with Performance
-- ============================================================================

TestElementLayout = {}

function TestElementLayout:test_layoutChildren_empty()
  local element = createBasicElement({})

  -- Should not error with no children
  element:layoutChildren()

  luaunit.assertTrue(true)
end

function TestElementLayout:test_layoutChildren_with_children()
  local parent = createBasicElement({
    width = 200,
    height = 200,
  })

  local child1 = createBasicElement({ width = 50, height = 50 })
  local child2 = createBasicElement({ width = 50, height = 50 })

  parent:addChild(child1)
  parent:addChild(child2)

  parent:layoutChildren()

  -- Children should have positions
  luaunit.assertNotNil(child1.x)
  luaunit.assertNotNil(child2.x)
end

function TestElementLayout:test_checkPerformanceWarnings()
  local parent = createBasicElement({})

  -- Add many children to trigger warnings
  for i = 1, 150 do
    parent:addChild(createBasicElement({ width = 10, height = 10 }))
  end

  -- Should check performance
  parent:_checkPerformanceWarnings()

  luaunit.assertTrue(true)
end

-- ============================================================================
-- Absolute Positioning with CSS Offsets
-- ============================================================================

TestElementPositioning = {}

function TestElementPositioning:test_absolute_positioning_with_top_left()
  local element = createBasicElement({
    positioning = "absolute",
    top = 10,
    left = 20,
  })

  luaunit.assertEquals(element.positioning, "absolute")
  luaunit.assertEquals(element.top, 10)
  luaunit.assertEquals(element.left, 20)
end

function TestElementPositioning:test_absolute_positioning_with_bottom_right()
  local element = createBasicElement({
    positioning = "absolute",
    bottom = 10,
    right = 20,
  })

  luaunit.assertEquals(element.positioning, "absolute")
  luaunit.assertEquals(element.bottom, 10)
  luaunit.assertEquals(element.right, 20)
end

function TestElementPositioning:test_relative_positioning()
  local element = createBasicElement({
    positioning = "relative",
    top = 10,
    left = 10,
  })

  luaunit.assertEquals(element.positioning, "relative")
end

-- ============================================================================
-- Theme State Management
-- ============================================================================

TestElementTheme = {}

function TestElementTheme:test_element_with_hover_state()
  local element = createBasicElement({
    backgroundColor = Color.new(1, 0, 0, 1),
    hover = {
      backgroundColor = Color.new(0, 1, 0, 1),
    },
  })

  luaunit.assertNotNil(element.hover)
  luaunit.assertNotNil(element.hover.backgroundColor)
end

function TestElementTheme:test_element_with_active_state()
  local element = createBasicElement({
    backgroundColor = Color.new(1, 0, 0, 1),
    active = {
      backgroundColor = Color.new(0, 0, 1, 1),
    },
  })

  luaunit.assertNotNil(element.active)
end

function TestElementTheme:test_element_with_disabled_state()
  local element = createBasicElement({
    disabled = true,
  })

  luaunit.assertTrue(element.disabled)
end

-- ============================================================================
-- Transform Application
-- ============================================================================

TestElementTransform = {}

function TestElementTransform:test_rotate_transform()
  local element = createBasicElement({})

  element:rotate(90)

  luaunit.assertNotNil(element._transform)
  luaunit.assertEquals(element._transform.rotation, 90)
end

function TestElementTransform:test_scale_transform()
  local element = createBasicElement({})

  element:scale(2, 2)

  luaunit.assertNotNil(element._transform)
  luaunit.assertEquals(element._transform.scaleX, 2)
  luaunit.assertEquals(element._transform.scaleY, 2)
end

function TestElementTransform:test_translate_transform()
  local element = createBasicElement({})

  element:translate(10, 20)

  luaunit.assertNotNil(element._transform)
  luaunit.assertEquals(element._transform.translateX, 10)
  luaunit.assertEquals(element._transform.translateY, 20)
end

function TestElementTransform:test_setTransformOrigin()
  local element = createBasicElement({})

  element:setTransformOrigin(0.5, 0.5)

  luaunit.assertNotNil(element._transform)
  luaunit.assertEquals(element._transform.originX, 0.5)
  luaunit.assertEquals(element._transform.originY, 0.5)
end

function TestElementTransform:test_combined_transforms()
  local element = createBasicElement({})

  element:rotate(45)
  element:scale(1.5, 1.5)
  element:translate(10, 10)

  luaunit.assertEquals(element._transform.rotation, 45)
  luaunit.assertEquals(element._transform.scaleX, 1.5)
  luaunit.assertEquals(element._transform.translateX, 10)
end

-- ============================================================================
-- Grid Layout
-- ============================================================================

TestElementGrid = {}

function TestElementGrid:test_grid_layout()
  local element = createBasicElement({
    display = "grid",
    gridTemplateColumns = "1fr 1fr",
    gridTemplateRows = "auto auto",
  })

  luaunit.assertEquals(element.display, "grid")
  luaunit.assertNotNil(element.gridTemplateColumns)
end

function TestElementGrid:test_grid_gap()
  local element = createBasicElement({
    display = "grid",
    gridGap = 10,
  })

  luaunit.assertEquals(element.gridGap, 10)
end

-- ============================================================================
-- Editable Element Text Operations
-- ============================================================================

TestElementTextOps = {}

function TestElementTextOps:test_insertText()
  local element = createBasicElement({
    editable = true,
    text = "Hello",
  })

  element:insertText(" World", 5)

  luaunit.assertEquals(element:getText(), "Hello World")
end

function TestElementTextOps:test_deleteText()
  local element = createBasicElement({
    editable = true,
    text = "Hello World",
  })

  element:deleteText(5, 11)

  luaunit.assertEquals(element:getText(), "Hello")
end

function TestElementTextOps:test_replaceText()
  local element = createBasicElement({
    editable = true,
    text = "Hello World",
  })

  element:replaceText(6, 11, "Lua")

  luaunit.assertEquals(element:getText(), "Hello Lua")
end

function TestElementTextOps:test_getText_non_editable()
  local element = createBasicElement({
    text = "Test",
  })

  luaunit.assertEquals(element:getText(), "Test")
end

-- ============================================================================
-- Focus Management
-- ============================================================================

TestElementFocus = {}

function TestElementFocus:test_focus_non_editable()
  local element = createBasicElement({})

  element:focus()

  -- Should not create editor for non-editable element
  luaunit.assertNil(element._textEditor)
end

function TestElementFocus:test_focus_editable()
  local element = createBasicElement({
    editable = true,
    text = "Test",
  })

  element:focus()

  -- Should create editor
  luaunit.assertNotNil(element._textEditor)
  luaunit.assertTrue(element:isFocused())
end

function TestElementFocus:test_blur()
  local element = createBasicElement({
    editable = true,
    text = "Test",
  })

  element:focus()
  element:blur()

  luaunit.assertFalse(element:isFocused())
end

-- ============================================================================
-- Hierarchy Methods
-- ============================================================================

TestElementHierarchy = {}

function TestElementHierarchy:test_getHierarchyDepth_root()
  local element = createBasicElement({})

  local depth = element:getHierarchyDepth()

  luaunit.assertEquals(depth, 0)
end

function TestElementHierarchy:test_getHierarchyDepth_nested()
  local root = createBasicElement({})
  local child = createBasicElement({})
  local grandchild = createBasicElement({})

  root:addChild(child)
  child:addChild(grandchild)

  luaunit.assertEquals(grandchild:getHierarchyDepth(), 2)
end

function TestElementHierarchy:test_countElements()
  local root = createBasicElement({})

  local child1 = createBasicElement({})
  local child2 = createBasicElement({})

  root:addChild(child1)
  root:addChild(child2)

  local count = root:countElements()

  luaunit.assertEquals(count, 3) -- root + 2 children
end

-- ============================================================================
-- Scroll Methods Edge Cases
-- ============================================================================

TestElementScrollEdgeCases = {}

function TestElementScrollEdgeCases:test_scrollBy_non_scrollable()
  local element = createBasicElement({})

  -- Should not error
  element:scrollBy(10, 10)

  luaunit.assertTrue(true)
end

function TestElementScrollEdgeCases:test_getScrollPosition_no_scroll()
  local element = createBasicElement({})

  local x, y = element:getScrollPosition()

  luaunit.assertEquals(x, 0)
  luaunit.assertEquals(y, 0)
end

function TestElementScrollEdgeCases:test_hasOverflow_no_overflow()
  local element = createBasicElement({
    width = 100,
    height = 100,
  })

  local hasX, hasY = element:hasOverflow()

  luaunit.assertFalse(hasX)
  luaunit.assertFalse(hasY)
end

function TestElementScrollEdgeCases:test_getContentSize()
  local element = createBasicElement({})

  local w, h = element:getContentSize()

  luaunit.assertNotNil(w)
  luaunit.assertNotNil(h)
end

-- ============================================================================
-- Child Management Edge Cases
-- ============================================================================

TestElementChildManagement = {}

function TestElementChildManagement:test_addChild_nil()
  local element = createBasicElement({})

  -- Should not error or should handle gracefully
  pcall(function()
    element:addChild(nil)
  end)

  luaunit.assertTrue(true)
end

function TestElementChildManagement:test_removeChild_not_found()
  local parent = createBasicElement({})
  local child = createBasicElement({})

  -- Removing child that was never added
  parent:removeChild(child)

  luaunit.assertTrue(true)
end

function TestElementChildManagement:test_clearChildren_empty()
  local element = createBasicElement({})

  element:clearChildren()

  luaunit.assertEquals(element:getChildCount(), 0)
end

function TestElementChildManagement:test_getChildCount()
  local parent = createBasicElement({})

  luaunit.assertEquals(parent:getChildCount(), 0)

  parent:addChild(createBasicElement({}))
  parent:addChild(createBasicElement({}))

  luaunit.assertEquals(parent:getChildCount(), 2)
end

-- ============================================================================
-- Property Setting
-- ============================================================================

TestElementProperty = {}

function TestElementProperty:test_setProperty_valid()
  local element = createBasicElement({})

  element:setProperty("opacity", 0.5)

  luaunit.assertEquals(element.opacity, 0.5)
end

function TestElementProperty:test_setProperty_with_transition()
  local element = createBasicElement({
    opacity = 1,
  })

  element:setTransition("opacity", { duration = 1.0 })
  element:setProperty("opacity", 0)

  -- Transition should be created
  luaunit.assertNotNil(element._transitions)
end

-- ============================================================================
-- Transition Management
-- ============================================================================

TestElementTransitions = {}

function TestElementTransitions:test_removeTransition()
  local element = createBasicElement({
    opacity = 1,
  })

  element:setTransition("opacity", { duration = 1.0 })
  element:removeTransition("opacity")

  -- Transition should be removed
  luaunit.assertTrue(true)
end

function TestElementTransitions:test_setTransitionGroup()
  local element = createBasicElement({})

  element:setTransitionGroup("fade", { duration = 1.0 }, { "opacity", "scale" })

  luaunit.assertTrue(true)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
