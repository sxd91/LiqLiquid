import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:liqliquid/utils/storage_pref.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior(this.dragDevices);

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  final Set<PointerDeviceKind> dragDevices;

/// 液态玻璃阻尼滚动行为
class LiquidGlassScrollBehavior extends MaterialScrollBehavior {
  const LiquidGlassScrollBehavior(super.dragDevices);

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return Pref.useLiquidGlass
        ? const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast)
            .applyTo(super.getScrollPhysics(context))
        : super.getScrollPhysics(context);
  }
}

}

const Set<PointerDeviceKind> desktopDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.unknown,
  PointerDeviceKind.mouse,
};
