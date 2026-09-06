import MobsterFixture
import SwiftUI

struct SeedParameterView: View {
    @Binding var parameters: FixtureParameters

    private static let range = 0 ... 9999

    /// The slider works in a signed whole number and the seed is unsigned, so the two are bridged rather than bound directly.
    private var whole: Binding<Int> {
        Binding(get: { Int(parameters.seed) }, set: { parameters.seed = UInt64(max($0, Self.range.lowerBound)) })
    }

    var body: some View {
        IntegerParameterSliderView(title: "Seed", value: whole, range: Self.range)
        Button("Reseed") {
            parameters.seed = UInt64((Int(parameters.seed) + 1) % (Self.range.upperBound + 1))
        }
        .controlSize(.large)
    }
}
