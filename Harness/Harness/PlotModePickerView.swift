import Mobster
import SwiftUI

struct PlotModePickerView: View {
    @Binding var mode: PresetPlotMode

    var body: some View {
        Picker("Plot Mode", selection: $mode) {
            Text("Aspect").tag(PresetPlotMode.aspect)
            Text("Bounds").tag(PresetPlotMode.bounds)
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
    }
}
