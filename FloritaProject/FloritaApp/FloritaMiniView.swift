import SwiftUI

/// Lightweight floating companion window mirroring Florita's status.
struct FloritaMiniView: View {
    /// Shared growth store that powers the UI.
    @ObservedObject var growthStore: FloritaGrowthStore
    /// Controls the watering animation overlay.
    @State private var isWateringAnimationActive = false

    var body: some View {
        ZStack {
            if shouldShowBackdrop {
                backgroundSurface
            }
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(wateringStatusMessage)
                            .font(.headline)
                        Text(growthStore.currentGrowthStage.localizedStageDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    FloritaPlantDisplay(growthStage: growthStore.currentGrowthStage,
                                        isAnimated: growthStore.isAnimationEnabled)
                        .overlay(WateringAnimationOverlay(isActive: isWateringAnimationActive))
                        .frame(width: 120, height: 120)
                }
                Button(action: handleWateringAction) {
                    Text(Copy.waterButton)
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(LinearGradient(colors: [Color(red: 0.36, green: 0.64, blue: 0.57),
                                                            Color(red: 0.27, green: 0.53, blue: 0.5)],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(growthStore.didWaterToday)
            }
            .padding(20)
        }
        .background(Color.clear)
        .background(WindowTransparencySynchronizer(isTransparent: growthStore.preferredBackgroundStyle.isTransparent || growthStore.isMiniWindowFullyTransparent))
        .padding(12)
    }

    /// Localized status line reflecting whether Florita was watered today.
    private var wateringStatusMessage: String {
        growthStore.didWaterToday ? Copy.wateredToday : Copy.notWateredToday
    }

    /// Performs watering logic, animation, and reminder scheduling.
    private func handleWateringAction() {
        guard growthStore.registerDailyWatering() else { return }
        performWateringAnimation()
        scheduleNextReminder()
    }

    /// Centralized copy used by the mini window.
    private enum Copy {
        static let waterButton = FloritaLocalization.localizedString("waterButton")
        static let notWateredToday = FloritaLocalization.localizedString("notWateredToday")
        static let wateredToday = FloritaLocalization.localizedString("wateredToday")
    }

    /// Determines whether the view should render its own background treatment.
    private var shouldShowBackdrop: Bool {
        !(growthStore.preferredBackgroundStyle.isTransparent || growthStore.isMiniWindowFullyTransparent)
    }

    /// Plays a brief cascading droplet animation while watering.
    private func performWateringAnimation(duration: Duration = .seconds(1.0)) {
        withAnimation { isWateringAnimationActive = true }
        Task { @MainActor in
            try? await Task.sleep(for: duration)
            withAnimation { isWateringAnimationActive = false }
        }
    }

    /// Schedules the next daily reminder once watering completes.
    private func scheduleNextReminder() {
        let now = Date()
        let nextReminder = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 9, minute: 0),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now.addingTimeInterval(24 * 60 * 60)
        ReminderNotificationService.shared.scheduleCareReminder(at: nextReminder)
    }

    /// Background surface that adapts to the selected theme when transparency is disabled.
    @ViewBuilder
    private var backgroundSurface: some View {
        switch growthStore.preferredBackgroundStyle {
        case .cozyGradient:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.94, green: 0.97, blue: 0.95),
                                              Color(red: 0.88, green: 0.94, blue: 0.9)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        case .softSunrise:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.85),
                                            Color(red: 0.99, green: 0.8, blue: 0.88)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.1)
                        .blendMode(.screen)
                )
                .shadow(color: Color(red: 0.94, green: 0.48, blue: 0.6).opacity(0.25), radius: 18, x: 0, y: 10)
        case .eveningTwilight:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color(red: 0.33, green: 0.28, blue: 0.5),
                                            Color(red: 0.12, green: 0.2, blue: 0.38)],
                                   startPoint: .top,
                                   endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(LinearGradient(colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.2)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 10)
        case .forestCanopy:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color(red: 0.8, green: 0.92, blue: 0.82),
                                            Color(red: 0.58, green: 0.79, blue: 0.68)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1.1)
                )
                .shadow(color: Color(red: 0.31, green: 0.57, blue: 0.44).opacity(0.22), radius: 14, x: 0, y: 8)
        case .plain:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.95, green: 0.96, blue: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        case .transparent:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.ultraThinMaterial))
        }
    }
}
