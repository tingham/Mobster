import SwiftUI

struct HarnessView: View {
    @State private var model = HarnessModel()

    var body: some View {
        HStack(spacing: 0) {
            PresetCanvasView(frame: HarnessModel.frame, paths: model.plot.paths, strokes: model.strokes)
            Divider()
            HarnessInspectorView(model: model)
        }
    }
}
