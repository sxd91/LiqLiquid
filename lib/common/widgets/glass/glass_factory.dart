import 'package:flutter/material.dart';
import 'package:liqliquid/common/widgets/glass/glass_backdrop.dart';
import 'package:liqliquid/utils/storage_pref.dart';

/// Global glass parameter factory - replaces GlassFactory that used LiquidGlassSettings.
///
/// All glass controls source their parameters from this factory,
/// which reads from user preferences (Pref).
abstract final class GlassFactory {
  /// Standard glass backdrop config.
  static GlassBackdropConfig standardGlass(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? cs.primaryContainer.withValues(alpha: Pref.glassOpacity * 0.8)
        : cs.surfaceContainerHighest.withValues(alpha: Pref.glassOpacity);

    return GlassBackdropConfig(
      effects: [
        BlurEffect(radius: Pref.glassBlur),
        LensEffect(
          refractionHeight: 12,
          refractionAmount: Pref.glassRefraction * 10,
          chromaticAberration: Pref.glassChromatic > 0.3,
        ),
        const VibrancyEffect(saturation: 1.5),
      ],
      surfaceColor: baseColor,
      borderRadius: BorderRadius.circular(16),
    );
  }

  /// Transparent glass (zero opacity, pure refraction + dispersion).
  static GlassBackdropConfig transparentGlass() {
    return GlassBackdropConfig(
      effects: [
        LensEffect(
          refractionHeight: 2,
          refractionAmount: Pref.glassRefraction * 15,
          chromaticAberration: true,
        ),
      ],
      surfaceColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
    );
  }

  /// Bottom bar glass backdrop config.
  static GlassBackdropConfig bottomBarGlass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassBackdropConfig(
      effects: [
        VibrancyEffect(saturation: Pref.bottomBarSaturation),
        BlurEffect(radius: Pref.bottomBarBlur),
        LensEffect(
          refractionHeight: Pref.bottomBarThickness,
          refractionAmount: Pref.bottomBarRefractiveIndex * 10,
          chromaticAberration: Pref.bottomBarChromaticAberration > 0.0,
        ),
      ],
      surfaceColor:
          Pref.bottomBarGlassColor(isDark ? Brightness.dark : Brightness.light),
      borderRadius: BorderRadius.circular(28),
    );
  }

  /// Button backdrop config.
  static GlassBackdropConfig buttonGlass(BuildContext context) {
return GlassBackdropConfig(
      effects: [
        const VibrancyEffect(),
        const BlurEffect(radius: 2),
        const LensEffect(
          refractionHeight: 12,
          refractionAmount: 24,
          chromaticAberration: true,
        ),
      ],
      borderRadius: BorderRadius.circular(24),
    );
  }
}
