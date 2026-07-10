# 11. Trim Defensive ErrorHandler Instrumentation

meta:
  id: reduce-loc-simplify-architecture-11
  feature: reduce-loc-simplify-architecture
  priority: P2
  depends_on: [reduce-loc-simplify-architecture-06, reduce-loc-simplify-architecture-07, reduce-loc-simplify-architecture-08]
  tags: [implementation, cleanup, refactor]

objective:

- Reduce the ~45 `ErrorHandler:warn/:error` call sites in Element.lua (and proportional redundancy in extracted modules) so validation happens at module/param boundaries rather than repeated at every internal call.

deliverables:

- Consolidated validation: props validated once at `_applyProps` entry (via schema validators) rather than re-checked at each use site.
- Redundant "expecting X, got Y" warns that duplicate the schema validator removed — schema validators already cover type/range.
- Internal call sites that trust their own module's invariants (e.g., ScrollManager → ScrollManager internal) no longer re-warn on every step.
- ErrorHandler calls reduced to genuine boundary/external-input checks.

steps:

- Inventory all `ErrorHandler` call sites in Element.lua and the extracted subsystem modules.
- For each, classify: (a) boundary validation (keep), (b) defensive re-check of an already-validated input (remove), (c) per-frame warn that should be a one-time registration (refactor).
- Remove category-(b) sites; replace category-(c) with initialization-time warnings or assertions.
- Ensure schema validators (task 02) cover the removed boundary checks — if not, strengthen the validator rather than the call site.
- Run full suite to confirm no behavioral regression (warnings removed but valid inputs still accepted, invalid inputs still rejected with appropriate error).

tests:

- Unit: invalid inputs at public API boundaries still produce an error/warn (e.g., `setProperty("opacity", 2)` warns via schema validator).
- Integration: `critical_failures_test.lua`, `event_handler_test.lua`, full suite green.

acceptance_criteria:

- `grep -c "ErrorHandler" modules/Element.lua` drops by ≥40% from baseline.
- No public-API input goes unvalidated — validation moved to schema/boundary, not deleted.
- Test suite matches baseline (including the failure-path tests).
- `critical_failures_test.lua` passes.

validation:

- `lua testing/__tests__/critical_failures_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline.
- `grep -c "ErrorHandler" modules/Element.lua` shows reduction vs baseline recorded in task 01.

notes:

- Do NOT remove validation that catches genuinely-external malformed input (e.g., user-supplied `love` image paths) — only remove redundant re-checks of already-trusted internal data.
- The `critical_failures_test.lua` suite is the guardrail here; if it breaks, a removed warn was load-bearing — restore it.
- Coordinate with task 12 — test expectations on warning messages may need updating.
