# 05. Add Tests and Examples

meta:
  id: nineslice-corner-scaling-05
  feature: nineslice-corner-scaling
  priority: P2
  depends_on: [nineslice-corner-scaling-04]
  tags: [tests-required, documentation]

objective:
- Create comprehensive tests for scaling functionality and visual demonstration examples

deliverables:
- Test file: `testing/__tests__/22_image_scaler_nearest_tests.lua`
- Test file: `testing/__tests__/23_image_scaler_bilinear_tests.lua`
- Test file: `testing/__tests__/24_nineslice_corner_scaling_tests.lua`
- Example demo: `examples/NineSliceCornerScalingDemo.lua`
- Updated documentation in themes/README.md

steps:
- Create `22_image_scaler_nearest_tests.lua`:
  - Test basic 2x scaling with solid colors
  - Test non-uniform scaling (2x3)
  - Test edge cases (1x1, same size)
  - Verify pixel-perfect nearest-neighbor sampling
- Create `23_image_scaler_bilinear_tests.lua`:
  - Test gradient interpolation
  - Test checkerboard pattern smoothing
  - Verify smooth transitions
  - Compare against nearest-neighbor for smoothness
- Create `24_nineslice_corner_scaling_tests.lua`:
  - Test NineSlice.draw with scaleCorners=true
  - Test both "nearest" and "bilinear" algorithms
  - Test cache population and reuse
  - Test cache invalidation on resize
  - Verify backward compatibility (scaleCorners=false)
- Create `NineSliceCornerScalingDemo.lua`:
  - Side-by-side comparison: no scaling, nearest, bilinear
  - Interactive buttons to toggle scaling modes
  - Display at multiple sizes to show scaling effect
  - Show performance metrics (FPS, cache status)
- Update `themes/README.md`:
  - Add "Corner Scaling" section
  - Explain when to use scaleCorners
  - Document scalingAlgorithm options
  - Provide usage examples
  - Add visual comparison images/descriptions

tests:
- Unit: All ImageScaler tests pass independently
- Unit: All NineSlice scaling tests pass
- Integration: Demo runs without errors
- Integration: All scaling modes work in demo
- Manual: Visual inspection confirms correct scaling behavior

acceptance_criteria:
- All test files execute successfully with 100% pass rate
- Tests cover edge cases and error conditions
- Demo provides clear visual comparison of scaling modes
- Demo is interactive and educational
- Documentation clearly explains feature usage
- Documentation includes practical examples
- All existing tests continue to pass
- New tests added to runAll.lua test suite

validation:
- Run: `cd testing && lua runAll.lua`
- Verify: All tests pass including new ones
- Run: `love examples/NineSliceCornerScalingDemo.lua`
- Verify: Demo shows clear visual differences between modes
- Manual: Review documentation for clarity and completeness
- Check: Performance is acceptable at all scaling levels

notes:
- Test images should be simple (solid colors, gradients) for predictable results
- Use luaunit assertions: assertEquals, assertTrue, assertAlmostEquals (for float comparisons)
- Demo should clearly label each scaling mode
- Consider adding zoom functionality to demo for detailed inspection
- Document performance tradeoffs: nearest is faster, bilinear is smoother
- Include example theme definition showing scaleCorners usage:
  ```lua
  button = {
    atlas = "themes/button.png",
    insets = { left = 8, top = 8, right = 8, bottom = 8 },
    scaleCorners = true,
    scalingAlgorithm = "bilinear"
  }
  ```
- Explain use case: pixel art themes that should scale cleanly with window size
