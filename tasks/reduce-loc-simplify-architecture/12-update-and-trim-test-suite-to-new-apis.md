# 12. Update and Trim Test Suite to New APIs

meta:
  id: reduce-loc-simplify-architecture-12
  feature: reduce-loc-simplify-architecture
  priority: P1
  depends_on: [reduce-loc-simplify-architecture-10, reduce-loc-simplify-architecture-11]
  tags: [tests, refactor]

objective:

- Migrate the test suite to the schema/registry-driven APIs and extracted subsystem modules, and remove tests that redundantly covered the old hand-bound props (whose coverage is now subsumed by the schema + binding loop).

deliverables:

- Existing tests updated to call extracted subsystems directly where appropriate (e.g., `Select.open(el)` vs `el:openSelect()`) while keeping the Element-method delegates covered once.
- New schema tests (`property_schema_test.lua`) and extraction-specific tests integrated into `runAll.lua`.
- Redundant prop-specific test cases (e.g., one test per Deferred bool) consolidated — the generic Deferred-binding loop covers them via a parametric test.
- `element_test.lua` (4,370 LOC) trimmed of cases now covered generically; target a meaningful reduction without losing behavioral coverage.
- Test counts recorded vs baseline (task 01).

steps:

- Audit `element_test.lua`, `flexlove_test.lua`, and the subsystem test files for cases that test the old hand-binding mechanics rather than behavior.
- Consolidate repetitive Deferred / prop-default tests into parametric table-driven tests over schema entries.
- Update any tests that called removed ErrorHandler warns to expect the new schema-validator error path (per task 11).
- Add integration tests for the new `PropertySchema` module and the extraction delegations.
- Register any new test files in `runAll.lua`.
- Run the full suite; ensure pass count ≥ baseline minus intentionally-removed redundant cases.

tests:

- Unit: the test suite itself — each migrated test passes.
- Integration: `runAll.lua` green; coverage parity (no behavior lost) confirmed via the schema-driven cases.

acceptance_criteria:

- `lua testing/runAll.lua --no-coverage` exits 0.
- Total test LOC reduced or neutral, with no loss of *behavioral* coverage (document removed-redundant cases).
- New schema/extraction tests registered and passing.
- Baseline test names (from task 01) accounted for: either migrated or explicitly documented as removed-redundant.

validation:

- `lua testing/runAll.lua --no-coverage` exits 0 and pass count ≥ baseline behavioral coverage.
- `lua testing/__tests__/property_schema_test.lua` exits 0.
- Diff of test pass count vs `baseline.md` shows no unexplained regressions.

notes:

- This is the riskiest test-only task — prioritize behavioral coverage preservation over LOC reduction. Keep a redundant case rather than silently lose coverage.
- If a migrated test reveals a real behavior drift from tasks 03–10, file it back to the responsible task rather than papering over it here.
