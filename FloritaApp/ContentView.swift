import SwiftUI

/// Primary window responsible for presenting Florita's growth state and daily actions.
struct FloritaDashboardView: View {
    /// Shared growth store injected by the application entry point.
    @ObservedObject var growthStore: FloritaGrowthStore
    /// Window opener used to reveal companion windows.
    @Environment(\.openWindow) private var openWindow
    /// Tracks whether the onboarding sheet should currently be visible.
    @State private var isOnboardingPresented = false
    /// Toggles the watering drop overlay animation.
    @State private var isWateringAnimationActive = false

    var body: some View {
        ZStack {
            appBackdrop
            VStack(spacing: 32) {
                FloritaPlantDisplay(growthStage: growthStore.currentGrowthStage,
                                    isAnimated: growthStore.isAnimationEnabled,
                                    showsSunRays: growthStore.didWaterToday)
                    .overlay(WateringAnimationOverlay(isActive: isWateringAnimationActive))
                    .padding(26)
                    .background(plantCardBackdrop)
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .overlay(plantCardBorder)
                    .scaleEffect(isWateringAnimationActive ? 1.02 : 1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75), value: isWateringAnimationActive)

                VStack(spacing: 10) {
                    Text(wateringStatusMessage)
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color(red: 0.13, green: 0.31, blue: 0.43))
                    Text(growthStore.currentGrowthStage.localizedStageDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                Button(action: handleWateringAction) {
                    Text(FloritaLocalization.localizedString("waterButton"))
                        .font(.headline)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(wateringButtonBackground)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.28))
                        )
                }
                .buttonStyle(.plain)
                .disabled(growthStore.didWaterToday)
                .opacity(growthStore.didWaterToday ? 0.65 : 1)
                .scaleEffect(isWateringAnimationActive ? 0.98 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isWateringAnimationActive)

                Button(action: { openWindow(id: "mini") }) {
                    Label("Open Florita Mini", systemImage: "rectangle.portrait.on.rectangle.portrait")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .background(miniWindowButtonBackground)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 44)
            .frame(maxWidth: 520)
            hiddenGrowthAdvanceShortcut
        }
        .frame(minWidth: growthStore.preferredWindowSize.minimumSize.width,
               minHeight: growthStore.preferredWindowSize.minimumSize.height)
        .background(WindowSizeSynchronizer(targetSize: growthStore.preferredWindowSize.minimumSize))
        .background(WindowTransparencySynchronizer(isTransparent: growthStore.preferredBackgroundStyle.isTransparent))
        .onAppear {
            if isOnboardingPresented == false && growthStore.didCompleteOnboarding == false {
                isOnboardingPresented = true
            }
            ReminderNotificationService.shared.requestAuthorizationIfNeeded()
        }
        .onChange(of: growthStore.didCompleteOnboarding) { _, completed in
            isOnboardingPresented = !completed
        }
        .sheet(isPresented: $isOnboardingPresented) {
            OnboardingFlowView(isPresented: $isOnboardingPresented, growthStore: growthStore)
                .frame(minWidth: 420, minHeight: 360)
        }
    }

    /// Localized message describing today's watering status.
    private var wateringStatusMessage: String {
        growthStore.didWaterToday ? FloritaLocalization.localizedString("wateredToday") : FloritaLocalization.localizedString("notWateredToday")
    }

    /// Gradient used for the primary watering button background.
    private var wateringButtonBackground: some View {
        LinearGradient(colors: [Color(red: 0.09, green: 0.38, blue: 0.63),
                                Color(red: 0.03, green: 0.26, blue: 0.43)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    /// Subtle gradient applied to the "Florita Mini" button.
    private var miniWindowButtonBackground: some View {
        LinearGradient(colors: [Color.white.opacity(0.28), Color.white.opacity(0.08)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .background(Color.white.opacity(0.04))
    }

    /// Visual background for the plant card container.
    private var plantCardBackdrop: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(
                LinearGradient(colors: [Color(red: 0.93, green: 0.97, blue: 1.0),
                                        Color(red: 0.88, green: 0.96, blue: 0.94)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
    }

    /// Stroke and drop shadow applied around the plant card.
    private var plantCardBorder: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    /// Background gradient that tracks the selected window theme.
    private var appBackdrop: some View {
        Group {
            switch growthStore.preferredBackgroundStyle {
            case .cozyGradient:
                LinearGradient(colors: [Color(red: 0.82, green: 0.94, blue: 0.99),
                                        Color(red: 0.92, green: 0.98, blue: 0.96)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .overlay(
                        AngularGradient(colors: [Color.white.opacity(0.12), Color.clear], center: .center)
                            .blur(radius: 220)
                    )
            case .softSunrise:
                LinearGradient(colors: [Color(red: 1.0, green: 0.92, blue: 0.85),
                                        Color(red: 0.99, green: 0.79, blue: 0.88)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .overlay(
                        RadialGradient(colors: [Color.white.opacity(0.38), Color.clear],
                                       center: .topLeading,
                                       startRadius: 40,
                                       endRadius: 320)
                    )
                    .overlay(
                        LinearGradient(colors: [Color.white.opacity(0.12), Color.clear],
                                       startPoint: .bottomTrailing,
                                       endPoint: .topLeading)
                            .blur(radius: 200)
                    )
            case .eveningTwilight:
                LinearGradient(colors: [Color(red: 0.39, green: 0.32, blue: 0.58),
                                        Color(red: 0.15, green: 0.22, blue: 0.41)],
                               startPoint: .top,
                               endPoint: .bottomTrailing)
                    .overlay(
                        AngularGradient(colors: [Color.purple.opacity(0.25),
                                                 Color.blue.opacity(0.12),
                                                 Color.clear],
                                        center: .center)
                            .blur(radius: 240)
                    )
                    .overlay(
                        RadialGradient(colors: [Color.white.opacity(0.18), Color.clear],
                                       center: .top,
                                       startRadius: 20,
                                       endRadius: 260)
                    )
            case .forestCanopy:
                LinearGradient(colors: [Color(red: 0.78, green: 0.91, blue: 0.8),
                                        Color(red: 0.56, green: 0.78, blue: 0.68)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .overlay(
                        LinearGradient(colors: [Color.white.opacity(0.16), Color.clear],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                            .blur(radius: 160)
                    )
                    .overlay(
                        RadialGradient(colors: [Color.white.opacity(0.18), Color.clear],
                                       center: .bottom,
                                       startRadius: 10,
                                       endRadius: 260)
                    )
            case .plain:
                Color(red: 0.94, green: 0.97, blue: 0.99)
            case .transparent:
                Color.clear
            }
        }
        .ignoresSafeArea()
    }

    /// Handles the watering button tap, updating state and scheduling reminders.
    private func handleWateringAction() {
        guard growthStore.registerDailyWatering() else { return }
        animateWateringSequence()
        scheduleNextCareReminder()
    }

    /// Runs a short animation to highlight the watering interaction.
    /// - Parameter duration: Duration the overlay remains visible.
    private func animateWateringSequence(duration: Duration = .seconds(1.1)) {
        withAnimation {
            isWateringAnimationActive = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: duration)
            withAnimation {
                isWateringAnimationActive = false
            }
        }
    }

    /// Schedules the next gentle care reminder notification.
    private func scheduleNextCareReminder() {
        let now = Date()
        let nineAMComponents = DateComponents(hour: 9, minute: 0)
        let nextReminder = Calendar.current.nextDate(
            after: now,
            matching: nineAMComponents,
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now.addingTimeInterval(24 * 60 * 60)
        ReminderNotificationService.shared.scheduleCareReminder(at: nextReminder)
    }

    /// Hidden accelerator used during development to bump the growth stage.
    private func simulateGrowthAdvance() {
        growthStore.simulateGrowthForDebugging()
        animateWateringSequence(duration: .seconds(0.9))
    }

    /// Invisible button wired to the debug keyboard shortcut.
    @ViewBuilder
    private var hiddenGrowthAdvanceShortcut: some View {
        Button(action: simulateGrowthAdvance) {
            EmptyView()
        }
        .keyboardShortcut("g", modifiers: [.command, .option])
        .frame(width: 0, height: 0)
        .accessibilityHidden(true)
        .opacity(0)
    }
}

#if DEBUG
struct FloritaDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        FloritaDashboardView(growthStore: FloritaGrowthStore())
            .frame(width: 480, height: 600)
    }
}
#endif
