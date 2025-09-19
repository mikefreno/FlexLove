# 07. Flex Wrap Tests

meta:
  id: gui-layout-testing-07
  feature: gui-layout-testing
  priority: P2
  depends_on: []
  tags: [implementation, tests-required]

objective:
- Test that flex wrap functionality works correctly in flex layout

deliverables:
- Unit tests for flex wrap functionality
- Tests for different wrap values (nowrap, wrap, wrap-reverse)
- Tests for proper line wrapping behavior

steps:
- Create test suite for flex wrap tests
- Test element creation with various flex wrap values
- Verify that children wrap to new lines when needed
- Test wrap-reverse behavior
- Verify proper positioning in wrapped layouts

tests:
- Unit: Test Element.new() with positioning=Positioning.FLEX and various flexWrap values, verify proper initialization
- Unit: Test layoutChildren() method with different flexWrap values, verify correct wrapping behavior
- Integration/e2e: Verify that elements wrap children correctly based on flexWrap properties

acceptance_criteria:
- Elements with different flexWrap values can be created successfully
- Children wrap to new lines when container width/height is exceeded
- Wrap-reverse behavior works correctly
- Proper positioning is maintained in wrapped layouts
- Elements maintain their own coordinate system with flexWrap settings

validation:
- Run existing tests in testing/__tests__/gui-layout-testing.lua if it exists, or create new test file for this functionality
- Execute: lua testing/__tests__/gui-layout-testing.lua

notes:
- Flex wrap controls whether children can wrap to multiple lines
- Should test all valid flexWrap values (nowrap, wrap, wrap-reverse)
- The layoutChildren() method should implement proper wrapping logic
- Should verify behavior with both horizontal and vertical flex directions