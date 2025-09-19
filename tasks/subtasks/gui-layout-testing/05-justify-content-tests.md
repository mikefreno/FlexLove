# 05. Justify Content Alignment Tests

meta:
  id: gui-layout-testing-05
  feature: gui-layout-testing
  priority: P2
  depends_on: []
  tags: [implementation, tests-required]

objective:
- Test that justify content alignment works correctly in flex layout

deliverables:
- Unit tests for justify content functionality
- Tests for different justify content values (flex-start, flex-end, center, space-between, space-around)
- Tests for proper positioning based on justify content settings

steps:
- Create test suite for justify content tests
- Test element creation with various justify content values
- Verify that children are positioned according to justify content rules
- Test alignment in both horizontal and vertical directions
- Verify spacing behavior with different justify content options

tests:
- Unit: Test Element.new() with positioning=Positioning.FLEX and various justifyContent values, verify proper initialization
- Unit: Test layoutChildren() method with different justifyContent values, verify correct positioning behavior
- Integration/e2e: Verify that elements align children correctly based on justifyContent properties

acceptance_criteria:
- Elements with different justifyContent values can be created successfully
- Children are positioned according to justify content rules (flex-start, flex-end, center, space-between, space-around)
- Proper spacing is maintained between children for different justify content options
- Alignment works correctly in both horizontal and vertical directions
- Elements maintain their own coordinate system with justify content settings

validation:
- Run existing tests in testing/__tests__/gui-layout-testing.lua if it exists, or create new test file for this functionality
- Execute: lua testing/__tests__/gui-layout-testing.lua

notes:
- Justify content controls how children are distributed along the main axis
- Should test all valid justifyContent values (flex-start, flex-end, center, space-between, space-around)
- The layoutChildren() method should implement proper justification logic
- Should verify behavior for both horizontal and vertical flex directions