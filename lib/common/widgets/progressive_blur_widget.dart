// Progressive blur overlay — applies a gradient blur from top (strong) to bottom (none).
// Used as a floating layer behind the search bar / top nav while scrolling.

import 'package:flutter/material.dart';
import 'package:progressive_blur/progressive_blur.dart';

class ProgressiveBlurOverlay extends StatelessWidget {
  const ProgressiveBlurOverlay({
    super.key,
    this.height = 120,
    this.blurStrength = 12.0,
    this.gradientStops = const [0.0, 0.4, 1.0],
    this.color = Colors.white,
    this.opacity = 0.6,
  });

  final double height;
  final double blurStrength;
  final List<double> gradientStops;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 0,
      bottom: null,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: height,
          child: LinearGradientBlur(
            stops: gradientStops,
            blur: List.generate(
              gradientStops.length,
              (i) => blurStrength * (1.0 - i / (gradientStops.length - 1)),
            ),
            gradientColors: List.generate(
              gradientStops.length,
              (i) => color.withValues(alpha: opacity),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
