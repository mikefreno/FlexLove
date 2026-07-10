# 13. Verify LOC Reduction and Regressions

meta:
  id: reduce-loc-simplify-architecture-13
  feature: reduce-loc-simplify-architecture
  priority: P0
  depends_on: [reduce-loc-simplify-architecture-12, reduce-loc-simplify-architecture-09]
  tags: [verification, metrics, final]

objective:

- Measure the final state of the codebase against the baseline (task 01) and confirm all exit criteria are met.

deliverables:

- A `tasks/reduce-loc-simplify-architecture/final-report.md` artifact comparing baseline vs final metrics: per-file LOC, Element method count, props-handling counts, ErrorHandler call count, test pass/fail.
- Confirmation (or documented deviation) for each exit criterion in the feature README.

steps:

- Re-run all the metrics captured in task 01: `wc -l` across source, Element method greps, `props.X` / `self.X = props.X` counts, `Deferred` count, `ErrorHandler` count.
- Run `lua testing/runAll.lua --no-coverage` and capture pass/fail; compare to `baseline.md`.
- Verify each README exit criterion:
  - Element.lua ≤ 3,100 LOC.
  - No Element function > ~400 LOC.
  - Zero hand-written `self.X = props.X` Deferred boilerplate pairs.
  - `setProperty` has no inline special-case branches (or only the documented explicit handler map).
  - No select/scrollbar/text-selection logic on the Element class.
  - utils split into ≥3 modules, each ≤ ~400 LOC.
  - Total non-test source LOC reduced ≥20%.
- Write `final-report.md` with a table: metric | baseline | final | delta.
- List any unmet criteria with a root-cause note and proposed follow-up.

tests:

- Unit: none — verification task.
- Integration: the full test suite is the regression check.

acceptance_criteria:

- `final-report.md` exists and contains the complete metric comparison table.
- All exit criteria either met or explicitly documented as deviated with justification.
- `lua testing/runAll.lua --no-coverage` passes with no new failures vs baseline.

validation:

- `cat tasks/reduce-loc-simplify-architecture/final-report.md` shows the comparison table.
- `lua testing/runAll.lua --no-coverage` exits 0.
- `wc -l modules/Element.lua` ≤ 3,100 (or documented deviation).

notes:

- If a criterion misses the target, document the gap and the next incremental step rather than over-refactoring under time pressure in this task.
- This task is read-only with respect to source — only writes are the report artifact.
