/// How a preset's design space is laid onto a Frame.
public enum PresetPlotMode: Hashable, Sendable {
    /// The design is stretched per axis onto the Frame, taking the Frame's aspect ratio and distorting to it.
    case aspect
    /// The design is scaled uniformly to the smallest size whose bounds still encompass the Frame, and centered. It overflows the shorter axis.
    case bounds
}
