#!/bin/bash

# Parallel Test Runner for FlexLove
# Runs tests in parallel to speed up execution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create temp directory for test results
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "========================================"
echo "Running tests in parallel..."
echo "========================================"

# Get all test files
TEST_FILES=(
  "testing/__tests__/animation_test.lua"
  "testing/__tests__/animation_properties_test.lua"
  "testing/__tests__/blur_test.lua"
  "testing/__tests__/critical_failures_test.lua"
  "testing/__tests__/easing_test.lua"
  "testing/__tests__/element_test.lua"
  "testing/__tests__/event_handler_test.lua"
  "testing/__tests__/flexlove_test.lua"
  "testing/__tests__/font_cache_test.lua"
  "testing/__tests__/grid_test.lua"
  "testing/__tests__/image_cache_test.lua"
  "testing/__tests__/image_renderer_test.lua"
  "testing/__tests__/image_scaler_test.lua"
  "testing/__tests__/image_tiling_test.lua"
  "testing/__tests__/input_event_test.lua"
  "testing/__tests__/keyframe_animation_test.lua"
  "testing/__tests__/layout_edge_cases_test.lua"
  "testing/__tests__/layout_engine_test.lua"
  "testing/__tests__/ninepatch_parser_test.lua"
  "testing/__tests__/ninepatch_test.lua"
  "testing/__tests__/overflow_test.lua"
  "testing/__tests__/path_validation_test.lua"
  "testing/__tests__/performance_instrumentation_test.lua"
  "testing/__tests__/performance_warnings_test.lua"
  "testing/__tests__/renderer_test.lua"
  "testing/__tests__/roundedrect_test.lua"
  "testing/__tests__/sanitization_test.lua"
  "testing/__tests__/text_editor_test.lua"
  "testing/__tests__/theme_test.lua"
  "testing/__tests__/touch_events_test.lua"
  "testing/__tests__/transform_test.lua"
  "testing/__tests__/units_test.lua"
  "testing/__tests__/utils_test.lua"
)

# Number of parallel jobs (adjust based on CPU cores)
MAX_JOBS=${MAX_JOBS:-8}

# Function to run a single test file
run_test() {
  local test_file=$1
  local test_name=$(basename "$test_file" .lua)
  local output_file="$TEMP_DIR/${test_name}.out"
  local status_file="$TEMP_DIR/${test_name}.status"
  
  # Create a wrapper script that runs the test
  cat > "$TEMP_DIR/${test_name}_runner.lua" << 'EOF'
package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"
_G.RUNNING_ALL_TESTS = true
local luaunit = require("testing.luaunit")
EOF
  
  echo "dofile('$test_file')" >> "$TEMP_DIR/${test_name}_runner.lua"
  echo "os.exit(luaunit.LuaUnit.run())" >> "$TEMP_DIR/${test_name}_runner.lua"
  
  # Run the test and capture output
  if lua "$TEMP_DIR/${test_name}_runner.lua" > "$output_file" 2>&1; then
    echo "0" > "$status_file"
  else
    echo "1" > "$status_file"
  fi
}

export -f run_test
export TEMP_DIR

# Run tests in parallel
printf '%s\n' "${TEST_FILES[@]}" | xargs -P $MAX_JOBS -I {} bash -c 'run_test "{}"'

# Collect results
echo ""
echo "========================================"
echo "Test Results Summary"
echo "========================================"

total_tests=0
passed_tests=0
failed_tests=0
total_successes=0
total_failures=0
total_errors=0

for test_file in "${TEST_FILES[@]}"; do
  test_name=$(basename "$test_file" .lua)
  output_file="$TEMP_DIR/${test_name}.out"
  status_file="$TEMP_DIR/${test_name}.status"
  
  if [ -f "$status_file" ]; then
    status=$(cat "$status_file")
    
    # Extract test counts from output
    if grep -q "Ran.*tests" "$output_file"; then
      test_line=$(grep "Ran.*tests" "$output_file")
      
      # Parse: "Ran X tests in Y seconds, A successes, B failures, C errors"
      if [[ $test_line =~ Ran\ ([0-9]+)\ tests.*,\ ([0-9]+)\ successes.*,\ ([0-9]+)\ failures.*,\ ([0-9]+)\ errors ]]; then
        tests="${BASH_REMATCH[1]}"
        successes="${BASH_REMATCH[2]}"
        failures="${BASH_REMATCH[3]}"
        errors="${BASH_REMATCH[4]}"
        
        total_tests=$((total_tests + tests))
        total_successes=$((total_successes + successes))
        total_failures=$((total_failures + failures))
        total_errors=$((total_errors + errors))
        
        if [ "$status" = "0" ] && [ "$failures" = "0" ] && [ "$errors" = "0" ]; then
          echo -e "${GREEN}✓${NC} $test_name: $tests tests, $successes passed"
          passed_tests=$((passed_tests + 1))
        else
          echo -e "${RED}✗${NC} $test_name: $tests tests, $successes passed, $failures failures, $errors errors"
          failed_tests=$((failed_tests + 1))
        fi
      fi
    else
      echo -e "${RED}✗${NC} $test_name: Failed to run"
      failed_tests=$((failed_tests + 1))
    fi
  else
    echo -e "${RED}✗${NC} $test_name: No results"
    failed_tests=$((failed_tests + 1))
  fi
done

echo ""
echo "========================================"
echo "Overall Summary"
echo "========================================"
echo "Total test files: ${#TEST_FILES[@]}"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"
echo ""
echo "Total tests run: $total_tests"
echo -e "${GREEN}Successes: $total_successes${NC}"
echo -e "${YELLOW}Failures: $total_failures${NC}"
echo -e "${RED}Errors: $total_errors${NC}"
echo ""

# Show detailed output for failed tests
if [ $failed_tests -gt 0 ]; then
  echo "========================================"
  echo "Failed Test Details"
  echo "========================================"
  
  for test_file in "${TEST_FILES[@]}"; do
    test_name=$(basename "$test_file" .lua)
    output_file="$TEMP_DIR/${test_name}.out"
    status_file="$TEMP_DIR/${test_name}.status"
    
    if [ -f "$status_file" ] && [ "$(cat "$status_file")" != "0" ]; then
      echo ""
      echo "--- $test_name ---"
      # Show last 20 lines of output
      tail -20 "$output_file"
    fi
  done
fi

# Exit with error if any tests failed
if [ $failed_tests -gt 0 ] || [ $total_errors -gt 0 ]; then
  exit 1
else
  exit 0
fi
