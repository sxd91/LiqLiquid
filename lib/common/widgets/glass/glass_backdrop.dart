import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:liqliquid/utils/storage_pref.dart';

sealed class GlassBackdropEffect {
  const GlassBackdropEffect();
}

class BlurEffect extends GlassBackdropEffect {
  final double radius;
  const BlurEffect({required this.radius});
}

class LensEffect extends GlassBackdropEffect {
  final double refractionHeight;
  final double refractionAmount;
  final bool chromaticAberration;
  const LensEffect({
    required this.refractionHeight,
    required this.refractionAmount,
    this.chromaticAberration = false,
  });
}

class VibrancyEffect extends GlassBackdropEffect {
  final double saturation;
  const VibrancyEffect({this.saturation = 1.5});
}

class GlassBackdropConfig {
  final List<GlassBackdropEffect> effects;
  final Color? tint;
  final Color? surfaceColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final List<BoxShadow>? innerShadows;
  final bool clipToBounds;

  const GlassBackdropConfig({
    this.effects = const [],
    this.tint,
    this.surfaceColor,
    this.borderRadius,
    this.shadows,
    this.innerShadows,
    this.clipToBounds = true,
  });

  double get blurRadius {
    for (final e in effects) {
      if (e is BlurEffect) return e.radius;
    }
    return 0.0;
  }

  ({double height, double amount, bool aberration})? get lensParams {
    for (final e in effects) {
      if (e is LensEffect) {
        return (height: e.refractionHeight, amount: e.refractionAmount, aberration: e.chromaticAberration);
      }
    }
    return null;
  }

  double get vibrancySaturation {
    for (final e in effects) {
      if (e is VibrancyEffect) return e.saturation;
    }
    return 1.0;
  }
}

class GlassBackdrop extends StatelessWidget {
  final Widget child;
  final GlassBackdropConfig config;

  const GlassBackdrop({
    super.key,
    required this.child,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (!Pref.useLiquidGlass) return child;

    Widget result = child;
    final blurRadius = config.blurRadius;
    final lens = config.lensParams;
    final vibrancy = config.vibrancySaturation;

    if (vibrancy != 1.0) {
      result = _VibrancyFilter(saturation: vibrancy, child: result);
    }

    if (lens != null && lens.amount > 0 && lens.height > 0) {
      result = _LensLayer(
        refractionHeight: lens.height,
        refractionAmount: lens.amount,
        chromaticAberration: lens.aberration,
        child: result,
      );
    }

    if (blurRadius > 0) {
      result = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: result,
        ),
      );
    }

    if (config.surfaceColor != null || config.tint != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          color: config.surfaceColor,
          borderRadius: config.borderRadius,
        ),
        child: config.tint != null
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(config.tint!, BlendMode.hue),
                child: Opacity(opacity: 0.75, child: result),
              )
            : result,
      );
    }

    if (config.shadows != null && config.shadows!.isNotEmpty) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: config.borderRadius,
          boxShadow: config.shadows,
        ),
        child: result,
      );
    }

    if (config.clipToBounds && config.borderRadius != null) {
      result = ClipRRect(borderRadius: config.borderRadius!, child: result);
    }

    return result;
  }
}

class _VibrancyFilter extends StatelessWidget {
  final double saturation;
  final Widget child;
  const _VibrancyFilter({required this.saturation, required this.child});

  static ColorFilter _makeFilter(double sat) {
    final invSat = 1.0 - sat;
    const r = 0.213;
    const g = 0.715;
    const b = 0.072;

    final cr = r * invSat;
    final cg = g * invSat;
    final cb = b * invSat;
    final cs = sat;

    return ColorFilter.matrix(<double>[
      cr + cs, cg, cb, 0, 0,
      cr, cg + cs, cb, 0, 0,
      cr, cg, cb + cs, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(colorFilter: _makeFilter(saturation), child: child);
  }
}

class _LensLayer extends StatelessWidget {
  final double refractionHeight;
  final double refractionAmount;
  final bool chromaticAberration;
  final Widget child;
  const _LensLayer({
    required this.refractionHeight,
    required this.refractionAmount,
    required this.chromaticAberration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 + (refractionAmount / 100.0).clamp(0.0, 0.05);
    Widget result = Transform.scale(scale: scale, alignment: Alignment.center, child: child);
    if (chromaticAberration) {
      result = _ChromaticAberrationFilter(
        intensity: (refractionAmount / 50.0).clamp(0.0, 1.0),
        child: result,
      );
    }
    return ClipRect(child: result);
  }
}

class _ChromaticAberrationFilter extends StatelessWidget {
  final double intensity;
  final Widget child;
  const _ChromaticAberrationFilter({required this.intensity, required this.child});

  @override
  Widget build(BuildContext context) {
    if (intensity <= 0) return child;
    return CustomPaint(
      foregroundPainter: _ChromaticPainter(intensity: intensity),
      child: child,
    );
  }
}

class _ChromaticPainter extends CustomPainter {
  final double intensity;
  _ChromaticPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = intensity * 3.0;
    final rect = Offset.zero & size;
    paint.color = const Color(0x08FF0000);
    canvas.drawRect(rect.deflate(intensity * 2), paint);
    paint.color = const Color(0x080000FF);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ChromaticPainter old) => old.intensity != intensity;
}
