# FlexLöve Performance Profiler

A comprehensive profiling system for stress testing and benchmarking FlexLöve's performance with the full Love2D runtime.

## Quick Start

1. **Run the profiler:**
   ```bash
   love profiling/
   ```

2. **Select a profile** using arrow keys and press ENTER

3. **View real-time metrics** in the overlay (FPS, frame time, memory)

## Running Specific Profiles

Run a specific profile directly from the command line:

```bash
love profiling/ layout_stress_profile
love profiling/ animation_stress_profile
love profiling/ render_stress_profile
love profiling/ event_stress_profile
love profiling/ immediate_mode_profile
love profiling/ memory_profile
```

## Available Profiles

### Layout Stress Profile
Tests layout engine performance with large element hierarchies.

**Features:**
- Adjustable element count (100-5000)
- Multiple nesting levels
- Flexbox layout stress testing
- Dynamic element creation

**Controls:**
- `+` / `-` : Increase/decrease element count by 50
- `R` : Reset to default (100 elements)
- `ESC` : Return to menu

### Animation Stress Profile
Tests animation system performance with many concurrent animations.

**Features:**
- 100-1000 animated elements
- Multiple animation properties (position, size, color, opacity)
- Various easing functions
- Concurrent animations

**Controls:**
- `+` / `-` : Increase/decrease animation count by 50
- `SPACE` : Pause/resume all animations
- `R` : Reset animations
- `ESC` : Return to menu

### Render Stress Profile
Tests rendering performance with heavy draw operations.

**Features:**
- Thousands of drawable elements
- Rounded rectangles with various radii
- Text rendering stress
- Layering and overdraw scenarios
- Effects (blur, shadows)

**Controls:**
- `+` / `-` : Increase/decrease element count
- `1-5` : Toggle different render features
- `R` : Reset
- `ESC` : Return to menu

### Event Stress Profile
Tests event handling performance at scale.

**Features:**
- Many interactive elements (500+)
- Event propagation through deep hierarchies
- Hover and click event handling
- Hit testing performance
- Visual feedback on interactions

**Controls:**
- `+` / `-` : Increase/decrease interactive elements
- Move mouse to test hover performance
- Click elements to test event dispatch
- `R` : Reset
- `ESC` : Return to menu

### Immediate Mode Profile
Tests immediate mode where UI is recreated every frame.

**Features:**
- Full UI recreation each frame
- Performance comparison vs retained mode
- 50-300 element recreation
- State persistence across frames
- BeginFrame/EndFrame pattern

**Controls:**
- `+` / `-` : Increase/decrease element count
- `R` : Reset
- `ESC` : Return to menu

### Memory Profile
Tests memory usage patterns and garbage collection.

**Features:**
- Memory growth tracking
- GC frequency and pause time monitoring
- Element creation/destruction cycles
- ImageCache memory testing
- Memory leak detection

**Controls:**
- `SPACE` : Create/destroy element batch
- `G` : Force garbage collection
- `R` : Reset memory tracking
- `ESC` : Return to menu

## Performance Metrics

The profiler overlay displays:

- **FPS** : Current frames per second (color-coded: green=good, yellow=warning, red=critical)
- **Frame Time** : Current frame time in milliseconds
- **Avg Frame** : Average frame time across all frames
- **Min/Max** : Minimum and maximum frame times
- **P95/P99** : 95th and 99th percentile frame times
- **Memory** : Current memory usage in MB
- **Peak Memory** : Maximum memory usage recorded
- **Top Markers** : Custom timing markers (if used by profile)

## Keyboard Shortcuts

### Global Controls
- `ESC` : Return to menu (from profile) or quit (from menu)
- `R` : Reset current profile
- `F11` : Toggle fullscreen

### Menu Navigation
- `↑` / `↓` : Navigate profile list
- `ENTER` / `SPACE` : Select profile

## Creating Custom Profiles

Create a new file in `profiling/__profiles__/` following this template:

```lua
local FlexLove = require("FlexLove")

local profile = {}

function profile.init()
  -- Initialize FlexLove and build your UI
  FlexLove.init({
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
  })
  
  -- Build your test UI here
end

function profile.update(dt)
  -- Update logic (animations, state changes, etc)
end

function profile.draw()
  -- Draw your UI
  -- The profiler overlay is drawn automatically
end

function profile.keypressed(key)
  -- Handle keyboard input specific to your profile
end

function profile.resize(w, h)
  -- Handle window resize
  FlexLove.resize(w, h)
end

function profile.reset()
  -- Reset profile to initial state
end

function profile.cleanup()
  -- Clean up resources
end

return profile
```

The filename (without `.lua` extension) will be used as the profile name in the menu.

## Using PerformanceProfiler Directly

For custom timing markers in your profile:

```lua
local PerformanceProfiler = require("profiling.utils.PerformanceProfiler")
local profiler = PerformanceProfiler.new()

function profile.update(dt)
  profiler:beginFrame()
  
  -- Mark custom operation
  profiler:markBegin("my_operation")
  -- ... do something expensive ...
  profiler:markEnd("my_operation")
  
  profiler:endFrame()
end

function profile.draw()
  -- Draw profiler overlay
  profiler:draw(10, 10)
  
  -- Export report
  local report = profiler:getReport()
  print("Average FPS:", report.fps.average)
  print("My operation avg time:", report.markers.my_operation.average)
end
```

## Configuration

Edit `profiling/conf.lua` to adjust:
- Window size (default: 1280x720)
- VSync (default: off for uncapped FPS)
- MSAA (default: 4x)
- Stencil support (required for rounded rectangles)

## Interpreting Results

### Good Performance
- FPS: 60+ (displayed in green)
- Frame Time: < 13ms
- P99 Frame Time: < 16.67ms

### Warning Signs
- FPS: 45-60 (displayed in yellow)
- Frame Time: 13-16.67ms
- Frequent GC pauses

### Critical Issues
- FPS: < 45 (displayed in red)
- Frame Time: > 16.67ms
- Memory continuously growing
- Stuttering/frame drops

## Troubleshooting

### Profile fails to load
- Check Lua syntax errors in the profile file
- Ensure `profile.init()` function exists
- Verify FlexLove is initialized properly

### Low FPS in all profiles
- Disable VSync in conf.lua
- Check GPU drivers are up to date
- Try reducing element counts
- Monitor CPU/GPU usage externally

### Memory keeps growing
- Check for element leaks (not cleaning up)
- Verify event handlers are removed
- Test with Memory Profile to identify leaks
- Force GC with `G` key to see if memory is released

### Profiler overlay not showing
- Ensure PerformanceProfiler is initialized in profile
- Call `profiler:beginFrame()` and `profiler:endFrame()`
- Check overlay isn't being drawn off-screen

## Architecture

```
profiling/
├── conf.lua                    # Love2D configuration
├── main.lua                    # Main entry point and harness
├── __profiles__/               # Profile test files
│   ├── layout_stress_profile.lua
│   ├── animation_stress_profile.lua
│   ├── render_stress_profile.lua
│   ├── event_stress_profile.lua
│   ├── immediate_mode_profile.lua
│   └── memory_profile.lua
└── utils/
    └── PerformanceProfiler.lua # Profiling utility module
```

## Tips for Profiling

1. **Start small**: Begin with low element counts and scale up
2. **Watch for drop-offs**: Note when FPS drops below 60
3. **Compare modes**: Test both immediate and retained modes
4. **Long runs**: Run profiles for 5+ minutes to catch memory leaks
5. **Use markers**: Add custom markers for specific operations
6. **Export data**: Use `profiler:exportJSON()` for detailed analysis
7. **Monitor externally**: Use OS tools to monitor CPU/GPU usage

## Performance Targets

FlexLöve should maintain 60 FPS with:
- 1000+ simple elements (retained mode)
- 200+ elements (immediate mode)
- 500+ concurrent animations
- 1000+ draw calls
- 500+ interactive elements

## Contributing

To add a new profile:

1. Create a new file in `__profiles__/` with `_profile.lua` suffix
2. Follow the profile template structure
3. Test thoroughly with various configurations
4. Document controls and features in this README

## License

Same license as FlexLöve (MIT)
