# 03. Fix Width/Height Proportional Scaling

meta:
  id: flexlove-responsive-resize-03
  feature: flexlove-responsive-resize
  priority: P2
  depends_on: [flexlove-responsive-resize-02]
  tags: [implementation, scaling, resize-fix]

objective:
- Fix broken proportional scaling logic for element width and height during window resize
- Ensure elements maintain proper aspect ratios and scale correctly
- Replace current broken resize calculation with robust proportional scaling

deliverables:
- Fixed Element:resize() method with correct proportional scaling
- Updated scaling calculations to use viewport units foundation
- Maintained aspect ratios during resize operations
- Improved resize behavior for both absolute and flex positioned elements

steps:
- Analyze current broken resize logic in Element:resize() method (lines 1075-1093)
- Replace simple ratio multiplication with proper viewport-aware scaling
- Implement scale factor calculations that preserve aspect ratios
- Add handling for elements with viewport units vs pixel values
- Update resize propagation to children with correct parent context
- Fix issues with autosizing elements during resize operations
- Ensure flex layout recalculations work properly after resize
- Add resize clamping to prevent elements from becoming too small/large

tests:
- Unit: Test Element:resize() with various window size changes (800x600 -> 1600x1200, etc.)
- Unit: Test proportional scaling maintains aspect ratios (Arrange–Act–Assert)
- Unit: Test elements with mixed unit types scale appropriately
- Integration: Test nested element hierarchies maintain relative relationships
- Integration: Test flex containers with children scale correctly together
- Integration: Test autosizing elements recalculate properly after resize

acceptance_criteria:
- Width and height scale proportionately maintaining aspect ratios
- Elements using viewport units (vw, vh) recalculate correctly on resize
- Percentage-based elements scale relative to their scaled parents
- Pixel-based elements scale proportionally with window size changes
- No elements become negative size or extremely large during resize
- Flex layout recalculates correctly after element resize operations
- All existing resize test scenarios pass with improved scaling

validation:
- Run: `lua simple_resize_test.lua` and verify output shows correct proportional scaling
- Test: Create element 200x100 at 800x600, resize to 1600x1200, verify 400x200 dimensions
- Test: Elements with 50% width maintain 50% of parent width after resize
- Verify: Complex nested layouts scale maintaining relative positioning
- Run: All existing tests pass with new resize behavior

notes:
- Current logic (lines 1081-1084) simply multiplies by ratios - this doesn't handle viewport units
- Need to distinguish between elements that should scale (pixels) vs recalculate (viewport units)
- Consider caching scale factors to avoid recalculation for unchanged dimensions
- Ensure resize doesn't break flex layout calculations by calling layoutChildren() appropriately