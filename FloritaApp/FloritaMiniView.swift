import SwiftUI

struct FloritaMiniView: View {
    @ObservedObject var store: PlantStore
    @State private var isWatering = false

    var body: some View {
        ZStack {
            if shouldShowBackdrop {
                backgroundSurface
            }
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(statusText)
                            .font(.headline)
                        Text(store.stage.localizedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    PlantDisplayView(stage: store.stage, animated: store.prefersAnimatedGraphics)
                        .overlay(WateringOverlay(isActive: isWatering))
                        .frame(width: 120, height: 120)
                }
                Button(action: waterPlant) {
                    Text(StoreCopy.waterButton)
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(LinearGradient(colors: [Color(red: 0.36, green: 0.64, blue: 0.57), Color(red: 0.27, green: 0.53, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(store.hasWateredToday)
            }
            .padding(20)
        }
        .background(Color.clear)
        .background(WindowTransparencyApplier(isTransparent: store.backgroundStyle.isTransparent || store.miniWindowPrefersFullTransparency))
        .padding(12)
    }

    private var statusText: String {
        store.hasWateredToday ? StoreCopy.wateredToday : StoreCopy.notWateredToday
    }

    private func waterPlant() {
        guard store.waterToday() else { return }
        triggerWateringAnimation()
        scheduleNextReminder()
    }

    private enum StoreCopy {
        static let waterButton = Localization.string("waterButton")
        static let notWateredToday = Localization.string("notWateredToday")
        static let wateredToday = Localization.string("wateredToday")
    }

    private var shouldShowBackdrop: Bool {
        !(store.backgroundStyle.isTransparent || store.miniWindowPrefersFullTransparency)
    }

    private func triggerWateringAnimation(duration: Duration = .seconds(1.0)) {
        withAnimation { isWatering = true }
        Task { @MainActor in
            try? await Task.sleep(for: duration)
            withAnimation { isWatering = false }
        }
    }

    private func scheduleNextReminder() {
        let now = Date()
        let nextNine = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 9, minute: 0),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now.addingTimeInterval(24 * 60 * 60)
        NotificationService.shared.scheduleCareReminder(at: nextNine)
    }

    @ViewBuilder
    private var backgroundSurface: some View {
        switch store.backgroundStyle {
        case .cozyGradient:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.94, green: 0.97, blue: 0.95), Color(red: 0.88, green: 0.94, blue: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
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
