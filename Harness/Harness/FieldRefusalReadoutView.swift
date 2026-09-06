import Mobster
import SwiftUI

/// A refused bake vends no field and a canvas with no field on it looks like a canvas nothing was drawn against, so the refusal is said outright along with the epsilon that would be paid for.
struct FieldRefusalReadoutView: View {
    let refusal: FieldRefusal

    var body: some View {
        HStack {
            Text("Bake")
            Spacer()
            Text("Refused")
                .foregroundStyle(.red)
        }
        HStack {
            Text("Asked")
            Spacer()
            Text(Double(refusal.epsilon), format: .number.precision(.fractionLength(3)))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        HStack {
            Text("Affordable")
            Spacer()
            Text(Double(refusal.affordable), format: .number.precision(.fractionLength(3)))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
