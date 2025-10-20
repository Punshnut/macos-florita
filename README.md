# Florita – Alpha 0.1 🌿

Hola y welcome to Florita, a playful macOS 14+ SwiftUI experiment that keeps a little desktop plant happy right on your screen. This tiny garden is still sprouting, but every time you tap `Water` it grows taller and brighter—and you can keep the mini Florita window floating nearby for company.

## Why Florita Feels Cozy
- Friendly SwiftUI interface coated in soft pastels and shape-built art (gentle animation optional).
- Simple habit loop: water once per calendar day and Florita climbs from sprout to blooms—no stress, no setbacks.
- Florita Mini provides a compact floating view you can park beside your work.
- Shared `@AppStorage` persistence keeps the main window, mini window, and menu bar popover in sync.
- Optional, soundless reminder around 09:00 nudges you to water your buddy.
- Settings (⌘,) include animation toggle, background style (pastel, plain, transparent), window size (cozy vs. roomy), and menu bar visibility.
- Quick onboarding walkthrough explains watering, reminders, and Florita Mini.
- Unit tests cover growth thresholds and calendar-day comparisons so the plant behaves consistently.

## Getting Started
1. Open `Florita.xcodeproj` in Xcode 15 or newer (macOS 14 SDK).
2. Select the **Florita** scheme and run on “My Mac (macOS 14+)”.
3. Follow or skip the short intro—Florita won’t mind.
4. Use the Window menu or in-app button to open **Florita Mini** and park the plant where you like.
5. Press ⌘, and enable “Show Florita in menu bar” if you want a popover buddy near the status icons.

## Extras & Playgrounds
- Run `swift Scripts/AnimatedPlantDemo.swift` to watch an endless growth animation loop for ambience.

## Roadmap Dreams
This is **Alpha 0.1**, a seedling phase. We’re dreaming about richer animations, plant personalities, and seasonal surprises. If you spot a bug or have a wish, let us know—the garden grows with your ideas.

Gracias por regar Florita y letting a little calm bloom on your desktop. 💚
