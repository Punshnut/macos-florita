import Cocoa
import SwiftUI

@main
struct MacNotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About MacNotes") {
                    // Action for About
                }
                .keyboardShortcut("I", modifiers: [.command])
            }
        }
    }
}