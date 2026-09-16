import Mobster

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
    var headSex: HeadSex = .male
    /// Opening at the middle of the range, which is the three quarter view.
    var headView: Float = 0.5
    var ashcanSex: AshcanSex = .male
    var ashcanHeads: Float = 8
    var ashcanLeftHand = SIMD2<Float>(0.31, 0.5)
    var ashcanRightHand = SIMD2<Float>(0.69, 0.5)
    var ashcanLeftFoot = SIMD2<Float>(0.42, 1)
    var ashcanRightFoot = SIMD2<Float>(0.58, 1)
    /// Degrees, cast the way the ruler casts them: zero along positive x, rising toward positive y.
    var ashcanLeftElbowDegree: Float = 180
    var ashcanRightElbowDegree: Float = 0
    var ashcanLeftKneeDegree: Float = 180
    var ashcanRightKneeDegree: Float = 0
    var ashcanHeadLines = true
}
