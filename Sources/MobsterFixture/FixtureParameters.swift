/// Every dial shaping the population. There is no default, because a magnitude the fixture chose is one the harness cannot present as a slider.
public struct FixtureParameters: Hashable, Sendable {
    public var seed: UInt64
    public var lineCount: Int
    public var vertsPerLine: Int
    /// Distance between consecutive verts, as a fraction of the shorter Frame extent.
    public var step: Float
    /// The greatest heading change one step may make, in degrees.
    public var turn: Float
    /// Inset from the Frame edge within which a line begins, as a fraction of the Frame extent.
    public var margin: Float
    /// How far the per vert mass and drag stray from the plain travel. Zero leaves every vert unattributed, and a population moving alike is a population no peer attribute can be read against.
    public var spread: Float

    public init(seed: UInt64, lineCount: Int, vertsPerLine: Int, step: Float, turn: Float, margin: Float, spread: Float) {
        self.seed = seed
        self.lineCount = lineCount
        self.vertsPerLine = vertsPerLine
        self.step = step
        self.turn = turn
        self.margin = margin
        self.spread = spread
    }
}
