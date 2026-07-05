import 'package:flutter/material.dart';
import 'package:liqliquid/utils/storage_pref.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

/// Liquid glass damped scroll behavior
class LiquidGlassScrollBehavior extends MaterialScrollBehavior {
  const LiquidGlassScrollBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Pref.useLiquidGlass) {
      return const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast)
          .applyTo(super.getScrollPhysics(context));
    }
    return super.getScrollPhysics(context);
  }
}
