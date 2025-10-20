import SwiftUI

/// Available window sizing presets for the primary Florita scene.
enum WindowSizePreference: String, CaseIterable, Identifiable {
    case small
    case large

    /// Identifiable conformance derived from the raw value.
    var id: String { rawValue }

    /// User-facing label describing the size preset.
    var displayName: String {
        switch self {
        case .small: return "Cozy (Small)"
        case .large: return "Roomy (Large)"
        }
    }

    /// Minimum size that should be applied to the main window.
    var minimumSize: CGSize {
        switch self {
        case .small: return CGSize(width: 380, height: 440)
        case .large: return CGSize(width: 520, height: 600)
        }
    }
}

/// Visual background treatments offered throughout the experience.
enum BackgroundStylePreference: String, CaseIterable, Identifiable {
    case cozyGradient
    case softSunrise
    case eveningTwilight
    case forestCanopy
    case plain
    case transparent

    /// Identifiable conformance derived from the raw value.
    var id: String { rawValue }

    /// Localized copy describing the background style.
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

    /// Indicates whether the style should render a fully transparent backdrop.
    var isTransparent: Bool {
        self == .transparent
    }
}
