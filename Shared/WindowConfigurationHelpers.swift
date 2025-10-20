import SwiftUI

#if os(macOS)
import AppKit

struct WindowSizeApplier: NSViewRepresentable {
    let targetSize: CGSize

    final class Coordinator {
        var lastAppliedSize: CGSize = .zero
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.isHidden = true
        DispatchQueue.main.async {
            applySizeIfPossible(from: view, coordinator: context.coordinator)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            applySizeIfPossible(from: nsView, coordinator: context.coordinator)
        }
    }

    private func applySizeIfPossible(from view: NSView, coordinator: Coordinator) {
        guard let window = view.window else { return }
        let currentSize = window.contentLayoutRect.size
        guard coordinator.lastAppliedSize != targetSize ||
              abs(currentSize.width - targetSize.width) > 0.5 ||
              abs(currentSize.height - targetSize.height) > 0.5 else {
            return
        }
        coordinator.lastAppliedSize = targetSize
        window.setContentSize(targetSize)
    }
}

struct WindowTransparencyApplier: NSViewRepresentable {
    let isTransparent: Bool

    final class Coordinator {
        var lastTransparency: Bool?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.isHidden = true
        DispatchQueue.main.async {
            applyTransparencyIfPossible(from: view, coordinator: context.coordinator)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            applyTransparencyIfPossible(from: nsView, coordinator: context.coordinator)
        }
    }

    private func applyTransparencyIfPossible(from view: NSView, coordinator: Coordinator) {
        guard let window = view.window else { return }
        guard coordinator.lastTransparency != isTransparent else { return }
        coordinator.lastTransparency = isTransparent
        if isTransparent {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.titlebarAppearsTransparent = true
        } else {
            window.isOpaque = true
            window.backgroundColor = NSColor.windowBackgroundColor
            window.titlebarAppearsTransparent = false
        }
    }
}
#else
struct WindowSizeApplier: View {
    let targetSize: CGSize

    var body: some View {
        EmptyView()
    }
}

struct WindowTransparencyApplier: View {
    let isTransparent: Bool

    var body: some View {
        EmptyView()
    }
}
#endif
