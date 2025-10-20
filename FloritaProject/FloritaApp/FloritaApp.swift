import SwiftUI
@main
struct FloritaApp: App {
    /// Shared store that coordinates growth data and preferences.
    @StateObject private var growthStore = FloritaGrowthStore.sharedStore

    /// Binding bridging the store's menu bar visibility preference to SwiftUI.
    private var menuBarBinding: Binding<Bool> {
        Binding(
            get: { growthStore.isMenuBarItemVisible },
            set: { growthStore.isMenuBarItemVisible = $0 }
        )
    }

    /// Configures all macOS scenes: main dashboard, mini window, settings, and menu bar extra.
    var body: some Scene {
        WindowGroup {
            FloritaDashboardView(growthStore: growthStore)
                .frame(minWidth: growthStore.preferredWindowSize.minimumSize.width,
                       minHeight: growthStore.preferredWindowSize.minimumSize.height)
        }
        WindowGroup("Florita Mini", id: "mini") {
            FloritaMiniView(growthStore: growthStore)
                .frame(minWidth: 360, minHeight: 220)
        }
        .defaultSize(width: 360, height: 220)
        .windowResizability(.contentSize)
        Settings {
            FloritaSettingsView(growthStore: growthStore)
        }
        MenuBarExtra("Florita", systemImage: "leaf.fill", isInserted: menuBarBinding) {
            FloritaMenuBarView(growthStore: growthStore)
                .frame(width: 240)
        }
        .menuBarExtraStyle(.window)
    }
}
