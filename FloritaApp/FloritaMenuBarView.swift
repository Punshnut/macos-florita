import SwiftUI

/// Compact dashboard presented inside the menu bar extra.
struct FloritaMenuBarView: View {
    /// Shared growth store keeping track of Florita's state.
    @ObservedObject var growthStore: FloritaGrowthStore
    /// Controls the brief watering animation overlay.
    @State private var isWateringAnimationActive = false

    var body: some View {
        VStack(spacing: 16) {
            miniHeader
            FloritaPlantDisplay(growthStage: growthStore.currentGrowthStage,
                                isAnimated: growthStore.isAnimationEnabled)
                .overlay(WateringAnimationOverlay(isActive: isWateringAnimationActive))
                .frame(width: 140, height: 140)
            Button(action: handleWateringAction) {
                Text(FloritaLocalization.localizedString("waterButton"))
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(LinearGradient(colors: [Color(red: 0.36, green: 0.64, blue: 0.57),
                                                        Color(red: 0.27, green: 0.53, blue: 0.5)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(growthStore.didWaterToday)

            if growthStore.didWaterToday {
                Text(FloritaLocalization.localizedString("wateredToday"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 220)
    }

    /// Header summarizing the current watering status.
    private var miniHeader: some View {
        VStack(spacing: 4) {
            Text(wateringStatusMessage)
                .font(.headline)
            Text(growthStore.currentGrowthStage.localizedStageDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .multilineTextAlignment(.center)
    }

    /// Localized status line for the header.
    private var wateringStatusMessage: String {
        growthStore.didWaterToday ? FloritaLocalization.localizedString("wateredToday") : FloritaLocalization.localizedString("notWateredToday")
    }

    /// Handles watering from the menu bar view and animates feedback.
    private func handleWateringAction() {
        guard growthStore.registerDailyWatering() else { return }
        withAnimation { isWateringAnimationActive = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.0))
            withAnimation { isWateringAnimationActive = false }
        }
        let now = Date()
        let nextReminder = Calendar.current.nextDate(after: now,
                                                     matching: DateComponents(hour: 9, minute: 0),
                                                     matchingPolicy: .nextTimePreservingSmallerComponents) ?? now.addingTimeInterval(24 * 60 * 60)
        ReminderNotificationService.shared.scheduleCareReminder(at: nextReminder)
    }
}
