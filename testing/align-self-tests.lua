package.path = package.path
  .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua;./testing/?.lua"

local luaunit = require("testing.luaunit")
require("testing.love_helper")

local Gui = require("game.libs.FlexLove").GUI
local enums = require("game.libs.FlexLove").enums

-- Test case for align self properties
TestAlignSelf = {}

function TestAlignSelf:testAutoAlignSelf()
  -- Create a flex container with default alignment
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add a child with auto align self
  local child = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
    alignSelf = enums.AlignSelf.AUTO,
  })

  -- Layout children
  window:layoutChildren()

  -- With auto, child should inherit alignment from parent's alignItems
  luaunit.assertEquals(child.alignSelf, enums.AlignSelf.AUTO)
end

function TestAlignSelf:testStretchAlignSelf()
  -- Create a flex container with stretch alignment
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add a child with stretch align self
  local child = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
    alignSelf = enums.AlignSelf.STRETCH,
  })

  -- Layout children
  window:layoutChildren()

  -- With stretch, child should be stretched to fill container height
  luaunit.assertEquals(child.height, 200) -- Should stretch to full container height
end

function TestAlignSelf:testFlexStartAlignSelf()
  -- Create a flex container with center alignment
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add a child with flex-start align self
  local child = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
    alignSelf = enums.AlignSelf.FLEX_START,
  })

  -- Layout children
  window:layoutChildren()

  -- With flex-start, child should be aligned to the start of cross axis (top)
  luaunit.assertEquals(child.y, 0) -- Should be at top position
end

function TestAlignSelf:testFlexEndAlignSelf()
  -- Create a flex container with center alignment
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add a child with flex-end align self
  local child = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
    alignSelf = enums.AlignSelf.FLEX_END,
  })

  -- Layout children
  window:layoutChildren()

  -- With flex-end, child should be aligned to the end of cross axis (bottom)
  luaunit.assertEquals(child.y, 200 - 30) -- Should be at bottom position
end

function TestAlignSelf:testCenterAlignSelf()
  -- Create a flex container with stretch alignment
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.STRETCH,
  })

  -- Add a child with center align self
  local child = Gui.new({
    parent = window,
    w = 50,
    h = 30,
    text = "Test Button",
    alignSelf = enums.AlignSelf.CENTER,
  })

  -- Layout children
  window:layoutChildren()

  -- With center, child should be centered along cross axis
  luaunit.assertEquals(child.x, 0)
  luaunit.assertEquals(child.y, (200 - 30) / 2) -- Should be centered vertically
end

function TestAlignSelf:testVerticalAlignSelf()
  -- Create a vertical flex container with center alignment
  local window = Gui.new({
    x = 0,
    y = 0,
    w = 300,
    h = 200,
    positioning = enums.Positioning.FLEX,
    flexDirection = enums.FlexDirection.VERTICAL,
    justifyContent = enums.JustifyContent.FLEX_START,
    alignItems = enums.AlignItems.CENTER,
  })

  -- Add a child with center align self
  local child = Gui.new({
    parent = window,
    x = 0,
    y = 0,
    w = 50,
    h = 30,
    text = "Test Button",
    alignSelf = enums.AlignSelf.CENTER,
  })

  -- Layout children
  window:layoutChildren()

  -- With vertical container, align self affects the X axis
  luaunit.assertEquals(child.x, (300 - 50) / 2) -- Should be centered horizontally
end

-- Run the tests
luaunit.LuaUnit.run()
