import Mobster
import Observation

@Observable
final class HarnessModel {
    /// Scene space is fitted to the canvas at draw time, so this is a shape rather than a pixel count.
    static let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))

    var kind: PresetKind = .columns { didSet { replot() } }
    var mode: PresetPlotMode = .aspect { didSet { replot() } }
    var parameters = PresetParameters() { didSet { replot() } }

    /// Held rather than computed so the timing readout reports one generation and not one per redraw.
    private(set) var plot: PresetPlot

    init() {
        plot = PresetPlot(kind: .columns, parameters: PresetParameters(), frame: Self.frame, mode: .aspect)
    }

    private func replot() {
        plot = PresetPlot(kind: kind, parameters: parameters, frame: Self.frame, mode: mode)
    }
}
