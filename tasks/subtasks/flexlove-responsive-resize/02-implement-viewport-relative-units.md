# 02. Implement Viewport-Relative Units

meta:
  id: flexlove-responsive-resize-02
  feature: flexlove-responsive-resize
  priority: P2
  depends_on: [flexlove-responsive-resize-01]
  tags: [implementation, viewport-units, responsive]

objective:
- Add support for viewport-relative sizing and positioning units (%, vw, vh, vmin, vmax)
- Enable responsive design patterns with percentage-based layouts
- Provide foundation for proportional scaling system

deliverables:
- New unit parsing system that supports multiple unit types
- Updated Element constructor to handle viewport-relative units
- New viewport tracking and calculation methods
- Documentation for new unit system usage

steps:
- Create unit parsing utility that detects and converts different unit types (px, %, vw, vh, vmin, vmax)
- Add viewport size tracking to Gui class (current window dimensions)
- Modify Element.new() to parse and store unit types alongside values
- Implement unit resolution methods that convert relative units to pixels
- Update calculateAutoWidth/Height to work with viewport units
- Add unit conversion for x, y, width, height, padding, margin properties
- Create helper methods for viewport calculations (vw=1% of viewport width, etc.)

tests:
- Unit: Test unit parsing for all supported types ("100px", "50%", "25vw", "75vh", "10vmin", "90vmax")
- Unit: Test viewport unit calculations with different window sizes (Arrange–Act–Assert)
- Unit: Test Element creation with mixed unit types for different properties
- Integration: Test nested elements with parent using % and child using vw/vh
- Integration: Test viewport unit behavior during window resize events

acceptance_criteria:
- Elements accept viewport units for x, y, width, height, padding, margin properties
- Percentage units (%) are relative to parent container dimensions
- Viewport units (vw, vh) are relative to window/viewport dimensions
- vmin/vmax units work correctly (vmin = smaller of vw/vh, vmax = larger)
- Mixed unit types work together (e.g., width="50%", height="200px")
- Unit calculations are accurate and performant
- Backward compatibility maintained for pixel values

validation:
- Run: Create element with `w="50vw", h="25vh"` and verify dimensions match 50% of window width, 25% of window height
- Run: Create element with `padding={left="5%", top="10px"}` and verify mixed units resolve correctly
- Test: Resize window and verify viewport units recalculate appropriately
- Verify: All existing tests pass with new unit system

notes:
- Support string values like "50vw" alongside numeric pixel values
- Cache viewport dimensions to avoid repeated love.window.getMode() calls
- Consider performance implications of unit conversion during layout
- Percentage units should respect padding/border of parent containers