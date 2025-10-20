import SwiftUI

/// Wrapper view that chooses between animated and static plant artwork.
struct FloritaPlantDisplay: View {
    /// Growth stage to render.
    var growthStage: FloritaGrowthStage
    /// Flag determining whether the animated illustration should be used.
    var isAnimated: Bool

    var body: some View {
        Group {
            if isAnimated {
                AnimatedGrowthCanvas(growthStage: growthStage)
            } else {
                StaticGrowthCanvas(growthStage: growthStage)
            }
        }
    }
}
