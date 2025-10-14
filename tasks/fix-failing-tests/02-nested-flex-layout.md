# 02. Fix Nested Flex Layout

meta:
  id: fix-failing-tests-02
  feature: fix-failing-tests
  priority: P1
  depends_on: [fix-failing-tests-01]
  tags: [bugfix, layout, flex, tests-required]

objective:
- Fix width calculation issues in nested flex containers

deliverables:
- Correct nested flex container width calculations
- Fix testNestedHorizontalFlexContainers test (expected 120, got 300)
- Ensure nested flex layouts respect parent constraints

steps:
1. Analyze testNestedHorizontalFlexContainers test case in `03_flex_direction_horizontal_tests.lua` (line 584)
2. Identify why nested container width is 300 instead of 120 (150% error)
3. Review flex layout algorithm in FlexLove.lua for nested container handling
4. Fix width calculation for children in nested flex containers
5. Verify flex direction (horizontal/vertical) is properly inherited/respected
6. Test with multiple levels of nesting

tests:
- Unit: Test nested flex container width calculation
- Unit: Test flex child width respects parent content width
- Integration: testNestedHorizontalFlexContainers must pass
- Integration: Run all flex direction tests (03, 04) and verify no regressions

acceptance_criteria:
- testNestedHorizontalFlexContainers passes (child width = 120)
- No regressions in other flex direction tests
- Nested flex containers properly constrain child dimensions
- Works for both horizontal and vertical flex directions

validation:
- Run: `cd /Users/mike/Code/station_alpha/game/libs && lua testing/__tests__/03_flex_direction_horizontal_tests.lua`
- Verify testNestedHorizontalFlexContainers passes
- Run: `cd /Users/mike/Code/station_alpha/game/libs && lua testing/__tests__/04_flex_direction_vertical_tests.lua`
- Verify no regressions in vertical tests

notes:
- This is a systematic issue affecting nested layouts
- May be related to border-box vs content-box calculations
- Check if padding/margin is being double-counted in nested scenarios
- Review Element:layoutChildren() method for flex containers
