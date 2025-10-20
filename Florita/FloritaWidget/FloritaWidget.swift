import WidgetKit
import SwiftUI
import AppIntents

struct FloritaEntry: TimelineEntry {
    let date: Date
    let snapshot: PlantSnapshot
}

struct FloritaTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> FloritaEntry {
        FloritaEntry(date: Date(), snapshot: PlantSnapshot(lastWateredDate: Date(), daysOfCare: 4, stage: .leaves, prefersAnimatedGraphics: false, windowSize: .large, backgroundStyle: .cozyGradient))
    }

    func getSnapshot(in context: Context, completion: @escaping (FloritaEntry) -> Void) {
        completion(makeEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FloritaEntry>) -> Void) {
        let currentDate = Date()
        let entry = makeEntry(for: currentDate)
        let calendar = Calendar(identifier: .gregorian)
        let nextReload = calendar.nextDate(after: currentDate, matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTimePreservingSmallerComponents) ?? currentDate.addingTimeInterval(60 * 60 * 24)

        let timeline = Timeline(entries: [entry], policy: .after(nextReload))
        completion(timeline)
    }

    private func makeEntry(for date: Date) -> FloritaEntry {
        FloritaEntry(date: date, snapshot: PlantSnapshot.current())
    }
}

struct FloritaWidgetEntryView: View {
    var entry: FloritaEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .padding()
            .background(background)
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            smallContent
        case .systemMedium:
            mediumContent
        default:
            smallContent
        }
    }

    private var smallContent: some View {
        VStack(spacing: 12) {
            PlantCanvas(stage: entry.snapshot.stage)
            statusText
            waterButton
        }
    }

    private var mediumContent: some View {
        HStack(spacing: 16) {
            PlantCanvas(stage: entry.snapshot.stage)
                .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 10) {
                statusText
                Text(entry.snapshot.stage.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                waterButton
            }
        }
    }

    private var statusText: some View {
        Text(entry.snapshot.wateredToday ? Localization.string("wateredToday") : Localization.string("notWateredToday"))
            .font(.headline)
            .foregroundStyle(.primary)
    }

    private var waterButton: some View {
        Button(intent: WaterPlantIntent()) {
            Text(Localization.string("waterButton"))
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(buttonBackground)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(entry.snapshot.wateredToday)
    }

    private var buttonBackground: some ShapeStyle {
        LinearGradient(colors: [Color(red: 0.36, green: 0.64, blue: 0.57), Color(red: 0.27, green: 0.53, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.94, green: 0.97, blue: 0.95), Color(red: 0.89, green: 0.94, blue: 0.9)], startPoint: .top, endPoint: .bottom))
    }
}

struct FloritaWidget: Widget {
    let kind: String = FloritaWidgetConstants.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FloritaTimelineProvider()) { entry in
            FloritaWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName(LocalizedStringKey("widget_display_name"))
        .description(LocalizedStringKey("widget_description"))
    }
}

@main
struct FloritaWidgetBundle: WidgetBundle {
    var body: some Widget {
        FloritaWidget()
    }
}

struct WaterPlantIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("waterButton")

    func perform() async throws -> some IntentResult {
        let didWater = await MainActor.run { PlantStore.shared.waterToday() }
        if didWater {
            await MainActor.run {
                WidgetCenter.shared.reloadTimelines(ofKind: FloritaWidgetConstants.kind)
            }
            let now = Date()
            let nextNine = Calendar.current.nextDate(after: now, matching: DateComponents(hour: 9, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents) ?? now.addingTimeInterval(24 * 60 * 60)
            await MainActor.run {
                NotificationService.shared.scheduleCareReminder(at: nextNine)
            }
            return .result(dialog: IntentDialog(Localization.string("wateredToday")))
        } else {
            return .result(dialog: IntentDialog(Localization.string("wateredToday")))
        }
    }
}
