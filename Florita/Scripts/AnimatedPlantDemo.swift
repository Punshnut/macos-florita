#!/usr/bin/env swift

import SwiftUI
import AppKit

private enum DemoStage: Double, CaseIterable {
    case sprout = 0.4
    case leaves = 0.75
    case blooms = 1.0

    var next: DemoStage {
        let all = DemoStage.allCases
        guard let index = all.firstIndex(of: self), index + 1 < all.count else { return .sprout }
        return all[index + 1]
    }
}

@main
struct FloritaGrowthDemo: App {
    @State private var stage: DemoStage = .sprout

    var body: some Scene {
        WindowGroup("Florita Growth Demo") {
            AnimatedDemoPlant(stage: stage)
                .frame(width: 320, height: 320)
                .padding(24)
                .background(Color(red: 0.94, green: 0.97, blue: 0.96))
                .onAppear(perform: advanceStage)
        }
        .windowStyle(.hiddenTitleBar)
    }

    private func advanceStage() {
        Task.detached {
            while true {
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                await MainActor.run {
                    stage = stage.next
                }
            }
        }
    }
}

private struct AnimatedDemoPlant: View {
    var stage: DemoStage
    @State private var animationStart = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let progress = clampedProgress(for: context.date)
            DemoPlantScene(progress: progress, time: context.date.timeIntervalSinceReferenceDate, stage: stage)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear { animationStart = Date() }
        .onChange(of: stage) { _, _ in animationStart = Date() }
    }

    private func clampedProgress(for date: Date) -> CGFloat {
        guard date >= animationStart else { return 0 }
        let elapsed = date.timeIntervalSince(animationStart)
        return CGFloat(min(max(elapsed / 6, 0), 1))
    }
}

private struct DemoPlantScene: View {
    let progress: CGFloat
    let time: TimeInterval
    let stage: DemoStage

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.92, green: 0.96, blue: 1.0), Color(red: 0.88, green: 0.94, blue: 0.9)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.58, green: 0.44, blue: 0.32), Color(red: 0.46, green: 0.34, blue: 0.24)], startPoint: .top, endPoint: .bottom))
                    .frame(width: size.width * 0.7, height: size.height * 0.22)
                    .position(x: size.width / 2, y: size.height * 0.82)
                stemLayer(size: size)
                if leavesProgress > 0 {
                    leavesLayer(size: size)
                }
                if bloomProgress > 0 {
                    bloomLayer(size: size)
                }
            }
        }
    }

    private var stageProgress: CGFloat { min(progress, CGFloat(stage.rawValue)) }

    private var stemProgress: CGFloat { min(stageProgress / 0.4, 1) }

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
        guard stageProgress >= CGFloat(stage.rawValue) else { return 0 }
        return sin(time / 2.5) * 2.5
    }

    private func stemLayer(size: CGSize) -> some View {
        DemoStemShape()
            .trim(from: 0, to: stemProgress)
            .stroke(style: StrokeStyle(lineWidth: size.width * 0.035, lineCap: .round))
            .foregroundStyle(LinearGradient(colors: [Color(red: 0.38, green: 0.63, blue: 0.35), Color(red: 0.29, green: 0.51, blue: 0.28)], startPoint: .bottom, endPoint: .top))
            .frame(width: size.width * 0.2, height: size.height * 0.55)
            .position(x: size.width / 2, y: size.height * 0.52)
            .rotationEffect(.degrees(idleSway / 5))
    }

    private func leavesLayer(size: CGSize) -> some View {
        ZStack {
            DemoLeafShape(curve: 1.0)
                .fill(Color(red: 0.48, green: 0.75, blue: 0.44))
                .frame(width: size.width * 0.28, height: size.height * 0.18)
                .position(x: size.width * 0.38, y: size.height * 0.5)
                .rotationEffect(.degrees(-18 + idleSway))
                .scaleEffect(leavesProgress * 0.9 + 0.1, anchor: .trailing)
                .opacity(Double(leavesProgress))
            DemoLeafShape(curve: -1.0)
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
                DemoPetalShape()
                    .fill(Color(red: 0.95, green: 0.72, blue: 0.82))
                    .frame(width: size.width * 0.26, height: size.height * 0.26)
                    .rotationEffect(.degrees(Double(index) * 72))
                    .scaleEffect(bloomProgress * 0.9 + 0.1)
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

private struct DemoStemShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let midX = rect.midX
            path.move(to: CGPoint(x: midX, y: rect.maxY))
            path.addCurve(to: CGPoint(x: midX, y: rect.minY), control1: CGPoint(x: midX - rect.width * 0.7, y: rect.midY), control2: CGPoint(x: midX + rect.width * 0.7, y: rect.midY))
        }
    }
}

private struct DemoLeafShape: Shape {
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

private struct DemoPetalShape: Shape {
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
