import AppKit
import SwiftUI
#if canImport(Glass)
import Glass
#endif

@available(macOS 26.0, *)
struct LiquidGlassBackdrop<Content: View>: View {

    private let content: Content
    private let cornerRadius: CGFloat = 22

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
#if canImport(Glass)
            GlassEffectContainer {
                content
                    .glassEffect(.group)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
            }
            .glassBackground(material: .thin, blurRadius: 28)
#else
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(.ultraThinMaterial)
#endif
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

@available(macOS 26.0, *)
private struct LegacyAppKitContent: NSViewRepresentable {
    let contentView: NSView

    func makeNSView(context: Context) -> NSView {
        let container = TransparentContainer()
        embed(contentView, into: container)
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let container = nsView as? TransparentContainer else { return }
        embed(contentView, into: container)
    }

    private func embed(_ view: NSView, into container: TransparentContainer) {
        if view.superview !== container {
            view.removeFromSuperview()
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
    }
}

private final class TransparentContainer: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(macOS 26.0, *)
struct ItsycalLiquidShellView: View {
    let legacyContent: NSView

    var body: some View {
        LiquidGlassBackdrop {
            LegacyAppKitContent(contentView: legacyContent)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
    }
}

@available(macOS 26.0, *)
@objcMembers
final class ItsycalGlassBridge: NSObject {

    @objc(makeGlassHostWithContentView:)
    static func makeGlassHost(with contentView: NSView) -> NSView {
        let shellView = ItsycalLiquidShellView(legacyContent: contentView)
        let host = NSHostingView(rootView: shellView)
        host.translatesAutoresizingMaskIntoConstraints = false
        host.wantsLayer = true
        host.layer?.backgroundColor = NSColor.clear.cgColor
        return host
    }

    @objc(refreshContentLayoutForHost:)
    static func refreshContentLayout(for host: NSView) {
        guard let hosting = host as? NSHostingView<ItsycalLiquidShellView> else { return }
        hosting.layoutSubtreeIfNeeded()
    }
}
