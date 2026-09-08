> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 11: Decimation

## Requirements covered

path.decimate.tolerance, path.smooth.never

## Deliverable

Supplied paths are decimated until their deviation from the supplied geometry reaches one texel. Detail the field cannot resolve is not carried.

The texel follows from the Frame and the derived field resolution, which follows in turn from the Frame and the settle epsilon. The tolerance is derived the whole way down and nothing about it is supplied.

## What not to build

Mobster does not smooth supplied geometry. The consumer has already interpreted the stroke and smoothing again discards a decision made with more context than we have. `path.smooth.never` is a constraint on this cut, not a feature of it.

The complexity cap is a separate cycle and is not in scope here. Do not reject anything.

## Prior art

`~/Source/Repos/Jerome/Sources/Jerome/Finding/ContourFinder.swift:84-106` is a stack based Ramer Douglas Peucker taking and returning `[SIMD2<Float>]`, importing only simd. Hard copy it. Do not add a dependency and do not write the mathematics from scratch.

## Constraints

- Swift only. One type per file, filename matching the type.
- Deterministic: the same path and tolerance decimate identically every time.
- Decimation must not move a vertex. It removes vertices or it does nothing.

## Acceptance

`swift build` and `swift test` green. A path already inside tolerance is returned unchanged. A dense path along a straight run reduces to its endpoints. A path with a feature larger than a texel keeps that feature, asserted against hand derived positions. A test fails when the tolerance changes.
