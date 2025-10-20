import SwiftUI

struct FloritaSettingsView: View {
    @ObservedObject var store: PlantStore

    var body: some View {
        Form {
            Section("Window") {
                Picker("Preferred Size", selection: windowSizeBinding) {
                    ForEach(WindowSizePreference.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                Picker("Background", selection: backgroundBinding) {
                    ForEach(BackgroundStylePreference.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                Toggle("Make Florita Mini fully transparent", isOn: miniWindowTransparencyBinding)
                    .toggleStyle(.switch)
            }

            Section("Menu Bar") {
                Toggle("Show Florita in menu bar", isOn: menuBarBinding)
                    .toggleStyle(.switch)
            }

            Section("Animation") {
                Toggle("Gently animate Florita's growth", isOn: animationBinding)
                    .toggleStyle(.switch)
                Text("Swap in your own animated art at any time – the current graphics are lightweight SwiftUI shapes.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 360)
    }

    private var animationBinding: Binding<Bool> {
        Binding(
            get: { store.prefersAnimatedGraphics },
            set: { store.prefersAnimatedGraphics = $0 }
        )
    }

    private var windowSizeBinding: Binding<WindowSizePreference> {
        Binding(
            get: { store.windowSize },
            set: { store.windowSize = $0 }
        )
    }

    private var backgroundBinding: Binding<BackgroundStylePreference> {
        Binding(
            get: { store.backgroundStyle },
            set: { store.backgroundStyle = $0 }
        )
    }

    private var menuBarBinding: Binding<Bool> {
        Binding(
            get: { store.menuBarIconEnabled },
            set: { store.menuBarIconEnabled = $0 }
        )
    }

    private var miniWindowTransparencyBinding: Binding<Bool> {
        Binding(
            get: { store.miniWindowPrefersFullTransparency },
            set: { store.miniWindowPrefersFullTransparency = $0 }
        )
    }
}
