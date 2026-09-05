/// A point a Guide is moving. The consumer owns the point; the identifiers are keys and the token confers no ownership of the data they name.
public struct Token: Hashable, Sendable {
    public let point: PointIdentifier
    public let stroke: StrokeIdentifier
    /// Scene coordinates. Stored rather than recomputed from the origin, because the target can change at any moment and this is the anchor the next segment starts from.
    public var location: SIMD2<Float>
    /// Scene coordinates.
    public var target: SIMD2<Float>
    /// The time the segment in flight began.
    public var origin: Double

    public init(point: PointIdentifier, stroke: StrokeIdentifier, location: SIMD2<Float>, target: SIMD2<Float>, origin: Double) {
        self.point = point
        self.stroke = stroke
        self.location = location
        self.target = target
        self.origin = origin
    }
}
