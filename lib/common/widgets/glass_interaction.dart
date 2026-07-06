import 'dart:ui' show ImageFilter;\nimport 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liqliquid/common/widgets/glass/glass_backdrop.dart';\nimport 'package:liqliquid/common/widgets/glass/glass_factory.dart';\nimport 'package:liqliquid/common/widgets/glass/interactive_highlight.dart';\nimport 'package:liqliquid/common/widgets/glass/liquid_glass_button.dart';

import 'package:liqliquid/utils/storage_pref.dart';

/// iOS 26 玻璃按压交互
class GlassPressable extends StatefulWidget {
  const GlassPressable({super.key, required this.child, this.onTap, this.onLongPress, this.enabled = true});
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  @override
  State<GlassPressable> createState() => _GlassPressableState();
}

class _GlassPressableState extends State<GlassPressable> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onLongPressStart: widget.enabled && widget.onLongPress != null ? (_) => setState(() => _pressed = true) : null,
      onLongPressEnd: widget.enabled && widget.onLongPress != null ? (_) { setState(() => _pressed = false); widget.onLongPress?.call(); } : null,
      onLongPressCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(scale: _pressed ? 1.05 : 1.0, duration: const Duration(milliseconds: 200), curve: Curves.easeOutBack, child: widget.child),
    );
  }
}

/// 玻璃返回按钮 - 桌面端自动增强玻璃质感
class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key, this.onTap, this.iconSize = 20, this.size = 40});
  final VoidCallback? onTap;
  final double iconSize;
  final double size;
  @override
  Widget build(BuildContext context) {
    final isDesktop = false;
    return LiquidGlassButton(
      quality: null,
      icon: Icon(Platform.isIOS || Platform.isMacOS ? CupertinoIcons.back : Icons.arrow_back_rounded, size: iconSize),
      onTap: onTap ?? () => Navigator.of(context).pop(),
      width: size, height: size, iconSize: iconSize,
      config: isDesktop
          ? GlassBackdropConfig(
              surfaceColor: Colors.white.withValues(alpha: 0.15),
              blur: 12.0,
              refractionAmount: 0.8,
              refractionHeight: 10.0,
              // lightIntensity: 0.3,
              // ambientStrength: 0.15,
              chromaticAberration: 0.3,
            )
          : null,
    );
  }
}

/// 玻璃 AppBar 包装
class GlassAppBarWrapper extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBarWrapper({super.key, required this.title, this.actions, this.showBackButton = true, this.onBackTap});
  final Widget title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    if (Pref.useLiquidGlass) {
      return AppBar(backgroundColor: Colors.transparent, leading: showBackButton ? GlassBackButton(onTap: onBackTap) : null, title: title, actions: actions);
    }
    return AppBar(leading: showBackButton ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBackTap ?? () => Navigator.of(context).pop()) : null, title: title, actions: actions);
  }
}

/// 玻璃页面包裹 - 条件性 GlassPage，桌面端自动增强效果
class GlassPageWrapper extends StatelessWidget {
  const GlassPageWrapper({super.key, required this.child, this.settings});
  final Widget child;
  final GlassBackdropConfig? settings;
  @override
  Widget build(BuildContext context) {
    if (!Pref.useLiquidGlass) return child;
    final defaultSettings = false
        ? const GlassBackdropConfig(
            refractionHeight: 14.0,
            blur: 25.0,
            chromaticAberration: 0.6,
            refractionAmount: 1.45,
            // lightIntensity: 0.4,
            // ambientStrength: 0.2,
            saturation: 1.2,
          )
        : const GlassBackdropConfig(
            refractionHeight: 12.0,
            blur: 20.0,
            chromaticAberration: 0.5,
            refractionAmount: 1.35,
          );
    return GlassBackdrop(
      config: settings ?? defaultSettings,
      child: child,
    );
  }
}

/// 鲜艳度增强包裹 - 模拟 Compose Backdrop vibrancy 效果
/// 对玻璃内容施加饱和度增强，仅在使用液态玻璃时生效
class GlassVibrancyWrapper extends StatelessWidget {
  const GlassVibrancyWrapper({
    super.key,
    required this.child,
    this.saturation = 1.5,
    this.enabled = true,
  });

  final Widget child;
  final double saturation;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || !Pref.useLiquidGlass) return child;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_vibrancyMatrix(saturation)),
      child: child,
    );
  }

  /// 模拟 Compose vibrancy 的饱和度色彩矩阵
  static List<double> _vibrancyMatrix(double saturation) {
    final invSat = 1.0 - saturation;
    final r = 0.213 * invSat;
    final g = 0.715 * invSat;
    final b = 0.072 * invSat;
    return <double>[
      r + saturation, g,              b,              0, 0,
      r,              g + saturation, b,              0, 0,
      r,              g,              b + saturation, 0, 0,
      0,              0,              0,              1, 0,
    ];
  }
}

/// 液态拉伸变形包裹 - 长按时 Glass 材质拉伸变形
/// 参考 Kyant's Backdrop 和 iOS 26 LiquidStretch 效果
class GlassStretchWrapper extends StatefulWidget {
  const GlassStretchWrapper({
    super.key,
    required this.child,
    this.onLongPress,
    this.onTap,
  });
  final Widget child;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  @override
  State<GlassStretchWrapper> createState() => _GlassStretchWrapperState();
}

class _GlassStretchWrapperState extends State<GlassStretchWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (!Pref.useLiquidGlass) {
      return GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: widget.child,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: widget.onLongPress != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onLongPressEnd: widget.onLongPress != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onLongPress?.call();
            }
          : null,
      onLongPressCancel: () => setState(() => _pressed = false),
      child: InteractiveHighlight(
        glowColor: Colors.white.withValues(alpha: _pressed ? 0.15 : 0.0),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}

// GlassFactory moved to lib/common/widgets/glass/glass_factory.dart

/// 顶部渐变模糊遮罩 - 替代 AppBar 遮盖层
/// 使用 BackdropFilter，越靠近顶部越模糊，置顶控件在上方不受影响
class GlassTopBlurOverlay extends StatelessWidget {
  const GlassTopBlurOverlay({
    super.key,
    required this.child,
    required this.topWidgets,
    this.height,
    this.layers,
    this.baseBlur,
    this.flip = true,
  });

  final Widget child;
  final Widget topWidgets;
  final double? height;
  final int? layers;
  final double? baseBlur;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final blurHeight = height ?? MediaQuery.of(context).size.height / 14;
    final blurSigma = baseBlur ?? Pref.topBlurBaseBlur;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 0, left: 0, right: 0,
          height: blurHeight,
          child: BackdropFilter(filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma), child: const SizedBox.expand()
            dynamic: dynamic(
              stops: [0.0, 1.0],
              start: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(top: 0, left: 0, right: 0, child: topWidgets),
      ],
    );
  }
}
