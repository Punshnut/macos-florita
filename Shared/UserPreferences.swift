import SwiftUI

enum WindowSizePreference: String, CaseIterable, Identifiable {
    case small
    case large

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .small: return "Cozy (Small)"
        case .large: return "Roomy (Large)"
        }
    }

    var minimumSize: CGSize {
        switch self {
        case .small: return CGSize(width: 380, height: 440)
        case .large: return CGSize(width: 520, height: 600)
        }
    }
}

enum BackgroundStylePreference: String, CaseIterable, Identifiable {
    case cozyGradient
    case softSunrise
    case eveningTwilight
    case forestCanopy
    case plain
    case transparent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cozyGradient: return "Pastel Canvas"
        case .softSunrise: return "Soft Sunrise"
        case .eveningTwilight: return "Evening Twilight"
        case .forestCanopy: return "Forest Canopy"
        case .plain: return "Plain"
        case .transparent: return "Transparent"
        }
    }

    var isTransparent: Bool {
        self == .transparent
    }
}
