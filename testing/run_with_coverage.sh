#!/bin/bash
# Run tests with code coverage

# Set up LuaRocks path
eval $(luarocks path)

# Clean up old coverage files
rm -f luacov.stats.out luacov.report.out

# Run tests with coverage enabled
COVERAGE=1 lua testing/runAll.lua

# Check if tests passed
if [ $? -eq 0 ]; then
  echo ""
  echo "========================================"
  echo "Generating coverage report..."
  echo "========================================"
  
  # Generate detailed report
  luacov
  
  # Show summary
  echo ""
  echo "========================================"
  echo "Coverage Summary"
  echo "========================================"
  
  # Extract and display summary information
  if [ -f luacov.report.out ]; then
    echo ""
    grep -A 100 "^Summary" luacov.report.out | head -30
    echo ""
    echo "Full report available in: luacov.report.out"
  fi
else
  echo "Tests failed. Coverage report not generated."
  exit 1
fi
