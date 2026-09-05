import Testing
@testable import Mobster

struct RulerPresetTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))

    @Test func aLineAndAParallelPairAreProduced() {
        let preset = RulerPreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 0, secondDegree: 180, distance: 0.1)
        #expect(preset.paths(in: frame, mode: .aspect).count == 3)
    }

    @Test func theLineCrossesTheFrame() {
        let preset = RulerPreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 0, secondDegree: 180, distance: 0)
        let line = preset.paths(in: frame, mode: .aspect)[0]

        #expect(abs(line[0].x - 100) < 0.001)
        #expect(abs(line[1].x - 0) < 0.001)
        #expect(abs(line[0].y - 50) < 0.01)
        #expect(abs(line[1].y - 50) < 0.01)
    }

    @Test func thePairIsOffsetEitherSideOfTheLine() {
        let preset = RulerPreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 0, secondDegree: 180, distance: 0.1)
        let paths = preset.paths(in: frame, mode: .aspect)
        let base = paths[0][0].y
        let leading = paths[1][0].y
        let trailing = paths[2][0].y

        #expect(abs(abs(leading - base) - 10) < 0.01)
        #expect(abs(abs(trailing - base) - 10) < 0.01)
        #expect((leading - base) * (trailing - base) < 0)
    }

    @Test func eachParallelCrossesTheFrame() {
        let preset = RulerPreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 0, secondDegree: 90, distance: 0.1)

        for path in preset.paths(in: frame, mode: .aspect) {
            for location in path {
                #expect(onEdge(location))
            }
        }
    }

    @Test func aZeroDistanceCollapsesThePairOntoTheLine() {
        let preset = RulerPreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 30, secondDegree: 200, distance: 0)
        let paths = preset.paths(in: frame, mode: .aspect)

        #expect(paths[0] == paths[1])
        #expect(paths[0] == paths[2])
    }

    @Test func degreesSweepTheLineAboutTheCenter() {
        let vertical = RulerPreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 90, secondDegree: 270, distance: 0)
        let line = vertical.paths(in: frame, mode: .aspect)[0]

        #expect(abs(line[0].y - 100) < 0.001)
        #expect(abs(line[1].y - 0) < 0.001)
        #expect(abs(line[0].x - 50) < 0.01)
    }

    private func onEdge(_ location: SIMD2<Float>) -> Bool {
        let low = frame.origin
        let high = frame.origin + frame.size
        let inside = location.x >= low.x - 0.01 && location.x <= high.x + 0.01 && location.y >= low.y - 0.01 && location.y <= high.y + 0.01
        let touching = abs(location.x - low.x) < 0.01 || abs(location.x - high.x) < 0.01 || abs(location.y - low.y) < 0.01 || abs(location.y - high.y) < 0.01
        return inside && touching
    }
}
