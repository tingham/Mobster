import Mobster
import MobsterFixture
import Observation

@Observable
final class HarnessModel {
    /// Scene space is fitted to the canvas at draw time, so this is a shape rather than a pixel count.
    static let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    /// Texel segment products a bake may spend. A bake runs at roughly a nanosecond a product in release and a hundred times that in the debug build this harness is dragged in, so this opening holds a drag near a quarter second rather than near half a minute.
    static let openingBudget = 2_000_000
    /// Three decades, the lower end being a bake no build stalls on and the upper end one a release consumer would still wait through.
    static let budgetRange = 100_000 ... 100_000_000
    /// The fixture takes no default of its own, so the opening magnitudes are the harness's and every one of them is a slider. The opening spread is off zero because coupling propagates a difference in motion, and a population moving alike shows a coupling slider doing nothing.
    static let openingFixture = FixtureParameters(seed: 1, lineCount: 24, vertsPerLine: 48, step: 0.02, turn: 30, margin: 0.1, spread: 0.5)
    /// Zero to one. This opening is a place for the slider to start from and not a recommendation: it is the value that puts a visible run inside the transport window.
    static let openingAdhesion: Float = 0.1
    /// Seconds. The time by which every vert has arrived, which the transport window is eight seconds wide enough to cover.
    static let openingRun: Float = 4
    /// Scene units, against a Frame six hundred by four hundred. What a pixel is worth here is the question the slider exists to answer.
    static let openingEpsilon: Float = 1
    /// Minus one to one, carried by every vert in the population. The opening leaves the population moving independently, which is the reading the coupled ones are judged against.
    static let openingCoupling: Float = 0

    var kind: PresetKind = .columns { didSet { replot() } }
    var mode: PresetPlotMode = .aspect { didSet { replot() } }
    var focus: PresetFocus = .maxXMinY { didSet { replot() } }
    var parameters = PresetParameters() { didSet { replot() } }
    var fieldVisible = false
    var fixture = HarnessModel.openingFixture { didSet { repopulate() } }
    var adhesion = HarnessModel.openingAdhesion { didSet { retune() } }
    var run = HarnessModel.openingRun { didSet { retune() } }
    var settleEpsilon = HarnessModel.openingEpsilon { didSet { retune() } }
    var budget = HarnessModel.openingBudget { didSet { retune() } }
    var coupling = HarnessModel.openingCoupling { didSet { repopulate() } }
    let transport = Transport()

    /// Held rather than computed so the timing readout reports one generation and not one per redraw.
    private(set) var plot: PresetPlot
    /// Taken whether or not the field is shown, because the bake happens either way.
    private(set) var field: FieldPlot
    /// The anchors every displacement is measured from, which the harness holds undisplaced.
    private(set) var lines: [Line]
    private(set) var motion: MotionPlot
    private let engine: MotionEngine

    /// Nil where the field is hidden, which the canvas draws the same way as a field holding no path location: not at all.
    var raster: FieldRaster? {
        fieldVisible ? field.raster : nil
    }

    init() {
        let opening = PresetPlot(kind: .columns, parameters: PresetParameters(), frame: Self.frame, mode: .aspect, focus: .maxXMinY)
        let population = Self.coupled(LineFixture(parameters: Self.openingFixture).lines(in: Self.frame), coupling: Self.openingCoupling)
        let running = MotionEngine(frame: Self.frame,
                                   source: Self.source(opening.paths),
                                   content: population,
                                   adhesion: Self.openingAdhesion,
                                   run: Double(Self.openingRun),
                                   epsilon: Self.openingEpsilon,
                                   budget: Self.openingBudget)
        plot = opening
        lines = population
        engine = running
        field = running.field
        motion = running.plot
    }

    /// The wall clock that calls this schedules the redraw. What the Guide is handed is the step the transport counts, which no clock reading enters.
    func tick() {
        guard transport.playing else { return }
        transport.advance()
        seek()
    }

    func scrub(to step: Int) {
        transport.seek(to: step)
        seek()
    }

    /// The harness already holds the plotted paths for drawing, so it hands them over as lines rather than naming the preset again.
    private static func source(_ paths: [[SIMD2<Float>]]) -> GuideSource {
        .lines(paths.map { path in Line(verts: path.map { Vert(location: $0) }) })
    }

    private func replot() {
        plot = PresetPlot(kind: kind, parameters: parameters, frame: Self.frame, mode: mode, focus: focus)
        reload()
    }

    private func repopulate() {
        lines = Self.coupled(LineFixture(parameters: fixture).lines(in: Self.frame), coupling: coupling)
        reload()
    }

    /// One coupling across the whole population, so what the slider does to a line reads at a glance rather than against a per vert spread.
    private static func coupled(_ lines: [Line], coupling: Float) -> [Line] {
        lines.map { line in
            Line(verts: line.verts.map { vert in
                Vert(location: vert.location, identifier: vert.identifier, mass: vert.mass, drag: vert.drag, coupling: coupling)
            }, identifier: line.identifier)
        }
    }

    private func reload() {
        engine.load(source: Self.source(plot.paths), content: lines)
        settle()
    }

    /// The bake happens inside the Guide, so every one of these rebakes and there is no separate rebake to trigger.
    private func retune() {
        engine.tune(adhesion: adhesion, run: Double(run), epsilon: settleEpsilon, budget: budget)
        settle()
    }

    private func seek() {
        engine.seek(to: transport.step)
        motion = engine.plot
    }

    private func settle() {
        field = engine.field
        motion = engine.plot
    }
}
