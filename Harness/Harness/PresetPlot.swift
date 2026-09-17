import Foundation
import Metal
import Mobster

/// The paths on screen, what the device refused if it refused anything, and the time the preset took to produce those same paths.
struct PresetPlot {
    let paths: [[SIMD2<Float>]]
    /// Nil where nothing was refused. A mesh preset extracts through the device and a device can refuse, which no plotted preset can.
    let refusal: MeshRefusal?
    let duration: Duration

    /// The device is the consumer's to supply and a mesh source is the only thing that needs one, so it arrives beside the parameters rather than inside the package.
    init(kind: PresetKind, parameters: PresetParameters, frame: Frame, focus: PresetFocus, device: (any MTLDevice)?) {
        var produced: [[SIMD2<Float>]] = []
        var refused: MeshRefusal?
        let elapsed = ContinuousClock().measure {
            do throws(MeshRefusal) {
                produced = try Self.generate(kind: kind, parameters: parameters, frame: frame, focus: focus, device: device)
            } catch {
                refused = error
            }
        }
        paths = produced
        refusal = refused
        duration = elapsed
    }

    private static func generate(kind: PresetKind, parameters: PresetParameters, frame: Frame, focus: PresetFocus, device: (any MTLDevice)?) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        switch kind {
        case .goldenRatio:
            GoldenRatioPreset(focus: focus).paths(in: frame)
        case .thirds:
            ThirdsPreset().paths(in: frame)
        case .columns:
            ColumnsPreset(count: parameters.columnCount, gutter: parameters.columnGutter).paths(in: frame)
        case .rows:
            RowsPreset(count: parameters.rowCount, gutter: parameters.rowGutter).paths(in: frame)
        case .grid:
            GridPreset(count: parameters.gridCount, gutter: parameters.gridGutter).paths(in: frame)
        case .ruler:
            RulerPreset(center: parameters.rulerCenter,
                        firstDegree: parameters.rulerFirstDegree,
                        secondDegree: parameters.rulerSecondDegree,
                        distance: parameters.rulerDistance).paths(in: frame)
        case .curve:
            CurvePreset(center: parameters.curveCenter,
                        firstDegree: parameters.curveFirstDegree,
                        secondDegree: parameters.curveSecondDegree,
                        distance: parameters.curveDistance,
                        control: parameters.curveControl,
                        resolution: parameters.curveResolution).paths(in: frame)
        case .head:
            try head(parameters: parameters, frame: frame, device: device)
        case .figure:
            try figure(parameters: parameters, frame: frame, device: device)
        case .cube:
            try cube(parameters: parameters, frame: frame, device: device)
        }
    }

    private static func head(parameters: PresetParameters, frame: Frame, device: (any MTLDevice)?) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        guard let device else { return [] }
        let construction = HeadPreset(sex: parameters.headSex, target: parameters.headTarget, roll: roll(parameters.headRoll))

        return try MeshExtraction(mesh: construction.mesh(in: frame), frame: frame, fit: parameters.meshFit, perspective: MeshPerspective(fieldOfView: parameters.meshFieldOfView)).paths(device: device)
    }

    /// The break lines measure the figure rather than belonging to it, so they are appended as paths after the extracted boundaries.
    private static func figure(parameters: PresetParameters, frame: Frame, device: (any MTLDevice)?) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        guard let device else { return [] }
        let figure = FigurePreset(sex: parameters.figureSex,
                                  heads: parameters.figureHeads,
                                  target: parameters.figureTarget,
                                  leftHand: parameters.figureLeftHand,
                                  rightHand: parameters.figureRightHand,
                                  leftFoot: parameters.figureLeftFoot,
                                  rightFoot: parameters.figureRightFoot,
                                  headLines: parameters.figureHeadLines)
        let extracted = try MeshExtraction(mesh: figure.mesh(in: frame), frame: frame, fit: parameters.meshFit, perspective: MeshPerspective(fieldOfView: parameters.meshFieldOfView)).paths(device: device)

        return extracted + figure.breakLines(in: frame)
    }

    /// Every mac this harness runs on carries a device, so the absent case is the API's rather than a state the harness presents.
    private static func cube(parameters: PresetParameters, frame: Frame, device: (any MTLDevice)?) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        guard let device else { return [] }
        let box = CubeMesh(position: parameters.cubePosition, size: parameters.cubeSize, target: parameters.cubeTarget)

        return try MeshExtraction(mesh: box.mesh(in: frame), frame: frame, fit: parameters.meshFit, perspective: MeshPerspective(fieldOfView: parameters.meshFieldOfView)).paths(device: device)
    }

    /// The panel dials a roll as a degree, which the preset takes in radians.
    private static func roll(_ degree: Float) -> Float {
        degree * Float.pi / 180
    }
}
