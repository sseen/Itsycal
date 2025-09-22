import AppKit
import QuartzCore
import SwiftUI

@available(macOS 15.0, *)
@objcMembers
final class ItsycalGlassHostView: NSView {

    private var hostingView: NSHostingView<ItsycalGlassShell>
    private var edgeInsets: NSEdgeInsets
    private let cornerRadius: CGFloat
    private let borderWidth: CGFloat
    private let arrowHeight: CGFloat
    private var contentViewReference: NSView

    private let maskLayer = CAShapeLayer()
    private let strokeLayer = CAShapeLayer()

    private var arrowMidX: CGFloat = 0

    init(contentView: NSView,
         edgeInsets: NSEdgeInsets,
         cornerRadius: CGFloat,
         borderWidth: CGFloat,
         arrowHeight: CGFloat) {

        self.edgeInsets = edgeInsets
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.arrowHeight = arrowHeight

        self.contentViewReference = contentView

        let shell = ItsycalGlassShell(contentView: contentView,
                                      edgeInsets: EdgeInsets(edgeInsets))
        self.hostingView = NSHostingView(rootView: shell)

        super.init(frame: .zero)

        wantsLayer = true

        maskLayer.fillColor = NSColor.white.cgColor
        maskLayer.strokeColor = nil
        maskLayer.lineWidth = 0
        layer?.mask = maskLayer

        strokeLayer.fillColor = NSColor.clear.cgColor
        strokeLayer.lineWidth = borderWidth
        strokeLayer.lineJoin = .round
        strokeLayer.lineCap = .round
        strokeLayer.strokeColor = NSColor.separatorColor.withAlphaComponent(0.18).cgColor
        layer?.addSublayer(strokeLayer)

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        updateShape()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        updateShape()
    }

    func updateContentView(_ view: NSView) {
        contentViewReference = view
        hostingView.rootView = ItsycalGlassShell(contentView: view,
                                                edgeInsets: EdgeInsets(edgeInsets))
    }

    func setArrowMidX(_ value: CGFloat) {
        arrowMidX = value
        updateShape()
    }

    func setEdgeInsets(_ newInsets: NSEdgeInsets) {
        edgeInsets = newInsets
        hostingView.rootView = ItsycalGlassShell(contentView: contentViewReference,
                                                edgeInsets: EdgeInsets(edgeInsets))
        updateShape()
    }

    func setBorderColor(_ color: NSColor) {
        strokeLayer.strokeColor = color.withAlphaComponent(0.18).cgColor
    }

    private func updateShape() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let path = ItsycalGlassHostView.bubblePath(in: bounds,
                                                   borderWidth: borderWidth,
                                                   cornerRadius: cornerRadius,
                                                   arrowHeight: arrowHeight,
                                                   arrowMidX: arrowMidX)
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        strokeLayer.frame = bounds
        strokeLayer.path = path.cgPath
    }

    private static func bubblePath(in bounds: CGRect,
                                   borderWidth: CGFloat,
                                   cornerRadius: CGFloat,
                                   arrowHeight: CGFloat,
                                   arrowMidX: CGFloat) -> NSBezierPath {

        var rect = bounds.insetBy(dx: borderWidth, dy: borderWidth)
        rect.size.height -= arrowHeight

        let rectPath = NSBezierPath(roundedRect: rect,
                                    xRadius: cornerRadius,
                                    yRadius: cornerRadius)

        let effectiveMidX = arrowMidX == 0 ? rect.midX : arrowMidX
        let curveOffset: CGFloat = 5.0
        let arrowBaseY = rect.maxY
        let arrowWidth = arrowHeight + curveOffset
        let startX = effectiveMidX - arrowWidth

        let tipPoint = NSPoint(x: startX + arrowWidth, y: arrowBaseY + arrowHeight)
        let endPoint = NSPoint(x: startX + 2 * arrowWidth, y: arrowBaseY)

        let firstControl1 = NSPoint(x: startX + curveOffset, y: arrowBaseY)
        let firstControl2 = NSPoint(x: startX + arrowHeight, y: arrowBaseY + arrowHeight)
        let secondControl1 = NSPoint(x: tipPoint.x + curveOffset, y: arrowBaseY + arrowHeight)
        let secondControl2 = NSPoint(x: tipPoint.x + arrowHeight, y: arrowBaseY)

        let arrowPath = NSBezierPath()
        arrowPath.move(to: NSPoint(x: startX, y: arrowBaseY))
        arrowPath.curve(to: tipPoint,
                        controlPoint1: firstControl1,
                        controlPoint2: firstControl2)
        arrowPath.curve(to: endPoint,
                        controlPoint1: secondControl1,
                        controlPoint2: secondControl2)

        rectPath.append(arrowPath)
        rectPath.close()

        return rectPath
    }
}

@available(macOS 15.0, *)
private struct ItsycalGlassShell: View {
    let contentView: NSView
    let edgeInsets: EdgeInsets

    var body: some View {
        GlassEffectContainer {
            LegacyAppKitContent(contentView: contentView)
                .glassEffect()
        }
        .padding(edgeInsets)
    }
}

@available(macOS 15.0, *)
private struct LegacyAppKitContent: NSViewRepresentable {
    let contentView: NSView

    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.wantsLayer = false

        if contentView.superview !== nil {
            contentView.removeFromSuperview()
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: container.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

@available(macOS 15.0, *)
private extension EdgeInsets {
    init(_ insets: NSEdgeInsets) {
        self.init(top: insets.top,
                  leading: insets.left,
                  bottom: insets.bottom,
                  trailing: insets.right)
    }
}

@available(macOS 15.0, *)
private extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var didClosePath = false

        for i in 0..<elementCount {
            var points = [NSPoint](repeating: .zero, count: 3)
            switch element(at: i, associatedPoints: &points) {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
                didClosePath = true
            @unknown default:
                break
            }
        }

        if !didClosePath {
            path.closeSubpath()
        }

        return path
    }
}
