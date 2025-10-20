import SwiftUI
struct ContentView: View {
    @ObservedObject var store: PlantStore
    @Environment(\.openWindow) private var openWindow
    @State private var showOnboarding = false
    @State private var isWatering = false

    var body: some View {
        ZStack {
            appBackground
            VStack(spacing: 32) {
                PlantDisplayView(stage: store.stage, animated: store.prefersAnimatedGraphics)
                    .overlay(WateringOverlay(isActive: isWatering))
                    .padding(26)
                    .background(plantCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .overlay(plantCardStroke)
                    .scaleEffect(isWatering ? 1.02 : 1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75), value: isWatering)

                VStack(spacing: 10) {
                    Text(statusText)
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color(red: 0.13, green: 0.31, blue: 0.43))
                    Text(store.stage.localizedDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                Button(action: waterPlant) {
                    Text(Localization.string("waterButton"))
                        .font(.headline)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(buttonBackground)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.28))
                        )
                }
                .buttonStyle(.plain)
                .disabled(store.hasWateredToday)
                .opacity(store.hasWateredToday ? 0.65 : 1)
                .scaleEffect(isWatering ? 0.98 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isWatering)

                Button(action: { openWindow(id: "mini") }) {
                    Label("Open Florita Mini", systemImage: "rectangle.portrait.on.rectangle.portrait")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .background(miniButtonBackground)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 44)
            .frame(maxWidth: 520)
        }
        .frame(minWidth: store.windowSize.minimumSize.width, minHeight: store.windowSize.minimumSize.height)
        .onAppear {
            if showOnboarding == false && store.hasCompletedOnboarding == false {
                showOnboarding = true
            }
            NotificationService.shared.requestAuthorizationIfNeeded()
        }
        .onChange(of: store.hasCompletedOnboarding) { _, completed in
            showOnboarding = !completed
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingFlowView(isPresented: $showOnboarding, store: store)
                .frame(minWidth: 420, minHeight: 360)
        }
    }

    private var statusText: String {
        store.hasWateredToday ? Localization.string("wateredToday") : Localization.string("notWateredToday")
    }

    private var buttonBackground: some View {
        LinearGradient(colors: [Color(red: 0.09, green: 0.38, blue: 0.63),
                                Color(red: 0.03, green: 0.26, blue: 0.43)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    private var miniButtonBackground: some View {
        LinearGradient(colors: [Color.white.opacity(0.28), Color.white.opacity(0.08)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .background(Color.white.opacity(0.04))
    }

    private var plantCardBackground: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(
                LinearGradient(colors: [Color(red: 0.93, green: 0.97, blue: 1.0),
                                        Color(red: 0.88, green: 0.96, blue: 0.94)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
    }

    private var plantCardStroke: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var appBackground: some View {
        Group {
            switch store.backgroundStyle {
            case .cozyGradient:
                LinearGradient(colors: [Color(red: 0.82, green: 0.94, blue: 0.99),
                                        Color(red: 0.92, green: 0.98, blue: 0.96)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .overlay(
                        AngularGradient(colors: [Color.white.opacity(0.12), Color.clear], center: .center)
                            .blur(radius: 220)
                    )
            case .plain:
                Color(red: 0.94, green: 0.97, blue: 0.99)
            case .transparent:
                Color.clear
            }
        }
        .ignoresSafeArea()
    }

    private func waterPlant() {
        let didWater = store.waterToday()
        guard didWater else { return }
        withAnimation {
            isWatering = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.1))
            withAnimation {
                isWatering = false
            }
        }
        let now = Date()
        let nextNine = Calendar.current.nextDate(after: now, matching: DateComponents(hour: 9, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents) ?? now.addingTimeInterval(24 * 60 * 60)
        NotificationService.shared.scheduleCareReminder(at: nextNine)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: PlantStore())
            .frame(width: 480, height: 600)
    }
}
#endif
