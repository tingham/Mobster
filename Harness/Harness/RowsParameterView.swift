import SwiftUI

struct RowsParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        IntegerParameterSliderView(title: "Count", value: $parameters.rowCount, range: 1 ... 24)
        ParameterSliderView(title: "Gutter", value: $parameters.rowGutter, range: 0 ... 0.2)
    }
}
