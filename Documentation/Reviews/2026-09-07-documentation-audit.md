# Documentation audit, 2026-09-07

Whole repository. Branch `develop` at `4f92c62`, plus the working tree amendment `aef3961` to `Documentation/Design/Mobster.md` made during this audit. Tag `0.1.0` is the merge of this content to `main`; `git log 0.1.0..develop` is empty, so the audited tree is the tagged content.

Scope: every statement in `Documentation/` and every comment in `Sources/` and `Harness/`, verified against the code rather than against another document. `Documentation/Reviews/` excluded from staleness reporting per instruction, and reported only where pointed at as current.

## Build and test, run by me

`swift build`:

```
Building for debugging...
[26/30] Compiling MobsterFixture LineFixture.swift
[27/30] Emitting module MobsterFixture
[30/30] Compiling MobsterFixture FixtureIdentitySequence.swift
Build complete! (1.67s)
```

`swift test`:

```
Test run with 208 tests in 37 suites passed after 1.386 seconds.
```

Both clean. No warnings emitted. `xcodebuild` on the harness was not run; see the closing section.

The working tree carries one uncommitted change, `Harness/Harness.xcodeproj/project.pbxproj`, a whitespace reformat of the `PBXFileSystemSynchronizedRootGroup` entry. No content change.

---

# 1. Statements that are FALSE about the current code

## 1.1 `guide.source.layer` contradicts `path.supplied`

`Documentation/Design/Mobster.md:61-62` reads "A Guide may name a layer as its source. Stroke data from that layer is interpreted by Mobster into paths." `Documentation/Design/Mobster.md:72-73` (`path.supplied`, added this morning) reads "Mobster does not interpret source geometry into paths; a consumer wanting a layer as a source reduces it before sending."

Both cannot be true. `Sources/Mobster/GuideSource.swift:3-4` offers `.lines([Line])` and `.preset(any Preset)`; there is no layer case and no layer identity anywhere in the package. `Sources/Mobster/Guide.swift:87-88` returns the supplied lines unchanged.

`aef3961` retired `path.interpret` for exactly this reason and left `guide.source.layer` standing with the same claim in it.

## 1.2 `guide.adherence.curve` puts the mapping in the wrong place

`Documentation/Design/Mobster.md:237-238`: "The mapping from the adherence dial to a reach is derived in the harness, between zero and the reach that satisfies full adherence."

The mapping is in the package, not the harness. `Sources/Mobster/Guide.swift:39` is `Adherence(reach: adhesion * fullAdherenceReach)` — a linear map from the dial to the reach, applied inside `evaluate`. The harness passes the dial through untouched: `Harness/Harness/MotionEngine.swift:71` hands `adhesion` to `initialize` and derives nothing. `Harness/Harness/MotionParameterView.swift:7` is a plain 0...1 slider.

The harness also never displays a reach at all, so if the requirement were read as "the harness answers what the curve should be", nothing in the harness lets the principal see the quantity being decided.

## 1.3 `guide.settle.epsilon` defines arrival by distance; the code decides it by time

`Documentation/Design/Mobster.md:304-305`: "A vert has arrived when it is nearer its target than the settle epsilon."

Nothing compares a distance to `settleEpsilon`. Arrival is `Sources/Mobster/Guide.swift:78-82`, `progress(at:)`, which returns 1 when `time >= duration`. The epsilon is used in exactly two places, both derivations: `Guide.swift:53` (`fullAdherenceReach`) and `FieldBake.swift:19` (the resolution). This also conflicts with `Mobster.md:286-287` (`guide.evaluate.settled`), which defines arrival by the duration and is the definition the code implements.

The harness inherits the time definition: `Harness/Harness/MotionEngine.swift:33` reports `settled: time >= run`, and `Harness/Harness/SettlementReadoutView.swift:10` prints it.

## 1.4 `Sources/Mobster/Guide.swift:9-10` states a role the epsilon does not perform

The comment reads "Scene units, deciding arrival, deriving the field resolution and setting the reach full adhesion requires." Two of the three are true. "Deciding arrival" is not — see 1.3. A comment asserting three roles where the code performs two is the worst case for a reader checking the third.

## 1.5 `Sources/Mobster/Guide.swift:84` states a reason that is false for half the function it documents

"Nothing keys a guide, so an interpreted vert carries no identifier." It documents `interpret(_:in:)`, whose `.lines` branch (`Guide.swift:87-88`) returns the consumer's lines with whatever identifiers they carry. `Tests/MobsterTests/GuideSourceTests.swift:21` asserts a supplied `LineIdentifier(3)` survives. The comment is true of the `.preset` branch only, and reads as a property of the whole function.

## 1.6 `field.resolution.refuse` says the package sets the spend; the code says it deliberately does not

`Documentation/Design/Mobster.md:163-164`: "A derived resolution whose bake exceeds what the package will spend is refused."

`Sources/Mobster/FieldBake.swift:8-9`: "Texel segment products the bake may spend. Supplied, because how long a caller will wait is not the package's to decide." The budget is a consumer argument on `Guide.initialize` (`Guide.swift:25`) and on `FieldBake.init` (`FieldBake.swift:11`). The requirement and the code comment assert opposite ownership of the same number, in the same repository.

## 1.7 `preset.thirds` calls Thirds a grid with a zero gutter; the code disagrees

`Documentation/Design/Mobster.md:119-120`: "It is a grid with a zero gutter and is kept separate regardless."

Under `preset.gutter.band` (`Mobster.md:131-132`) a gutter is a band with two edges whatever its width. `Sources/Mobster/PresetGutter.swift:13-16` emits `[leading, leading + gutter]` unconditionally, so `GridPreset(count: 3, gutter: 0)` yields 4 coincident verticals and 4 coincident horizontals, 8 paths. `Sources/Mobster/ThirdsPreset.swift:13-20` yields 2 and 2, 4 paths. `Tests/MobsterTests/GuideSourceTests.swift:29` asserts the 4. `Tests/MobsterTests/GridPresetTests.swift:18` asserts `4 * (count - 1)`.

The two presets do not produce the same picture, the same path count, or the same bake cost. The sentence would license deleting Thirds.

## 1.8 `preset.gutter.fraction` is false in bounds mode

`Documentation/Design/Mobster.md:134-135`: "A gutter width is a fraction of the Frame extent along the axis it divides. Its meaning does not change with plot mode."

The gutter is a fraction of the design extent, which is 1 (`ColumnsPreset.swift:3`, `RowsPreset.swift:3`, `GridPreset.swift:3`), and is then carried through `PresetProjection`. In `.aspect` the design maps to the Frame per axis and the requirement holds. In `.bounds` the scale is `max(frame.size.x, frame.size.y)` on both axes (`Sources/Mobster/PresetProjection.swift:13-15`), so on a 600 by 400 Frame a rows gutter of 0.02 plots as 12 scene units against a 400 unit height — 3 per cent of the Frame extent, not 2. The meaning does change with plot mode.

The code says so itself and the requirement does not: `Sources/Mobster/ColumnsPreset.swift:6` and `RowsPreset.swift:6` read "which is the Frame width in aspect mode", and `GridPreset.swift:6` "which is the Frame extent of that axis in aspect mode". Three comments carry the qualifier the requirement denies. Nothing tests the bounds case; `Tests/MobsterTests/PresetGutterTests.swift` works in design space only.

## 1.9 `README.md` describes a package that does not exist

- `README.md:13`: "Mobster serves both of these needs by providing \"Modifier\" types that are configured and consumed by OneBrush." There is no `Modifier` type in `Sources/Mobster`. The public surface is `Guide`, `GuideSource`, `Frame`, `Line`, `Vert`, the two identifiers, seven presets, and the field types.
- `README.md:10`: "Derived Point Creation". Nothing in the package creates points. `Guide.evaluate` returns exactly the verts it was handed, displaced (`Sources/Mobster/Guide.swift:37-43`). `mobster.identity.mint.never` forbids the capability this line advertises.
- `README.md:11`: "Applied Point Manipulation" is the only one of the two the package does.
- The README does not name `Guide`, the field, the settle epsilon, the bake budget, the `MobsterFixture` product (`Package.swift:12`), or the harness. `README.md:17` links to the design document and that link is correct.

## 1.10 `Documentation/Integration.md:5` misdescribes the return

"It gives back the points, by identifier, and where they landed." `Guide.evaluate` returns `[Line]` in the order supplied, each line carrying its verts in the order supplied (`Sources/Mobster/Guide.swift:37-43`). Nothing is keyed by identifier, and the identifier is optional and frequently nil — `Tests/MobsterTests/GuideSourceTests.swift:39` asserts nil is the intended state for an interpreted guide. A consumer reading line 5 expects a dictionary.

## 1.11 `Documentation/Integration.md:24` understates what the Guide retains

"The Guide outlives the call only to hold its baked field, which is the expensive part." It also holds `frame`, `adhesion`, `duration`, `settleEpsilon` and `lines`, all `public private(set)` (`Sources/Mobster/Guide.swift:4-12`). `lines` is source content, retained across evaluations. The sentence that follows, "It retains nothing about content", is true of evaluated content and false of source content, and the guide does not distinguish them for the reader.

## 1.12 `Documentation/Integration.md:46` carries three mutually incompatible cost figures

"Measured on a Frame of 1000 by 700 in release, at an epsilon of one the grid is 351,168 squares and a fifth of a second buys about 285 segments. The same fifth of a second buys 4,000 segments at an epsilon of five."

The grid figure is correct. `FieldResolution.init` (`Sources/Mobster/FieldResolution.swift:18-30`) gives `ceil(1000 / sqrt(2)) = 708` on the wide axis, `round(0.7 x 708) = 496` on the other, and 708 x 496 = 351,168 exactly.

The segment figures do not agree with each other. 351,168 x 285 = 100,082,880 products in 0.2 s, or 2.0 ns per product. At an epsilon of five the same derivation gives 142 x 99 = 14,058 texels, and 14,058 x 4,000 = 56,232,000 products in 0.2 s, or 3.6 ns per product. The two halves of one sentence imply rates 78 per cent apart.

Neither agrees with `Harness/Harness/HarnessModel.swift:9`, "A bake runs at roughly a nanosecond a product in release", which would make the same fifth of a second buy 569 segments at an epsilon of one and 14,225 at an epsilon of five.

Three numbers, three rates, and the harness comment is the one a reader is most likely to trust because it is next to the constant it justifies.

## 1.13 `Documentation/Integration.md:72` promises a capability the design has just forbidden

"Requires from Mobster: a source layer identity the client can store and hand back, and interpretation of that layer's stroke data into paths." Same defect as 1.1. `path.supplied` (`Mobster.md:72-73`) now says the consumer reduces the layer before sending. This is the guide telling a consumer to plan an integration around a capability the design document, as of today, says will not exist.

## 1.14 `Documentation/Workflow.md:5` points at itself as the requirements document

"Discussion with principal regarding requirements and changes should result in an update to the requirements document (this file.)" `Workflow.md` is not the requirements document. `Documentation/Design/Mobster.md:4` is, and says so. An agent following line 5 literally writes requirements into the process document.

## 1.15 `Documentation/Workflow.md:9` describes a reconciliation gate that ran four times in sixteen cuts

"the \"chat host\" agent will dispatch a `requirements-analyst` to provide whole changeset reconciliation against the dispatch for that work." `Documentation/Reviews/` holds four reconciliations: 001, 003, 005 and 009. Twelve cuts merged without one, including 013 (the stateless evaluator, which retired the entire token model), 014, 015 and 016. The process description is not what happened. The GitHub record confirms the cuts landed: issues 2 through 18 are all closed.

## 1.16 The Body section lists an attribute that does not exist

`Documentation/Design/Mobster.md:311-315` says a vert carries three optional attributes and names them: a weight, "A counter influence. It appears stochastic across a canvas. It is derived from the vert identifier rather than drawn", and a coupling.

`Sources/Mobster/Vert.swift:6-8` carries `mass`, `drag`, `coupling`. There is no counter influence and nothing stochastic. `vert.drag` (`Mobster.md:248-249`) is the attribute that took the slot, and it is deterministic and unseeded. The Body list was not updated when drag replaced it.

The section header at `Mobster.md:309` says "Outcomes, not yet a parameterization", which excuses the absence of a control surface. It does not excuse naming an attribute that was decided against.

## 1.17 The Body section claims an outcome the coupling implementation cannot produce

`Documentation/Design/Mobster.md:319` lists among the outcomes "a vert pushing its peers away from their own targets; and a whole line moving as one body."

`Sources/Mobster/Coupling.swift:3` states the shape actually built: "An offset carries a vert further along its own travel; it does not carry it toward the coupled vert's target." `Documentation/Issues/016-coupling.md:11` says the same. A coupled vert therefore always moves toward its own target and never toward a peer's. A negative coupling retards a peer along its own travel — `Tests/MobsterTests/GuideCouplingTests.swift:70-78` asserts exactly that — rather than pushing it away from its target. And a line whose verts have different targets cannot move as one body under a time offset, because every vert is home at the duration by construction (`Coupling.swift:17-18`, asserted at `GuideCouplingTests.swift:80-92`).

Two of the five listed outcomes are unreachable. `Mobster.md:317`, "No rule is needed for which vert's target wins on a stiff line, because the motion emerges from propagation", is true but for a different reason than the one the paragraph implies: no vert's target ever competes with another's.

## 1.18 `Documentation/Issues/009-guide.md:17` states an adherence behaviour the design explicitly refutes

"At full adherence the reach covers the Frame and a point snaps fully onto the path."

`Mobster.md:213-214` (`guide.adherence.reach.full`): "A reach merely equal to the Frame extent does not achieve it, because the falloff yields a weight below one for every finite reach." The code agrees with the requirement: `Tests/MobsterTests/GuideAdhesionTests.swift:25` records a full adherence reach of 2428.76 on a 128 by 128 Frame, thirteen times the diagonal, and `GuideAdhesionTests.swift:50` records the worst case vert settling 0.977 short at full adhesion rather than on the path.

## 1.19 `Documentation/Issues/010-harness-motion.md` names three harness features that do not exist

- Line 11: "tokenizes the fixture population against it". There are no tokens. The token model was retired by cut 12.
- Line 13: "A slider for adherence reach and a slider for speed." The harness has Adhesion, Duration and Coupling (`Harness/Harness/MotionParameterView.swift:7-9`). No reach slider. No speed slider — the transport interval is fixed at `Transport.swift:7` and commented as fixed.
- Line 14: "The settled notification is surfaced." There is no notification. Settlement is a derived boolean read per frame (`MotionEngine.swift:33`).
- Line 15: "Dirty rectangles are drawn when shown." Nothing in the package computes a rectangle. `guide.rect.dirty` no longer exists as a requirement.

## 1.20 `Documentation/Issues/008-sweep.md` names a control the next cut removed

Line 14 asks for "a slider for field resolution, which is the magnitude `field.store.location.exact` trades against bake time", and line 26 accepts on "moving the resolution slider visibly changes it". Cut 13 (`014-resolution.md:9`) removed the supplied resolution outright. The harness now exposes Settle Epsilon and Budget (`Harness/Harness/FieldParameterView.swift:9-10`). No resolution slider exists or can.

## 1.21 `Documentation/Issues/001-package-foundation.md:13` names two retired types

"A sample carrying a point identifier and a location. A grouping carrying a stroke identifier and its ordered samples." `Sample` and `Stroke` were retired by `013-types.md:11` in favour of `Vert` and `Line`. Neither name appears in `Sources/`.

## 1.22 `Documentation/Issues/012-decimate.md` is a change order for work that was measured, declined and retired

The whole file describes decimation. Its two cited requirements are gone: `path.decimate.tolerance` was deleted at `4f92c62` and `path.smooth.never` was rewritten in the same commit to forbid decimation outright. `d19a409` is titled "Add the grid preset and decide decimation by measurement". Nothing in `Sources/` decimates.

Line 21 instructs an implementer to hard copy `~/Source/Repos/Jerome/Sources/Jerome/Finding/ContourFinder.swift:84-106`, Ramer Douglas Peucker. No copy was made and none should be.

## 1.23 `Documentation/Issues/002-path-interpretation.md` is a change order whose every requirement is retired

Its four cited path requirements — `path.interpret`, `path.decimate`, `path.complexity.cap`, `path.vend` — are down to one; only `path.vend` survives. Lines 11 to 13 ask for curvature interpretation, decimation and a complexity cap, none of which exist. Lines 22 to 25 instruct four hard copies from Jerome and onebrush, including a Schneider spline fit. None were made.

Read as current, this file tells an implementer to build the one thing `path.supplied` was written this morning to forbid.

## 1.24 Twenty seven requirement identifiers cited by change orders no longer exist

Cross referencing every `## Requirements covered` list against the 100 unique URIs in the design document:

`guide.initialize.reset`, `guide.play`, `guide.play.evaluate`, `guide.play.end`, `guide.rate`, `guide.rect.dirty`, `guide.settle.notify`, `guide.settle.track.never`, `guide.skiptake.source`, `guide.skiptake.target`, `guide.skiptake.retarget`, `guide.skiptake.tokenize`, `guide.skiptake.remove`, `path.complexity.cap`, `path.decimate`, `path.decimate.tolerance`, `path.interpret`, `token.authority.none`, `token.create`, `token.identity.point`, `token.identity.stroke`, `token.origin`, `token.planar`, `token.progress`, `token.reuse`, `token.segment`, `token.target`.

Cited by `001` (1), `002` (4), `009` (23), `010` (3), `012` (2). No issue file carries a supersession marker; `grep -i "supersed|retired|obsolete|historical|withdrawn"` across `Documentation/Issues/` returns one hit, and it is `014-resolution.md:9` describing its own deliverable.

## Which change orders are a record and which would mislead

A record of what was asked, safe to read: `003`, `004`, `005`, `006`, `007`, `011`, `013`, `014`, `015`, `016`. Each describes work that landed and largely stands.

Would mislead someone reading it as current, in descending order of damage:

1. `009-guide.md` — 23 dead URIs, a whole retired architecture (tokens, skip takes, play, rate, dirty rectangles, settlement notification), and a false adherence claim at line 17.
2. `002-path-interpretation.md` — asks for the interpretation `path.supplied` forbids, plus four uncopied prior art references.
3. `012-decimate.md` — asks for decimation `path.smooth.never` forbids.
4. `010-harness-motion.md` — four harness features that do not exist.
5. `008-sweep.md` — a resolution slider that cannot exist.
6. `001-package-foundation.md` — two retired type names and one dead URI.

---

# 2. Requirements with no implementation

## 2.1 `path.role` — nothing implements it

`Documentation/Design/Mobster.md:81-82`. "A vended path carries what it is. A consumer can distinguish a ruler's base line from its parallels, and a spiral from the rectangles it was derived from, without relying on the order they arrive in."

`Sources/Mobster/Preset.swift:3` returns `[[SIMD2<Float>]]`. `Sources/Mobster/RulerPreset.swift:26` returns base, then plus offset, then minus offset — positional. `Sources/Mobster/GoldenRatioPreset.swift:19` returns the resource paths in file order, spiral at index 0 and twelve quadlines after. `Sources/Mobster/Guide.swift:90-92` builds `Line(verts:)` with the identifier defaulted nil. `Sources/Mobster/Line.swift:3-5` carries verts and an optional consumer identifier and nothing else.

Arrival order is the only discriminator, and the tests are built on it: `Tests/MobsterTests/GoldenRatioPresetTests.swift:8-9` defines `spiral` as `paths[0]` and `quadlines` as `dropFirst()`. The test suite encodes the exact dependency the requirement forbids.

## 2.2 `guide.determinism.seed` — nothing in the package needs a seed

`Documentation/Design/Mobster.md:301-302`. "A seed required by a vert attribute is derived from the vert identifier."

No vert attribute in `Sources/Mobster` requires a seed. `mass`, `drag` and `coupling` are all deterministic closed forms (`Travel.swift:16-38`, `Coupling.swift:16-37`). The one place a seed is derived from a vert identifier is `Sources/MobsterFixture/FixtureSpread.swift:20`, and the fixture is the consumer's stand in, not Mobster — `Package.swift:20` says so explicitly.

The requirement was written for the counter influence attribute of `Mobster.md:314`, which was never built. It has no subject left.

## 2.3 `guide.adherence.change` — no mechanism, and no state for it to act on

`Documentation/Design/Mobster.md:234-235`. "Changing adherence resolves every target again from each point's current location, and ends the segment in flight as a field change does."

There is no way to change adherence except `initialize`, which rebakes everything (`Guide.swift:25-35`); `adhesion` is `private(set)`. There is no segment and nothing is in flight: `evaluate` is a pure function of content and time (`Guide.swift:37-43`) and retains nothing. Both clauses of the requirement name concepts the stateless evaluator removed. It survived cut 12 unamended.

## 2.4 `guide.source.map.absolute` — no source frame exists to map from

`Documentation/Design/Mobster.md:67-68`. "A source Frame differing from the target Frame maps absolutely."

`Guide.initialize` takes one `frame` (`Guide.swift:25`), used both to plot a preset and to bake. A `.lines` source arrives in scene coordinates and is never fitted, so the requirement is not violated, but nothing in the API can express "a source Frame differing from the target Frame". With `path.supplied` now telling the consumer to reduce a layer before sending, the concept has nowhere left to live.

## 2.5 `preset.frame.mode.default` omits Grid

`Documentation/Design/Mobster.md:104-105` enumerates "Thirds, Columns, Rows, Ruler and Curve". `Sources/Mobster/GridPreset.swift:10` defaults to `.aspect`, `Tests/MobsterTests/GridPresetTests.swift:89-91` asserts it, and `Documentation/Issues/011-grid.md` says it should. The requirement is a closed list that a later cut added a sixth member to without amending. A reader checking Grid against the enumeration concludes its aspect default is unrequired.

## 2.6 `guide.initialize` is one URI carrying two different requirements

`Documentation/Design/Mobster.md:38-39` under Space: "A Guide receives the Frame it operates within when it is constructed, so that no workload can run before it. Initialize supplies a new Frame and resets."

`Documentation/Design/Mobster.md:268-269` under Evaluation: "A Guide is initialized with its source, which is guide lines or a preset, the Frame it operates within, an adhesion, and a duration. The bake happens here and once."

101 bold identifiers, 100 unique. This is the only collision. Both are implemented, but a change order citing `guide.initialize` names an ambiguity, and `001-package-foundation.md:7` and `009-guide.md:7` cite the same URI for different work.

## 2.7 `guide.initialize.again` enumerates four of the five things initialize replaces

`Documentation/Design/Mobster.md:47-48`: "replaces the source, the Frame, the adhesion and the duration". `Guide.swift:29-34` also replaces `settleEpsilon`, which is the input the whole field derivation hangs on. `Tests/MobsterTests/GuideSourceTests.swift:60` mirrors the requirement's omission in its own test name and does not assert the epsilon it passes at line 65.

---

# 3. Implementations with no requirement

## 3.1 `Adherence` is public and vends a reach the design says the consumer never sees

`Sources/Mobster/Adherence.swift:2-8`. `public struct Adherence` with `public let reach: Float` and a public initializer. `Documentation/Design/Mobster.md:271-272` (`guide.adhesion`): "It maps onto the reach the falloff uses, and the consumer never sees a reach."

All 34 files in `Tests/MobsterTests/` use `@testable import Mobster`, so no test requires this to be public. Neither the harness nor `MobsterFixture` references `Adherence`. Nothing needs it exported.

`Guide.fullAdherenceReach` (`Guide.swift:52`) is a second public reach, and that one is required — `guide.adherence.reach.full.derive` at `Mobster.md:231-232` says "Mobster vends it". So `guide.adhesion` and `guide.adherence.reach.full.derive` also disagree with each other about whether a reach crosses the boundary at all.

## 3.2 `Field` and `FieldBake` are public where `guide.field.vend` says the field is not exposed

`Sources/Mobster/Field.swift:2` and `Sources/Mobster/FieldBake.swift:2`, both public with public members and public initializers. `Documentation/Design/Mobster.md:289-290`: "A Guide vends a rasterization of its field on demand. The field itself is not exposed."

The Guide's own field is private (`Guide.swift:13`), so the letter of the requirement holds. But a consumer can construct `FieldBake` and obtain a `Field` with its full `locations` array. Nothing in the harness, the fixture, or any non-testable test does so. No requirement asks for a field to cross the boundary.

## 3.3 `MobsterFixture` is a shipped library product; `harness.fixture` says the harness carries it

`Package.swift:12` exports `MobsterFixture` as a public library product. `Documentation/Design/Mobster.md:348-349`: "The harness carries a nominally complex dataset as a fixture."

The fixture is in `Sources/MobsterFixture` and ships to any consumer of the repository. `Package.swift:20` gives the reason — "The fixture mints identifiers, which Mobster is forbidden to do, so it sits in its own target rather than inside the library" — and that reason justifies a separate target, not a published product. `007-fixture.md:1` calls the cut "Data only, plus the harness drawing it". Whether the fixture ships is a decision no requirement records.

## 3.4 `CurvePreset.resolution` is a public parameter no requirement names

`Sources/Mobster/CurvePreset.swift:14`, `public let resolution: Int`, with a slider at `Harness/Harness/CurveParameterView.swift:14`. `preset.curve` (`Mobster.md:155-156`) names a center, two degrees, a distance and a control location, and nothing about sampling. `precondition(resolution >= 1)` at `CurvePreset.swift:28` is the only public trap in the package. Minor, and probably wanted, but it is a control surface with no requirement behind it.

---

# 4. Statements that were true and are now confusing

## 4.1 Drag is documented as resistance in the code and as leniency in the design

`Documentation/Design/Mobster.md:248-249` (`vert.drag`) calls it "An optional leniency across its travel", running one down to minus one, with one being plain travel. Commit `1cb377d` is titled "Drag is leniency running down, not resistance running up".

`Sources/Mobster/Travel.swift:35`: "A resistance of one is spent, a resistance of zero holds the vert back against the whole run, and a resistance of minus one leads it away before it returns." `Travel.swift:37` names the local `resistance`. `Travel.swift:7`: "Nil is the plain travel rather than a resistance of zero."

The arithmetic is right. The word is inverted: under the ordinary sense of resistance, a resistance of one being "spent" and a resistance of zero holding the vert back is backwards, and a reader checking the comment against `progress * (progress + resistance * (1 - progress))` has to work out which of the two is wrong.

`Sources/MobsterFixture/FixtureSpread.swift:23-24` gets it right and uses `leniency`. So the package and its own fixture name the same attribute two opposite ways.

## 4.2 `mobster.frame.between` uses "frames" in a sense the rest of the document reserves

`Documentation/Design/Mobster.md:8-9`: "Mobster evaluates between two frames." Every other use of Frame in the document is the scene space region of `guide.frame.region`, and a Guide holds exactly one. The body of the requirement — "Carrying positions across successive sets of targets" — makes clear it means animation frames. `Sources/Mobster/Guide.swift:1` repeats the collision verbatim: "Evaluates content between two frames."

Read against `guide.frame.region` three lines of code away, the class doc comment says the Guide spans two regions. It does not.

## 4.3 `field.bake` and `path.vend` still say "interpreted"

`Documentation/Design/Mobster.md:166-167`: "The field is baked from the interpreted paths". `Mobster.md:78-79`: "Interpreted paths are vended to the consumer on demand." Both survive `aef3961`, which retired `path.interpret` on the grounds that nothing interprets anything. Both requirements are satisfied by the code; the adjective is the residue. `guide.lines.vend` at `Mobster.md:292-293` carries the same word.

For the record, since it was asked: `path.vend` and `guide.lines.vend` ARE implemented. `Sources/Mobster/Guide.swift:12` declares `public private(set) var lines: [Line]`, assigned at `Guide.swift:33`, exercised at `Tests/MobsterTests/GuideSourceTests.swift:20-22`, `:29-31` and `:38-39`.

## 4.4 `vert.mass` and the Body describe motion "per tick"

`Documentation/Design/Mobster.md:246`: "A vert with more mass moves less per tick." `Mobster.md:313` repeats it. There is no tick. `Travel.fraction(at:)` (`Sources/Mobster/Travel.swift:16-28`) is a closed form in progress, and `guide.evaluate.time` (`Mobster.md:283-284`) states that evaluation is not an increment from a previous call. The behaviour the phrase describes is right; the mechanism it implies was removed with the token model.

## 4.5 `Documentation/Design/Prose.md` carries no marker that it is superseded, and one document points at it as authority

Prose.md sits in `Documentation/Design/` beside the authority, opens with the same title and tagline as `Mobster.md:1-2`, and carries no header saying it has been superseded. `Prose.md:9` still reads "## Prose (To be moved to pricinpal issue in github prior to task planning.)" — an instruction that has been carried out; GitHub issue 1, "Mobster design prose", is open and is what `Mobster.md:4` means by "the principal issue". As written, the line reads as outstanding work.

What is in it, against the current code: an `.advance` method taking a speed multiplier, a `.settled` notification to listeners, point tokens with stroke identifier and progress and target fields, skip takes, dirty rectangles in scene coordinates, and at `Prose.md:60` "At 1.0 the reach covers the Frame and every point snaps fully onto its nearest guide location", which `guide.adherence.reach.full` exists to refute. None of it is true of `Sources/`.

`Documentation/Reviews/2026-09-05-003-presets-reconciliation.md:81` cites `Prose.md:42` as the determining evidence for how `preset.frame.aspect` should be read: "`Prose.md:42` writes \"the scaled (and potentially distorted) paths\". The parenthetical requires a referent." That is the repository treating Prose.md as load bearing on a live requirement. The review is historical and I am not reporting it as stale; I report it because you asked whether anything points at Prose.md as though it were current, and this does.

## 4.6 `Documentation/Design/Generators.md` is true and unreachable

Every substantive claim checks out. Line 11: with the count being repetitions beyond the original, closure at `angle x (count + 1) = 360` is correct. Line 21: a reflection has determinant minus one and no composition of rotations reaches it, correct. Line 27: two perpendicular axes yield four images including the unasked half turn, correct. Line 3 declares it is not an implementation target and nothing in `Sources/` implements symmetry, so nothing contradicts it.

It is linked from nothing. `README.md:17` links only to `Mobster.md`; `Mobster.md` never mentions generators. A live problem statement no index reaches is a document that gets rediscovered rather than read.

---

# 5. Anything in two places that disagrees

| Claim | Place A | Place B |
|---|---|---|
| Whether Mobster interprets a source layer into paths | `Mobster.md:61-62` says it does | `Mobster.md:72-73` says it does not; `GuideSource.swift:3-4` has no layer case |
| Who owns the bake spend | `Mobster.md:163-164`, "what the package will spend" | `FieldBake.swift:8-9`, "not the package's to decide" |
| Whether a reach crosses the boundary | `Mobster.md:271-272`, "the consumer never sees a reach" | `Mobster.md:231-232`, "Mobster vends it"; `Guide.swift:52` |
| Where the adhesion to reach curve lives | `Mobster.md:237-238`, in the harness | `Guide.swift:39`, in the package |
| What decides arrival | `Mobster.md:304-305`, distance under the epsilon | `Mobster.md:286-287` and `Guide.swift:78-82`, the duration |
| Whether the gutter fraction is mode independent | `Mobster.md:134-135`, it is | `ColumnsPreset.swift:6`, `RowsPreset.swift:6`, `GridPreset.swift:6`, only in aspect mode |
| Bake cost per texel segment product in release | `Integration.md:46`, 2.0 ns, and 3.6 ns in the same sentence | `HarnessModel.swift:9`, roughly 1 ns |
| Whether Thirds equals a zero gutter Grid | `Mobster.md:119-120`, it does | `ThirdsPreset.swift:13-20` gives 4 paths, `GridPreset` at count 3 gives 8 |
| The name of the third vert attribute | `Mobster.md:314`, a counter influence | `Vert.swift:7`, `drag` |
| The word for the drag scale | `Mobster.md:248`, leniency | `Travel.swift:35,37`, resistance |
| Which presets default to aspect | `Mobster.md:104-105`, five named | `GridPreset.swift:10` is a sixth |
| Where the fixture lives | `Mobster.md:348-349`, the harness | `Package.swift:12`, a shipped library product |
| Which document holds the requirements | `Workflow.md:5`, "this file" | `Mobster.md:4` |

---

# 6. What I could not do

- I did not run `xcodebuild` on the harness. The harness is outside the package graph and has no test target, so nothing in `swift test` reaches it and none of the comments in `Harness/` are verified by anything but the compiler. Every harness finding above is from reading, and the harness build state is unverified by me.
- `Documentation/Issues/002-path-interpretation.md:22-25` and `012-decimate.md:21` cite source files in `~/Source/Repos/Jerome` and `~/Source/Repos/onebrush` by path and line. I did not read those repositories, so I can confirm only that no copy of any of them exists in `Sources/`. Whether the cited line ranges still hold at their origins is unchecked.
- `harness.copy` (`Mobster.md:360-361`) is satisfied vacuously. No data structure in the repository came from Jerome, Tempest or Muslin; the only prior art citation anywhere in `Sources/` is `FixtureRandom.swift:1`, "SplitMix64", and I verified the constants `0x9E3779B97F4A7C15`, `0xBF58476D1CE4E5B9` and `0x94D049BB133111EB` with shifts 30, 27 and 31 against the published algorithm. That citation is correct.
- `Documentation/Design/Mobster.md` was amended twice during this audit (`4f92c62`, then `aef3961`). Everything above is reconciled against the file as it stands after `aef3961`. Line numbers in the Paths, Presets, Field, Adherence, Types, Evaluation, Body and Harness sections are from that text.

# 7. Comments I verified and found accurate

Listed only to bound the negative result, since a comment audit that reports nothing about the rest is not a finished audit. Every doc comment in `Sources/` and `Harness/` not named in sections 1 or 4 was checked against its code and holds. The load bearing ones I derived rather than read:

- `Adherence.swift:10`. The residual is `d^3 / (r^2 + d^2)`; solving for `r` gives `d x sqrt(d/e - 1)`, which is line 13.
- `FieldResolution.swift:17-19`. Half a texel diagonal within the epsilon gives a side of `e x sqrt(2)`, which is the divisor at line 19.
- `FieldBake.swift:66`. The settled location bounds and never answers: the true nearest segment always passes both the box gap guard and the distance guard, because the previous texel's answer is itself a path location and so bounds the true distance from above.
- `Field.swift:35`. Zero distance maps to 255 and the ceiling to 0, so a path is white and the furthest texel black.
- `Coupling.swift:23`. Hop ascending with both sides added as a pair, order independent, asserted at `GuideCouplingTests.swift:94-106`.
- `GuideCouplingTests.swift:5,10`. An epsilon of 0.71 does derive one unit texels on a 128 Frame, and the reach of 288.4728 does leave 0.7545 of forty units.
- `GuideAdhesionTests.swift:24,37`. The recorded reaches and the two and five sixths growth ratio are correct.
- `HarnessModel.swift:11-12,17-18` and `Transport.swift:8-9`. Three decades, and 480 steps at a sixtieth is eight seconds.
- `GoldenRatioPreset.swift:4-5`. The stored spiral does converge toward max x, min y, and the resource is 1.618033989 by 1 with the spiral at index 0 and twelve quadlines after it.
