# 05. Fix Comprehensive Flex Width Calculation Discrepancies

meta:
  id: flexlove-test-fixes-05
  feature: flexlove-test-fixes
  priority: P1
  depends_on: [flexlove-test-fixes-01, flexlove-test-fixes-02, flexlove-test-fixes-03, flexlove-test-fixes-04]
  tags: [implementation, tests-required, css-compliance]

objective:
- Fix width calculation discrepancies in comprehensive flex layouts where calculated widths are 50-60 units larger than expected

deliverables:
- Updated FlexLove.lua flex item width calculation logic
- Fixed test failures in 08_comprehensive_flex_tests.lua (2 failing tests)
- Accurate flex-grow, flex-shrink, and flex-basis calculations

steps:
- Examine failing tests: testComplexApplicationLayout (expected 400, got 450) and testComplexDashboardLayout (expected 400, got 460)
- Read current flex item sizing implementation in FlexLove.lua
- Identify source of consistent 50-60 unit width increases
- Implement proper CSS Flexbox flex item sizing algorithm
- Fix flex-grow distribution calculations
- Ensure flex-basis and min/max width constraints are respected

tests:
- Unit: Test flex sizing functions (calculateFlexGrow, calculateFlexShrink, applyFlexBasis)
- Integration: Run 08_comprehensive_flex_tests.lua and verify all 7 tests pass
- Regression: Verify all previous flex tests (01-07) still pass

acceptance_criteria:
- All 2 previously failing tests in 08_comprehensive_flex_tests.lua now pass
- Width calculations are accurate within 1 pixel tolerance
- Complex application and dashboard layouts size correctly
- Flex item sizing matches CSS Flexbox specifications

validation:
- Run: `lua testing/__tests__/08_comprehensive_flex_tests.lua`
- Verify: 7/7 tests pass with no failures
- Check: Widths match expected 400 exactly (not 450.0 or 460.0)

notes:
- Focus on CSS Flexbox flex property and item sizing algorithms
- Consider how padding, margins, and borders affect flex calculations
- Pay attention to available space distribution among flex items
- Reference: https://www.w3.org/TR/css-flexbox-1/#flex-property