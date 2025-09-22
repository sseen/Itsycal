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

## SwiftUI 全量迁移计划（macOS 26+）

### 0. 总体策略
- macOS 26 及以上：使用 SwiftUI `MenuBarExtra` + Liquid Glass Scene，彻底替换 `ItsycalWindow`。  
- macOS 25 及以下：保持现有 Objective-C / AppKit 流程，不受影响。  
- 数据层（EventCenter、MoCalendar、偏好）继续复用，通过 SwiftUI ViewModel 桥接。

### 1. 新入口
1. 新增 `ItsycalMacApp.swift`，创建 `@main` SwiftUI 应用。  
2. 通过 `@NSApplicationDelegateAdaptor` 包装旧 AppDelegate，在 macOS 26 以下调用原逻辑。  
3. `body` 中使用 `MenuBarExtra`（26+）与 `LegacyBridgeScene`（旧系统）对应。  
4. 验证：26 上出现新的菜单项，旧系统仍弹出现有窗口。

### 2. ViewModel 与桥接
1. 新建 `ItsycalViewModel.swift`（`@objcMembers`, `ObservableObject`）。  
2. 暴露日历网格、事件列表、偏好状态；封装原有 `EventCenter` 调用。  
3. 提供 SwiftUI 可调用的接口（切换月份、创建事件、刷新数据）。  
4. 验证：在旧 AppDelegate 内更新 ViewModel 是否能实时驱动 SwiftUI 预览。

### 3. SwiftUI 界面构建
1. `ItsycalMenuView`：使用 `GlassEffectContainer` + `LazyVGrid` 显示日期、`List` 展示 Agenda。  
2. 采用 `.buttonStyle(.glass)` 等系统样式；所有容器背景保持透明。  
3. 按钮、工具栏、快捷入口重写为 SwiftUI 组件。  
4. 验证：功能可交互（选日、查看 Agenda、调用旧的创建事件逻辑）。

### 4. MenuBarExtra & Scene 管理
1. 在 `MenuBarExtra` 中创建 `StateObject` 的 `ItsycalViewModel`。  
2. 使用 `.menuBarExtraStyle(.window)` 与系统保持一致。  
3. 将快捷键、偏好操作迁移到 SwiftUI `Commands` 或 `Focus` API。  
4. 验证：菜单栏快捷键、窗口弹出/收起与控制中心一致。

### 5. 兼容与收尾
1. 保留原 `main.m`、`ItsycalWindow` 供旧系统使用；在 26+ 构建链路中排除此路径。  
2. 清理不再使用的桥接代码，更新项目配置与文档。  
3. 编写测试步骤：26 环境验证 SwiftUI 外观，25 环境确认旧界面无回归。  
4. 更新 README / 变更日志，标注 26+ 新界面。
