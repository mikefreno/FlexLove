# 03. Fix Align-Items Y-Axis Positioning Calculations

meta:
  id: flexlove-test-fixes-03
  feature: flexlove-test-fixes
  priority: P1
  depends_on: [flexlove-test-fixes-01]
  tags: [implementation, tests-required, css-compliance]

objective:
- Fix align-items Y-axis positioning calculations that are incorrectly positioning elements in complex nested layouts

deliverables:
- Updated FlexLove.lua align-items calculation logic
- Fixed test failures in 06_align_items_tests.lua (6 failing tests)
- Proper cross-axis alignment for flex-start, flex-end, center, stretch, baseline

steps:
- Examine failing test cases showing incorrect Y positioning
- Read current align-items implementation in FlexLove.lua
- Identify why Y positions are calculated incorrectly (gaps of 10-80+ pixels)
- Implement proper CSS Flexbox align-items algorithm
- Fix cross-axis positioning for various alignment values
- Ensure nested layouts properly handle align-items inheritance

tests:
- Unit: Test align-items calculation functions (calculateAlignItemsOffset, alignCrossAxis)
- Integration: Run 06_align_items_tests.lua and verify all 21 tests pass
- Cross-test: Verify align-items works with vertical layouts and justify-content

acceptance_criteria:
- All 6 previously failing tests in 06_align_items_tests.lua now pass
- Y-axis positioning is accurate for all align-items values
- Complex nested layouts (cards, dashboards, forms, modals) align correctly
- Cross-axis behavior matches CSS Flexbox specifications

validation:
- Run: `lua testing/__tests__/06_align_items_tests.lua`
- Verify: 21/21 tests pass with no failures
- Check: Y positions match expected values (23, 115, 150, 90, 148, 5) exactly

notes:
- Focus on CSS Flexbox align-items cross-axis alignment
- Consider container height vs item height for alignment calculations
- Pay attention to baseline alignment in mixed content scenarios
- Reference: https://www.w3.org/TR/css-flexbox-1/#align-items-property