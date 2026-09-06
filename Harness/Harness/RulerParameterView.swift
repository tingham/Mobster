import SwiftUI

struct RulerParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        ParameterSliderView(title: "Center X", value: $parameters.rulerCenter.x, range: 0 ... 1)
        ParameterSliderView(title: "Center Y", value: $parameters.rulerCenter.y, range: 0 ... 1)
        ParameterSliderView(title: "First Degree", value: $parameters.rulerFirstDegree, range: 0 ... 360)
        ParameterSliderView(title: "Second Degree", value: $parameters.rulerSecondDegree, range: 0 ... 360)
        ParameterSliderView(title: "Distance", value: $parameters.rulerDistance, range: 0 ... 0.5)
    }
}
