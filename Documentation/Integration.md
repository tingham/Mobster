# Integrating Mobster

The package is small. The integration is not. What follows are the modes a client composes from it, which differ chiefly in **what the document persists** — the displaced positions, or the relationship that produced them.

## Live stroke only

The guide affects the stroke being drawn and nothing else. Its membership is the in progress stroke, not the layer. The result is captured to persistence when the stroke commits.

Requires from Mobster: a membership scoped to one stroke, and a settled result read at commit.

## Preview then drop

The guide is placed with a falloff and previews live over existing content. Dropping it persists the modifications destructively and the guide goes away.

Requires from Mobster: the live workload for the preview, the destructive result on commit, and the falloff selection governing how much existing work the preview disturbs.

## Dynamic modifier from a layer

The guide is placed as a modifier on a layer and driven by guide marks made on another layer. **The relationship is persisted, not the results.** Editing the source layer changes the target.

Requires from Mobster: a source layer identity the client can store and hand back, and interpretation of that layer's stroke data into paths.

## Dynamic modifier from a preset

As above, but plotted from a preset rather than a source layer. Persisted only as the active modifier on the layer, never as the resulting positions.

Requires from Mobster: preset identity and parameters the client can store and hand back.

## The consequence the last two carry

A mode that persists the relationship rather than the positions **recomputes the displacement every time the document opens**. That makes determinism a document integrity requirement rather than a convenience: if the falloff, the field bake, or the rate resolve differently in a later version, every document using those modes opens changed.

Nothing in the package currently pins its behaviour across versions. The determinism the design does require — the same sequence of plays and field changes producing the same result — is within one build. Two builds agreeing is a separate promise and it is not yet made anywhere.

Document load is also the case for playing straight to the end, since a stored relationship should open settled rather than animating on every open.
