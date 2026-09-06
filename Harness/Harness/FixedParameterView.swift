import SwiftUI

struct FixedParameterView: View {
    let title: String

    var body: some View {
        ContentUnavailableView("No Parameters",
                               systemImage: "slider.horizontal.3",
                               description: Text("\(title) exposes no parameters."))
    }
}
