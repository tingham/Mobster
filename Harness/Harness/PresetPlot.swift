import Foundation
import Metal
import Mobster

/// The paths on screen, the identity raster they were traced from where it is shown, what the device refused if it refused anything, and the time the guide type took to produce all of it.
struct PresetPlot {
    let paths: [Line]
    /// Nil for a guide type that extracts nothing and where the identities are not shown, a second identity pass being what it costs to take one.
    let raster: MeshIdentityRaster?
    /// Nil where nothing was refused. A guide type built from a mesh produces through the device and a device can refuse, which no plotted one can.
    let refusal: MeshRefusal?
    let duration: Duration

    /// The device is the consumer's to supply, so it arrives beside the parameters and goes into the production context a mesh built guide type is configured with.
    init(kind: PresetKind, parameters: PresetParameters, frame: Frame, focus: PresetFocus, identities: Bool, device: (any MTLDevice)?) {
        var produced: [Line] = []
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

    private static func generate(kind: PresetKind, parameters: PresetParameters, frame: Frame, focus: PresetFocus, device: (any MTLDevice)?) throws(MeshRefusal) -> [Line] {
        guard let configuration = configuration(kind: kind, parameters: parameters, focus: focus, device: device) else { return [] }

        return try configuration.lines(in: frame)
    }

    /// Nil only where a mesh built guide type is asked for with no device. Every mac this harness runs on carries one, so that case is the API's rather than a state the harness presents.
    private static func configuration(kind: PresetKind, parameters: PresetParameters, focus: PresetFocus, device: (any MTLDevice)?) -> (any PresetConfiguration)? {
        switch kind {
        case .goldenRatio:
            return GoldenRatioConfiguration(parameters: GoldenRatioPreset(focus: focus, quadlines: parameters.goldenRatioQuadlines))
        case .thirds:
            return ThirdsConfiguration(parameters: ThirdsPreset())
        case .columns:
            return ColumnsConfiguration(parameters: ColumnsPreset(count: parameters.columnCount, gutter: parameters.columnGutter))
        case .rows:
            return RowsConfiguration(parameters: RowsPreset(count: parameters.rowCount, gutter: parameters.rowGutter))
        case .grid:
            return GridConfiguration(parameters: GridPreset(count: parameters.gridCount, gutter: parameters.gridGutter))
        case .ruler:
            return RulerConfiguration(parameters: RulerPreset(center: parameters.rulerCenter,
                                                              firstDegree: parameters.rulerFirstDegree,
                                                              secondDegree: parameters.rulerSecondDegree,
                                                              distance: parameters.rulerDistance))
        case .curve:
            return CurveConfiguration(parameters: CurvePreset(center: parameters.curveCenter,
                                                              firstDegree: parameters.curveFirstDegree,
                                                              secondDegree: parameters.curveSecondDegree,
                                                              distance: parameters.curveDistance,
                                                              control: parameters.curveControl,
                                                              resolution: parameters.curveResolution))
        case .head:
            guard let device else { return nil }
            return HeadConfiguration(parameters: head(parameters), context: context(parameters, device: device))
        case .figure:
            guard let device else { return nil }
            return FigureConfiguration(parameters: construction(parameters), context: context(parameters, device: device))
        case .cube:
            guard let device else { return nil }
            return CubeConfiguration(parameters: box(parameters), context: context(parameters, device: device))
        }
    }

    /// The identity target the paths were traced from, which is the harness's own reading of the production and not something a guide type vends.
    private static func raster(kind: PresetKind, parameters: PresetParameters, frame: Frame, device: (any MTLDevice)?) throws(MeshRefusal) -> MeshIdentityRaster? {
        guard let device, let mesh = mesh(kind: kind, parameters: parameters, frame: frame) else { return nil }
        let production = context(parameters, device: device)

        return try MeshExtraction(mesh: mesh, frame: frame, fit: production.fit, perspective: production.perspective).raster(device: production.device)
    }

    /// The mesh a guide type builds, and nil for one that plots its paths instead.
    private static func mesh(kind: PresetKind, parameters: PresetParameters, frame: Frame) -> Mesh? {
        switch kind {
        case .head:
            head(parameters).mesh(in: frame)
        case .figure:
            construction(parameters).mesh(in: frame)
        case .cube:
            box(parameters).mesh(in: frame)
        case .goldenRatio, .thirds, .columns, .rows, .grid, .ruler, .curve:
            nil
        }
    }

    /// What the sliders dial that the parameters do not carry, built again at every production because the device is a reference and not a value.
    private static func context(_ parameters: PresetParameters, device: any MTLDevice) -> PresetContext {
        PresetContext(device: device, fit: parameters.meshFit, perspective: MeshPerspective(fieldOfView: parameters.meshFieldOfView))
    }

    private static func head(_ parameters: PresetParameters) -> HeadPreset {
        HeadPreset(sex: parameters.headSex, target: parameters.headTarget, roll: roll(parameters.headRoll))
    }

    private static func box(_ parameters: PresetParameters) -> CubeMesh {
        CubeMesh(position: parameters.cubePosition, size: parameters.cubeSize, target: parameters.cubeTarget)
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

    /// The panel dials a roll as a degree, which the parameters take in radians.
    static func roll(_ degree: Float) -> Float {
        degree * Float.pi / 180
    }
}
