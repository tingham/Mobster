/// Identity of a stroke, minted by the consumer and opaque to Mobster.
public struct StrokeIdentifier: Hashable, Sendable {
    /// Mobster keys on this and never interprets it.
    public let value: UInt64

    public init(_ value: UInt64) {
        self.value = value
    }
}
