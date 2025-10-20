import Foundation

/// Represents the discrete growth milestones Florita can progress through.
enum FloritaGrowthStage: String, Codable, CaseIterable {
    case sprout
    case leaves
    case blooms

    /// Derives the appropriate growth stage for the supplied number of care days.
    /// - Parameter careDayCount: The number of calendar days Florita has been watered.
    /// - Returns: The growth stage corresponding to the care history.
    static func stage(forCareDayCount careDayCount: Int) -> FloritaGrowthStage {
        switch careDayCount {
        case ..<3:
            return .sprout
        case 3...6:
            return .leaves
        default:
            return .blooms
        }
    }

    /// Provides a localized user-facing string describing the current growth stage.
    var localizedStageDescription: String {
        switch self {
        case .sprout:
            return FloritaLocalization.localizedString("stage_sprout")
        case .leaves:
            return FloritaLocalization.localizedString("stage_leaves")
        case .blooms:
            return FloritaLocalization.localizedString("stage_blooms")
        }
    }
}

/// Small helper that searches every accessible bundle for a translated string.
enum FloritaLocalization {
    /// Attempts to resolve a localized string for the given key.
    /// - Parameter key: Localization lookup key.
    /// - Returns: A localized string if available, otherwise the key itself.
    static func localizedString(_ key: String) -> String {
        for bundle in availableBundles {
            let value = NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
            if value != key {
                return value
            }
        }
        return key
    }

    /// Ordered bundles used to resolve localization resources.
    private static var availableBundles: [Bundle] {
        var bundles: [Bundle] = [.main]
        if let sharedFrameworkBundle, sharedFrameworkBundle.bundleURL != Bundle.main.bundleURL {
            bundles.append(sharedFrameworkBundle)
        }
        return bundles
    }

    /// Shared bundle reference used when the module is consumed as a framework.
    private static let sharedFrameworkBundle: Bundle? = Bundle(for: BundleToken.self)

    private final class BundleToken: NSObject {}
}
