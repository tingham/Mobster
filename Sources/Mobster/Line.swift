public struct Line: Sendable {
    /// Ordered as the consumer laid it down.
    public let verts: [Vert]
    /// The consumer's, returned untouched.
    public let identifier: LineIdentifier?
    /// Form where the vendor declares none, so a consumer that knows nothing of roles is conformed against as it was before roles were carried.
    public let role: PathRole

    public init(verts: [Vert], identifier: LineIdentifier? = nil, role: PathRole = .form) {
        self.verts = verts
        self.identifier = identifier
        self.role = role
    }
}
