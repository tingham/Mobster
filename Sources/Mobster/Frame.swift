/// A region in scene space.
public struct Frame: Sendable {
    public let origin: SIMD2<Float>
    public let size: SIMD2<Float>

    public init(origin: SIMD2<Float>, size: SIMD2<Float>) {
        self.origin = origin
        self.size = size
    }
}
