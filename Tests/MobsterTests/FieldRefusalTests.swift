import Testing
@testable import Mobster

struct FieldRefusalTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1000, 700))
    /// Four segments, so the cost of a bake is four times its texels.
    private let paths = [[SIMD2<Float>(100, 100), SIMD2<Float>(900, 100), SIMD2<Float>(900, 600)], [SIMD2<Float>(100, 600), SIMD2<Float>(500, 350), SIMD2<Float>(100, 100)]]
    private let segments = 4

    private var lines: [Line] {
        paths.map { path in Line(verts: path.map { Vert(location: $0) }) }
    }

    private func bake(epsilon: Float, budget: Int) -> FieldBake {
        FieldBake(paths: paths, frame: frame, settleEpsilon: epsilon, budget: budget)
    }

    @Test func aBakeWithinTheBudgetIsNotRefused() throws {
        let field = try bake(epsilon: 1, budget: 2_000_000).field()

        #expect(field.columns == 708)
        #expect(field.locations.count == field.columns * field.rows)
    }

    @Test func aBakeBeyondTheBudgetIsRefused() {
        #expect(throws: FieldRefusal.self) { try bake(epsilon: 1, budget: 10_000).field() }
    }

    @Test func theRefusalReportsTheEpsilonAskedFor() throws {
        let refusal = try #require(throws: FieldRefusal.self) { try bake(epsilon: 1, budget: 10_000).field() }

        #expect(refusal.epsilon == 1)
        #expect(refusal.affordable > refusal.epsilon)
    }

    @Test func theAffordableEpsilonIsAccepted() throws {
        let refusal = try #require(throws: FieldRefusal.self) { try bake(epsilon: 1, budget: 10_000).field() }
        let field = try bake(epsilon: refusal.affordable, budget: 10_000).field()

        #expect(field.columns * field.rows * segments <= 10_000)
        #expect(field.locations.count == field.columns * field.rows)
    }

    /// The finest one, not merely one that fits: a single texel more across the Frame is a bake the same budget will not pay for.
    @Test func theAffordableEpsilonIsTheFinestTheBudgetBuys() throws {
        let refusal = try #require(throws: FieldRefusal.self) { try bake(epsilon: 1, budget: 10_000).field() }
        let afforded = FieldResolution(frame: frame, settleEpsilon: refusal.affordable)
        let finer = FieldResolution(frame: frame, settleEpsilon: FieldResolution.epsilon(count: afforded.count + 1, frame: frame))

        #expect(afforded.texels * segments <= 10_000)
        #expect(finer.texels * segments > 10_000)
    }

    /// One texel is the least a bake can cost, so a budget the segments alone outrun leaves no epsilon to offer.
    @Test func aBudgetTheSegmentsAloneOutrunAffordsNoEpsilon() throws {
        let refusal = try #require(throws: FieldRefusal.self) { try bake(epsilon: 1, budget: segments - 1).field() }

        #expect(refusal.affordable == .infinity)
        #expect(try bake(epsilon: refusal.affordable, budget: segments - 1).field().isEmpty)
    }

    @Test func aGuideBakingItsSourceCarriesTheRefusalToItsCaller() {
        let guide = Guide(frame: frame)

        #expect(throws: FieldRefusal.self) {
            try guide.initialize(source: .lines(lines), frame: frame, adhesion: 1, duration: 1, settleEpsilon: 1, budget: 10_000)
        }
    }

    /// A refused bake replaces nothing, so the Guide a consumer already holds keeps answering for the source it did bake.
    @Test func aRefusedGuideStandsAsItDidBeforeTheAttempt() throws {
        let guide = Guide(frame: frame)
        try guide.initialize(source: .lines(lines), frame: frame, adhesion: 0.5, duration: 3, settleEpsilon: 4, budget: .max)

        #expect(throws: FieldRefusal.self) {
            try guide.initialize(source: .lines(lines), frame: frame, adhesion: 1, duration: 9, settleEpsilon: 1, budget: 10_000)
        }

        #expect(guide.adhesion == 0.5)
        #expect(guide.duration == 3)
        #expect(guide.settleEpsilon == 4)
        #expect(guide.lines.count == lines.count)
    }
}
