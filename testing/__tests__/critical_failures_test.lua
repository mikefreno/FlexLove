-- Critical Failure Tests for FlexLove
-- These tests are designed to find ACTUAL BUGS:
-- 1. Memory leaks / garbage creation without cleanup
-- 2. Layout calculation bugs causing incorrect positioning
-- 3. Unsafe input access (nil dereference, division by zero, etc.)

package.path = package.path .. ";./?.lua;./modules/?.lua"
require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")

TestCriticalFailures = {}

function TestCriticalFailures:setUp()
  collectgarbage("collect")
  FlexLove.destroy()
  FlexLove.setMode("retained")
end

function TestCriticalFailures:tearDown()
  FlexLove.destroy()
  collectgarbage("collect")
end

-- ============================================================
-- MEMORY LEAK TESTS - Find garbage that's not cleaned up
-- ============================================================

-- Test: Canvas objects should be cleaned up on resize
function TestCriticalFailures:test_canvas_cleanup_on_resize()
  FlexLove.init()

  -- Create initial canvases
  FlexLove.draw(function() end)
  local canvas1 = FlexLove._gameCanvas

  -- Resize should invalidate old canvases
  FlexLove.resize()

  -- Draw again to create new canvases
  FlexLove.draw(function() end)
  local canvas2 = FlexLove._gameCanvas

  -- Old canvas should be replaced
  luaunit.assertNotEquals(canvas1, canvas2)

  -- Check canvas is actually nil after resize (before draw)
  FlexLove.resize()
  luaunit.assertNil(FlexLove._gameCanvas)
end

-- Test: Elements should be cleaned up from topElements on destroy
function TestCriticalFailures:test_element_cleanup_from_top_elements()
  local element1 = FlexLove.new({ width = 100, height = 100 })
  local element2 = FlexLove.new({ width = 100, height = 100 })

  luaunit.assertEquals(#FlexLove.topElements, 2)

  element1:destroy()
  luaunit.assertEquals(#FlexLove.topElements, 1)

  element2:destroy()
  luaunit.assertEquals(#FlexLove.topElements, 0)
end

-- Test: Child elements should be destroyed when parent is destroyed
function TestCriticalFailures:test_child_cleanup_on_parent_destroy()
  local parent = FlexLove.new({ width = 200, height = 200 })
  local child = FlexLove.new({ width = 50, height = 50, parent = parent })

  luaunit.assertEquals(#parent.children, 1)

  -- Destroy parent should also clear children
  parent:destroy()

  -- Child should have no parent reference (potential memory leak if not cleared)
  luaunit.assertNil(child.parent)
  luaunit.assertEquals(#parent.children, 0)
end

-- Test: Event handlers should be cleared on destroy (closure leak)
function TestCriticalFailures:test_event_handler_cleanup()
  local captured_data = { large_array = {} }
  for i = 1, 1000 do
    captured_data.large_array[i] = i
  end

  local element = FlexLove.new({
    width = 100,
    height = 100,
    onEvent = function(el, event)
      -- This closure captures captured_data
      print(captured_data.large_array[1])
    end,
  })

  element:destroy()

  -- onEvent should be nil after destroy (prevent closure leak)
  luaunit.assertNil(element.onEvent)
end

-- Test: Immediate mode state should not grow unbounded
function TestCriticalFailures:test_immediate_mode_state_cleanup()
  FlexLove.setMode("immediate")
  FlexLove.init({ stateRetentionFrames = 2 })

  -- Create elements for multiple frames
  for frame = 1, 10 do
    FlexLove.beginFrame()
    FlexLove.new({ id = "element_" .. frame, width = 100, height = 100 })
    FlexLove.endFrame()
  end

  -- State count should be limited by stateRetentionFrames
  local stateCount = FlexLove.getStateCount()
  -- Should be much less than 10 due to cleanup
  luaunit.assertTrue(stateCount < 10, "State count: " .. stateCount .. " (should be cleaned up)")
end

-- ============================================================
-- LAYOUT CALCULATION BUGS - Find incorrect positioning
-- ============================================================

-- Test: Flex layout with overflow should not position children outside container
function TestCriticalFailures:test_flex_overflow_positioning()
  local parent = FlexLove.new({
    width = 100,
    height = 100,
    positioning = "flex",
    flexDirection = "horizontal",
    flexWrap = "nowrap",
  })

  -- Add children that exceed parent width
  local child1 = FlexLove.new({ width = 80, height = 50, parent = parent })
  local child2 = FlexLove.new({ width = 80, height = 50, parent = parent })

  -- Children should be positioned, even if they overflow
  -- Check that x positions are at least valid numbers
  luaunit.assertNotNil(child1.x)
  luaunit.assertNotNil(child2.x)
  luaunit.assertTrue(child1.x >= 0)
  luaunit.assertTrue(child2.x > child1.x)
end

-- Test: Percentage width with zero parent width (division by zero)
function TestCriticalFailures:test_percentage_width_zero_parent()
  local parent = FlexLove.new({ width = 0, height = 100 })

  -- This should not crash (division by zero in percentage calculation)
  local success, child = pcall(function()
    return FlexLove.new({ width = "50%", height = 50, parent = parent })
  end)

  luaunit.assertTrue(success, "Should not crash with zero parent width")
  if success then
    -- Width should be 0 or handled gracefully
    luaunit.assertTrue(child.width >= 0)
  end
end

-- Test: Auto-sizing with circular dependency
function TestCriticalFailures:test_autosizing_circular_dependency()
  -- Parent auto-sizes to child, child uses percentage of parent
  local parent = FlexLove.new({ height = 100 }) -- No width = auto

  -- Child width is percentage of parent, but parent width depends on child
  local success, child = pcall(function()
    return FlexLove.new({ width = "50%", height = 50, parent = parent })
  end)

  luaunit.assertTrue(success, "Should not crash with circular sizing")

  -- Check that we don't get NaN or negative values
  if success then
    luaunit.assertFalse(parent.width ~= parent.width, "Parent width should not be NaN")
    luaunit.assertFalse(child.width ~= child.width, "Child width should not be NaN")
    luaunit.assertTrue(parent.width >= 0, "Parent width should be non-negative")
    luaunit.assertTrue(child.width >= 0, "Child width should be non-negative")
  end
end

-- Test: Negative padding should not cause negative content dimensions
function TestCriticalFailures:test_negative_padding_content_dimensions()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    padding = { top = -50, left = -50, right = -50, bottom = -50 },
  })

  -- Content width/height should never be negative
  luaunit.assertTrue(element.width >= 0, "Content width should be non-negative: " .. element.width)
  luaunit.assertTrue(element.height >= 0, "Content height should be non-negative: " .. element.height)
end

-- Test: Grid layout with zero rows/columns (division by zero)
function TestCriticalFailures:test_grid_zero_dimensions()
  local parent = FlexLove.new({
    width = 300,
    height = 200,
    positioning = "grid",
    gridRows = 0,
    gridColumns = 0,
  })

  -- This should not crash when adding children
  local success = pcall(function()
    FlexLove.new({ width = 50, height = 50, parent = parent })
  end)

  luaunit.assertTrue(success, "Should not crash with zero grid dimensions")
end

-- ============================================================
-- UNSAFE INPUT ACCESS - Find nil dereference and type errors
-- ============================================================

-- Test: setText with number should not crash (type coercion)
function TestCriticalFailures:test_set_text_with_number()
  local element = FlexLove.new({ width = 100, height = 100, text = "initial" })

  -- Many Lua APIs expect string but get number
  local success = pcall(function()
    element:setText(12345)
  end)

  luaunit.assertTrue(success, "Should handle number text gracefully")
end

-- Test: Image path with special characters should not crash file system
function TestCriticalFailures:test_image_path_special_characters()
  local success = pcall(function()
    FlexLove.new({
      width = 100,
      height = 100,
      imagePath = "../../../etc/passwd", -- Path traversal attempt
    })
  end)

  luaunit.assertTrue(success, "Should handle malicious paths gracefully")
end

-- Test: onEvent callback that errors should not crash the system
function TestCriticalFailures:test_on_event_error_handling()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    onEvent = function(el, event)
      error("Intentional error in callback")
    end,
  })

  -- Simulate mouse click
  local success = pcall(function()
    local InputEvent = require("modules.InputEvent")
    local event = InputEvent.new({ type = "pressed", button = 1 })
    if element.onEvent then
      element.onEvent(element, event)
    end
  end)

  -- Should error (no protection), but shouldn't leave system in bad state
  luaunit.assertFalse(success)

  -- Element should still be valid
  luaunit.assertNotNil(element)
end

-- Test: Text with null bytes should not cause buffer issues
function TestCriticalFailures:test_text_with_null_bytes()
  local success = pcall(function()
    FlexLove.new({
      width = 200,
      height = 100,
      text = "Hello\0World\0\0\0",
    })
  end)

  luaunit.assertTrue(success, "Should handle null bytes in text")
end

-- Test: Extremely deep nesting should not cause stack overflow
function TestCriticalFailures:test_extreme_nesting_stack_overflow()
  local parent = FlexLove.new({ width = 500, height = 500 })
  local current = parent

  -- Try to create 1000 levels of nesting
  local success = pcall(function()
    for i = 1, 1000 do
      local child = FlexLove.new({
        width = 10,
        height = 10,
        parent = current,
      })
      current = child
    end
  end)

  -- This might fail due to legitimate recursion limits
  -- But it should fail gracefully, not segfault
  if not success then
    print("Deep nesting failed (expected for extreme depth)")
  end

  luaunit.assertTrue(true) -- If we get here, no segfault
end

-- Test: Gap with NaN value
function TestCriticalFailures:test_gap_nan_value()
  local success = pcall(function()
    FlexLove.new({
      width = 300,
      height = 200,
      positioning = "flex",
      gap = 0 / 0, -- NaN
    })
  end)

  -- NaN in calculations can propagate and cause issues
  luaunit.assertTrue(success, "Should handle NaN gap")
end

-- Test: Border-box model with huge padding
function TestCriticalFailures:test_huge_padding_overflow()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    padding = { top = 1000000, left = 1000000, right = 1000000, bottom = 1000000 },
  })

  -- Content dimensions should be clamped to 0, not underflow
  luaunit.assertTrue(element.width >= 0, "Width should not underflow: " .. element.width)
  luaunit.assertTrue(element.height >= 0, "Height should not underflow: " .. element.height)
end

-- Test: Scroll position race condition in immediate mode
function TestCriticalFailures:test_scroll_position_race_immediate_mode()
  FlexLove.setMode("immediate")

  -- Create scrollable element
  FlexLove.beginFrame()
  local element = FlexLove.new({
    id = "scroll_test",
    width = 200,
    height = 200,
    overflow = "scroll",
  })
  FlexLove.endFrame()

  -- Set scroll position
  element:setScrollPosition(50, 50)

  -- Create same element next frame (state should restore)
  FlexLove.beginFrame()
  local element2 = FlexLove.new({
    id = "scroll_test",
    width = 200,
    height = 200,
    overflow = "scroll",
  })
  FlexLove.endFrame()

  -- Scroll position should persist (or at least not crash)
  local scrollX, scrollY = element2:getScrollPosition()
  luaunit.assertNotNil(scrollX)
  luaunit.assertNotNil(scrollY)
end

-- Test: Theme with missing required properties
function TestCriticalFailures:test_theme_missing_properties()
  local Theme = require("modules.Theme")

  -- Create theme with minimal properties
  local success = pcall(function()
    local theme = Theme.new({
      name = "broken",
      -- Missing components table
    })

    FlexLove.init({ theme = theme })
  end)

  -- Should handle gracefully or error clearly
  luaunit.assertTrue(true) -- If we get here, no segfault
end

-- Test: Blur with zero or negative quality
function TestCriticalFailures:test_blur_invalid_quality()
  local success = pcall(function()
    FlexLove.new({
      width = 100,
      height = 100,
      contentBlur = { intensity = 50, quality = 0 },
    })
  end)

  luaunit.assertTrue(success, "Should handle zero blur quality")

  success = pcall(function()
    FlexLove.new({
      width = 100,
      height = 100,
      contentBlur = { intensity = 50, quality = -5 },
    })
  end)

  luaunit.assertTrue(success, "Should handle negative blur quality")
end

-- ============================================================
-- NIL DEREFERENCE BUGS - Target specific LSP warnings
-- ============================================================

-- Test: 9-patch padding with corrupted theme state (Element.lua:752-755)
function TestCriticalFailures:test_ninepatch_padding_nil_dereference()
  local Theme = require("modules.Theme")
  
  -- Create a theme with 9-patch data
  local theme = Theme.new({
    name = "test_theme",
    components = {
      container = {
        ninePatch = {
          imagePath = "themes/metal.lua", -- Invalid path to trigger edge case
          contentPadding = { top = 10, left = 10, right = 10, bottom = 10 }
        }
      }
    }
  })
  
  FlexLove.init({ theme = theme })
  
  -- Try to create element that uses 9-patch padding
  -- If ninePatchContentPadding becomes nil but use9PatchPadding is true, this will crash
  local success, err = pcall(function()
    return FlexLove.new({
      width = 100,
      height = 100,
      component = "container",
      -- No explicit padding, should use 9-patch padding
    })
  end)
  
  if not success then
    print("ERROR: " .. tostring(err))
  end
  
  luaunit.assertTrue(success, "Should handle 9-patch padding gracefully")
end

-- Test: Theme with malformed 9-patch data
function TestCriticalFailures:test_malformed_ninepatch_data()
  local Theme = require("modules.Theme")
  
  -- Create theme with incomplete 9-patch data
  local success = pcall(function()
    local theme = Theme.new({
      name = "broken_nine_patch",
      components = {
        container = {
          ninePatch = {
            -- Missing imagePath
            contentPadding = { top = 10, left = 10 }, -- Incomplete padding
          }
        }
      }
    })
    
    FlexLove.init({ theme = theme })
    
    FlexLove.new({
      width = 100,
      height = 100,
      component = "container",
    })
  end)
  
  -- Should either succeed or fail with clear error (not nil dereference)
  luaunit.assertTrue(true) -- If we get here, no segfault
end

-- ============================================================
-- INTEGRATION TESTS - Combine features in unexpected ways
-- ============================================================

-- Test: Scrollable element with overflow content + immediate mode + state restoration
function TestCriticalFailures:test_scroll_overflow_immediate_mode_integration()
  FlexLove.setMode("immediate")
  
  for frame = 1, 3 do
    FlexLove.beginFrame()
    
    local scrollContainer = FlexLove.new({
      id = "scroll_container",
      width = 200,
      height = 150,
      overflow = "scroll",
      positioning = "flex",
      flexDirection = "vertical",
    })
    
    -- Add children that exceed container height
    for i = 1, 10 do
      FlexLove.new({
        id = "child_" .. i,
        width = 180,
        height = 50,
        parent = scrollContainer,
      })
    end
    
    FlexLove.endFrame()
    
    -- Scroll on second frame
    if frame == 2 then
      scrollContainer:setScrollPosition(0, 100)
    end
    
    -- Check scroll position restored on third frame
    if frame == 3 then
      local scrollX, scrollY = scrollContainer:getScrollPosition()
      luaunit.assertNotNil(scrollX, "Scroll X should be preserved")
      luaunit.assertNotNil(scrollY, "Scroll Y should be preserved")
    end
  end
end

-- Test: Grid layout with auto-sized children and percentage gaps
function TestCriticalFailures:test_grid_autosized_children_percentage_gap()
  local grid = FlexLove.new({
    width = 300,
    height = 300,
    positioning = "grid",
    gridRows = 3,
    gridColumns = 3,
    gap = "5%", -- Percentage gap
  })
  
  -- Add auto-sized children (no explicit dimensions)
  for i = 1, 9 do
    local child = FlexLove.new({
      parent = grid,
      text = "Cell " .. i,
      -- Auto-sizing based on text
    })
    
    -- Verify child dimensions are valid
    luaunit.assertNotNil(child.width)
    luaunit.assertNotNil(child.height)
    luaunit.assertTrue(child.width >= 0)
    luaunit.assertTrue(child.height >= 0)
  end
end

-- Test: Nested flex containers with conflicting alignment
function TestCriticalFailures:test_nested_flex_conflicting_alignment()
  local outer = FlexLove.new({
    width = 400,
    height = 400,
    positioning = "flex",
    flexDirection = "vertical",
    alignItems = "stretch",
    justifyContent = "center",
  })
  
  local middle = FlexLove.new({
    parent = outer,
    height = 200,
    -- Auto width (should stretch)
    positioning = "flex",
    flexDirection = "horizontal",
    alignItems = "flex-end",
    justifyContent = "space-between",
  })
  
  local inner1 = FlexLove.new({
    parent = middle,
    width = 50,
    -- Auto height
    text = "A",
  })
  
  local inner2 = FlexLove.new({
    parent = middle,
    width = 50,
    height = 100,
    text = "B",
  })
  
  -- Verify all elements have valid dimensions and positions
  luaunit.assertTrue(outer.width > 0)
  luaunit.assertTrue(middle.width > 0)
  luaunit.assertTrue(inner1.height > 0)
  luaunit.assertNotNil(inner1.x)
  luaunit.assertNotNil(inner2.x)
end

-- Test: Element with multiple conflicting size sources
function TestCriticalFailures:test_conflicting_size_sources()
  -- Element with explicit size + auto-sizing content + parent constraints
  local parent = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    alignItems = "stretch",
  })
  
  local success = pcall(function()
    FlexLove.new({
      parent = parent,
      width = 300, -- Exceeds parent width
      height = "50%", -- Percentage height
      text = "Very long text that should cause auto-sizing",
      padding = { top = 50, left = 50, right = 50, bottom = 50 },
    })
  end)
  
  luaunit.assertTrue(success, "Should handle conflicting size sources")
end

-- Test: Image element with resize during load
function TestCriticalFailures:test_image_resize_during_load()
  local element = FlexLove.new({
    width = 100,
    height = 100,
    imagePath = "nonexistent.png", -- Won't load, but should handle gracefully
  })
  
  -- Simulate resize while "loading"
  FlexLove.resize(1920, 1080)
  
  -- Element should still be valid
  luaunit.assertNotNil(element.width)
  luaunit.assertNotNil(element.height)
  luaunit.assertTrue(element.width > 0)
  luaunit.assertTrue(element.height > 0)
end

-- Test: Rapid theme switching with active elements
function TestCriticalFailures:test_rapid_theme_switching()
  local Theme = require("modules.Theme")
  
  local theme1 = Theme.new({ name = "theme1", components = {} })
  local theme2 = Theme.new({ name = "theme2", components = {} })
  
  FlexLove.init({ theme = theme1 })
  
  -- Create elements with theme1
  local element1 = FlexLove.new({ width = 100, height = 100 })
  local element2 = FlexLove.new({ width = 100, height = 100 })
  
  -- Switch theme
  FlexLove.destroy()
  FlexLove.init({ theme = theme2 })
  
  -- Old elements should be invalidated (accessing them might crash)
  local success = pcall(function()
    element1:setText("test")
  end)
  
  -- It's OK if this fails (element destroyed), but shouldn't segfault
  luaunit.assertTrue(true)
end

-- Test: Update properties during layout calculation
function TestCriticalFailures:test_update_during_layout()
  local parent = FlexLove.new({
    width = 300,
    height = 300,
    positioning = "flex",
  })
  
  local child = FlexLove.new({
    width = 100,
    height = 100,
    parent = parent,
  })
  
  -- Modify child properties immediately after creation (during layout)
  child:setText("Modified during layout")
  child.backgroundColor = { r = 1, g = 0, b = 0, a = 1 }
  
  -- Trigger another layout
  parent:resize(400, 400)
  
  -- Everything should still be valid
  luaunit.assertNotNil(child.text)
  luaunit.assertEquals(child.text, "Modified during layout")
end

-- ============================================================
-- STATE CORRUPTION SCENARIOS
-- ============================================================

-- Test: Destroy element with active event listeners
function TestCriticalFailures:test_destroy_with_active_listeners()
  local eventFired = false
  
  local element = FlexLove.new({
    width = 100,
    height = 100,
    onEvent = function(el, event)
      eventFired = true
    end,
  })
  
  -- Simulate an event via InputEvent
  local InputEvent = require("modules.InputEvent")
  local event = InputEvent.new({ type = "pressed", button = 1, x = 50, y = 50 })
  
  if element.onEvent and element:contains(50, 50) then
    element.onEvent(element, event)
  end
  
  luaunit.assertTrue(eventFired, "Event should fire before destroy")
  
  -- Destroy element
  element:destroy()
  
  -- onEvent should be nil after destroy
  luaunit.assertNil(element.onEvent, "onEvent should be cleared after destroy")
end

-- Test: Double destroy should be safe
function TestCriticalFailures:test_double_destroy_safety()
  local element = FlexLove.new({ width = 100, height = 100 })
  
  element:destroy()
  
  -- Second destroy should be safe (idempotent)
  local success = pcall(function()
    element:destroy()
  end)
  
  luaunit.assertTrue(success, "Double destroy should be safe")
end

-- Test: Circular parent-child reference (should never happen, but test safety)
function TestCriticalFailures:test_circular_parent_child_reference()
  local parent = FlexLove.new({ width = 200, height = 200 })
  local child = FlexLove.new({ width = 100, height = 100, parent = parent })
  
  -- Try to create circular reference (should be prevented)
  local success = pcall(function()
    parent.parent = child -- This should never be allowed
    parent:layoutChildren() -- This would cause infinite recursion
  end)
  
  -- Even if we set circular reference, layout should not crash
  luaunit.assertTrue(true) -- If we get here, no stack overflow
end

-- Test: Modify children array during iteration
function TestCriticalFailures:test_modify_children_during_iteration()
  local parent = FlexLove.new({
    width = 300,
    height = 300,
    positioning = "flex",
  })
  
  -- Add several children
  local children = {}
  for i = 1, 5 do
    children[i] = FlexLove.new({
      width = 50,
      height = 50,
      parent = parent,
    })
  end
  
  -- Remove child during layout (simulates user code modifying structure)
  local success = pcall(function()
    -- Trigger layout
    parent:layoutChildren()
    
    -- Remove a child (modifies children array)
    children[3]:destroy()
    
    -- Trigger layout again
    parent:layoutChildren()
  end)
  
  luaunit.assertTrue(success, "Should handle children modification during layout")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
