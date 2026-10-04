-- Regression tests: managed-select dropdown options must receive hover and
-- press events in immediate mode.
--
-- Bug: Context.findInteractiveAtPosition pruned traversal at any element whose
-- bounds did not contain the cursor. Dropdown options render BELOW the
-- trigger's border box (managed select frame anchored to its bottom edge), so
-- traversal stopped at the trigger and the options were never collected as
-- interactive candidates. Clickable.onUpdate then computed
-- isActiveElement=false for every option, leaving them without hover feedback
-- and dead to presses — while the click fell through to whatever interactive
-- element happened to sit underneath the dropdown in the settings window.
--
-- The fix mirrors flexlove.getElementAtPosition: only clipping ancestors
-- (overflow hidden/scroll/auto) prune out-of-bounds descendants, and invisible
-- subtrees (display=false / visibility=hidden / opacity<=0) are pruned so a
-- closed dropdown stays inert.
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

local luaunit = require("testing.luaunit")
require("testing.loveStub")
local FlexLove = require("FlexLove")

local Context = require("modules.Context")

local display_mode_options = {
  { value = "windowed", label = "Windowed" },
  { value = "exclusive", label = "Fullscreen" },
  { value = "desktop", label = "Borderless Fullscreen" },
}

-- Captured per-frame element refs (elements are recreated every frame in
-- immediate mode).
local refs = {}

---Rebuild the dropdown each frame, mirroring the game-loop immediate-mode
---pattern (UI created during draw, finalized by endFrame).
local function draw_dropdown()
  refs = {}
  local root = FlexLove.new({ id = "root", width = 800, height = 600, themeComponent = "framev3" })

  local frame = FlexLove.new({
    positioning = "flex",
    flexDirection = "vertical",
    gap = 2,
    padding = 6,
    z = 100,
  })

  local trigger = FlexLove.new({
    parent = root,
    positioning = "absolute",
    left = 300,
    top = 100,
    width = 200,
    height = 40,
    themeComponent = "buttonv2",
    selectParent = {
      value = "exclusive",
      selectFrame = frame,
      onChange = function(_, value)
        refs.changedValue = value
      end,
    },
  })

  for _, option in ipairs(display_mode_options) do
    FlexLove.new({
      parent = trigger,
      width = "100%",
      height = 32,
      text = option.label,
      themeComponent = "buttonv2",
      selectOption = { value = option.value, label = option.label },
    })
  end

  refs.root = root
  refs.frame = frame
  refs.trigger = trigger
end

local function frame()
  FlexLove.update(1 / 60)
  draw_dropdown()
  FlexLove.endFrame()
end

local function moveMouse(x, y)
  FlexLove.Input.setVirtualState({ x = x, y = y })
  frame()
end

local function click(x, y)
  FlexLove.Input.setVirtualState({ x = x, y = y })
  FlexLove.Input.setButton(1, true)
  frame()
  FlexLove.Input.setButton(1, false)
  frame()
end

TestSelectImmediateInteractivity = {}

function TestSelectImmediateInteractivity:setUp()
  FlexLove.destroy()
  FlexLove.init({ immediateMode = true })
  FlexLove.setMode("immediate")
  FlexLove.Input.useVirtual(true)
  FlexLove.Input.setVirtualState({ x = -100, y = -100, buttons = {}, keys = {} })
  frame()
  frame()
end

function TestSelectImmediateInteractivity:tearDown()
  FlexLove.destroy()
  FlexLove.Input.useVirtual(false)
end

function TestSelectImmediateInteractivity:testDropdownOpensOnTriggerClick()
  local trigger = refs.trigger
  click(trigger.x + trigger:getBorderBoxWidth() / 2, trigger.y + trigger:getBorderBoxHeight() / 2)

  luaunit.assertTrue(refs.trigger:isSelectOpen(), "dropdown should be open after clicking the trigger")
  luaunit.assertEquals(refs.trigger._selectState.selectFrame.visibility, "visible")
end

function TestSelectImmediateInteractivity:testOptionReceivesHoverWhenOpen()
  local trigger = refs.trigger
  click(trigger.x + trigger:getBorderBoxWidth() / 2, trigger.y + trigger:getBorderBoxHeight() / 2)
  luaunit.assertTrue(refs.trigger:isSelectOpen())

  local option = refs.trigger._selectState.options[1]
  local ox, oy = option.x, option.y
  local ow, oh = option:getBorderBoxWidth(), option:getBorderBoxHeight()

  moveMouse(ox + ow / 2, oy + oh / 2)

  local hovered = refs.trigger._selectState.options[1]
  luaunit.assertTrue(hovered._eventHandler:getState()._hovered, "option should register hover")
  luaunit.assertEquals(hovered._themeManager._themeState, "hover", "option should switch to hover theme state")
  luaunit.assertTrue(
    Context.findInteractiveAtPosition(ox + ow / 2, oy + oh / 2) == hovered,
    "option should be the topmost interactive element"
  )
end

function TestSelectImmediateInteractivity:testOptionClickAppliesSelection()
  local trigger = refs.trigger
  click(trigger.x + trigger:getBorderBoxWidth() / 2, trigger.y + trigger:getBorderBoxHeight() / 2)

  local option = refs.trigger._selectState.options[1] -- "Windowed"
  click(option.x + option:getBorderBoxWidth() / 2, option.y + option:getBorderBoxHeight() / 2)

  luaunit.assertEquals(refs.changedValue, "windowed", "onChange should fire for the pressed option")
end

function TestSelectImmediateInteractivity:testClosedDropdownStaysInert()
  local trigger = refs.trigger
  luaunit.assertFalse(refs.trigger:isSelectOpen())

  -- An option's position while closed overlaps the root below the trigger.
  -- Hovering there must NOT flag the hidden option as hovered/active, and the
  -- interactive lookup must not return anything from the dropdown subtree.
  local option = refs.trigger._selectState.options[1]
  local ox, oy = option.x, option.y
  local ow, oh = option:getBorderBoxWidth(), option:getBorderBoxHeight()

  moveMouse(ox + ow / 2, oy + oh / 2)

  local current = refs.trigger._selectState.options[1]
  luaunit.assertFalse(current._eventHandler:getState()._hovered, "closed dropdown option must not hover")
  luaunit.assertNotEquals(Context.findInteractiveAtPosition(ox + ow / 2, oy + oh / 2), current)
end

os.exit(luaunit.LuaUnit.run())
