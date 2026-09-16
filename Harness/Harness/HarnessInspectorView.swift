import SwiftUI

struct HarnessInspectorView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        Form {
            Section("Preset") {
                PresetPickerView(kind: $model.kind)
                PlotControlView(model: model)
                if let refusal = model.plot.refusal {
                    MeshRefusalReadoutView(refusal: refusal)
                }
            }
            Section("Parameters") {
                ParameterPanelView(model: model)
            }
            Section("Field") {
                FieldParameterView(model: model)
            }
            Section("Fixture") {
                FixtureParameterView(parameters: $model.fixture)
            }
            Section("Motion") {
                MotionParameterView(model: model)
            }
            Section("Transport") {
                TransportControlView(model: model)
                SettlementReadoutView(settled: model.motion.settled)
            }
            Section("Timing") {
                TimingReadoutView(plot: model.plot)
                PlayTimingReadoutView(plot: model.motion)
            }
        }
        .formStyle(.grouped)
        .frame(width: 340)
    }
}
