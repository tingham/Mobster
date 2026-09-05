import SwiftUI

struct ColumnsParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        IntegerParameterSliderView(title: "Count", value: $parameters.columnCount, range: 1 ... 24)
        ParameterSliderView(title: "Gutter", value: $parameters.columnGutter, range: 0 ... 0.2)
    }
}
