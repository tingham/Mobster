import SwiftUI

struct TransportControlView: View {
    let model: HarnessModel

    /// The scrub works in a continuous value and lands on the whole step index the transport counts in.
    private var scrub: Binding<Double> {
        Binding(get: { Double(model.transport.step) }, set: { model.scrub(to: Int($0.rounded())) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button(model.transport.playing ? "Pause" : "Play") {
                    model.transport.playing.toggle()
                }
                .controlSize(.large)
                .frame(minWidth: 88)
                Spacer()
                Text("\(model.transport.time, format: .number.precision(.fractionLength(3))) s")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: scrub, in: 0 ... Double(Transport.limit), step: 1)
                .controlSize(.large)
        }
    }
}
