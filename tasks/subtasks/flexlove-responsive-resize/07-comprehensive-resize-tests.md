# 07. Comprehensive Resize and Scaling Test Suite

meta:
  id: flexlove-responsive-resize-07
  feature: flexlove-responsive-resize
  priority: P2
  depends_on: [flexlove-responsive-resize-05]
  tags: [testing, validation, comprehensive-tests]

objective:
- Create comprehensive test suite validating all resize and scaling functionality
- Ensure all edge cases and combinations of features work correctly
- Provide regression testing for future changes to resize system

deliverables:
- New test file: 12_comprehensive_resize_tests.lua
- Test cases covering all resize scenarios and edge cases
- Performance benchmarks for resize operations
- Integration tests for complex real-world layouts

steps:
- Create comprehensive test file covering all resize functionality
- Add tests for viewport unit parsing and calculation accuracy
- Add tests for proportional scaling of dimensions (width, height)
- Add tests for relative positioning maintenance during resize
- Add tests for text size, padding, margin, and gap scaling
- Add tests for mixed unit types and complex nested layouts
- Add performance tests measuring resize operation timing
- Add edge case tests (negative values, zero dimensions, extreme ratios)
- Add regression tests for previous bugs and issues

tests:
- Unit: Test all viewport unit types (%, vw, vh, vmin, vmax) parse and calculate correctly
- Unit: Test proportional scaling with various window size ratios (1.5x, 2x, 0.5x, etc.)
- Unit: Test position scaling maintains relative positioning accurately
- Unit: Test text and spacing scaling maintains proportional relationships
- Integration: Test complex nested layouts with mixed positioning types
- Integration: Test real-world UI patterns (header/sidebar/content layouts)
- Performance: Test resize performance with large element counts
- Edge case: Test extreme resize ratios and boundary conditions

acceptance_criteria:
- All new resize functionality is thoroughly tested with passing tests
- Edge cases and error conditions are handled gracefully
- Performance tests validate resize operations meet timing requirements
- Complex layout scenarios are validated with integration tests
- All existing tests continue to pass with new resize functionality
- Test coverage includes all unit types, scaling scenarios, and positioning combinations
- Regression tests prevent future issues with resize functionality

validation:
- Run: `lua testing/__tests__/12_comprehensive_resize_tests.lua` passes all tests
- Run: `lua testing/runAll.lua` passes all tests including new resize tests
- Test: All documented resize scenarios work as specified
- Benchmark: Resize performance meets established timing requirements
- Verify: Complex layouts resize correctly without visual artifacts

notes:
- Include tests for simple_resize_test.lua scenarios that were previously failing
- Test both LOVE2D resize events and direct Gui.resize() calls
- Include stress tests with hundreds of elements to validate performance
- Test memory usage during repeated resize operations to check for leaks