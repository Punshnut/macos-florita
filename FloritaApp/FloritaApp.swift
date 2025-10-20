import SwiftUI
@main
struct FloritaApp: App {
    @StateObject private var store = PlantStore.shared

    private var menuBarBinding: Binding<Bool> {
        Binding(
            get: { store.menuBarIconEnabled },
            set: { store.menuBarIconEnabled = $0 }
        )
    }

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
        MenuBarExtra("Florita", systemImage: "leaf.fill", isInserted: menuBarBinding) {
            FloritaMenuBarView(store: store)
                .frame(width: 240)
        }
        .menuBarExtraStyle(.window)
    }
}
