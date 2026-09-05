import SwiftUI

struct BakeTimingReadoutView: View {
    let plot: FieldPlot?

    private var milliseconds: Double? {
        guard let components = plot?.duration.components else { return nil }
        return Double(components.seconds) * 1000 + Double(components.attoseconds) / 1_000_000_000_000_000
    }

    var body: some View {
        HStack {
            Text("Bake")
            Spacer()
            reading
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    private var reading: Text {
        guard let milliseconds else { return Text("Not baked") }
        return Text("\(milliseconds, format: .number.precision(.fractionLength(3))) ms")
    }
}
