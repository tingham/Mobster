# Cut 13: Derived field resolution

## Requirements covered

field.resolution.derive, field.resolution.refuse

## Deliverable

The field resolution follows from the Frame and the settle epsilon. It is no longer supplied. Remove the resolution parameter from every entry point that takes one.

A read snaps to the containing texel, so a texel larger than the epsilon carries more error than the tolerance the verts are settling within. That coupling is the derivation.

Where the derived resolution costs more to bake than the package will spend, refuse and report both the epsilon asked for and the epsilon that would be affordable, so the consumer chooses again rather than discovering the cost.

## Constraints

- Swift only. One type per file.
- The spending limit is a parameter, not a baked constant.
- The bake is exhaustive and its cost is texels times segments. Measure before and after and report both.

## Acceptance

`swift build` and `swift test` green. No entry point accepts a resolution. A halved epsilon produces a finer field, asserted on the texel count. A refusal reports an affordable epsilon that, when supplied, is accepted. A test fails when the derivation changes.
