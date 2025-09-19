# 03. Horizontal Flex Direction Tests

meta:
  id: gui-layout-testing-03
  feature: gui-layout-testing
  priority: P2
  depends_on: []
  tags: [implementation, tests-required]

objective:
- Test that flex layout works correctly with horizontal direction (default)

deliverables:
- Unit tests for horizontal flex direction functionality
- Tests for child positioning in horizontal flex layout
- Tests for proper spacing and alignment in horizontal layout

steps:
- Create test suite for horizontal flex direction tests
- Test element creation with flex direction = FlexDirection.HORIZONTAL
- Verify that children are positioned horizontally
- Test proper spacing between children
- Verify that alignment works correctly in horizontal direction

tests:
- Unit: Test Element.new() with positioning=Positioning.FLEX and flexDirection=FlexDirection.HORIZONTAL, verify that the element is set up for horizontal layout
- Unit: Test layoutChildren() method with horizontal flex direction, verify that children are positioned horizontally along x-axis
- Integration/e2e: Verify that horizontal flex elements position children correctly along x-axis

acceptance_criteria:
- Elements with flexDirection=FlexDirection.HORIZONTAL can be created successfully
- Children are positioned horizontally (along x-axis) relative to parent
- Proper spacing is maintained between children in horizontal direction
- Alignment properties work correctly for horizontal layout
- Elements maintain their own coordinate system in horizontal flex mode

validation:
- Run existing tests in testing/__tests__/gui-layout-testing.lua if it exists, or create new test file for this functionality
- Execute: lua testing/__tests__/gui-layout-testing.lua

notes:
- Horizontal flex direction is the default and should be tested first
- Children should be positioned from left to right (x-axis)
- The layoutChildren() method should handle horizontal positioning logic
- Elements should maintain proper spacing according to gap property