# 09. Split utils.lua Into Focused Modules

meta:
  id: reduce-loc-simplify-architecture-09
  feature: reduce-loc-simplify-architecture
  priority: P2
  depends_on: []
  tags: [implementation, refactor, tests-required]

objective:

- Break the 1,335-line `utils.lua` grab bag into focused modules so each concern is independently testable and no single utils file exceeds ~400 LOC.

deliverables:

- `modules/utils.lua` re-scoped to only generic math/table helpers (clamp, lerp, round, enums, getImageBasePath etc.) ≤ ~400 LOC.
- New `modules/FontCache.lua` owning FONT_CACHE, getFont, preloadFont, resolveFontPath, cache stats/clear.
- New `modules/PathValidator.lua` (or fold into existing) owning sanitizePath, isPathSafe, validatePath, getFileExtension, hasAllowedExtension, normalizePath.
- New `modules/TextSanitizer.lua` owning sanitizeText, validateTextInput, escapeHtml, escapeLuaPattern, stripNonPrintable, validateTextRange.
- New `modules/NumberValidation.lua` (or fold validate* functions) owning isNaN, isInfinity, validateNumber, sanitizeNumber, validateInteger, validatePercentage, validateOpacity, validateDegrees, validateCoordinate, validateDimension, validateRange, validateType, validateEnum.
- Backward-compatible re-exports: `utils.getFont`, `utils.validateRange`, etc. remain as thin aliases so call sites needn't change in this task.
- Updated/split tests.

steps:

- Categorize every function in utils.lua (48 symbols) into the 4 target modules by concern.
- Create the new module files with proper `Module.new`/`Module.init(deps)` pattern and LuaDoc per FlexLove conventions.
- Move function bodies verbatim (no logic changes this task).
- Add backward-compat aliases in `utils.lua` delegating to the new modules (`utils.getFont = FontCache.getFont`).
- Update `FlexLove.lua` / `ModuleLoader` to load the new modules and pass as deps.
- Split `utils_test.lua` into per-module test files OR keep it but ensure it still covers the alias surface.

tests:

- Unit: each new module's functions produce identical output to the old utils functions for a set of representative inputs.
- Integration: `utils_test.lua`, `calc_test.lua` (if validation used), `theme_test.lua` (font cache), full suite green.

acceptance_criteria:

- `wc -l modules/utils.lua` ≤ 400.
- Each new module file ≤ 400 LOC and concerns clearly separated (no cross-imports between them except via deps).
- Backward-compat aliases pass the existing `utils_test.lua` unchanged.
- No test regressions vs baseline.

validation:

- `lua testing/__tests__/utils_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline.
- `wc -l modules/*.lua | sort -rn | head` shows utils no longer in top 3.

notes:

- Backward-compat aliases are intentional to keep this task low-risk. A later cleanup can removes the aliases if call sites are updated — but that's out of scope here.
- `validateOpacity`/`validateNumber` are tiny but cohesive; grouping all validators in one `NumberValidation` module avoids 8 micro-files.
- This task has no hard dependency and can run in parallel with 02–08.
