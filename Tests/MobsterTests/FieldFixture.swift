@testable import Mobster

/// A field baked at a stated texel count. The count is what these tests were written around, so each one names the lattice it reasons on and lets the derivation supply the epsilon that demands it.
enum FieldFixture {
    static func field(paths: [[SIMD2<Float>]], frame: Frame, count: Int) -> Field {
        try! FieldBake(paths: paths, frame: frame, settleEpsilon: FieldResolution.epsilon(count: count, frame: frame), budget: .max).field()
    }
}
