import Testing
@testable import Mobster

struct CurvePresetTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))

    private func preset(control: SIMD2<Float>, distance: Float, resolution: Int) -> CurvePreset {
        CurvePreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 0, secondDegree: 180, distance: distance, control: control, resolution: resolution)
    }

    @Test func aCurveAndAParallelPairAreProduced() {
        #expect(preset(control: SIMD2<Float>(0.5, 0.8), distance: 0.1, resolution: 8).paths(in: frame, mode: .aspect).count == 3)
    }

    @Test func resolutionSetsTheSampleCount() {
        for resolution in [1, 4, 32] {
            let paths = preset(control: SIMD2<Float>(0.5, 0.8), distance: 0.1, resolution: resolution).paths(in: frame, mode: .aspect)
            #expect(paths.allSatisfy { $0.count == resolution + 1 })
        }
    }

    @Test func aControlOnTheChordYieldsAStraightRun() {
        let paths = preset(control: SIMD2<Float>(0.5, 0.5), distance: 0, resolution: 8).paths(in: frame, mode: .aspect)

        #expect(paths[0].allSatisfy { abs($0.y - 50) < 0.01 })
    }

    @Test func aControlOffTheChordBowsTheRun() {
        let paths = preset(control: SIMD2<Float>(0.5, 1.0), distance: 0, resolution: 8).paths(in: frame, mode: .aspect)
        let midpoint = paths[0][4]

        #expect(midpoint.y > 60)
    }

    @Test func theCurveStartsAndEndsOnTheChord() {
        let paths = preset(control: SIMD2<Float>(0.5, 1.0), distance: 0, resolution: 8).paths(in: frame, mode: .aspect)

        #expect(abs(paths[0].first!.x - 100) < 0.001)
        #expect(abs(paths[0].last!.x - 0) < 0.001)
    }

    @Test func thePairIsOffsetEitherSideOfTheCurve() {
        let paths = preset(control: SIMD2<Float>(0.5, 0.8), distance: 0.1, resolution: 8).paths(in: frame, mode: .aspect)
        let base = paths[0][4].y

        #expect(abs(abs(paths[1][4].y - base) - 10) < 0.01)
        #expect((paths[1][4].y - base) * (paths[2][4].y - base) < 0)
    }
}
