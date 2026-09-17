import Mobster
import SwiftUI

struct FigurePosePickerView: View {
    @Binding var parameters: PresetParameters

    /// Choosing a pose sets all four targets at once. Nothing interpolates between two of them, so this is a picker and not a slider.
    private var selection: Binding<String> {
        Binding(get: { parameters.figurePose },
                set: { name in
                    guard let pose = FigurePose.named.first(where: { $0.name == name }) else { return }
                    parameters.pose(pose)
                })
    }

    var body: some View {
        Picker("Pose", selection: selection) {
            ForEach(FigurePose.named, id: \.name) { pose in
                Text(pose.name).tag(pose.name)
            }
        }
        .controlSize(.large)
    }
}
