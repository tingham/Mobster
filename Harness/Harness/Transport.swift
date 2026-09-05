import Observation

/// The time the harness hands the Guide. Steps are counted rather than measured, so a step index names one time value and only one, whichever direction the transport arrived at it from.
@Observable
final class Transport {
    /// Seconds one step covers. Fixed, so the speed dial is the only thing changing how far a step carries a point.
    static let interval: Double = 1.0 / 60.0
    /// The last step the scrub reaches. Eight seconds of run at the interval above.
    static let limit = 480

    var playing = false
    private(set) var step = 0

    var time: Double {
        Double(step) * Self.interval
    }

    /// Playing past the last step holds there rather than wrapping, because a wrap would restart a run the principal is watching settle.
    func advance() {
        guard step < Self.limit else {
            playing = false
            return
        }
        step += 1
    }

    func seek(to destination: Int) {
        step = min(max(destination, 0), Self.limit)
    }
}
