/// The identity target read back, one whole identity a fragment, row major from the origin of the Frame.
struct MeshIdentityRaster: Hashable, Sendable {
    /// The one value a component may not carry, which is how a fragment covering no component tells itself apart from one that does.
    static let background = UInt32.max

    let columns: Int
    let rows: Int
    let identities: [UInt32]

    func identity(column: Int, row: Int) -> UInt32 {
        identities[row * columns + column]
    }
}
