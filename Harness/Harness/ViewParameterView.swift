import SwiftUI

/// The view every guide type built from a mesh carries, offered once so a guide type is switched without the panel changing shape. The depth of a target is a slider because the preview carries no third axis for a handle to stand on.
struct ViewParameterView: View {
    /// Construction units on each axis, wide enough to carry a target past the construction's own bounds on any of them.
    private static let reach: ClosedRange<Float> = -2 ... 2
    /// Degrees about forward, a full turn either way.
    private static let turn: ClosedRange<Float> = -180 ... 180

    @Binding var target: SIMD3<Float>
    @Binding var roll: Float

    var body: some View {
        ParameterSliderView(title: "Target X", value: $target.x, range: Self.reach)
        ParameterSliderView(title: "Target Y", value: $target.y, range: Self.reach)
        ParameterSliderView(title: "Target Z", value: $target.z, range: Self.reach)
        ParameterSliderView(title: "Roll", value: $roll, range: Self.turn)
    }
}
