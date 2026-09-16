/// A construction in triangles, low in count, every one of them belonging to a component.
public struct Mesh: Hashable, Sendable {
    public let triangles: [MeshTriangle]

    public init(triangles: [MeshTriangle]) {
        self.triangles = triangles
    }
}
