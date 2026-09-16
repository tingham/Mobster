import Mobster
import SwiftUI

struct HeadParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        HeadSexPickerView(sex: $parameters.headSex)
        ParameterSliderView(title: "Target X", value: $parameters.headTarget.x, range: -2 ... 2)
        ParameterSliderView(title: "Target Y", value: $parameters.headTarget.y, range: -2 ... 2)
        ParameterSliderView(title: "Target Z", value: $parameters.headTarget.z, range: -2 ... 2)
        ParameterSliderView(title: "Roll", value: $parameters.headRoll, range: -180 ... 180)
        IntegerParameterSliderView(title: "Fit", value: $parameters.meshFit, range: 4 ... 48)
        ParameterSliderView(title: "Field Of View", value: $parameters.meshFieldOfView, range: MeshPerspective.range)
    }
}
