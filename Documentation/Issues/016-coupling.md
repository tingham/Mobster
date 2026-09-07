# Cut 15: Coupling

## Requirements covered

vert.coupling, vert.physics

## Deliverable

`evaluate` consumes a vert's coupling. A vert's motion advances its neighbours along their own travel, by a signed amount, propagating outward along the line.

Coupling is a time offset, not a shared displacement. A coupled neighbour moves further along toward **its own** target; it is not carried toward this vert's target.

## Why that shape

Propagation supplies the falloff for free. A coupling below one passes along less at each hop than it received, so influence decays with distance along the line and how far it reaches is not a separate parameter.

It also removes an arbitration that a line level property would have required. With coupling on the vert, nothing has to decide which vert's target wins for a stiff line, because the motion emerges from propagation rather than being chosen.

## Deliberately not in this cut

Shared displacement, where a line moves as one body preserving its shape. Time offsets cannot produce that: two verts with different targets deform however tightly they are coupled. Whether that behaviour is wanted is a judgement the principal makes after seeing this version in the harness, and building it now would pre empt that.

## Constraints

- Every vert is still home at the duration. Coupling shapes the approach the way mass and drag do; it does not carry a vert past the duration or leave one short of it. A negative offset must not leave a neighbour unarrived when the duration is reached.
- Deterministic, and this is where it will go wrong: a vert reached from both sides must combine the offsets it receives order independently. Summing and taking the maximum both qualify; taking the first does not. The field tie break resolved by sweep order until a reconciliation caught it, and this has the same shape.
- An absent coupling is not a coupling of zero.
- Swift only. One type per file, filename matching. No wall clock, no drawn random state.

## Harness

A coupling slider, applied uniformly across the fixture population, so the effect is visible at a glance. The principal is deciding whether shared displacement is needed and cannot decide that from a test.

## Acceptance

`swift build` and `swift test` green, `xcodebuild` on the harness succeeds. A line of uncoupled verts is unchanged by the feature. A vert with coupling advances its neighbours and the advance decays with distance along the line, asserted against hand derived positions. A negative coupling retards neighbours. Every vert is home at the duration across a spread of couplings. A vert reached from both sides receives the same result whichever order the line is walked, asserted by walking it both ways.
