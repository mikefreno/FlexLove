---@diagnostic disable: lowercase-global
function love.conf(t)
  t.identity = "flexlove-profiler"
  t.version = "11.5"
  t.console = true

  -- Window configuration
  t.window.title = "FlexLöve Profiler"
  t.window.width = 1280
  t.window.height = 720
  t.window.borderless = false
  t.window.resizable = true
  t.window.minwidth = 800
  t.window.minheight = 600
  t.window.fullscreen = false
  t.window.fullscreentype = "desktop"
  t.window.vsync = 0  -- Disable VSync for uncapped FPS testing
  t.window.msaa = 4
  t.window.depth = nil
  t.window.stencil = true  -- Required for rounded rectangles
  t.window.display = 1
  t.window.highdpi = true
  t.window.usedpiscale = true
  t.window.x = nil
  t.window.y = nil

  -- Enable required modules
  t.modules.audio = false      -- Not needed for UI profiling
  t.modules.data = true
  t.modules.event = true
  t.modules.font = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = false   -- Not needed
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = false    -- Not needed
  t.modules.sound = false      -- Not needed
  t.modules.system = true
  t.modules.thread = false
  t.modules.timer = true       -- Essential for profiling
  t.modules.touch = true
  t.modules.video = false      -- Not needed
  t.modules.window = true
end
