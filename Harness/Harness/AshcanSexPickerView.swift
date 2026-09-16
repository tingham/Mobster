import Mobster
import SwiftUI

struct AshcanSexPickerView: View {
    @Binding var sex: AshcanSex

    var body: some View {
        Picker("Sex", selection: $sex) {
            Text("Male").tag(AshcanSex.male)
            Text("Female").tag(AshcanSex.female)
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
    }
}
