public struct Stroke: Hashable, Sendable {
    public let identifier: StrokeIdentifier
    /// Ordered as the consumer laid the stroke down.
    public let samples: [Sample]

    public init(identifier: StrokeIdentifier, samples: [Sample]) {
        self.identifier = identifier
        self.samples = samples
    }
}
