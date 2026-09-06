/// Identity of a point, minted by the consumer and opaque to Mobster.
public struct PointIdentifier: Hashable, Sendable {
    /// Mobster keys on this and never interprets it.
    public let value: UInt64

    public init(_ value: UInt64) {
        self.value = value
    }
}
