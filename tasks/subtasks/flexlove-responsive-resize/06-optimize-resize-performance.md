# 06. Optimize Resize Performance

meta:
  id: flexlove-responsive-resize-06
  feature: flexlove-responsive-resize
  priority: P2
  depends_on: [flexlove-responsive-resize-01]
  tags: [optimization, performance, resize-performance]

objective:
- Optimize resize calculations and layout performance to prevent lag during window resize
- Reduce redundant calculations and improve resize response time
- Implement efficient batching and caching strategies for resize operations

deliverables:
- Optimized Element:resize() method with performance improvements
- Cached calculation results to avoid redundant operations
- Batched layout updates during resize operations
- Performance measurement and validation framework

steps:
- Profile current resize performance to identify bottlenecks
- Implement resize calculation caching to avoid redundant operations
- Batch layout recalculations instead of per-element updates
- Optimize viewport unit resolution with cached viewport dimensions
- Add dirty flag system to only update changed elements during resize
- Implement resize debouncing to handle rapid resize events efficiently
- Optimize font cache operations during text size scaling
- Reduce layout thrashing by batching child element updates

tests:
- Unit: Test resize performance with different element counts (10, 50, 100, 500 elements)
- Unit: Test cache hit rates for repeated resize operations (Arrange–Act–Assert)
- Unit: Test batch update operations reduce layout recalculation calls
- Integration: Test resize performance with complex nested layouts
- Integration: Test performance with mixed element types (absolute, flex, viewport units)
- Performance: Measure resize time before and after optimizations

acceptance_criteria:
- Resize operations complete within acceptable time limits (< 16ms for 60fps)
- Performance scales linearly with element count (not exponential)
- Cached calculations reduce redundant viewport unit resolutions
- Batched updates reduce layout thrashing during resize events
- Font cache operations are optimized for scaled font size requests
- Memory usage remains stable during repeated resize operations
- Resize performance is consistent across different layout complexities

validation:
- Benchmark: Time resize operations with 100+ elements (should be < 16ms)
- Test: Resize event handling at 60fps without dropped frames
- Profile: Memory usage remains stable during rapid resize events
- Verify: Complex layouts resize smoothly without visible lag
- Run: Performance test suite shows improvement over baseline measurements

notes:
- Current implementation calls layoutChildren() for every element individually
- Font cache could be optimized to pre-calculate common scaled sizes
- Viewport dimension caching should update only when window actually changes
- Consider using RequestAnimationFrame-like pattern for batching resize updates