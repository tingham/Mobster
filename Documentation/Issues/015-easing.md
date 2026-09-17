> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 14: Mass and drag

## Requirements covered

vert.mass, vert.drag, vert.attributes.optional

## Deliverable

`evaluate` consumes a vert's mass and drag when computing how far along its travel that vert stands at the supplied time.

- Mass moves a vert less per tick.
- Drag moves a vert less at the start of its travel.
- A drag of minus one moves a vert away from its target rather than toward it.

## What does not change

`guide.evaluate.settled` says every vert has arrived at the duration. Mass and drag shape the approach between zero and the duration; they do not delay arrival past it. A vert with maximum mass still stands on its target at the duration.

Negative drag is the exception and only in the sense that its path leads away before returning; at the duration it is home like everything else.

## The absent attribute

An absent attribute is not a defaulted one. A vert supplying no mass is asking for the plain travel; a vert supplying a mass of zero is asking for a weight of zero. Whatever those two mean, they must not be the same code path, and a test must prove they differ.

## Constraints

- Swift only. One type per file, filename matching.
- Deterministic. No wall clock, no drawn random state. A seed, if a curve needs one, derives from the vert identifier.
- Evaluating a time yields the same result whatever times were evaluated before it.
- Do not invent character. Mass and drag are the two named shapes and nothing else. No springs, no overshoot, no easing library.

## Acceptance

`swift build` and `swift test` green, `xcodebuild` on the harness succeeds. Every vert stands on its target at the duration regardless of mass and drag, asserted across a spread of both. A heavier vert is behind a lighter one at half the duration, asserted against hand derived positions. A vert with drag of minus one is further from its target at a small time than it began, and home at the duration. A test fails when the mass term changes and another fails when the drag term changes.
