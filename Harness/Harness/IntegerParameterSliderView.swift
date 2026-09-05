import SwiftUI

struct IntegerParameterSliderView: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    /// The slider works in a continuous value and snaps back to the whole number the preset takes.
    private var continuous: Binding<Double> {
        Binding(get: { Double(value) }, set: { value = Int($0.rounded()) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(value, format: .number)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: continuous, in: Double(range.lowerBound) ... Double(range.upperBound), step: 1)
                .controlSize(.large)
        }
    }
}
