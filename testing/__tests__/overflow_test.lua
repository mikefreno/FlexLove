-- Test suite for overflow detection and scroll behavior
-- This tests the critical ScrollManager.detectOverflow() path which is currently 0% covered
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")

TestOverflowDetection = {}

function TestOverflowDetection:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestOverflowDetection:tearDown()
  FlexLove.endFrame()
end

-- Test basic overflow detection when content exceeds container
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

-- Test edge case: overflow = "visible" should skip detection
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

-- Test edge case: empty container
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

-- Test overflow with absolutely positioned children (should be ignored)
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

-- Test scroll clamping with overflow
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

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
