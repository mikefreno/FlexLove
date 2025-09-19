# 04. Fix Flex-Wrap Complex Layout Issues

meta:
  id: flexlove-test-fixes-04
  feature: flexlove-test-fixes
  priority: P1
  depends_on: [flexlove-test-fixes-02, flexlove-test-fixes-03]
  tags: [implementation, tests-required, css-compliance]

objective:
- Fix flex-wrap functionality issues in complex layouts including nil value errors and layout assertion failures

deliverables:
- Updated FlexLove.lua flex-wrap calculation logic
- Fixed test failures in 07_flex_wrap_tests.lua (3 failures + 1 error)
- Proper wrapping behavior for overflow scenarios

steps:
- Fix nil value error in TestFlexWrap20_ComplexProductCatalog (attempt to index nil field 'integer index')
- Investigate assertion failures in complex card grid, image gallery, and dashboard layouts
- Read current flex-wrap implementation in FlexLove.lua
- Implement proper CSS Flexbox flex-wrap algorithm
- Ensure wrapped lines properly calculate positions and dimensions
- Fix container sizing when items wrap to new lines

tests:
- Unit: Test flex-wrap calculation functions (calculateWrapPositions, handleLineWrapping)
- Integration: Run 07_flex_wrap_tests.lua and verify all 20 tests pass
- Edge-case: Test complex scenarios with varied item sizes and container constraints

acceptance_criteria:
- All 4 previously failing tests in 07_flex_wrap_tests.lua now pass
- No nil value errors when accessing wrapped item properties
- Complex layouts (card grids, image galleries, dashboards) wrap correctly
- Wrapped line positioning and spacing matches CSS Flexbox behavior

validation:
- Run: `lua testing/__tests__/07_flex_wrap_tests.lua`
- Verify: 20/20 tests pass with no failures or errors
- Check: All assertion statements evaluate to true

notes:
- Focus on CSS Flexbox flex-wrap property and line wrapping behavior
- Pay attention to array indexing and nil value safety
- Consider how wrapping interacts with justify-content and align-items
- Reference: https://www.w3.org/TR/css-flexbox-1/#flex-wrap-property