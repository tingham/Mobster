/// A boundary between two identities, traced into an ordered run of samples in fragment coordinates.
struct MeshSeam: Hashable, Sendable {
    /// The pair that meet along it, lesser first, which is what puts the seams of a mesh in a defined order.
    let identities: SIMD2<UInt32>
    let locations: [SIMD2<Float>]
}
