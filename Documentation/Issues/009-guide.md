# Cut 8: The Guide

Tokens, targets, adherence, and playback. The thing the package exists to do.

## Requirements covered

token.create, token.reuse, token.identity.stroke, token.identity.point, token.progress, token.target, token.origin, token.planar, token.segment, token.authority.none, guide.adherence.reach, guide.adherence.reach.full, guide.adherence.reach.least, guide.adherence.falloff, guide.adherence.target, guide.adherence.short, guide.adherence.curve, guide.play, guide.play.evaluate, guide.play.end, guide.rate, guide.determinism.pure, guide.determinism.seed, guide.rect.dirty, guide.settle.epsilon, guide.settle.notify, guide.settle.track.never, guide.skiptake.source, guide.skiptake.target, guide.skiptake.retarget, guide.skiptake.tokenize, guide.skiptake.remove, guide.initialize.reset, guide.pass.single

## Scope

Library only. No harness work in this cut; a later pass displays it.

## The shape of it

A Guide holds a Frame, a field baked from its guide paths, and a token per point in its membership. A token carries the identifiers of its point and its stroke, the point's current location, the location it will land on, and the time origin of the segment in flight. It carries no depth and no authority over the point it references.

A target is resolved when the token is created and persists until a field change. Resolution reads the field twice: distance at the point's location, and direction toward the nearest path location. The falloff yields a weight of one over one plus the square of distance over reach, and the target is the point's own location displaced toward the nearest path location by that weight of the distance between them. A point far from every path therefore settles SHORT of the path rather than arriving at it. At full adherence the reach covers the Frame and a point snaps fully onto the path; at the least adherence the reach collapses and only a point already at a path location moves.

A field change ends the segment in flight and starts a new one anchored at wherever the point actually is. That is why progress is stored rather than derived: the target can change at any time, so the current location is the anchor for the next interpolation.

## Deliverables

- Token creation over a membership, reusing an existing token for a point that already has one.
- Target resolution against the field.
- The adherence falloff, with reach as a parameter.
- `play`, receiving a speed and a time, evaluating every token in the membership at that time. Playing to the end time settles every token in one call.
- Rectangles in scene coordinates covering advanced points, individually or as unions.
- A settled notification to listeners when every point is within one pixel of its target. The Guide does not track settled state and does not walk its membership to answer for it.
- Initialize discards every token and rebuilds the membership.
- Tests.

## On the rate

The rate at which a point travels its segment is DELIBERATELY unspecified by the design. It is an aesthetic question the principal answers by moving a slider. Implement the simplest honest rate, make it a parameter, and do not invent easing, springs, or character. That is a later decision and pre empting it costs more than it saves.

## Determinism

Evaluation within a segment is a pure function of the token and the time. No wall clock. No drawn random state. Where the rate needs a seed, derive it from the point identifier rather than drawing one. Same sequence of plays and field changes, same result, every time.

## Constraints

- Swift only. No Metal.
- One type per file. No extension islands. No protocol declared with a conformer.
- Mobster never mints an identifier.
- A pass resolves one Guide. Do not build composition of two.

## Acceptance

`swift build` and `swift test` green. A point at a path location does not move. A point far from every path settles short, at a distance the falloff predicts, asserted against a hand computed literal. A field change mid flight re anchors the segment at the point's current location rather than its original one. Playing the same sequence twice yields identical locations. Settlement fires once, when the last point arrives.
