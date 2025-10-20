import SwiftUI

struct FloritaMenuBarView: View {
    @ObservedObject var store: PlantStore
    @State private var isWatering = false

    var body: some View {
        VStack(spacing: 16) {
            miniHeader
            PlantDisplayView(stage: store.stage, animated: store.prefersAnimatedGraphics)
                .overlay(WateringOverlay(isActive: isWatering))
                .frame(width: 140, height: 140)
            Button(action: waterPlant) {
                Text(Localization.string("waterButton"))
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(LinearGradient(colors: [Color(red: 0.36, green: 0.64, blue: 0.57), Color(red: 0.27, green: 0.53, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(store.hasWateredToday)

            if store.hasWateredToday {
                Text(Localization.string("wateredToday"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 220)
    }

    private var miniHeader: some View {
        VStack(spacing: 4) {
            Text(statusText)
                .font(.headline)
            Text(store.stage.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .multilineTextAlignment(.center)
    }

    private var statusText: String {
        store.hasWateredToday ? Localization.string("wateredToday") : Localization.string("notWateredToday")
    }

    private func waterPlant() {
        guard store.waterToday() else { return }
        withAnimation { isWatering = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.0))
            withAnimation { isWatering = false }
        }
        let now = Date()
        let nextNine = Calendar.current.nextDate(after: now, matching: DateComponents(hour: 9, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents) ?? now.addingTimeInterval(24 * 60 * 60)
        NotificationService.shared.scheduleCareReminder(at: nextNine)
    }
}
