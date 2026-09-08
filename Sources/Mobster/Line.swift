public struct Line: Sendable {
    /// Ordered as the consumer laid it down.
    public let verts: [Vert]
    /// The consumer's, returned untouched.
    public let identifier: LineIdentifier?

    public init(verts: [Vert], identifier: LineIdentifier? = nil) {
        self.verts = verts
        self.identifier = identifier
    }
}
