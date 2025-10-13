# Negative Margin Theme Integration

## Objective
Implement support for negative margins within the theme system.

## Key Requirements
- Theme definitions should support negative margin values
- Theme-based negative margins should be properly applied to elements
- The integration should work seamlessly with existing theme functionality
- Negative margins in themes should override default values and explicit settings

## Implementation Plan
1. Modify theme system to accept negative margin values
2. Update theme application logic to handle negative margins
3. Ensure theme-based negative margins are prioritized correctly
4. Create tests for theme-based negative margin scenarios

## Files to Modify
- Theme system files (space.lua, themes/README.md)
- FlexLove.lua (layout system core)

## Acceptance Criteria
- Negative margins work in theme definitions
- Theme-based negative margins are properly applied
- Theme priority handling works correctly with negative margins
- All theme-based scenarios pass tests