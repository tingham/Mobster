import SwiftUI

/// The location a construction is pointed at, on all three of its axes. It is a direction rather than a place a user puts something, so it is dialled: the depth has no axis on the preview, and a mark laid down for it would stand where the construction would be seen from the front rather than where the construction now is.
struct ViewTargetParameterView: View {
    /// Construction units on each axis, wide enough to carry a target past the construction's own bounds on any of them.
    private static let reach: ClosedRange<Float> = -2 ... 2

    /// What the three sliders are titled by, a panel carrying more than one target needing them told apart.
    let name: String
    @Binding var target: SIMD3<Float>

    var body: some View {
        ParameterSliderView(title: "\(name) X", value: $target.x, range: Self.reach)
        ParameterSliderView(title: "\(name) Y", value: $target.y, range: Self.reach)
        ParameterSliderView(title: "\(name) Z", value: $target.z, range: Self.reach)
    }
}
