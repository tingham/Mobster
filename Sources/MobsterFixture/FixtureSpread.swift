import Mobster

/// The mass and drag one vert carries. Both are derived from the vert identifier rather than drawn, so a vert keeps its attributes wherever it lands and the walk's stream is not disturbed by the spread being asked for.
struct FixtureSpread {
    /// How far the attributes stray from the plain travel. Zero leaves every vert unattributed, which is the population as it stands without a spread.
    let amount: Float
    let seed: UInt64

    init(amount: Float, seed: UInt64) {
        self.amount = amount
        self.seed = seed
    }

    /// Nil where no spread is asked for, because an absent attribute is not a defaulted one and a spread of nothing is not a population of neutral weights.
    func attributes(for identifier: VertIdentifier) -> (mass: Float, drag: Float)? {
        let bounded = min(max(amount, 0), 1)
        guard bounded > 0 else { return nil }

        // The seed is spread across the whole word before the identifier is added, so two seeds a step apart do not hand one vert's attributes to its neighbour.
        var random = FixtureRandom(seed: identifier.value &+ seed &* 0x9E37_79B9_7F4A_7C15)
        let weight = random.unit()
        let leniency = random.unit()

        // A mass of one and a drag of one are both the plain travel, but one is the top of the leniency scale, so mass strays either side of it and drag only runs down from it.
        return (1 + bounded * (weight * 2 - 1), 1 - bounded * 2 * leniency)
    }
}
