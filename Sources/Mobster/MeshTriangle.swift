/// A triangle of a mesh and the component it belongs to. Its locations carry x and y in scene coordinates and z toward the near side, a mesh arriving already turned toward the view.
public struct MeshTriangle: Hashable, Sendable {
    public let first: SIMD3<Float>
    public let second: SIMD3<Float>
    public let third: SIMD3<Float>
    public let identity: MeshIdentity

    public init(first: SIMD3<Float>, second: SIMD3<Float>, third: SIMD3<Float>, identity: MeshIdentity) {
        self.first = first
        self.second = second
        self.third = third
        self.identity = identity
    }
}
