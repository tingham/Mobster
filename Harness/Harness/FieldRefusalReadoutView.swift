import Mobster
import SwiftUI

/// A refused bake vends no field and a canvas with no field on it looks like a canvas nothing was drawn against, so the refusal is said outright along with the epsilon that would be paid for. A mesh source refuses for the identity pass instead, which carries no epsilon to report and so reports what the device would not do.
struct FieldRefusalReadoutView: View {
    let refusal: GuideRefusal

    private var asked: Float? {
        guard case let .field(bake) = refusal else { return nil }
        return bake.epsilon
    }

    private var affordable: Float? {
        guard case let .field(bake) = refusal else { return nil }
        return bake.affordable
    }

    private var pass: MeshRefusal? {
        guard case let .mesh(render) = refusal else { return nil }
        return render
    }

    var body: some View {
        HStack {
            Text("Bake")
            Spacer()
            Text("Refused")
                .foregroundStyle(.red)
        }
        if let asked, let affordable {
            HStack {
                Text("Asked")
                Spacer()
                Text(Double(asked), format: .number.precision(.fractionLength(3)))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Affordable")
                Spacer()
                Text(Double(affordable), format: .number.precision(.fractionLength(3)))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        if let pass {
            MeshRefusalReadoutView(refusal: pass)
        }
    }
}
