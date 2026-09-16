import SwiftUI

struct CubeParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        ParameterSliderView(title: "Position X", value: $parameters.cubePosition.x, range: 0 ... 1)
        ParameterSliderView(title: "Position Y", value: $parameters.cubePosition.y, range: 0 ... 1)
        ParameterSliderView(title: "Size", value: $parameters.cubeSize, range: 0.05 ... 1)
        ParameterSliderView(title: "Target X", value: $parameters.cubeTarget.x, range: -2 ... 2)
        ParameterSliderView(title: "Target Y", value: $parameters.cubeTarget.y, range: -2 ... 2)
        ParameterSliderView(title: "Target Z", value: $parameters.cubeTarget.z, range: -2 ... 2)
        IntegerParameterSliderView(title: "Fit", value: $parameters.meshFit, range: 4 ... 48)
    }
}
