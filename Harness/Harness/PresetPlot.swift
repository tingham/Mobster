import Foundation
import Metal
import Mobster

/// The paths on screen, the identity raster they were traced from where it is shown, what the device refused if it refused anything, and the time the preset took to produce all of it.
struct PresetPlot {
    let paths: [[SIMD2<Float>]]
    /// Nil for a preset that extracts nothing and where the identities are not shown, a second identity pass being what it costs to take one.
    let raster: MeshIdentityRaster?
    /// Nil where nothing was refused. A mesh preset extracts through the device and a device can refuse, which no plotted preset can.
    let refusal: MeshRefusal?
    let duration: Duration

    /// The device is the consumer's to supply and a mesh source is the only thing that needs one, so it arrives beside the parameters rather than inside the package.
    init(kind: PresetKind, parameters: PresetParameters, frame: Frame, focus: PresetFocus, identities: Bool, device: (any MTLDevice)?) {
        var produced: [[SIMD2<Float>]] = []
        var read: MeshIdentityRaster?
        var refused: MeshRefusal?
        let elapsed = ContinuousClock().measure {
            do throws(MeshRefusal) {
                produced = try Self.generate(kind: kind, parameters: parameters, frame: frame, focus: focus, device: device)
                read = identities ? try Self.raster(kind: kind, parameters: parameters, frame: frame, device: device) : nil
            } catch {
                refused = error
            }
        }
        paths = produced
        raster = read
        refusal = refused
        duration = elapsed
    }

    /// The identity raster of whichever mesh the preset builds, which a plotted preset has none of.
    private static func raster(kind: PresetKind, parameters: PresetParameters, frame: Frame, device: (any MTLDevice)?) throws(MeshRefusal) -> MeshIdentityRaster? {
        guard let device, let mesh = mesh(kind: kind, parameters: parameters, frame: frame) else { return nil }

        return try extraction(mesh, parameters: parameters, frame: frame).raster(device: device)
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
        guard let device, let mesh = mesh(kind: .head, parameters: parameters, frame: frame) else { return [] }

        return try extraction(mesh, parameters: parameters, frame: frame).paths(device: device)
    }

    /// The break lines measure the figure rather than belonging to it, so they are appended as paths after the extracted boundaries.
    private static func figure(parameters: PresetParameters, frame: Frame, device: (any MTLDevice)?) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        guard let device, let mesh = mesh(kind: .figure, parameters: parameters, frame: frame) else { return [] }
        let extracted = try extraction(mesh, parameters: parameters, frame: frame).paths(device: device)

        return extracted + Self.construction(parameters).breakLines(in: frame)
    }

    /// Every mac this harness runs on carries a device, so the absent case is the API's rather than a state the harness presents.
    private static func cube(parameters: PresetParameters, frame: Frame, device: (any MTLDevice)?) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        guard let device, let mesh = mesh(kind: .cube, parameters: parameters, frame: frame) else { return [] }

        return try extraction(mesh, parameters: parameters, frame: frame).paths(device: device)
    }

    /// The mesh a preset builds, and nil for one that plots its paths instead.
    private static func mesh(kind: PresetKind, parameters: PresetParameters, frame: Frame) -> Mesh? {
        switch kind {
        case .head:
            HeadPreset(sex: parameters.headSex, target: parameters.headTarget, roll: roll(parameters.headRoll)).mesh(in: frame)
        case .figure:
            construction(parameters).mesh(in: frame)
        case .cube:
            CubeMesh(position: parameters.cubePosition, size: parameters.cubeSize, target: parameters.cubeTarget).mesh(in: frame)
        case .goldenRatio, .thirds, .columns, .rows, .grid, .ruler, .curve:
            nil
        }
    }

    /// The figure the harness plots, which is also what carries the head target a handle stands on.
    static func construction(_ parameters: PresetParameters) -> FigurePreset {
        FigurePreset(sex: parameters.figureSex,
                     heads: parameters.figureHeads,
                     target: parameters.figureTarget,
                     headTarget: parameters.figureHeadTarget,
                     leftHand: parameters.figureLeftHand,
                     rightHand: parameters.figureRightHand,
                     leftFoot: parameters.figureLeftFoot,
                     rightFoot: parameters.figureRightFoot,
                     headLines: parameters.figureHeadLines)
    }

    private static func extraction(_ mesh: Mesh, parameters: PresetParameters, frame: Frame) -> MeshExtraction {
        MeshExtraction(mesh: mesh, frame: frame, fit: parameters.meshFit, perspective: MeshPerspective(fieldOfView: parameters.meshFieldOfView))
    }

    /// The panel dials a roll as a degree, which the preset takes in radians.
    static func roll(_ degree: Float) -> Float {
        degree * Float.pi / 180
    }
}
