/// The rectangle defining scene space.
public struct Frame: Hashable, Sendable {
    /// Scene coordinates.
    public let origin: SIMD2<Float>
    public let size: SIMD2<Float>

    public init(origin: SIMD2<Float>, size: SIMD2<Float>) {
        self.origin = origin
        self.size = size
    }
}
