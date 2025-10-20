import SwiftUI

/// Shape-driven plant views (static + animated) so future artwork can drop in easily.

struct PlantCanvas: View {
    var stage: PlantStage

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                backgroundLayer
                soilLayer(size: size)
                stemLayer(size: size)
                if stage != .sprout {
                    leavesLayer(size: size)
                }
                if stage == .blooms {
                    bloomLayer(size: size)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(stage.localizedDescription)
    }

    private var backgroundLayer: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.92, green: 0.96, blue: 1.0), Color(red: 0.88, green: 0.94, blue: 0.9)], startPoint: .top, endPoint: .bottom))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    private func soilLayer(size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.58, green: 0.44, blue: 0.32), Color(red: 0.46, green: 0.34, blue: 0.24)], startPoint: .top, endPoint: .bottom))
            .frame(width: size.width * 0.72, height: size.height * 0.22)
            .position(x: size.width / 2, y: size.height * 0.82)
    }

    private func stemLayer(size: CGSize) -> some View {
        StemShape()
            .stroke(style: StrokeStyle(lineWidth: size.width * 0.035, lineCap: .round))
            .foregroundStyle(LinearGradient(colors: [Color(red: 0.38, green: 0.63, blue: 0.35), Color(red: 0.29, green: 0.51, blue: 0.28)], startPoint: .bottom, endPoint: .top))
            .frame(width: size.width * 0.2, height: size.height * 0.55)
            .position(x: size.width / 2, y: size.height * 0.52)
    }

    private func leavesLayer(size: CGSize) -> some View {
        ZStack {
            LeafShape(curve: 1.0)
                .fill(Color(red: 0.48, green: 0.75, blue: 0.44))
                .frame(width: size.width * 0.28, height: size.height * 0.18)
                .position(x: size.width * 0.38, y: size.height * 0.5)
                .rotationEffect(.degrees(-18))
            LeafShape(curve: -1.0)
                .fill(Color(red: 0.37, green: 0.68, blue: 0.38))
                .frame(width: size.width * 0.28, height: size.height * 0.18)
                .position(x: size.width * 0.62, y: size.height * 0.48)
                .rotationEffect(.degrees(18))
        }
        .transition(.scale)
    }

    private func bloomLayer(size: CGSize) -> some View {
        ZStack {
            ForEach(0..<5) { index in
                PetalShape()
                    .fill(Color(red: 0.95, green: 0.72, blue: 0.82))
                    .frame(width: size.width * 0.26, height: size.height * 0.26)
                    .rotationEffect(.degrees(Double(index) * 72))
            }
            Circle()
                .fill(Color(red: 0.99, green: 0.88, blue: 0.62))
                .frame(width: size.width * 0.18, height: size.width * 0.18)
        }
        .position(x: size.width / 2, y: size.height * 0.28)
        .transition(.opacity)
    }
}

struct AnimatedPlantCanvas: View {
    var stage: PlantStage
    @State private var animationStart = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let progress = clampedProgress(for: timeline.date)
            PlantAnimationScene(progress: progress, time: timeline.date.timeIntervalSinceReferenceDate, stage: stage)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(stage.localizedDescription)
        .onAppear { animationStart = Date() }
        .onChange(of: stage) { _, _ in
            animationStart = Date()
        }
    }

    private func clampedProgress(for date: Date) -> CGFloat {
        guard date >= animationStart else { return 0 }
        let elapsed = date.timeIntervalSince(animationStart)
        let duration: TimeInterval = 6
        return CGFloat(min(max(elapsed / duration, 0), 1))
    }
}

private struct PlantAnimationScene: View {
    let progress: CGFloat
    let time: TimeInterval
    let stage: PlantStage

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                backgroundLayer
                soilLayer(size: size)
                stemLayer(size: size)
                if leavesProgress > 0 {
                    leavesLayer(size: size)
                }
                if bloomProgress > 0 {
                    bloomLayer(size: size)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: stage)
        }
    }

    private var stageProgress: CGFloat {
        min(progress, stage.animationCap)
    }

    private var stemProgress: CGFloat {
        min(stageProgress / 0.4, 1)
    }

    private var leavesProgress: CGFloat {
        guard stage != .sprout else { return 0 }
        let value = (stageProgress - 0.4) / 0.3
        return min(max(value, 0), 1)
    }

    private var bloomProgress: CGFloat {
        guard stage == .blooms else { return 0 }
        let value = (stageProgress - 0.75) / 0.25
        return min(max(value, 0), 1)
    }

    private var idleSway: Double {
        guard stageProgress >= stage.animationCap else { return 0 }
        return sin(time / 2.5) * 2.5
    }

    private var backgroundLayer: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.92, green: 0.96, blue: 1.0), Color(red: 0.88, green: 0.94, blue: 0.9)], startPoint: .top, endPoint: .bottom))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    private func soilLayer(size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.58, green: 0.44, blue: 0.32), Color(red: 0.46, green: 0.34, blue: 0.24)], startPoint: .top, endPoint: .bottom))
            .frame(width: size.width * 0.72, height: size.height * 0.22)
            .position(x: size.width / 2, y: size.height * 0.82)
    }

    private func stemLayer(size: CGSize) -> some View {
        StemShape()
            .trim(from: 0, to: stemProgress)
            .stroke(style: StrokeStyle(lineWidth: size.width * 0.035, lineCap: .round))
            .foregroundStyle(LinearGradient(colors: [Color(red: 0.38, green: 0.63, blue: 0.35), Color(red: 0.29, green: 0.51, blue: 0.28)], startPoint: .bottom, endPoint: .top))
            .frame(width: size.width * 0.2, height: size.height * 0.55)
            .position(x: size.width / 2, y: size.height * 0.52)
            .rotationEffect(.degrees(idleSway / 5))
    }

    private func leavesLayer(size: CGSize) -> some View {
        ZStack {
            LeafShape(curve: 1.0)
                .fill(Color(red: 0.48, green: 0.75, blue: 0.44))
                .frame(width: size.width * 0.28, height: size.height * 0.18)
                .position(x: size.width * 0.38, y: size.height * 0.5)
                .rotationEffect(.degrees(-18 + idleSway))
                .scaleEffect(leavesProgress * 0.9 + 0.1, anchor: .trailing)
                .opacity(Double(leavesProgress))
            LeafShape(curve: -1.0)
                .fill(Color(red: 0.37, green: 0.68, blue: 0.38))
                .frame(width: size.width * 0.28, height: size.height * 0.18)
                .position(x: size.width * 0.62, y: size.height * 0.48)
                .rotationEffect(.degrees(18 - idleSway))
                .scaleEffect(leavesProgress * 0.9 + 0.1, anchor: .leading)
                .opacity(Double(leavesProgress))
        }
    }

    private func bloomLayer(size: CGSize) -> some View {
        ZStack {
            ForEach(0..<5) { index in
                PetalShape()
                    .fill(Color(red: 0.95, green: 0.72, blue: 0.82))
                    .frame(width: size.width * 0.26, height: size.height * 0.26)
                    .rotationEffect(.degrees(Double(index) * 72))
                    .scaleEffect(bloomProgress * 0.9 + 0.1, anchor: .center)
                    .opacity(Double(bloomProgress))
            }
            Circle()
                .fill(Color(red: 0.99, green: 0.88, blue: 0.62))
                .frame(width: size.width * 0.18, height: size.width * 0.18)
                .scaleEffect(bloomProgress * 0.9 + 0.1)
                .opacity(Double(bloomProgress))
        }
        .position(x: size.width / 2, y: size.height * 0.28)
        .rotationEffect(.degrees(idleSway))
    }
}

private struct StemShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let midX = rect.midX
            path.move(to: CGPoint(x: midX, y: rect.maxY))
            path.addCurve(to: CGPoint(x: midX, y: rect.minY), control1: CGPoint(x: midX - rect.width * 0.7, y: rect.midY), control2: CGPoint(x: midX + rect.width * 0.7, y: rect.midY))
        }
    }
}

private struct LeafShape: Shape {
    var curve: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.midX * (1 + curve * 0.4), y: rect.midY * 0.4))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX * (1 + curve * 0.4), y: rect.midY * 1.6))
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX * (1 - curve * 0.4), y: rect.midY * 1.6))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), control: CGPoint(x: rect.midX * (1 - curve * 0.4), y: rect.midY * 0.4))
            path.closeSubpath()
        }
    }
}

private struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        return Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX + width * 0.45, y: rect.midY * 0.4))
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX + width * 0.45, y: rect.midY * 1.6))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), control: CGPoint(x: rect.midX - width * 0.45, y: rect.midY * 1.6))
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.midX - width * 0.45, y: rect.midY * 0.4))
            path.closeSubpath()
        }
    }
}

#if DEBUG
struct AnimatedPlantCanvas_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedPlantCanvas(stage: .blooms)
            .frame(width: 240, height: 240)
            .padding()
    }
}
#endif

private extension PlantStage {
    var animationCap: CGFloat {
        switch self {
        case .sprout:
            return 0.4
        case .leaves:
            return 0.75
        case .blooms:
            return 1.0
        }
    }
}

#if DEBUG
struct PlantCanvas_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlantCanvas(stage: .sprout)
            PlantCanvas(stage: .leaves)
            PlantCanvas(stage: .blooms)
        }
        .padding()
        .previewLayout(.fixed(width: 240, height: 240))
    }
}
#endif
