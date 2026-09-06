import SwiftUI

struct FieldParameterView: View {
    @Bindable var model: HarnessModel

    var body: some View {
        Toggle("Show Field", isOn: $model.fieldVisible)
            .controlSize(.large)
        ParameterSliderView(title: "Settle Epsilon", value: $model.settleEpsilon, range: 0 ... 20)
        BudgetParameterSliderView(value: $model.budget, range: HarnessModel.budgetRange)
        if let refusal = model.field.refusal {
            FieldRefusalReadoutView(refusal: refusal)
        } else {
            FieldExtentReadoutView(field: model.field.field)
        }
        BakeTimingReadoutView(plot: model.field)
    }
}
