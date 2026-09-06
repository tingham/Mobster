# Reconciliation: Cut 8, the Guide

Branch `cycle/guide`, commits `d289b83..f1d2758`, worktree `/Users/tingham/Source/Repos/Mobster/.worktrees/guide`. Merged at `1b65ab4`. The six source files and eight test files of the cut are byte identical between `f1d2758` and `develop`.

Authorities: `Documentation/Design/Mobster.md` and `Documentation/Issues/009-guide.md`.

## Build and test, actual output

Guide worktree: `swift build` succeeds, "Build complete! (0.14s)". `swift test` FAILS TO COMPILE. `FieldReadTests.swift:79`, `FieldToleranceTests.swift:85,86,90` and the Golden Ratio initializer call are stale against the plot mode signature. Those three files were swept onto the construction time plot mode in `c46f287` on `cycle/sweep`, merged to develop at `adc0378`, which is after the `d289b83` branch point. Inherited, not a defect of this cut. The consequence that is a fact of this cut: `swift test` was never green on this branch, so the acceptance criterion could only have been met against a filtered run or against the merge.

Merged develop checkout: `swift build` clean, `swift test` reports "Test run with 141 tests in 30 suites passed after 1.302 seconds".

## A. Requirement coverage

The change order names THIRTY FOUR URIs, not thirty three.

| URI | Where | Verdict |
|---|---|---|
| token.create | Guide.swift:26-39; TokenTests.swift:11 | covered |
| token.reuse | Guide.swift:29; TokenTests.swift:42 | covered, mutation reddens |
| token.identity.stroke | Token.swift:4, Guide.swift:33; GuidePlayTests.swift:75 | covered |
| token.identity.point | Token.swift:3, Guide.swift:32; TokenTests.swift:36 | covered |
| token.progress | Token.swift:6, Guide.swift:63; GuidePlayTests.swift:26 | covered |
| token.target | Token.swift:8, Guide.swift:35; GuideSegmentTests.swift:18 | covered |
| token.origin | Token.swift:10, Guide.swift:64 | FAILED, see C1 |
| token.planar | Token.swift:6,8 | vacuous, enforced by the type, no test |
| token.segment | Guide.swift:43-52; GuideSegmentTests.swift:32 | covered for a field change, over applied at every play |
| token.authority.none | Token.swift:2-11 | vacuous, no test |
| guide.adherence.reach | Adherence.swift:4; AdherenceTests.swift:23 | covered |
| guide.adherence.reach.full | Adherence.swift:11-15; AdherenceTests.swift:37 | VACUOUS, only at reach infinity |
| guide.adherence.reach.least | Adherence.swift:12; AdherenceTests.swift:40 | CC, names an empty behaviour |
| guide.adherence.falloff | Adherence.swift:14; AdherenceTests.swift:23-29 | covered, arithmetic verified |
| guide.adherence.target | Adherence.swift:21; AdherenceTests.swift:31 | covered, arithmetic verified |
| guide.adherence.short | Adherence.swift:21; AdherenceTests.swift:31 | covered, arithmetic verified |
| guide.adherence.curve | nowhere | CO, unimplemented everywhere |
| guide.play | Guide.swift:54 | covered |
| guide.play.evaluate | Guide.swift:59; GuidePlayTests.swift:22 | covered, mutation reddens |
| guide.play.end | Guide.swift:106; GuidePlayTests.swift:31 | FAILED, see F6 |
| guide.rate | Guide.swift:54,100 | covered by abstention |
| guide.determinism.pure | Guide.swift:100-117; GuideDeterminismTests.swift:35 | covered, verified across processes |
| guide.determinism.seed | no seed exists | vacuous, conditional requirement, consistent |
| guide.rect.dirty | GuideRect.swift:12, Guide.swift:78, GuideAdvance.swift:10,14 | covered, mutations redden |
| guide.settle.epsilon | Guide.swift:3,112 | VACUOUS, two epsilon mutations survive |
| guide.settle.notify | Guide.swift:83-85 | FAILED, see E |
| guide.settle.track.never | Guide.swift:82-83 | HONOURED |
| guide.skiptake.source | nowhere | CO, unaddressed |
| guide.skiptake.target | Guide.swift:26; TokenTests.swift:60 | covered |
| guide.skiptake.retarget | Guide.swift:48; GuideSegmentTests.swift:11 | covered, mutation reddens |
| guide.skiptake.tokenize | Guide.swift:35 | VACUOUS, mutation survives |
| guide.skiptake.remove | Guide.swift:18-23 | vacuous, correct but untested |
| guide.initialize.reset | Guide.swift:20-21; GuideTests.swift:25 | covered, mutation reddens |
| guide.pass.single | absence of composition | vacuous by design |

`guide.space.scene` is claimed by commit `f42ca54` and is not in the change order's covered list. The work it names is required by `guide.rect.dirty` regardless. Noted, not raised.

## B. The target formula

`Adherence.weight` is `1 / (1 + (d/reach)^2)`, `Adherence.target` is `location + direction * (weight * distance)`. Frame 128x128, vertical path at x=64.5, point (24.5,64.5), field distance exactly 40, direction (1,0).

| reach | weight, by hand | target.x, by hand | target.x, from the code |
|---|---|---|---|
| 40 | 1/2 = 0.5 | 24.5 + 20 = 44.5 | 44.5 |
| 0.5, very low | 1/6401 = 0.000156226 | 24.5 + 0.0062490 = 24.506249 | 24.506248 |
| 181.019333, the Frame diagonal | one over 1.048828 = 0.9534451 | 24.5 + 38.13780 = 62.63780 | 62.637802 |
| 10000, far exceeding the Frame | one over 1.000016 = 0.999984 | 24.5 + 39.99936 = 64.49936 | 64.49936 |
| infinity | 1 | 64.5 | 64.5 |

Every derivation agrees with the code to the last digit Float carries. The falloff, the target displacement and the short settle are implemented as the design states.

The rewritten `guide.adherence.reach.full` at `Mobster.md:203-204` says the reach follows from the Frame extent and the epsilon. That number is `r >= d * sqrt(d - 1)`, from residual `= d^3 / (r^2 + d^2) <= 1`. For a 128x128 Frame with a worst case distance equal to the diagonal 181.0193 the required reach is 2428.76 scene units, 13.4 times the diagonal. At a reach equal to the diagonal the residual is 90.51 pixels; at ten times the diagonal it is still 1.79, over epsilon. Nothing in the package computes or asserts this.

## C. The segment invariant

**C1. CC, token.origin.** "A token stores the time origin of the segment in flight." `Guide.swift:64` writes `token.origin = time` on EVERY play, so origin is the last evaluation stamp. The segment ends at every play, not only at a field change as `token.segment` states. `TokenTests.swift:57` asserts `origin == 1` after a play at t=1 and so ratifies it.

Observable, reach infinity, field x=64.5, speed 10, point at (24.5,64.5):

- plays at t=1 then t=2, location 44.5
- plays at t=1, t=0, t=2, location 54.5
- play at t=2 alone, location 44.5

An intervening backward play rebases the clock to 0 and the next forward play travels 20 units for one second of elapsed time. `GuidePlayTests.swift:79` asserts only that the backward play does not move the point, not that origin is left alone.

Second consequence: a speed change mid segment applies only to the interval since the last play. Point at (0.5,64.5) toward 64.5, `play(10, t=1)` then `play(20, t=2)` gives 30.5; a segment model gives 40.5. The implemented behaviour is the one a slider wants. It is an adjudication for the principal, not a defect I am proposing a fix for.

**C2. The invariant holds where the design states it.** Verified against the built sources, not merely for a point that has not started or has already settled.

- Point caught mid travel: reach 40, target 44.5, `play(10, t=1)` leaves it at 34.5. A field change to x=0.5 at t=1 leaves location 34.5, sets origin 1, and resolves target 14.76125 from where the point ACTUALLY IS. Resolving from where it set out would have given 6.853. Hand check: d=34, weight 1/(1+(34/40)^2) = 0.580552, displacement 19.73877, 34.5 - 19.73877 = 14.76123.
- Two field changes in quick succession: change A to x=0.5 at t=1.0 gives target 14.76125, change B to x=100.5 at t=1.0000001 gives target 52.23002 and origin 1.0000001, location held at 34.5 through both. A subsequent `play(10, t=2)` lands at 44.5. The invariant survives back to back changes.
- Field change at the exact instant of a play: `play(10, t=1)` to 34.5, change to x=0.5 at t=1, `play(10, t=2)` lands at 24.5 with target 14.76125. Correct.

**C3. The surviving mutation and the strengthened test.** Confirmed. Dropping `token.origin = time` at `Guide.swift:49` reddens EXACTLY ONE test, `theNextSegmentRunsFromTheReanchoredLocation` at `GuideSegmentTests.swift:32`. It bites, and it is the sole thing that catches it.

Two other tests have the shape that let the mutation survive, both changing the field at the same instant as the last play, both therefore blind to the origin update:

- `GuideSettlementTests.swift:52`, `update(field: moved, time: 1000)` immediately after `play(speed: 10, time: 1000)`
- `GuideDeterminismTests.swift:29`, `update(field: field(at: 12.5), time: 1.25)` immediately after `play(speed: 9, time: 1.25)`

The determinism run therefore never exercises a field change at an instant distinct from the surrounding plays.

## D. Determinism

No wall clock and no drawn random state participate. grep across `Sources/Mobster` for `Date`, `CACurrentMediaTime`, `DispatchTime`, `mach_absolute`, `.now`, `random`, `arc4`, `drand`, `clock` returns nothing. Iteration is over the `membership` array at `Guide.swift:46` and `Guide.swift:59`, never over the `tokens` dictionary, so hash order does not enter. Replacing the membership walk in `play` with a walk of `tokens.keys` reddens `advanceIdentifiesThePointAndItsStroke`.

Across processes: a probe built from the library sources emits a bit exact hex float digest of 32 token locations after an initialize, two field changes and four plays. Four separate process invocations, one with a perturbed environment, produce byte identical output, md5 `72d3cd921435c84d3b3567f3cfc4b3f4`. The fixture cut's standard holds.

## E. Settlement

`guide.settle.track.never` is HONOURED. `Guide.swift:82-83` answers from `arrivals` and `pending`, counters accumulated inside the pass the play already takes. No settled flag is stored on the token or the Guide, and no second walk of the membership is taken.

**CO, guide.settle.notify.** The gate at `Guide.swift:83` is `arrivals > 0, pending == 0`, which requires at least one point to TRANSITION from unsettled to settled. Four cases where every point has settled and no listener is called:

1. Membership already at its target at tokenization. Point at (64.5,64.5) on the path, reach infinity, `play(10, t=1000)`: fires 0.
2. Empty membership: fires 0.
3. No field supplied. Tokens target their own location, so every point is settled: fires 0. A Guide that never receives a field never notifies at all.
4. The sharpest. Point at (63.5,64.5), target 64.5, distance exactly 1. `arrived` is computed before the move at `Guide.swift:62` and is already true at the epsilon boundary, so `arrivals` stays 0. The play moves the point a full pixel, returns one displacement and one dirty rect, the point ends on its target, and the listener is never called.

It cannot fire twice for one settlement: once every point is settled, later plays produce `arrivals == 0`. It fires again after a field change sends the points out and they resettle, which `GuideSettlementTests.swift:43` asserts and which the requirement licenses.

**CC, guide.settle.epsilon against guide.space.scene.** The requirement says "within one pixel". `Guide.swift:2` declares it in SCENE UNITS and `Guide.swift:112` compares a scene space length. `FieldGrid.swift:8` defines a texel as the Frame size over the texel counts, so the two coincide only at a unit texel. Every test uses a 128x128 Frame at resolution 128, texel 1x1, which is why the discrepancy never surfaces.

## F. The flagged decisions

The briefing names nine and lists seven.

1. **Constant speed rate, speed as the parameter.** CONSISTENT. `Guide.swift:54,100-109`. Matches the change order's instruction to implement the simplest honest rate and invent no character, and matches `guide.rate` deferring the rate to the harness.
2. **Clock origin required at tokenize, defaulted to zero at initialize.** CONSISTENT. I probed the hazard and it does not materialise: initialize at a defaulted origin of 0 followed by `update(field:)` at t=5000 and `play(1, t=5001)` advances one unit, not five thousand, because `Guide.swift:49` rebases origin. Same result whether the field arrives before or after the first play.
3. **The Guide takes a baked Field rather than baking one.** INCONSISTENT. It contradicts the change order's own shape sentence, "A Guide holds a Frame, a field baked from its guide paths", and it strands `guide.skiptake.source`.
4. **`Guide.init` requires an Adherence with no default.** CONSISTENT with `guide.adherence.curve`. `Adherence.swift:3` states the reason correctly.
5. **Listeners as closures rather than a protocol.** CONSISTENT with the change order constraint "No protocol declared with a conformer". No protocol is declared anywhere in the cut.
6. **`guide.play.end` read as any time past the last arrival.** INCONSISTENT, and it fails the requirement. See below.
7. **`guide.determinism.seed` has nothing to derive.** CONSISTENT. The requirement is conditional, "A seed required by the rate", and a constant rate requires none. Vacuous coverage, correctly so.

**F6, CO, guide.play.end.** "Playing to the end time settles every token in one call." Because origin is rebased at every play, travel is speed times the interval since the LAST PLAY, not since the segment start. Point at (0.5,64.5), target 127.5, distance 127:

- Fresh guide, `play(speed 1, time 1000)`, location 127.5, settled. This is the only case the suite tests, `GuidePlayTests.swift:31`.
- Same guide after 999 plays at speed 0.01 stepping t=1 to 999, location 10.490145. Then `play(speed 1, time 1000)`, location 11.490145, NOT settled.

There is no time value that settles every token in one call from an arbitrary state. A consumer that has been playing every frame cannot reach the end by naming a large time.

## Two further omissions

**CO, guide.skiptake.source.** "A stroke event on the source layer updates the field." No entry point takes a stroke event on the source layer. No commit in the range names the URI. The change order lists it as covered.

**CO, guide.initialize** (`Mobster.md`, not in the change order's list). "A Guide receives the Frame it operates within before any other workload is invoked." `update(field:time:)`, `tokenize(membership:time:)` and `play(speed:time:)` all run before `initialize` with no guard. Probed: `tokenize` before `initialize` created two tokens and resolved a real target of 44.5 against the supplied field while `guide.frame` was still nil. Compounding it, `Guide.frame` is WRITE ONLY: declared at `Guide.swift:6`, assigned at `Guide.swift:19`, never read anywhere in the type. The Field carries its own Frame at `Field.swift:3` and that is the one the reads use. The ordering the requirement states can be neither enforced nor observed.

**CC, guide.adherence.reach.least** (`Mobster.md:206-207`) against `guide.adherence.falloff`. "Only a point already at a path location is displaced." At reach 0 no point off the path moves, and a point ON the path is returned unchanged by the distance guard at `Adherence.swift:20`. Verified: `Adherence(reach: 0).target` for (64.5,64.5) returns 64.5. The distinguishing clause names an empty set of displacements at every reach. `AdherenceTests.swift:40` asserts the opposite of the requirement and is the correct behaviour.

## G. Test honesty

Twenty mutations run against a copy of the merged tree in scratchpad, baseline 141 tests green. Sixteen reddened, four survived.

Verified reddening, more than the four asked for:

| Mutation | Reddens |
|---|---|
| drop the reuse guard, Guide.swift:29 | existingTokenIsReused, newPointJoinsTheMembershipWithoutDisturbingTheRest |
| drop the square in the falloff, Adherence.swift:14 | weightIsOneOverOnePlusTheSquareOfDistanceOverReach:28, pointFarFromEveryPathSettlesShortOfIt |
| drop the distance factor, Adherence.swift:21 | pointFarFromEveryPathSettlesShortOfIt, fullReachSnapsOntoTheNearestPathLocation, and seven more |
| drop the clamp to remaining, Guide.swift:106 | playingToTheEndTimeSettlesEveryTokenInOneCall, steppingASegmentMatchesArrivingAtItInOneCall, settledTokenDirtiesNothing |
| drop the origin update, Guide.swift:49 | theNextSegmentRunsFromTheReanchoredLocation, and only that |
| drop the retarget, Guide.swift:48 | eleven tests |
| drop the arrivals gate, Guide.swift:83 | settlementDoesNotFireForAMembershipThatNeverMoved, settlementFiresOnceWhenTheLastPointArrives |
| drop `tokens = [:]`, Guide.swift:20 | initializeDiscardsEveryToken |
| collapsed reach yields full weight, Adherence.swift:12 | collapsedReachDisplacesNothing |
| displace away from the path, Adherence.swift:21 | nine tests |
| skip the last token in play | six tests |
| skip the last token in retarget | five tests |
| play walks tokens.keys not membership | advanceIdentifiesThePointAndItsStroke |
| a point that did not move still dirties | pointAtAPathLocationDoesNotMove, settledTokenDirtiesNothing, timeBeforeTheOriginAdvancesNothing |
| rect origin off the low corner, GuideRect.swift:15 | coveringSpansTwoLocationsInEitherOrder |
| rect collapses onto the destination, Guide.swift:78 | advanceCarriesARectPerPointAndTheirUnion |

`guide.rect.dirty` is not the weak point you expected. The rect assertions at `GuidePlayTests.swift:63-67` are on exact origin and size, not on a rect being returned. Collapsing the rect so it covers NOTHING THAT MOVED reddens. Moving its origin off the low corner reddens. Emitting a rect for a point that did not move reddens three tests. Verified independently: a diagonal move through `play` from (20.5,20.5) landing at (27.571068,27.571068) produces a rect at origin (20.5,20.5) size (7.071068,7.071068), exactly covering the run.

### The four survivors

1. **CO, guide.settle.epsilon, vacuous.** Changing `Guide.swift:3` from 1 to 0 leaves all 141 green. Changing it to 5 also leaves all 141 green. No test pins the epsilon and no test is decided by it: every settlement test uses a reach where the point lands exactly on its resolved target, so the comparison at `Guide.swift:112` is always `0 <= epsilon`. Missing test: a point stopping strictly between 0 and 1 of its target asserted settled, and one strictly beyond 1 asserted not settled.
2. **CO, guide.skiptake.tokenize, vacuous.** Replacing `Guide.swift:35` `target: target(for: sample.location)` with `target: sample.location`, so new data is tokenized and NOT evaluated against the field, leaves all 141 green. `TokenTests.swift:60` never calls `update(field:)` so the field is nil and both versions produce `target == location`. `TokenTests.swift:42` supplies a field but adds no new point. Missing test: `tokenize` with a new point while a field is present, asserting the new token's target against a hand computed falloff value.
3. Changing the epsilon to 5, as above.
4. **IDEA, potential gap.** `max(time - token.origin, 0)` at `Guide.swift:105` is dead. Removing the `max` leaves all 141 green, because a negative travel is already caught by `guard travel > 0` at `Guide.swift:107`. The comment at `Guide.swift:99` attributes the backward time behaviour to a guard that is not the one doing the work.

### What the thirteen do not cover

- No assertion at a large finite reach. Every reach in the suite is 0, 10, 20, 37, 40 or infinity. Infinity is the single value at which the falloff degenerates to weight exactly one, so the full adherence behaviour is asserted only where the arithmetic cannot fail. The reach the harness will actually supply, a large finite one, is never exercised. Compounding it, infinity is not reachable through the harness at all: grep for `Adherence` across `Sources` and `Harness` returns four hits, all inside `Guide.swift:11,14,15,96`. There is no dial to reach mapping and no user reachable configuration.
- No test of the epsilon value, as above.
- No test of `tokenize` against a live field, as above.
- No test of `guide.skiptake.remove`. Verified by probe that the behaviour is correct, a stroke redelivered with one of two points dropped leaves both tokens and membership `[1,2]` intact, but nothing asserts it.
- No test of settlement notification for a membership that was already settled at tokenization, which is the case that fails.
- No test of a field change at an instant distinct from the surrounding plays in either the determinism or the settlement suite.
- No test of `token.planar` or `token.authority.none`. Both are enforced by the shape of the type rather than asserted.

## H. Conventions

| Rule | Result |
|---|---|
| One type per file with filename matching | ONE VIOLATION. `GuideSettlementTests.swift:4` declares `private final class SettleCount` alongside `struct GuideSettlementTests` at line 8. |
| No protocol declared with a conformer | clean, no protocol declared in the cut |
| No extension block appended in the same file | clean, no `extension` in any file of the cut |
| Comments one physical line each, no hard wrapping | clean, no consecutive comment lines and no line over 200 characters |
| No hyphenated compound words | clean, grep for a lowercase hyphen lowercase pattern returns nothing across the cut's sources and tests |

## Unable to do

Nothing was blocked. `swift test` could not be run to completion on the `cycle/guide` worktree for the inherited reason recorded above; the merged develop checkout was used for the green run and for mutation testing, and the cut's files are identical between the two.
