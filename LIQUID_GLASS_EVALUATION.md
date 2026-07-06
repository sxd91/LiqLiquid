# LiqLiquid 液态玻璃 UI 完整改造评估与实施提示词

## 项目概述
项目路径: F:\liquidPiliPlus-main
基于 flutter 的 Bilibili 客户端，使用 liquid_glass_widgets v0.21.1 实现 iOS 26 液态玻璃风格。
所有玻璃组件遵循条件分支: Pref.useLiquidGlass ? GlassXxx(...) : MaterialXxx(...)

## 当前已实现功能（✅ 无需改动）
1. ✅ main.dart - LiquidGlassWidgets.initialize() 和 LiquidGlassWidgets.wrap() 已正确初始化
2. ✅ storage_key.dart - useLiquidGlass 和 useGlassNavBar 配置键存在
3. ✅ storage_pref.dart - Pref.useLiquidGlass 和 Pref.useGlassNavBar getter 已实现
4. ✅ glass_interaction.dart - GlassPressable、GlassBackButton、GlassAppBarWrapper、GlassPageWrapper 已封装
5. ✅ scroll_behavior.dart - LiquidGlassScrollBehavior 已实现，使用 Flutter 3.44 兼容的无参 const 构造函数
6. ✅ main/view.dart - GlassTabBar.searchable() 底部导航栏已实现条件切换，GlassPageWrapper 包裹主页面
7. ✅ home/view.dart - GlassSegmentedControl 用于首页标签，ProgressiveBlurWidget 用于模糊效果
8. ✅ video/header_mixin.dart、video/header_control.dart - GlassSlider 已在弹幕/播放设置中全面使用
9. ✅ setting/slider_dialog.dart、dual_slider_dialog.dart - GlassSlider 条件分支
10. ✅ setting/switch_item.dart - GlassSwitch 条件分支
11. ✅ setting/style_settings.dart - 液态玻璃总开关、玻璃底部导航、浮动导航、主页背景的设置入口已添加
12. ✅ live_dm_block/view.dart - GlassSlider 已用于直播弹幕屏蔽设置

---

## 待实施改动清单（按优先级排序）

### 1. [高] 底部导航栏可自定义玻璃参数

**问题**: 当前 main/view.dart 中 GlassTabBar 的 LiquidGlassSettings 是硬编码的:
```dart
settings: LiquidGlassSettings(
  glassColor: Colors.black.withValues(alpha: 0.88),
  blur: 3.0,
  refractiveIndex: 1.4,
  thickness: 16.0,
  chromaticAberration: 0.3,
)
```
用户无法在设置中调节这些参数。

**Skill 要求**:
- glassColor (颜色选择器)
- blur (滑块 0-50)
- refractiveIndex (滑块 0.0-2.0)
- chromaticAberration (滑块 0.0-1.0)
- thickness (滑块 0-40)

**需要改动的文件**:

1. **lib/utils/storage_key.dart** - 添加键:
   - bottomBarBlur = 'bottomBarBlur'
   - bottomBarRefractiveIndex = 'bottomBarRefractiveIndex'
   - bottomBarThickness = 'bottomBarThickness'
   - bottomBarChromaticAberration = 'bottomBarChromaticAberration'
   - bottomBarGlassColor = 'bottomBarGlassColor' (存储颜色 int 值)

2. **lib/utils/storage_pref.dart** - 添加 Pref getter:
   - static double get bottomBarBlur => _setting.get(SettingBoxKey.bottomBarBlur, defaultValue: 3.0)
   - static double get bottomBarRefractiveIndex => _setting.get(SettingBoxKey.bottomBarRefractiveIndex, defaultValue: 1.4)
   - static double get bottomBarThickness => _setting.get(SettingBoxKey.bottomBarThickness, defaultValue: 16.0)
   - static double get bottomBarChromaticAberration => _setting.get(SettingBoxKey.bottomBarChromaticAberration, defaultValue: 0.3)
   - static Color get bottomBarGlassColor => Color(_setting.get(SettingBoxKey.bottomBarGlassColor, defaultValue: Colors.black.withValues(alpha: 0.88).value))

3. **lib/pages/main/view.dart** - 将硬编码的 LiquidGlassSettings 改为动态读取 Pref:
   ```dart
   settings: LiquidGlassSettings(
     glassColor: Pref.bottomBarGlassColor,
     blur: Pref.bottomBarBlur,
     refractiveIndex: Pref.bottomBarRefractiveIndex,
     thickness: Pref.bottomBarThickness,
     chromaticAberration: Pref.bottomBarChromaticAberration,
   )
   ```

4. **lib/pages/setting/models/style_settings.dart** - 在「液态玻璃」区块下方添加底部导航栏玻璃参数设置项:
   - 使用 SliderDialog 添加 blur、refractiveIndex、thickness、chromaticAberration 滑块
   - 使用颜色选择器添加 glassColor 颜色设置
   - 每个设置项需要 setKey 和 Pref getter 对应

---

### 2. [高] 关于页面 GlassAppBar 条件化

**问题**: lib/pages/about/view.dart 第94行直接使用 GlassAppBar，没有 Pref.useLiquidGlass 条件判断。

**需要改动的文件**:
- **lib/pages/about/view.dart**: 将 `appBar: showAppBar ? GlassAppBar(...) : null`
  改为使用 `GlassAppBarWrapper` 或添加 Pref.useLiquidGlass 条件:
  ```dart
  appBar: showAppBar 
    ? (Pref.useLiquidGlass 
        ? GlassAppBar(title: const Text('关于'), backgroundColor: Colors.transparent) 
        : AppBar(title: const Text('关于')))
    : null,
  ```

---

### 3. [中] 视频播放器控制器玻璃化（GlassButton + GlassCard）

**问题**: 视频播放器控制按钮全部使用 Material 组件, 未使用液态玻璃效果。
- lib/plugin/pl_player/widgets/common_btn.dart (ComBtn) - Material 按钮
- lib/plugin/pl_player/widgets/play_pause_btn.dart - Material 动画按钮
- lib/plugin/pl_player/widgets/bottom_control.dart - Material 进度条
- lib/plugin/pl_player/widgets/backward_seek.dart - Material 快退指示器
- lib/plugin/pl_player/widgets/forward_seek.dart - Material 快进指示器

**Skill 要求**: 使用 GlassButton + GlassCard, 关键: `useOwnLayer: true` 防止 PlatformView 上的矩形模糊光晕。

**需要改动的文件**:

1. **lib/plugin/pl_player/widgets/common_btn.dart** - 将 ComBtn 的 GestureDetector 改为条件性 GlassButton:
   ```dart
   Pref.useLiquidGlass
     ? GlassButton(useOwnLayer: true, quality: GlassQuality.premium, icon: icon, onTap: onTap, width: width, height: height)
     : /* 原有 GestureDetector 实现 */
   ```

2. **lib/plugin/pl_player/widgets/play_pause_btn.dart** - 播放/暂停按钮改为 GlassButton.custom:
   ```dart
   Pref.useLiquidGlass
     ? GlassButton.custom(useOwnLayer: true, quality: GlassQuality.premium, onTap: togglePlayPause, width: 72, height: 72, child: Icon(...))
     : /* 原有实现 */
   ```

3. **lib/plugin/pl_player/widgets/bottom_control.dart** - 进度条区域包裹 GlassCard:
   ```dart
   Pref.useLiquidGlass
     ? GlassCard(useOwnLayer: true, padding: ..., child: /* 原有进度条 */)
     : /* 原有实现 */
   ```

4. **lib/plugin/pl_player/widgets/backward_seek.dart** - 快退指示器包裹 GlassCard
5. **lib/plugin/pl_player/widgets/forward_seek.dart** - 快进指示器包裹 GlassCard

---

### 4. [中] LiquidStretch 长按变形效果

**问题**: 项目中完全没有使用 LiquidStretch。

**Skill 要求**: LiquidStretch 长按变形 - 拖动时长按区域拉伸变形, 释放时弹回。

**实施建议**:
- **lib/pages/main/view.dart** - 在底部导航栏图标上包裹 LiquidStretch, 长按时图标区域拉伸变形
- 或创建新文件 **lib/common/widgets/glass_interaction.dart** 添加 GlassStretchWrapper 封装组件

**示例模式** (参考 SKILL.md):
```dart
LiquidStretch(
  child: navBarIcon,
  onLongPress: () { /* 可选回调 */ },
)
```

---

### 5. [中] GlassScaffold contentAware 亮度自适应

**问题**: 未使用 GlassScaffold 的 contentAware 功能。

**Skill 要求**: `GlassScaffold(contentAware: true)` 自动根据背景内容翻转亮/暗图标。

**需要改动的文件**:
- **lib/pages/main/view.dart** - 在最外层包裹 GlassScaffold(contentAware: true)（当 Pref.useLiquidGlass 时）
- 或通过 GlassPageWrapper 集成

---

### 6. [低] 多页面玻璃化覆盖

**问题**: 以下页面未使用 GlassPageWrapper 或 GlassAppBarWrapper:
- lib/pages/setting/view.dart (设置页)
- lib/pages/mine/view.dart (个人页)
- lib/pages/search/view.dart (搜索页)
- lib/pages/dynamics/view.dart (动态页)
- lib/pages/whisper/view.dart (私信页)
- lib/pages/webdav/view.dart (WebDAV 页)

**需要改动的文件** (对每个页面):
- 在 Scaffold 外层包裹 `GlassPageWrapper(child: ...)` 或直接在 build 方法中判断
- 将 AppBar 替换为 `GlassAppBarWrapper`

---

### 7. [低] 动态颜色自适应

**问题**: 底部导航栏玻璃颜色为固定值, 不会根据背景主题动态调整。

**Skill 要求**: "Read the dominant color behind the nav bar and adjust glassColor. Use LiquidGlassScope or build LiquidGlassSettings reactively from Theme.of(context).colorScheme."

**需要改动的文件**:
- **lib/pages/main/view.dart** - 在构建 LiquidGlassSettings 时读取 Theme.of(context).colorScheme 动态调整 glassColor, 例如:
  ```dart
  glassColor: Theme.of(context).brightness == Brightness.dark
    ? Colors.white.withValues(alpha: 0.08)
    : Colors.black.withValues(alpha: 0.88)
  ```

---

## 实施注意事项
1. 所有改动必须遵循条件分支模式: `Pref.useLiquidGlass ? GlassXxx(...) : MaterialXxx(...)`
2. 视频播放器覆盖层必须使用 `useOwnLayer: true`
3. 不修改无关代码, 保持最小变更原则
4. 所有 ScrollBehavior 必须使用 Flutter 3.44 兼容的无参 const 构造函数
5. 新增 Pref getter 必须提供合理的 defaultValue
6. 新增 SettingBoxKey 遵循命名规范: 驼峰命名, 值为 snake_case 字符串

## 文件读写原则（最高优先级）
**所有代码文件的读取和写入必须使用 Node.js (fs 模块) 完成, 确保正确处理 UTF-8 编码, 防止中文乱码。**