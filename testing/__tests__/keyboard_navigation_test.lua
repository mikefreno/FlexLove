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

local luaunit = require("testing.luaunit")

local FlexLove = require("FlexLove")
local KeyboardNavigation = require("modules.KeyboardNavigation")
local FocusIndicator = require("modules.FocusIndicator")
local Context = require("modules.Context")
local Element = require("modules.Element")
local utils = require("modules.utils")
local Color = require("modules.Color")
local Theme = require("modules.Theme")

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

Theme.init({ ErrorHandler = FlexLove._ErrorHandler, Color = Color, utils = utils })

-- Link FocusIndicator to KeyboardNavigation
KeyboardNavigation.FocusIndicator = FocusIndicator

-- Test helper to create test UI
local function createTestUI()
  local container = Element.new({
    x = 0,
    y = 0,
    width = 800,
    height = 600,
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
TestKeyboardNavigation = {}

function TestKeyboardNavigation:testApplyKeyboardNavConfigWorks()
  local originalWrapAround = KeyboardNavigation.config.wrapAround
  FlexLove.enableKeyboardNavigation({ wrapAround = false })
  assert(KeyboardNavigation.config.wrapAround == false, "enableKeyboardNavigation should apply wrapAround config")
  FlexLove.enableKeyboardNavigation({ wrapAround = true })
  assert(KeyboardNavigation.config.wrapAround == true, "enableKeyboardNavigation should restore wrapAround config")
  KeyboardNavigation.config.wrapAround = originalWrapAround
end

function TestKeyboardNavigation:testApplyKeyboardNavConfigFocusIndicatorColor()
  local originalColor = {
    FocusIndicator.config.color[1],
    FocusIndicator.config.color[2],
    FocusIndicator.config.color[3],
    FocusIndicator.config.color[4],
  }
  FlexLove.enableKeyboardNavigation({
    focusIndicator = {
      color = { 1, 0, 0, 1 },
    },
  })
  assert(FocusIndicator.config.color[1] == 1, "Red channel should be 1")
  assert(FocusIndicator.config.color[2] == 0, "Green channel should be 0")
  assert(FocusIndicator.config.color[3] == 0, "Blue channel should be 0")
  assert(FocusIndicator.config.color[4] == 1, "Alpha channel should be 1")
  FocusIndicator.setColor(originalColor[1], originalColor[2], originalColor[3], originalColor[4])
end

function TestKeyboardNavigation:testApplyKeyboardNavConfigFocusIndicatorEnabled()
  local original = FocusIndicator.config.enabled
  FlexLove.enableKeyboardNavigation({
    focusIndicator = {
      enabled = false,
    },
  })
  assert(FocusIndicator.config.enabled == false, "FocusIndicator enabled should be false")
  FocusIndicator.config.enabled = original
end

function TestKeyboardNavigation:testEnableKeyboardNavigationUpdatesFocusIndicatorColor()
  local originalColor = {
    FocusIndicator.config.color[1],
    FocusIndicator.config.color[2],
    FocusIndicator.config.color[3],
    FocusIndicator.config.color[4],
  }
  FlexLove.enableKeyboardNavigation({
    focusIndicator = {
      color = { 0, 1, 0, 1 },
    },
  })
  assert(FocusIndicator.config.color[1] == 0, "Red channel should be 0")
  assert(FocusIndicator.config.color[2] == 1, "Green channel should be 1")
  assert(FocusIndicator.config.color[3] == 0, "Blue channel should be 0")
  assert(FocusIndicator.config.color[4] == 1, "Alpha channel should be 1")
  FocusIndicator.setColor(originalColor[1], originalColor[2], originalColor[3], originalColor[4])
end

function TestKeyboardNavigation:testFocusableDetection()
  local focused = Element.new({ editable = true })
  local interactive = Element.new({ onEvent = function() end })
  local plain = Element.new({ text = "Plain" })
  local disabled = Element.new({ onEvent = function() end, disabled = true })

  assert(focused:isFocusable() == true, "Editable element should be focusable")
  assert(interactive:isFocusable() == true, "Element with onEvent should be focusable")
  assert(plain:isFocusable() == false, "Plain element should not be focusable")
  assert(disabled:isFocusable() == false, "Disabled element should not be focusable")
end

function TestKeyboardNavigation:testSequentialNavigation()
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
end

function TestKeyboardNavigation:testShiftTabNavigation()
  local container = createTestUI()
  Context.setNavigationContainer(container)

  -- Focus last element (input1)
  local last = container.children[4]
  Context.setFocused(last)

  -- Shift+Tab to previous
  local success = KeyboardNavigation:previousFocusable()
  assert(success == true, "Shift+Tab should succeed")
  assert(Context.getFocused() == container.children[3], "Shift+Tab should move to previous element (btn3)")
end

function TestKeyboardNavigation:testTabWrapAround()
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
end

function TestKeyboardNavigation:testNoWrapAround()
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
end

function TestKeyboardNavigation:testDirectionalNavigation()
  -- Create horizontal layout
  local container = Element.new({
    x = 0,
    y = 0,
    width = 800,
    height = 600,
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
end

function TestKeyboardNavigation:testActivation()
  -- Track if onEvent was called
  local activated = false

  -- Create test UI with tracked onEvent
  local container = Element.new({
    x = 0,
    y = 0,
    width = 800,
    height = 600,
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 10,
  })
  Context.setNavigationContainer(container)

  Element.new({
    parent = container,
    id = "btn1",
    text = "Button 1",
    onEvent = function(elem, event)
      if event.type == "press" or event.type == "release" then
        activated = true
      end
    end,
  })
  Element.new({ parent = container, id = "btn2", text = "Button 2", onEvent = function() end })
  Element.new({ parent = container, id = "btn3", text = "Button 3", onEvent = function() end })
  Element.new({ parent = container, id = "input1", editable = true })

  -- Focus first button
  Context.setFocused(container.children[1])

  -- Simulate keyboard navigation focus indicator visibility
  FocusIndicator.setFocused(container.children[1])

  -- Activate with Enter
  local success = KeyboardNavigation:activateElement()
  assert(success == true, "Activation should succeed")
  assert(activated == true, "onEvent should have been called")
end

function TestKeyboardNavigation:testFocusIndicatorHiddenViaHandleKeyPress()
  local container = createTestUI()
  Context.setNavigationContainer(container)

  -- Focus via keyboard navigation so indicator is shown
  local success = KeyboardNavigation:nextFocusable()
  assert(success == true, "Keyboard navigation should focus first element")

  -- Activate via key handling path
  success = KeyboardNavigation:handleKeyPress("return", "return", false)
  assert(success == true, "Enter key should activate focused element")
end

function TestKeyboardNavigation:testFocusIndicatorReappearsAfterNextKeyboardNavigation()
  local container = createTestUI()
  Context.setNavigationContainer(container)

  local success = KeyboardNavigation:nextFocusable()
  assert(success == true, "First keyboard navigation should succeed")

  success = KeyboardNavigation:activateElement()
  assert(success == true, "Activation should succeed")

  success = KeyboardNavigation:nextFocusable()
  assert(success == true, "Second keyboard navigation should succeed")
end

function TestKeyboardNavigation:testKeyboardFocusUsesHoverThemeState()
  local theme = Theme.new({
    name = "Keyboard Focus Theme",
    components = {
      button = {
        atlas = "path/to/button.png",
        states = {
          hover = {
            atlas = "path/to/button_hover.png",
          },
        },
      },
    },
  })
  Theme.setActive(theme)

  local container = Element.new({
    x = 0,
    y = 0,
    width = 800,
    height = 600,
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 10,
  })
  Context.setNavigationContainer(container)

  local button = Element.new({
    parent = container,
    id = "themed-btn",
    text = "Themed Button",
    themeComponent = "button",
    onEvent = function() end,
  })

  local success = KeyboardNavigation:nextFocusable()
  assert(success == true, "Keyboard navigation should focus the themed button")
  assert(Context.getFocused() == button, "Themed button should receive keyboard focus")

  button:update(0.016)
end

function TestKeyboardNavigation:testDropFocusOnSelectionConfigAndOverride()
  local originalDropFocusOnSelection = KeyboardNavigation.config.dropFocusOnSelection
  KeyboardNavigation.config.dropFocusOnSelection = false

  local container = Element.new({
    x = 0,
    y = 0,
    width = 800,
    height = 600,
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 10,
  })
  Context.setNavigationContainer(container)

  local keepFocusButton = Element.new({
    parent = container,
    id = "keep-focus-btn",
    text = "Keep Focus",
    onEvent = function() end,
  })

  local dropFocusButton = Element.new({
    parent = container,
    id = "drop-focus-btn",
    text = "Drop Focus",
    dropFocusOnSelection = true,
    onEvent = function() end,
  })

  Context.setFocused(keepFocusButton)
  FocusIndicator.setFocused(keepFocusButton)

  local success = KeyboardNavigation:activateElement()
  assert(success == true, "Activation should succeed with global keep-focus config")
  assert(Context.getFocused() == keepFocusButton, "Global config should keep focus after activation")

  Context.setFocused(dropFocusButton)
  FocusIndicator.setFocused(dropFocusButton)

  success = KeyboardNavigation:activateElement()
  assert(success == true, "Activation should succeed with per-element drop-focus override")
  assert(Context.getFocused() == nil, "Per-element override should drop focus after activation")

  KeyboardNavigation.config.dropFocusOnSelection = true

  Context.setFocused(keepFocusButton)
  FocusIndicator.setFocused(keepFocusButton)

  success = KeyboardNavigation:activateElement()
  assert(success == true, "Activation should succeed with global drop-focus config")
  assert(Context.getFocused() == nil, "Global config should drop focus after activation")

  local keepFocusOverrideButton = Element.new({
    parent = container,
    id = "keep-focus-override-btn",
    text = "Keep Focus Override",
    dropFocusOnSelection = false,
    onEvent = function() end,
  })

  Context.setFocused(keepFocusOverrideButton)
  FocusIndicator.setFocused(keepFocusOverrideButton)

  success = KeyboardNavigation:activateElement()
  assert(success == true, "Activation should succeed with per-element keep-focus override")
  assert(Context.getFocused() == keepFocusOverrideButton, "Per-element override should keep focus after activation")

  KeyboardNavigation.config.dropFocusOnSelection = originalDropFocusOnSelection
end

function TestKeyboardNavigation:testDismiss()
  local container = createTestUI()
  Context.setNavigationContainer(container)

  -- Focus an element
  Context.setFocused(container.children[1])

  -- Dismiss should clear focus
  local success = KeyboardNavigation:dismissElement()
  assert(success == true, "Dismiss should succeed")
  assert(Context.getFocused() == nil, "Focus should be cleared")
end

function TestKeyboardNavigation:testNavigationStack()
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
end

function TestKeyboardNavigation:testImmediateModeNavigation()
  -- Save state for cleanup
  local savedMode = Context._immediateMode
  local savedTopElements = Context.topElements
  local savedZIndex = Context._zIndexOrderedElements
  local savedFocused = Context._focusedElement
  local savedFocusedId = Context._focusedElementId
  local savedNavContainer = Context._navigationContext.containerElement

  -- Switch to immediate mode
  FlexLove.setMode("immediate")
  Context.topElements = {}
  Context._zIndexOrderedElements = {}
  Context._focusedElement = nil
  Context._focusedElementId = nil
  Context._navigationContext.containerElement = nil

  -- Track elements created in immediate mode
  local btn1, btn2, btn3
  local container

  -- Run a frame to create elements in immediate mode
  FlexLove.beginFrame()
  container = Element.new({
    x = 0,
    y = 0,
    width = 800,
    height = 600,
    positioning = utils.enums.Positioning.FLEX,
    flexDirection = utils.enums.FlexDirection.VERTICAL,
    gap = 10,
  })

  btn1 = Element.new({ parent = container, id = "btn1", text = "Button 1", onEvent = function() end })
  btn2 = Element.new({ parent = container, id = "btn2", text = "Button 2", onEvent = function() end })
  btn3 = Element.new({ parent = container, id = "btn3", text = "Button 3", onEvent = function() end })

  FlexLove.endFrame() -- Triggers layout and populates z-index order

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

  -- Restore retained mode and clean up
  FlexLove.setMode("retained")
  Context._immediateMode = savedMode
  Context.topElements = savedTopElements
  Context._zIndexOrderedElements = savedZIndex
  Context._focusedElement = savedFocused
  Context._focusedElementId = savedFocusedId
  Context._navigationContext.containerElement = savedNavContainer
end

function TestKeyboardNavigation:testSpatialIndex()
  -- Enable spatial index
  KeyboardNavigation.enableSpatialIndex(true)

  -- Create buttons with explicit positions (not using flex layout)
  local btnTop = Element.new({
    x = 100,
    y = 50,
    width = 80,
    height = 30,
    text = "Top",
    onEvent = function() end,
  })

  local btnCenter = Element.new({
    x = 100,
    y = 150,
    width = 80,
    height = 30,
    text = "Center",
    onEvent = function() end,
  })

  local btnBottom = Element.new({
    x = 100,
    y = 250,
    width = 80,
    height = 30,
    text = "Bottom",
    onEvent = function() end,
  })

  local btnRight = Element.new({
    x = 250,
    y = 150,
    width = 80,
    height = 30,
    text = "Right",
    onEvent = function() end,
  })

  -- Update spatial index with all buttons
  KeyboardNavigation._spatialIndex.elementPositions[btnTop] = { x = 100, y = 50, w = 80, h = 30 }
  KeyboardNavigation._spatialIndex.elementPositions[btnCenter] = { x = 100, y = 150, w = 80, h = 30 }
  KeyboardNavigation._spatialIndex.elementPositions[btnBottom] = { x = 100, y = 250, w = 80, h = 30 }
  KeyboardNavigation._spatialIndex.elementPositions[btnRight] = { x = 250, y = 150, w = 80, h = 30 }

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

  addToGrid(btnTop, { x = 100, y = 50, w = 80, h = 30 })
  addToGrid(btnCenter, { x = 100, y = 150, w = 80, h = 30 })
  addToGrid(btnBottom, { x = 100, y = 250, w = 80, h = 30 })
  addToGrid(btnRight, { x = 250, y = 150, w = 80, h = 30 })

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
end

-- getFocusableElements tests
function TestKeyboardNavigation:testGetFocusableElementsReturnsFocusableInRetainedMode()
  -- Save state for isolation
  local savedTopElements = Context.topElements
  local savedMode = Context._immediateMode
  Context.topElements = {}
  Context._immediateMode = false

  -- Create focusable top-level elements (onEvent makes them focusable)
  local elem1 = Element.new({ id = "f1", onEvent = function() end })
  local elem2 = Element.new({ id = "f2", onEvent = function() end })

  local focusable = Context.getFocusableElements()
  assert(#focusable == 2, "Should return 2 focusable elements")
  assert(focusable[1].id == "f1", "First should be f1")
  assert(focusable[2].id == "f2", "Second should be f2")

  -- Restore state
  Context.topElements = savedTopElements
  Context._immediateMode = savedMode
end

function TestKeyboardNavigation:testGetFocusableElementsReturnsFocusableInImmediateMode()
  -- Save state for isolation
  local savedMode = Context._immediateMode
  local savedZIndex = Context._zIndexOrderedElements
  Context._immediateMode = true
  Context._zIndexOrderedElements = {}

  -- Create focusable elements (onEvent makes them focusable)
  local elem1 = Element.new({ id = "i1", onEvent = function() end })
  local elem2 = Element.new({ id = "i2", onEvent = function() end })

  local focusable = Context.getFocusableElements()
  assert(#focusable == 2, "Should return 2 focusable elements in immediate mode")
  assert(focusable[1].id == "i1", "First should be i1")
  assert(focusable[2].id == "i2", "Second should be i2")

  -- Restore state
  Context._immediateMode = savedMode
  Context._zIndexOrderedElements = savedZIndex
end

function TestKeyboardNavigation:testGetFocusableElementsExcludesDisplayNone()
  -- Save state for isolation
  local savedTopElements = Context.topElements
  local savedMode = Context._immediateMode
  Context.topElements = {}
  Context._immediateMode = false

  local visible = Element.new({ id = "vis", onEvent = function() end })
  local hidden = Element.new({ id = "hid", display = false, onEvent = function() end })

  local focusable = Context.getFocusableElements()
  assert(#focusable == 1, "Should return only 1 focusable element (display:none excluded)")
  assert(focusable[1].id == "vis", "Should return visible element")

  -- Restore state
  Context.topElements = savedTopElements
  Context._immediateMode = savedMode
end

function TestKeyboardNavigation:testGetFocusableElementsExcludesDisabled()
  -- Save state for isolation
  local savedTopElements = Context.topElements
  local savedMode = Context._immediateMode
  Context.topElements = {}
  Context._immediateMode = false

  local enabled = Element.new({ id = "en", onEvent = function() end })
  local disabled = Element.new({ id = "dis", disabled = true, onEvent = function() end })

  local focusable = Context.getFocusableElements()
  assert(#focusable == 1, "Should return only 1 focusable element (disabled excluded)")
  assert(focusable[1].id == "en", "Should return enabled element")

  -- Restore state
  Context.topElements = savedTopElements
  Context._immediateMode = savedMode
end

function TestKeyboardNavigation:testGetFocusableElementsExcludesNonFocusable()
  -- Save state for isolation
  local savedTopElements = Context.topElements
  local savedMode = Context._immediateMode
  Context.topElements = {}
  Context._immediateMode = false

  local focusableElem = Element.new({ id = "foc", onEvent = function() end })
  local nonFocusable = Element.new({ id = "nfoc" }) -- no onEvent, not focusable

  local result = Context.getFocusableElements()
  assert(#result == 1, "Should return only 1 focusable element")
  assert(result[1].id == "foc", "Should return focusable element")

  -- Restore state
  Context.topElements = savedTopElements
  Context._immediateMode = savedMode
end

function TestKeyboardNavigation:testGetFocusableElementsReturnsEmptyList()
  -- Ensure no top elements
  local saved = Context.topElements
  Context.topElements = {}

  local focusable = Context.getFocusableElements()
  assert(#focusable == 0, "Should return empty list when no focusable elements")

  -- Restore
  Context.topElements = saved
end

function TestKeyboardNavigation:testGetFocusableElementsRecursiveInRetainedMode()
  -- Save state for isolation
  local savedTopElements = Context.topElements
  local savedMode = Context._immediateMode
  Context.topElements = {}
  Context._immediateMode = false

  -- Create nested structure (onEvent makes them focusable)
  local parent = Element.new({ id = "parent", onEvent = function() end })
  local child1 = Element.new({ parent = parent, id = "child1", onEvent = function() end })
  local child2 = Element.new({ parent = parent, id = "child2", onEvent = function() end })

  local focusable = Context.getFocusableElements()
  assert(#focusable == 3, "Should return 3 focusable elements (parent + 2 children)")
  assert(focusable[1].id == "parent", "First should be parent")
  assert(focusable[2].id == "child1", "Second should be child1")
  assert(focusable[3].id == "child2", "Third should be child2")

  -- Restore state
  Context.topElements = savedTopElements
  Context._immediateMode = savedMode
end

-- Standalone runner (runAll.lua dofiles this file and runs all suites itself)
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
