import Mobster
import SwiftUI

struct HeadSexPickerView: View {
    @Binding var sex: HeadSex

    var body: some View {
        Picker("Sex", selection: $sex) {
            Text("Male").tag(HeadSex.male)
            Text("Female").tag(HeadSex.female)
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
    }
}
