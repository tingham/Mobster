/// A region in scene space covering advanced points.
public struct GuideRect: Hashable, Sendable {
    public let origin: SIMD2<Float>
    public let size: SIMD2<Float>

    public init(origin: SIMD2<Float>, size: SIMD2<Float>) {
        self.origin = origin
        self.size = size
    }

    /// The least region containing the run between two locations.
    public init(covering start: SIMD2<Float>, _ end: SIMD2<Float>) {
        let low = SIMD2<Float>(min(start.x, end.x), min(start.y, end.y))
        let high = SIMD2<Float>(max(start.x, end.x), max(start.y, end.y))
        self.init(origin: low, size: high - low)
    }

    public func union(_ other: GuideRect) -> GuideRect {
        let low = SIMD2<Float>(min(origin.x, other.origin.x), min(origin.y, other.origin.y))
        let far = origin + size
        let otherFar = other.origin + other.size
        let high = SIMD2<Float>(max(far.x, otherFar.x), max(far.y, otherFar.y))
        return GuideRect(origin: low, size: high - low)
    }

    /// Nil for an empty collection, which covers nothing and is not the same as covering a point at the scene origin.
    public static func union(of rects: [GuideRect]) -> GuideRect? {
        guard let first = rects.first else { return nil }
        return rects.dropFirst().reduce(first) { $0.union($1) }
    }
}
