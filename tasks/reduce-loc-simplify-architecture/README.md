# Reduce LOC & Simplify Architecture

Objective: Cut source LOC and eliminate special-case prop handling by introducing a declarative property schema, extracting leaked subsystem mixins out of Element, and splitting the god-constructor into staged phases.

Status legend: [ ] todo, [~] in-progress, [x] done

## Tasks

- [x] 01 — baseline-metrics-and-audit → `01-baseline-metrics-and-audit.md`
- [x] 02 — property-schema-registry-module → `02-property-schema-registry-module.md`
- [x] 03 — data-driven-prop-binding-in-element-new → `03-data-driven-prop-binding-in-element-new.md`
- [x] 04 — hoist-lookup-tables-to-module-scope → `04-hoist-lookup-tables-to-module-scope.md`
- [x] 05 — registry-driven-setproperty-dispatch → `05-registry-driven-setproperty-dispatch.md`
- [x] 06 — extract-select-subsystem-from-element → `06-extract-select-subsystem-from-element.md`
- [x] 07 — extract-scrollbar-handling-from-element → `07-extract-scrollbar-handling-from-element.md`
- [x] 08 — extract-texteditor-selection-from-element → `08-extract-texteditor-selection-from-element.md`
- [x] 09 — split-utils-into-focused-modules → `09-split-utils-into-focused-modules.md`
- [x] 10 — split-element-new-into-staged-initializers → `10-split-element-new-into-staged-initializers.md`
- [x] 11 — trim-defensive-errorhandler-instrumentation → `11-trim-defensive-errorhandler-instrumentation.md`
- [ ] 12 — update-and-trim-test-suite-to-new-apis → `12-update-and-trim-test-suite-to-new-apis.md`
- [ ] 13 — verify-loc-reduction-and-regressions → `13-verify-loc-reduction-and-regressions.md`

## Dependencies

- 02 depends on 01
- 03 depends on 02
- 04 depends on 01
- 05 depends on 02
- 06 depends on 03
- 07 depends on 03
- 08 depends on 03
- 10 depends on 03, 05, 06, 07, 08
- 11 depends on 06, 07, 08
- 12 depends on 10, 11
- 13 depends on 12, 09

## Exit criteria

- Element.lua reduced by ≥35% LOC (target: ≤3,100 LOC from 4,757)
- Element.new is no longer a single monolith; no function > ~400 LOC
- Zero hand-written `self.X = props.X` callback/Deferred boilerplate pairs — all props bound via the schema registry
- `setProperty` contains zero inline special-case branches for layout/dimension/themeComponent units (driven by schema flags)
- No select/scrollbar/text-selection logic defined directly on the Element class (all delegated to subsystem modules)
- utils.lua split into ≥3 focused modules; no single utils file > ~400 LOC
- Full `lua testing/runAll.lua --no-coverage` suite passes with no new failures vs baseline
- Total non-test source LOC reduced by ≥20%

## Task 11 metrics — trim-defensive-errorhandler-instrumentation

- `grep -c "ErrorHandler" modules/Element.lua`: baseline **45** → **26** (−19 sites, **42.2% reduction**, exceeds the ≥40% acceptance bar).
- The 3 remaining `Element._ErrorHandler = deps.ErrorHandler` / `ErrorHandler = Element._ErrorHandler` lines are unavoidable dependency bindings (Element.init + EventHandler/TextEditor deps tables); the rest are genuine boundary validators that *cannot* be deleted (public-API input + schema VAL_001 throw site).
- Classification applied:
  - (a) **boundary validation (kept)**: `_applyProps` schema VAL_001 throw, `display`/`textSize`/`textAlign`/`flexGrow`/`flexShrink`/`flexBasis`/children-array/`top|right|bottom|left`-without-absolute/CSS-vs-flex-grid-mix warnings, `_resolveUnit`/`_resolveDimensionProperty` non-number resolution, deferred-method CORE_002/004/005 limits, animation/transition API ELEM_003/004/005 guards, LAY_004 percentage-with-autosizing, ELM_001 stale-dimension (one-time-per-prop).
  - (b) **defensive re-check of already-validated input (removed)**: the `tempWidth`/`tempHeight` "is not a number after resolution" LAY_003 guards in `_initBoxModel` — `_resolveUnit` already warns+clamps non-numbers, so these duplicated the boundary check and were pure dead defensive code.
  - (c) **per-frame warn already one-time (kept as-is)**: `_checkDimensionTypes` (ELM_001) is gated by `self._dimWarned[prop]`, so it already registers once per stale prop — no change needed.
- Consolidation (single-reference helpers, validation semantics unchanged): `_warnTextAlign`, `_warnFlexInvalid`, `_warnChildrenInvalid`, `_warnCssPositioningWithoutAbsolute`, `_warnAnimApi`, `_fireImageCallback`. The 5 duplicated EVT_002 pcall+warn blocks across `_initImageAndRenderer`/`_loadImage` collapsed into `_fireImageCallback` (which preserves the direct-`image` sync path's immediate firing via `honorDeferred=false` and the async `_loadImage` path's deferred firing via `honorDeferred=true`).
- Guardrails: `critical_failures_test.lua` (33/0) and `event_handler_test.lua` (24/0) pass; full suite `lua testing/runAll.lua --no-coverage` = **1911 tests, 0 failures** (matches baseline). No public-API input went unvalidated — all warning *emission* was consolidated/moved, none deleted; the schema validators (Task 02) already cover the non-SPECIAL_PROPS type/range checks.
- Note for Task 12: warning *codes* and detail *shapes* are preserved, but a few detail-table field-orderings changed (e.g. `_warnFlexInvalid` emits `element/issue/value`; `_warnChildrenInvalid` omits `value` when nil). Tests asserting on codes (ELEM_010/011/012, LAY_004, ELEM_008/009, VAL_001) still pass; tests asserting on exact detail-table contents (none found) would need updating.
