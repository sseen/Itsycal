import AppKit
import SwiftUI
#if canImport(Glass)
import Glass
#endif

@available(macOS 26.0, *)
struct MenuBubbleShape: Shape {
    var cornerRadius: CGFloat = 22
    var arrowHeight: CGFloat = 12
    var arrowWidth: CGFloat = 28

    func path(in rect: CGRect) -> Path {
        let arrowHalfWidth = max(arrowWidth / 2, 8)
        let arrowBaseY = arrowHeight
        let topY = arrowBaseY
        let bottomY = rect.maxY
        let leftX = rect.minX
        let rightX = rect.maxX
        let arrowMidX = rect.midX

        var path = Path()
        path.move(to: CGPoint(x: leftX + cornerRadius, y: topY))
        path.addLine(to: CGPoint(x: arrowMidX - arrowHalfWidth, y: topY))
        path.addQuadCurve(to: CGPoint(x: arrowMidX, y: 0), control: CGPoint(x: arrowMidX - arrowHalfWidth * 0.4, y: topY * 0.3))
        path.addQuadCurve(to: CGPoint(x: arrowMidX + arrowHalfWidth, y: topY), control: CGPoint(x: arrowMidX + arrowHalfWidth * 0.4, y: topY * 0.3))
        path.addLine(to: CGPoint(x: rightX - cornerRadius, y: topY))
        path.addQuadCurve(to: CGPoint(x: rightX, y: topY + cornerRadius), control: CGPoint(x: rightX, y: topY))
        path.addLine(to: CGPoint(x: rightX, y: bottomY - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rightX - cornerRadius, y: bottomY), control: CGPoint(x: rightX, y: bottomY))
        path.addLine(to: CGPoint(x: leftX + cornerRadius, y: bottomY))
        path.addQuadCurve(to: CGPoint(x: leftX, y: bottomY - cornerRadius), control: CGPoint(x: leftX, y: bottomY))
        path.addLine(to: CGPoint(x: leftX, y: topY + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: leftX + cornerRadius, y: topY), control: CGPoint(x: leftX, y: topY))
        path.closeSubpath()
        return path
    }
}

@available(macOS 26.0, *)
struct LiquidGlassBackdrop<Content: View>: View {

    private let content: Content
    private let arrowHeight: CGFloat = 12
    private let arrowWidth: CGFloat = 28
    private let cornerRadius: CGFloat = 22

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let shape = MenuBubbleShape(cornerRadius: cornerRadius, arrowHeight: arrowHeight, arrowWidth: arrowWidth)

        Group {
#if canImport(Glass)
            GlassEffectContainer {
                content
                    .glassEffect(.group)
                    .padding(.top, arrowHeight + 14)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 18)
            }
            .glassBackground(material: .thin, blurRadius: 28)
#else
            content
                .padding(.top, arrowHeight + 14)
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
                .background(.ultraThinMaterial)
#endif
        }
        .clipShape(shape)
        .shadow(color: Color.black.opacity(0.18), radius: 22, y: 6)
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
