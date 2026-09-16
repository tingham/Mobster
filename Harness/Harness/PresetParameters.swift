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
    /// Head space, measured from the centre of the cranial mass in head heights. Opening level with the head and off to the side, which is the three quarter view.
    var headTarget = SIMD3<Float>(1, 0, 1)
    /// Degrees about forward.
    var headRoll: Float = 0
    var ashcanSex: AshcanSex = .male
    var ashcanHeads: Float = 8
    /// Figure space, measured from the middle of the figure: x across, y downward, z out of the chest. Opening straight out of the chest, which is the frontal view.
    var ashcanTarget = SIMD3<Float>(0, 0, 1)
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
    /// Locations each extracted boundary is fitted to, which every mesh preset is read at.
    var meshFit: Int = 12
    /// Degrees. The field of view every mesh preset is projected through, opening at the cone of vision.
    var meshFieldOfView: Float = MeshPerspective.opening
    /// A fraction of the Frame, locating the centre of the box.
    var cubePosition = SIMD2<Float>(0.5, 0.5)
    /// The edge of the box as a fraction of the lesser axis of the Frame.
    var cubeSize: Float = 0.5
    /// Box space, measured from its centre: x across, y downward, z out of the near face. Opening down the body diagonal, which is the view three faces read from.
    var cubeTarget = SIMD3<Float>(1, 1.7320508, 1.4142135)
}
