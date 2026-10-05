import Mobster
import SwiftUI

struct HeadParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        HeadSexPickerView(sex: $parameters.headSex)
        ViewParameterView(target: $parameters.headTarget, roll: $parameters.headRoll)
        IntegerParameterSliderView(title: "Fit", value: $parameters.meshFit, range: 4 ... 48)
        ParameterSliderView(title: "Field Of View", value: $parameters.meshFieldOfView, range: MeshPerspective.range)
    }
}
