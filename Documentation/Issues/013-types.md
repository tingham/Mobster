> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 12: Vert and Line

## Requirements covered

vert, vert.mass, vert.drag, vert.coupling, vert.attributes.optional, vert.physics, line

## Deliverable

The two types the consumer speaks in. `Vert` carries a location, an optional identifier, and optional mass, drag and coupling. `Line` carries an ordered sequence of verts and an optional identifier, and holds no behaviour of its own.

They replace `Sample` and `Stroke`. Retire those.

## Constraints

- An absent attribute is not a defaulted one. A consumer supplying none must be distinguishable from one supplying zero, because the first asks for peer state to be disregarded entirely and the second asks for a weight of zero.
- Identifiers remain opaque unsigned integers Mobster never dereferences and never mints.
- Value types. Sendable. One type per file, filename matching.
- No behaviour in this cut. Types and their tests only.

## Acceptance

`swift build` and `swift test` green. A vert with no attributes is distinguishable from one with attributes set to zero, asserted. Value semantics asserted by the types being structs, checkable with Mirror, not by reassignment.
