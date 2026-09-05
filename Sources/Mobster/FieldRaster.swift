/// A grayscale image of a field, vended for display.
public struct FieldRaster: Hashable, Sendable {
    public let columns: Int
    public let rows: Int
    /// Row major, one intensity per texel.
    public let samples: [UInt8]

    public init(columns: Int, rows: Int, samples: [UInt8]) {
        self.columns = columns
        self.rows = rows
        self.samples = samples
    }
}
