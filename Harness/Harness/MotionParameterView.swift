import SwiftUI

struct MotionParameterView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        ParameterSliderView(title: "Reach", value: $model.reach, range: 0 ... 1000)
        ParameterSliderView(title: "Speed", value: $model.speed, range: 0 ... 2000)
        Toggle("Show Dirty Rects", isOn: $model.dirtyVisible)
            .controlSize(.large)
    }
}
