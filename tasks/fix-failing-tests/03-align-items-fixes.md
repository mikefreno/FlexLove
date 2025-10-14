# 03. Fix Align Items Issues

meta:
  id: fix-failing-tests-03
  feature: fix-failing-tests
  priority: P1
  depends_on: [fix-failing-tests-02]
  tags: [bugfix, layout, align-items, tests-required]

objective:
- Fix align-items layout calculation issues in complex flex layouts

deliverables:
- Fix 6 failing align-items tests in `06_align_items_tests.lua`
- Correct vertical positioning calculations for different align-items values
- Ensure align-items works correctly in nested and complex layouts

steps:
1. Analyze the 6 failing test cases:
   - testComplexCardLayoutMixedAlignItems (expected 207, got 187)
   - testComplexDashboardWidgetLayout (expected 60, got 75)
   - testComplexFormMultiLevelAlignments (expected 60, got 50)
   - testComplexMediaObjectNestedAlignments (expected 41, got 101.5) - MAJOR ISSUE
   - testComplexModalDialogNestedAlignments (expected 214, got 209)
   - testComplexToolbarVariedAlignments (expected 5, got 10)
2. Identify common patterns in failures (most are vertical positioning errors)
3. Review align-items implementation for FLEX_START, CENTER, FLEX_END, STRETCH
4. Fix calculation errors in cross-axis positioning
5. Test with nested flex containers and mixed align-items values

tests:
- Unit: Test align-items CENTER calculation
- Unit: Test align-items FLEX_START calculation
- Unit: Test align-items FLEX_END calculation
- Unit: Test align-items STRETCH behavior
- Integration: All 6 failing tests must pass
- Integration: Run full `06_align_items_tests.lua` suite with no regressions

acceptance_criteria:
- testComplexCardLayoutMixedAlignItems passes (y = 207)
- testComplexDashboardWidgetLayout passes (y = 60)
- testComplexFormMultiLevelAlignments passes (y = 60)
- testComplexMediaObjectNestedAlignments passes (y = 41) - critical fix
- testComplexModalDialogNestedAlignments passes (y = 214)
- testComplexToolbarVariedAlignments passes (y = 5)
- No regressions in other align-items tests

validation:
- Run: `cd /Users/mike/Code/station_alpha/game/libs && lua testing/__tests__/06_align_items_tests.lua`
- Verify all 6 tests pass
- Check that total test count in file shows 100% pass rate

notes:
- testComplexMediaObjectNestedAlignments has 147% error - investigate first
- Most errors are vertical positioning (y-coordinate) issues
- May be related to padding/margin calculations in cross-axis
- Check Element:layoutChildren() flex cross-axis positioning logic
- alignSelf should override alignItems for individual children
