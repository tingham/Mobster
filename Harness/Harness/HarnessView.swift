import Combine
import SwiftUI

struct HarnessView: View {
    @State private var model = HarnessModel()
    /// Held in state rather than rebuilt with the body, so a redraw does not resubscribe and restart the cadence.
    @State private var tick = Timer.publish(every: Transport.interval, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 0) {
            PresetCanvasView(frame: HarnessModel.frame,
                             raster: model.raster,
                             paths: model.plot.paths,
                             lines: model.lines,
                             displaced: model.motion.lines)
            Divider()
            HarnessInspectorView(model: model)
        }
        .onReceive(tick) { _ in model.tick() }
    }
}
