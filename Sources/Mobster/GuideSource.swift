import Metal

/// What a Guide takes its lines from and bakes its field from.
public enum GuideSource: Sendable {
    case lines([Line])
    case preset(any Preset)
    /// The device the mesh is rendered on is carried here, so a source that needs no device never holds one and a Guide creates none. The fit is the count of locations each extracted boundary is reduced to.
    case mesh(Mesh, device: any MTLDevice, fit: Int, perspective: MeshPerspective)
}
