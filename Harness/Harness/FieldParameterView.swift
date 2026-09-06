import SwiftUI

struct FieldParameterView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        Toggle("Show Field", isOn: $model.fieldVisible)
            .controlSize(.large)
    }
}
