# 01. Fix Vertical Flex Layout Calculation Issues

meta:
  id: flexlove-test-fixes-01
  feature: flexlove-test-fixes
  priority: P1
  depends_on: []
  tags: [implementation, tests-required, css-compliance]

objective:
- Fix vertical flex layout calculations that are returning 0 instead of computed values in complex nested scenarios

deliverables:
- Updated FlexLove.lua vertical flex layout calculation logic
- Fixed test failures in 04_flex_direction_vertical_tests.lua (4 failing tests)
- Proper height calculation for nested vertical flex containers

steps:
- Examine failing test cases: testCalendarTimelineLayout, testMobileVerticalStackLayout, testMultiLevelAccordionLayout, testNestedFormLayout
- Read FlexLove.lua implementation to understand current vertical flex calculation logic
- Identify why calculations return 0 instead of expected positive values (38, 144, 42, 71)
- Implement proper CSS Flexbox vertical layout algorithm
- Ensure nested flex containers properly calculate child heights
- Verify flex-direction: column behavior matches CSS specifications

tests:
- Unit: Test individual vertical flex calculation functions (calculateFlexHeight, processVerticalChildren)
- Integration: Run 04_flex_direction_vertical_tests.lua and verify all 22 tests pass
- Regression: Ensure tests 01-03 still pass after changes

acceptance_criteria:
- All 4 previously failing tests in 04_flex_direction_vertical_tests.lua now pass
- Vertical flex layouts properly calculate and assign heights to child elements
- Complex nested scenarios (calendar, mobile stack, accordion, forms) render correctly
- No regression in absolute positioning tests (01-03)

validation:
- Run: `lua testing/__tests__/04_flex_direction_vertical_tests.lua`
- Verify: 22/22 tests pass with no failures
- Check: Expected values (38, 144, 42, 71) are correctly calculated

notes:
- Focus on CSS Flexbox specification for flex-direction: column
- Pay attention to how nested containers affect height calculations
- Consider main axis vs cross axis behavior in vertical layout
- Reference: https://www.w3.org/TR/css-flexbox-1/#flex-direction-property