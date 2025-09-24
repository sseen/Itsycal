//
//  ItsycalLiquidGlassAllInOne.swift — Control Center 风格（修正版）
//

import SwiftUI
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - 背板：LiquidGlassBackdrop（Glass 分支 + 回退 + 高光/描边/轻噪点）


public struct LiquidGlassBackdrop<Content: View>: View {
    private let content: Content
    private let cornerRadius: CGFloat
    private let padding: CGFloat

    public init(cornerRadius: CGFloat = 22,
                padding: CGFloat = 18,
                @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
//            if #available(macOS 26.0, iOS 26.0, *) {
                // ✅ 1) 多块玻璃必须放在容器里，根部铺 glass 背景
                GlassEffectContainer {
                    content
                        .padding(.horizontal, padding)
                        .padding(.vertical, padding)
                }
                .glassBackgroundEffect(.plate, displayMode: .always) // 控制中心同款做法
//            } else {
//                // ↩︎ 回退：使用 NSVisualEffectView 做 backdrop + vibrancy
//                ZStack {
//                    VisualEffectBlur(material: .underWindowBackground,
//                                     blendingMode: .behindWindow)
//                    VibrantContainer {
//                        content
//                            .padding(.horizontal, padding)
//                            .padding(.vertical, padding)
//                    }
//                }
//            }
        }
        .clipShape(shape)
        .overlay(highlights.mask(shape))                     // 高光/体积
        .overlay(NoiseView().mask(shape))                    // 轻噪点（避免塑料感）
        .overlay(shape.stroke(Color.white.opacity(0.32), lineWidth: 0.9)
                    .blendMode(.screen))                     // 外亮描边
        .overlay(shape.stroke(Color.black.opacity(0.10), lineWidth: 0.7)
                    .blendMode(.multiply))                   // 内暗描边
        .compositingGroup()
        .shadow(color: .black.opacity(0.13), radius: 24, x: 0, y: 12)
    }
}

// MARK: - 旧系统回退件

@available(macOS 11.0, *)
private struct VibrantContainer<Content: View>: NSViewRepresentable {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .hudWindow
        v.blendingMode = .withinWindow
        v.state = .active

        let host = NSHostingView(rootView: content)
        host.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(host)
        NSLayoutConstraint.activate([
            host.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            host.topAnchor.constraint(equalTo: v.topAnchor),
            host.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) {}
}

@available(macOS 10.13, *)
private struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - 叠层：高光 + 轻噪点

@available(macOS 11.0, *)
private var highlights: some View {
    ZStack {
        LinearGradient(colors: [Color.white.opacity(0.28), .clear],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .blendMode(.softLight)

        RadialGradient(colors: [Color.white.opacity(0.30), .clear],
                       center: .topLeading, startRadius: 0, endRadius: 220)
            .blendMode(.screen)

        LinearGradient(colors: [.black.opacity(0.10), .clear],
                       startPoint: .bottom, endPoint: .top)
            .blendMode(.multiply)
    }
    .allowsHitTesting(false)
}

@available(macOS 11.0, *)
private struct NoiseView: View {
    static let image: NSImage = {
        let context = CIContext(options: nil)
        let random = CIFilter(name: "CIRandomGenerator")!.outputImage!
        let cc = CIFilter.colorControls()
        cc.inputImage = random
        cc.saturation = 0
        let out = cc.outputImage!.cropped(to: CGRect(x: 0, y: 0, width: 512, height: 512))
        let cg = context.createCGImage(out, from: out.extent)!
        return NSImage(cgImage: cg, size: NSSize(width: 512, height: 512))
    }()
    var body: some View {
        Image(nsImage: Self.image)
            .resizable()
            .scaledToFill()
            .opacity(0.03)
            .saturation(1.05)
            .contrast(1.02)
            .allowsHitTesting(false)
    }
}

// MARK: - 你的视图：ItsycalMenuView（关键：把“圆点”也做成玻璃）

@available(macOS 26.0, *)
struct ItsycalMenuView: View {
    @EnvironmentObject var viewModel: ItsycalViewModel
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LiquidGlassBackdrop {
            VStack(alignment: .leading, spacing: 18) {
                header
                weekdayRow
                calendarGrid
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .frame(minWidth: 360, idealWidth: 380, maxWidth: 420)
        .animation(.smooth(duration: 0.24, extraBounce: 0), value: viewModel.baseDate)
    }

    private var header: some View {
        HStack(spacing: 14) {
            NavigationButton(systemName: "chevron.left") { viewModel.stepMonth(by: -1) }
            Spacer(minLength: 12)
            Text(viewModel.currentMonthTitle.uppercased())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(.primary)      // ✅ 层级样式，保留 vibrancy
            Spacer(minLength: 12)
            NavigationButton(systemName: "chevron.right") { viewModel.stepMonth(by: 1) }
        }
    }

    private var weekdayRow: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary) // ✅ 别用 Color.secondary + opacity
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(viewModel.weeks.enumerated()), id: \.offset) { _, week in
                ForEach(week) { day in
                    Button { viewModel.select(date: day.id) } label: {
                        Text(day.label)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .background(dayHighlight(for: day)) // ✅ 玻璃圆点作为背景形状
                    .clipShape(Circle())
                    .foregroundStyle(day.isCurrentMonth ? .primary : .tertiary)
                }
            }
        }
        .animation(.smooth(duration: 0.22, extraBounce: 0), value: viewModel.baseDate)
    }

    @ViewBuilder
    private func dayHighlight(for day: ItsycalViewModel.CalendarDay) -> some View {
        let isSelected = viewModel.selectedDate.map { Calendar.current.isDate($0, inSameDayAs: day.id) } ?? false
        if isSelected || day.isToday {
            // ✅ 2) 把“圆点”也变成玻璃，让它和面板一体化（有折射/高光）
            Circle()
                .glassEffect() // 默认 regular 变体
                .overlay(Circle().stroke(Color.white.opacity(0.24), lineWidth: 0.9))
                .overlay(Circle().stroke(Color.black.opacity(0.10), lineWidth: 0.7).blendMode(.multiply))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        } else {
            Circle().fill(Color.clear)
        }
    }

    private struct NavigationButton: View {
        let systemName: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.glass) // 26+ 自带玻璃按钮样式
        }
    }
}

// MARK: - 窗口透明（AppKit 侧）
public func applyGlassWindowTweaks(_ window: NSWindow) {
    window.isOpaque = false
    window.backgroundColor = .clear
    window.titlebarAppearsTransparent = true
}
