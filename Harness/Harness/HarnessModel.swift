import Mobster
import MobsterFixture
import Observation

@Observable
final class HarnessModel {
    /// Scene space is fitted to the canvas at draw time, so this is a shape rather than a pixel count.
    static let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    /// Texel segment products a bake may spend. A bake runs at roughly a nanosecond a product in release and a hundred times that in the debug build this harness is dragged in, so this holds a drag near a quarter second rather than near half a minute.
    static let budget = 2_000_000
    /// The fixture takes no default of its own, so the opening magnitudes are the harness's and every one of them is a slider.
    static let openingFixture = FixtureParameters(seed: 1, strokeCount: 24, pointsPerStroke: 48, step: 0.02, turn: 30, margin: 0.1)
    /// Scene units. The dial that would map onto a reach is the thing the principal is here to decide, so the slider carries the reach itself and interposes no curve. This opening is a place for the sliders to start from and not a recommendation: it is the pair that puts a visible run inside the transport window.
    static let openingReach: Float = 200
    /// Scene units per second.
    static let openingSpeed: Float = 100
    /// Scene units, against a Frame six hundred by four hundred. What a pixel is worth here is the question the slider exists to answer.
    static let openingEpsilon: Float = 1

    var kind: PresetKind = .columns { didSet { replot() } }
    var mode: PresetPlotMode = .aspect { didSet { replot() } }
    var focus: PresetFocus = .maxXMinY { didSet { replot() } }
    var parameters = PresetParameters() { didSet { replot() } }
    var fieldVisible = false
    var fixture = HarnessModel.openingFixture { didSet { repopulate() } }
    var reach = HarnessModel.openingReach { didSet { retune() } }
    var speed = HarnessModel.openingSpeed { didSet { retune() } }
    var settleEpsilon = HarnessModel.openingEpsilon { didSet { resettle() } }
    var dirtyVisible = false
    let transport = Transport()

    /// Held rather than computed so the timing readout reports one generation and not one per redraw.
    private(set) var plot: PresetPlot
    /// Baked whether or not it is shown, because the tokens resolve against it either way.
    private(set) var field: FieldPlot
    private(set) var strokes: [Stroke]
    private(set) var motion: MotionPlot
    private let engine: MotionEngine

    /// Nil where the field is hidden, which the canvas draws the same way as a field holding no path location: not at all.
    var raster: FieldRaster? {
        fieldVisible ? field.raster : nil
    }

    var dirtyRects: [GuideRect] {
        dirtyVisible ? motion.rects : []
    }

    init() {
        let opening = PresetPlot(kind: .columns, parameters: PresetParameters(), frame: Self.frame, mode: .aspect, focus: .maxXMinY)
        let baked = FieldPlot(paths: opening.paths, frame: Self.frame, settleEpsilon: Self.openingEpsilon, budget: Self.budget)
        let population = StrokeFixture(parameters: Self.openingFixture).strokes(in: Self.frame)
        let running = MotionEngine(frame: Self.frame, field: baked.field, strokes: population, reach: Self.openingReach, speed: Self.openingSpeed, epsilon: Self.openingEpsilon)
        plot = opening
        field = baked
        strokes = population
        engine = running
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

    private func replot() {
        plot = PresetPlot(kind: kind, parameters: parameters, frame: Self.frame, mode: mode, focus: focus)
        rebake()
    }

    private func rebake() {
        field = FieldPlot(paths: plot.paths, frame: Self.frame, settleEpsilon: settleEpsilon, budget: Self.budget)
        reload()
    }

    /// The field resolution follows from the epsilon, so a change to it rebakes as well as retunes.
    private func resettle() {
        rebake()
        retune()
    }

    private func repopulate() {
        strokes = StrokeFixture(parameters: fixture).strokes(in: Self.frame)
        reload()
    }

    private func reload() {
        engine.load(field: field.field, strokes: strokes)
        motion = engine.plot
    }

    private func retune() {
        engine.tune(reach: reach, speed: speed, epsilon: settleEpsilon)
        motion = engine.plot
    }

    private func seek() {
        engine.seek(to: transport.step)
        motion = engine.plot
    }
}
