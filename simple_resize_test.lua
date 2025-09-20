#!/usr/bin/env lua

-- Load test framework and dependencies
package.path = package.path .. ";?.lua"
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums
local Positioning, FlexDirection, AlignItems =
  enums.Positioning, enums.FlexDirection, enums.AlignItems

-- Simple resize test
print("=== Simple Resize Test ===")

-- Initial window size: 800x600
love.window.setMode(800, 600)

local parent = Gui.new({
  id = "parent",
  x = 100,
  y = 100,
  w = 200,
  h = 150,
  positioning = Positioning.FLEX,
  flexDirection = FlexDirection.HORIZONTAL,
  alignItems = AlignItems.STRETCH,
})

local child = Gui.new({
  id = "child",
  w = 100,
  h = 80,
  positioning = Positioning.FLEX,
})

parent:addChild(child)

print("Before resize:")
print("  Parent: x=" .. parent.x .. ", y=" .. parent.y .. ", w=" .. parent.width .. ", h=" .. parent.height)
print("  Child: x=" .. child.x .. ", y=" .. child.y .. ", w=" .. child.width .. ", h=" .. child.height)

-- Resize window to 1600x1200 (2x scale)
love.window.setMode(1600, 1200)
Gui.resize()

print("After resize to 1600x1200:")
print("  Parent: x=" .. parent.x .. ", y=" .. parent.y .. ", w=" .. parent.width .. ", h=" .. parent.height)
print("  Child: x=" .. child.x .. ", y=" .. child.y .. ", w=" .. child.width .. ", h=" .. child.height)

print("Expected child dimensions after 2x resize:")
print("  Child width: 200 (100 * 2)")
print("  Child height: 160 (80 * 2)")