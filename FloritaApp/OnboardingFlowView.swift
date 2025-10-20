import SwiftUI

/// Guided introduction that welcomes new caretakers and explains the basics.
struct OnboardingFlowView: View {
    /// Binding controlling whether the sheet is currently visible.
    @Binding var isPresented: Bool
    /// Shared growth store used to mark onboarding completion.
    @ObservedObject var growthStore: FloritaGrowthStore
    /// Tracks which onboarding page is currently displayed.
    @State private var currentStepIndex = 0

    /// Ordered onboarding steps presented inside the tab view.
    private let steps: [OnboardingStep] = [
        OnboardingStep(title: "Welcome to Florita", subtitle: "Nurture a calm little garden on your desktop. Water once a day to help Florita glow."),
        OnboardingStep(title: "Watering", subtitle: "Press \"Water\" in the main window or in Florita Mini once per calendar day. Florita keeps growing - no penalties, ever."),
        OnboardingStep(title: "Florita Mini", subtitle: "Open the \"Florita Mini\" window from the Window menu or in-app button to keep a tiny companion floating nearby. Prefer the menu bar? Flip it on in Settings (⌘,).")
    ]

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("Skip") {
                    completeOnboarding()
                }
                .buttonStyle(.link)
                .opacity(currentStepIndex < steps.count - 1 ? 1 : 0)

                Spacer()

                Text("Step \(currentStepIndex + 1) of \(steps.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TabView(selection: $currentStepIndex) {
                ForEach(Array(steps.enumerated()), id: \.offset) { offset, step in
                    VStack(spacing: 18) {
                        Text(step.title)
                            .font(.title2.weight(.semibold))
                        Text(step.subtitle)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .tag(offset)
                }
            }
            #if os(macOS)
                .tabViewStyle(DefaultTabViewStyle())
            #else
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            #endif

            ProgressView(value: Double(currentStepIndex + 1), total: Double(steps.count))
                .progressViewStyle(.linear)
                .frame(maxWidth: .infinity)

            Button(currentStepIndex == steps.count - 1 ? "Get Started" : "Next") {
                if currentStepIndex == steps.count - 1 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentStepIndex += 1
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 320)
    }

    /// Marks onboarding as complete and dismisses the sheet.
    private func completeOnboarding() {
        growthStore.recordOnboardingCompletion()
        isPresented = false
    }
}

/// Simple value object describing a single onboarding step.
private struct OnboardingStep {
    let title: String
    let subtitle: String
}
