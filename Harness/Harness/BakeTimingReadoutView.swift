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
        #if DEBUG
        // The figure above is a debug bake and a consumer ships against a release one, which measured a hundred times faster on the same field.
        Text("Debug build. The same bake measured about a hundred times faster in release.")
            .font(.caption)
            .foregroundStyle(.secondary)
        #endif
    }
}
