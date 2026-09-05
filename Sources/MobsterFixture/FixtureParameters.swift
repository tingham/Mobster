/// Every dial shaping the population. There is no default, because a magnitude the fixture chose is one the harness cannot present as a slider.
public struct FixtureParameters: Hashable, Sendable {
    public var seed: UInt64
    public var strokeCount: Int
    public var pointsPerStroke: Int
    /// Distance between consecutive points, as a fraction of the shorter Frame extent.
    public var step: Float
    /// The greatest heading change one step may make, in degrees.
    public var turn: Float
    /// Inset from the Frame edge within which a stroke begins, as a fraction of the Frame extent.
    public var margin: Float

    public init(seed: UInt64, strokeCount: Int, pointsPerStroke: Int, step: Float, turn: Float, margin: Float) {
        self.seed = seed
        self.strokeCount = strokeCount
        self.pointsPerStroke = pointsPerStroke
        self.step = step
        self.turn = turn
        self.margin = margin
    }
}
