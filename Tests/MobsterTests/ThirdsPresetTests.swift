import Testing
@testable import Mobster

struct ThirdsPresetTests {
    @Test func threeColumnsAndThreeRowsYieldFourLines() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(90, 60))
        #expect(ThirdsPreset().paths(in: frame).count == 4)
    }

    @Test func linesSitAtThirdsOfTheFrame() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(90, 60))
        let paths = ThirdsPreset().paths(in: frame)

        #expect(abs(paths[0][0].x - 30) < 0.001)
        #expect(abs(paths[1][0].x - 60) < 0.001)
        #expect(abs(paths[2][0].y - 20) < 0.001)
        #expect(abs(paths[3][0].y - 40) < 0.001)
    }

    @Test func linesTrackAFrameOrigin() {
        let frame = Frame(origin: SIMD2<Float>(100, 50), size: SIMD2<Float>(90, 60))
        let paths = ThirdsPreset().paths(in: frame)

        #expect(abs(paths[0][0].x - 130) < 0.001)
        #expect(abs(paths[2][0].y - 70) < 0.001)
    }
}
