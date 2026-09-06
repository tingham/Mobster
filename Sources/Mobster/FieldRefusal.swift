/// A bake refused for what it would cost, carrying the epsilon asked for beside the one that would be paid for, so the consumer chooses again rather than discovering the cost by waiting through it.
public struct FieldRefusal: Error, Hashable, Sendable {
    /// Scene units, the epsilon whose derived resolution outruns the budget.
    public let epsilon: Float
    /// Scene units, the finest epsilon these paths bake within the budget. Infinite where the segments alone outrun it and no epsilon is affordable.
    public let affordable: Float
}
