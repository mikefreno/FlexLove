# 01. Basic Absolute Positioning Tests

meta:
  id: gui-layout-testing-01
  feature: gui-layout-testing
  priority: P2
  depends_on: []
  tags: [implementation, tests-required]

objective:
- Test that elements can be created with absolute positioning and positioned correctly

deliverables:
- Unit tests for Element creation with absolute positioning
- Tests for x/y coordinate handling in absolute mode
- Tests for z-index layering functionality

steps:
- Create test suite for absolute positioning tests
- Test element creation with absolute positioning mode
- Verify x and y coordinates are properly set
- Test z-index functionality
- Verify that absolute positioned elements don't participate in flex layout calculations

tests:
- Unit: Test Element.new() with positioning=Positioning.ABSOLUTE, verify that x/y coordinates are correctly assigned and that the element is added to Gui.topElements
- Unit: Test that absolute positioned elements maintain their own coordinate system independent of parent
- Integration/e2e: Verify that absolute positioned children are not affected by parent's flex layout properties

acceptance_criteria:
- Elements with positioning=Positioning.ABSOLUTE can be created successfully
- Element x/y coordinates are correctly set according to props
- Element z-index is properly assigned and maintained
- Absolute elements maintain their own coordinate system
- Absolute elements do not participate in flex layout calculations

validation:
- Run existing tests in testing/__tests__/gui-layout-testing.lua if it exists, or create new test file for this functionality
- Execute: lua testing/__tests__/gui-layout-testing.lua

notes:
- Elements with positioning=Positioning.ABSOLUTE should be added to Gui.topElements when they have no parent
- Elements with positioning=Positioning.ABSOLUTE that have a parent should not participate in flex layout calculations of their parent
- Absolute positioned elements should maintain their own x/y coordinates regardless of parent changes