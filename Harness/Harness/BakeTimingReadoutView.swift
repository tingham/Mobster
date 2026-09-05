import SwiftUI

struct BakeTimingReadoutView: View {
    let plot: FieldPlot

    private var milliseconds: Double {
        let components = plot.duration.components
        return Double(components.seconds) * 1000 + Double(components.attoseconds) / 1_000_000_000_000_000
    }

    var body: some View {
        HStack {
            Text("Bake")
            Spacer()
            Text("\(milliseconds, format: .number.precision(.fractionLength(3))) ms")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
