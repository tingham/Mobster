import Mobster

/// The fixture stands in for the consuming application, which is the only party that mints.
struct FixtureIdentitySequence {
    private var pending: UInt64 = 1

    mutating func stroke() -> StrokeIdentifier {
        StrokeIdentifier(take())
    }

    mutating func point() -> PointIdentifier {
        PointIdentifier(take())
    }

    /// One counter serves both kinds, so a point identifier is unique across the whole population and not merely within its stroke.
    private mutating func take() -> UInt64 {
        defer { pending &+= 1 }
        return pending
    }
}
