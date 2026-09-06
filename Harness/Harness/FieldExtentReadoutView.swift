import Mobster
import SwiftUI

/// The texel count the epsilon derived, which is the quantity the budget is spent on.
struct FieldExtentReadoutView: View {
    let field: Field

    var body: some View {
        HStack {
            Text("Texels")
            Spacer()
            Text("\(field.columns * field.rows, format: .number) (\(field.columns) by \(field.rows))")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
