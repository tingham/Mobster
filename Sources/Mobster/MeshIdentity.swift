/// The identity of a mesh component, carried by every triangle of that component. It marks structure rather than tessellation, so the two triangles of a cube face share one and the sixteen facets approximating a limb share one.
public struct MeshIdentity: Hashable, Sendable {
    /// Mobster keys on this and never interprets it.
    public let value: UInt32

    public init(_ value: UInt32) {
        self.value = value
    }
}
