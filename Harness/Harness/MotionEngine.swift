import Mobster

/// Runs the Guide at whatever time the transport stands on. One play answers for that time outright, so the engine keeps no history and a scrub is the same single call a forward step is.
final class MotionEngine {
    private let frame: Frame
    private var field: Field
    private var strokes: [Stroke]
    private var reach: Float
    private var speed: Float
    private var epsilon: Float
    private var guide: Guide
    private var locations: [PointIdentifier: SIMD2<Float>] = [:]
    private var rects: [GuideRect] = []
    private var settled = false
    private var duration: Duration = .zero
    private var time: Double = 0

    init(frame: Frame, field: Field, strokes: [Stroke], reach: Float, speed: Float, epsilon: Float) {
        self.frame = frame
        self.field = field
        self.strokes = strokes
        self.reach = reach
        self.speed = speed
        self.epsilon = epsilon
        guide = Guide(frame: frame, adherence: Adherence(reach: reach), settleEpsilon: epsilon)
        build()
    }

    var plot: MotionPlot {
        MotionPlot(locations: locations, rects: rects, settled: settled, duration: duration)
    }

    func load(field: Field, strokes: [Stroke]) {
        self.field = field
        self.strokes = strokes
        rebuild()
    }

    /// Reach rebuilds because it changes where every point was always going, and the epsilon because a Guide reports settlement on entry alone. Speed is an argument to the play.
    func tune(reach: Float, speed: Float, epsilon: Float) {
        self.speed = speed
        guard reach != self.reach || epsilon != self.epsilon else {
            play(at: time)
            return
        }
        self.reach = reach
        self.epsilon = epsilon
        rebuild()
    }

    func seek(to step: Int) {
        play(at: Double(step) * Transport.interval)
    }

    /// The time on screen survives the rebuild, so an input change answers for that time rather than throwing the run back to the start.
    private func rebuild() {
        let landing = time
        build()
        play(at: landing)
    }

    /// A fresh Guide rather than a reinitialized one, because initialize discards tokens and leaves the settle listeners in place.
    private func build() {
        guide = Guide(frame: frame, adherence: Adherence(reach: reach), settleEpsilon: epsilon)
        settled = false
        // Registered ahead of the tokenization so a membership settled the moment it exists is caught.
        guide.addSettleListener { [weak self] in self?.settled = true }
        guide.initialize(frame: frame, membership: strokes, time: 0)
        guide.update(field: field, time: 0)
        locations = strokes.reduce(into: [PointIdentifier: SIMD2<Float>]()) { store, stroke in
            for sample in stroke.samples { store[sample.identifier] = sample.location }
        }
        rects = []
        duration = .zero
        time = 0
    }

    /// The clock read reports what the play cost. It never enters the time the Guide is handed.
    private func play(at moment: Double) {
        // A play at an earlier time may leave the membership unsettled, and a Guide reports entry alone, so the latch is dropped here and left for the Guide to set again.
        if moment < time { settled = false }

        var advance = GuideAdvance(displacements: [])
        duration = ContinuousClock().measure {
            advance = guide.play(speed: speed, time: moment)
        }

        for displacement in advance.displacements {
            locations[displacement.point] = displacement.location
        }
        rects = advance.rects
        time = moment
    }
}
