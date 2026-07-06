import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liqliquid/utils/storage_pref.dart';

class ComBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final double width;
  final double height;
  final String? tooltip;

  const ComBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.width = 34,
    this.height = 34,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
<<<<<<< HEAD
    if (Pref.useLiquidGlass && onTap != null) {
=======
    if (Pref.useLiquidGlass) {
>>>>>>> c606655405a8987367046edb5af1fc820329d114
      child = GlassButton(
        useOwnLayer: true,
        quality: GlassQuality.premium,
        icon: icon,
<<<<<<< HEAD
        onTap: onTap!,
=======
        onTap: onTap,
        onLongPress: onLongPress,
>>>>>>> c606655405a8987367046edb5af1fc820329d114
        width: width,
        height: height,
      );
    } else {
      child = SizedBox(
        width: width,
        height: height,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          onSecondaryTap: onSecondaryTap,
          behavior: HitTestBehavior.opaque,
          child: icon,
        ),
      );
    }
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: child);
    }
    return child;
  }
}
