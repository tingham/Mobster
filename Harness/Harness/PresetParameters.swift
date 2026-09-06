/// Every dial the harness offers. Each preset keeps its own values so switching presets does not disturb a magnitude already dialled in on another.
struct PresetParameters: Hashable, Sendable {
    var columnCount: Int = 4
    var columnGutter: Float = 0.02
    var rowCount: Int = 4
    var rowGutter: Float = 0.02
    var gridCount: Int = 4
    var gridGutter: Float = 0.02
    var rulerCenter: SIMD2<Float> = SIMD2<Float>(0.5, 0.5)
    var rulerFirstDegree: Float = 0
    var rulerSecondDegree: Float = 180
    var rulerDistance: Float = 0.1
    var curveCenter: SIMD2<Float> = SIMD2<Float>(0.5, 0.5)
    var curveFirstDegree: Float = 0
    var curveSecondDegree: Float = 180
    var curveDistance: Float = 0.1
    var curveControl: SIMD2<Float> = SIMD2<Float>(0.5, 0.25)
    var curveResolution: Int = 32
}
