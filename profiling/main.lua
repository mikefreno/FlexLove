-- FlexLöve Profiler - Main Entry Point
-- Load FlexLöve from parent directory
package.path = package.path .. ";../?.lua;../?/init.lua"

local FlexLove = require("FlexLove")
local PerformanceProfiler = require("profiling.utils.PerformanceProfiler")

local state = {
  mode = "menu", -- "menu" or "profile"
  currentProfile = nil,
  profiler = nil,
  profiles = {},
  selectedIndex = 1,
  ui = nil,
  error = nil,
}

---@return table
local function discoverProfiles()
  local profiles = {}
  local files = love.filesystem.getDirectoryItems("__profiles__")

  for _, file in ipairs(files) do
    if file:match("%.lua$") then
      local name = file:gsub("%.lua$", "")
      table.insert(profiles, {
        name = name,
        displayName = name:gsub("_", " "):gsub("(%a)(%w*)", function(a, b) return a:upper() .. b end),
        path = "__profiles__/" .. file,
      })
    end
  end

  table.sort(profiles, function(a, b) return a.name < b.name end)
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
  if state.currentProfile and type(state.currentProfile.cleanup) == "function" then
    pcall(function() state.currentProfile.cleanup() end)
  end

  state.currentProfile = nil
  state.profiler = nil
  state.mode = "menu"
  collectgarbage("collect")
end

local function buildMenu()
  FlexLove.beginFrame()

  local root = FlexLove.new({
    width = "100%",
    height = "100%",
    backgroundColor = {0.1, 0.1, 0.15, 1},
    flexDirection = "column",
    justifyContent = "flex-start",
    alignItems = "center",
    padding = 40,
  })

  root:addChild(FlexLove.new({
    flexDirection = "column",
    alignItems = "center",
    gap = 30,
    children = {
      FlexLove.new({
        width = 600,
        height = 80,
        backgroundColor = {0.15, 0.15, 0.25, 1},
        borderRadius = 10,
        justifyContent = "center",
        alignItems = "center",
        children = {
          FlexLove.new({
            textContent = "FlexLöve Performance Profiler",
            fontSize = 32,
            color = {0.3, 0.8, 1, 1},
          })
        }
      }),

      FlexLove.new({
        textContent = "Select a profile to run:",
        fontSize = 20,
        color = {0.8, 0.8, 0.8, 1},
      }),

      FlexLove.new({
        width = 600,
        flexDirection = "column",
        gap = 10,
        children = (function()
          local items = {}
          for i, profile in ipairs(state.profiles) do
            local isSelected = i == state.selectedIndex
            table.insert(items, FlexLove.new({
              width = "100%",
              height = 50,
              backgroundColor = isSelected and {0.2, 0.4, 0.8, 1} or {0.15, 0.15, 0.25, 1},
              borderRadius = 8,
              justifyContent = "flex-start",
              alignItems = "center",
              padding = 15,
              cursor = "pointer",
              onClick = function()
                state.selectedIndex = i
                loadProfile(profile)
              end,
              onHover = function(element)
                if not isSelected then
                  element.backgroundColor = {0.2, 0.2, 0.35, 1}
                end
              end,
              onHoverEnd = function(element)
                if not isSelected then
                  element.backgroundColor = {0.15, 0.15, 0.25, 1}
                end
              end,
              children = {
                FlexLove.new({
                  textContent = profile.displayName,
                  fontSize = 18,
                  color = isSelected and {1, 1, 1, 1} or {0.8, 0.8, 0.8, 1},
                })
              }
            }))
          end
          return items
        end)()
      }),

      FlexLove.new({
        textContent = "Use ↑/↓ to select, ENTER to run, ESC to quit",
        fontSize = 14,
        color = {0.5, 0.5, 0.5, 1},
        marginTop = 20,
      }),
    }
  }))

  if state.error then
    root:addChild(FlexLove.new({
      width = 600,
      padding = 15,
      backgroundColor = {0.8, 0.2, 0.2, 1},
      borderRadius = 8,
      marginTop = 20,
      children = {
        FlexLove.new({
          textContent = "Error: " .. state.error,
          fontSize = 14,
          color = {1, 1, 1, 1},
        })
      }
    }))
  end

  FlexLove.endFrame()
end

function love.load(args)
  FlexLove.init({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
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

function love.update(dt)
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

function love.draw()
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

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Press R to reset | ESC to menu | F11 fullscreen", 10, love.graphics.getHeight() - 25)
  end
end

function love.keypressed(key)
  if state.mode == "menu" then
    if key == "escape" then
      love.event.quit()
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
        pcall(function() state.currentProfile.reset() end)
      end
    elseif key == "f11" then
      love.window.setFullscreen(not love.window.getFullscreen())
    end

    if state.currentProfile and type(state.currentProfile.keypressed) == "function" then
      pcall(function() state.currentProfile.keypressed(key) end)
    end
  end
end

function love.mousepressed(x, y, button)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.mousepressed) == "function" then
      pcall(function() state.currentProfile.mousepressed(x, y, button) end)
    end
  end
end

function love.mousereleased(x, y, button)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.mousereleased) == "function" then
      pcall(function() state.currentProfile.mousereleased(x, y, button) end)
    end
  end
end

function love.mousemoved(x, y, dx, dy)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.mousemoved) == "function" then
      pcall(function() state.currentProfile.mousemoved(x, y, dx, dy) end)
    end
  end
end

function love.resize(w, h)
  FlexLove.resize(w, h)
  if state.mode == "profile" and state.currentProfile then
    if type(state.currentProfile.resize) == "function" then
      pcall(function() state.currentProfile.resize(w, h) end)
    end
  end
end

function love.quit()
  if state.currentProfile and type(state.currentProfile.cleanup) == "function" then
    pcall(function() state.currentProfile.cleanup() end)
  end
end
