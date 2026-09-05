public struct Sample: Sendable {
    public let identifier: PointIdentifier
    /// Scene coordinates.
    public let location: SIMD2<Float>

    public init(identifier: PointIdentifier, location: SIMD2<Float>) {
        self.identifier = identifier
        self.location = location
    }
}
