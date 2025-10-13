# 05. Negative Margin Tests

meta:
  id: negative-margin-support-05
  feature: negative-margin-support
  priority: P2
  depends_on: [negative-margin-support-04]
  tags: [implementation, tests-required]

objective:
- Create comprehensive test suite for negative margin functionality to ensure proper behavior and validation

deliverables:
- Unit tests for negative margin application logic
- Integration tests for negative margin in layout scenarios
- Test coverage for edge cases and invalid inputs

steps:
- Create test files for negative margin functionality
- Implement unit tests covering core negative margin logic
- Add integration tests with layout scenarios
- Verify validation behavior with invalid inputs
- Run all tests to ensure full coverage

tests:
- Unit: Test negative margin application functions, validation functions
- Integration/e2e: Test negative margins in various layout scenarios including nested elements and theme integration

acceptance_criteria:
- All unit tests pass without failures
- Integration tests validate proper negative margin behavior in layouts
- Edge case tests handle invalid inputs gracefully
- Test coverage reaches 90%+ for the negative margin feature

validation:
- Run existing test suite with new test files included
- Verify all negative margin related tests execute successfully
- Check that no regressions were introduced

notes:
- Build upon existing testing patterns established in the project
- Ensure test files follow the same structure as other test implementations