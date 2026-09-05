# Cut 6: Fixture

The target points a Guide manipulates. Data only, plus the harness drawing it.

## Requirements covered

harness.fixture, and it exercises mobster.identity.opaque, mobster.transfer.value

## What this is for

Everything built so far produces guide paths. Nothing yet produces the POINTS a guide acts on. Without a population of target points there is nothing to displace, nothing to tokenize, and nothing to watch settle. This cut supplies that population and puts it on screen next to the guides.

## Deliverables

- A fixture producing a nominally complex population of strokes, each carrying ordered points with identifiers.
- The population is SEEDED and deterministic. The same seed and the same parameters produce an identical population every time, point identifiers included.
- Parameters: stroke count, points per stroke, and the seed. Anything else that shapes the population is also a parameter.
- The harness draws the fixture population inside the Frame, distinguishable from the guide paths.
- Harness sliders for every fixture parameter, and a control to reseed.
- Tests.

## Constraints

- Swift only. No Metal.
- One type per file. No extension islands.
- Identifiers are minted by the FIXTURE, which stands in for the consumer. Mobster itself never mints an identifier, and nothing in the Mobster library sources may gain that ability through this cut. If the fixture belongs outside the package for that reason, say so rather than putting a mint inside it.
- Determinism comes from the seed, not from a clock. No wall clock, no drawn random state that is not seeded.
- Guide paths draw in cyan. Choose a different, clearly distinguishable treatment for fixture points and say what you chose.

## Acceptance

`swift build` and `swift test` green. `xcodebuild` on the harness succeeds. The same seed produces byte identical output across two separate processes, not merely twice in one. Changing the seed changes the population. Point identifiers are unique across the whole population, not merely within a stroke.
