import Mobster
import SwiftUI

struct FigureParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        FigureSexPickerView(sex: $parameters.figureSex)
        FigurePosePickerView(parameters: $parameters)
        ParameterSliderView(title: "Heads", value: $parameters.figureHeads, range: 4 ... 8)
        ParameterSliderView(title: "Target X", value: $parameters.figureTarget.x, range: -2 ... 2)
        ParameterSliderView(title: "Target Y", value: $parameters.figureTarget.y, range: -2 ... 2)
        ParameterSliderView(title: "Target Z", value: $parameters.figureTarget.z, range: -2 ... 2)
        IntegerParameterSliderView(title: "Fit", value: $parameters.meshFit, range: 4 ... 48)
        ParameterSliderView(title: "Field Of View", value: $parameters.meshFieldOfView, range: MeshPerspective.range)
        Toggle("Head Lines", isOn: $parameters.figureHeadLines)
            .controlSize(.large)
    }
}
