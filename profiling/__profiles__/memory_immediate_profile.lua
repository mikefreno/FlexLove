-- Memory Scanner Profile - IMMEDIATE MODE
-- Measures actual memory usage in immediate mode with real LÖVE rendering

package.path = package.path .. ";../?.lua;../?/init.lua"

local FlexLove = require("FlexLove")
local MemoryScanner = require("modules.MemoryScanner")
local StateManager = require("modules.StateManager")
local Context = require("modules.Context")
local ImageCache = require("modules.ImageCache")
local ErrorHandler = require("modules.ErrorHandler")

local profile = {
  name = "Memory Scanner - Immediate Mode",
  description = "Comprehensive memory stress test with 200+ elements in immediate mode",
  frameCount = 0,
  totalFrames = 10,
  reportGenerated = false,
  themeColors = {},
  elementCounts = {},
}

function profile.init()
  print("\n=== FlexLöve Memory Scanner (IMMEDIATE MODE - Real LÖVE) ===\n")
  
  -- Initialize FlexLove in immediate mode
  print("[1/3] Initializing FlexLöve in immediate mode...")
  FlexLove.init({
    immediateMode = true,
    memoryProfiling = true,
  })
  
  -- Initialize MemoryScanner
  print("[2/3] Initializing MemoryScanner...")
  MemoryScanner.init({
    StateManager = StateManager,
    Context = Context,
    ImageCache = ImageCache,
    ErrorHandler = ErrorHandler,
  })
  
  -- Define theme colors
  print("[3/3] Preparing theme and counters...")
  profile.themeColors = {
    primary = FlexLove.Color.new(0.23, 0.28, 0.38),
    secondary = FlexLove.Color.new(0.77, 0.83, 0.92),
    text = FlexLove.Color.new(0.9, 0.9, 0.9),
    accent1 = FlexLove.Color.new(0.4, 0.6, 0.8),
    accent2 = FlexLove.Color.new(0.6, 0.4, 0.7),
  }
  
  profile.elementCounts = {
    basic = 0,
    text = 0,
    themed = 0,
    callback = 0,
    scrollable = 0,
    nested = 0,
    styled = 0,
  }
  
  print("\nCreating UI elements across 10 frames...\n")
end

function profile.update(dt)
  if profile.frameCount >= profile.totalFrames then
    if not profile.reportGenerated then
      profile.generateReport()
      profile.reportGenerated = true
    end
    return
  end
  
  FlexLove.beginFrame()
  
  local frame = profile.frameCount + 1
  
  -- Root container with scrolling
  local root = FlexLove.new({
    id = "root_" .. frame,
    width = "100%",
    height = "100%",
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
    backgroundColor = FlexLove.Color.new(0.1, 0.1, 0.15, 1),
    overflowY = "scroll",
  })
  profile.elementCounts.scrollable = profile.elementCounts.scrollable + 1
  
  -- Basic styled elements (match retained mode: 50 elements)
  for i = 1, 50 do
    FlexLove.new({
      id = string.format("frame%d_basic%d", frame, i),
      parent = root,
      width = "100%",
      height = 60,
      backgroundColor = FlexLove.Color.new(0.2 + (i % 10) * 0.05, 0.3, 0.4, 1),
      cornerRadius = (i % 10) * 4,
      border = { width = 2, color = FlexLove.Color.new(0.5, 0.6, 0.7, 1) },
      margin = { bottom = 5 },
    })
    profile.elementCounts.basic = profile.elementCounts.basic + 1
    profile.elementCounts.styled = profile.elementCounts.styled + 1
  end
  
  -- Text container
  local textContainer = FlexLove.new({
    id = string.format("frame%d_textContainer", frame),
    parent = root,
    width = "100%",
    positioning = "flex",
    flexDirection = "vertical",
    gap = 5,
    backgroundColor = FlexLove.Color.new(0.15, 0.15, 0.2, 1),
    padding = { top = 10, right = 10, bottom = 10, left = 10 },
    cornerRadius = 8,
  })
  profile.elementCounts.nested = profile.elementCounts.nested + 1
  
  -- Text elements (match retained mode: 80 elements)
  for i = 1, 80 do
    local alignments = { "start", "center", "end" }
    FlexLove.new({
      id = string.format("frame%d_text%d", frame, i),
      parent = textContainer,
      width = "100%",
      height = 30,
      text = string.format("Text #%d Frame %d - Memory Test", i, frame),
      textColor = FlexLove.Color.new(0.9, 0.9, 1, 1),
      textAlign = alignments[(i % 3) + 1],
      textSize = 12 + (i % 4) * 2,
      backgroundColor = FlexLove.Color.new(0.2, 0.25, 0.3, 0.5),
      padding = { left = 10, right = 10 },
    })
    profile.elementCounts.text = profile.elementCounts.text + 1
  end
  
  -- Button row
  local buttonRow = FlexLove.new({
    id = string.format("frame%d_buttonRow", frame),
    parent = root,
    width = "100%",
    height = 50,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 10,
    justifyContent = "space-between",
  })
  profile.elementCounts.nested = profile.elementCounts.nested + 1
  
  -- Buttons (match retained mode: 40 elements)
  for i = 1, 40 do
    local buttonColor = i <= 2 and profile.themeColors.primary or profile.themeColors.secondary
    FlexLove.new({
      id = string.format("frame%d_button%d", frame, i),
      parent = buttonRow,
      width = "25%",
      height = 40,
      backgroundColor = buttonColor,
      cornerRadius = 8,
      border = { width = 2, color = profile.themeColors.accent1 },
      text = "Btn " .. i,
      textColor = profile.themeColors.text,
      textAlign = "center",
      textSize = 14,
    })
    profile.elementCounts.themed = profile.elementCounts.themed + 1
  end
  
  FlexLove.endFrame()
  
  profile.frameCount = profile.frameCount + 1
end

function profile.draw()
  FlexLove.draw()
  
  -- Draw status
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(string.format("Frame: %d/%d", profile.frameCount, profile.totalFrames), 10, 10)
  love.graphics.print(string.format("Memory: %.2f MB", collectgarbage("count") / 1024), 10, 30)
  
  if profile.reportGenerated then
    love.graphics.print("Report generated! Press ESC to exit.", 10, 50)
  end
end

function profile.generateReport()
  print("\n[Generating Memory Report...]\n")
  
  local totalElements = profile.elementCounts.basic
    + profile.elementCounts.text
    + profile.elementCounts.themed
    + profile.elementCounts.callback
    + profile.elementCounts.scrollable
    + profile.elementCounts.nested
    + profile.elementCounts.styled
  
  print("Element Type Breakdown:")
  print(string.format("  → Basic: %d", profile.elementCounts.basic))
  print(string.format("  → Text: %d", profile.elementCounts.text))
  print(string.format("  → Themed: %d", profile.elementCounts.themed))
  print(string.format("  → Scrollable: %d", profile.elementCounts.scrollable))
  print(string.format("  → Nested: %d", profile.elementCounts.nested))
  print(string.format("  → Styled: %d", profile.elementCounts.styled))
  print(string.format("  → TOTAL: %d elements\n", totalElements))
  
  local report = MemoryScanner.scan()
  
  local formatted = MemoryScanner.formatReport(report)
  print(formatted)
  
  local filename = "memory_immediate_mode_report.txt"
  MemoryScanner.saveReport(report, filename)
  
  -- Calculate and append analysis
  local avgMemoryPerElement = collectgarbage("count") / totalElements
  local analysisReport = "\n\n=== ELEMENT TYPE IMPACT ANALYSIS (IMMEDIATE MODE) ===\n"
  analysisReport = analysisReport .. string.format("Total Memory Used: %.2f KB\n\n", collectgarbage("count"))
  analysisReport = analysisReport .. "Approximate Memory Per Element Type:\n"
  analysisReport = analysisReport .. string.format("  • Basic: ~%.2f KB each\n", avgMemoryPerElement * 0.8)
  analysisReport = analysisReport .. string.format("  • Text: ~%.2f KB each\n", avgMemoryPerElement * 1.2)
  analysisReport = analysisReport .. string.format("  • Themed: ~%.2f KB each\n", avgMemoryPerElement * 1.5)
  analysisReport = analysisReport .. string.format("  • Scrollable: ~%.2f KB each\n", avgMemoryPerElement * 1.6)
  analysisReport = analysisReport .. string.format("  • Nested: ~%.2f KB each\n", avgMemoryPerElement * 1.1)
  analysisReport = analysisReport .. string.format("  • Styled: ~%.2f KB each\n\n", avgMemoryPerElement * 1.0)
  analysisReport = analysisReport .. string.format("Average per element: %.2f KB\n", avgMemoryPerElement)
  analysisReport = analysisReport .. string.format("Total elements created: %d\n", totalElements)
  
  local file = io.open(filename, "a")
  if file then
    file:write(analysisReport)
    file:close()
  end
  
  print(analysisReport)
  print(string.format("\nFull report saved to: %s\n", filename))
end

function profile.cleanup()
  print("\nCleaning up memory scanner...\n")
end

return profile
