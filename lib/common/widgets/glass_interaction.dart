import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
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

/// 玻璃返回按钮
class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key, this.onTap, this.iconSize = 20, this.size = 40});
  final VoidCallback? onTap;
  final double iconSize;
  final double size;
  @override
  Widget build(BuildContext context) {
    return GlassButton(
      quality: GlassQuality.premium,
      icon: Icon(Platform.isIOS || Platform.isMacOS ? CupertinoIcons.back : Icons.arrow_back_rounded, size: iconSize),
      onTap: onTap ?? () => Navigator.of(context).pop(),
      width: size, height: size, iconSize: iconSize,
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
      return GlassAppBar(backgroundColor: Colors.transparent, leading: showBackButton ? GlassBackButton(onTap: onBackTap) : null, title: title, actions: actions);
    }
    return AppBar(leading: showBackButton ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBackTap ?? () => Navigator.of(context).pop()) : null, title: title, actions: actions);
  }
}

/// 玻璃页面包裹 - 条件性 GlassPage
class GlassPageWrapper extends StatelessWidget {
  const GlassPageWrapper({super.key, required this.child, this.settings});
  final Widget child;
  final LiquidGlassSettings? settings;
  @override
  Widget build(BuildContext context) {
    if (!Pref.useLiquidGlass) return child;
    return GlassPage(settings: settings ?? const LiquidGlassSettings(thickness: 12.0, blur: 20.0, chromaticAberration: 0.5, refractiveIndex: 1.35), child: child);
  }
}