// LiquidStretch wrapper — adds press-and-drag deformation to interactive elements.
// Intercepts GestureDetector events to drive LiquidStretch effects.

import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass_plus.dart';

class LiquidStretchable extends StatefulWidget {
  const LiquidStretchable({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<LiquidStretchable> createState() => _LiquidStretchableState();
}

class _LiquidStretchableState extends State<LiquidStretchable> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled) setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (widget.enabled) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: LiquidStretch(
        pressed: _isPressed,
        child: widget.child,
      ),
    );
  }
}
