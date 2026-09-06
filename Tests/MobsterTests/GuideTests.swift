import Testing
@testable import Mobster

struct GuideTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    @Test func theFrameArrivesWithTheGuide() {
        let guide = Guide(frame: frame, settleEpsilon: 1)

        #expect(guide.frame.origin == frame.origin)
        #expect(guide.frame.size == frame.size)
    }

    @Test func theEpsilonArrivesWithTheGuide() {
        #expect(Guide(frame: frame, settleEpsilon: 3).settleEpsilon == 3)
    }

    @Test func aGuideBeforeInitializeHoldsNoLineAndDisplacesNothing() {
        let guide = Guide(frame: frame, settleEpsilon: 1)
        let content = [Line(verts: [Vert(location: SIMD2<Float>(24.5, 64.5))])]

        #expect(guide.lines.isEmpty)
        #expect(guide.raster() == nil)
        #expect(guide.evaluate(content, at: 1000)[0].verts[0].location == SIMD2<Float>(24.5, 64.5))
    }

    @Test func aGuideRetainsNothingAboutTheContentItEvaluated() {
        let guide = Guide(frame: frame, settleEpsilon: 1)
        guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 1, duration: 1, resolution: 128)
        _ = guide.evaluate([Line(verts: [Vert(location: SIMD2<Float>(24.5, 64.5))])], at: 1)

        #expect(guide.lines.count == 4)
        #expect(guide.evaluate([], at: 1).isEmpty)
    }
}
