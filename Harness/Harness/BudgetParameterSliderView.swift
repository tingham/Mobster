import SwiftUI

/// Texel segment products span three decades and the region worth dragging through is the bottom tenth of them, so the slider travels in powers of ten rather than in products.
struct BudgetParameterSliderView: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    private var exponent: Binding<Double> {
        Binding(get: { log10(Double(value)) }, set: { value = Int(pow(10, $0).rounded()) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Budget")
                Spacer()
                Text(value, format: .number)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: exponent, in: log10(Double(range.lowerBound)) ... log10(Double(range.upperBound)))
                .controlSize(.large)
        }
    }
}
