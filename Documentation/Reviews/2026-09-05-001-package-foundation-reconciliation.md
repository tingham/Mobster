# Reconciliation: Cut 1 package foundation

Branch `cycle/foundation`, commits `1d9197c..b3247e2`, worktree `/Users/tingham/Source/Repos/Mobster/.worktrees/foundation`.
Authorities: `/Users/tingham/Source/Repos/Mobster/Documentation/Design/Mobster.md` (sections Package, Space, Sources), then `/Users/tingham/Source/Repos/Mobster/Documentation/Issues/001-package-foundation.md`.
Both authorities were amended mid review. Everything below reconciles against the amended text: `guide.initialize` reading "A Guide receives the Frame it operates within before any other workload is invoked. The Frame is a region in scene space and carries a position within it", and the acceptance line reading "Every type that carries data across the boundary is a value type. The Guide is not such a type."

## Build and test, actual output

`swift build` in the worktree:

```
[0/1] Planning build
Building for debugging...
[0/1] Write swift-version-698CFE1F834E5642.txt
Build complete! (0.18s)
```

`swift test` in the worktree:

```
Test Suite 'All tests' started at 2026-09-05 09:41:15.819.
Test Suite 'All tests' passed at 2026-09-05 09:41:15.820.
	 Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.001) seconds
...
Test run with 11 tests in 3 suites passed after 0.001 seconds.
```

Green. Eleven tests, three suites, no warnings emitted. The build was incremental against the existing `.build` directory; I did not clean first. The XCTest harness reporting zero tests is expected, the suites are Swift Testing.

## A. Requirement coverage

**mobster.model.none** — Satisfied. No import statement exists anywhere under `Sources/Mobster`. `SIMD2` is standard library, so neither `simd` nor `Foundation` was pulled in. `Package.swift:13` declares no dependencies. The only imports in the package are `Testing` and `@testable import Mobster` in the test target.

**mobster.import.permitted** — Vacuous. This is a permission and not an obligation. Nothing imports, so nothing exercises it.

**mobster.identity.opaque** — Satisfied, through an interpretation the order did not state. `PointIdentifier.swift:4` and `StrokeIdentifier.swift:4` each hold `public let value: UInt64`. What literally crosses the boundary is a struct rather than an unsigned integer; the representation is unsigned, and the nominal wrapper is the stronger reading of "opaque". See D7.

**mobster.identity.opaque.read** — Vacuous. No Mobster code consumes an identifier. `Guide` holds no membership. `PointIdentifier.value` and `StrokeIdentifier.value` are read by nothing in `Sources` or `Tests`. That property is the only surface through which this requirement can ever be violated, and nothing in the cut constrains it.

**mobster.identity.mint.never** — Vacuous. The only construction path is `PointIdentifier.swift:6` and `StrokeIdentifier.swift:6`, each taking a supplied `UInt64`. There is no code in the cut that could mint.

**mobster.implementation.swift** — Satisfied. All Swift. `Package.swift:1` is tools version 6.0, no Metal target, no `.metal` file.

**mobster.transfer.value** — Satisfied by declaration for the data types. `Frame.swift:2`, `Sample.swift:1`, `Stroke.swift:1`, `PointIdentifier.swift:2` and `StrokeIdentifier.swift:2` are all structs; `Stroke.samples` at `Stroke.swift:4` is an `Array`, itself a value type. Only one datum actually crosses in this cut, the `Frame` at `Guide.swift:8`. `Sample` and `Stroke` cross nothing yet, so their conformance is declared rather than exercised.

**guide.initialize** — Satisfied in part, remainder vacuous. `Guide.swift:8` receives the Frame. `Frame.swift:4` and `Frame.swift:5` carry a position and a size, matching the amended text. The clause "before any other workload is invoked" is unenforced: there is no workload to guard, no precondition, no trap. `Guide.swift:3` marks the uninitialized state with nil but nothing rejects use of a Guide in that state.

**guide.initialize.reset** — Vacuous. `Guide.swift:8` through `Guide.swift:10` assigns the frame and discards nothing. There are no tokens and no membership to rebuild. The comment at `Guide.swift:7` asserts a discard the code does not perform; see C.

**guide.space.scene** — Vacuous in part. `Frame.swift:3` and `Sample.swift:3` assert scene coordinates in a comment. No type, no unit and no test carries the space, so nothing can fail. Targets and returned rectangles, the other two thirds of the requirement, do not exist in this cut.

## B. Overreach

**CE — Guide.frame.** `Guide.swift:3` exposes `public private(set) var frame: Frame?`. No requirement asks a Guide to vend the Frame it received; `guide.initialize` says only that it receives it. Its only readers are `GuideTests.swift:10` and `GuideTests.swift:20`. Accepted by the coordinator.

**CE — Hashable on the payload types.** `Frame.swift:2`, `Sample.swift:1` and `Stroke.swift:1` conform to `Hashable`. No requirement asks these three to compare or hash. `mobster.identity.opaque.read` justifies `Hashable` on the two identifiers, "an identifier is a key and nothing else", and does not reach the payload. The conformance's only consumers are `GuideTests.swift:10`, `GuideTests.swift:20` and `ValueSemanticsTests.swift:50`. This is surface introduced to make assertions possible.

Not overreach, examined and cleared: `Sendable` on all five value types is the default expectation under the tools 6.0 language mode and costs nothing; the explicit memberwise initialisers are required for construction outside the module; `Frame.origin` is now named by the amended `guide.initialize` and the CE I raised against it is withdrawn.

## C. Convention violations

**`Guide.swift:7`.** `/// Establishes scene space and discards all prior state. Nothing is held yet, so there is nothing to discard.` Two defects in one line. The second sentence is workflow status describing the state of the cut rather than the declaration, and it will rot the moment tokens exist. The first sentence restates a requirement that the code does not implement, so the comment asserts behavior a reader will not find. The one physical line rule is met.

**`Frame.swift:3`.** `/// Scene coordinates.` is attached to `origin` alone. `size` at `Frame.swift:5` carries no annotation and inherits nothing, and a size is an extent rather than a coordinate, so the annotation does not generalise to it.

Clean, examined: one type per file with filename matching across all six source files and all three test files; no protocol declared anywhere, so no conformer collision; no extension block anywhere; no hyphenated compound word in any source or test file. `swift-tools-version` at `Package.swift:1` is SwiftPM mandated syntax and is not a violation.

## D. Decisions the order did not state

**1. Type names.** `Stroke` and the two identifier names are consistent. `mobster.identity.opaque` names "a point identifier and a stroke identifier"; `guide.target` and `guide.skiptake.source` use "stroke" throughout. `Sample` is unaddressed by the requirements: the word does not appear anywhere in Mobster.md, and the requirements' word for a point carrying a location is "point", as at `token.progress`, "A token stores the current location of its point". The order supplied "sample" at its deliverable line, so the vocabulary divergence originates in the order and not in the implementation.

**IDEA, potential gap.** Mobster's `Stroke` at `Sources/Mobster/Stroke.swift:1` shares a name with the OneBrush document model type that `mobster.model.none` forbids importing. No import exists and the requirement holds. The harness under `harness.fixture` will hold both, and the collision resolves there rather than here.

**2. UInt64 width.** Unaddressed. `mobster.identity.opaque` says "unsigned integer" without a width. Consistent. A consumer whose identifiers are narrower or wider converts at the boundary, which no requirement speaks to.

**3. Public readable wrapped value.** Unaddressed. `mobster.identity.opaque.read` binds Mobster and not the consumer, so exposing the minted integer back to the party that minted it is consistent. Nothing reads it today, in `Sources` or in `Tests`. It remains the single affordance capable of violating the requirement, guarded by neither a test nor access control.

**4. Frame as origin and size, both SIMD2 of Float.** The origin is consistent with the amended `guide.initialize`, "carries a position within it". The vector type and the single precision are unaddressed; no requirement names a numeric type or a precision anywhere in the document. Consistent. The shape serves the downstream requirements that read the Frame: `field.tiebreak.center` needs a center, `preset.frame.aspect` needs an aspect ratio, `guide.space.normalize` needs both the position and the extent to normalize across the region and reverse it.

**5. Guide as a final class.** Consistent with the requirements. `mobster.transfer.value` governs data crossing the boundary, and a Guide is not data. Four requirements presume a durable addressable object: `guide.settle.notify` has listeners, `guide.initialize.reset` discards what was held, `token.create` and `token.reuse` presume storage surviving between calls, and `guide.pass.single` presumes a Guide is a thing resolved by a pass rather than a value passed through. Recorded below as an order defect, since the conflict was with the order's acceptance text and not with the code.

**6. Guide.frame optional, nil before initialize.** Unaddressed, and consistent. `guide.initialize.reset` requires initialize to be callable more than once, which rules out an initializer only non optional Frame, and the optional is the consequence of that. The nil state itself is named by no requirement, and nothing enforces the ordering clause of `guide.initialize` because there is no workload yet to order against.

**7. A nominal struct wrapper rather than a typealias over UInt64.** Unaddressed, and consistent. A typealias would satisfy the letter of "unsigned integer" while leaving the identifier orderable and arithmetic; the wrapper is the stronger reading of "opaque".

## E. Test honesty

**`ValueSemanticsTests.swift:5`, `:15`, `:37`** — sampleCopyIsIndependent, strokeCopyIsIndependent, frameCopyIsIndependent. These assert nothing about value semantics. Each declares `var copy = original` and then reassigns `copy` to a wholly new instance; reassigning a variable never mutates the original under reference semantics either. All three pass verbatim if `Sample`, `Stroke` and `Frame` were final classes. Every stored member is `let`, so no mutation path exists through which value semantics could be observed at all. Correction accepted by the coordinator: assert the types are structs, which `Mirror` can check and which fails if one becomes a class.

**`IdentifierTests.swift:5`, `:10`, `:15`, `:25`** — the four equality and hashing tests. These assert synthesized `Hashable`, which is to say they assert that Swift works. They pass against a wrapper of any integer type, including one that Mobster dereferences, orders or does arithmetic on. Nothing in the file touches opacity. Correction accepted: opacity is a negative property no runtime test can assert and moves to acceptance as a grep, leaving the assertable remainder that the identifiers conform to nothing beyond Hashable and Sendable, and specifically not Comparable, not Strideable, and no arithmetic protocol.

**`ValueSemanticsTests.swift:46`** — equalValuesCompareEqual. Asserts synthesized `==`. It fails only if someone hand writes a wrong `==`, and it is the only consumer of the Hashable conformance flagged in B.

**`ValueSemanticsTests.swift:28`** — strokeRetainsSampleOrder. Honest. It fails if `Stroke` sorted its samples or held them in a set, and ordering is a property the order asked for at its deliverable line, "its ordered samples".

**`GuideTests.swift:5`** — initializeEstablishesSceneSpace. Honest against `guide.initialize`, though it reaches through the surface flagged in B.

**`GuideTests.swift:13`** — initializeReplacesPriorFrame. Named for `guide.initialize.reset` and asserts only that the second write to a property won. It cannot detect a failure to discard tokens or rebuild a membership, because neither exists. It passes against the current implementation, which discards nothing, and it would pass against any implementation that discards nothing. Vacuous against the requirement it is named for.

## Public surface, consumer against test

Genuinely needed by a consumer: `Frame` and its initialiser, supplied to `initialize`; `Guide`, its initialiser and `initialize`, instantiated and driven; `PointIdentifier` and `StrokeIdentifier` with their initialisers, minted and supplied; `Sample` and `Stroke` with their initialisers, supplied as membership under `mobster.transfer.event`.

Public only because a test reached for it: `Guide.frame` at `Guide.swift:3`, read at `GuideTests.swift:10` and `GuideTests.swift:20`. The harness supplies the Frame and never reads it back. This is the only member in the cut that meets that description exactly.

Public with no reader at all, neither consumer nor test: `PointIdentifier.value` at `PointIdentifier.swift:4` and `StrokeIdentifier.value` at `StrokeIdentifier.swift:4`.

Public and speculative rather than test driven: the members of `Frame`, `Sample` and `Stroke`. Tests read them at `ValueSemanticsTests.swift:10` through `:12`, `:24`, `:25`, `:34`, `:42` and `:43`, but they are supplied by the consumer through the memberwise initialiser and no code in the cut hands one back. `mobster.transfer.event` says advancement returns displaced locations with rectangles, not Samples, so a consumer reading these members is not yet a requirement anywhere.

## Internal plus @testable

Yes for `Guide.frame`, with no behavior change. All three test files already carry `@testable import Mobster` at `GuideTests.swift:2`, `IdentifierTests.swift:2` and `ValueSemanticsTests.swift:2`, which grants the test target access to internal declarations of the module built for testing. Dropping `public` from `Guide.swift:3` leaves `private(set) var frame: Frame?`, keeps `GuideTests.swift:10` and `GuideTests.swift:20` compiling unchanged, and removes the property from the harness's view. `Guide` itself stays public; a public class holding an internal member is unremarkable.

The same mechanism applies to the members of `Frame`, `Sample` and `Stroke` should you want them off the public surface, and construction survives because the memberwise initialisers at `Frame.swift:7`, `Sample.swift:6` and `Stroke.swift:6` are written explicitly and stay public. I did not compile that second variant and do not assert it beyond the mechanism.

## Order defects, recorded

**Corrected.** The acceptance line read "Every type crossing the boundary is a value type", which contradicted `mobster.transfer.value` as written and would have forced the Guide into a value type against `guide.settle.notify`, `guide.initialize.reset`, `token.create`, `token.reuse` and `guide.pass.single`. Corrected to name the Guide explicitly. The code was right.

**Corrected.** The requirement text of `guide.initialize` read "the Frame that defines scene space", which is circular: a Frame defining scene space cannot be positioned within the space it defines. Corrected to "the Frame it operates within ... a region in scene space and carries a position within it". `Frame.origin` was raised as a CE against the old text and is withdrawn against the new.

**Open.** The order's deliverable line still reads "A Guide type exposing `initialize`, receiving the Frame that defines scene space", carrying the same circular phrase that was removed from the requirement. The acceptance line was fixed and this one was not.

**Corrected.** The order's deliverable line asked for "Tests covering identifier opacity", which is a negative property no runtime test can assert. Moves to acceptance as a grep.

**Out of range.** The order's first deliverable, `Package.swift`, is at commit `1d9197c`, the base of the range given to me, so it is not part of the changeset under review. Its content matches Jerome on the two named axes: tools version 6.0 at `Package.swift:1` against `Jerome/Package.swift:1`, and platforms iOS 18 with macOS 15 at `Package.swift:7` and `Package.swift:8` against `Jerome/Package.swift:15` and `Jerome/Package.swift:16`. Language mode excluded from scope by instruction.

## IDEA

**IDEA, enhancement proposal.** The amended `guide.initialize` now carries three assertions under one identifier: that the Frame arrives before any workload, that it is a region in scene space, and that it carries a position within it. The sentence contains an "and", which by the principal's own rule marks a requirement needing a split. A later cut that satisfies the first two and fails the third has no URI to fail.

**IDEA, potential gap.** The copy of `Documentation/Design/Mobster.md` committed in the worktree at `b3247e2` is the earlier prose draft with Overview, Workflow and Prose sections, not the requirements document. An implementer working on `cycle/foundation` who opens the design document in the tree reads the wrong authority. The requirements version exists only as an uncommitted file in the main checkout.

## Unable to do

Nothing. Both authorities were readable, the changeset was fully readable, and the build and test claims were verified directly.
