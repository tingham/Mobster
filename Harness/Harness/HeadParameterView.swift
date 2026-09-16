import SwiftUI

struct HeadParameterView: View {
    @Binding var parameters: PresetParameters

    var body: some View {
        HeadSexPickerView(sex: $parameters.headSex)
        // Zero is full profile, one is face forward, and the middle is the three quarter view.
        ParameterSliderView(title: "View", value: $parameters.headView, range: 0 ... 1)
    }
}
