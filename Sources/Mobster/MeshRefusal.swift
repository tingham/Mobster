/// An identity pass the device would not run, naming what it refused. A render that answers nothing cannot be told apart from one that found nothing, which is the whole reason this crosses the boundary.
public enum MeshRefusal: Error, Hashable, Sendable {
    /// The pass would not compile on the device supplied, or the device vended no queue to run it on.
    case pass
    /// The identity target or its depth target would not allocate at the fragment lattice the Frame derives.
    case target(columns: Int, rows: Int)
    /// The locations or the identities of the mesh would not allocate as device buffers.
    case buffers(triangles: Int)
    /// The device took the pass and vended nothing to encode it into.
    case encoding
}
