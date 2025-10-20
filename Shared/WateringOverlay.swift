import SwiftUI

struct WateringOverlay: View {
    var isActive: Bool

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard isActive else { return }
                let dropletCount = 12
                for index in 0..<dropletCount {
                    let progress = Double(index) / Double(dropletCount)
                    let x = size.width * CGFloat(progress)
                    let randomOffset = sin(progress * .pi * 4) * 12
                    var droplet = Path()
                    droplet.addRoundedRect(in: CGRect(x: x + randomOffset,
                                                      y: size.height * CGFloat(progress) * 0.6,
                                                      width: 6,
                                                      height: 14), cornerSize: CGSize(width: 3, height: 4))
                    context.opacity = 0.6 - progress * 0.4
                    context.fill(droplet, with: .radialGradient(
                        Gradient(colors: [Color(red: 0.68, green: 0.86, blue: 0.94), Color(red: 0.43, green: 0.72, blue: 0.85).opacity(0.2)]),
                        center: CGPoint(x: droplet.boundingRect.midX, y: droplet.boundingRect.midY),
                        startRadius: 0,
                        endRadius: 10
                    ))
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(isActive ? 1 : 0)
        .animation(.easeOut(duration: 1.0), value: isActive)
    }
}
