import SwiftUI
import Combine

@MainActor
final class PlantStore: ObservableObject {
    static let shared = PlantStore()
    static let appGroupIdentifier = "group.com.example.florita"

    enum StorageKey {
        static let lastWateredTimestamp = "lastWateredTimestamp"
        static let daysOfCare = "daysOfCare"
        static let stage = "stage"
        static let prefersAnimatedGraphics = "prefersAnimatedGraphics"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let windowSizePreference = "windowSizePreference"
        static let backgroundStylePreference = "backgroundStylePreference"
    }

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    private let defaults: UserDefaults
    private var lastWateredTimestampStorage: AppStorage<Double>
    private var daysOfCareStorage: AppStorage<Int>
    private var stageStorage: AppStorage<String>
    private var animatedGraphicsStorage: AppStorage<Bool>
    private var onboardingStorage: AppStorage<Bool>
    private var windowSizeStorage: AppStorage<String>
    private var backgroundStyleStorage: AppStorage<String>
    private let calendar: Calendar

    init(defaults: UserDefaults = PlantStore.sharedDefaults, calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.defaults = defaults
        self.calendar = calendar
        lastWateredTimestampStorage = AppStorage(wrappedValue: 0, StorageKey.lastWateredTimestamp, store: defaults)
        daysOfCareStorage = AppStorage(wrappedValue: 0, StorageKey.daysOfCare, store: defaults)
        stageStorage = AppStorage(wrappedValue: PlantStage.sprout.rawValue, StorageKey.stage, store: defaults)
        animatedGraphicsStorage = AppStorage(wrappedValue: true, StorageKey.prefersAnimatedGraphics, store: defaults)
        onboardingStorage = AppStorage(wrappedValue: false, StorageKey.hasCompletedOnboarding, store: defaults)
        windowSizeStorage = AppStorage(wrappedValue: WindowSizePreference.large.rawValue, StorageKey.windowSizePreference, store: defaults)
        backgroundStyleStorage = AppStorage(wrappedValue: BackgroundStylePreference.cozyGradient.rawValue, StorageKey.backgroundStylePreference, store: defaults)
        recomputeStage()
    }

    var lastWateredDate: Date? {
        get {
            let timestamp = lastWateredTimestampStorage.wrappedValue
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set {
            let newTimestamp = newValue?.timeIntervalSince1970 ?? 0
            if newTimestamp != lastWateredTimestampStorage.wrappedValue {
                objectWillChange.send()
                lastWateredTimestampStorage.wrappedValue = newTimestamp
            }
        }
    }

    var daysOfCare: Int {
        get { daysOfCareStorage.wrappedValue }
        set {
            if newValue != daysOfCareStorage.wrappedValue {
                objectWillChange.send()
                daysOfCareStorage.wrappedValue = newValue
                recomputeStage()
            }
        }
    }

    var stage: PlantStage {
        get { PlantStage(rawValue: stageStorage.wrappedValue) ?? .sprout }
        set {
            if newValue.rawValue != stageStorage.wrappedValue {
                objectWillChange.send()
                stageStorage.wrappedValue = newValue.rawValue
            }
        }
    }

    var prefersAnimatedGraphics: Bool {
        get { animatedGraphicsStorage.wrappedValue }
        set {
            guard newValue != animatedGraphicsStorage.wrappedValue else { return }
            objectWillChange.send()
            animatedGraphicsStorage.wrappedValue = newValue
        }
    }

    var hasCompletedOnboarding: Bool {
        get { onboardingStorage.wrappedValue }
        set {
            guard newValue != onboardingStorage.wrappedValue else { return }
            objectWillChange.send()
            onboardingStorage.wrappedValue = newValue
        }
    }

    var windowSize: WindowSizePreference {
        get { WindowSizePreference(rawValue: windowSizeStorage.wrappedValue) ?? .large }
        set {
            guard newValue.rawValue != windowSizeStorage.wrappedValue else { return }
            objectWillChange.send()
            windowSizeStorage.wrappedValue = newValue.rawValue
        }
    }

    var backgroundStyle: BackgroundStylePreference {
        get { BackgroundStylePreference(rawValue: backgroundStyleStorage.wrappedValue) ?? .cozyGradient }
        set {
            guard newValue.rawValue != backgroundStyleStorage.wrappedValue else { return }
            objectWillChange.send()
            backgroundStyleStorage.wrappedValue = newValue.rawValue
        }
    }

    var hasWateredToday: Bool {
        guard let lastWateredDate else { return false }
        return PlantStore.isSameCalendarDay(lastWateredDate, Date(), calendar: calendar)
    }

    @discardableResult
    func waterToday(now: Date = Date()) -> Bool {
        if let last = lastWateredDate, PlantStore.isSameCalendarDay(last, now, calendar: calendar) {
            return false
        }
        lastWateredDate = now
        daysOfCare += 1
        return true
    }

    func recomputeStage() {
        stage = PlantStage.stage(forDaysOfCare: daysOfCare)
    }

    static func isSameCalendarDay(_ lhs: Date, _ rhs: Date, calendar: Calendar = Calendar(identifier: .gregorian)) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    func resetForPreviews() {
        lastWateredDate = nil
        daysOfCare = 0
        stage = .sprout
        prefersAnimatedGraphics = true
        hasCompletedOnboarding = false
        windowSize = .large
        backgroundStyle = .cozyGradient
    }

    func markOnboardingComplete() {
        hasCompletedOnboarding = true
    }
}

struct PlantSnapshot {
    let lastWateredDate: Date?
    let daysOfCare: Int
    let stage: PlantStage
    let prefersAnimatedGraphics: Bool
    let windowSize: WindowSizePreference
    let backgroundStyle: BackgroundStylePreference

    var wateredToday: Bool {
        guard let lastWateredDate else { return false }
        return PlantStore.isSameCalendarDay(lastWateredDate, Date())
    }

    static func current(defaults: UserDefaults = PlantStore.sharedDefaults) -> PlantSnapshot {
        let timestamp = defaults.double(forKey: PlantStore.StorageKey.lastWateredTimestamp)
        let lastWatered = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        let days = defaults.integer(forKey: PlantStore.StorageKey.daysOfCare)
        let stageRaw = defaults.string(forKey: PlantStore.StorageKey.stage) ?? PlantStage.sprout.rawValue
        let stage = PlantStage(rawValue: stageRaw) ?? PlantStage.stage(forDaysOfCare: days)
        let prefersAnimation = defaults.object(forKey: PlantStore.StorageKey.prefersAnimatedGraphics) as? Bool ?? true
        let windowRaw = defaults.string(forKey: PlantStore.StorageKey.windowSizePreference) ?? WindowSizePreference.large.rawValue
        let backgroundRaw = defaults.string(forKey: PlantStore.StorageKey.backgroundStylePreference) ?? BackgroundStylePreference.cozyGradient.rawValue
        let window = WindowSizePreference(rawValue: windowRaw) ?? .large
        let background = BackgroundStylePreference(rawValue: backgroundRaw) ?? .cozyGradient
        return PlantSnapshot(lastWateredDate: lastWatered, daysOfCare: days, stage: stage, prefersAnimatedGraphics: prefersAnimation, windowSize: window, backgroundStyle: background)
    }
}
