# 02. Fix Justify-Content Space Distribution Calculations

meta:
  id: flexlove-test-fixes-02
  feature: flexlove-test-fixes
  priority: P1
  depends_on: [flexlove-test-fixes-01]
  tags: [implementation, tests-required, css-compliance]

objective:
- Fix justify-content space distribution calculations that are consistently off by 20 units and incorrect positioning

deliverables:
- Updated FlexLove.lua justify-content calculation logic
- Fixed test failures in 05_justify_content_tests.lua (5 failing tests)
- Proper space distribution for flex-start, flex-end, center, space-between, space-around

steps:
- Examine failing test cases with systematic 20-unit errors and positioning issues
- Read current justify-content implementation in FlexLove.lua
- Identify root cause of consistent 20-unit calculation errors
- Implement proper CSS Flexbox justify-content algorithm
- Fix space-around and space-between distribution calculations
- Ensure positioning accounts for container padding/margins correctly

tests:
- Unit: Test justify-content calculation functions (calculateJustifyContentOffset, distributeSpace)
- Integration: Run 05_justify_content_tests.lua and verify all 20 tests pass
- Cross-test: Verify justify-content works with vertical layouts from task 01

acceptance_criteria:
- All 5 previously failing tests in 05_justify_content_tests.lua now pass
- Justify-content calculations are accurate within 1 pixel tolerance
- Complex layouts (forms, navigation, grids, modals) position correctly
- Space distribution algorithms match CSS Flexbox specifications

validation:
- Run: `lua testing/__tests__/05_justify_content_tests.lua`
- Verify: 20/20 tests pass with no failures
- Check: Values match expected (600, 315.0, 220, 800, 150.0) exactly

notes:
- Focus on CSS Flexbox justify-content property specification
- Pay attention to padding/margin handling in space calculations
- Consider container width vs available space for distribution
- Reference: https://www.w3.org/TR/css-flexbox-1/#justify-content-property