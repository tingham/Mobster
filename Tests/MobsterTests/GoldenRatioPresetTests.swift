import Testing
@testable import Mobster

struct GoldenRatioPresetTests {
    @Test func theSpiralIsReadFromTheResource() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
        let paths = GoldenRatioPreset().paths(in: frame, mode: .aspect)

        #expect(paths.count == 1)
        #expect(paths[0].count > 100)
    }

    @Test func aspectPlottingFillsTheFrame() {
        let frame = Frame(origin: SIMD2<Float>(10, 20), size: SIMD2<Float>(300, 200))
        let locations = GoldenRatioPreset().paths(in: frame, mode: .aspect).flatMap { $0 }

        #expect(abs(locations.map(\.x).min()! - 10) < 0.01)
        #expect(abs(locations.map(\.x).max()! - 310) < 0.01)
        #expect(abs(locations.map(\.y).min()! - 20) < 0.01)
        #expect(abs(locations.map(\.y).max()! - 220) < 0.01)
    }

    @Test func boundsPlottingEncompassesTheFrame() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
        let locations = GoldenRatioPreset().paths(in: frame, mode: .bounds).flatMap { $0 }

        #expect(locations.map(\.x).min()! <= 0.01)
        #expect(locations.map(\.x).max()! >= 99.99)
        #expect(locations.map(\.y).min()! <= 0.01)
        #expect(locations.map(\.y).max()! >= 99.99)
    }

    @Test func boundsPlottingHoldsTheStandardRatio() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
        let locations = GoldenRatioPreset().paths(in: frame, mode: .bounds).flatMap { $0 }
        let width = locations.map(\.x).max()! - locations.map(\.x).min()!
        let height = locations.map(\.y).max()! - locations.map(\.y).min()!

        #expect(abs(width / height - 1.618034) < 0.001)
    }
}
