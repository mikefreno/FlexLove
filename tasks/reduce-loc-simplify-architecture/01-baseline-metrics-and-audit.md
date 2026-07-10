# 01. Baseline Metrics and Audit

meta:
  id: reduce-loc-simplify-architecture-01
  feature: reduce-loc-simplify-architecture
  priority: P0
  depends_on: []
  tags: [audit, metrics, foundational]

objective:

- Capture the current state of the codebase so every later task can measure its impact against a known-good baseline.

deliverables:

- A `tasks/reduce-loc-simplify-architecture/baseline.md` artifact recording per-file LOC, Element method count, props-handling counts, and test results.
- A confirmed-green test run snapshot (pass/fail counts) to protect against regressions.

steps:

- Run `wc -l` across all non-test source files (`modules/*.lua`, `FlexLove.lua`) and record totals plus the top 15 largest.
- Count Element.lua metrics: total methods (`grep -c "^function Element:"`), `props.X` reads in `Element.new`, `self.X = props.X` copies, `Deferred` boilerplate lines, `ErrorHandler` call sites.
- Categorize Element methods by subsystem (select/scroll/text-selection/maintenance) for the extraction tasks.
- Run `lua testing/runAll.lua --no-coverage` and capture pass/fail/skip counts into the baseline artifact.
- Record the full test names list so task 12 can compare coverage parity.

tests:

- Unit: none — this is a measurement task.
- Integration/e2e: confirm `runAll.lua` exits 0 (or document pre-existing failures explicitly).

acceptance_criteria:

- `baseline.md` exists and contains: per-file LOC, Element metrics, test pass/fail counts.
- The test suite result recorded matches actual output (no fabrication).

validation:

- `cat tasks/reduce-loc-simplify-architecture/baseline.md` shows all required sections.
- `lua testing/runAll.lua --no-coverage` reproduces the recorded pass/fail counts.

notes:

- Keep the baseline read-only — do not modify any source in this task.
- If the suite has pre-existing failures, document them so they aren't blamed on later tasks.
