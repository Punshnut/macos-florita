import SwiftUI
import Combine

/// Central store that persists Florita's growth journey, user preferences, and convenience helpers.
@MainActor
final class FloritaGrowthStore: ObservableObject {
    /// Shared instance leveraged by the app entry points.
    static let sharedStore = FloritaGrowthStore()

    /// Keys used when persisting values with `AppStorage`.
    enum PreferenceKey {
        static let lastWateredTimestamp = "lastWateredTimestamp"
        static let careDayCount = "daysOfCare"
        static let growthStage = "stage"
        static let prefersAnimatedGraphics = "prefersAnimatedGraphics"
        static let completedOnboarding = "hasCompletedOnboarding"
        static let windowSizePreference = "windowSizePreference"
        static let backgroundStylePreference = "backgroundStylePreference"
        static let menuBarVisibility = "menuBarEnabled"
        static let miniWindowTransparency = "miniWindowTransparency"
    }

    private var lastWateredTimestampPreference: AppStorage<Double>
    private var careDayCountPreference: AppStorage<Int>
    private var growthStagePreference: AppStorage<String>
    private var animationPreference: AppStorage<Bool>
    private var onboardingCompletionPreference: AppStorage<Bool>
    private var windowSizePreference: AppStorage<String>
    private var backgroundStylePreference: AppStorage<String>
    private var menuBarVisibilityPreference: AppStorage<Bool>
    private var miniWindowTransparencyPreference: AppStorage<Bool>
    private let calendarProvider: Calendar

    /// Creates a store backed by the supplied defaults and calendar implementation.
    init(userDefaults: UserDefaults = .standard,
         calendar: Calendar = Calendar(identifier: .gregorian)) {
        calendarProvider = calendar
        lastWateredTimestampPreference = AppStorage(wrappedValue: 0, PreferenceKey.lastWateredTimestamp, store: userDefaults)
        careDayCountPreference = AppStorage(wrappedValue: 0, PreferenceKey.careDayCount, store: userDefaults)
        growthStagePreference = AppStorage(wrappedValue: FloritaGrowthStage.sprout.rawValue, PreferenceKey.growthStage, store: userDefaults)
        animationPreference = AppStorage(wrappedValue: true, PreferenceKey.prefersAnimatedGraphics, store: userDefaults)
        onboardingCompletionPreference = AppStorage(wrappedValue: false, PreferenceKey.completedOnboarding, store: userDefaults)
        windowSizePreference = AppStorage(wrappedValue: WindowSizePreference.large.rawValue, PreferenceKey.windowSizePreference, store: userDefaults)
        backgroundStylePreference = AppStorage(wrappedValue: BackgroundStylePreference.cozyGradient.rawValue, PreferenceKey.backgroundStylePreference, store: userDefaults)
        menuBarVisibilityPreference = AppStorage(wrappedValue: false, PreferenceKey.menuBarVisibility, store: userDefaults)
        miniWindowTransparencyPreference = AppStorage(wrappedValue: false, PreferenceKey.miniWindowTransparency, store: userDefaults)
        refreshGrowthStage()
    }

    /// Date Florita was most recently watered. `nil` represents no recorded watering.
    var mostRecentWateringDate: Date? {
        get {
            let timestamp = lastWateredTimestampPreference.wrappedValue
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set {
            let newTimestamp = newValue?.timeIntervalSince1970 ?? 0
            guard newTimestamp != lastWateredTimestampPreference.wrappedValue else { return }
            objectWillChange.send()
            lastWateredTimestampPreference.wrappedValue = newTimestamp
        }
    }

    /// Running total of days Florita has been cared for.
    var totalCareDayCount: Int {
        get { careDayCountPreference.wrappedValue }
        set {
            guard newValue != careDayCountPreference.wrappedValue else { return }
            objectWillChange.send()
            careDayCountPreference.wrappedValue = newValue
            refreshGrowthStage()
        }
    }

    /// Current growth stage derived from the care history.
    var currentGrowthStage: FloritaGrowthStage {
        get { FloritaGrowthStage(rawValue: growthStagePreference.wrappedValue) ?? .sprout }
        set {
            guard newValue.rawValue != growthStagePreference.wrappedValue else { return }
            objectWillChange.send()
            growthStagePreference.wrappedValue = newValue.rawValue
        }
    }

    /// Indicates whether animated artwork should be used.
    var isAnimationEnabled: Bool {
        get { animationPreference.wrappedValue }
        set {
            guard newValue != animationPreference.wrappedValue else { return }
            objectWillChange.send()
            animationPreference.wrappedValue = newValue
        }
    }

    /// Tracks whether onboarding flow has been completed.
    var didCompleteOnboarding: Bool {
        get { onboardingCompletionPreference.wrappedValue }
        set {
            guard newValue != onboardingCompletionPreference.wrappedValue else { return }
            objectWillChange.send()
            onboardingCompletionPreference.wrappedValue = newValue
        }
    }

    /// Persisted window size preference used for the primary scene.
    var preferredWindowSize: WindowSizePreference {
        get { WindowSizePreference(rawValue: windowSizePreference.wrappedValue) ?? .large }
        set {
            guard newValue.rawValue != windowSizePreference.wrappedValue else { return }
            objectWillChange.send()
            windowSizePreference.wrappedValue = newValue.rawValue
        }
    }

    /// Selected background style for the primary window.
    var preferredBackgroundStyle: BackgroundStylePreference {
        get { BackgroundStylePreference(rawValue: backgroundStylePreference.wrappedValue) ?? .cozyGradient }
        set {
            guard newValue.rawValue != backgroundStylePreference.wrappedValue else { return }
            objectWillChange.send()
            backgroundStylePreference.wrappedValue = newValue.rawValue
        }
    }

    /// Toggles the presence of Florita's menu bar extra.
    var isMenuBarItemVisible: Bool {
        get { menuBarVisibilityPreference.wrappedValue }
        set {
            guard newValue != menuBarVisibilityPreference.wrappedValue else { return }
            objectWillChange.send()
            menuBarVisibilityPreference.wrappedValue = newValue
        }
    }

    /// Determines whether the mini window prefers complete transparency.
    var isMiniWindowFullyTransparent: Bool {
        get { miniWindowTransparencyPreference.wrappedValue }
        set {
            guard newValue != miniWindowTransparencyPreference.wrappedValue else { return }
            objectWillChange.send()
            miniWindowTransparencyPreference.wrappedValue = newValue
        }
    }

    /// Convenience flag that reports whether Florita has already been watered today.
    var didWaterToday: Bool {
        guard let mostRecentWateringDate else { return false }
        return FloritaGrowthStore.occursOnSameCalendarDay(mostRecentWateringDate, Date(), calendar: calendarProvider)
    }

    /// Registers a watering event for the current calendar day.
    /// - Parameter now: Optional override for the time of watering.
    /// - Returns: `true` if the watering was recorded, `false` if this day's watering already exists.
    @discardableResult
    func registerDailyWatering(now: Date = Date()) -> Bool {
        if let lastWateringDate = mostRecentWateringDate,
           FloritaGrowthStore.occursOnSameCalendarDay(lastWateringDate, now, calendar: calendarProvider) {
            return false
        }
        mostRecentWateringDate = now
        totalCareDayCount += 1
        return true
    }

    /// Wipes watering history and growth progress.
    func resetGrowthHistory() {
        mostRecentWateringDate = nil
        totalCareDayCount = 0
    }

    /// Helper for previews and debug tooling to fast-forward Florita's growth.
    /// - Parameter steps: Number of care days to add.
    func simulateGrowthForDebugging(by steps: Int = 1) {
        guard steps > 0 else { return }
        totalCareDayCount += steps
    }

    /// Aligns the growth stage to the current total care day count.
    func refreshGrowthStage() {
        currentGrowthStage = FloritaGrowthStage.stage(forCareDayCount: totalCareDayCount)
    }

    /// Determines whether two dates fall on the same calendar day within the supplied calendar.
    /// - Parameters:
    ///   - lhs: First date value.
    ///   - rhs: Second date value.
    ///   - calendar: Calendar to evaluate with.
    /// - Returns: `true` when both dates occur on the same calendar day.
    static func occursOnSameCalendarDay(_ lhs: Date,
                                        _ rhs: Date,
                                        calendar: Calendar = Calendar(identifier: .gregorian)) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    /// Restores baseline values useful for previews during development.
    func restorePreviewDefaults() {
        mostRecentWateringDate = nil
        totalCareDayCount = 0
        currentGrowthStage = .sprout
        isAnimationEnabled = true
        didCompleteOnboarding = false
        preferredWindowSize = .large
        preferredBackgroundStyle = .cozyGradient
        isMenuBarItemVisible = false
        isMiniWindowFullyTransparent = false
    }

    /// Marks onboarding as completed to avoid re-presenting the flow.
    func recordOnboardingCompletion() {
        didCompleteOnboarding = true
    }
}
