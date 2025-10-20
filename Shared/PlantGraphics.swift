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
        let specs: [LeafSpec] = [
            LeafSpec(position: CGPoint(x: 0.34, y: 0.64),
                     size: CGSize(width: 0.28, height: 0.19),
                     anchor: .trailing,
                     baseRotation: -34,
                     swayMultiplier: 0.55,
                     curve: 1.05,
                     start: 0.0,
                     span: 0.3,
                     tone: .emerald),
            LeafSpec(position: CGPoint(x: 0.66, y: 0.63),
                     size: CGSize(width: 0.28, height: 0.19),
                     anchor: .leading,
                     baseRotation: 34,
                     swayMultiplier: -0.55,
                     curve: -1.05,
                     start: 0.0,
                     span: 0.3,
                     tone: .jade),
            LeafSpec(position: CGPoint(x: 0.42, y: 0.5),
                     size: CGSize(width: 0.32, height: 0.21),
                     anchor: .trailing,
                     baseRotation: -20,
                     swayMultiplier: 0.4,
                     curve: 0.85,
                     start: 0.22,
                     span: 0.32,
                     tone: .jade),
            LeafSpec(position: CGPoint(x: 0.58, y: 0.48),
                     size: CGSize(width: 0.32, height: 0.21),
                     anchor: .leading,
                     baseRotation: 22,
                     swayMultiplier: -0.4,
                     curve: -0.85,
                     start: 0.22,
                     span: 0.32,
                     tone: .forest),
            LeafSpec(position: CGPoint(x: 0.4, y: 0.4),
                     size: CGSize(width: 0.26, height: 0.18),
                     anchor: .trailing,
                     baseRotation: -12,
                     swayMultiplier: 0.3,
                     curve: 0.6,
                     start: 0.48,
                     span: 0.3,
                     tone: .forest),
            LeafSpec(position: CGPoint(x: 0.6, y: 0.38),
                     size: CGSize(width: 0.26, height: 0.18),
                     anchor: .leading,
                     baseRotation: 14,
                     swayMultiplier: -0.3,
                     curve: -0.6,
                     start: 0.48,
                     span: 0.3,
                     tone: .emerald),
            LeafSpec(position: CGPoint(x: 0.5, y: 0.35),
                     size: CGSize(width: 0.23, height: 0.17),
                     anchor: .bottom,
                     baseRotation: 0,
                     swayMultiplier: 0.18,
                     curve: 0,
                     start: 0.62,
                     span: 0.28,
                     tone: .mint)
        ]

        return ZStack {
            ForEach(Array(specs.enumerated()), id: \.offset) { index, spec in
                let localGrowth = stagedLeafGrowth(global: growth, start: spec.start, span: spec.span)
                if localGrowth > 0 {
                    LeafShape(curve: spec.curve)
                        .fill(leafGradient(tone: spec.tone))
                        .frame(width: size.width * spec.size.width, height: size.height * spec.size.height)
                        .position(x: size.width * spec.position.x, y: size.height * spec.position.y)
                        .rotationEffect(.degrees(spec.baseRotation + sway * spec.swayMultiplier))
                        .scaleEffect(0.25 + 0.75 * localGrowth, anchor: spec.anchor)
                        .opacity(Double(localGrowth))
                        .zIndex(Double(index))
                }
            }
        }
    }

    private func stagedLeafGrowth(global: CGFloat, start: CGFloat, span: CGFloat) -> CGFloat {
        guard span > 0 else {
            return global >= start ? 1 : 0
        }
        let progress = ((global - start) / span).clamped()
        return ease(progress)
    }

    private struct LeafSpec {
        let position: CGPoint
        let size: CGSize
        let anchor: UnitPoint
        let baseRotation: Double
        let swayMultiplier: Double
        let curve: CGFloat
        let start: CGFloat
        let span: CGFloat
        let tone: LeafTone
    }

    private enum LeafTone {
        case emerald
        case jade
        case forest
        case mint
    }

    private func stagedBloomGrowth(global: CGFloat, start: CGFloat, span: CGFloat) -> CGFloat {
        guard span > 0 else {
            return global >= start ? 1 : 0
        }
        let progress = ((global - start) / span).clamped()
        return ease(progress)
    }

    private struct TulipSpec {
        let base: CGPoint
        let size: CGSize
        let stemHeight: CGFloat
        let stemWidth: CGFloat
        let start: CGFloat
        let span: CGFloat
        let tilt: Double
        let swayMultiplier: Double
        let palette: TulipPalette
    }

    private enum TulipPalette {
        case sunrise
        case orchid
        case violet
    }

    func bloomLayer(size: CGSize, growth: CGFloat, sway: Double, time: TimeInterval?) -> some View {
        let specs: [TulipSpec] = [
            TulipSpec(base: CGPoint(x: 0.5, y: 0.34),
                      size: CGSize(width: 0.22, height: 0.28),
                      stemHeight: 0.16,
                      stemWidth: 0.02,
                      start: 0.0,
                      span: 0.35,
                      tilt: 0,
                      swayMultiplier: 0.25,
                      palette: .sunrise),
            TulipSpec(base: CGPoint(x: 0.4, y: 0.36),
                      size: CGSize(width: 0.2, height: 0.25),
                      stemHeight: 0.18,
                      stemWidth: 0.018,
                      start: 0.28,
                      span: 0.34,
                      tilt: -6,
                      swayMultiplier: 0.35,
                      palette: .orchid),
            TulipSpec(base: CGPoint(x: 0.6, y: 0.35),
                      size: CGSize(width: 0.2, height: 0.25),
                      stemHeight: 0.17,
                      stemWidth: 0.018,
                      start: 0.56,
                      span: 0.34,
                      tilt: 7,
                      swayMultiplier: -0.32,
                      palette: .violet)
        ]

        let stemGradient = LinearGradient(colors: [Color(red: 0.37, green: 0.64, blue: 0.34),
                                                   Color(red: 0.29, green: 0.55, blue: 0.3)],
                                          startPoint: .bottom,
                                          endPoint: .top)

        return ZStack {
            ForEach(Array(specs.enumerated()), id: \.offset) { index, spec in
                let bloomProgress = stagedBloomGrowth(global: growth, start: spec.start, span: spec.span)
                if bloomProgress > 0 {
                    let centerX = size.width * spec.base.x
                    let baseY = size.height * spec.base.y
                    let stemHeight = size.height * spec.stemHeight
                    let stemWidth = size.width * spec.stemWidth
                    let flowerHeight = size.height * spec.size.height
                    let flowerWidth = size.width * spec.size.width
                    let stemScale = 0.35 + 0.65 * bloomProgress
                    let bloomScale = 0.35 + 0.65 * bloomProgress
                    let swayContribution = sway * spec.swayMultiplier
                    let bob = sin((time ?? 0) / 1.8 + Double(index) * 0.9) * Double(bloomProgress) * 1.8
                    let stemTopY = baseY - stemHeight * stemScale

                    Capsule(style: .continuous)
                        .fill(stemGradient)
                        .frame(width: stemWidth, height: stemHeight)
                        .scaleEffect(x: 1, y: stemScale, anchor: .bottom)
                        .rotationEffect(.degrees(spec.tilt + swayContribution * 0.6), anchor: .bottom)
                        .position(x: centerX, y: baseY)
                        .opacity(Double(bloomProgress))

                    TulipShape()
                        .fill(tulipGradient(palette: spec.palette))
                        .frame(width: flowerWidth, height: flowerHeight)
                        .scaleEffect(bloomScale, anchor: .bottom)
                        .rotationEffect(.degrees(spec.tilt + swayContribution * 1.1 + bob * 0.35), anchor: .bottom)
                        .position(x: centerX, y: stemTopY)
                        .opacity(Double(bloomProgress))
                        .overlay(
                            TulipShape()
                                .stroke(Color.white.opacity(0.18), lineWidth: size.width * 0.006)
                        )
                        .overlay(
                            RadialGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0)],
                                           center: .topLeading,
                                           startRadius: 0,
                                           endRadius: max(flowerWidth, flowerHeight) * 0.6)
                                .opacity(Double(bloomProgress) * 0.7)
                                .mask(TulipShape())
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .zIndex(Double(index) + 1)
                }
            }
        }
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

    private func leafGradient(tone: LeafTone) -> LinearGradient {
        switch tone {
        case .emerald:
            return LinearGradient(colors: [Color(red: 0.54, green: 0.8, blue: 0.46),
                                           Color(red: 0.32, green: 0.63, blue: 0.34)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case .jade:
            return LinearGradient(colors: [Color(red: 0.48, green: 0.76, blue: 0.44),
                                           Color(red: 0.29, green: 0.6, blue: 0.34)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case .forest:
            return LinearGradient(colors: [Color(red: 0.41, green: 0.66, blue: 0.37),
                                           Color(red: 0.25, green: 0.5, blue: 0.29)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case .mint:
            return LinearGradient(colors: [Color(red: 0.64, green: 0.86, blue: 0.58),
                                          Color(red: 0.44, green: 0.71, blue: 0.42)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        }
    }

    private func tulipGradient(palette: TulipPalette) -> LinearGradient {
        switch palette {
        case .sunrise:
            return LinearGradient(colors: [Color(red: 0.99, green: 0.82, blue: 0.48),
                                           Color(red: 0.94, green: 0.49, blue: 0.35)],
                                  startPoint: .top,
                                  endPoint: .bottom)
        case .orchid:
            return LinearGradient(colors: [Color(red: 0.96, green: 0.7, blue: 0.82),
                                           Color(red: 0.79, green: 0.42, blue: 0.66)],
                                  startPoint: .top,
                                  endPoint: .bottom)
        case .violet:
            return LinearGradient(colors: [Color(red: 0.79, green: 0.66, blue: 0.97),
                                           Color(red: 0.47, green: 0.36, blue: 0.78)],
                                  startPoint: .top,
                                  endPoint: .bottom)
        }
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
            let width = rect.width
            let height = rect.height
            let midY = rect.midY
            let lean = curve * width * 0.25

            path.move(to: CGPoint(x: rect.minX, y: midY))
            path.addQuadCurve(to: CGPoint(x: rect.minX + width * 0.2, y: rect.minY + height * 0.18),
                              control: CGPoint(x: rect.minX - width * 0.05, y: midY - height * 0.22))
            path.addQuadCurve(to: CGPoint(x: rect.midX + lean, y: rect.minY + height * 0.05),
                              control: CGPoint(x: rect.minX + width * 0.45 + lean * 0.4, y: rect.minY - height * 0.05))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: midY),
                              control: CGPoint(x: rect.midX + lean + width * 0.26, y: rect.minY + height * 0.12))
            path.addQuadCurve(to: CGPoint(x: rect.midX + lean, y: rect.maxY - height * 0.05),
                              control: CGPoint(x: rect.midX + lean + width * 0.26, y: rect.maxY - height * 0.12))
            path.addQuadCurve(to: CGPoint(x: rect.minX + width * 0.2, y: rect.maxY - height * 0.18),
                              control: CGPoint(x: rect.minX + width * 0.45 + lean * 0.4, y: rect.maxY + height * 0.05))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: midY),
                              control: CGPoint(x: rect.minX - width * 0.05, y: midY + height * 0.22))
            path.closeSubpath()
        }
    }
}

private struct TulipShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let midX = rect.midX
        return Path { path in
            path.move(to: CGPoint(x: midX, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                              control: CGPoint(x: rect.minX + width * 0.08, y: rect.maxY - height * 0.08))
            path.addQuadCurve(to: CGPoint(x: rect.minX + width * 0.18, y: rect.minY + height * 0.32),
                              control: CGPoint(x: rect.minX - width * 0.18, y: rect.minY + height * 0.4))
            path.addQuadCurve(to: CGPoint(x: midX - width * 0.18, y: rect.minY + height * 0.08),
                              control: CGPoint(x: rect.minX + width * 0.32, y: rect.minY + height * 0.12))
            path.addQuadCurve(to: CGPoint(x: midX, y: rect.minY),
                              control: CGPoint(x: midX - width * 0.04, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: midX + width * 0.18, y: rect.minY + height * 0.08),
                              control: CGPoint(x: midX + width * 0.04, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - width * 0.18, y: rect.minY + height * 0.32),
                              control: CGPoint(x: rect.maxX - width * 0.32, y: rect.minY + height * 0.12))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                              control: CGPoint(x: rect.maxX + width * 0.18, y: rect.minY + height * 0.4))
            path.addQuadCurve(to: CGPoint(x: midX, y: rect.maxY),
                              control: CGPoint(x: rect.maxX - width * 0.08, y: rect.maxY - height * 0.08))
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
