import SwiftUI

struct FieldParameterView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        Toggle("Show Field", isOn: $model.fieldVisible)
            .controlSize(.large)
        IntegerParameterSliderView(title: "Resolution", value: $model.fieldResolution, range: 8 ... 256)
    }
}
