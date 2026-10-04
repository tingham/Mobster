import SwiftUI

struct ParameterPanelView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        switch model.kind {
        case .goldenRatio, .thirds:
            FixedParameterView(title: presetTitle(model.kind))
        case .columns:
            ColumnsParameterView(parameters: $model.parameters)
        case .rows:
            RowsParameterView(parameters: $model.parameters)
        case .grid:
            GridParameterView(parameters: $model.parameters)
        case .ruler:
            RulerParameterView(parameters: $model.parameters)
        case .curve:
            CurveParameterView(parameters: $model.parameters)
        case .head:
            HeadParameterView(parameters: $model.parameters)
        case .figure:
            FigureParameterView(parameters: $model.parameters)
        case .cube:
            CubeParameterView(parameters: $model.parameters)
        }
    }
}
