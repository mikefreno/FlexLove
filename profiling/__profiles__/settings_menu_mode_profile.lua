-- Profiling test comparing retained mode flag vs. default behavior in complex UI
-- This simulates creating a settings menu multiple times per frame to stress test
-- the performance difference between explicit mode="retained" and implicit retained mode

package.path = package.path .. ";../../?.lua;../../modules/?.lua"

local FlexLove = require("FlexLove")
local Color = require("modules.Color")

-- Mock resolution sets (simplified)
local resolution_sets = {
  ["16:9"] = {
    { 1920, 1080 },
    { 1600, 900 },
    { 1280, 720 },
  },
  ["16:10"] = {
    { 1920, 1200 },
    { 1680, 1050 },
    { 1280, 800 },
  },
}

-- Mock Settings object
local Settings = {
  values = {
    resolution = { width = 1920, height = 1080 },
    fullscreen = false,
    vsync = true,
    msaa = 4,
    resizable = true,
    borderless = false,
    masterVolume = 0.8,
    musicVolume = 0.7,
    sfxVolume = 0.9,
    crtEffectStrength = 0.3,
  },
  get = function(self, key)
    return self.values[key]
  end,
  set = function(self, key, value)
    self.values[key] = value
  end,
  reset_to_defaults = function(self) end,
  apply = function(self) end,
}

-- Helper function to round numbers
local function round(num, decimals)
  local mult = 10 ^ (decimals or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Simplified SettingsMenu implementation
local function create_settings_menu_with_mode_flag(use_mode_flag)
  local GuiZIndexing = { MainMenuOverlay = 100 }

  -- Backdrop
  local backdrop_props = {
    z = GuiZIndexing.MainMenuOverlay - 1,
    width = "100%",
    height = "100%",
    backdropBlur = { radius = 10 },
    backgroundColor = Color.new(1, 1, 1, 0.1),
  }
  if use_mode_flag then
    backdrop_props.mode = "retained"
  end
  local backdrop = FlexLove.new(backdrop_props)

  -- Main window
  local window_props = {
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
  if use_mode_flag then
    window_props.mode = "retained"
  end
  local window = FlexLove.new(window_props)

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
    textColor = Color.new(0.8, 0.9, 1, 1),
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

  local button_container = FlexLove.new({
    parent = row4,
    width = "60%",
    height = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 5,
  })

  local msaa_values = { 0, 1, 2, 4, 8, 16 }
  for _, msaa_val in ipairs(msaa_values) do
    local is_selected = Settings:get("msaa") == msaa_val
    FlexLove.new({
      parent = button_container,
      themeComponent = is_selected and "buttonv1" or "buttonv2",
      text = tostring(msaa_val),
      textAlign = "center",
      width = "8vw",
      height = "100%",
      textSize = "sm",
      disabled = is_selected,
      opacity = is_selected and 0.7 or 1.0,
    })
  end

  -- Audio Settings Section
  FlexLove.new({
    parent = content,
    text = "Audio Settings",
    textAlign = "start",
    textSize = "xl",
    width = "100%",
    textColor = Color.new(0.8, 0.9, 1, 1),
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

  local slider_container = FlexLove.new({
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

  local slider_track = FlexLove.new({
    parent = slider_container,
    width = "80%",
    height = "75%",
    positioning = "flex",
    flexDirection = "horizontal",
    themeComponent = "framev3",
  })

  FlexLove.new({
    parent = slider_track,
    width = (normalized * 100) .. "%",
    height = "100%",
    themeComponent = "buttonv1",
    themeStateLock = true,
  })

  FlexLove.new({
    parent = slider_container,
    text = string.format("%d", value * 100),
    textAlign = "center",
    textSize = "md",
    width = "15%",
  })

  -- Meta controls (bottom buttons)
  local meta_container = FlexLove.new({
    parent = window,
    positioning = "absolute",
    width = "100%",
    height = "10%",
    y = "90%",
    x = "0%",
  })

  local button_bar = FlexLove.new({
    parent = meta_container,
    width = "100%",
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "center",
    alignItems = "center",
    gap = 10,
  })

  FlexLove.new({
    parent = button_bar,
    themeComponent = "buttonv2",
    text = "Reset",
    textAlign = "center",
    width = "15vw",
    height = "6vh",
    textSize = "lg",
  })

  return { backdrop = backdrop, window = window }
end

-- Profile configuration
local PROFILE_NAME = "Settings Menu Mode Comparison"
local ITERATIONS_PER_TEST = 100 -- Create the menu 100 times to measure difference

print("=" .. string.rep("=", 78))
print(string.format("  %s", PROFILE_NAME))
print("=" .. string.rep("=", 78))
print()
print("This profile compares performance when creating a complex settings menu")
print("with explicit mode='retained' flags vs. implicit retained mode (global).")
print()
print(string.format("Test configuration:"))
print(string.format("  - Iterations: %d menu creations per test", ITERATIONS_PER_TEST))
print(string.format("  - Elements per menu: ~45 (backdrop, window, buttons, sliders, etc.)"))
print(string.format("  - Total elements created: ~%d per test", ITERATIONS_PER_TEST * 45))
print()

-- Warm up
print("Warming up...")
FlexLove.init({ immediateMode = false, theme = "space" })
for i = 1, 10 do
  create_settings_menu_with_mode_flag(false)
end
collectgarbage("collect")

-- Test 1: Without explicit mode flags (implicit retained via global setting)
print("Running Test 1: Without explicit mode='retained' flags...")
FlexLove.init({ immediateMode = false, theme = "space" })
collectgarbage("collect")
local mem_before_implicit = collectgarbage("count")
local time_before_implicit = os.clock()

for i = 1, ITERATIONS_PER_TEST do
  local menu = create_settings_menu_with_mode_flag(false)
end

local time_after_implicit = os.clock()
collectgarbage("collect")
local mem_after_implicit = collectgarbage("count")

local time_implicit = time_after_implicit - time_before_implicit
local mem_implicit = mem_after_implicit - mem_before_implicit

print(string.format("  Time: %.4f seconds", time_implicit))
print(string.format("  Memory: %.2f KB", mem_implicit))
print(string.format("  Avg time per menu: %.4f ms", (time_implicit / ITERATIONS_PER_TEST) * 1000))
print()

-- Test 2: With explicit mode="retained" flags
print("Running Test 2: With explicit mode='retained' flags...")
FlexLove.init({ immediateMode = false, theme = "space" })
collectgarbage("collect")
local mem_before_explicit = collectgarbage("count")
local time_before_explicit = os.clock()

for i = 1, ITERATIONS_PER_TEST do
  local menu = create_settings_menu_with_mode_flag(true)
end

local time_after_explicit = os.clock()
collectgarbage("collect")
local mem_after_explicit = collectgarbage("count")

local time_explicit = time_after_explicit - time_before_explicit
local mem_explicit = mem_after_explicit - mem_before_explicit

print(string.format("  Time: %.4f seconds", time_explicit))
print(string.format("  Memory: %.2f KB", mem_explicit))
print(string.format("  Avg time per menu: %.4f ms", (time_explicit / ITERATIONS_PER_TEST) * 1000))
print()

-- Calculate differences
print("=" .. string.rep("=", 78))
print("RESULTS COMPARISON")
print("=" .. string.rep("=", 78))
print()

local time_diff = time_explicit - time_implicit
local time_percent = (time_diff / time_implicit) * 100
local mem_diff = mem_explicit - mem_implicit

print(string.format("Time Difference:"))
print(string.format("  Without mode flag: %.4f seconds", time_implicit))
print(string.format("  With mode flag:    %.4f seconds", time_explicit))
print(string.format("  Difference:        %.4f seconds (%+.2f%%)", time_diff, time_percent))
print()

print(string.format("Memory Difference:"))
print(string.format("  Without mode flag: %.2f KB", mem_implicit))
print(string.format("  With mode flag:    %.2f KB", mem_explicit))
print(string.format("  Difference:        %+.2f KB", mem_diff))
print()

-- Interpretation
print("INTERPRETATION:")
print()
if math.abs(time_percent) < 5 then
  print("  ✓ Performance is essentially identical (< 5% difference)")
  print("    The explicit mode flag has negligible impact on performance.")
elseif time_percent > 0 then
  print(string.format("  ⚠ Explicit mode flag is %.2f%% SLOWER", time_percent))
  print("    This indicates overhead from mode checking/resolution.")
else
  print(string.format("  ✓ Explicit mode flag is %.2f%% FASTER", -time_percent))
  print("    This indicates potential optimization benefits.")
end
print()

if math.abs(mem_diff) < 50 then
  print("  ✓ Memory usage is essentially identical (< 50 KB difference)")
elseif mem_diff > 0 then
  print(string.format("  ⚠ Explicit mode flag uses %.2f KB MORE memory", mem_diff))
else
  print(string.format("  ✓ Explicit mode flag uses %.2f KB LESS memory", -mem_diff))
end
print()

print("RECOMMENDATION:")
print()
if math.abs(time_percent) < 5 and math.abs(mem_diff) < 50 then
  print("  The explicit mode='retained' flag provides clarity and explicitness")
  print("  without any meaningful performance cost. It's recommended for:")
  print("    - Code readability (makes intent explicit)")
  print("    - Future-proofing (if global mode changes)")
  print("    - Mixed-mode UIs (where some elements are immediate)")
else
  print("  Consider the trade-offs based on your specific use case.")
end
print()

print("=" .. string.rep("=", 78))
print("Profile complete!")
print("=" .. string.rep("=", 78))
