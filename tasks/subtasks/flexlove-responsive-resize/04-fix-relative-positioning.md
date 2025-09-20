# 04. Fix X/Y Relative Positioning

meta:
  id: flexlove-responsive-resize-04
  feature: flexlove-responsive-resize
  priority: P2
  depends_on: [flexlove-responsive-resize-03]
  tags: [implementation, positioning, resize-fix]

objective:
- Fix x and y position scaling to maintain proper relative positioning during window resize
- Ensure elements maintain their spatial relationships after resize operations
- Handle both absolute and flex positioned elements correctly

deliverables:
- Fixed position scaling logic in Element:resize() method
- Correct relative positioning calculations for nested elements
- Proper handling of viewport-relative position units
- Maintained spatial relationships between parent and child elements

steps:
- Fix current position scaling in Element:resize() (lines 1083-1084 currently broken)
- Implement proper coordinate scaling that preserves relative positioning
- Add special handling for flex-positioned elements (positions managed by layout)
- Update position calculations to work with viewport units (x="25vw", y="10vh")
- Ensure percentage-based positions scale relative to scaled parent dimensions
- Add position clamping to prevent elements from moving outside reasonable bounds
- Handle edge cases like negative positions and positions larger than parent
- Update flex layout position calculations after resize to maintain relationships

tests:
- Unit: Test position scaling with various window size changes (Arrange–Act–Assert)
- Unit: Test elements maintain relative distance from parent corners/edges
- Unit: Test viewport unit positions (vw, vh) recalculate correctly on resize
- Integration: Test nested absolute elements maintain relative positioning
- Integration: Test flex children positions update correctly after parent resize
- Integration: Test mixed positioning types (absolute children in flex parents)

acceptance_criteria:
- X and Y positions scale proportionally maintaining relative positioning
- Elements using viewport position units recalculate correctly on resize
- Percentage-based positions maintain correct relative positioning to parents
- Absolute positioned elements maintain spatial relationships with siblings
- Flex positioned elements are repositioned correctly by layout system after resize
- No elements move outside their parent boundaries unexpectedly
- Complex nested layouts maintain relative positioning relationships

validation:
- Test: Element at x=100, y=50 in 800x600 window moves to x=200, y=100 in 1600x1200 window
- Test: Element with x="25%", y="10%" maintains same relative position after parent resize
- Test: Flex container children maintain relative layout positions after resize
- Verify: All positioning test suites pass with new resize position handling
- Run: Complex layout examples maintain visual structure after resize

notes:
- Current logic (lines 1083-1084) simply multiplies by ratios - doesn't distinguish positioning types
- Flex positioned elements should not have x/y scaled directly - layout system handles positioning
- Need to handle both relative units (%, vw, vh) and absolute pixel positions differently
- Consider parent-child position relationships when scaling nested elements