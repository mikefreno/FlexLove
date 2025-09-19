# 02. Absolute Positioning Child Layout Tests

meta:
  id: gui-layout-testing-02
  feature: gui-layout-testing
  priority: P2
  depends_on: [gui-layout-testing-01]
  tags: [implementation, tests-required]

objective:
- Test that absolute positioning elements properly handle child elements and don't interfere with flex layout calculations

deliverables:
- Unit tests for adding children to absolute positioned elements
- Tests for child positioning behavior in absolute mode
- Tests for parent-child coordinate relationships

steps:
- Create test suite for absolute positioning child layout
- Test adding children to absolute positioned parents
- Verify that children maintain their own coordinates
- Verify that absolute positioned parents don't affect child layout calculations
- Test that absolute children don't participate in flex layout of their parent

tests:
- Unit: Test Element.addChild() with absolute positioned parent, verify that child coordinates are preserved
- Unit: Test that absolute positioned elements don't call layoutChildren() method (should return early)
- Integration/e2e: Verify that adding children to absolute parent doesn't affect parent's flex properties

acceptance_criteria:
- Children can be added to absolute positioned parents successfully
- Child elements maintain their own coordinate system
- Absolute positioned parents don't participate in flex layout calculations
- Absolute children don't influence parent's layout behavior
- Children are properly added to parent's children table

validation:
- Run existing tests in testing/__tests__/gui-layout-testing.lua if it exists, or create new test file for this functionality
- Execute: lua testing/__tests__/gui-layout-testing.lua

notes:
- Absolute positioned elements should not call layoutChildren() method (as per the code)
- Children of absolute parents should maintain their own x/y coordinates independent of parent changes
- The layoutChildren() function should return early when positioning == Positioning.ABSOLUTE
- Absolute children should not participate in flex layout calculations of their parent