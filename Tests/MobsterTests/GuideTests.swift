import Testing
@testable import Mobster

struct GuideTests {
    @Test func initializeSuppliesANewFrame() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1024, 768))
        let guide = Guide(frame: frame, adherence: Adherence(reach: 10), settleEpsilon: 1)

        let replacement = Frame(origin: SIMD2<Float>(-50, -50), size: SIMD2<Float>(200, 200))
        guide.initialize(frame: replacement)

        #expect(guide.frame.origin == replacement.origin)
        #expect(guide.frame.size == replacement.size)
    }

    @Test func initializeDiscardsEveryToken() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
        let guide = Guide(frame: frame, adherence: Adherence(reach: 10), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(10, 10)),
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(20, 20)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        #expect(guide.tokens.count == 2)

        let replacement = Stroke(identifier: StrokeIdentifier(2), samples: [
            Sample(identifier: PointIdentifier(3), location: SIMD2<Float>(30, 30)),
        ])
        guide.initialize(frame: frame, membership: [replacement])

        #expect(guide.tokens.count == 1)
        #expect(guide.membership == [PointIdentifier(3)])
    }

    @Test func theFrameArrivesWithTheGuide() {
        let frame = Frame(origin: SIMD2<Float>(-50, -50), size: SIMD2<Float>(200, 300))
        let guide = Guide(frame: frame, adherence: Adherence(reach: 10), settleEpsilon: 1)

        #expect(guide.frame.origin == frame.origin)
        #expect(guide.frame.size == frame.size)
    }

    @Test func aGuideWorksBeforeInitializeBecauseItAlreadyHasItsFrame() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
        let guide = Guide(frame: frame, adherence: Adherence(reach: 30), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.tokenize(membership: [stroke], time: 0)
        guide.update(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], resolution: 128, time: 0)

        #expect(guide.tokens.count == 1)
        #expect(abs((guide.tokens[PointIdentifier(1)]?.target.x ?? 0) - 38.9) < 1e-3)
    }
}
