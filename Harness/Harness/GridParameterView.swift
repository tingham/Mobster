import SwiftUI

struct GridParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        IntegerParameterSliderView(title: "Count", value: $parameters.gridCount, range: 1 ... 24)
        ParameterSliderView(title: "Gutter", value: $parameters.gridGutter, range: 0 ... 0.2)
    }
}
