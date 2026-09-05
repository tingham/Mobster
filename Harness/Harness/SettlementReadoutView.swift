import SwiftUI

struct SettlementReadoutView: View {
    let settled: Bool

    var body: some View {
        HStack {
            Text("Settlement")
            Spacer()
            Text(settled ? "Settled" : "In flight")
                .foregroundStyle(settled ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
        }
    }
}
