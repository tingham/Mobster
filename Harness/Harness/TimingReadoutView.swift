import SwiftUI

struct TimingReadoutView: View {
    let plot: PresetPlot

    private var microseconds: Double {
        let components = plot.duration.components
        return Double(components.seconds) * 1_000_000 + Double(components.attoseconds) / 1_000_000_000_000
    }

    var body: some View {
        HStack {
            Text("Generation")
            Spacer()
            Text("\(microseconds, format: .number.precision(.fractionLength(1))) µs")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
