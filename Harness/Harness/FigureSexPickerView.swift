import Mobster
import SwiftUI

struct FigureSexPickerView: View {
    @Binding var sex: FigureSex

    var body: some View {
        Picker("Sex", selection: $sex) {
            Text("Male").tag(FigureSex.male)
            Text("Female").tag(FigureSex.female)
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
    }
}
