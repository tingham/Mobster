import SwiftUI

struct CurveParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        ParameterSliderView(title: "Center X", value: $parameters.curveCenter.x, range: 0 ... 1)
        ParameterSliderView(title: "Center Y", value: $parameters.curveCenter.y, range: 0 ... 1)
        ParameterSliderView(title: "First Degree", value: $parameters.curveFirstDegree, range: 0 ... 360)
        ParameterSliderView(title: "Second Degree", value: $parameters.curveSecondDegree, range: 0 ... 360)
        ParameterSliderView(title: "Distance", value: $parameters.curveDistance, range: 0 ... 0.5)
        ParameterSliderView(title: "Control X", value: $parameters.curveControl.x, range: 0 ... 1)
        ParameterSliderView(title: "Control Y", value: $parameters.curveControl.y, range: 0 ... 1)
        IntegerParameterSliderView(title: "Resolution", value: $parameters.curveResolution, range: 1 ... 128)
    }
}
