import SwiftUI
@main
struct FloritaApp: App {
    @StateObject private var store = PlantStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .frame(minWidth: store.windowSize.minimumSize.width, minHeight: store.windowSize.minimumSize.height)
        }
        WindowGroup("Florita Mini", id: "mini") {
            FloritaMiniView(store: store)
                .frame(minWidth: 360, minHeight: 220)
        }
        .defaultSize(width: 360, height: 220)
        .windowResizability(.contentSize)
        Settings {
            FloritaSettingsView(store: store)
        }
    }
}
