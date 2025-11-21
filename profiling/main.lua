-- FlexLöve Profiler - Main Entry Point
-- Load FlexLöve from parent directory
package.path = package.path .. ";../?.lua;../?/init.lua"

local FlexLove = require("libs.FlexLove")
local PerformanceProfiler = require("profiling.utils.PerformanceProfiler")
local lv = love

local state = {
  mode = "menu", -- "menu" or "profile"
  currentProfile = nil,
  currentProfileInfo = nil,
  profiler = nil,
  profiles = {},
  selectedIndex = 1,
  ui = nil,
  error = nil,
}

---@return table
local function discoverProfiles()
  local profiles = {}
  local files = lv.filesystem.getDirectoryItems("__profiles__")

  for _, file in ipairs(files) do
    if file:match("%.lua$") then
      local name = file:gsub("%.lua$", "")
      table.insert(profiles, {
        name = name,
        displayName = name:gsub("_", " "):gsub("(%a)(%w*)", function(a, b)
          return a:upper() .. b
        end),
        path = "__profiles__/" .. file,
      })
    end
  end

  table.sort(profiles, function(a, b)
    return a.name < b.name
  end)
  return profiles
end

---@param profileInfo table
local function loadProfile(profileInfo)
  state.error = nil
  local success, profile = pcall(function()
    return require("profiling.__profiles__." .. profileInfo.name)
  end)

  if not success then
    state.error = "Failed to load profile: " .. tostring(profile)
    return false
  end

  if type(profile.init) ~= "function" then
    state.error = "Profile missing init() function"
    return false
  end

  state.currentProfile = profile
  state.currentProfileInfo = profileInfo
  state.profiler = PerformanceProfiler.new()
  state.mode = "profile"

  success, state.error = pcall(function()
    profile.init()
  end)

  if not success then
    state.error = "Profile init failed: " .. tostring(state.error)
    state.currentProfile = nil
    state.mode = "menu"
    return false
  end

  return true
end

local function returnToMenu()
  -- Save profiling report before exiting
  if state.profiler and state.currentProfileInfo then
    local success, filepath = state.profiler:saveReport(state.currentProfileInfo.name)
    if success then
      print("\n========================================")
      print("✓ Profiling report saved successfully!")
      print("  Location: " .. filepath)
      print("========================================\n")
    else
      print("\n✗ Failed to save report: " .. tostring(filepath) .. "\n")
    end
  end

  if state.currentProfile and type(state.currentProfile.cleanup) == "function" then
    pcall(function()
      state.currentProfile.cleanup()
    end)
  end

  state.currentProfile = nil
  state.currentProfileInfo = nil
  state.profiler = nil
  state.mode = "menu"
  collectgarbage("collect")
end

local function buildMenu()
  FlexLove.beginFrame()

  local root = FlexLove.new({
    width = "100%",
    height = "100%",
    backgroundColor = FlexLove.Color.new(0.1, 0.1, 0.15, 1),
    positioning = "flex",
    flexDirection = "vertical",
    justifyContent = "flex-start",
    alignItems = "center",
    padding = { horizontal = 40, vertical = 40 },
  })

  local container = FlexLove.new({
    parent = root,
    positioning = "flex",
    flexDirection = "vertical",
    alignItems = "center",
    gap = 30,
  })

  -- Title
  FlexLove.new({
    parent = container,
    width = 600,
    height = 80,
    backgroundColor = FlexLove.Color.new(0.15, 0.15, 0.25, 1),
    borderRadius = 10,
    positioning = "flex",
    justifyContent = "center",
    alignItems = "center",
    text = "FlexLöve Performance Profiler",
    textSize = "3xl",
    textColor = FlexLove.Color.new(0.3, 0.8, 1, 1),
  })

  -- Subtitle
  FlexLove.new({
    parent = container,
    text = "Select a profile to run:",
    textSize = "xl",
    textColor = FlexLove.Color.new(0.8, 0.8, 0.8, 1),
  })

  -- Profile list
  local profileList = FlexLove.new({
    parent = container,
    width = 600,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
  })

  for i, profile in ipairs(state.profiles) do
    local isSelected = i == state.selectedIndex
    local button = FlexLove.new({
      parent = profileList,
      width = "100%",
      height = 50,
      backgroundColor = isSelected and FlexLove.Color.new(0.2, 0.4, 0.8, 1) or FlexLove.Color.new(0.15, 0.15, 0.25, 1),
      borderRadius = 8,
      positioning = "flex",
      justifyContent = "flex-start",
      alignItems = "center",
      padding = { horizontal = 15, vertical = 15 },
      onEvent = function(element, event)
        if event.type == "release" then
          state.selectedIndex = i
          loadProfile(profile)
        elseif event.type == "hover" and not isSelected then
          element.backgroundColor = FlexLove.Color.new(0.2, 0.2, 0.35, 1)
        elseif event.type == "unhover" and not isSelected then
          element.backgroundColor = FlexLove.Color.new(0.15, 0.15, 0.25, 1)
        end
      end,
    })

    FlexLove.new({
      parent = button,
      text = profile.displayName,
      textSize = "lg",
      textColor = isSelected and FlexLove.Color.new(1, 1, 1, 1) or FlexLove.Color.new(0.8, 0.8, 0.8, 1),
    })
  end

  -- Instructions
  FlexLove.new({
    parent = container,
    text = "Use ↑/↓ to select, ENTER to run, ESC to quit",
    textSize = "md",
    textColor = FlexLove.Color.new(0.5, 0.5, 0.5, 1),
    margin = { top = 20 },
  })

  -- Error display
  if state.error then
    local errorBox = FlexLove.new({
      parent = container,
      width = 600,
      padding = { horizontal = 15, vertical = 15 },
      backgroundColor = FlexLove.Color.new(0.8, 0.2, 0.2, 1),
      borderRadius = 8,
      margin = { top = 20 },
    })

    FlexLove.new({
      parent = errorBox,
      text = "Error: " .. state.error,
      textSize = "md",
      textColor = FlexLove.Color.new(1, 1, 1, 1),
    })
  end

  FlexLove.endFrame()
end

function lv.load(args)
  FlexLove.init({
    width = lv.graphics.getWidth(),
    height = lv.graphics.getHeight(),
    immediateMode = true,
  })

  state.profiles = discoverProfiles()

  if #args > 0 then
    local profileName = args[1]
    for _, profile in ipairs(state.profiles) do
      if profile.name == profileName then
        loadProfile(profile)
        return
      end
    end
    print("Profile not found: " .. profileName)
  end
end

function lv.update(dt)
  if state.mode == "menu" then
    FlexLove.update(dt)
  elseif state.mode == "profile" and state.currentProfile then
    if state.profiler then
      state.profiler:beginFrame()
    end

    if type(state.currentProfile.update) == "function" then
      local success, err = pcall(function()
        state.currentProfile.update(dt)
      end)
      if not success then
        state.error = "Profile update error: " .. tostring(err)
        returnToMenu()
      end
    end

    if state.profiler then
      state.profiler:endFrame()
    end
  end
end

function lv.draw()
  if state.mode == "menu" then
    buildMenu()
    FlexLove.draw()
  elseif state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.draw) == "function" then
      local success, err = pcall(function()
        state.currentProfile.draw()
      end)
      if not success then
        state.error = "Profile draw error: " .. tostring(err)
        returnToMenu()
        return
      end
    end

    if state.profiler then
      state.profiler:draw(10, 10)
    end

    lv.graphics.setColor(1, 1, 1, 1)
    lv.graphics.print("Press R to reset | S to save report | ESC to menu | F11 fullscreen", 10, love.graphics.getHeight() - 25)
  end
end

function lv.keypressed(key)
  if state.mode == "menu" then
    if key == "escape" then
      lv.event.quit()
    elseif key == "up" then
      state.selectedIndex = math.max(1, state.selectedIndex - 1)
    elseif key == "down" then
      state.selectedIndex = math.min(#state.profiles, state.selectedIndex + 1)
    elseif key == "return" or key == "space" then
      if state.profiles[state.selectedIndex] then
        loadProfile(state.profiles[state.selectedIndex])
      end
    end
  elseif state.mode == "profile" then
    if key == "escape" then
      returnToMenu()
    elseif key == "r" then
      if state.profiler then
        state.profiler:reset()
      end
      if state.currentProfile and type(state.currentProfile.reset) == "function" then
        pcall(function()
          state.currentProfile.reset()
        end)
      end
    elseif key == "s" then
      -- Save report manually
      if state.profiler and state.currentProfileInfo then
        local success, filepath = state.profiler:saveReport(state.currentProfileInfo.name)
        if success then
          print("\n========================================")
          print("✓ Profiling report saved successfully!")
          print("  Location: " .. filepath)
          print("========================================\n")
        else
          print("\n✗ Failed to save report: " .. tostring(filepath) .. "\n")
        end
      end
    elseif key == "f11" then
      lv.window.setFullscreen(not love.window.getFullscreen())
    end

    if state.currentProfile and type(state.currentProfile.keypressed) == "function" then
      pcall(function()
        state.currentProfile.keypressed(key, state.profiler)
      end)
    end
  end
end

function lv.mousepressed(x, y, button)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.mousepressed) == "function" then
      pcall(function()
        state.currentProfile.mousepressed(x, y, button)
      end)
    end
  end
end

function lv.mousereleased(x, y, button)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.mousereleased) == "function" then
      pcall(function()
        state.currentProfile.mousereleased(x, y, button)
      end)
    end
  end
end

function lv.mousemoved(x, y, dx, dy)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.mousemoved) == "function" then
      pcall(function()
        state.currentProfile.mousemoved(x, y, dx, dy)
      end)
    end
  end
end

function lv.resize(w, h)
  FlexLove.resize(w, h)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.resize) == "function" then
      pcall(function()
        state.currentProfile.resize(w, h)
      end)
    end
  end
end

function lv.quit()
  if state.currentProfile and type(state.currentProfile.cleanup) == "function" then
    pcall(function()
      state.currentProfile.cleanup()
    end)
  end
end
