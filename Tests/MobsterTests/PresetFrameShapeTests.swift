import Testing
@testable import Mobster

struct PresetFrameShapeTests {
    static let wide = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1920, 1080))
    static let tall = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1080, 1920))

    @Test(arguments: 0 ..< PresetDeterminismTests.plotters.count, [PresetPlotMode.aspect, PresetPlotMode.bounds])
    func aWideFrameYieldsFiniteLocations(index: Int, mode: PresetPlotMode) {
        let paths = PresetDeterminismTests.plotters[index](Self.wide, mode)

        #expect(!paths.isEmpty)
        #expect(paths.allSatisfy { $0.count >= 2 })
        #expect(paths.allSatisfy { $0.allSatisfy { $0.x.isFinite && $0.y.isFinite } })
    }

    @Test(arguments: 0 ..< PresetDeterminismTests.plotters.count, [PresetPlotMode.aspect, PresetPlotMode.bounds])
    func aTallFrameYieldsFiniteLocations(index: Int, mode: PresetPlotMode) {
        let paths = PresetDeterminismTests.plotters[index](Self.tall, mode)

        #expect(!paths.isEmpty)
        #expect(paths.allSatisfy { $0.count >= 2 })
        #expect(paths.allSatisfy { $0.allSatisfy { $0.x.isFinite && $0.y.isFinite } })
    }
}
