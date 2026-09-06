import MobsterFixture
import SwiftUI

struct FixtureParameterView: View {
    @Binding var parameters: FixtureParameters

    var body: some View {
        SeedParameterView(parameters: $parameters)
        IntegerParameterSliderView(title: "Lines", value: $parameters.lineCount, range: 0 ... 200)
        IntegerParameterSliderView(title: "Verts Per Line", value: $parameters.vertsPerLine, range: 1 ... 400)
        ParameterSliderView(title: "Step", value: $parameters.step, range: 0.001 ... 0.2)
        ParameterSliderView(title: "Turn", value: $parameters.turn, range: 0 ... 180)
        ParameterSliderView(title: "Margin", value: $parameters.margin, range: 0 ... 0.45)
    }
}
