/// The result of one play.
public struct GuideAdvance: Hashable, Sendable {
    /// One entry per point that moved. A point that did not move dirties nothing.
    public let displacements: [GuideDisplacement]

    public init(displacements: [GuideDisplacement]) {
        self.displacements = displacements
    }

    public var rects: [GuideRect] {
        displacements.map(\.rect)
    }

    public var union: GuideRect? {
        GuideRect.union(of: rects)
    }
}
