# 02. Property Schema Registry Module

meta:
  id: reduce-loc-simplify-architecture-02
  feature: reduce-loc-simplify-architecture
  priority: P0
  depends_on: [reduce-loc-simplify-architecture-01]
  tags: [implementation, architecture, tests-required]

objective:

- Create a single declarative source of truth for every Element prop — its type, default, normalization rule, validation, whether it's a dimension/unit prop, whether it triggers layout invalidation, and whether it has a Deferred companion.

deliverables:

- New module: `modules/PropertySchema.lua` exposing `PropertySchema.define(props)` → registry table and `PropertySchema.get(name)` → metadata.
- A populated schema table covering all currently-handled props in `Element.new` and `setProperty` (dimensions, layout Influencers, callbacks, visual, state, select, scroll, text fields).
- Metadata fields per prop: `type`, `default`, `normalizer` (fn|nil), `validator` (fn|nil), `isDimension` (bool), `affectsLayout` (bool), `syncsTheme` (bool), `hasDeferred` (bool), `storageKey` (string|nil for aliased storage).
- Unit tests for the registry covering lookup, defaults, missing-prop handling, and normalizer invocation.

steps:

- Enumerate every `props.X` reference in `Element.new` (lines 274–1920) and every special case in `setProperty` to build the full prop inventory.
- Design the metadata shape; keep it minimal — only fields that downstream tasks (03, 05) actually consume.
- Implement `PropertySchema.lua` as a pure data table + accessor, no `love` dependency so it's unit-testable standalone.
- Populate the schema entries in `Element.init` (or a dedicated `PropertySchema.populate()`) so it can extend/override per build profile.
- Write `testing/__tests__/property_schema_test.lua` following the FlexLove test lifecycle (loveStub, luaunit).

tests:

- Unit: `PropertySchema.get("opacity")` returns correct default/validator; `.get("unknown")` returns nil without error; normalizer functions transform input correctly (e.g., single-value padding → 4-side table).
- Integration: schema covers at least the full prop set enumerated from Element.new (assert no prop in the inventory returns nil).

acceptance_criteria:

- `PropertySchema.lua` exists and returns metadata for every prop currently handled in `Element.new` and `setProperty`.
- Registry lookups are O(1) table access, no per-call construction.
- Unit test file passes with all defined entries validated.
- No `love` import in the module (pure Lua, stub-testable).

validation:

- `lua testing/__tests__/property_schema_test.lua` exits 0.
- `grep -c "props\." modules/Element.lua` count of unique props ≤ schema entries (every handled prop is registered).

notes:

- This module is the keystone — tasks 03 and 05 depend on its metadata shape. Lock the API before proceeding.
- Keep normalizers small and pure; they'll be hot-pathed during construction.
