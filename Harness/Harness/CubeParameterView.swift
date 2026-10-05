import Mobster
import SwiftUI

struct CubeParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        ParameterSliderView(title: "Position X", value: $parameters.cubePosition.x, range: 0 ... 1)
        ParameterSliderView(title: "Position Y", value: $parameters.cubePosition.y, range: 0 ... 1)
        ParameterSliderView(title: "Size", value: $parameters.cubeSize, range: 0.05 ... 1)
        ViewParameterView(target: $parameters.cubeTarget, roll: $parameters.cubeRoll)
        IntegerParameterSliderView(title: "Fit", value: $parameters.meshFit, range: 4 ... 48)
        ParameterSliderView(title: "Field Of View", value: $parameters.meshFieldOfView, range: MeshPerspective.range)
    }
}
