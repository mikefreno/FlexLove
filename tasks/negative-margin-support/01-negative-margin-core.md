# Negative Margin Core Implementation

## Objective
Implement core functionality for negative margins in the layout system.

## Key Requirements
- Support negative margin values in all margin properties (top, right, bottom, left)
- Negative margins should be properly calculated and applied during layout
- The system should handle negative margins without breaking existing functionality
- Negative margins should work with both explicit values and theme-based values

## Implementation Plan
1. Modify the margin calculation logic to support negative values
2. Update layout processing to apply negative margins correctly
3. Ensure negative margins don't interfere with existing positioning logic
4. Create tests for basic negative margin scenarios

## Files to Modify
- FlexLove.lua (layout system core)
- Theme system files (space.lua, themes/README.md)

## Acceptance Criteria
- Negative margins are properly calculated and applied
- Existing functionality is not broken by negative margin support
- Margins work with both explicit and theme-based values