import SwiftUI

/// Adds a rain-drop overlay when Florita is being watered.
struct WateringAnimationOverlay: View {
    /// Controls whether droplets should be rendered.
    var isActive: Bool

    var body: some View {
        GeometryReader { geometry in
            let containerSize = geometry.size
            ZStack(alignment: .bottomLeading) {
                Canvas { context, size in
                    guard isActive else { return }
                    let dropletCount = 14
                    let nozzlePoint = CGPoint(x: size.width * 0.38, y: size.height * 0.42)
                    for index in 0..<dropletCount {
                        let progress = Double(index) / Double(max(dropletCount - 1, 1))
                        let cgProgress = CGFloat(progress)
                        let spread = size.width * 0.18
                        let xOffset = sin(progress * .pi * 1.6 + Double(index) * 0.24) * Double(spread)
                        let xPosition = nozzlePoint.x + CGFloat(xOffset)
                        let yPosition = nozzlePoint.y + size.height * 0.48 * cgProgress + size.height * 0.05 * cgProgress * cgProgress
                        let dropletWidth = max(3.2, 6.0 * (1 - cgProgress * 0.35))
                        let dropletHeight = dropletWidth * 2.2

                        var droplet = Path()
                        droplet.addRoundedRect(
                            in: CGRect(x: xPosition - dropletWidth / 2,
                                       y: yPosition,
                                       width: dropletWidth,
                                       height: dropletHeight),
                            cornerSize: CGSize(width: dropletWidth / 2, height: dropletWidth / 2)
                        )

                        context.opacity = max(0.15, 0.65 - progress * 0.45)
                        context.fill(
                            droplet,
                            with: .linearGradient(
                                Gradient(colors: [Color(red: 0.68, green: 0.86, blue: 0.94),
                                                  Color(red: 0.42, green: 0.71, blue: 0.85).opacity(0.2)]),
                                startPoint: CGPoint(x: xPosition, y: yPosition),
                                endPoint: CGPoint(x: xPosition, y: yPosition + dropletHeight * 1.2)
                            )
                        )
                    }
                }
                if isActive {
                    GardeningHoseIllustration(containerSize: containerSize)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .padding(.leading, -containerSize.width * 0.12)
                        .padding(.bottom, -containerSize.height * 0.04)
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(isActive ? 1 : 0)
        .animation(.easeOut(duration: 1.0), value: isActive)
    }
}

/// Stylized gardening hose that appears while watering.
private struct GardeningHoseIllustration: View {
    var containerSize: CGSize

    var body: some View {
        let hoseWidth = containerSize.width * 0.062
        let startPoint = CGPoint(x: -containerSize.width * 0.24, y: containerSize.height * 0.9)
        let control1 = CGPoint(x: containerSize.width * 0.05, y: containerSize.height * 1.02)
        let control2 = CGPoint(x: containerSize.width * 0.18, y: containerSize.height * 0.62)
        let endPoint = CGPoint(x: containerSize.width * 0.36, y: containerSize.height * 0.42)
        let nozzleLength = containerSize.width * 0.16
        let nozzleThickness = containerSize.width * 0.045

        ZStack(alignment: .bottomLeading) {
            Path { path in
                path.move(to: startPoint)
                path.addCurve(to: endPoint, control1: control1, control2: control2)
            }
            .stroke(
                LinearGradient(colors: [Color(red: 0.12, green: 0.47, blue: 0.58),
                                        Color(red: 0.04, green: 0.3, blue: 0.38)],
                               startPoint: .leading,
                               endPoint: .trailing),
                style: StrokeStyle(lineWidth: hoseWidth, lineCap: .round)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 5)

            Path { path in
                path.move(to: startPoint)
                path.addCurve(to: endPoint, control1: control1, control2: control2)
            }
            .stroke(Color.white.opacity(0.22), style: StrokeStyle(lineWidth: hoseWidth * 0.35, lineCap: .round))
            .offset(y: -hoseWidth * 0.2)

            RoundedRectangle(cornerRadius: nozzleThickness / 2, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color(red: 0.86, green: 0.88, blue: 0.92),
                                            Color(red: 0.63, green: 0.68, blue: 0.75)],
                                   startPoint: .top,
                                   endPoint: .bottom)
                )
                .frame(width: nozzleLength, height: nozzleThickness)
                .rotationEffect(.degrees(-22))
                .offset(x: endPoint.x - nozzleLength * 0.1, y: endPoint.y - nozzleThickness * 0.45)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

            Capsule()
                .fill(LinearGradient(colors: [Color(red: 0.07, green: 0.27, blue: 0.32),
                                              Color(red: 0.12, green: 0.43, blue: 0.48)],
                                     startPoint: .leading,
                                     endPoint: .trailing))
                .frame(width: hoseWidth * 2.8, height: hoseWidth * 1.1)
                .rotationEffect(.degrees(-12))
                .offset(x: startPoint.x + hoseWidth * 0.6, y: startPoint.y - hoseWidth * 1.4)

            Circle()
                .fill(Color(red: 0.09, green: 0.36, blue: 0.4))
                .frame(width: hoseWidth * 1.4, height: hoseWidth * 1.4)
                .offset(x: startPoint.x + hoseWidth * 0.8, y: startPoint.y - hoseWidth * 0.6)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
        .frame(width: containerSize.width, height: containerSize.height, alignment: .bottomLeading)
    }
}
