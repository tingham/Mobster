import Testing
@testable import Mobster

struct GuideSourceTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func guide() -> Guide {
        Guide(frame: frame, settleEpsilon: 1)
    }

    @Test func theLinesOfALineSourceAreVendedAsTheyArrived() {
        let supplied = [Line(verts: [
            Vert(location: SIMD2<Float>(64.5, 0)),
            Vert(location: SIMD2<Float>(64.5, 128)),
        ], identifier: LineIdentifier(3))]

        let guide = guide()
        guide.initialize(source: .lines(supplied), frame: frame, adhesion: 1, duration: 1, resolution: 128)

        #expect(guide.lines.count == 1)
        #expect(guide.lines[0].identifier == LineIdentifier(3))
        #expect(guide.lines[0].verts.map(\.location) == supplied[0].verts.map(\.location))
    }

    @Test func aPresetIsInterpretedIntoLinesAgainstTheFrame() {
        let guide = guide()
        guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 1, duration: 1, resolution: 128)

        #expect(guide.lines.count == 4)
        #expect(guide.lines.allSatisfy { $0.verts.count == 2 })
        #expect(abs(guide.lines[0].verts[0].location.x - 128 / 3) < 1e-3)
    }

    @Test func aGuideNeedsNoIdentifierOnTheLinesItInterprets() {
        let guide = guide()
        guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 1, duration: 1, resolution: 128)

        #expect(guide.lines.allSatisfy { $0.identifier == nil })
        #expect(guide.lines.flatMap(\.verts).allSatisfy { $0.identifier == nil })
    }

    @Test func theFieldIsVendedAsARasterizationOfTheFrame() {
        let guide = guide()
        guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 1, duration: 1, resolution: 128)
        let raster = guide.raster()

        #expect(raster?.columns == 128)
        #expect(raster?.rows == 128)
        #expect(raster?.samples.count == 128 * 128)
    }

    @Test func aSourceHoldingNoPathVendsNoRasterization() {
        let guide = guide()
        guide.initialize(source: .lines([]), frame: frame, adhesion: 1, duration: 1, resolution: 128)

        #expect(guide.raster() == nil)
    }

    @Test func initializingAgainReplacesTheSourceTheFrameTheAdhesionAndTheDuration() {
        let guide = guide()
        guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 0.25, duration: 2, resolution: 128)

        let replacement = Frame(origin: SIMD2<Float>(-50, -50), size: SIMD2<Float>(200, 200))
        guide.initialize(source: .lines([Line(verts: [Vert(location: SIMD2<Float>(0, 0))])]), frame: replacement, adhesion: 0.75, duration: 9, resolution: 64)

        #expect(guide.lines.count == 1)
        #expect(guide.frame.origin == replacement.origin)
        #expect(guide.frame.size == replacement.size)
        #expect(guide.adhesion == 0.75)
        #expect(guide.duration == 9)
    }
}
