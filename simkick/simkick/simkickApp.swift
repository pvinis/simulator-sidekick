import SwiftUI


@main
struct simkickApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.windowResizability(.contentSize)
		.windowStyle(.hiddenTitleBar)
		.defaultSize(width: 200, height: 600)
    }
}
