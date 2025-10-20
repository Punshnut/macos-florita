import Foundation

enum PlantStage: String, Codable, CaseIterable {
    case sprout
    case leaves
    case blooms

    static func stage(forDaysOfCare days: Int) -> PlantStage {
        switch days {
        case ..<3:
            return .sprout
        case 3...6:
            return .leaves
        default:
            return .blooms
        }
    }

    var localizedDescription: String {
        switch self {
        case .sprout:
            return Localization.string("stage_sprout")
        case .leaves:
            return Localization.string("stage_leaves")
        case .blooms:
            return Localization.string("stage_blooms")
        }
    }
}

enum Localization {
    static func string(_ key: String) -> String {
        for bundle in bundles {
            let value = NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
            if value != key {
                return value
            }
        }
        return key
    }

    private static var bundles: [Bundle] {
        var all: [Bundle] = [.main]
        if let shared = sharedBundle, shared.bundleURL != Bundle.main.bundleURL {
            all.append(shared)
        }
        return all
    }

    private static let sharedBundle: Bundle? = Bundle(for: BundleToken.self)

    private final class BundleToken: NSObject {}
}
