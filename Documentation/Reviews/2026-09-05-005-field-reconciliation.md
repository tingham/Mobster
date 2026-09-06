# Cut 5 Field, reconciliation

Branch `cycle/field`, commits `3e018a6..30313b6`, worktree `/Users/tingham/Source/Repos/Mobster/.worktrees/field`.

Authorities: `Documentation/Design/Mobster.md` Field section, main checkout; `Documentation/Issues/005-field.md`.
Prior art read: `~/Source/References/metal-by-example-sample-code/objc/12-TextRendering/TextRendering/MBEFontAtlas.m:291-380`.

Design line numbers below are the main checkout as of this review. The Field section gained five URIs during the review, in response to findings sent as they were made: `field.bake.exterior`, `field.store.location.tolerance`, `field.tiebreak.stable`, `field.extent`, `field.empty`. Findings are reconciled against the current text.

## Build and test, run

```
swift build   Build complete! (0.19s)
swift test    Test run with 73 tests in 17 suites passed after 0.582 seconds.
```

All measurement below was performed against a full copy of the worktree in a scratch directory. The worktree itself was not modified and its suite is still green.

## A. Requirement coverage

| URI | Design | Implementation | Verdict |
|---|---|---|---|
| field.bake | 156 | `FieldBake.swift:19-40` | Covered |
| field.bake.exterior | 159 | absent | **CO 1** |
| field.store.location | 162 | `Field.swift:7`, no distance stored anywhere | Covered |
| field.store.location.tolerance | 165 | `FieldBake.swift:43-91` | Held on every interior configuration measured; breached only through CO 1 |
| field.read.distance | 168 | `Field.swift:16-20` | Covered |
| field.read.direction | 171 | `Field.swift:23-29` | Covered |
| field.gradient.never | 174 | `Field.swift` has no neighbour access | Satisfied by construction, **coverage vacuous** |
| field.unsigned | 177 | `Field.swift:19` square root, no sign computed | Satisfied by construction, **coverage vacuous** |
| field.tiebreak.center | 180 | `FieldBake.swift:113-122` | Covered, and correct in the general case, section D |
| field.tiebreak.stable | 183 | `FieldBake.swift:121` returns false | **CO 2** |
| field.extent | 186 | `FieldBake.swift:28`, `:32`, `:37` | Satisfied |
| field.empty | 189 | `Field.swift:33-35` vends a raster | **CO 3** |
| field.vend.grayscale | 192 | `Field.swift:32-53`, `FieldRaster.swift` | Covered |

The two vacuous entries are not defects. `field.gradient.never` and `field.unsigned` are negative requirements that the storage choice makes unstatable in code: there is nothing to difference and no sign to recover. No test asserts either, and no test can.

## CO 1 — field.bake.exterior (159)

A path location outside the Frame does not participate in the field.

`FieldBake.swift:60` admits a candidate only when the exact nearest point on the segment lies within one texel diagonal of a texel centre. `FieldBake.swift:51-54` clamps the seed's index range to the grid. A segment far enough outside the Frame therefore reaches no texel and is dropped.

Measured. Frame origin `(0,0)` size `(100,100)`, resolution 100, texel `(1,1)`, texel centres on half units. Two vertical paths, `x=-10` outside and `x=90` inside. Query `(5.5, 50.5)`.

| | nearest location | distance | direction |
|---|---|---|---|
| true | `(-10.0, 50.5)` | 15.5 | `(-1, 0)` |
| field | `(90.0, 50.5)` | 84.5 | `(+1, 0)` |

The direction is reversed. Under `guide.adherence.target` (Mobster.md:216) the point is displaced across the whole Frame away from the guide nearest it.

Not an edge case. `guide.source.map.absolute` (Mobster.md:64) states a source Frame differing from the target maps absolutely and is not fitted, so exterior source geometry is the designed behaviour of a layer source. And it fires on an in-repo preset without any layer source at all: `preset.frame.bounds` (Mobster.md:98) scales Golden Ratio to a minimum bounds *encompassing* the Frame while preserving its 1 to 1.618 proportions, so on a square Frame part of the spiral is necessarily outside it. `GoldenRatioPreset` in bounds mode, square Frame, resolution 128: 3992 of 16384 texels store a location more than one texel diagonal from the true nearest, worst error 102.14 scene units against a texel diagonal of 1.105.

### Partly outside is the same defect, not a second one

A segment crossing the boundary seeds interior texels exactly, because `FieldBake.swift:59` computes the nearest point over the *whole* segment and the index clamp only trims the part of the bounding box off the grid. It fails on exactly one class of texel: an interior texel whose true nearest lies on the exterior portion. Whether that class is empty is a geometric accident of the path.

| configuration | texels beyond the tolerance | worst location error |
|---|---|---|
| horizontal `(-60,50)` to `(40,50)`, crossing the left edge | 0 of 10000 | 0 |
| elbow `(50,40)`,`(-30,40)`,`(-30,90)`,`(50,90)`, vertical limb wholly outside | 0 of 10000 | 0 |
| diagonal `(-50,-50)` to `(50,150)`, entering at `(0,50)` leaving at `(25,100)` | 8898 of 10000 | 42.93 |

### The empty field is the same defect, not a second one

When no segment comes within a texel diagonal of any texel centre, the seed leaves every slot nil and `FieldBake.swift:32` returns the empty field. Confirmed with path `(-30,4)` to `(4,-30)`, wholly outside: `columns=100 rows=100 locations=[]`, every read infinity. Correcting `field.bake.exterior` removes this case; no separate remedy is required.

## CO 2 — field.tiebreak.stable (183)

Where neither candidate is nearer the Frame centre, the requirement is the lesser x, then the lesser y, and it is stated so that it survives a change to sweep order. `FieldBake.swift:121` states no rule: it returns false and the incumbent stands, so the winner is whichever side the sweep reached first.

It complies by accident on axis aligned medial lines, which is why nothing caught it. Frame `(0,0)` size `(100,100)`, resolution 101 so that a texel centre lands exactly on 50:

- verticals at `x=30` and `x=70`, medial texel centre `x=50`: stored `x` is 30.0. Complies. Forward sweep arrives from the left.
- horizontals at `y=30` and `y=70`, medial texel centre `y=50`: stored `y` is 30.0. Complies. Forward sweep arrives from above.

It fails on a diagonal medial line. Two single point paths at `(30,70)` and `(70,30)`, resolution 100. Both are 28.28 from the Frame centre, so `field.tiebreak.center` abstains and `field.tiebreak.stable` governs. Required answer `(30.0, 70.0)`. Sampled at texels `(30,30)`, `(40,40)`, `(50,50)`, `(60,60)`, `(70,70)`: every one stores `(70.0, 30.0)`. Supplying the two paths in the opposite order gives the identical wrong answer, which confirms the cause is sweep order and not input order.

The forward mask at `FieldBake.swift:10` reaches a medial texel from the neighbour above it, and above the line `y=x` the nearer dot is the greater x one.

At the read, texel `(0,0)` centre `(0.5,0.5)`: field direction `(0.9206, 0.3907)` where the rule requires `(0.3907, 0.9206)`. A 44 degree error at the correct distance.

Correction is one clause in `prefers()`: where both distances tie and both distances to the Frame centre tie, compare `candidate.x` then `candidate.y`, instead of returning false.

## CO 3 — field.empty (189)

A field holding no path location vends a grayscale. `Field.swift:33-35` returns a `FieldRaster` of the full `columns` by `rows` with every sample zero. Measured: no paths, Frame `(0,0)` size `(100,100)`, resolution 32, gives a 32 by 32 raster of 1024 samples whose distinct set is `[0]`. That is a solid black image of the correct dimensions, which is exactly the raster the requirement says cannot be told apart from a legitimate one.

The requirement's first sentence, that the field reports it holds none, is met only incidentally: `Field.locations` is a public `let`, so a consumer can read `isEmpty`. There is no named report.

## B. The departure from Grevera

Verdict: **correct diagnosis and correct remedy**. It is not a wrong remedy. But it does not rescue the case the implementer used to justify it, and that is recorded in section D rather than here.

### The diagnosis holds, provably

`MBEFontAtlas.m:344` admits a neighbour on `d(n) + w < d(cur)`, strict, with `w` of 1 or root 2. If the neighbour carries a point P with `|P - cur|` exactly equal to `d(cur)`, then by the triangle inequality `d(n) = |P - n| >= d(cur) - w`, so `d(n) + w >= d(cur)` and the guard always rejects. An equidistant candidate can never reach a tie break placed behind that bound.

The implementer understated the case. The same bound also rejects candidates that are *strictly* nearer, because `|P - cur| <= d(n) + w` makes the guard sufficient for improvement but not necessary. That is the documented error source in Dead Reckoning and it is the larger of the two defects. The change is better justified than its justification.

### The remedy is never worse, provably and by measurement

Every acceptance the chamfer bound makes, the exact comparison also makes, since `d(n) + w < d(cur)` implies `|P - cur| < d(cur)`. The exact comparison accepts a strict superset, and every extra acceptance strictly reduces the carried distance.

Both variants run off the identical seed, error counted per texel against a brute force reference, measured as excess distance:

| configuration | delivered wrong / worst excess | chamfer restored wrong / worst excess |
|---|---|---|
| Ruler preset, res 128, 16384 texels | 8726 / 0.077 | 13706 / 0.197 |
| Frame 200 by 35, res 64, 704 texels | 515 / 0.125 | 582 / 0.473 |
| diagonal, L, crossing pair, single point, two points, Columns preset | 0 / 0 | 0 / 0 |

### The cost

**Termination.** Unaffected. The chamfer bound is not a convergence criterion in a two sweep scheme; the sweeps are fixed and terminate unconditionally either way.

**Convergence to the true nearest.** No, and it was no before the change. The residual is the ruler figure above. Against the *location* bound that `field.store.location.tolerance` actually states, rather than the distance excess, the residual is zero on every interior configuration measured, so the promise the design now makes is kept.

**Complexity.** Unchanged, order `columns * rows` with eight neighbour visits. Constant factor materially worse. Because the field deliberately holds no distance, `prefers()` recomputes both sides with a square root on every neighbour visit (`FieldBake.swift:115-116`) and two more on a near tie (`:121`). That is at least eight square roots per texel per sweep where the prior art performs one float comparison and computes a hypot only on acceptance. Nothing in the design or the order constrains this, so it is not a finding, but `harness.timing` will see it.

## C. Correctness of the field, by arithmetic

Every case below is a configuration the delivered tests do not cover. Frame origin `(0,0)` size `(100,100)`, resolution 100, so texels are `(1,1)` and texel centres lie on half units, which makes the arithmetic exact rather than nearby.

### C1, an L shaped path

Path `(10,30)`, `(70,30)`, `(70,90)`. Segment A is `y=30` for `x` in `[10,70]`. Segment B is `x=70` for `y` in `[30,90]`.

Query `(40.5, 60.5)`. Foot on A is `(40.5, 30)`, distance `60.5 - 30 = 30.5`. Foot on B is `(70, 60.5)`, distance `70 - 40.5 = 29.5`. Nearest is B. Expect `(70, 60.5)`, 29.5, `(1, 0)`.
Field: `(70.0, 60.5)`, 29.5, `(1.0, 0.0)`. Match.

Query `(30.5, 50.5)`. A gives `(30.5, 30)` at 20.5. B gives `(70, 50.5)` at 39.5. Expect `(30.5, 30)`, 20.5, `(0, -1)`.
Field: `(30.5, 30.0)`, 20.5, `(0.0, -1.0)`. Match.

Query `(5.5, 20.5)`, outside the L on the open side, so the answer is a clamped endpoint. The perpendicular foot on A is `x = 5.5`, outside `[10,70]`, clamped to the vertex `(10,30)`. Distance root of `4.5^2 + 9.5^2` = root of `110.5` = 10.51190. Direction `(4.5, 9.5) / 10.51190` = `(0.428086, 0.903738)`.
Field: `(10.0, 30.0)`, 10.511898, `(0.42808634, 0.90373784)`. Match.

Query `(95.5, 95.5)`, beyond the far end of B. Foot on A clamps to `(70,30)` at root of `25.5^2 + 65.5^2` = 70.288. Foot on B clamps to the endpoint `(70,90)` at root of `25.5^2 + 5.5^2` = root of `680.5` = 26.0864. Direction `(-25.5, -5.5) / 26.0864` = `(-0.97752, -0.21084)`.
Field: `(70.0, 90.0)`, 26.086395, `(-0.977521, -0.21083787)`. Match.

### C2, a crossing pair

Two paths, horizontal `y=60` for `x` in `[0,100]` and vertical `x=25` for `y` in `[0,100]`, crossing at `(25,60)`.

| query | nearest by hand | distance | direction | field |
|---|---|---|---|---|
| `(70.5, 20.5)` | `(70.5, 60)` on the horizontal, 39.5, against 45.5 on the vertical | 39.5 | `(0, 1)` | `(70.5, 60.0)`, 39.5, `(0,1)`. Match |
| `(10.5, 10.5)` | `(25, 10.5)` on the vertical, 14.5, against 49.5 on the horizontal | 14.5 | `(1, 0)` | `(25.0, 10.5)`, 14.5, `(1,0)`. Match |
| `(80.5, 90.5)` | `(80.5, 60)`, 30.5, against 55.5 | 30.5 | `(0, -1)` | `(80.5, 60.0)`, 30.5, `(0,-1)`. Match |
| `(99.5, 0.5)` | `(99.5, 60)`, 59.5, against 74.5 | 59.5 | `(0, 1)` | `(99.5, 60.0)`, 59.5, `(0,1)`. Match |

The `(99.5, 0.5)` case is the far corner of the Frame from both paths, the longest propagation chain in the grid, and it is exact.

### C3, the location bound across a wider sweep

Location error against brute force, ties discarded because on a tie both candidates are true nearest locations, threshold one texel diagonal:

| configuration | resolution | texels beyond the bound |
|---|---|---|
| single diagonal `(0,0)` to `(100,100)` | 100 | 0 |
| two verticals at 30 and 70 | 100 | 0 |
| Columns preset, count 4 gutter 0.05 | 128 | 0 |
| Ruler preset, centre `(0.4,0.6)`, 17 and 212 degrees, distance 0.08 | 128 | 0 |
| Thirds preset | 128 | 0 |
| two single point paths at `(30,70)` and `(70,30)` | 100 | 0 |
| two near parallel converging lines | 128 | 0 |
| Curve preset, 32 segments, tight control | 128 | 0 |
| Golden Ratio in bounds mode | 128 | **3992**, worst 102.14 |
| segment `(-50,-50)` to `(50,150)` | 100 | **8898**, worst 42.93 |

Only the last two, both instances of CO 1, breach it. The propagation itself is sound within the region it can see.

## D. The tie break

**It works in general, not only in the mirrored pair the tests assert.** Constructed with no symmetry: path P horizontal at `y=10`, path Q vertical at `x=12`, Frame `(0,0)` size `(100,100)`, resolution 100. The locus of equidistance is `x = y + 2`. Query texel centre `(32.5, 30.5)`, which lies on it. Candidates `(32.5, 10)` and `(12, 30.5)`, both at 20.5 from the query. To the Frame centre `(50,50)`: root of `17.5^2 + 40^2` = 43.66 against root of `38^2 + 19.5^2` = 42.71. Correct resolution is `(12, 30.5)`. The field returns `(12.0, 30.5)`, distance 20.5, direction `(-1, 0)`, and returns the same with the paths supplied in the opposite order.

**"Toward the centre" is evaluated as the candidate path location being nearer the Frame centre**, `FieldBake.swift:120-121`, not as the reported direction pointing centreward. That is the natural reading of `field.tiebreak.center` and the delivered tests agree with it. No finding.

**A candidate that is itself at the Frame centre is stable**, and for the right reason: `length(incumbent - middle)` is zero, so no candidate can satisfy the strict less than minus tolerance and displace it; conversely a Frame centre candidate displaces any incumbent at equal query distance. Verified in both path orders, stored `(50.0, 50.0)` either way.

**Two candidates equidistant from the centre as well as from the query is CO 2 above.** It is not exotic. `ColumnsPreset(count: 4, gutter: 0.05)` on a Frame of `(0,0)` size `(100,100)` plots at 21.25, 26.25, 47.5, 52.5, 73.75, 78.75; the medial line between 47.5 and 52.5 sits at `x = 50.0`, the Frame centre, so both candidates are 2.5 from it. That is precisely the case the implementer cited to justify dropping the chamfer bound, and it is the one case the delivered tie break declines to decide.

At the resolutions the tests use, the degenerate case never lands on a texel centre. A 100 unit Frame at resolution 100 puts centres on half units, so `x=50` falls between columns 49 and 50 and one side is genuinely nearer; the Columns preset at 128 likewise. It only appears at odd texel counts. Whatever the harness derives for resolution decides whether the bias is visible at all.

## E. The four unstated decisions

**E1, resolution counts texels across the wider axis with the other axis keeping texels square.** Wider axis: consistent, `FieldBake.swift:20`, `:25-26`. The square claim: **inconsistent with its own stated form**. `FieldBake.swift:26` rounds, so the texel is square only when the aspect ratio times the resolution is an integer. Frame `(100,35)` at resolution 10 gives columns 10, rows 4, texel `(10.0, 8.75)`. No requirement demands square texels, so nothing is failed; the comment at `FieldBake.swift:6` and the test name at `FieldBakeTests.swift:7` both assert something the code does not do. See section G.

**E2, the grayscale normalizes against the greatest distance the field itself carries.** `Field.swift:45`. **Consistent** with `field.vend.grayscale`, which calls the rasterization an approximation and does not name a ceiling. Normalizing against the field rather than against an invented constant is the defensible reading. The empty case is CO 3.

**E3, a read outside the Frame clamps to the nearest texel.** `Field.swift:67-68`. **Consistent** with the literal wording of `field.read.distance`, which scopes the answer to "the nearest path location the field holds", and clamping does select the nearest texel. `field.bake.exterior` speaks only of a query *inside* the Frame and does not govern this. Note the cost so it is a decision and not an accident: query `(1000, 50.5)` against the main diagonal returns stored `(75,75)` and distance 925.32, where the true nearest on the path is the endpoint `(100,100)` at 901.36. Exact against what the field holds, 23.96 units off the geometry. **Unaddressed by any requirement, and undefended by any test** — see section F.

**E4, an empty field reads infinite distance and zero direction.** `Field.swift:17` and `:24`. **Consistent**, and it is one plausible way to satisfy the first sentence of `field.empty`. Asserted for distance at `FieldBakeTests.swift:47`; direction on an empty field is untested. The grayscale half of `field.empty` is CO 3.

## F. Test honesty

I could not find the implementer's list of six behaviours. It is not in the commit messages on `3e018a6..30313b6`, not in `005-field.md`, not in `Documentation`. The only claim in the delivered artefacts is the line in `30313b6`: "Each assertion was watched to fail against a deliberately broken bake before it was committed." I verified that claim against the assertions instead, by breaking twelve behaviours in a scratch copy.

### The claim holds

Six representative breaks, each reverted before the next:

| break | test that went red |
|---|---|
| Tie break clause removed, `FieldBake.swift:121` returns false | `theMirrorOfThatCaseResolvesTowardTheCentreAsWell` only |
| Tie break resolves toward the Frame origin, `FieldBake.swift:120` | `theMirrorOfThatCaseResolvesTowardTheCentreAsWell` only |
| `direction` returns the unnormalized run, `Field.swift:28` | `directionAtALocationOffThePathPointsAtTheNearestPathLocation` and both tie break tests |
| Grayscale normalizes against a constant, `Field.swift:45` | `aPathIsWhiteAndTheFurthestTexelIsBlack`, `intensityFallsWithDistance` |
| Resolution counts across the narrower axis, `FieldBake.swift:20` | `resolutionCountsTexelsAcrossTheWiderAxisAndKeepsATexelSquare` |
| Read snaps to the nearest texel centre, `Field.swift:67-68` | five tests |

The first two reddening exactly one of the two tie break tests is what `30313b6` predicted when it said an implementation that always keeps the first candidate fails one of the two. The pair does bite as claimed.

### What the suite does not defend

Six breaks that reddened nothing.

1. **Distance and direction measured from the texel centre instead of the query location.** `field.read.distance` says the length from *that location*. I replaced the query with its texel centre in both reads and all 73 tests stayed green. The reason is stated in the suite's own comment at `FieldReadTests.swift:5`: every read test queries an exact texel centre, so the two are indistinguishable. The error this hides is up to half a texel diagonal on every read, the same order as `guide.settle.epsilon`.

2. **The clamp for a read outside the Frame**, `Field.swift:67-68`. Replaced with a modulo wrap. Nothing red.

3. **The Frame origin in the tie break**, `FieldBake.swift:120`. Changed `frame.origin + frame.size / 2` to `frame.size / 2`. Nothing red, because both tie break tests use a Frame at origin `(0,0)`.

4. **The Frame origin in the read**, `Field.swift:66`. Dropped the subtraction of `frame.origin`. Nothing red, because every test calling `distance(at:)` or `direction(at:)` uses a Frame at origin `(0,0)`. `guide.frame.position` (Mobster.md:40) says the Frame carries a position in scene space; the read path is asserted only at the origin. `FieldBakeTests` does use `(-30,15)` but reads `field.locations` directly.

5. **`field.gradient.never`.** Nothing to break. Vacuous by nature, not by omission.

6. **`field.unsigned`.** Nothing to break. Vacuous by nature, not by omission.

Two further behaviours have no test at all and are now failing URIs: `field.bake.exterior` and `field.empty`. `field.store.location.tolerance` has no test either and is the natural assertion to add once CO 1 is corrected.

One weak assertion rather than a missing one. `everyStoredLocationSitsOnAPath`, `FieldBakeTests.swift:27-41`, checks that each stored location lies *on* the path, not that it is the *nearest*. A field storing the same single path point in every texel would pass it.

A break that reddened nothing for a good reason, recorded so it is not mistaken for a hole: removing the seed reach guard at `FieldBake.swift:60`, which turns the bake into exact brute force, leaves the suite green. That is a strictly better field and the suite is right not to object.

## G. Conventions

Clean, examined. One type per file with the filename matching, across `Field.swift`, `FieldBake.swift`, `FieldRaster.swift` and all four test files. No protocol declared anywhere in the cut. No extension block anywhere. Every comment is one physical line with no hard wrapping. No hyphenated or stroke joined compound word in any of the seven files.

**`FieldBake.swift:6` states something the code does not do.** "The other axis takes the count that keeps a texel square." `FieldBake.swift:26` rounds. Frame `(100,35)` at resolution 10 gives texel `(10.0, 8.75)`. The test named for it, `FieldBakeTests.swift:7`, asserts only counts at `:13-15` and never a texel dimension, on a Frame whose ratio is exact. The second half of the test's own name is asserted nowhere.

**`FieldBake.swift:1` names the wrong prior art.** "The propagation is the dead reckoning transform of Grevera 2004." The chamfer bound is the defining feature of dead reckoning and `FieldBake.swift:76` records dropping it. What remains, an exact seed followed by two vector propagation sweeps compared on true distance, is a Danielsson style vector distance transform. This matters because the next reader goes to `MBEFontAtlas.m` expecting to find this algorithm.

**`FieldTiebreakTests.swift:4` describes a case the tests avoid.** "which is the medial line a Columns preset runs down the middle of every column." The Columns medial line at `x = 50` is the symmetric case where the assertion these tests make is undecided. See CO 2 and section D.

`FieldBake.swift:76` is true but understates its own reason; see section B. Not a violation.

## IDEA

**IDEA, potential gap.** The texel grid mapping is written three times: `Field.swift:56-59`, `Field.swift:65-68` inline in the read, and `FieldBake.swift:139-141`. They can drift. Changing `Field.center` to use the texel corner instead of its centre reddens only `aPathIsWhiteAndTheFurthestTexelIsBlack`, because the read does not go through it.

**IDEA, potential gap.** `FieldBake.swift:37` silently returns an empty field if any texel is left unfilled after the sweeps. That converts an internal inconsistency into the same silent nothing `field.empty` was written against, and it is a second route to it beyond `:32`.

**IDEA, potential gap.** A Frame with a zero extent on one axis traps. `FieldBake.swift:21` guards the wider span but not the narrower one, so a Frame of size `(100, 0)` at resolution 10 gives rows 1 and a texel `y` of 0, and `FieldBake.swift:144` executes `Int` of infinity: "Float value cannot be converted to Int because it is either infinite or NaN". No requirement names a degenerate Frame. The code already decided such a Frame should yield an empty field rather than trap, and handled only one of the two ways a Frame can be degenerate.

**IDEA, enhancement.** `Field`'s public init accepts any `locations` array without checking it against `columns * rows`. `Field(frame:columns:100, rows:100, locations:[])` is constructible and reads infinity everywhere, which is CO 3's symptom reachable without the bake.

## Not found

No CE. Nothing in the cut is work no requirement asks for.

No CC. The two candidates I tested do not conflict: `field.store.location.tolerance` and `field.tiebreak.center` do not disagree, because on an exact tie both candidates are true nearest locations and the tolerance is not engaged.
