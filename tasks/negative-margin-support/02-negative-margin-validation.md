# Negative Margin Validation and Edge Cases

## Objective
Implement validation and edge case handling for negative margins.

## Key Requirements
- Validate that negative margin values are properly handled
- Handle edge cases like negative margins that exceed element dimensions
- Ensure negative margins don't cause layout issues or conflicts
- Test various combinations of negative margins with existing layout properties

## Implementation Plan
1. Add validation logic for negative margin values
2. Implement edge case handling for extreme negative margins
3. Create tests for various negative margin combinations
4. Verify that negative margins don't break existing layout functionality

## Files to Modify
- FlexLove.lua (layout system core)
- Testing files (new test cases)

## Acceptance Criteria
- Negative margins are properly validated
- Edge cases with negative margins are handled correctly
- Layout functionality is not broken by negative margin support
- All combinations of negative margins pass tests