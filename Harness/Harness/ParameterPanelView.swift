import SwiftUI

struct ParameterPanelView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        switch model.kind {
        case .goldenRatio, .thirds:
            FixedParameterView(title: model.kind.title)
        case .columns:
            ColumnsParameterView(parameters: $model.parameters)
        case .rows:
            RowsParameterView(parameters: $model.parameters)
        case .ruler:
            RulerParameterView(parameters: $model.parameters)
        case .curve:
            CurveParameterView(parameters: $model.parameters)
        }
    }
}
