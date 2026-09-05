import SwiftUI

struct MotionParameterView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        ParameterSliderView(title: "Reach", value: $model.reach, range: 0 ... 1000)
        ParameterSliderView(title: "Speed", value: $model.speed, range: 0 ... 2000)
        ParameterSliderView(title: "Settle Epsilon", value: $model.settleEpsilon, range: 0 ... 20)
        Toggle("Show Dirty Rects", isOn: $model.dirtyVisible)
            .controlSize(.large)
    }
}
