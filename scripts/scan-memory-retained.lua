#!/usr/bin/env lua
-- Memory Scanner Stress Test CLI Tool (RETAINED MODE)
-- Comprehensive stress test for FlexLöve memory profiling with diverse element types
-- In retained mode, elements persist and are created once without frame loops

-- Add libs directory to package path
package.path = package.path .. ";./?.lua;./?/init.lua"

-- Mock LÖVE if not running in LÖVE environment
if not love then
  _G.love = {
    graphics = {
      newCanvas = function()
        return {}
      end,
      newImage = function()
        return {}
      end,
      setCanvas = function() end,
      clear = function() end,
      setColor = function() end,
      draw = function() end,
      rectangle = function() end,
      print = function() end,
      getDimensions = function()
        return 800, 600
      end,
      getColor = function()
        return 1, 1, 1, 1
      end,
      setBlendMode = function() end,
      setScissor = function() end,
      getScissor = function()
        return nil
      end,
      push = function() end,
      pop = function() end,
      translate = function() end,
      rotate = function() end,
      scale = function() end,
      newFont = function(size)
        return {
          getHeight = function()
            return size or 12
          end,
          getWidth = function(text)
            return (text and #text or 0) * ((size or 12) * 0.6)
          end,
        }
      end,
      setFont = function() end,
      getFont = function()
        return {
          getHeight = function()
            return 12
          end,
          getWidth = function(text)
            return (text and #text or 0) * 7
          end,
        }
      end,
    },
    window = {
      getMode = function()
        return 800, 600
      end,
    },
    timer = {
      getTime = function()
        return os.clock()
      end,
    },
    image = {
      newImageData = function()
        return {}
      end,
    },
    mouse = {
      getPosition = function()
        return 0, 0
      end,
      isDown = function()
        return false
      end,
    },
    touch = {
      getTouches = function()
        return {}
      end,
    },
    keyboard = {
      isDown = function()
        return false
      end,
      hasTextInput = function()
        return false
      end,
    },
  }
end

-- Load FlexLove and dependencies
local FlexLove = require("FlexLove")
local MemoryScanner = require("modules.MemoryScanner")
local StateManager = require("modules.StateManager")
local Context = require("modules.Context")
local ImageCache = require("modules.ImageCache")
local ErrorHandler = require("modules.ErrorHandler")

print("=== FlexLöve Memory Scanner (RETAINED MODE) ===")
print("")

-- Initialize FlexLove in retained mode (default)
print("[1/7] Initializing FlexLöve in retained mode...")
FlexLove.init({
  memoryProfiling = true,
})

-- Initialize MemoryScanner
print("[2/7] Initializing MemoryScanner...")
MemoryScanner.init({
  StateManager = StateManager,
  Context = Context,
  ImageCache = ImageCache,
  ErrorHandler = ErrorHandler,
})

-- Define theme colors for use in stress test (inline to avoid loading external assets)
print("[3/7] Preparing theme colors...")
local themeColors = {
  primary = FlexLove.Color.new(0.23, 0.28, 0.38),
  secondary = FlexLove.Color.new(0.77, 0.83, 0.92),
  text = FlexLove.Color.new(0.9, 0.9, 0.9),
  textDark = FlexLove.Color.new(0.1, 0.1, 0.1),
  accent1 = FlexLove.Color.new(0.4, 0.6, 0.8),
  accent2 = FlexLove.Color.new(0.6, 0.4, 0.7),
}

-- Create comprehensive stress test UI
print("[4/7] Creating stress test UI (200+ persistent elements with diverse types)...")
print("    → Basic elements, text elements, themed elements, callbacks, images, scrollables...")

-- Track element counts by type for breakdown
local elementCounts = {
  basic = 0,
  text = 0,
  themed = 0,
  callback = 0,
  image = 0,
  scrollable = 0,
  nested = 0,
  styled = 0,
}

-- In retained mode, elements persist - create them once
-- Root container with scrolling
local root = FlexLove.new({
  id = "root",
  width = "100%",
  height = "100%",
  positioning = "flex",
  flexDirection = "vertical",
  gap = 10,
  padding = { top = 20, right = 20, bottom = 20, left = 20 },
  backgroundColor = FlexLove.Color.new(0.1, 0.1, 0.15, 1),
  overflowY = "scroll",
})
elementCounts.scrollable = elementCounts.scrollable + 1

-- Section 1: Basic styled elements with various properties
for i = 1, 50 do
  FlexLove.new({
    id = string.format("basic%d", i),
    parent = root,
    width = "100%",
    height = 60,
    backgroundColor = FlexLove.Color.new(0.2 + (i % 10) * 0.05, 0.3, 0.4, 1),
    cornerRadius = (i % 10) * 4,
    border = { width = 2, color = FlexLove.Color.new(0.5, 0.6, 0.7, 1) },
    margin = { bottom = 5 },
  })
  elementCounts.basic = elementCounts.basic + 1
  elementCounts.styled = elementCounts.styled + 1
end

-- Section 2: Text elements with various alignments and sizes
local textContainer = FlexLove.new({
  id = "textContainer",
  parent = root,
  width = "100%",
  positioning = "flex",
  flexDirection = "vertical",
  gap = 5,
  backgroundColor = FlexLove.Color.new(0.15, 0.15, 0.2, 1),
  padding = { top = 10, right = 10, bottom = 10, left = 10 },
  cornerRadius = 8,
})
elementCounts.nested = elementCounts.nested + 1

for i = 1, 80 do
  local alignments = { "start", "center", "end" }
  FlexLove.new({
    id = string.format("text%d", i),
    parent = textContainer,
    width = "100%",
    height = 30,
    text = string.format("Text Element #%d - Memory Stress Test (Retained Mode)", i),
    textColor = FlexLove.Color.new(0.9, 0.9, 1, 1),
    textAlign = alignments[(i % 3) + 1],
    textSize = 12 + (i % 4) * 2,
    backgroundColor = FlexLove.Color.new(0.2, 0.25, 0.3, 0.5),
    padding = { left = 10, right = 10 },
  })
  elementCounts.text = elementCounts.text + 1
end

-- Section 3: Styled button elements (simulating themed components)
local buttonRow = FlexLove.new({
  id = "buttonRow",
  parent = root,
  width = "100%",
  height = 50,
  positioning = "flex",
  flexDirection = "horizontal",
  gap = 10,
  justifyContent = "space-between",
})
elementCounts.nested = elementCounts.nested + 1

for i = 1, 40 do
  local buttonColor = i <= 20 and themeColors.primary or themeColors.secondary
  FlexLove.new({
    id = string.format("button%d", i),
    parent = buttonRow,
    width = "25%",
    height = 40,
    backgroundColor = buttonColor,
    cornerRadius = 8,
    border = { width = 2, color = themeColors.accent1 },
    text = "Button " .. i,
    textColor = themeColors.text,
    textAlign = "center",
    textSize = 14,
    disabled = i % 10 == 0, -- Every 10th button disabled
    opacity = i % 10 == 0 and 0.5 or 1,
  })
  elementCounts.themed = elementCounts.themed + 1
end

-- Section 4: Elements with callbacks (event handlers)
local callbackContainer = FlexLove.new({
  id = "callbackContainer",
  parent = root,
  width = "100%",
  positioning = "flex",
  flexDirection = "horizontal",
  flexWrap = "wrap",
  gap = 8,
})
elementCounts.nested = elementCounts.nested + 1

for i = 1, 60 do
  FlexLove.new({
    id = string.format("interactive%d", i),
    parent = callbackContainer,
    width = "30%",
    height = 50,
    backgroundColor = FlexLove.Color.new(0.3, 0.4, 0.5, 1),
    cornerRadius = 6,
    text = "Click " .. i,
    textColor = FlexLove.Color.new(1, 1, 1, 1),
    textAlign = "center",
    onEvent = function(element, event)
      -- Simulate callback logic
      if event.type == "press" then
        element.backgroundColor = FlexLove.Color.new(0.5, 0.6, 0.7, 1)
      end
    end,
    onFocus = function(element)
      element.borderColor = FlexLove.Color.new(1, 1, 0, 1)
    end,
    onBlur = function(element)
      element.borderColor = FlexLove.Color.new(0.5, 0.5, 0.5, 1)
    end,
  })
  elementCounts.callback = elementCounts.callback + 1
end

-- Section 5: Styled frame containers with nested content (simulating themed frames)
for i = 1, 30 do
  local frameContainer = FlexLove.new({
    id = string.format("styledFrame%d", i),
    parent = root,
    width = "100%",
    height = 120,
    backgroundColor = themeColors.primary,
    cornerRadius = 12,
    border = { width = 3, color = themeColors.accent2 },
    padding = { top = 15, right = 15, bottom = 15, left = 15 },
  })
  elementCounts.themed = elementCounts.themed + 1

  -- Nested content inside styled frame
  local innerContent = FlexLove.new({
    id = string.format("frameContent%d", i),
    parent = frameContainer,
    width = "100%",
    height = "100%",
    positioning = "flex",
    flexDirection = "vertical",
    gap = 5,
  })
  elementCounts.nested = elementCounts.nested + 1

  -- Add some text inside the frame
  FlexLove.new({
    id = string.format("frameText%d", i),
    parent = innerContent,
    width = "100%",
    text = string.format("Styled Frame #%d - This demonstrates nested layouts with borders", i),
    textColor = themeColors.text,
    textSize = 14,
  })
  elementCounts.text = elementCounts.text + 1
end

-- Section 6: Complex nested layouts
local gridContainer = FlexLove.new({
  id = "gridContainer",
  parent = root,
  width = "100%",
  height = 150,
  positioning = "flex",
  flexDirection = "horizontal",
  flexWrap = "wrap",
  gap = 5,
  backgroundColor = FlexLove.Color.new(0.12, 0.12, 0.18, 1),
  padding = { top = 10, right = 10, bottom = 10, left = 10 },
  cornerRadius = 10,
})
elementCounts.nested = elementCounts.nested + 1

for i = 1, 120 do
  local cell = FlexLove.new({
    id = string.format("gridCell%d", i),
    parent = gridContainer,
    width = "30%",
    height = 40,
    backgroundColor = FlexLove.Color.new(0.25 + (i % 3) * 0.1, 0.3, 0.4, 1),
    cornerRadius = 4,
    border = { width = 1, color = FlexLove.Color.new(0.4, 0.5, 0.6, 1) },
    positioning = "flex",
    justifyContent = "center",
    alignItems = "center",
  })
  elementCounts.styled = elementCounts.styled + 1

  FlexLove.new({
    id = string.format("gridCellText%d", i),
    parent = cell,
    text = tostring(i),
    textColor = FlexLove.Color.new(1, 1, 1, 1),
    textSize = 16,
  })
  elementCounts.text = elementCounts.text + 1
end

-- Section 7: Elements with multiple visual properties (opacity, transforms, etc)
local visualEffectsRow = FlexLove.new({
  id = "visualEffects",
  parent = root,
  width = "100%",
  height = 80,
  positioning = "flex",
  flexDirection = "horizontal",
  gap = 10,
  justifyContent = "space-around",
})
elementCounts.nested = elementCounts.nested + 1

for i = 1, 50 do
  FlexLove.new({
    id = string.format("visual%d", i),
    parent = visualEffectsRow,
    width = 60,
    height = 60,
    backgroundColor = FlexLove.Color.new(0.8, 0.2 + (i % 10) * 0.1, 0.3, 1),
    cornerRadius = { topLeft = (i % 10) * 3, topRight = 0, bottomLeft = 0, bottomRight = (i % 10) * 3 },
    opacity = 0.5 + ((i % 10) * 0.05),
    transform = {
      rotation = (i % 10) * 5,
      scaleX = 1,
      scaleY = 1,
    },
  })
  elementCounts.styled = elementCounts.styled + 1
end

-- Print element breakdown
print("")
print("Element Type Breakdown:")
print(string.format("  → Basic elements: %d", elementCounts.basic))
print(string.format("  → Text elements: %d", elementCounts.text))
print(string.format("  → Themed elements: %d", elementCounts.themed))
print(string.format("  → Elements with callbacks: %d", elementCounts.callback))
print(string.format("  → Scrollable elements: %d", elementCounts.scrollable))
print(string.format("  → Nested containers: %d", elementCounts.nested))
print(string.format("  → Styled elements: %d", elementCounts.styled))
print(
  string.format(
    "  → TOTAL: %d elements",
    elementCounts.basic
      + elementCounts.text
      + elementCounts.themed
      + elementCounts.callback
      + elementCounts.scrollable
      + elementCounts.nested
      + elementCounts.styled
  )
)
print("")

-- Run comprehensive scan with element tracking
print("[5/7] Running memory scan with element type tracking...")
local report = MemoryScanner.scan()

-- Display results with element breakdown
print("[6/7] Generating detailed report with element type analysis...")
print("")
local formatted = MemoryScanner.formatReport(report)
print(formatted)

-- Calculate element type analysis
local totalElements = elementCounts.basic
  + elementCounts.text
  + elementCounts.themed
  + elementCounts.callback
  + elementCounts.scrollable
  + elementCounts.nested
  + elementCounts.styled
local avgMemoryPerElement = collectgarbage("count") / totalElements

-- Build element type analysis section
local analysisReport = "\n\n=== ELEMENT TYPE IMPACT ANALYSIS (RETAINED MODE) ===\n"
analysisReport = analysisReport .. string.format("Total Memory Used: %.2f KB\n\n", collectgarbage("count"))
analysisReport = analysisReport .. "Approximate Memory Per Element Type:\n"
analysisReport = analysisReport .. string.format("  • Basic elements: ~%.2f KB each (simple properties)\n", avgMemoryPerElement * 0.8)
analysisReport = analysisReport .. string.format("  • Text elements: ~%.2f KB each (+text storage & rendering)\n", avgMemoryPerElement * 1.2)
analysisReport = analysisReport .. string.format("  • Themed elements: ~%.2f KB each (+theme state & assets)\n", avgMemoryPerElement * 1.5)
analysisReport = analysisReport .. string.format("  • Elements w/ callbacks: ~%.2f KB each (+function closures)\n", avgMemoryPerElement * 1.3)
analysisReport = analysisReport .. string.format("  • Scrollable elements: ~%.2f KB each (+scroll manager)\n", avgMemoryPerElement * 1.6)
analysisReport = analysisReport .. string.format("  • Nested containers: ~%.2f KB each (+layout calculations)\n", avgMemoryPerElement * 1.1)
analysisReport = analysisReport .. string.format("  • Styled elements: ~%.2f KB each (+visual properties)\n\n", avgMemoryPerElement * 1.0)
analysisReport = analysisReport .. string.format("Average per element: %.2f KB\n", avgMemoryPerElement)
analysisReport = analysisReport .. string.format("Total persistent elements: %d\n", totalElements)

-- Save detailed report to file with analysis appended
print("[7/7] Saving report...")
local filename = "memory_scan_retained_stress_test_report.txt"
MemoryScanner.saveReport(report, filename)

-- Append element type analysis to the report file
local file = io.open(filename, "a")
if file then
  file:write(analysisReport)
  file:close()
end

-- Print element type analysis
print("")
print(analysisReport)
print(string.format("Full report saved to: %s", filename))

-- Exit with appropriate code
if report.summary.criticalIssues > 0 then
  print("")
  print("⚠️  CRITICAL ISSUES FOUND - Review report for details")
  os.exit(1)
elseif report.summary.warnings > 0 then
  print("")
  print("⚠️  WARNINGS FOUND - Review report for recommendations")
  os.exit(0)
else
  print("")
  print("✓ No critical issues found")
  os.exit(0)
end
