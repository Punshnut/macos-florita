import SwiftUI

/// Settings surface for configuring Florita's presentation and behavior.
struct FloritaSettingsView: View {
    /// Shared growth store feeding user preferences.
    @ObservedObject var growthStore: FloritaGrowthStore
    /// Controls the destructive reset confirmation alert.
    @State private var isResetConfirmationPresented = false

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

            Section("Growth") {
                Button(role: .destructive, action: { isResetConfirmationPresented = true }) {
                    Label("Reset Florita's growth journey", systemImage: "arrow.counterclockwise.heart")
                }
                Text("Need a fresh start? Resetting brings Florita back to sprout stage, ready for new memories.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 360)
        .alert("Start fresh with Florita?", isPresented: $isResetConfirmationPresented) {
            Button("Begin again", role: .destructive) {
                growthStore.resetGrowthHistory()
            }
            Button("Keep growing", role: .cancel) { }
        } message: {
            Text("Florita will forget every watering day and curl back into a tiny sprout. We'll cheer together from day one!")
        }
    }

    /// Binding bridging animation preference edits back into the store.
    private var animationBinding: Binding<Bool> {
        Binding(
            get: { growthStore.isAnimationEnabled },
            set: { growthStore.isAnimationEnabled = $0 }
        )
    }

    /// Binding for the primary window size preference.
    private var windowSizeBinding: Binding<WindowSizePreference> {
        Binding(
            get: { growthStore.preferredWindowSize },
            set: { growthStore.preferredWindowSize = $0 }
        )
    }

    /// Binding for the global background style selection.
    private var backgroundBinding: Binding<BackgroundStylePreference> {
        Binding(
            get: { growthStore.preferredBackgroundStyle },
            set: { growthStore.preferredBackgroundStyle = $0 }
        )
    }

    /// Binding for toggling the menu bar extra visibility.
    private var menuBarBinding: Binding<Bool> {
        Binding(
            get: { growthStore.isMenuBarItemVisible },
            set: { growthStore.isMenuBarItemVisible = $0 }
        )
    }

    /// Binding representing the transparency preference for the mini window.
    private var miniWindowTransparencyBinding: Binding<Bool> {
        Binding(
            get: { growthStore.isMiniWindowFullyTransparent },
            set: { growthStore.isMiniWindowFullyTransparent = $0 }
        )
    }
}
