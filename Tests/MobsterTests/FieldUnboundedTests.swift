import Testing
@testable import Mobster

struct FieldUnboundedTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    private let paths = [[SIMD2<Float>(100, 100), SIMD2<Float>(500, 100), SIMD2<Float>(500, 300)]]
    private let budget = 2_000_000

    private func bake(epsilon: Float, frame: Frame? = nil) -> FieldBake {
        FieldBake(paths: paths, frame: frame ?? self.frame, settleEpsilon: epsilon, budget: budget)
    }

    @Test(arguments: [Float(0), -1, -1000]) func anEpsilonAtOrBelowZeroIsRefused(epsilon: Float) throws {
        let refusal = try #require(throws: FieldRefusal.self) { try bake(epsilon: epsilon).field() }

        #expect(refusal.epsilon == epsilon)
    }

    /// The refusal is what the harness opening reads, so the epsilon it names has to be one this same bake pays for rather than a bound on one.
    @Test func theUnboundedRefusalReportsAnAffordableEpsilon() throws {
        let refusal = try #require(throws: FieldRefusal.self) { try bake(epsilon: 0).field() }
        let field = try bake(epsilon: refusal.affordable).field()

        #expect(refusal.affordable.isFinite)
        #expect(!field.isEmpty)
        #expect(field.columns * field.rows * 2 <= budget)
    }

    /// The same answer a refusal for cost gives, the unbounded ask differing only in that no epsilon it could have asked for would have been cheaper.
    @Test func theUnboundedRefusalAffordsWhatARefusalForCostAffords() throws {
        let unbounded = try #require(throws: FieldRefusal.self) { try bake(epsilon: 0).field() }
        let costly = try #require(throws: FieldRefusal.self) { try bake(epsilon: 0.01).field() }

        #expect(unbounded.affordable == costly.affordable)
    }

    /// A budget the segments alone outrun affords nothing, which an unbounded ask reports as any other refusal does.
    @Test func anUnpayableBudgetAffordsNoEpsilon() throws {
        let refusal = try #require(throws: FieldRefusal.self) {
            try FieldBake(paths: paths, frame: frame, settleEpsilon: 0, budget: 1).field()
        }

        #expect(refusal.affordable == .infinity)
    }

    /// The two failures are separate: a Frame with nothing to bake into is empty however unbounded the epsilon it was handed.
    @Test func aFrameWithNoExtentBakesEmptyAtAnUnboundedEpsilon() throws {
        let flat = try bake(epsilon: 0, frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 0))).field()
        let thin = try bake(epsilon: 0, frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(0, 400))).field()

        #expect(flat.isEmpty)
        #expect(thin.isEmpty)
    }

    /// How a consumer holding a Guide learns the epsilon it can pay for, there being no query that answers it.
    @Test func aGuideAskedForAnUnboundedEpsilonRefusesForTheBake() throws {
        let guide = Guide(frame: frame)
        let lines = paths.map { path in Line(verts: path.map { Vert(location: $0) }) }
        let refusal = try #require(throws: GuideRefusal.self) {
            try guide.initialize(source: .lines(lines), frame: frame, adhesion: 1, duration: 1, settleEpsilon: 0, budget: budget)
        }

        guard case let .field(bake) = refusal else {
            #expect(Bool(false), "an unbounded epsilon reaches the caller as the field case")
            return
        }

        #expect(bake.epsilon == 0)
        #expect(bake.affordable.isFinite)
    }
}
