import Mobster
import SwiftUI

/// The texel count the epsilon derived, which is the quantity the budget is spent on.
struct FieldExtentReadoutView: View {
    let raster: FieldRaster

    var body: some View {
        HStack {
            Text("Texels")
            Spacer()
            Text("\(raster.columns * raster.rows, format: .number) (\(raster.columns) by \(raster.rows))")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
