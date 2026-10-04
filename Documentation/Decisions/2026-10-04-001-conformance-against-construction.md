# Conformance against construction, and the epsilon a harness opens at

Date: 2026-10-04

## Context

Golden Ratio conformed badly in OneBrush. The principal reported that it conformed at forty five degrees, and that plotting the spiral without its quadlines produced the field he expected.

The brief for the cycle preceding this one described a diagnostic: make the quadlines optional so their contribution could be removed and observed. That diagnostic landed at bd456b6 and confirmed the cause. What it did not describe, and what this record exists for, is that the confirmed cause has a requirement already written against it and that requirement is unimplemented.

## Diagnosis

The quadlines are an axis aligned lattice. In a nearest location field the medial line between a horizontal attractor and a vertical one stands at forty five degrees, so a point descending that field travels diagonally. The field was correct for the paths it was handed. `Sources/Mobster/Guide.swift` hands everything its source vends into `FieldBake`, and the quadlines are among them.

`mobster.preset.goldenRatio.quadlines` predicted this in its own text before it was observed: the rectangles "are present only for aligning against, and near the eye they are packed tighter than the curve, so a guide that baked them would conform a point to the scaffolding."

No field defect was found. The exhaustive bake, the exactness of the stored location and the tie break all behaved as their requirements describe.

## Decisions

### The quadline toggle is a diagnostic and not the remedy

`GoldenRatioPreset(quadlines:)` drops the quadlines from the plot entirely by way of `Array(resource.paths.prefix(1))`. That serves `mobster.preset.goldenRatio.quadlines`, which makes plotting them optional, and it serves nothing in `mobster.path.construction`, which requires scaffolding that is drawn and not followed. A consumer wanting to see the rectangles while conforming to the spiral alone cannot get it from a flag that removes them from both.

Whether the flag survives the role implementation was left to the principal and is not decided here.

### A path carries a role, and position indexing is retired

The principal named the carrier: a path role, dictating which supplied paths are for visualization only against those which produce conformance. This is written as `mobster.path.role` and `mobster.path.role.default`.

`mobster.path.order` held the opposing contract: "Nothing on a path says what it is, so a consumer that wants to draw a quadline differently from a spiral indexes by position. That is brittle and it is the contract until something asks for better." A role is the something that asked. The last two sentences of that requirement are now false. They were left standing with an aside rather than cut, because the first two sentences carry a defined emission order that is worth holding on its own and the cut is the principal's to make.

A role has nowhere to live today. `Sources/Mobster/Preset.swift` declares `func paths(in frame: Frame) -> [[SIMD2<Float>]]` and `Sources/Mobster/Line.swift` holds `verts` and `identifier` alone. Satisfying the role therefore changes the surface OneBrush consumes, at both the protocol return and `Line`, which makes it a version bump and a coordinated pull rather than a patch.

### A harness opens at the epsilon its budget affords, derived rather than eyeballed

The principal's instruction: the harness should initialize to the finest epsilon that does produce a field, using the refusal that already reports it.

This is written as `mobster.harness.epsilon.afford` and `mobster.harness.epsilon.afford.reload`. The second exists because affordability moves with the segment count of the loaded source, so a constant cannot hold across a preset swap: Thirds carries four segments and Golden Ratio three hundred and thirty six.

`mobster.vend.default.harness` holds that an opening value is the package's opinion "because the principal set it by eye at the control that derives it." For epsilon that is no longer true. Nobody sets it by eye, so there is no constant to transcribe and `mobster.vend.default` has no static to hold. Budget is untouched and stays set by eye, because it encodes how long a person will wait and nothing derives that.

### Affordability is learned by faulting, not by a query method

The principal set the criterion: supply a method if it is less expensive than faulting, and otherwise faulting is the workflow.

Measured against `Sources/Mobster/FieldBake.swift`, the refusal is thrown before any texel work. The order is the resolution derivation, the grid, the segment flattening, the budget guard, and only then the nested loops. A refused bake therefore costs the derivation, one flattening pass over the supplied verts, and the bisection in `affordable()`, which is roughly sixteen iterations of integer arithmetic. A query returning the same number would pay the derivation and the bisection identically, and could count segments without materializing them, saving one allocation against a bake it never performs.

That saving is not a cost difference in any sense that matters, and for a mesh source the extraction preceding the bake dwarfs it. By the stated criterion, faulting is the workflow and no method is added.

One consequence is recorded against the day it grates: a fault answers only when the caller asks for something unaffordable. A caller supplying an affordable epsilon receives a field and never learns the finest one available. The harness opening therefore asks for an epsilon it knows the derivation cannot afford, in order to be told what it can. That is using an exception as a query. It was accepted because the criterion was cost and the cost is equal, not because it reads well.

### Every requirement uri carries the package name

All one hundred and sixty three requirement uris are prefixed `mobster.`, to remove ambiguity for readers outside this repository. The affected namespaces were field, form, guide, harness, mesh, path, preset, vert and the bare `vert` and `line` type entries.

The principal directed that this be noted here rather than annotated per requirement. No `@renamed` sigils were added. The mapping is total and mechanical — strip the leading `mobster.` to recover any prior name — so a reference to an old uri in an issue, a review or a dispatch brief resolves without a per requirement record, and one hundred and forty five annotations would have been permanent noise in the document for a transformation a reader can perform in their head.

Two hundred and seventy eight uri references stand in `Documentation/Reviews/`, `Documentation/Integration.md` and `Documentation/Workflow.md`, and more in closed and open GitHub issues. They were not rewritten. They resolve by the same mechanical mapping.

## Open, and not decided here

- What a non-positive settle epsilon does. It currently returns an empty field and reports success, because `FieldResolution` yields a zero count for it and `FieldBake` reads a zero count as the degenerate Frame case that `mobster.field.frame.degenerate` requires not to trap. A degenerate epsilon is riding a degenerate Frame's path. Filed as issue 35.
- Whether a floor at `span / (ceiling · √2)` makes anything finer unsatisfiable rather than silently clamped.
- Whether the affordability derivation, private in `FieldBake`, is vended to consumers that need it for the reason the harness does.
- Whether the last two sentences of `mobster.path.order` are cut.
- A two tier field bucketing points into higher resolution sub fields, parked by the principal as a later performance step. Filed as issue 37.

Recorded by clem.
