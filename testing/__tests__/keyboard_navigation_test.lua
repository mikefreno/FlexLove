-- Keyboard Navigation Tests
-- Tests for Tab/Shift+Tab navigation, arrow key navigation, and focus management

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

local FlexLove = require("FlexLove")
local KeyboardNavigation = require("modules.KeyboardNavigation")
local FocusIndicator = require("modules.FocusIndicator")
local Context = require("modules.Context")
local Element = require("modules.Element")
local utils = require("modules.utils")
local Color = require("modules.Color")

-- Set up FlexLove in retained mode for testing (simpler for navigation tests)
FlexLove.init()
FlexLove.setMode("retained")

-- Initialize KeyboardNavigation
KeyboardNavigation.init({
  Context = Context,
  Element = Element,
  ErrorHandler = FlexLove._ErrorHandler,
  utils = utils,
  InputEvent = require("modules.InputEvent"),
})

-- Initialize FocusIndicator
FocusIndicator.init({
  Context = Context,
  Color = Color,
})

-- Link FocusIndicator to KeyboardNavigation
KeyboardNavigation.FocusIndicator = FocusIndicator

-- Test helper to create test UI
local function createTestUI()
  local container = Element.new({
    x = 0, y = 0,
    width = 800, height = 600,
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 10,
  })

  Element.new({ parent = container, id = "btn1", text = "Button 1", onEvent = function() end })
  Element.new({ parent = container, id = "btn2", text = "Button 2", onEvent = function() end })
  Element.new({ parent = container, id = "btn3", text = "Button 3", onEvent = function() end })
  Element.new({ parent = container, id = "input1", editable = true })

  return container
end

-- Test cases
local tests = {
  testFocusableDetection = function()
    local focused = Element.new({ editable = true })
    local interactive = Element.new({ onEvent = function() end })
    local plain = Element.new({ text = "Plain" })
    local disabled = Element.new({ onEvent = function() end, disabled = true })

    assert(focused:isFocusable() == true, "Editable element should be focusable")
    assert(interactive:isFocusable() == true, "Element with onEvent should be focusable")
    assert(plain:isFocusable() == false, "Plain element should not be focusable")
    assert(disabled:isFocusable() == false, "Disabled element should not be focusable")

    print("[PASS] testFocusableDetection")
  end,

  testSequentialNavigation = function()
    local container = createTestUI()
    Context.setNavigationContainer(container)

    -- Focus first element
    local first = container.children[1]
    Context.setFocused(first)

    -- Tab to next
    local success = KeyboardNavigation:nextFocusable()
    assert(success == true, "Tab should succeed")
    assert(Context.getFocused() == container.children[2], "Tab should move to next element")

    -- Tab again
    success = KeyboardNavigation:nextFocusable()
    assert(success == true, "Tab should succeed")
    assert(Context.getFocused() == container.children[3], "Tab should move to third element")

    print("[PASS] testSequentialNavigation")
  end,

  testShiftTabNavigation = function()
    local container = createTestUI()
    Context.setNavigationContainer(container)

    -- Focus last element (input1)
    local last = container.children[4]
    Context.setFocused(last)

    -- Shift+Tab to previous
    local success = KeyboardNavigation:previousFocusable()
    assert(success == true, "Shift+Tab should succeed")
    assert(Context.getFocused() == container.children[3], "Shift+Tab should move to previous element (btn3)")

    print("[PASS] testShiftTabNavigation")
  end,

  testTabWrapAround = function()
    local container = createTestUI()
    Context.setNavigationContainer(container)

    -- Focus last element (input1)
    local last = container.children[4]
    Context.setFocused(last)

    -- Tab at end with wrapAround=true should go to first
    KeyboardNavigation.config.wrapAround = true
    local success = KeyboardNavigation:nextFocusable()
    assert(success == true, "Tab should succeed with wrap")
    assert(Context.getFocused() == container.children[1], "Tab at end should wrap to first")

    print("[PASS] testTabWrapAround")
  end,

  testNoWrapAround = function()
    local container = createTestUI()
    Context.setNavigationContainer(container)

    -- Focus last element (input1)
    local last = container.children[4]
    Context.setFocused(last)

    -- Tab at end with wrapAround=false should stay
    KeyboardNavigation.config.wrapAround = false
    local success = KeyboardNavigation:nextFocusable()
    assert(success == false, "Tab should fail without wrap")
    assert(Context.getFocused() == container.children[4], "Focus should stay on last element")

    -- Restore default
    KeyboardNavigation.config.wrapAround = true

    print("[PASS] testNoWrapAround")
  end,

  testDirectionalNavigation = function()
    -- Create horizontal layout
    local container = Element.new({
      x = 0, y = 0,
      width = 800, height = 600,
      positioning = utils.enums.Positioning.FLEX,
      flexDirection = utils.enums.FlexDirection.HORIZONTAL,
      gap = 10,
    })
    Context.setNavigationContainer(container)

    Element.new({ parent = container, id = "left", text = "Left", onEvent = function() end })
    Element.new({ parent = container, id = "center", text = "Center", onEvent = function() end })
    Element.new({ parent = container, id = "right", text = "Right", onEvent = function() end })

    -- Focus middle element
    Context.setFocused(container.children[2])

    -- Navigate right
    local success = KeyboardNavigation:navigateDirectional("right")
    assert(success == true, "Navigate right should succeed")
    assert(Context.getFocused() == container.children[3], "Should navigate to right element")

    -- Navigate left from right goes to center (closest element in that direction)
    success = KeyboardNavigation:navigateDirectional("left")
    assert(success == true, "Navigate left should succeed")
    assert(Context.getFocused() == container.children[2], "Should navigate to center (closest left)")

    print("[PASS] testDirectionalNavigation")
  end,

  testActivation = function()
    -- Track if onEvent was called
    local activated = false

    -- Create test UI with tracked onEvent
    local container = Element.new({
      x = 0, y = 0,
      width = 800, height = 600,
      positioning = utils.enums.Positioning.FLEX,
      flexDirection = utils.enums.FlexDirection.VERTICAL,
      gap = 10,
    })
    Context.setNavigationContainer(container)

    Element.new({ parent = container, id = "btn1", text = "Button 1", onEvent = function(elem, event)
      if event.type == "press" or event.type == "release" then
        activated = true
      end
    end })
    Element.new({ parent = container, id = "btn2", text = "Button 2", onEvent = function() end })
    Element.new({ parent = container, id = "btn3", text = "Button 3", onEvent = function() end })
    Element.new({ parent = container, id = "input1", editable = true })

    -- Focus first button
    Context.setFocused(container.children[1])

    -- Activate with Enter
    local success = KeyboardNavigation:activateElement()
    assert(success == true, "Activation should succeed")
    assert(activated == true, "onEvent should have been called")

    print("[PASS] testActivation")
  end,

  testDismiss = function()
    local container = createTestUI()
    Context.setNavigationContainer(container)

    -- Focus an element
    Context.setFocused(container.children[1])

    -- Dismiss should clear focus
    local success = KeyboardNavigation:dismissElement()
    assert(success == true, "Dismiss should succeed")
    assert(Context.getFocused() == nil, "Focus should be cleared")

    print("[PASS] testDismiss")
  end,

  testNavigationStack = function()
    local container = createTestUI()
    Context.setNavigationContainer(container)

    -- Focus first element
    Context.setFocused(container.children[1])

    -- Push focus (simulating modal open)
    KeyboardNavigation:pushFocus(container.children[2])
    assert(Context.getFocused() == container.children[2], "Should focus modal element")

    -- Pop focus (simulating modal close)
    KeyboardNavigation:popFocus()
    assert(Context.getFocused() == container.children[1], "Should restore previous focus")

    print("[PASS] testNavigationStack")
  end,

  testImmediateModeNavigation = function()
    -- Switch to immediate mode
    FlexLove.setMode("immediate")

    -- Track elements created in immediate mode
    local btn1, btn2, btn3
    local container

    -- Run a frame to create elements in immediate mode
    FlexLove.beginFrame()
    container = Element.new({
      x = 0, y = 0,
      width = 800, height = 600,
      positioning = utils.enums.Positioning.FLEX,
      flexDirection = utils.enums.FlexDirection.VERTICAL,
      gap = 10,
    })

    btn1 = Element.new({ parent = container, id = "btn1", text = "Button 1", onEvent = function() end })
    btn2 = Element.new({ parent = container, id = "btn2", text = "Button 2", onEvent = function() end })
    btn3 = Element.new({ parent = container, id = "btn3", text = "Button 3", onEvent = function() end })

    FlexLove.endFrame() -- Triggers layout and populates _zIndexOrderedElements

    -- Verify elements are in z-index order
    assert(#Context._zIndexOrderedElements >= 3, "Should have at least 3 elements in z-index order")

    -- Set navigation container for immediate mode
    Context.setNavigationContainer(container)

    -- Focus first button
    Context.setFocused(btn1)
    assert(Context.getFocused() == btn1, "Should focus btn1")

    -- Tab to next (should go to btn2 in z-index order)
    local success = KeyboardNavigation:nextFocusable()
    assert(success == true, "Tab should succeed in immediate mode")

    -- Tab again (should go to btn3)
    success = KeyboardNavigation:nextFocusable()
    assert(success == true, "Tab should succeed in immediate mode")

    -- Shift+Tab back
    success = KeyboardNavigation:previousFocusable()
    assert(success == true, "Shift+Tab should succeed in immediate mode")

    -- Restore retained mode
    FlexLove.setMode("retained")

    print("[PASS] testImmediateModeNavigation")
  end,

  testSpatialIndex = function()
    -- Enable spatial index
    KeyboardNavigation.enableSpatialIndex(true)

    -- Create buttons with explicit positions (not using flex layout)
    local btnTop = Element.new({
      x = 100, y = 50,
      width = 80, height = 30,
      text = "Top",
      onEvent = function() end
    })

    local btnCenter = Element.new({
      x = 100, y = 150,
      width = 80, height = 30,
      text = "Center",
      onEvent = function() end
    })

    local btnBottom = Element.new({
      x = 100, y = 250,
      width = 80, height = 30,
      text = "Bottom",
      onEvent = function() end
    })

    local btnRight = Element.new({
      x = 250, y = 150,
      width = 80, height = 30,
      text = "Right",
      onEvent = function() end
    })

    -- Update spatial index with all buttons
    KeyboardNavigation._spatialIndex.elementPositions[btnTop] = {x = 100, y = 50, w = 80, h = 30}
    KeyboardNavigation._spatialIndex.elementPositions[btnCenter] = {x = 100, y = 150, w = 80, h = 30}
    KeyboardNavigation._spatialIndex.elementPositions[btnBottom] = {x = 100, y = 250, w = 80, h = 30}
    KeyboardNavigation._spatialIndex.elementPositions[btnRight] = {x = 250, y = 150, w = 80, h = 30}

    -- Add to grid cells
    local cellSize = KeyboardNavigation._spatialIndex.cellSize
    local function addToGrid(elem, pos)
      local leftCell = math.floor(pos.x / cellSize)
      local rightCell = math.floor((pos.x + pos.w - 1) / cellSize)
      local topCell = math.floor(pos.y / cellSize)
      local bottomCell = math.floor((pos.y + pos.h - 1) / cellSize)

      for gx = leftCell, rightCell do
        for gy = topCell, bottomCell do
          local cellKey = string.format("%d,%d", gx, gy)
          if not KeyboardNavigation._spatialIndex.grid[cellKey] then
            KeyboardNavigation._spatialIndex.grid[cellKey] = {}
          end
          table.insert(KeyboardNavigation._spatialIndex.grid[cellKey], elem)
        end
      end
    end

    addToGrid(btnTop, {x = 100, y = 50, w = 80, h = 30})
    addToGrid(btnCenter, {x = 100, y = 150, w = 80, h = 30})
    addToGrid(btnBottom, {x = 100, y = 250, w = 80, h = 30})
    addToGrid(btnRight, {x = 250, y = 150, w = 80, h = 30})

    -- Focus center button
    Context.setFocused(btnCenter)

    -- Navigate up (should go to btnTop)
    local success = KeyboardNavigation:navigateDirectional("up")
    assert(success == true, "Navigate up should succeed with spatial index")
    assert(Context.getFocused() == btnTop, "Should navigate to button above")

    -- Navigate right (should go to btnRight)
    success = KeyboardNavigation:navigateDirectional("right")
    assert(success == true, "Navigate right should succeed with spatial index")
    assert(Context.getFocused() == btnRight, "Should navigate to button on right")

    -- Navigate down (should go to btnBottom)
    Context.setFocused(btnCenter)
    success = KeyboardNavigation:navigateDirectional("down")
    assert(success == true, "Navigate down should succeed with spatial index")
    assert(Context.getFocused() == btnBottom, "Should navigate to button below")

    -- Disable spatial index
    KeyboardNavigation.enableSpatialIndex(false)

    print("[PASS] testSpatialIndex")
  end,
}

-- Run tests
local passed = 0
local failed = 0

for name, test in pairs(tests) do
  local success, err = pcall(test)
  if success then
    passed = passed + 1
  else
    failed = failed + 1
    print(string.format("[FAIL] %s: %s", name, tostring(err)))
  end
end

print("\n========================================")
print(string.format("Keyboard Navigation Tests: %d passed, %d failed", passed, failed))
print("========================================\n")

-- Exit with appropriate code
if failed > 0 then
  os.exit(1)
end
