import SwiftUI

struct MotionParameterView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        ParameterSliderView(title: "Adhesion", value: $model.adhesion, range: 0 ... 1)
        ParameterSliderView(title: "Duration", value: $model.run, range: 0 ... 8)
        ParameterSliderView(title: "Coupling", value: $model.coupling, range: -1 ... 1)
    }
}
