import SwiftUI

struct ParameterSliderView: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(Double(value), format: .number.precision(.fractionLength(3)))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range)
                .controlSize(.large)
        }
    }
}
