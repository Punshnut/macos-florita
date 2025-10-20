import SwiftUI

struct PlantDisplayView: View {
    var stage: PlantStage
    var animated: Bool

    var body: some View {
        Group {
            if animated {
                AnimatedPlantCanvas(stage: stage)
            } else {
                PlantCanvas(stage: stage)
            }
        }
    }
}
