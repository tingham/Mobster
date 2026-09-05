import Mobster

/// Where every point stands after the run, what the advance that reached this step dirtied, and what one advance costs.
struct MotionPlot {
    /// Keyed by point, so a stroke's samples are looked up by identity rather than by position in the membership.
    let locations: [PointIdentifier: SIMD2<Float>]
    let rects: [GuideRect]
    let settled: Bool
    /// The last advance alone, which is the per step cost rather than the cost of the replay a rewind performs.
    let duration: Duration

    static let idle = MotionPlot(locations: [:], rects: [], settled: false, duration: .zero)
}
