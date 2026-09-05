# Reconciliation: Cut 3, Presets

Branch `cycle/foundation`. Commits `3b869a9..650e720`, read inclusive of `3b869a9` — the exclusive range contains only the test commit and no implementation. Worktree `/Users/tingham/Source/Repos/Mobster/.worktrees/foundation`.

Authorities: `/Users/tingham/Source/Repos/Mobster/Documentation/Design/Mobster.md` (Presets section), then `/Users/tingham/Source/Repos/Mobster/Documentation/Issues/003-presets.md`.

Both authorities were amended during this review, in part in response to interim findings. **Every URI and line number below is the amended file.** This report is reconciled against them and does not argue with them. Findings I raised that the amendments closed are listed at the end so the record is complete, but they are not open.

## Build and test, run by me

The worktree carried uncommitted edits to four cut 1 source files and three cut 1 test files while I worked. To keep the result attributable to the range I cloned the repository into a scratch directory and checked out `650e720` clean.

```
swift build   Build complete! (14.34s)   no warnings
swift test    Test run with 51 tests in 13 suites passed after 0.012 seconds
```

Green. Green against the requirements as they stood when the cut was written, not as they stand now.

## A. Requirement coverage

| URI | Where | Verdict |
|---|---|---|
| preset.storage.static (82) | `GoldenRatioPreset.swift:8`, `PresetResource.swift:9-19`, `Sources/Mobster/Resources/GoldenRatio.json`, `Package.swift:16` | Satisfied as to storage form. See CC 1 |
| preset.storage.generated (85) | `ThirdsPreset.swift`, `ColumnsPreset.swift`, `RowsPreset.swift`, `RulerPreset.swift`, `CurvePreset.swift` | Satisfied |
| preset.frame.mode (88) | `paths(in:mode:)` on all six presets | **CO 1** |
| preset.frame.aspect (91) | `PresetPlotMode.swift:4`, `PresetProjection.swift:9-11` | Satisfied. Assignment determined correct, section C1 |
| preset.frame.bounds (94) | `PresetPlotMode.swift:6`, `PresetProjection.swift:12-16` | Satisfied |
| preset.frame.bounds.center (97) | `PresetProjection.swift:15` | Satisfied |
| preset.frame.mode.aspect (100) | `ThirdsPreset.swift:7`, `ColumnsPreset.swift:14`, `RowsPreset.swift:14`, `RulerPreset.swift:19`, `CurvePreset.swift:25` | **CO 2** |
| preset.frame.mode.bounds (103) | `GoldenRatioPreset.swift:7` | **CO 3** |
| preset.goldenRatio (106) | `GoldenRatioPreset.swift:7-12`; JSON verified as 289 locations spanning exactly 0..1.618033989 by 0..1 | Satisfied |
| preset.thirds (109) | `ThirdsPreset.swift:9-18` | Satisfied in aspect mode |
| preset.columns (112) | `ColumnsPreset.swift:14-21` | Satisfied |
| preset.rows (115) | `RowsPreset.swift:14-21` | Satisfied |
| preset.gutter.band (118) | `PresetGutter.swift:7-17` | Satisfied. Verified by arithmetic, section B |
| preset.gutter.fraction (121) | `ColumnsPreset.swift:16`, `RowsPreset.swift:16` | Satisfied in aspect mode |
| preset.ruler (124) | `PresetChord.swift:26-32` | Satisfied in aspect mode |
| preset.ruler.center (127) | `RulerPreset.swift:6`, `CurvePreset.swift:6` | Satisfied |
| preset.ruler.degrees (130) | `PresetChord.swift:27-28` with `PresetProjection.swift:20` | Satisfied |
| preset.ruler.line (133) | `RulerPreset.swift:22-24` | Satisfied |
| preset.ruler.pair (136) | `RulerPreset.swift:24`, `CurvePreset.swift:34` | Satisfied as to count and sidedness |
| preset.ruler.pair.cross (139) | `PresetChord.swift:21-24` | **CO 4** |
| preset.curve (142) | `CurvePreset.swift:25-40` | Structure satisfied. "The interpreted spline" is VACUOUS. **CC 2** |

Vacuous coverage, stated plainly: `preset.curve`'s "the interpreted spline" is covered by a quadratic Bezier the implementer wrote. `path.interpret` (Mobster.md:68) is cut 2 and does not exist. There is nothing in this cut that is an interpretation.

Several rows read "satisfied in aspect mode". That is not a hedge. Under `preset.frame.mode.aspect` those presets have no other mode, so the qualification will disappear when CO 1 and CO 2 are addressed. It is recorded because today the code will happily plot them the other way.

## B. The gutter, checked by arithmetic

Derived by hand from `preset.gutter.band` before reading the implementation.

Four columns, three interior gutters, gutter width `g`, extent 1. Column width `d` satisfies `4d + 3g = 1`, so `d = (1 - 3g)/4`. The six edges are

```
d, d+g, 2d+g, 2d+2g, 3d+2g, 3d+3g
```

Six positions, all interior, none at 0 or 1.

`PresetGutter.swift:10` sets `division = (extent - Float(count-1)*gutter)/Float(count)`, which is `d`. `PresetGutter.swift:13-16` emits `Float(index)*stride + division` and that plus `gutter`, with `stride = division + gutter`. Expanding index 0, 1, 2 reproduces the six above exactly.

Evaluated in float32, aspect mode, 100 wide Frame:

| gutter | division | scene x |
|---|---|---|
| 0.05 | 0.2125 | 21.25, 26.25, 47.5, 52.5, 73.75, 78.75 |
| 0.10 | 0.1750 | 17.5, 27.5, 45.0, 55.0, 72.5, 82.5 |

At 0.05: four columns of 21.25 plus three gutters of 5 sums to 100.0 exactly.

**Result: correct.** Six distinct line positions for a count of four with a nonzero gutter. Two edges per interior gutter, separated by exactly the gutter width. No line at either outer Frame edge, which is what `preset.gutter.band` implies by naming interior gutters only. This is where a reader counting on screen will expect them.

`preset.gutter.fraction` (121) is also satisfied in aspect mode. `ColumnsPreset.swift:16` passes `extent = designSize.x = 1` and the gutter reaches scene units through `scale.x = frame.size.x`, so 0.05 on a 100 wide Frame is 5 units, five percent of the axis it divides. `RowsPreset.swift:16` likewise on y.

## C. The five judgement calls

**C1. Plot mode assignment. CONSISTENT — correctly assigned, not inverted.**

Determined rather than accepted. The competing reading is that "consistent to the aspect ratio" means the preset preserves its OWN aspect, that is, a uniform scale. That reading collapses: under it neither mode distorts, because `preset.frame.bounds` is uniform by construction. `Prose.md:42` writes "the scaled (and potentially distorted) paths". The parenthetical requires a referent. Only one assignment supplies one — the mode that stretches per axis and adopts the Frame's aspect. That is `PresetPlotMode.aspect` at `PresetProjection.swift:9-11`.

`preset.frame.bounds` is independently correct. `PresetProjection.swift:13` uses `cover = max(frame.size.x/designSize.x, frame.size.y/designSize.y)`, the least uniform scale whose result contains the Frame on both axes. Confirmed at `PresetProjectionTests.swift:32` against an independently derived literal.

The two mechanisms are right. Which preset gets which is now fixed by `preset.frame.mode.aspect` and `preset.frame.mode.bounds`, and that is CO 2 and CO 3.

**C2. Three paths, base plus pair. CONSISTENT.**

`preset.ruler.line` (133) asserts the line exists and crosses. `preset.ruler.pair` (136) creates "a parallel line at that offset on each side of the line" — the line is the referent, so it survives. Three paths is correct. `RulerPreset.swift:24`, `CurvePreset.swift:34`.

Wrinkle, no requirement failed: at distance zero all three coincide exactly, asserted at `RulerPresetTests.swift:34-40`. Three identical paths vend into a field bake as three. No requirement names a threshold.

**C3. The offset pair falls short. INCONSISTENT.**

Unresolvable when I raised it; ruled on now by `preset.ruler.pair.cross` (139). It is CO 4, and it does not depend on the mode.

The arithmetic that settled it. RulerPreset, center (0.5, 0.5), degrees 0 and 90, distance 0.1, Frame origin (0,0) size (100,100), aspect mode. `PresetChord.edgeLocation` gives start (1.0, 0.5) on the right edge, end (0.5, 1.0) on the top edge. run = (-0.5, 0.5), length 0.70711, normal x and y both minus 0.70711. `PresetChord.offset` translates the whole segment.

```
paths[1]  scene (92.93, 42.93) to (42.93, 92.93)    both endpoints INSIDE the Frame
paths[2]  scene (107.07, 57.07) to (57.07, 107.07)  both endpoints outside
```

One parallel sits wholly inside and touches no edge; its twin sits wholly outside. `paths[0]` does cross, satisfying `preset.ruler.line`.

**C4. Quadratic Bezier standing in for the interpreted spline. INCONSISTENT.** CC 2.

**C5. Angle convention. CONSISTENT with the convention now named.**

`preset.ruler.degrees` (130) reads: a degree of zero points along positive x within the Frame; increasing degrees rotate toward positive y. `PresetChord.swift:27-28` computes `direction = (cos(radians), sin(radians))`, giving (1, 0) at zero and (0, 1) at ninety. `PresetProjection.swift:20` scales both axes positively, so positive design y is positive scene y. The implementation matches the named convention, and the check needs no knowledge of which way the consumer's screen points.

The convention was unnamed when the implementer chose it. It chose correctly.

## D. Magnitudes

I could not locate the implementer's stated list of five. It is not in the commit message of `3b869a9` or `650e720` and there is no handoff note under `Documentation/`. I swept every constant in the cut instead.

Structural, correctly not a parameter:

1. `designSize = SIMD2(1, 1)` at `ColumnsPreset.swift:3`, `RowsPreset.swift:3`, `ThirdsPreset.swift:3`, `RulerPreset.swift:3`, `CurvePreset.swift:3`. The zero to one identity named by `guide.space.normalize` (Mobster.md:49), reversed before return. A dial here has no observable effect because `PresetProjection` divides by it.
2. `fractions [1/3, 2/3]` at `ThirdsPreset.swift:9`. `preset.thirds` says three columns and three rows. A dial here makes it a different preset.
3. The 1.618033989 design width in `GoldenRatio.json`. `preset.goldenRatio` says "the standard ratio" and `preset.frame.mode.bounds` says the proportions ARE the requirement.
4. `greatestFiniteMagnitude` at `PresetChord.swift:38`, the sentinel for an axis the ray does not travel along. A guard, not a magnitude.
5. The zero normal at `PresetChord.swift:17` where the two degrees collapse. A degenerate case guard.
6. Quadratic degree at `CurvePreset.swift:37-40`. `preset.curve` names "a location", singular, which fixes the degree at two. Structural given the requirement, and the same code CC 2 objects to.

A dial denied: the Golden Ratio arc count and sample density only. CC 1.

No other denied dial found. Every tunable quantity the requirements name is exposed: `count` and `gutter` on Columns and Rows; `center`, two degrees and `distance` on Ruler; the same plus `control` and `resolution` on Curve.

**Direct answer on `preset.storage.static`.** It does not foreclose tuning the arc count or the sample density. It fixes the STORAGE FORM of a preset whose geometry is fixed. It names neither quantity. The implementer read a magnitude decision out of a storage requirement. `CurvePreset.swift:14` exposes `resolution` — the same quantity, sampling density — as a dial, and no requirement distinguishes the two presets in that respect.

## E. Test honesty

Tests that would pass against a wrong implementation, worst first.

1. `GoldenRatioPresetTests.swift:13-21`, `aspectPlottingFillsTheFrame`. **A test that passes only against an implementation violating a requirement is worse than a missing test, because it actively defends the defect.** It asserts that on a 300x200 Frame the spiral spans exactly x 10 to 310 and y 20 to 220 — the phi rectangle stretched to three by two. `preset.frame.mode.bounds` (103) says the proportions may not be distorted. This test asserts the distortion, so a correct implementation fails it and the suite will read as a regression. It has to be deleted, not adjusted.

   This is the second instance of the same shape in this cut. Item 2 asserts a tautology; item 1 asserts a violation. Both survived a green suite, and a green suite is the only signal the acceptance clause at `003-presets.md:35` reads. Two tests in one cut that cannot report a defect, one of which will report a correction as a failure, is a pattern rather than an oversight.
2. `PresetDeterminismTests.swift:19-20`. `#expect(plot(frame, .aspect) == plot(frame, .aspect))` invokes a pure Swift struct method twice, in one process, with identical arguments, and compares the result to itself. No implementation of these types, correct or wrong, can fail it. `003-presets.md:31` is untested. Labelled CO 5.
3. `PresetGutterTests.swift:21` recomputes `division = (1 - Float(count - 1) * gutter) / Float(count)`, character for character the formula at `PresetGutter.swift:10`, and asserts the implementation agrees at lines 23-24. It tests the arithmetic against a copy of itself. A wrong formula fails this only if the test author copied it wrong. `PresetGutterTests.swift:9-15` by contrast uses literals 0.4 and 0.6 and is honest.
4. Nothing anywhere asserts the six literal edge positions for a count of four. `ColumnsPresetTests.swift:33-40` checks each pair is five apart; `:42-49` checks the strides match; `:25-31` checks ascent and containment. All three are translation invariant. Six edges shifted bodily to 31.25, 36.25, 57.5, 62.5, 83.75, 88.75 pass all three, and that is exactly the failure visible by counting on screen. The missing assertion is `positions[0] == 21.25`.
5. `RulerPresetTests.swift:22-32` and `CurvePresetTests.swift:42-48` check the pair is ten units either side of the base at one sample. Both pass against the translation `preset.ruler.pair.cross` forbids, because a translated pair and a cast pair agree at the midpoint. Neither test asks where the parallel ENDS, which is the whole content of that requirement.
6. `PresetFrameShapeTests.swift:12-14` and `:21-23` assert non empty, at least two locations, finite. A preset returning a constant regardless of the Frame passes both the wide and the tall case. Neither test compares the wide result to the tall result.
7. `GoldenRatioPresetTests.swift:33-40` measures the bounding box aspect and finds 1.618034. That value comes from `size` in the JSON and is preserved by `PresetProjection` in bounds mode. The test verifies the projection, not the spiral. Nothing distinguishes the 289 location phi spiral from any path touching all four sides of the design rectangle; `:9-10` only asserts one path of more than a hundred locations.
8. `PresetDeterminismTests.swift:28` asserts the two modes differ on a 640x480 Frame. Any bounds implementation that is not the aspect stretch passes. A smoke test. The real check is `PresetProjectionTests.swift:32`, which uses an independently derived literal and is sound.
9. No test exercises a gutter large enough to invert the layout, a negative gutter, a negative resolution, or a Frame with a zero dimension.

Structural note on the suite. `PresetDeterminismTests.swift:5-12` builds a table of six plotters each taking a mode, and `PresetFrameShapeTests.swift:8` and `:17` fan it across both modes. Twenty four of the fifty one passing cases assert behaviour `preset.frame.mode` now forbids. The table is the shape CO 1 will have to be corrected through.

## F. Conventions

Clean: one type per file with the filename matching, all eleven new source files. No protocol declared. No extension block. Every comment in the cut is a single physical line with no hard wrapping. No hyphenated, em dashed, en dashed or stroke separated compound token in any comment in the cut.

One item. `ColumnsPreset.swift:6` and `RowsPreset.swift:6` read "A fraction of the design width, so a gutter tracks the Frame under either plot mode." The clause after "so" is the whole value of the comment and it is false — under bounds the gutter tracks `cover`, which is the longer Frame axis. It is also moot, because `preset.frame.mode.aspect` leaves Columns and Rows no other mode. The comment states a reason that is both wrong and about a situation that will not exist.

## Findings

CO 1, CO 2 and CO 3 are **BLOCKED ON THE PRINCIPAL**. They are recorded as known and deliberately uncorrected, not as open work awaiting an implementer. Two reasons. Removing the mode parameter changes six public signatures that a macOS harness on branch `cycle/harness` has already been built against. And the principal holds two rulings that determine the final shape: whether bounds mode survives at all once Golden Ratio is its only user, and whether Curve belongs in aspect given that a curve's tension is a shape property rather than a Frame relative one. Correcting the signatures before those rulings would be work done twice.

CO 4, CO 5 and the section E and F items are **ORDERED**. A correction batch is landing on `cycle/foundation` covering `preset.ruler.pair.cross`, the determinism test, the missing literal edge positions, the gutter test that recomputes its own formula, and the false comment on Columns and Rows. None of it touches a signature. This report describes the cut as I found it at `650e720` and does not reconcile against that batch; the items below are ordered, not verified.

**CO 1 — `preset.frame.mode` (Mobster.md:88). BLOCKED ON THE PRINCIPAL.**
"The mode is a property of the preset and not a parameter of the request." All six presets declare `paths(in frame: Frame, mode: PresetPlotMode)` and take it from the caller: `GoldenRatioPreset.swift:7`, `ThirdsPreset.swift:7`, `ColumnsPreset.swift:14`, `RowsPreset.swift:14`, `RulerPreset.swift:19`, `CurvePreset.swift:25`. `PresetPlotMode` is public for this reason. `003-presets.md:20` says the same thing.

**CO 2 — `preset.frame.mode.aspect` (Mobster.md:100). BLOCKED ON THE PRINCIPAL.**
"Thirds, Columns, Rows, Ruler and Curve plot in aspect mode." All five accept bounds and behave under it. Concretely, in bounds mode on a 1920x1080 Frame, `cover = 1920` and `translation.y = -420`, so Thirds puts its horizontal lines at 20.4 and 79.6 percent of the Frame height rather than at a third and two thirds; Columns and Rows scale the gutter by `cover` rather than by the axis it divides, breaking `preset.gutter.fraction`; and Ruler derives its locations on the edge of a rectangle larger than the Frame, breaking `preset.ruler`, so on a 200x100 Frame a degree of 90 from centre lands at scene (100, 150), fifty units past the Frame's top edge. None of these are separate defects. They are what CO 2 costs.

**CO 3 — `preset.frame.mode.bounds` (Mobster.md:103). BLOCKED ON THE PRINCIPAL.**
"Golden Ratio plots in bounds mode. Its proportions are the requirement and may not be distorted." `GoldenRatioPreset.swift:7` accepts aspect, and `GoldenRatioPresetTests.swift:13-21` asserts the distorted result as correct. See section E item 1.

**CO 4 — `preset.ruler.pair.cross` (Mobster.md:139). CORRECTION ORDERED.**
"It is cast to the edge of the Frame rather than translated as a fixed length." `PresetChord.offset` at `PresetChord.swift:21-24` translates the segment by `normal * distance` and nothing casts. `CurvePreset.swift:34` uses the same call and inherits the defect. Independent of mode. Section C3 gives the numbers.

**CO 5 — `003-presets.md:31`. CORRECTION ORDERED.**
The determinism requirement is untested. `PresetDeterminismTests.swift:19-20` compares a value to itself. Section E item 2.

**CC 1 — `preset.storage.static` (Mobster.md:82) against `003-presets.md:30`.**
`GoldenRatioPreset.swift:5` is `public init() {}`, zero parameters. Twelve quarter arcs at twenty four samples each, 289 locations, are frozen in `Sources/Mobster/Resources/GoldenRatio.json`. `003-presets.md:30` forbids a baked magnitude. Making arc count and sample density tunable computes the preset from parameters at load, which is the definition of `preset.storage.generated` (Mobster.md:85), so the correction moves the preset between two buckets the principal set himself.

Status: ESCALATED, not to be actioned. The fix is known and reclassifies the preset, so it is the principal's call. A harness has landed against the zero parameter initializer.

**CC 2 — `preset.curve` (Mobster.md:142) against `003-presets.md:11`.**
`preset.curve` says the control location controls the tension of "the interpreted spline". `path.interpret` (Mobster.md:68) is cut 2 and absent from this worktree. `003-presets.md:11` requires the preset to produce an ordered sequence of locations now. To satisfy both, `CurvePreset.swift:37-40` synthesizes its own quadratic Bezier and `:30-32` samples it. Both cannot hold. Coverage of "the interpreted spline" is vacuous, and when `path.interpret` lands the control location will mean something other than it does today.

## Raised and closed by amendment

The record, so the next implementer does not rediscover any of it.

- **"Nearest Frame."** Raised as a CC between `guide.initialize` (a Guide receives THE Frame, singular) and "the nearest Frame" as then carried by `preset.frame.aspect`, `preset.frame.bounds` and `guide.source.preset`; no requirement established a set of Frames from which a nearest could be selected, and nothing in the cut selected one. All three now read "the Frame". Closed.
- **`preset.ruler` subdivision.** Raised that the URI carried four independent assertions and could not be satisfied or failed as a unit, and that the parallel extent ambiguity was the direct consequence. Now split into `preset.ruler`, `preset.ruler.center`, `preset.ruler.degrees`, `preset.ruler.line`, `preset.ruler.pair` and `preset.ruler.pair.cross`. Closed. CO 4 exists because of the split.
- **Bounds placement.** Raised that `preset.frame.bounds` was silent on placement while `PresetProjection.swift:15` centred. `preset.frame.bounds.center` (97) now states it. Closed, satisfied.
- **Angle convention.** Raised that no requirement named one. `preset.ruler.degrees` (130) now names it in terms Mobster owns, without reference to a screen direction. Closed, satisfied.
- **Gutter fraction meaning.** Raised that no requirement named what the gutter is a fraction OF. `preset.gutter.fraction` (121) now names it. Closed, satisfied in aspect mode.
- **Design rectangle root cause.** I filed a root cause holding that every requirement phrased "of the Frame" held only under aspect, because bounds made the design rectangle larger than the Frame. `preset.frame.mode.aspect` and `preset.frame.mode.bounds` dissolve it: the one mode where the design rectangle diverges from the Frame is now reserved to Golden Ratio, which is fixed geometry with no Frame relative quantities to get wrong. `preset.frame.aspect` (91) now states the identity outright. Withdrawn.
- **Screen sweep direction.** The harness cut has landed and maps scene y straight to canvas y, so the principal can rule on the visible sweep by looking.

## IDEA, no URI failed

- `PresetGutter` has no precondition. A gutter at or above `extent/(count-1)` yields a zero or negative division and descending, out of range edges. `CurvePreset.swift:26` guards `resolution`; the gutter is unguarded.
- `preset.ruler.pair` does not name what happens at a distance of zero. The implementation vends three identical paths.

## What I did not do

I did not obtain the implementer's list of five magnitudes; it is not recorded anywhere I could reach. Section D is an independent sweep of every constant in the cut instead.
