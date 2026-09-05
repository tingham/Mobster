public final class Guide {
    /// Nil until initialize is called; no workload may run before that.
    private(set) var frame: Frame?

    public init() {}

    public func initialize(frame: Frame) {
        self.frame = frame
    }
}
