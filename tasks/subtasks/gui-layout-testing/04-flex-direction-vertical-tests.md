# 04. Vertical Flex Direction Tests

meta:
  id: gui-layout-testing-04
  feature: gui-layout-testing
  priority: P2
  depends_on: []
  tags: [implementation, tests-required]

objective:
- Test that flex layout works correctly with vertical direction

deliverables:
- Unit tests for vertical flex direction functionality
- Tests for child positioning in vertical flex layout
- Tests for proper spacing and alignment in vertical layout

steps:
- Create test suite for vertical flex direction tests
- Test element creation with flex direction = FlexDirection.VERTICAL
- Verify that children are positioned vertically
- Test proper spacing between children
- Verify that alignment works correctly in vertical direction

tests:
- Unit: Test Element.new() with positioning=Positioning.FLEX and flexDirection=FlexDirection.VERTICAL, verify that the element is set up for vertical layout
- Unit: Test layoutChildren() method with vertical flex direction, verify that children are positioned vertically along y-axis
- Integration/e2e: Verify that vertical flex elements position children correctly along y-axis

acceptance_criteria:
- Elements with flexDirection=FlexDirection.VERTICAL can be created successfully
- Children are positioned vertically (along y-axis) relative to parent
- Proper spacing is maintained between children in vertical direction
- Alignment properties work correctly for vertical layout
- Elements maintain their own coordinate system in vertical flex mode

validation:
- Run existing tests in testing/__tests__/gui-layout-testing.lua if it exists, or create new test file for this functionality
- Execute: lua testing/__tests__/gui-layout-testing.lua

notes:
- Vertical flex direction should be tested after horizontal to ensure comprehensive coverage
- Children should be positioned from top to bottom (y-axis)
- The layoutChildren() method should handle vertical positioning logic
- Elements should maintain proper spacing according to gap property