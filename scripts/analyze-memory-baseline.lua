#!/usr/bin/env lua
-- Memory Baseline Analysis
-- Analyzes base memory usage and per-element costs

-- Add libs directory to package path
package.path = package.path .. ";./?.lua;./?/init.lua"

-- Mock LÖVE
_G.love = {
  graphics = {
    newCanvas = function() return {} end,
    newImage = function() return {} end,
    setCanvas = function() end,
    clear = function() end,
    setColor = function() end,
    draw = function() end,
    rectangle = function() end,
    print = function() end,
    getDimensions = function() return 800, 600 end,
    getColor = function() return 1, 1, 1, 1 end,
    setBlendMode = function() end,
    setScissor = function() end,
    getScissor = function() return nil end,
    push = function() end,
    pop = function() end,
    translate = function() end,
    rotate = function() end,
    scale = function() end,
    newFont = function() return {} end,
    setFont = function() end,
    getFont = function() return { getHeight = function() return 12 end } end,
  },
  window = { getMode = function() return 800, 600 end },
  timer = { getTime = function() return os.clock() end },
  image = { newImageData = function() return {} end },
  mouse = { getPosition = function() return 0, 0 end },
}

local FlexLove = require("FlexLove")
local MemoryScanner = require("modules.MemoryScanner")
local StateManager = require("modules.StateManager")
local Context = require("modules.Context")
local ImageCache = require("modules.ImageCache")
local ErrorHandler = require("modules.ErrorHandler")

print("=== Memory Baseline Analysis ===")
print("")

-- Baseline: Just FlexLove loaded
collectgarbage("collect")
collectgarbage("collect")
local baseline = collectgarbage("count") / 1024
print(string.format("1. FlexLove loaded (no init): %.2f MB", baseline))

-- Initialize FlexLove
FlexLove.init({ immediateMode = true })
collectgarbage("collect")
collectgarbage("collect")
local afterInit = collectgarbage("count") / 1024
print(string.format("2. After init(): %.2f MB (+%.2f MB)", afterInit, afterInit - baseline))

-- Create 1 simple element
FlexLove.beginFrame()
FlexLove.new({ id = "test1", width = 100, height = 100 })
FlexLove.endFrame()
collectgarbage("collect")
collectgarbage("collect")
local after1Element = collectgarbage("count") / 1024
print(string.format("3. After 1 element: %.2f MB (+%.2f KB)", after1Element, (after1Element - afterInit) * 1024))

-- Create 10 more elements (total 11)
FlexLove.beginFrame()
for i = 1, 10 do
  FlexLove.new({ id = "elem" .. i, width = 100, height = 100 })
end
FlexLove.endFrame()
collectgarbage("collect")
collectgarbage("collect")
local after10Elements = collectgarbage("count") / 1024
print(string.format("4. After 10 more elements: %.2f MB (+%.2f KB)", after10Elements, (after10Elements - after1Element) * 1024))
print(string.format("   Per element: ~%.2f KB", (after10Elements - after1Element) * 1024 / 10))

-- Create 100 more elements
FlexLove.beginFrame()
for i = 1, 100 do
  FlexLove.new({ id = "bulk" .. i, width = 100, height = 100 })
end
FlexLove.endFrame()
collectgarbage("collect")
collectgarbage("collect")
local after100Elements = collectgarbage("count") / 1024
print(string.format("5. After 100 more elements: %.2f MB (+%.2f KB)", after100Elements, (after100Elements - after10Elements) * 1024))
print(string.format("   Per element: ~%.2f KB", (after100Elements - after10Elements) * 1024 / 100))

print("")
print("=== Memory Breakdown ===")

-- Initialize scanner
MemoryScanner.init({
  StateManager = StateManager,
  Context = Context,
  ImageCache = ImageCache,
  ErrorHandler = ErrorHandler,
})

local smReport = MemoryScanner.scanStateManager()
print(string.format("StateManager: %d states, %.2f KB total", smReport.stateCount, smReport.stateStoreSize / 1024))
if smReport.stateCount > 0 then
  print(string.format("  Per state: ~%.2f KB", smReport.stateStoreSize / smReport.stateCount / 1024))
end
print(string.format("  Metadata: %.2f KB", smReport.metadataSize / 1024))

print("")
print("=== Detailed State Analysis ===")

-- Analyze a single state
local sampleState = StateManager.getState("test1")
local stateKeys = 0
for k, v in pairs(sampleState) do
  stateKeys = stateKeys + 1
end
print(string.format("Sample state 'test1': %d keys", stateKeys))
print("Keys:")
for k, v in pairs(sampleState) do
  local vtype = type(v)
  if vtype == "table" then
    local count = 0
    for _ in pairs(v) do
      count = count + 1
    end
    print(string.format("  %s: table (%d items)", k, count))
  else
    print(string.format("  %s: %s = %s", k, vtype, tostring(v)))
  end
end

print("")
print("=== Optimization Targets ===")
print("")

-- Calculate potential savings
local stateOverhead = smReport.stateStoreSize / smReport.stateCount
print(string.format("1. StateManager per-state overhead: %.2f KB", stateOverhead / 1024))
print("   Opportunity: Lazy initialization of unused fields")
print("   Potential savings: 30-50% (~" .. string.format("%.2f", stateOverhead * 0.4 / 1024) .. " KB per state)")
print("")

print("2. Element instance size: ~" .. string.format("%.2f", (after10Elements - after1Element) * 1024 / 10) .. " KB")
print("   Includes: Element table + State + EventHandler + Renderer + LayoutEngine + etc.")
print("   Opportunity: Lazy module initialization, shared instances")
print("   Potential savings: 20-30%")
print("")

print("3. Module instances per element:")
print("   - EventHandler (always created)")
print("   - Renderer (always created)")
print("   - LayoutEngine (always created)")
print("   - ThemeManager (always created)")
print("   - ScrollManager (conditional)")
print("   - TextEditor (conditional)")
print("   Opportunity: Share non-stateful modules, lazy init conditional ones")
print("")

local totalMemory = after100Elements
print(string.format("Total memory with 111 elements: %.2f MB", totalMemory))
print(string.format("Potential savings with optimizations: %.2f - %.2f MB (30-50%%)",
  totalMemory * 0.3, totalMemory * 0.5))
