import Mobster

/// Runs the Guide at whatever time the transport stands on. One evaluation answers for that time outright, so the engine keeps no history and a scrub is the same single call a forward step is.
final class MotionEngine {
    private let frame: Frame
    private var source: GuideSource
    private var content: [Line]
    private var adhesion: Float
    private var run: Double
    private var epsilon: Float
    private var resolution: Int
    private var guide: Guide
    private var displaced: [Line] = []
    private var raster: FieldRaster?
    private var bake: Duration = .zero
    private var evaluation: Duration = .zero
    private var time: Double = 0

    init(frame: Frame, source: GuideSource, content: [Line], adhesion: Float, run: Double, epsilon: Float, resolution: Int) {
        self.frame = frame
        self.source = source
        self.content = content
        self.adhesion = adhesion
        self.run = run
        self.epsilon = epsilon
        self.resolution = resolution
        guide = Guide(frame: frame, settleEpsilon: epsilon)
        build()
    }

    var plot: MotionPlot {
        MotionPlot(lines: displaced, settled: time >= run, duration: evaluation)
    }

    var field: FieldPlot {
        FieldPlot(raster: raster, duration: bake)
    }

    func load(source: GuideSource, content: [Line], resolution: Int) {
        self.source = source
        self.content = content
        self.resolution = resolution
        rebuild()
    }

    /// The epsilon arrives with a Guide rather than at initialize, so a change to it is the one tune that cannot be answered by initializing again.
    func tune(adhesion: Float, run: Double, epsilon: Float) {
        self.adhesion = adhesion
        self.run = run
        self.epsilon = epsilon
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

    private func build() {
        guide = Guide(frame: frame, settleEpsilon: epsilon)
        bake = ContinuousClock().measure {
            guide.initialize(source: source, frame: frame, adhesion: adhesion, duration: run, resolution: resolution)
        }
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
