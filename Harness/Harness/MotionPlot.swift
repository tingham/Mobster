import Mobster

/// What the Guide returned for the step the transport stands on, and what that one evaluation cost.
struct MotionPlot {
    /// The content the Guide returned, in the order it was supplied.
    let lines: [Line]
    let settled: Bool
    /// One evaluation alone, which is the per step cost and not the cost of the run that reached this step.
    let duration: Duration

    static let idle = MotionPlot(lines: [], settled: false, duration: .zero)
}
