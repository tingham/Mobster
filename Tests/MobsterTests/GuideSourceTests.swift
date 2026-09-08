import Testing
@testable import Mobster

struct GuideSourceTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func guide() -> Guide {
        Guide(frame: frame)
    }

    @Test func theLinesOfALineSourceAreVendedAsTheyArrived() throws {
        let supplied = [Line(verts: [
            Vert(location: SIMD2<Float>(64.5, 0)),
            Vert(location: SIMD2<Float>(64.5, 128)),
        ], identifier: LineIdentifier(3))]

        let guide = guide()
        try guide.initialize(source: .lines(supplied), frame: frame, adhesion: 1, duration: 1, settleEpsilon: 1, budget: .max)

        #expect(guide.lines.count == 1)
        #expect(guide.lines[0].identifier == LineIdentifier(3))
        #expect(guide.lines[0].verts.map(\.location) == supplied[0].verts.map(\.location))
    }

    @Test func aPresetIsInterpretedIntoLinesAgainstTheFrame() throws {
        let guide = guide()
        try guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 1, duration: 1, settleEpsilon: 1, budget: .max)

        #expect(guide.lines.count == 4)
        #expect(guide.lines.allSatisfy { $0.verts.count == 2 })
        #expect(abs(guide.lines[0].verts[0].location.x - 128 / 3) < 1e-3)
    }

    @Test func aGuideNeedsNoIdentifierOnTheLinesItInterprets() throws {
        let guide = guide()
        try guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 1, duration: 1, settleEpsilon: 1, budget: .max)

        #expect(guide.lines.allSatisfy { $0.identifier == nil })
        #expect(guide.lines.flatMap(\.verts).allSatisfy { $0.identifier == nil })
    }

    @Test func theFieldIsVendedAsARasterizationOfTheFrame() throws {
        let guide = guide()
        try guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 1, duration: 1, settleEpsilon: 1, budget: .max)
        let raster = guide.raster()

        // A square Frame of 128 within an epsilon of one, which is half a texel diagonal held inside the epsilon: 128 over the root of two, rounded up.
        #expect(raster?.columns == 91)
        #expect(raster?.rows == 91)
        #expect(raster?.samples.count == 91 * 91)
    }

    @Test func aSourceHoldingNoPathVendsNoRasterization() throws {
        let guide = guide()
        try guide.initialize(source: .lines([]), frame: frame, adhesion: 1, duration: 1, settleEpsilon: 1, budget: .max)

        #expect(guide.raster() == nil)
    }

    @Test func initializingAgainReplacesTheSourceTheFrameTheAdhesionAndTheDuration() throws {
        let guide = guide()
        try guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 0.25, duration: 2, settleEpsilon: 1, budget: .max)

        let replacement = Frame(origin: SIMD2<Float>(-50, -50), size: SIMD2<Float>(200, 200))
        try guide.initialize(source: .lines([Line(verts: [Vert(location: SIMD2<Float>(0, 0))])]), frame: replacement, adhesion: 0.75, duration: 9, settleEpsilon: 4, budget: .max)

        #expect(guide.lines.count == 1)
        #expect(guide.frame.origin == replacement.origin)
        #expect(guide.frame.size == replacement.size)
        #expect(guide.adhesion == 0.75)
        #expect(guide.duration == 9)
    }
}
