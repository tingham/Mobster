import SwiftUI

struct AshcanParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        AshcanSexPickerView(sex: $parameters.ashcanSex)
        ParameterSliderView(title: "Heads", value: $parameters.ashcanHeads, range: 4 ... 8)
        Toggle("Head Lines", isOn: $parameters.ashcanHeadLines)
            .controlSize(.large)
        ParameterSliderView(title: "Left Hand X", value: $parameters.ashcanLeftHand.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Hand Y", value: $parameters.ashcanLeftHand.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Hand X", value: $parameters.ashcanRightHand.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Hand Y", value: $parameters.ashcanRightHand.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Foot X", value: $parameters.ashcanLeftFoot.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Foot Y", value: $parameters.ashcanLeftFoot.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Foot X", value: $parameters.ashcanRightFoot.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Foot Y", value: $parameters.ashcanRightFoot.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Elbow Pole", value: $parameters.ashcanLeftElbowDegree, range: 0 ... 360)
        ParameterSliderView(title: "Right Elbow Pole", value: $parameters.ashcanRightElbowDegree, range: 0 ... 360)
        ParameterSliderView(title: "Left Knee Pole", value: $parameters.ashcanLeftKneeDegree, range: 0 ... 360)
        ParameterSliderView(title: "Right Knee Pole", value: $parameters.ashcanRightKneeDegree, range: 0 ... 360)
    }
}
