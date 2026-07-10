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
- [~] 08 — extract-texteditor-selection-from-element → `08-extract-texteditor-selection-from-element.md`
- [ ] 09 — split-utils-into-focused-modules → `09-split-utils-into-focused-modules.md`
- [ ] 10 — split-element-new-into-staged-initializers → `10-split-element-new-into-staged-initializers.md`
- [ ] 11 — trim-defensive-errorhandler-instrumentation → `11-trim-defensive-errorhandler-instrumentation.md`
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
