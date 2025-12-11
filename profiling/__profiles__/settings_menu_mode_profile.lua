-- Settings Menu Mode Comparison Profile
-- Compares performance between explicit mode="retained" flags vs implicit retained mode

local FlexLove = require("FlexLove")

local profile = {
  name = "Settings Menu Mode Comparison",
  description = "Tests whether explicit mode='retained' has performance overhead",
  testPhase = "warmup", -- warmup, implicit, explicit, complete
  frameCount = 0,
  framesPerPhase = 300, -- 5 seconds at 60 FPS
  results = {
    implicit = { startMem = 0, endMem = 0, avgFrameTime = 0, frameTimes = {} },
    explicit = { startMem = 0, endMem = 0, avgFrameTime = 0, frameTimes = {} },
  },
  currentFrameStart = nil,
}

-- Mock Settings object
local Settings = {
  values = {
    resolution = { width = 1920, height = 1080 },
    fullscreen = false,
    vsync = true,
    msaa = 4,
    masterVolume = 0.8,
  },
  get = function(self, key)
    return self.values[key]
  end,
}

-- Simplified SettingsMenu implementation
local function createSettingsMenu(useExplicitMode)
  local GuiZIndexing = { MainMenuOverlay = 100 }

  -- Backdrop
  local backdropProps = {
    z = GuiZIndexing.MainMenuOverlay - 1,
    width = "100%",
    height = "100%",
    backdropBlur = { radius = 10 },
    backgroundColor = FlexLove.Color.new(1, 1, 1, 0.1),
  }
  if useExplicitMode then
    backdropProps.mode = "retained"
  end
  local backdrop = FlexLove.new(backdropProps)

  -- Main window
  local windowProps = {
    z = GuiZIndexing.MainMenuOverlay,
    x = "5%",
    y = "5%",
    width = "90%",
    height = "90%",
    themeComponent = "framev3",
    positioning = "flex",
    flexDirection = "vertical",
    justifySelf = "center",
    justifyContent = "flex-start",
    alignItems = "center",
    scaleCorners = 3,
    padding = { horizontal = "5%", vertical = "3%" },
    gap = 10,
  }
  if useExplicitMode then
    windowProps.mode = "retained"
  end
  local window = FlexLove.new(windowProps)

  -- Close button
  FlexLove.new({
    parent = window,
    x = "2%",
    y = "2%",
    alignSelf = "flex-start",
    themeComponent = "buttonv2",
    width = "4vw",
    height = "4vw",
    text = "X",
    textSize = "2xl",
    textAlign = "center",
  })

  -- Title
  FlexLove.new({
    parent = window,
    text = "Settings",
    textAlign = "center",
    textSize = "3xl",
    width = "100%",
    margin = { top = "-4%", bottom = "4%" },
  })

  -- Content container
  local content = FlexLove.new({
    parent = window,
    width = "100%",
    height = "100%",
    positioning = "flex",
    flexDirection = "vertical",
    padding = { top = "4%" },
  })

  -- Display Settings Section
  FlexLove.new({
    parent = content,
    text = "Display Settings",
    textAlign = "start",
    textSize = "xl",
    width = "100%",
    textColor = FlexLove.Color.new(0.8, 0.9, 1, 1),
  })

  -- Resolution control
  local row1 = FlexLove.new({
    parent = content,
    width = "100%",
    height = "5vh",
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    gap = 10,
  })

  FlexLove.new({
    parent = row1,
    text = "Resolution",
    textAlign = "start",
    textSize = "md",
    width = "30%",
  })

  local resolution = Settings:get("resolution")
  FlexLove.new({
    parent = row1,
    text = resolution.width .. " x " .. resolution.height,
    themeComponent = "buttonv2",
    width = "30%",
    textAlign = "center",
    textSize = "lg",
  })

  -- Fullscreen toggle
  local row2 = FlexLove.new({
    parent = content,
    width = "100%",
    height = "5vh",
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    gap = 10,
  })

  FlexLove.new({
    parent = row2,
    text = "Fullscreen",
    textAlign = "start",
    textSize = "md",
    width = "60%",
  })

  local fullscreen = Settings:get("fullscreen")
  FlexLove.new({
    parent = row2,
    text = fullscreen and "ON" or "OFF",
    themeComponent = fullscreen and "buttonv1" or "buttonv2",
    textAlign = "center",
    width = "15vw",
    height = "4vh",
    textSize = "md",
  })

  -- VSync toggle
  local row3 = FlexLove.new({
    parent = content,
    width = "100%",
    height = "5vh",
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    gap = 10,
  })

  FlexLove.new({
    parent = row3,
    text = "VSync",
    textAlign = "start",
    textSize = "md",
    width = "60%",
  })

  local vsync = Settings:get("vsync")
  FlexLove.new({
    parent = row3,
    text = vsync and "ON" or "OFF",
    themeComponent = vsync and "buttonv1" or "buttonv2",
    textAlign = "center",
    width = "15vw",
    height = "4vh",
    textSize = "md",
  })

  -- MSAA control
  local row4 = FlexLove.new({
    parent = content,
    width = "100%",
    height = "5vh",
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    gap = 10,
  })

  FlexLove.new({
    parent = row4,
    text = "MSAA",
    textAlign = "start",
    textSize = "md",
    width = "30%",
  })

  local buttonContainer = FlexLove.new({
    parent = row4,
    width = "60%",
    height = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 5,
  })

  local msaaValues = { 0, 1, 2, 4, 8, 16 }
  for _, msaaVal in ipairs(msaaValues) do
    local isSelected = Settings:get("msaa") == msaaVal
    FlexLove.new({
      parent = buttonContainer,
      themeComponent = isSelected and "buttonv1" or "buttonv2",
      text = tostring(msaaVal),
      textAlign = "center",
      width = "8vw",
      height = "100%",
      textSize = "sm",
      disabled = isSelected,
      opacity = isSelected and 0.7 or 1.0,
    })
  end

  -- Audio Settings Section
  FlexLove.new({
    parent = content,
    text = "Audio Settings",
    textAlign = "start",
    textSize = "xl",
    width = "100%",
    textColor = FlexLove.Color.new(0.8, 0.9, 1, 1),
  })

  -- Master volume slider
  local row5 = FlexLove.new({
    parent = content,
    width = "100%",
    height = "5vh",
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    gap = 10,
  })

  FlexLove.new({
    parent = row5,
    text = "Master Volume",
    textAlign = "start",
    textSize = "md",
    width = "30%",
  })

  local sliderContainer = FlexLove.new({
    parent = row5,
    width = "50%",
    height = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    alignItems = "center",
    gap = 5,
  })

  local value = Settings:get("masterVolume")
  local normalized = value

  local sliderTrack = FlexLove.new({
    parent = sliderContainer,
    width = "80%",
    height = "75%",
    positioning = "flex",
    flexDirection = "horizontal",
    themeComponent = "framev3",
  })

  FlexLove.new({
    parent = sliderTrack,
    width = (normalized * 100) .. "%",
    height = "100%",
    themeComponent = "buttonv1",
    themeStateLock = true,
  })

  FlexLove.new({
    parent = sliderContainer,
    text = string.format("%d", value * 100),
    textAlign = "center",
    textSize = "md",
    width = "15%",
  })

  -- Meta controls (bottom buttons)
  local metaContainer = FlexLove.new({
    parent = window,
    positioning = "absolute",
    width = "100%",
    height = "10%",
    y = "90%",
    x = "0%",
  })

  local buttonBar = FlexLove.new({
    parent = metaContainer,
    width = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "center",
    alignItems = "center",
    gap = 10,
  })

  FlexLove.new({
    parent = buttonBar,
    themeComponent = "buttonv2",
    text = "Reset",
    textAlign = "center",
    width = "15vw",
    height = "6vh",
    textSize = "lg",
  })

  return { backdrop = backdrop, window = window }
end

function profile.init()
  print("\n=== Settings Menu Mode Comparison Profile ===\n")
  print("Testing whether explicit mode='retained' has performance overhead")
  print("compared to implicit retained mode (global setting).\n")
  
  FlexLove.init({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    immediateMode = false, -- Global retained mode
    theme = "space",
  })
  
  profile.testPhase = "warmup"
  profile.frameCount = 0
  
  print("Phase 1: Warmup (30 frames)...")
end

function profile.update(dt)
  if profile.testPhase == "complete" then
    return
  end
  
  -- Track frame time
  local frameStart = love.timer.getTime()
  
  if profile.testPhase == "warmup" then
    -- Warmup phase - create menu a few times
    createSettingsMenu(false)
    profile.frameCount = profile.frameCount + 1
    
    if profile.frameCount >= 30 then
      print("  Warmup complete.\n")
      print("Phase 2: Testing WITHOUT explicit mode flags (" .. profile.framesPerPhase .. " frames)...")
      profile.testPhase = "implicit"
      profile.frameCount = 0
      collectgarbage("collect")
      collectgarbage("collect")
      profile.results.implicit.startMem = collectgarbage("count")
    end
    
  elseif profile.testPhase == "implicit" then
    -- Test implicit mode (no explicit mode flags)
    createSettingsMenu(false)
    
    local frameTime = (love.timer.getTime() - frameStart) * 1000
    table.insert(profile.results.implicit.frameTimes, frameTime)
    
    profile.frameCount = profile.frameCount + 1
    
    if profile.frameCount >= profile.framesPerPhase then
      collectgarbage("collect")
      collectgarbage("collect")
      profile.results.implicit.endMem = collectgarbage("count")
      
      -- Calculate average
      local sum = 0
      for _, ft in ipairs(profile.results.implicit.frameTimes) do
        sum = sum + ft
      end
      profile.results.implicit.avgFrameTime = sum / #profile.results.implicit.frameTimes
      
      print("  Complete. Avg frame time: " .. string.format("%.4f", profile.results.implicit.avgFrameTime) .. "ms\n")
      print("Phase 3: Testing WITH explicit mode='retained' flags (" .. profile.framesPerPhase .. " frames)...")
      
      profile.testPhase = "explicit"
      profile.frameCount = 0
      collectgarbage("collect")
      collectgarbage("collect")
      profile.results.explicit.startMem = collectgarbage("count")
    end
    
  elseif profile.testPhase == "explicit" then
    -- Test explicit mode (with mode="retained" flags)
    createSettingsMenu(true)
    
    local frameTime = (love.timer.getTime() - frameStart) * 1000
    table.insert(profile.results.explicit.frameTimes, frameTime)
    
    profile.frameCount = profile.frameCount + 1
    
    if profile.frameCount >= profile.framesPerPhase then
      collectgarbage("collect")
      collectgarbage("collect")
      profile.results.explicit.endMem = collectgarbage("count")
      
      -- Calculate average
      local sum = 0
      for _, ft in ipairs(profile.results.explicit.frameTimes) do
        sum = sum + ft
      end
      profile.results.explicit.avgFrameTime = sum / #profile.results.explicit.frameTimes
      
      print("  Complete. Avg frame time: " .. string.format("%.4f", profile.results.explicit.avgFrameTime) .. "ms\n")
      
      profile.testPhase = "complete"
      profile.generateReport()
    end
  end
end

function profile.draw()
  -- Draw the current menu
  if profile.testPhase ~= "complete" then
    FlexLove.draw()
  end
  
  -- Draw status overlay
  love.graphics.setColor(0, 0, 0, 0.85)
  love.graphics.rectangle("fill", 10, 10, 400, 120)
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Settings Menu Mode Comparison", 20, 20)
  
  if profile.testPhase == "warmup" then
    love.graphics.print("Phase: Warmup (" .. profile.frameCount .. "/30)", 20, 45)
  elseif profile.testPhase == "implicit" then
    love.graphics.print("Phase: Without mode flags", 20, 45)
    love.graphics.print("Progress: " .. profile.frameCount .. "/" .. profile.framesPerPhase, 20, 65)
  elseif profile.testPhase == "explicit" then
    love.graphics.print("Phase: With mode='retained' flags", 20, 45)
    love.graphics.print("Progress: " .. profile.frameCount .. "/" .. profile.framesPerPhase, 20, 65)
  elseif profile.testPhase == "complete" then
    love.graphics.print("Phase: COMPLETE", 20, 45)
    love.graphics.print("Report saved! Press S to save again, ESC to exit.", 20, 65)
  end
  
  love.graphics.print("Memory: " .. string.format("%.2f", collectgarbage("count") / 1024) .. " MB", 20, 85)
  love.graphics.print("Press ESC to return to menu", 20, 105)
end

function profile.generateReport()
  print("\n" .. string.rep("=", 80))
  print("RESULTS COMPARISON")
  print(string.rep("=", 80) .. "\n")
  
  local timeDiff = profile.results.explicit.avgFrameTime - profile.results.implicit.avgFrameTime
  local timePercent = (timeDiff / profile.results.implicit.avgFrameTime) * 100
  local memDiff = (profile.results.explicit.endMem - profile.results.explicit.startMem) -
                  (profile.results.implicit.endMem - profile.results.implicit.startMem)
  
  print("Time Comparison:")
  print(string.format("  Without mode flag: %.4f ms", profile.results.implicit.avgFrameTime))
  print(string.format("  With mode flag:    %.4f ms", profile.results.explicit.avgFrameTime))
  print(string.format("  Difference:        %.4f ms (%+.2f%%)", timeDiff, timePercent))
  print()
  
  print("Memory Comparison:")
  print(string.format("  Without mode flag: %.2f KB", profile.results.implicit.endMem - profile.results.implicit.startMem))
  print(string.format("  With mode flag:    %.2f KB", profile.results.explicit.endMem - profile.results.explicit.startMem))
  print(string.format("  Difference:        %+.2f KB", memDiff))
  print()
  
  print("INTERPRETATION:")
  print()
  if math.abs(timePercent) < 5 then
    print("  ✓ Performance is essentially identical (< 5% difference)")
    print("    The explicit mode flag has negligible impact on performance.")
  elseif timePercent > 0 then
    print(string.format("  ⚠ Explicit mode flag is %.2f%% SLOWER", timePercent))
    print("    This indicates overhead from mode checking/resolution.")
  else
    print(string.format("  ✓ Explicit mode flag is %.2f%% FASTER", -timePercent))
    print("    This indicates potential optimization benefits.")
  end
  print()
  
  if math.abs(memDiff) < 50 then
    print("  ✓ Memory usage is essentially identical (< 50 KB difference)")
  elseif memDiff > 0 then
    print(string.format("  ⚠ Explicit mode flag uses %.2f KB MORE memory", memDiff))
  else
    print(string.format("  ✓ Explicit mode flag uses %.2f KB LESS memory", -memDiff))
  end
  print()
  
  print("RECOMMENDATION:")
  print()
  if math.abs(timePercent) < 5 and math.abs(memDiff) < 50 then
    print("  The explicit mode='retained' flag provides clarity and explicitness")
    print("  without any meaningful performance cost. It's recommended for:")
    print("    - Code readability (makes intent explicit)")
    print("    - Future-proofing (if global mode changes)")
    print("    - Mixed-mode UIs (where some elements are immediate)")
  else
    print("  Consider the trade-offs based on your specific use case.")
  end
  print()
  print(string.rep("=", 80))
  print("Profile complete! Press S to save report.")
  print(string.rep("=", 80) .. "\n")
  
  -- Save report automatically
  profile.saveReportToFile()
end

function profile.saveReportToFile()
  local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
  local filename = string.format("reports/settings_menu_mode_profile/%s.md", timestamp)
  
  -- Get the actual project directory
  local sourceDir = love.filesystem.getSource()
  local filepath
  
  if sourceDir:match("%.love$") then
    -- Running from .love file, use save directory
    love.filesystem.createDirectory("reports/settings_menu_mode_profile")
    -- Use love.filesystem for sandboxed writes
    local content = profile.formatReportMarkdown()
    local success = love.filesystem.write(filename, content)
    if success then
      print("\n✓ Report saved to: " .. love.filesystem.getSaveDirectory() .. "/" .. filename)
    else
      print("\n✗ Failed to save report")
    end
  else
    -- Running from source, use io module
    filepath = sourceDir .. "/" .. filename
    os.execute('mkdir -p "' .. sourceDir .. '/reports/settings_menu_mode_profile"')
    
    local file, err = io.open(filepath, "w")
    if file then
      file:write(profile.formatReportMarkdown())
      file:close()
      print("\n✓ Report saved to: " .. filepath)
      
      -- Also save as latest.md
      local latestPath = sourceDir .. "/reports/settings_menu_mode_profile/latest.md"
      local latestFile = io.open(latestPath, "w")
      if latestFile then
        latestFile:write(profile.formatReportMarkdown())
        latestFile:close()
      end
    else
      print("\n✗ Failed to save report: " .. tostring(err))
    end
  end
end

function profile.formatReportMarkdown()
  local lines = {}
  
  table.insert(lines, "# Settings Menu Mode Comparison Report")
  table.insert(lines, "")
  table.insert(lines, "**Generated:** " .. os.date("%Y-%m-%d %H:%M:%S"))
  table.insert(lines, "")
  table.insert(lines, "This profile compares performance when creating a complex settings menu")
  table.insert(lines, "with explicit `mode='retained'` flags vs. implicit retained mode (global setting).")
  table.insert(lines, "")
  table.insert(lines, "---")
  table.insert(lines, "")
  
  table.insert(lines, "## Test Configuration")
  table.insert(lines, "")
  table.insert(lines, "- **Frames per test:** " .. profile.framesPerPhase)
  table.insert(lines, "- **Elements per menu:** ~45 (backdrop, window, buttons, sliders, etc.)")
  table.insert(lines, "- **Global mode:** `immediateMode = false` (retained)")
  table.insert(lines, "")
  
  table.insert(lines, "## Results")
  table.insert(lines, "")
  
  local timeDiff = profile.results.explicit.avgFrameTime - profile.results.implicit.avgFrameTime
  local timePercent = (timeDiff / profile.results.implicit.avgFrameTime) * 100
  local memDiff = (profile.results.explicit.endMem - profile.results.explicit.startMem) -
                  (profile.results.implicit.endMem - profile.results.implicit.startMem)
  
  table.insert(lines, "### Frame Time Comparison")
  table.insert(lines, "")
  table.insert(lines, "| Metric | Without `mode` flag | With `mode='retained'` flag | Difference |")
  table.insert(lines, "|--------|--------------------:|----------------------------:|-----------:|")
  table.insert(lines, string.format("| Average Frame Time | %.4f ms | %.4f ms | %+.4f ms (%+.2f%%) |",
    profile.results.implicit.avgFrameTime,
    profile.results.explicit.avgFrameTime,
    timeDiff,
    timePercent))
  table.insert(lines, "")
  
  table.insert(lines, "### Memory Comparison")
  table.insert(lines, "")
  table.insert(lines, "| Metric | Without `mode` flag | With `mode='retained'` flag | Difference |")
  table.insert(lines, "|--------|--------------------:|----------------------------:|-----------:|")
  table.insert(lines, string.format("| Memory Used | %.2f KB | %.2f KB | %+.2f KB |",
    profile.results.implicit.endMem - profile.results.implicit.startMem,
    profile.results.explicit.endMem - profile.results.explicit.startMem,
    memDiff))
  table.insert(lines, "")
  
  table.insert(lines, "## Interpretation")
  table.insert(lines, "")
  
  if math.abs(timePercent) < 5 then
    table.insert(lines, "✓ **Performance is essentially identical** (< 5% difference)")
    table.insert(lines, "")
    table.insert(lines, "The explicit `mode='retained'` flag has negligible impact on performance.")
  elseif timePercent > 0 then
    table.insert(lines, string.format("⚠ **Explicit mode flag is %.2f%% SLOWER**", timePercent))
    table.insert(lines, "")
    table.insert(lines, "This indicates overhead from mode checking/resolution.")
  else
    table.insert(lines, string.format("✓ **Explicit mode flag is %.2f%% FASTER**", -timePercent))
    table.insert(lines, "")
    table.insert(lines, "This indicates potential optimization benefits.")
  end
  table.insert(lines, "")
  
  if math.abs(memDiff) < 50 then
    table.insert(lines, "✓ **Memory usage is essentially identical** (< 50 KB difference)")
  elseif memDiff > 0 then
    table.insert(lines, string.format("⚠ **Explicit mode flag uses %.2f KB MORE memory**", memDiff))
  else
    table.insert(lines, string.format("✓ **Explicit mode flag uses %.2f KB LESS memory**", -memDiff))
  end
  table.insert(lines, "")
  
  table.insert(lines, "## Recommendation")
  table.insert(lines, "")
  
  if math.abs(timePercent) < 5 and math.abs(memDiff) < 50 then
    table.insert(lines, "The explicit `mode='retained'` flag provides clarity and explicitness")
    table.insert(lines, "without any meaningful performance cost. It's recommended for:")
    table.insert(lines, "")
    table.insert(lines, "- **Code readability** - Makes intent explicit")
    table.insert(lines, "- **Future-proofing** - If global mode changes")
    table.insert(lines, "- **Mixed-mode UIs** - Where some elements are immediate")
  else
    table.insert(lines, "Consider the trade-offs based on your specific use case.")
  end
  table.insert(lines, "")
  
  table.insert(lines, "---")
  table.insert(lines, "")
  table.insert(lines, "*Report generated by FlexLöve Performance Profiler*")
  
  return table.concat(lines, "\n")
end

function profile.keypressed(key, profiler)
  if key == "s" and profile.testPhase == "complete" then
    profile.saveReportToFile()
  end
end

function profile.resize(w, h)
  FlexLove.resize(w, h)
end

function profile.reset()
  profile.testPhase = "warmup"
  profile.frameCount = 0
  profile.results = {
    implicit = { startMem = 0, endMem = 0, avgFrameTime = 0, frameTimes = {} },
    explicit = { startMem = 0, endMem = 0, avgFrameTime = 0, frameTimes = {} },
  }
  print("\nProfile reset. Starting over...\n")
end

function profile.cleanup()
  print("\nCleaning up settings menu mode profile...\n")
end

return profile
