> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 10: Grid preset

## Requirements covered

preset.grid

## Deliverable

A grid preset plotting columnar dividers and row lines together across the Frame, with one count and one gutter serving both axes.

It plots in aspect mode by construction, as the other Frame relative presets do.

## Constraints

- Swift only. One type per file, filename matching the type.
- A gutter is a band with two edges. A count of four with one gutter width yields six lines per axis, twelve in all.
- Every value a user could tune is a parameter with no baked magnitude.
- Deterministic: same Frame and parameters yield an identical sequence every time.

## Acceptance

`swift build` and `swift test` green. The line count is asserted literally for a known count and gutter, on both axes, at positions derived by hand rather than recomputed from the implementation's own formula. A test fails when the count changes and another fails when the gutter changes.
