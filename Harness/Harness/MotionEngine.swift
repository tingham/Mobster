import Mobster

/// Runs the Guide at whatever time the transport stands on. One evaluation answers for that time outright, so the engine keeps no history and a scrub is the same single call a forward step is.
final class MotionEngine {
    private let frame: Frame
    private var source: GuideSource
    private var content: [Line]
    private var adhesion: Float
    private var run: Double
    private var epsilon: Float
    private var budget: Int
    private var guide: Guide
    private var displaced: [Line] = []
    private var raster: FieldRaster?
    private var refusal: FieldRefusal?
    private var bake: Duration = .zero
    private var evaluation: Duration = .zero
    private var time: Double = 0

    init(frame: Frame, source: GuideSource, content: [Line], adhesion: Float, run: Double, epsilon: Float, budget: Int) {
        self.frame = frame
        self.source = source
        self.content = content
        self.adhesion = adhesion
        self.run = run
        self.epsilon = epsilon
        self.budget = budget
        guide = Guide(frame: frame)
        build()
    }

    var plot: MotionPlot {
        MotionPlot(lines: displaced, settled: time >= run, duration: evaluation)
    }

    var field: FieldPlot {
        FieldPlot(raster: raster, refusal: refusal, duration: bake)
    }

    func load(source: GuideSource, content: [Line]) {
        self.source = source
        self.content = content
        rebuild()
    }

    func tune(adhesion: Float, run: Double, epsilon: Float, budget: Int) {
        self.adhesion = adhesion
        self.run = run
        self.epsilon = epsilon
        self.budget = budget
        rebuild()
    }

    func seek(to step: Int) {
        evaluate(at: Double(step) * Transport.interval)
    }

    /// The time on screen survives the rebuild, so an input change answers for that time rather than throwing the run back to the start.
    private func rebuild() {
        let landing = time
        build()
        evaluate(at: landing)
    }

    /// A refused bake leaves a Guide that displaces nothing, which the readout says outright rather than leaving the canvas to imply it.
    private func build() {
        guide = Guide(frame: frame)
        var refused: FieldRefusal?
        bake = ContinuousClock().measure {
            do throws(FieldRefusal) {
                try guide.initialize(source: source, frame: frame, adhesion: adhesion, duration: run, settleEpsilon: epsilon, budget: budget)
            } catch {
                refused = error
            }
        }
        refusal = refused
        // Taken once here rather than per redraw, because the grayscale is derived from the field and not held by it.
        raster = guide.raster()
        displaced = content
        evaluation = .zero
        time = 0
    }

    /// The clock read reports what the evaluation cost. It never enters the time the Guide is handed.
    private func evaluate(at moment: Double) {
        var returned: [Line] = []
        evaluation = ContinuousClock().measure {
            returned = guide.evaluate(content, at: moment)
        }
        displaced = returned
        time = moment
    }
}
