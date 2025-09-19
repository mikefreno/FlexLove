# 06. Fix Performance Test Deep Nesting Threshold

meta:
  id: flexlove-test-fixes-06
  feature: flexlove-test-fixes
  priority: P2
  depends_on: []
  tags: [performance, tests-required]

objective:
- Fix performance test threshold issue where deep nesting test fails to meet "substantial elements" criteria

deliverables:
- Updated performance test threshold or improved deep nesting element creation
- Fixed test failure in 10_performance_tests.lua (1 failing test)
- Proper performance benchmarking for deep nested structures

steps:
- Examine testExtremeScalePerformanceBenchmark deep nesting test logic
- Determine if issue is with element creation (only 30 elements) or threshold definition
- Read current deep nesting implementation in FlexLove.lua
- Either fix element creation to generate more substantial structures or adjust test threshold
- Ensure performance test accurately reflects real-world deep nesting scenarios

tests:
- Performance: Measure deep nesting element creation and layout performance
- Integration: Run 10_performance_tests.lua and verify all 13 tests pass
- Benchmark: Ensure performance metrics are realistic and meaningful

acceptance_criteria:
- Previously failing test testExtremeScalePerformanceBenchmark now passes
- Deep nesting creates appropriate number of elements for performance testing
- Performance thresholds are realistic and achievable
- Test accurately measures performance characteristics

validation:
- Run: `lua testing/__tests__/10_performance_tests.lua`
- Verify: 13/13 tests pass with no failures
- Check: Deep nesting assertion evaluates to true

notes:
- Consider what constitutes "substantial" for performance testing
- Balance between meaningful test and achievable performance
- May need to adjust either element creation logic or test threshold
- Focus on realistic performance scenarios rather than arbitrary numbers