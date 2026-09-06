# Cut 1: Package foundation

Establishes the package and the types that cross the boundary. No guide behavior.

## Requirements covered

mobster.model.none, mobster.import.permitted, mobster.identity.opaque, mobster.identity.opaque.read, mobster.identity.mint.never, mobster.implementation.swift, mobster.transfer.value, guide.initialize, guide.initialize.reset, guide.space.scene

## Deliverables

- `Package.swift`. Match the Swift tools version and platform floor used by `~/Source/Repos/Jerome`. Report what was matched rather than choosing independently.
- The value types that cross the boundary. A point identifier and a stroke identifier, each an opaque unsigned integer that Mobster never dereferences. A sample carrying a point identifier and a location. A grouping carrying a stroke identifier and its ordered samples. A Frame describing scene space.
- A Guide type exposing `initialize`, receiving the Frame it operates within. Initialize establishes that Frame and discards all prior state.
- Tests covering identifier opacity, value semantics across the boundary, and that initialize clears prior state.

## Constraints

- Mobster declares no document model and imports none. Nothing from OneBrush, Jerome, Tempest or Muslin is imported.
- Swift only. No Metal in this cut.
- One type per file. No protocol declared in the same file as a conformer. No extension blocks appended to a type declaration in the same file.
- Locations are in scene coordinates.

## Acceptance

`swift build` and `swift test` green on macOS. No import of any document model. Every type that carries data across the boundary is a value type. The Guide is not such a type: it holds state across calls, it notifies listeners, and initialize discards what it held, so it has reference semantics.
