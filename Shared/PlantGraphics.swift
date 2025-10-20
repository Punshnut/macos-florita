import SwiftUI

/// Shape-driven plant views (static + animated) ready to swap with custom artwork later on.

struct PlantCanvas: View {
    var stage: PlantStage

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let layers = PlantSceneLayers(stage: stage)
            ZStack {
                layers.backgroundBase()
                layers.lightRaysLayer(size: size, time: nil)
                layers.skyLayer(size: size, time: nil)
                layers.soilShadow(size: size)
                layers.soilLayer(size: size)
                layers.stemLayer(size: size, sway: 0, growth: 1)
                if stage != .sprout {
                    layers.leavesLayer(size: size, growth: 1, sway: 0)
                }
                if stage == .blooms {
                    layers.bloomLayer(size: size, growth: 1, sway: 0, time: nil)
                }
                layers.foregroundPebbles(size: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(stage.localizedDescription)
    }
}

struct AnimatedPlantCanvas: View {
    var stage: PlantStage
    @State private var animationStart = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            PlantAnimationScene(date: timeline.date, stage: stage, animationStart: animationStart)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(stage.localizedDescription)
        .onAppear { animationStart = Date() }
        .onChange(of: stage) { _, _ in animationStart = Date() }
    }
}

private struct PlantAnimationScene: View {
    let date: Date
    let stage: PlantStage
    let animationStart: Date

    private var elapsed: TimeInterval { max(date.timeIntervalSince(animationStart), 0) }
    private var progress: CGFloat {
        let duration: TimeInterval = 5.5
        return CGFloat((elapsed / duration).clamped(to: 0...1))
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let layers = PlantSceneLayers(stage: stage)
            let stageProgress = min(progress, stage.animationCap)
            let stemGrowth = ease((stageProgress / 0.4).clamped())
            let leavesGrowth = stage != .sprout ? ease(((stageProgress - 0.4) / 0.3).clamped()) : 0
            let bloomGrowth = stage == .blooms ? ease(((stageProgress - 0.75) / 0.25).clamped()) : 0
            let sway: Double = stageProgress >= stage.animationCap ? sin(elapsed / 3.0) * 2.2 : 0

            ZStack {
                layers.backgroundBase()
                layers.lightRaysLayer(size: size, time: elapsed)
                layers.skyLayer(size: size, time: elapsed)
                layers.soilShadow(size: size)
                layers.soilLayer(size: size)
                layers.stemLayer(size: size, sway: sway, growth: stemGrowth)
                if leavesGrowth > 0 {
                    layers.leavesLayer(size: size, growth: leavesGrowth, sway: sway)
                }
                if bloomGrowth > 0 {
                    layers.bloomLayer(size: size, growth: bloomGrowth, sway: sway, time: elapsed)
                }
                layers.foregroundPebbles(size: size)
            }
            .animation(.easeInOut(duration: 0.6), value: stage)
        }
    }
}

private struct PlantSceneLayers {
    var stage: PlantStage

    func backgroundBase() -> some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(colors: [Color(red: 0.86, green: 0.95, blue: 0.99),
                                        Color(red: 0.9, green: 0.98, blue: 0.95)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    func lightRaysLayer(size: CGSize, time: TimeInterval?) -> some View {
        let animatedAngle = Angle.degrees((time ?? 0) * 6)
        return ZStack {
            ForEach(0..<8) { index in
                let baseRotation = Angle.degrees(Double(index) * 9 - 32)
                let pulsation = 0.08 + 0.05 * sin((time ?? 0) / 1.8 + Double(index) * 0.9)
                RoundedRectangle(cornerRadius: size.height * 0.4, style: .continuous)
                    .fill(
                        LinearGradient(colors: [Color.white.opacity(0.28), Color.white.opacity(0)],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .frame(width: size.width * 1.35, height: size.height * 0.16)
                    .position(x: size.width / 2, y: size.height * 0.24)
                    .rotationEffect(baseRotation + animatedAngle)
                    .opacity(pulsation)
                    .blendMode(.plusLighter)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    func skyLayer(size: CGSize, time: TimeInterval?) -> some View {
        let drift = CGFloat(sin((time ?? 0) / 5.0)) * 16
        let glowPulse = 0.15 + 0.1 * sin((time ?? 0) / 4.0)
        return ZStack {
            RadialGradient(colors: [Color(red: 1.0, green: 0.98, blue: 0.88).opacity(0.9 + glowPulse), Color.clear],
                           center: UnitPoint(x: 0.25, y: 0.2),
                           startRadius: 12,
                           endRadius: size.width * 0.65)
                .blendMode(.plusLighter)
            cloud(at: CGPoint(x: size.width * 0.25 + drift, y: size.height * 0.18), scale: 0.9)
            cloud(at: CGPoint(x: size.width * 0.68 + drift * 0.6, y: size.height * 0.16), scale: 1.15)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    func soilShadow(size: CGSize) -> some View {
        Ellipse()
            .fill(Color.black.opacity(0.08))
            .frame(width: size.width * 0.6, height: size.height * 0.15)
            .position(x: size.width / 2, y: size.height * 0.84)
    }

    func soilLayer(size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.62, green: 0.46, blue: 0.34), Color(red: 0.43, green: 0.32, blue: 0.24)], startPoint: .top, endPoint: .bottom))
            .overlay {
                LinearGradient(colors: [Color.white.opacity(0.18), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .frame(width: size.width * 0.72, height: size.height * 0.22)
            .position(x: size.width / 2, y: size.height * 0.82)
    }

    func stemLayer(size: CGSize, sway: Double, growth: CGFloat) -> some View {
        StemShape()
            .trim(from: 0, to: growth)
            .stroke(style: StrokeStyle(lineWidth: size.width * 0.035, lineCap: .round))
            .foregroundStyle(LinearGradient(colors: [Color(red: 0.38, green: 0.63, blue: 0.35), Color(red: 0.29, green: 0.51, blue: 0.28)], startPoint: .bottom, endPoint: .top))
            .frame(width: size.width * 0.2, height: size.height * 0.55)
            .position(x: size.width / 2, y: size.height * 0.52)
            .rotationEffect(.degrees(sway * 0.18))
    }

    func leavesLayer(size: CGSize, growth: CGFloat, sway: Double) -> some View {
        ZStack {
            LeafShape(curve: 1.0)
                .fill(leafGradient(primary: true))
                .frame(width: size.width * 0.28, height: size.height * 0.18)
                .position(x: size.width * 0.38, y: size.height * 0.5)
                .rotationEffect(.degrees(-18 + sway * 0.45))
                .scaleEffect(growth * 0.9 + 0.1, anchor: .trailing)
                .opacity(Double(growth))
            LeafShape(curve: -1.0)
                .fill(leafGradient(primary: false))
                .frame(width: size.width * 0.28, height: size.height * 0.18)
                .position(x: size.width * 0.62, y: size.height * 0.48)
                .rotationEffect(.degrees(18 - sway * 0.45))
                .scaleEffect(growth * 0.9 + 0.1, anchor: .leading)
                .opacity(Double(growth))
        }
    }

    func bloomLayer(size: CGSize, growth: CGFloat, sway: Double, time: TimeInterval?) -> some View {
        let phase = sin((time ?? 0) / 2.5) * 4
        return ZStack {
            ForEach(0..<5) { index in
                PetalShape()
                    .fill(petalGradient(index: index))
                    .frame(width: size.width * 0.26, height: size.height * 0.26)
                    .rotationEffect(.degrees(Double(index) * 72 + phase))
                    .scaleEffect(growth * 0.9 + 0.1, anchor: .center)
                    .opacity(Double(growth))
            }
            Circle()
                .fill(Color(red: 0.99, green: 0.88, blue: 0.62))
                .frame(width: size.width * 0.18, height: size.width * 0.18)
                .scaleEffect(growth * 0.9 + 0.1)
                .shadow(color: Color(red: 0.99, green: 0.88, blue: 0.62).opacity(0.35), radius: 8, x: 0, y: 0)
        }
        .position(x: size.width / 2, y: size.height * 0.28)
        .rotationEffect(.degrees(sway))
    }

    func foregroundPebbles(size: CGSize) -> some View {
        let pebble = Capsule(style: .continuous)
        return ZStack {
            pebble.fill(Color(red: 0.72, green: 0.62, blue: 0.5).opacity(0.6))
                .frame(width: 22, height: 10)
                .position(x: size.width * 0.38, y: size.height * 0.88)
            pebble.fill(Color(red: 0.58, green: 0.5, blue: 0.42).opacity(0.7))
                .frame(width: 18, height: 9)
                .position(x: size.width * 0.62, y: size.height * 0.86)
            pebble.fill(Color(red: 0.66, green: 0.54, blue: 0.42).opacity(0.5))
                .frame(width: 14, height: 8)
                .position(x: size.width * 0.5, y: size.height * 0.9)
        }
    }

    private func cloud(at point: CGPoint, scale: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.45))
                .frame(width: 80 * scale, height: 30 * scale)
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 60 * scale, height: 26 * scale)
                .offset(x: -20 * scale, y: 8 * scale)
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 65 * scale, height: 24 * scale)
                .offset(x: 22 * scale, y: 9 * scale)
        }
        .position(point)
    }

    private func leafGradient(primary: Bool) -> LinearGradient {
        if primary {
            return LinearGradient(colors: [Color(red: 0.54, green: 0.78, blue: 0.48), Color(red: 0.33, green: 0.62, blue: 0.36)], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [Color(red: 0.44, green: 0.74, blue: 0.41), Color(red: 0.29, green: 0.58, blue: 0.33)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private func petalGradient(index: Int) -> AngularGradient {
        let hue = Double(index) * 0.05
        let colors = [Color(hue: 0.97 + hue, saturation: 0.45, brightness: 0.98),
                      Color(hue: 0.9 + hue, saturation: 0.55, brightness: 0.9)]
        return AngularGradient(colors: colors, center: .center)
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

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat> = 0...1) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

private func ease(_ value: CGFloat) -> CGFloat {
    let x = value.clamped()
    return x * x * (3 - 2 * x)
}

#if DEBUG
struct PlantCanvas_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlantCanvas(stage: .sprout)
            PlantCanvas(stage: .leaves)
            PlantCanvas(stage: .blooms)
            AnimatedPlantCanvas(stage: .blooms)
        }
        .padding()
        .previewLayout(.fixed(width: 240, height: 240))
    }
}
#endif
