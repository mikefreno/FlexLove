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

-- Regression tests for issue #9: managed selectFrame dropdown behavior.
-- Covers trigger/option label rendering, anchor alignment + resize tracking,
-- hit-testing options that overflow the trigger, and closed-state inertness.

TestSelectFrameBehavior = {}

function TestSelectFrameBehavior:setUp()
  FlexLove.destroy()
  FlexLove.init()
  FlexLove.setMode("retained")
end

function TestSelectFrameBehavior:tearDown()
  FlexLove.destroy()
end

local function buildDropdown(props)
  props = props or {}
  local root = FlexLove.new({ id = "root", width = 800, height = 600 })
  local frame = FlexLove.new({
    id = "dropdown_frame",
    positioning = "flex",
    flexDirection = "vertical",
    gap = 2,
    padding = 4,
  })
  local sp = FlexLove.new({
    id = "select_parent",
    parent = root,
    positioning = "absolute",
    left = props.x or 40,
    top = props.y or 60,
    width = props.width or 200,
    height = props.height or 40,
    padding = props.padding or 8,
    text = props.text or "Choose",
    selectParent = {
      value = props.value or "windowed",
      placeholder = props.placeholder or "Choose",
      selectFrame = frame,
    },
  })
  local optionA = FlexLove.new({
    id = "option_windowed",
    parent = sp,
    height = 30,
    selectOption = { value = "windowed", label = "Windowed" },
  })
  local optionB = FlexLove.new({
    id = "option_fullscreen",
    parent = sp,
    height = 30,
    selectOption = { value = "exclusive", label = "Fullscreen" },
  })
  return root, frame, sp, optionA, optionB
end

-- Option labels render without a duplicate `text` prop.
function TestSelectFrameBehavior:test_option_label_renders_without_text()
  local _, _, _, optionA = buildDropdown()
  luaunit.assertEquals(optionA.text, "Windowed")
end

-- The trigger displays the placeholder, then the selected option's label.
function TestSelectFrameBehavior:test_trigger_shows_selected_label()
  local _, _, sp = buildDropdown({ value = "exclusive", placeholder = "Pick one" })
  luaunit.assertEquals(sp.text, "Fullscreen", "trigger shows selected option label")

  sp:setSelectValue("windowed")
  luaunit.assertEquals(sp.text, "Windowed", "trigger label follows selection")
end

-- The managed anchor sits on the trigger's border-box bottom-left edge.
function TestSelectFrameBehavior:test_anchor_aligns_to_trigger_border_box()
  local _, _, sp = buildDropdown({ x = 40, y = 60, padding = 12 })
  local anchor = sp._selectState.selectAnchor

  luaunit.assertNotNil(anchor)
  luaunit.assertEquals(anchor.x, sp.x, "anchor aligns to trigger left edge")
  luaunit.assertEquals(anchor.y, sp.y + sp:getBorderBoxHeight(), "anchor sits below trigger")
end

-- Anchor geometry tracks the trigger across viewport resizes (no one-resize lag).
function TestSelectFrameBehavior:test_anchor_follows_trigger_on_resize()
  FlexLove.destroy()
  FlexLove.init()
  FlexLove.setMode("retained")

  local root = FlexLove.new({ id = "root", width = "100%", height = "100%" })
  local frame = FlexLove.new({ id = "frame", positioning = "flex", flexDirection = "vertical" })
  local sp = FlexLove.new({
    id = "sp",
    parent = root,
    width = "50%",
    height = "20%",
    selectParent = { value = "a", selectFrame = frame },
  })
  local anchor = sp._selectState.selectAnchor
  FlexLove.update(0.016)

  love.window.setMode(1200, 400)
  FlexLove.resize()
  FlexLove.update(0.016)
  luaunit.assertEquals(anchor.y, sp.y + sp:getBorderBoxHeight(), "anchor follows first resize")

  love.window.setMode(600, 900)
  FlexLove.resize()
  FlexLove.update(0.016)
  luaunit.assertEquals(anchor.y, sp.y + sp:getBorderBoxHeight(), "anchor follows second resize")
end

-- Options overflowing the trigger remain hit-testable while the dropdown is open.
function TestSelectFrameBehavior:test_option_outside_trigger_is_hittable_when_open()
  local _, _, sp, _, optionB = buildDropdown()
  FlexLove.update(0.016)

  local cx = optionB.x + optionB:getBorderBoxWidth() / 2
  local cy = optionB.y + optionB:getBorderBoxHeight() / 2
  luaunit.assertTrue(cy > sp.y + sp:getBorderBoxHeight(), "option is below the trigger")

  local closedHit = FlexLove.getElementAtPosition(cx, cy)
  luaunit.assertNotEquals(closedHit and closedHit.id, "option_fullscreen", "closed option is inert")

  sp:openSelect()
  FlexLove.update(0.016)
  local openHit = FlexLove.getElementAtPosition(cx, cy)
  luaunit.assertEquals(openHit and openHit.id, "option_fullscreen", "open option receives the hit")
end

-- Releasing an option while the dropdown is closed must not change the value.
function TestSelectFrameBehavior:test_option_release_ignored_when_closed()
  local _, _, sp, _, optionB = buildDropdown()

  optionB:_handleSelectRelease()
  luaunit.assertEquals(sp:getSelectValue(), "windowed", "closed option release is ignored")

  sp:openSelect()
  optionB:_handleSelectRelease()
  luaunit.assertEquals(sp:getSelectValue(), "exclusive", "open option release selects")
  luaunit.assertFalse(sp:isSelectOpen(), "select closes after selection")
end

-- ============================================================================
-- Immediate mode: elements are recreated each frame, so the open state and the
-- managed frame's visibility must survive the recreation cycle.
-- ============================================================================

TestSelectFrameImmediate = {}

function TestSelectFrameImmediate:setUp()
  FlexLove.destroy()
  FlexLove.init()
  FlexLove.setMode("immediate")
  love.mouse.setDown(1, false)
end

function TestSelectFrameImmediate:tearDown()
  love.mouse.setDown(1, false)
  FlexLove.destroy()
  FlexLove.setMode("retained")
end

function TestSelectFrameImmediate:frame()
  FlexLove.beginFrame()
  local root = FlexLove.new({ id = "imm_root", width = 800, height = 600 })
  local frame = FlexLove.new({ id = "imm_frame", positioning = "flex", flexDirection = "vertical" })
  local sp = FlexLove.new({
    id = "imm_sp",
    parent = root,
    width = 200,
    height = 40,
    selectParent = { value = "windowed", placeholder = "Choose", selectFrame = frame },
  })
  FlexLove.new({ id = "imm_o1", parent = sp, height = 30, selectOption = { value = "windowed", label = "Windowed" } })
  FlexLove.new({ id = "imm_o2", parent = sp, height = 30, selectOption = { value = "exclusive", label = "Fullscreen" } })
  FlexLove.endFrame()
  return sp
end

function TestSelectFrameImmediate:test_trigger_opens_dropdown()
  local sp = self:frame()

  love.mouse.setPosition(sp.x + 5, sp.y + 5)
  love.mouse.setDown(1, true)
  sp = self:frame()
  love.mouse.setDown(1, false)
  sp = self:frame()

  luaunit.assertTrue(sp:isSelectOpen(), "trigger click opens dropdown")
  local frame = sp._selectState.selectFrame
  luaunit.assertEquals(frame.visibility, "visible", "open dropdown is visible")
  luaunit.assertFalse(frame.disabled, "open dropdown accepts input")
end

function TestSelectFrameImmediate:test_option_click_selects_across_frames()
  local sp = self:frame()
  love.mouse.setPosition(sp.x + 5, sp.y + 5)
  love.mouse.setDown(1, true)
  sp = self:frame()
  love.mouse.setDown(1, false)
  sp = self:frame()

  local option = sp._selectState.selectFrame.children[2]
  luaunit.assertEquals(FlexLove.getElementAtPosition(option.x + 5, option.y + 5), option)

  love.mouse.setPosition(option.x + 5, option.y + 5)
  love.mouse.setDown(1, true)
  sp = self:frame()
  love.mouse.setDown(1, false)
  sp = self:frame()

  luaunit.assertEquals(sp:getSelectValue(), "exclusive")
  luaunit.assertEquals(sp.text, "Fullscreen")
  luaunit.assertFalse(sp:isSelectOpen())
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
