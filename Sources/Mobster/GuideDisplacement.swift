/// Where one point landed and the region its move dirtied.
public struct GuideDisplacement: Hashable, Sendable {
    public let point: PointIdentifier
    public let stroke: StrokeIdentifier
    /// Scene coordinates.
    public let location: SIMD2<Float>
    /// Covers the run from where the point was to where it now is.
    public let rect: GuideRect

    public init(point: PointIdentifier, stroke: StrokeIdentifier, location: SIMD2<Float>, rect: GuideRect) {
        self.point = point
        self.stroke = stroke
        self.location = location
        self.rect = rect
    }
}
