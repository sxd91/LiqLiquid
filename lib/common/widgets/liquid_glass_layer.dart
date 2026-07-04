// Liquid glass layer wrapper — enables glass effects across the app.
// Wraps the root widget with LiquidGlassLayer so all glass components
// share a consistent rendering context.

import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass_plus.dart';

class LiquidGlassRootLayer extends StatelessWidget {
  const LiquidGlassRootLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: const LiquidGlassSettings(
        thickness: 35,
        blur: 1.0,
        glassColor: Color.fromARGB(100, 255, 255, 255),
      ),
      child: child,
    );
  }
}
