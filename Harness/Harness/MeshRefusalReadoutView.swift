import Mobster
import SwiftUI

/// What the device would not do, said outright. A mesh that draws nothing and a mesh the identity pass never ran for look the same on a canvas, which is the whole reason this is on screen.
struct MeshRefusalReadoutView: View {
    let refusal: MeshRefusal

    private var reason: String {
        switch refusal {
        case .pass: "Pass would not compile"
        case let .target(columns, rows): "Target of \(columns) by \(rows) would not allocate"
        case let .buffers(triangles): "Buffers for \(triangles) triangles would not allocate"
        case .encoding: "Nothing to encode the pass into"
        }
    }

    var body: some View {
        HStack {
            Text("Mesh")
            Spacer()
            Text("Refused")
                .foregroundStyle(.red)
        }
        HStack {
            Text("Reason")
            Spacer()
            Text(reason)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
