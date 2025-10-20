# Florita - Alpha 0.1 🌿

Hola y welcome to the very first bloom of Florita, a cozy macOS 14+ SwiftUI app that brings a tiny desktop garden to life. This alpha build focuses on warmth, simple care rituals, and a little bit of everyday calma while we prepare the soil for future features.

## What’s Growing Right Now
- SwiftUI-powered macOS app with a gentle pastel design and a shape-based plant (animated or static - your choice).
- Daily watering ritual: tap the in-app button or the widget once per day to keep growth steady - never any penalties.
- WidgetKit extension (small & medium) featuring the same plant and an interactive `Water` AppIntent button.
- Shared `@AppStorage` persistence via the Florita app group so the app and widget stay in sync.
- Optional, soundless notification nudging you around 09:00 to water Florita.
- Settings window with controls for animation toggle, window size (cozy vs. roomy), and background style (pastel, plain, transparent).
- First-run onboarding walkthrough covering watering, widget setup, and where to customize the experience.
- Unit tests validating growth thresholds and calendar-day comparisons.

## Getting Started
1. Open `Florita/Florita.xcodeproj` in Xcode 15 or newer (macOS 14 SDK).
2. Select the **Florita** scheme and run on “My Mac (macOS 14+)”.
3. On first launch, follow or skip the intro to learn the basics.
4. Build **FloritaWidget** once, then add the widget from the macOS widget gallery.

## Scripts & Extras
- Watch a perpetual growth loop with `swift Scripts/AnimatedPlantDemo.swift`.

## Status & Hopes
This is **Alpha 0.1**-an early planting. Expect rough edges and plenty of room for future features like richer animations, deeper customization, and delightful seasonal events. Your feedback is la luz that helps Florita grow.

Con un pequeño abrazo digital, gracias for tending to Florita.
