# 04. Fix Justify Content Issues

meta:
  id: fix-failing-tests-04
  feature: fix-failing-tests
  priority: P1
  depends_on: [fix-failing-tests-02]
  tags: [bugfix, layout, justify-content, tests-required]

objective:
- Fix justify-content gap and spacing calculation issues

deliverables:
- Fix 3 failing justify-content tests in `05_justify_content_tests.lua`
- Correct main-axis spacing calculations for SPACE_BETWEEN, SPACE_AROUND, SPACE_EVENLY
- Ensure justify-content works correctly with gaps and padding

steps:
1. Analyze the 3 failing test cases:
   - testComplexFormJustifyContentLayout (expected 60, got 65)
   - testGridLayoutJustifyContentVariations (expected 30, got 33.33)
   - testMultiLevelNestedModalJustifyContent (expected 320, got 324)
2. Identify pattern: all failures are small overages (4-5 units)
3. Review justify-content implementation for spacing calculations
4. Check if gap is being added incorrectly in spacing calculations
5. Verify padding is not being double-counted
6. Test with different justify-content values (FLEX_START, CENTER, SPACE_BETWEEN, etc.)

tests:
- Unit: Test justify-content SPACE_BETWEEN with gap
- Unit: Test justify-content SPACE_AROUND with gap
- Unit: Test justify-content SPACE_EVENLY with gap
- Unit: Test justify-content CENTER with padding
- Integration: All 3 failing tests must pass
- Integration: Run full `05_justify_content_tests.lua` suite with no regressions

acceptance_criteria:
- testComplexFormJustifyContentLayout passes (x = 60)
- testGridLayoutJustifyContentVariations passes (x = 30)
- testMultiLevelNestedModalJustifyContent passes (x = 320)
- No regressions in other justify-content tests
- Gap calculations are correct for all justify-content modes

validation:
- Run: `cd /Users/mike/Code/station_alpha/game/libs && lua testing/__tests__/05_justify_content_tests.lua`
- Verify all 3 tests pass
- Check that spacing calculations are mathematically correct

notes:
- All errors are small (4-5 units) suggesting systematic gap/spacing issue
- May be adding gap where it shouldn't (e.g., after last child)
- Check Element:layoutChildren() justify-content spacing logic
- Grid layout test failure suggests issue may also affect grid positioning
- Review how gap interacts with different justify-content modes
