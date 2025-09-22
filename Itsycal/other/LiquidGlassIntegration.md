# Liquid Glass 适配总结

## 背景
- 原项目完全由 Objective-C + AppKit 构成，菜单窗口 `ItsycalWindow` 手绘边框并使用 `NSVisualEffectView` 实现传统毛玻璃。
- macOS 26 推出了全新的 SwiftUI Liquid Glass 体系（`glassEffect` / `GlassEffectContainer`），要求 SwiftUI 视图层才能获得正确材质与折射效果。
- 目标是在 macOS 26 上启用新外观，同时维持旧系统的现有视觉与行为。

## 遇到的主要阻力
1. **语言栈差异**  
   - 项目无 Swift 代码，缺乏 Swift 运行时初始化与头文件生成。  
   - 引入第一份 Swift 文件后才生成 `Swittee_Calendar-Swift.h`，且模块名前缀导致 `NSClassFromString` 找不到类。

2. **可用性与兼容性**  
   - Liquid Glass API 仅在 macOS 26 存在，必须 `@available(macOS 26.0, *)`，同时老系统仍需维持旧 UI。  
   - SwiftUI 视图要嵌入原有 AppKit 层级，既要保留箭头布局，又要避免破坏现有 Autolayout。

3. **运行时桥接**  
   - Objective-C 无法在编译期直接引用 Swift 类型时，需要通过 `NSClassFromString` + `objc_msgSend` 动态调用。  
   - Swift 侧增加 `@objcMembers` 桥接类 `ItsycalGlassBridge`，固定运行时名称并封装 `makeGlassHost`、`setArrowMidX` 等方法。

4. **窗口生命周期**  
   - 旧实现的 `setContentView:`、`positionRelativeToRect:` 对 `_childContentView` 和箭头位置有强耦合。  
   - 新的 Swift 容器必须实时更新箭头 Mask，仍然要在 Objective-C 中保留回退逻辑以防运行时桥接失败。

## 解决方案概览
- 新增 `ItsycalGlassHostView.swift`：在 SwiftUI 中使用 `GlassEffectContainer` 包裹原 AppKit 内容，使用 `CAShapeLayer` 实现箭头裁剪与描边。
- 新增 `ItsycalGlassBridge`：提供 `makeGlassHost` / `updateBorderColor` / `setArrowMidX` 等静态方法，供 Objective-C 动态调用。
- Objective-C 侧 `ItsycalWindow.m`：
  - `setContentView:` 中检测 macOS 版本 + 动态获取 Swift 桥接类，成功则替换为 SwiftUI 容器，否则回退到原 `NSVisualEffectView`。  
  - `positionRelativeToRect:` 在 Swift 容器存在时调用桥接更新箭头位置，失败则继续沿用旧逻辑。
- 所有新特性均限定在 macOS 26+，老系统不会受到影响。

## 教训与建议
- **提前预估跨语言集成成本**：纯 ObjC 工程在接入 SwiftUI 时需要准备 Swift 桥接、运行时命名与可用性判断。  
- **运行时检测可提高韧性**：通过 `NSClassFromString` + 回退逻辑，避免在 Swift 代码未编译进目标时崩溃。  
- **分层封装有助调试**：Swift 侧只负责视觉与布局，Objective-C 仍掌握生命周期与偏好逻辑，便于分段定位问题。  
- **升级路径**：后续可逐步把菜单内容迁移到 SwiftUI，进一步减少桥接代码。

