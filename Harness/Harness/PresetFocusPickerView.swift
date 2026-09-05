import Mobster
import SwiftUI

struct PresetFocusPickerView: View {
    @Binding var focus: PresetFocus

    var body: some View {
        // The corners are named on the scene axes rather than by screen position, which is the canvas orientation's business and not the preset's.
        Picker("Focus", selection: $focus) {
            Text("Min X, Min Y").tag(PresetFocus.minXMinY)
            Text("Max X, Min Y").tag(PresetFocus.maxXMinY)
            Text("Min X, Max Y").tag(PresetFocus.minXMaxY)
            Text("Max X, Max Y").tag(PresetFocus.maxXMaxY)
        }
        .controlSize(.large)
    }
}
