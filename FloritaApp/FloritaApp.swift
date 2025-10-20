import SwiftUI
import WidgetKit

@main
struct FloritaApp: App {
    @StateObject private var store = PlantStore.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .frame(minWidth: store.windowSize.minimumSize.width, minHeight: store.windowSize.minimumSize.height)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                WidgetCenter.shared.reloadTimelines(ofKind: FloritaWidgetConstants.kind)
            }
        }
        Settings {
            FloritaSettingsView(store: store)
        }
    }
}
