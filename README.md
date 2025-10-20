# Florita - Alpha 0.1 🌿

Hola y welcome to Florita, a playful macOS 14+ SwiftUI experiment that keeps a little desktop plant happy right on your screen. This tiny garden is still sprouting, but every day you tap “Water” it grows a little taller and a little brighter—and you can keep the mini Florita window floating nearby for company.

## Why Florita Feels Cozy
- Friendly SwiftUI interface coated in soft pastels and hand-drawn shapes (with optional gentle animations).
- Simple habit loop: water once per calendar day and Florita keeps climbing through sprout, leafy, and blooming stages—no stress, no setbacks.
- “Florita Mini” window mirrors the plant in a compact frame so you can leave it floating beside your work.
- Shared persistence powered by `@AppStorage`, keeping the main window and mini view perfectly in sync.
- Optional morning reminder (no sound) around 09:00 nudging you to water your buddy.
- Settings panel (⌘,) to choose animation style, background (pastel, plain, transparent), window size (cozy vs. roomy), and whether Florita lives in your menu bar.
- A brief onboarding tour that explains watering, reminders, and the mini window.
- Unit tests covering stage thresholds and calendar-day checks to keep the growth logic honest.

## Getting Started
1. Open `Florita.xcodeproj` in Xcode 15 or newer (macOS 14 SDK).
2. Select the **Florita** scheme and run on “My Mac (macOS 14+)”.
3. Follow or skip the quick intro—Florita won’t mind.
4. Use the Window menu (or the in-app button) to open **Florita Mini** and park the plant wherever you like.
5. Press ⌘, to open Settings anytime—flip on “Show Florita in menu bar” if you want a popover buddy near the status icons.

## Extras & Playgrounds
- Run `swift Scripts/AnimatedPlantDemo.swift` to watch an endless growth animation loop—perfect for ambience.

## Roadmap Dreams
This is **Alpha 0.1**, a seedling phase. We’re dreaming about richer animations, more plant personalities, and seasonal surprises. If you spot a bug or have a wish, let us know—the garden grows with your ideas.

Gracias por regar Florita y letting a little calm bloom on your desktop. 💚
