import SwiftUI

/// Wrapper view that chooses between animated and static plant artwork.
struct FloritaPlantDisplay: View {
    /// Growth stage to render.
    var growthStage: FloritaGrowthStage
    /// Flag determining whether the animated illustration should be used.
    var isAnimated: Bool
    /// Phase value that drives tap-triggered shake animations.
    @State private var tapShakePhase: CGFloat = 0

    var body: some View {
        plantContent
            .modifier(PlantShakeEffect(phase: tapShakePhase))
            .contentShape(Rectangle())
            .onTapGesture(perform: triggerShake)
    }

    /// Resolves the appropriate plant canvas based on animation capability.
    @ViewBuilder
    private var plantContent: some View {
        if isAnimated {
            AnimatedGrowthCanvas(growthStage: growthStage,
                                 tapShakePhase: tapShakePhase)
        } else {
            StaticGrowthCanvas(growthStage: growthStage,
                               tapShakePhase: tapShakePhase)
        }
    }

    /// Resets the shake phase and animates it downward to create a natural wiggle.
    private func triggerShake() {
        tapShakePhase = 1
        withAnimation(.easeOut(duration: 0.9)) {
            tapShakePhase = 0
        }
    }
}

/// Geometry effect that adds a subtle reactive shake translating and rotating the plant.
private struct PlantShakeEffect: GeometryEffect {
    /// Phase value animating from 1 back to 0 to describe the shake envelope.
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let normalized = Double(min(max(phase, 0), 1))
        guard normalized > 0 else { return ProjectionTransform(.identity) }
        let progress = 1 - normalized
        let horizontal = sin(progress * .pi * 4.5) * normalized * 10
        let vertical = sin(progress * .pi * 3.6) * normalized * 6
        let rotation = sin(progress * .pi * 4.0) * normalized * (.pi / 32)

        var transform = CGAffineTransform(translationX: horizontal, y: vertical)
        transform = transform.rotated(by: CGFloat(rotation))
        return ProjectionTransform(transform)
    }
}
