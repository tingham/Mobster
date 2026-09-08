import Mobster

/// The fixture stands in for the consuming application, which is the only party that mints.
struct FixtureIdentitySequence {
    private var pending: UInt64 = 1

    mutating func line() -> LineIdentifier {
        LineIdentifier(take())
    }

    mutating func vert() -> VertIdentifier {
        VertIdentifier(take())
    }

    /// One counter serves both kinds, so a vert identifier is unique across the whole population and not merely within its line.
    private mutating func take() -> UInt64 {
        defer { pending &+= 1 }
        return pending
    }
}
