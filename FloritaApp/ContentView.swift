import SwiftUI
struct ContentView: View {
    @ObservedObject var store: PlantStore
    @Environment(\.openWindow) private var openWindow
    @State private var showOnboarding = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)
            Group {
                if store.prefersAnimatedGraphics {
                    AnimatedPlantCanvas(stage: store.stage)
                } else {
                    PlantCanvas(stage: store.stage)
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Text(statusText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.22, green: 0.35, blue: 0.31))
                Text(store.stage.localizedDescription)
                    .font(.body)
                    .foregroundStyle(Color.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)

            Button(action: waterPlant) {
                Text(Localization.string("waterButton"))
                    .font(.headline)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(buttonBackground)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 36)
            .disabled(store.hasWateredToday)

            Button(action: { openWindow(id: "mini") }) {
                Label("Open Florita Mini", systemImage: "rectangle.portrait.on.rectangle.portrait")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)

            Spacer(minLength: 12)
        }
        .padding(.vertical, 32)
        .frame(minWidth: store.windowSize.minimumSize.width, minHeight: store.windowSize.minimumSize.height)
        .background(appBackground)
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
        LinearGradient(colors: [Color(red: 0.36, green: 0.64, blue: 0.57), Color(red: 0.27, green: 0.53, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var appBackground: some View {
        Group {
            switch store.backgroundStyle {
            case .cozyGradient:
                ZStack {
                    LinearGradient(colors: [Color(red: 0.95, green: 0.97, blue: 0.98), Color(red: 0.91, green: 0.95, blue: 0.92)], startPoint: .top, endPoint: .bottom)
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        .padding(12)
                }
            case .plain:
                Color(red: 0.96, green: 0.97, blue: 0.96)
            case .transparent:
                Color.clear
            }
        }
        .ignoresSafeArea()
    }

    private func waterPlant() {
        let didWater = store.waterToday()
        guard didWater else { return }
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
