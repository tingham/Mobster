import SwiftUI

struct PresetPickerView: View {
    @Binding var kind: PresetKind

    var body: some View {
        Picker("Preset", selection: $kind) {
            ForEach(PresetKind.allCases) { candidate in
                Text(candidate.title).tag(candidate)
            }
        }
        .controlSize(.large)
    }
}
