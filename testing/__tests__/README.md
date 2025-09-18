# FlexLove GUI Library Test Suite

This directory contains comprehensive tests for the FlexLove GUI library. The tests cover layout behavior, property management, animations, and utility functions.

## Test Files

1. **01_absolute_positioning.lua**
   - Basic absolute positioning
   - Parent-child relationships
   - Coordinate system tests

2. **02_flex_direction.lua**
   - Horizontal flex layout
   - Vertical flex layout
   - Mixed direction layouts

3. **03_vertical_flex_direction.lua**
   - Vertical layout specifics
   - Column-based layouts
   - Vertical alignment

4. **04_justify_content.lua**
   - Flex-start alignment
   - Flex-end alignment
   - Space-between distribution
   - Space-around distribution

5. **05_align_items.lua**
   - Cross-axis alignment
   - Stretch behavior
   - Baseline alignment

6. **06_flex_wrap.lua**
   - Wrapping behavior
   - Multi-line layouts
   - Wrap alignment

7. **07_layout_validation.lua**
   - Edge cases
   - Nested containers
   - Deep hierarchies

8. **08_performance.lua**
   - Large element counts
   - Deep hierarchies
   - Dynamic updates
   - Rapid resizing

9. **09_element_properties.lua**
   - Basic properties
   - Custom properties
   - Property modification
   - Visibility and clipping

10. **10_animation_and_transform.lua**
    - Basic transformations
    - Animation tweening
    - Easing functions
    - Animation cancellation

11. **11_auxiliary_functions.lua**
    - Element queries
    - Debug utilities
    - Layout helpers
    - Utility functions

## Running Tests

### Run All Tests
```bash
cd /path/to/station_alpha
for f in game/libs/testing/__tests__/flexlove/*.lua; do lua "$f"; done
```

### Run Specific Test File
```bash
cd /path/to/station_alpha
lua game/libs/testing/__tests__/flexlove/[test_file].lua
```

## Test Structure

Each test file follows this general structure:

```lua
package.path = package.path .. ";/path/to/station_alpha/?.lua"

local luaunit = require('game/libs/testing/luaunit')
require('game/libs/testing/loveStub')
local FlexLove = require('game/libs/FlexLove')

TestClassName = {}

function TestClassName:setUp()
    self.GUI = FlexLove.GUI
end

function TestClassName:testFeature()
    -- Test implementation
end

os.exit(luaunit.LuaUnit.run())
```

## Known Issues

1. Layout Calculations
   - Some justify-content calculations need verification
   - Align-items behavior needs adjustment
   - Flex-wrap positioning requires fixes

2. Missing Methods
   - Animation and transform methods not implemented
   - Some utility functions not available
   - Custom property support incomplete

3. Performance
   - Resize calculations may need optimization
   - Deep hierarchy performance could be improved

## Contributing

When adding new tests:

1. Follow the existing naming convention
2. Add proper type annotations
3. Include nil checks for optional features
4. Document expected behavior
5. Add the test to this README

## Dependencies

- Lua 5.1+ / LuaJIT
- LÖVE2D (for graphics features)
- luaunit (testing framework)