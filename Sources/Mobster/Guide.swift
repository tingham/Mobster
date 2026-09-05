public final class Guide {
    /// Nil until initialize is called; no workload may run before that.
    public private(set) var frame: Frame?

    public init() {}

    /// Establishes scene space and discards all prior state. Nothing is held yet, so there is nothing to discard.
    public func initialize(frame: Frame) {
        self.frame = frame
    }
}
