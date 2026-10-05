import SwiftUI

/// The view every guide type built from a mesh carries, offered once so a guide type is switched without the panel changing shape. A construction pointed at a location of its own and carrying no roll takes the target alone.
struct ViewParameterView: View {
    /// Degrees about forward, a full turn either way.
    private static let turn: ClosedRange<Float> = -180 ... 180

    @Binding var target: SIMD3<Float>
    @Binding var roll: Float

    var body: some View {
        ViewTargetParameterView(name: "Target", target: $target)
        ParameterSliderView(title: "Roll", value: $roll, range: Self.turn)
    }
}
