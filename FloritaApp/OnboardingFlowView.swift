import SwiftUI

struct OnboardingFlowView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store: PlantStore
    @State private var index = 0

    private let steps: [OnboardingStep] = [
        OnboardingStep(title: "Welcome to Florita", subtitle: "Nurture a calm little garden on your desktop. Water once a day to help Florita glow."),
        OnboardingStep(title: "Watering", subtitle: "Press \"Water\" in the app or tap the widget button once per calendar day. Florita keeps growing - no penalties, ever."),
        OnboardingStep(title: "Add the Widget", subtitle: "Build the widget target once, then add Florita from the macOS widget gallery. Customize window size, background, and animation later in Settings.")
    ]

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("Skip") {
                    completeOnboarding()
                }
                .buttonStyle(.link)
                .opacity(index < steps.count - 1 ? 1 : 0)

                Spacer()

                Text("Step \(index + 1) of \(steps.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TabView(selection: $index) {
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

            HStack {
                ProgressView(value: Double(index + 1), total: Double(steps.count))
                    .progressViewStyle(.linear)
                    .frame(maxWidth: .infinity)
            }

            Button(index == steps.count - 1 ? "Get Started" : "Next") {
                if index == steps.count - 1 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        index += 1
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 320)
    }

    private func completeOnboarding() {
        store.markOnboardingComplete()
        isPresented = false
    }
}

private struct OnboardingStep {
    let title: String
    let subtitle: String
}
