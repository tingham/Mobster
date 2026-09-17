import Mobster
import SwiftUI

struct FigureParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        FigureSexPickerView(sex: $parameters.figureSex)
        ParameterSliderView(title: "Heads", value: $parameters.figureHeads, range: 4 ... 8)
        ParameterSliderView(title: "Target X", value: $parameters.figureTarget.x, range: -2 ... 2)
        ParameterSliderView(title: "Target Y", value: $parameters.figureTarget.y, range: -2 ... 2)
        ParameterSliderView(title: "Target Z", value: $parameters.figureTarget.z, range: -2 ... 2)
        IntegerParameterSliderView(title: "Fit", value: $parameters.meshFit, range: 4 ... 48)
        ParameterSliderView(title: "Field Of View", value: $parameters.meshFieldOfView, range: MeshPerspective.range)
        Toggle("Head Lines", isOn: $parameters.figureHeadLines)
            .controlSize(.large)
        ParameterSliderView(title: "Left Hand X", value: $parameters.figureLeftHand.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Hand Y", value: $parameters.figureLeftHand.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Hand X", value: $parameters.figureRightHand.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Hand Y", value: $parameters.figureRightHand.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Foot X", value: $parameters.figureLeftFoot.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Foot Y", value: $parameters.figureLeftFoot.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Foot X", value: $parameters.figureRightFoot.x, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Right Foot Y", value: $parameters.figureRightFoot.y, range: -0.5 ... 1.5)
        ParameterSliderView(title: "Left Elbow Pole", value: $parameters.figureLeftElbowDegree, range: 0 ... 360)
        ParameterSliderView(title: "Right Elbow Pole", value: $parameters.figureRightElbowDegree, range: 0 ... 360)
        ParameterSliderView(title: "Left Knee Pole", value: $parameters.figureLeftKneeDegree, range: 0 ... 360)
        ParameterSliderView(title: "Right Knee Pole", value: $parameters.figureRightKneeDegree, range: 0 ... 360)
    }
}
