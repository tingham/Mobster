import SwiftUI

struct PlotControlView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        switch model.kind {
        case .goldenRatio:
            PresetFocusPickerView(focus: $model.focus)
        case .head, .figure, .cube:
            Toggle("Show Identities", isOn: $model.identityVisible)
                .controlSize(.large)
        case .thirds, .columns, .rows, .grid, .ruler, .curve:
            EmptyView()
        }
    }
}
