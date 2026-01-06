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

TestScrollbarPlacement = {}

function TestScrollbarPlacement:setUp()
  FlexLove.setMode("retained")
end

function TestScrollbarPlacement:test_reserve_space_with_percentage_height_children()
  -- Test case from user: horizontal scroll container with 100% height children
  -- Should NOT cause vertical overflow
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    overflow = "scroll", -- Always shows scrollbars
    scrollbarPlacement = "reserve-space",
  })

  local child1 = FlexLove.new({
    width = 100,
    height = "100%",
    parent = container,
  })

  -- Trigger layout
  container:layoutChildren()
  container._scrollManager:detectOverflow(container)

  local overflowX, overflowY = container._scrollManager:hasOverflow()

  -- Child height should be reduced to account for horizontal scrollbar
  -- Default scrollbar is 12px + 2px padding on each side = 16px
  -- So child height should be 200 - 16 = 184px
  luaunit.assertEquals(child1.height, 184)

  -- Should have horizontal overflow (scroll mode), but NOT vertical
  luaunit.assertFalse(overflowY, "Should not have vertical overflow with 100% height child")
end

function TestScrollbarPlacement:test_reserve_space_with_percentage_width_children()
  -- Vertical scroll container with 100% width children
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "column",
    overflow = "scroll", -- Always shows scrollbars
    scrollbarPlacement = "reserve-space",
  })

  local child1 = FlexLove.new({
    width = "100%",
    height = 100,
    parent = container,
  })

  -- Trigger layout
  container:layoutChildren()
  container._scrollManager:detectOverflow(container)

  local overflowX, overflowY = container._scrollManager:hasOverflow()

  -- Child width should be reduced to account for vertical scrollbar
  -- Default scrollbar is 12px + 2px padding on each side = 16px
  -- So child width should be 200 - 16 = 184px
  luaunit.assertEquals(child1.width, 184)

  -- Should have vertical overflow (scroll mode), but NOT horizontal
  luaunit.assertFalse(overflowX, "Should not have horizontal overflow with 100% width child")
end

function TestScrollbarPlacement:test_overlay_mode_no_size_adjustment()
  -- Overlay mode should NOT adjust child sizes
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    overflow = "scroll",
    scrollbarPlacement = "overlay",
  })

  local child1 = FlexLove.new({
    width = 100,
    height = "100%",
    parent = container,
  })

  -- Trigger layout
  container:layoutChildren()

  -- Child height should be full 200px (no reduction for scrollbar)
  luaunit.assertEquals(child1.height, 200)
end

function TestScrollbarPlacement:test_auto_overflow_reserves_space_only_when_needed()
  -- With overflow="auto" and reserve-space mode, space is reserved preemptively
  -- But scrollbars should only be visible when content actually overflows
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "column",
    overflow = "auto",
    scrollbarPlacement = "reserve-space",
  })

  -- Child that doesn't cause overflow
  local child1 = FlexLove.new({
    width = "100%",
    height = 100,
    parent = container,
  })

  -- Trigger layout and overflow detection
  container:layoutChildren()
  container._scrollManager:detectOverflow(container)

  local overflowX, overflowY = container._scrollManager:hasOverflow()

  -- No overflow detected since content (100px) < available height (184px after scrollbar reservation)
  luaunit.assertFalse(overflowY, "Should not have overflow")
  -- Space is reserved preemptively with overflow="auto" to avoid layout shifts
  luaunit.assertEquals(child1.width, 184, "Space should be reserved preemptively with auto mode")
end

function TestScrollbarPlacement:test_vertical_overflow_detected_with_reserved_space()
  -- Test that overflow is properly detected when using reserve-space
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "column",
    overflow = "auto",
    scrollbarPlacement = "reserve-space",
  })

  -- Child that WILL cause overflow
  local child1 = FlexLove.new({
    width = "100%",
    height = 300,
    parent = container,
  })

  -- Trigger layout and overflow detection
  container:layoutChildren()
  container._scrollManager:detectOverflow(container)

  local overflowX, overflowY = container._scrollManager:hasOverflow()

  -- Should detect vertical overflow
  luaunit.assertTrue(overflowY, "Should detect vertical overflow")

  -- Child width should be reduced for vertical scrollbar
  luaunit.assertEquals(child1.width, 184, "Child width should be reduced for scrollbar")
end

function TestScrollbarPlacement:test_scrollbar_balance_vertical()
  -- Test scrollbarBalance with vertical scrollbar
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "column",
    overflow = "scroll",
    scrollbarPlacement = "reserve-space",
    scrollbarBalance = true,
  })

  local child1 = FlexLove.new({
    width = "100%",
    height = 100,
    parent = container
  })

  container:layoutChildren()

  local reservedW, reservedH = container._scrollManager:getReservedSpace(container)
  
  -- Should reserve double the space (16 * 2 = 32)
  luaunit.assertEquals(reservedW, 32, "Should reserve doubled width for balance")
  
  -- Child width should account for balanced space
  luaunit.assertEquals(child1.width, 168, "Child width should be 200 - 32")
end

function TestScrollbarPlacement:test_scrollbar_balance_horizontal()
  -- Test scrollbarBalance with horizontal scrollbar
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    overflow = "scroll",
    scrollbarPlacement = "reserve-space",
    scrollbarBalance = true,
  })

  local child1 = FlexLove.new({
    width = 100,
    height = "100%",
    parent = container
  })

  container:layoutChildren()

  local reservedW, reservedH = container._scrollManager:getReservedSpace(container)
  
  -- Should reserve double the space (16 * 2 = 32)
  luaunit.assertEquals(reservedH, 32, "Should reserve doubled height for balance")
  
  -- Child height should account for balanced space
  luaunit.assertEquals(child1.height, 168, "Child height should be 200 - 32")
end

function TestScrollbarPlacement:test_scrollbar_balance_both()
  -- Test scrollbarBalance with both scrollbars
  local container = FlexLove.new({
    width = 200,
    height = 200,
    positioning = "flex",
    overflow = "scroll",
    scrollbarPlacement = "reserve-space",
    scrollbarBalance = true,
  })

  local child1 = FlexLove.new({
    width = "100%",
    height = "100%",
    parent = container
  })

  container:layoutChildren()

  local reservedW, reservedH = container._scrollManager:getReservedSpace(container)
  
  -- Both should reserve double the space
  luaunit.assertEquals(reservedW, 32, "Should reserve doubled width for balance")
  luaunit.assertEquals(reservedH, 32, "Should reserve doubled height for balance")
  
  -- Child should be sized to balanced available space
  luaunit.assertEquals(child1.width, 168, "Child width should be 200 - 32")
  luaunit.assertEquals(child1.height, 168, "Child height should be 200 - 32")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
