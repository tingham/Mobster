/// A point a Guide is moving. The consumer owns the point; the identifiers are keys and the token confers no ownership of the data they name.
public struct Token: Hashable, Sendable {
    public let point: PointIdentifier
    public let stroke: StrokeIdentifier
    /// Scene coordinates. Stored rather than recomputed from the origin, because the target can change at any moment and this is the anchor the next segment starts from.
    public var location: SIMD2<Float>
    /// Scene coordinates. Where the point stood when the segment began, so a time is evaluated against the whole segment rather than against the interval since the last evaluation.
    public var anchor: SIMD2<Float>
    /// Scene coordinates.
    public var target: SIMD2<Float>
    /// The time the segment in flight began.
    public var origin: Double

    /// A segment begins where the point already is, so the anchor is the location and is not supplied separately.
    public init(point: PointIdentifier, stroke: StrokeIdentifier, location: SIMD2<Float>, target: SIMD2<Float>, origin: Double) {
        self.point = point
        self.stroke = stroke
        self.location = location
        self.anchor = location
        self.target = target
        self.origin = origin
    }
}
