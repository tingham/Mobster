/// SplitMix64. A pure integer recurrence, so a seed reproduces its stream in any process on any run.
struct FixtureRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var mixed = state
        mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
        return mixed ^ (mixed >> 31)
    }

    /// Twenty four bits over two to the twenty fourth, which every Float holds exactly, so the quotient carries no rounding of its own.
    mutating func unit() -> Float {
        Float(next() >> 40) / Float(1 << 24)
    }
}
