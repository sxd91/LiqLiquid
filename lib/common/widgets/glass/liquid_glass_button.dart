import 'package:flutter/material.dart';
import 'package:liqliquid/common/widgets/glass/glass_backdrop.dart';
import 'package:liqliquid/common/widgets/glass/interactive_highlight.dart';
import 'package:liqliquid/utils/storage_pref.dart';

/// Port of KMP LiquidButton.
///
/// A glass button with:
/// - GlassBackdrop blur + lens effects
/// - InteractiveHighlight press glow
/// - Drag-responsive 3D tilt (tanh-mapped offset)
/// - Tint & surface color support
/// - API compatible with existing GlassButton call sites.
class LiquidGlassButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? icon;
  final String? text;
  final double width;
  final double height;
  final double iconSize;
  final GlassBackdropConfig? settings;
  final bool enabled;
  final Color? tint;
  final Color? surfaceColor;

  const LiquidGlassButton({
    super.key,
    this.onTap,
    this.icon,
    this.text,
    this.width = 48,
    this.height = 48,
    this.iconSize = 20,
    this.settings,
    this.enabled = true,
    this.tint,
    this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!Pref.useLiquidGlass) {
      return SizedBox(
        width: width,
        height: height,
        child: enabled
            ? IconButton(
                onPressed: onTap,
                icon: icon ?? const Icon(Icons.circle),
                iconSize: iconSize,
              )
            : IconButton(
                onPressed: null,
                icon: icon ?? const Icon(Icons.circle),
                iconSize: iconSize,
              ),
      );
    }

    final config = settings ??
        GlassBackdropConfig(
          effects: [
            const BlurEffect(radius: 2.0),
            const LensEffect(
              refractionHeight: 12.0,
              refractionAmount: 24.0,
              chromaticAberration: true,
            ),
            const VibrancyEffect(),
          ],
          tint: tint,
          surfaceColor: surfaceColor,
          borderRadius: BorderRadius.circular(height / 2),
        );

    return SizedBox(
      width: width,
      height: height,
      child: InteractiveHighlight(
        onTap: enabled ? onTap : null,
        child: GlassBackdrop(
          config: config,
          child: Center(
            child: icon ??
                (text != null
                    ? Text(text!, style: const TextStyle(fontSize: 14))
                    : const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}
