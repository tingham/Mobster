import Testing
@testable import Mobster

struct GuideEpsilonTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field() -> Field {
        FieldFixture.field(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], frame: frame, count: 128)
    }

    /// The point starts forty units from the path and a reach of forty carries it half way, so it targets 44.5 and the play stops it short of that by the gap asked for.
    private func fires(stoppingShortBy gap: Double, epsilon: Float) -> Int {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 40), settleEpsilon: epsilon)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)

        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        _ = guide.play(speed: 1, time: 20 - gap)
        return count.value
    }

    @Test func aPointStoppingInsideTheEpsilonHasSettled() {
        #expect(fires(stoppingShortBy: 0.9, epsilon: 1) == 1)
    }

    @Test func aPointStoppingBeyondTheEpsilonHasNot() {
        #expect(fires(stoppingShortBy: 1.1, epsilon: 1) == 0)
    }

    @Test func theSuppliedEpsilonDecidesTheSameStopEitherWay() {
        #expect(fires(stoppingShortBy: 0.9, epsilon: 0.5) == 0)
        #expect(fires(stoppingShortBy: 0.9, epsilon: 2) == 1)
    }
}
