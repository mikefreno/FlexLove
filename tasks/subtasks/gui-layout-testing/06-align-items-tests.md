# 06. Align Items Tests

meta:
  id: gui-layout-testing-06
  feature: gui-layout-testing
  priority: P2
  depends_on: []
  tags: [implementation, tests-required]

objective:
- Test that align items functionality works correctly in flex layout

deliverables:
- Unit tests for align items functionality
- Tests for different align items values (flex-start, flex-end, center, stretch)
- Tests for proper positioning based on align items settings

steps:
- Create test suite for align items tests
- Test element creation with various align items values
- Verify that children are positioned according to align items rules
- Test alignment in both horizontal and vertical directions
- Verify stretching behavior when align-items=stretch

tests:
- Unit: Test Element.new() with positioning=Positioning.FLEX and various alignItems values, verify proper initialization
- Unit: Test layoutChildren() method with different alignItems values, verify correct positioning behavior
- Integration/e2e: Verify that elements align children correctly based on alignItems properties

acceptance_criteria:
- Elements with different alignItems values can be created successfully
- Children are positioned according to align items rules (flex-start, flex-end, center, stretch)
- Proper alignment is maintained between children for different align items options
- Stretching behavior works correctly when alignItems=stretch
- Elements maintain their own coordinate system with align items settings

validation:
- Run existing tests in testing/__tests__/gui-layout-testing.lua if it exists, or create new test file for this functionality
- Execute: lua testing/__tests__/gui-layout-testing.lua

notes:
- Align items controls how children are aligned along the cross axis
- Should test all valid alignItems values (flex-start, flex-end, center, stretch)
- The layoutChildren() method should implement proper alignment logic
- Should verify behavior for both horizontal and vertical flex directions