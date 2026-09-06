# Integrating Mobster

## Mobster is a function

You give it paths or a preset with its parameters, a configuration for the field, a set of strokes, and a time. It gives back the points, by identifier, and where they landed.

```swift
let paths = ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame)

let guide = Guide(frame: frame, adherence: adherence, settleEpsilon: epsilon)
try guide.update(paths: paths, budget: budget, time: 0)
guide.tokenize(membership: strokes, time: 0)

let advance = guide.play(speed: speed, time: t)
for landed in advance.displacements {
    // landed.point, landed.location
}
```

Nothing in that sequence requires the Guide to outlive the call. Construct it, resolve, read the result, discard it. **Statefulness is the consumer's to derive**, not the package's to impose: a client that wants to hold the Guide between frames and animate may, and a client that wants one resolve and a committed result need not know the type persists anything.

## Which positions go back in

The single decision this contract forces, and the one that decides the character of the tool.

A target is resolved once, from where a point is when it is tokenized, and a point far from every path settles SHORT of that path rather than arriving on it. That is deliberate.

So one application, with the original positions in and a time past the last arrival, gives the final result: everything drawn as far toward the guide as adherence says it should be drawn, and no further. Feeding those results back in as a second application resolves fresh targets from the new positions and draws them further. Successive applications converge onto the path; a single application does not.

That is the iteration cycle — place a guide, apply it, commit, transform the guide, apply again — and it is why the two behave differently on purpose.

## Time is a dividend, not the mechanism

The time argument exists because evaluating at a time is how a target gets approached at all. That it can be swept to produce motion is an affordance that comes free, not the reason the package is shaped this way. A client using guides as art creation tools asks for a time past the last arrival, takes the positions, and never animates anything.

## The modes

The modes a client composes differ chiefly in **what the document persists** — the displaced positions, or the relationship that produced them.

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
