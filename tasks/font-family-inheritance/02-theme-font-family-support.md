# Theme Font Family Support

## Objective
Implement support for font family inheritance when parent elements have fontFamily set via the theme system.

## Key Requirements
- Theme system should properly pass font families to child elements
- Inheritance should work regardless of whether child has themeComponent set
- Theme-based font families should be prioritized over default values
- The system should handle theme updates and re-inheritance when themes change

## Implementation Plan
1. Modify theme processing logic to track font family inheritance
2. Ensure theme system can pass font family information to children during layout
3. Add logic to handle theme updates that affect font family inheritance
4. Create tests for theme-based font family inheritance scenarios

## Files to Modify
- Theme system files (space.lua, themes/README.md)
- FlexLove.lua (layout system core)

## Acceptance Criteria
- Font families from themes are properly inherited by children
- Theme updates correctly trigger re-inheritance of font families
- Inheritance works when parent has themeComponent set but child doesn't