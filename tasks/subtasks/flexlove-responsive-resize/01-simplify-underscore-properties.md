# 01. Remove Underscore Prefixed Properties and Simplify Logic

meta:
  id: flexlove-responsive-resize-01
  feature: flexlove-responsive-resize
  priority: P2
  depends_on: []
  tags: [refactoring, simplification, code-cleanup]

objective:
- Remove all underscore (_) prefixed properties from Element class while maintaining exact same logical behavior
- Simplify over-complicated logic patterns without changing functionality
- Reduce internal state complexity and improve code maintainability

deliverables:
- Modified FlexLove.lua with all underscore properties removed
- Simplified positioning and layout logic
- Updated Element class documentation
- Maintained backward compatibility for public API

steps:
- Analyze all underscore prefixed properties: _originalPositioning, _explicitlyAbsolute, _pressed, _touchPressed
- Refactor _originalPositioning and _explicitlyAbsolute into cleaner boolean logic
- Simplify touch and mouse interaction state management
- Remove redundant property tracking and complex conditional chains
- Consolidate positioning logic into cleaner, more readable methods
- Update @class Element documentation to reflect simplified structure

tests:
- Unit: Test Element.new() constructor with all positioning combinations (Arrange–Act–Assert)
- Unit: Test addChild() method maintains correct positioning behavior without underscore properties
- Unit: Test touch/mouse interaction without _pressed/_touchPressed tracking
- Integration: Run all existing test suites to ensure no behavioral regressions
- Integration: Test complex nested element structures maintain same positioning behavior

acceptance_criteria:
- Zero underscore prefixed properties remain in Element class
- All existing tests pass without modification
- No public API changes or breaking changes
- Positioning logic produces identical results to original implementation
- Touch and mouse interactions work exactly as before
- Code is more readable and maintainable

validation:
- Run: `grep -n "_.*=" FlexLove.lua` should return zero matches for underscore properties
- Run: `lua testing/runAll.lua` should pass all tests
- Verify: Element creation and positioning behavior identical in before/after comparison
- Manual test: Touch and click interactions function normally

notes:
- Focus on internal refactoring only - no external behavior changes
- The _explicitlyAbsolute logic can be simplified using positioning enum values directly
- Mouse/touch state can be managed with simpler direct property approach
- Consider consolidating positioning determination into single method