# 01. Fix Critical Errors

meta:
  id: fix-failing-tests-01
  feature: fix-failing-tests
  priority: P0
  depends_on: []
  tags: [bugfix, critical, tests-required]

objective:
- Fix critical errors that are causing test failures and preventing proper test execution

deliverables:
- Fix nil reference errors in test files
- Implement negative margin support
- Implement circular reference validation
- Fix any other critical errors preventing test execution

steps:
1. Analyze the 39 errors in the test output to identify root causes
2. Fix nil reference error in `01_absolute_positioning_basic_tests.lua` (testMultiBranchZIndexStacking)
3. Implement negative margin support in FlexLove.lua (Units.resolve should handle negative values)
4. Implement circular reference validation in Element creation/parenting
5. Fix any other blocking errors identified in step 1
6. Run tests to verify errors are reduced

tests:
- Unit: Test negative margin parsing and resolution in Units system
- Unit: Test circular reference detection when adding children
- Integration: Run `01_absolute_positioning_basic_tests.lua` and verify no errors
- Integration: Run `09_layout_validation_tests.lua` and verify circular reference test passes
- Integration: Run full test suite and verify error count is reduced from 39 to < 10

acceptance_criteria:
- testMultiBranchZIndexStacking passes without nil reference error
- testNegativeDimensionsAndPositions passes with negative margin support
- testCircularReferenceValidation passes with proper detection
- Total error count reduced from 39 to less than 10
- No new test failures introduced

validation:
- Run: `cd /Users/mike/Code/station_alpha/game/libs && lua testing/runAll.lua`
- Verify error count is < 10
- Verify the three specific tests mentioned pass

notes:
- Priority P0 because errors block other tests from running properly
- Negative margins are already implemented according to tasks/negative-margin-support/
- May need to check if implementation is complete or has bugs
- Circular reference validation should detect parent-child cycles
