# LiqLiquid 液态玻璃 UI 完整改造方案 v2.0

## 核心目标
基于 Kyant's Backdrop (Compose/KMP) 库的玻璃效果参数体系，全面提升 LiqLiquid Flutter 项目在**全平台**（含 Windows 桌面端）的 iOS 26 液态玻璃表现。

---

## 背景分析

### 当前 liquid_glass_widgets 状态
- 所有平台均有真实 shader 玻璃（非假玻璃）
- 参数调优不足，桌面端视觉效果差
- 缺少许多 Compose 库中的高级效果参数

### Kyant's Backdrop (Compose) 参数体系对比

| 效果维度 | Compose Backdrop | Flutter liquid_glass_widgets | 差距 |
|----------|------------------|------------------------------|------|
| 模糊 | blur(radius) | blur | 相当 |
| 折射 | lens(height, amount, depthEffect, chromAberr) | refractiveIndex | Compose 更精细 |
| 色彩饱和度 | vibrancy() / colorControls() | saturation | 相当 |
| 不透明度 | opacity(alpha) | glassColor alpha | 相当 |
| 高光 | Highlight(Plain/Default/Ambient) | lightIntensity, specularSharpness, lightAngle | Flutter 更可控 |
| 环境光 | Ambient highlight | ambientStrength | 相当 |
| 厚度 | - | thickness | Flutter 独有 |
| 色散 | chromaticAberration | chromaticAberration | 相当 |
| **深度效果** | **depthEffect (lens)** | **缺失** | **关键差距** |
| **阴影** | **Shadow(radius,offset,color)** | **缺失** | **关键差距** |
| **颜色控制** | **brightness/contrast/saturation** | **仅 saturation** | **差距** |

### Compose 库核心 API（作为参考）
```kotlin
// 效果链
drawBackdrop(backdrop, shape, effects = {
    vibrancy()              // 饱和度增强 1.5x
    blur(radius)            // 高斯模糊
    lens(                   // 玻璃折射
        refractionHeight,   // 折射高度
        refractionAmount,   // 折射量
        depthEffect = true, // 深度效果 ← Flutter 缺失
        chromaticAberration  // 色散
    )
    opacity(alpha)          // 不透明度
    colorControls(brightness, contrast, saturation) // 全颜色控制
}, highlight = { Highlight.Default }) // 高光

// 高光样式
Highlight.Default(angle=45f, falloff=1f)  // 角度+衰减
Highlight.Ambient(intensity=0.38f)         // 环境光
Highlight.Plain(color, blendMode)          // 平凡高光

// 阴影
Shadow(radius=24dp, offset, color, alpha, blendMode)
```

---

## 改动清单（按优先级）

### P0: 桌面端玻璃效果增强（核心）

**根因**: GlassTabBar LiquidGlassSettings 硬编码参数对桌面端不友好
**解决**: 平台自适应默认值 + 用户可调参数

**文件清单**:
1. **lib/utils/storage_key.dart** - 添加 10 个底部栏玻璃参数键
2. **lib/utils/storage_pref.dart** - 添加平台自适应 Pref getter
3. **lib/pages/main/view.dart** - 动态 LiquidGlassSettings
4. **lib/common/widgets/glass_interaction.dart** - 增强 GlassPageWrapper/GlassBackButton

### P1: vibrancy + depthEffect 模拟

**文件**: lib/common/widgets/glass_interaction.dart
新增 GlassVibrancyWrapper（ColorFilter 饱和度增强）

### P2: 关于页 AppBar 条件化

**文件**: lib/pages/about/view.dart
GlassAppBar → Pref.useLiquidGlass 条件分支

### P3: 底部栏玻璃参数设置 UI

**文件**: lib/pages/setting/models/style_settings.dart
添加 blur/折射率/厚度/色散/高光/环境光/饱和度 滑块设置

### P4: 视频播放器玻璃化

**文件**:
- lib/plugin/pl_player/widgets/common_btn.dart
- lib/plugin/pl_player/widgets/play_pause_btn.dart
- lib/plugin/pl_player/widgets/bottom_control.dart

### P5: 动态颜色自适应

**文件**: lib/pages/main/view.dart
根据 Theme brightness 动态调整 glassColor

### P6: LiquidStretch 长按变形

**文件**: lib/pages/main/view.dart, lib/common/widgets/glass_interaction.dart

---

## 实施原则

1. **Node.js fs 读写所有代码** - UTF-8 编码
2. Pref.useLiquidGlass ? GlassXxx : MaterialXxx 条件分支
3. 视频覆盖层 useOwnLayer: true
4. Flutter 3.44 兼容无参 const ScrollBehavior
5. 桌面端默认值明显优于当前硬编码
6. 最小变更，不修改无关代码
