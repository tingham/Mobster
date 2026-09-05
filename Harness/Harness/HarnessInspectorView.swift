import SwiftUI

struct HarnessInspectorView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        Form {
            Section("Preset") {
                PresetPickerView(kind: $model.kind)
                PlotModePickerView(mode: $model.mode)
            }
            Section("Parameters") {
                ParameterPanelView(model: model)
            }
            Section("Fixture") {
                FixtureParameterView(parameters: $model.fixture)
            }
            Section("Timing") {
                TimingReadoutView(plot: model.plot)
            }
        }
        .formStyle(.grouped)
        .frame(width: 340)
    }
}
