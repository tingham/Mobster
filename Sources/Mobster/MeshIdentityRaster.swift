/// The identity target read back, one whole identity a fragment, row major from the origin of the Frame. It crosses the boundary for display, as the field's grayscale does, because a consumer diagnosing a boundary that comes and goes cannot do it blind.
public struct MeshIdentityRaster: Hashable, Sendable {
    /// The one value a component may not carry, which is how a fragment covering no component tells itself apart from one that does.
    public static let background = UInt32.max

    public let columns: Int
    public let rows: Int
    public let identities: [UInt32]

    public func identity(column: Int, row: Int) -> UInt32 {
        identities[row * columns + column]
    }
}
