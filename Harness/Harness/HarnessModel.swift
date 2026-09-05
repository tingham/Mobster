import Mobster
import MobsterFixture
import Observation

@Observable
final class HarnessModel {
    /// Scene space is fitted to the canvas at draw time, so this is a shape rather than a pixel count.
    static let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))

    var kind: PresetKind = .columns { didSet { replot() } }
    var mode: PresetPlotMode = .aspect { didSet { replot() } }
    var focus: PresetFocus = .maxXMinY { didSet { replot() } }
    var parameters = PresetParameters() { didSet { replot() } }
    var fieldVisible = false { didSet { rebake() } }
    var fieldResolution = 64 { didSet { rebake() } }
    /// The fixture takes no default of its own, so the opening magnitudes are the harness's and every one of them is a slider.
    var fixture = FixtureParameters(seed: 1, strokeCount: 24, pointsPerStroke: 48, step: 0.02, turn: 30, margin: 0.1) { didSet { repopulate() } }

    /// Held rather than computed so the timing readout reports one generation and not one per redraw.
    private(set) var plot: PresetPlot
    /// Nil while the field is hidden, which is also what a hidden field costs.
    private(set) var field: FieldPlot?
    private(set) var strokes: [Stroke]

    init() {
        plot = PresetPlot(kind: .columns, parameters: PresetParameters(), frame: Self.frame, mode: .aspect, focus: .maxXMinY)
        strokes = []
        repopulate()
    }

    private func replot() {
        plot = PresetPlot(kind: kind, parameters: parameters, frame: Self.frame, mode: mode, focus: focus)
        rebake()
    }

    private func rebake() {
        guard fieldVisible else {
            field = nil
            return
        }
        field = FieldPlot(paths: plot.paths, frame: Self.frame, resolution: fieldResolution)
    }

    private func repopulate() {
        strokes = StrokeFixture(parameters: fixture).strokes(in: Self.frame)
    }
}
