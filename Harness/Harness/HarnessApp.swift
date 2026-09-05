import SwiftUI

@main
struct HarnessApp: App {
    var body: some Scene {
        WindowGroup {
            HarnessView()
        }
        .defaultSize(width: 1120, height: 720)
    }
}
