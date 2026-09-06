import Testing
@testable import Mobster

struct GuideSourceTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    private let path = [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]]

    private func guide() -> Guide {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 30), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        return guide
    }

    @Test func pathsBakeAFieldTheTargetsResolveAgainst() {
        let guide = guide()
        guide.update(paths: path, resolution: 128, time: 0)

        // Forty units out, a reach of thirty, so nine twenty fifths of the distance: 24.5 + 14.4.
        #expect(abs((guide.tokens[PointIdentifier(1)]?.target.x ?? 0) - 38.9) < 1e-3)
    }

    @Test func pathsBakeAgainstTheFrameTheGuideOperatesWithin() {
        let guide = guide()
        guide.update(paths: path, resolution: 128, time: 0)

        #expect(guide.field?.columns == 128)
        #expect(guide.field?.rows == 128)
        #expect(guide.field?.frame.size == frame.size)
    }

    @Test func bakedPathsEndTheSegmentInFlight() {
        let guide = guide()
        guide.update(paths: path, resolution: 128, time: 0)
        _ = guide.play(speed: 10, time: 1)

        guide.update(paths: [[SIMD2<Float>(0.5, 0), SIMD2<Float>(0.5, 128)]], resolution: 128, time: 4)
        let token = guide.tokens[PointIdentifier(1)]

        #expect(token?.location == SIMD2<Float>(34.5, 64.5))
        #expect(token?.anchor == SIMD2<Float>(34.5, 64.5))
        #expect(token?.origin == 4)
    }
}
