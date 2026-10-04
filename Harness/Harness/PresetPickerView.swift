import Mobster
import SwiftUI

struct PresetPickerView: View {
    @Binding var kind: PresetKind

    var body: some View {
        Picker("Preset", selection: $kind) {
            ForEach(PresetKind.allCases, id: \.self) { candidate in
                Text(presetTitle(candidate)).tag(candidate)
            }
        }
        .controlSize(.large)
    }
}
