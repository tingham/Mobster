import Testing
@testable import Mobster

struct GuideAdherenceReachTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    /// The texel centres in opposite corners of a 128 by 128 Frame baked at resolution 128, the furthest a point in this Frame can be from this path.
    private let corner = SIMD2<Float>(0.5, 0.5)
    private let far = SIMD2<Float>(127.5, 127.5)

    private func guide(reach: Float, epsilon: Float = 1) -> Guide {
        let guide = Guide(frame: frame, adherence: Adherence(reach: reach), settleEpsilon: epsilon)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: far),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(paths: [[corner]], resolution: 128, time: 0)
        return guide
    }

    private func residual(reach: Float) -> Float {
        let guide = guide(reach: reach)
        _ = guide.play(speed: 1000, time: 1000)
        let run = (guide.tokens[PointIdentifier(1)]?.location ?? far) - corner
        return (run.x * run.x + run.y * run.y).squareRoot()
    }

    @Test func theFullAdherenceReachFollowsFromTheFrameAndTheEpsilon() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 0), settleEpsilon: 1)
        guide.initialize(frame: frame)

        // The diagonal of the Frame is 181.01933, and 181.01933 times the square root of 180.01933.
        #expect(abs(guide.fullAdherenceReach - 2428.7598) < 1e-2)
    }

    @Test func theFullAdherenceReachFollowsTheEpsilonSupplied() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 0), settleEpsilon: 4)
        guide.initialize(frame: frame)

        #expect(abs(guide.fullAdherenceReach - 1204.2185) < 1e-2)
    }

    @Test func theFullAdherenceReachGrowsFasterThanTheFrame() {
        let small = Guide(frame: frame, adherence: Adherence(reach: 0), settleEpsilon: 1)
        small.initialize(frame: frame)
        let large = Guide(frame: frame, adherence: Adherence(reach: 0), settleEpsilon: 1)
        large.initialize(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(256, 256)))

        #expect(abs(large.fullAdherenceReach - 6879.1025) < 1e-1)
        // Twice the Frame, two and five sixths the reach.
        #expect(large.fullAdherenceReach / small.fullAdherenceReach > 2.8)
    }

    @Test func theWorstCasePointSettlesAtTheFullAdherenceReach() {
        let vending = Guide(frame: frame, adherence: Adherence(reach: 0), settleEpsilon: 1)
        vending.initialize(frame: frame)
        let reach = vending.fullAdherenceReach ?? 0

        let guide = guide(reach: reach)
        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        _ = guide.play(speed: 1000, time: 1000)

        #expect(abs(residual(reach: reach) - 0.9768142) < 1e-4)
        #expect(residual(reach: reach) < guide.settleEpsilon)
        #expect(count.value == 1)
    }

    @Test func aReachEqualToTheFrameLeavesThePointFarShort() {
        #expect(abs(residual(reach: 181.01933) - 89.098236) < 1e-3)
    }

    @Test func aReachTenTimesTheFrameStillLeavesItShort() {
        #expect(abs(residual(reach: 1810.1933) - 1.7508489) < 1e-3)
    }
}
