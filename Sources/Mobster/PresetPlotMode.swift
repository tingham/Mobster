/// How a preset's design space is laid onto a Frame. Each preset fixes its own, so the consumer never names one.
enum PresetPlotMode: Hashable, Sendable {
    /// The design is stretched per axis onto the Frame, taking the Frame's aspect ratio and distorting to it.
    case aspect
    /// The design is scaled uniformly to the smallest size whose bounds still encompass the Frame, and centered. It overflows the shorter axis.
    case bounds
    /// The design is scaled uniformly by the lesser axis of the Frame, and centered, so the whole of it sits within the Frame.
    case contain
}
