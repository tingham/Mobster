import SwiftUI

struct PlotControlView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        switch model.kind {
        case .goldenRatio:
            PresetFocusPickerView(focus: $model.focus)
        case .thirds, .columns, .rows, .ruler, .curve:
            PlotModePickerView(mode: $model.mode)
        }
    }
}
