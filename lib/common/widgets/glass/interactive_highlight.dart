import 'package:flutter/material.dart';

/// Port of KMP InteractiveHighlight.
///
/// Renders a radial gradient highlight at the touch position when pressed,
/// using a smooth animation for press/release transitions.
class InteractiveHighlight extends StatefulWidget {
  final Widget child;
  final Color highlightColor;
  final double highlightRadius;
  final VoidCallback? onTap;

  const InteractiveHighlight({
    super.key,
    required this.child,
    this.highlightColor = const Color(0x26FFFFFF),
    this.highlightRadius = 100,
    this.onTap,
  });

  @override
  State<InteractiveHighlight> createState() => _InteractiveHighlightState();
}

class _InteractiveHighlightState extends State<InteractiveHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _position = details.localPosition;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          return CustomPaint(
            painter: _HighlightPainter(
              position: _position,
              progress: _progress.value,
              color: widget.highlightColor,
              radius: widget.highlightRadius,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  final Offset position;
  final double progress;
  final Color color;
  final double radius;

  _HighlightPainter({
    required this.position,
    required this.progress,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (position.dx / size.width) * 2 - 1,
          (position.dy / size.height) * 2 - 1,
        ),
        radius: 0.5,
        colors: [
          color.withValues(alpha: progress),
          color.withValues(alpha: progress * 0.5),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter old) =>
      old.position != position ||
      old.progress != progress ||
      old.color != color ||
      old.radius != radius;
}
