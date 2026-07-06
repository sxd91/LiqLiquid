import 'package:flutter/material.dart';
import 'package:liqliquid/utils/storage_pref.dart';

class AddedSeriesHomeCustomAnimationCurve2 extends Curve {
  const AddedSeriesHomeCustomAnimationCurve2();
  static const _frames = <double>[
    90, 95, 115, 85, 110, 85, 94, 115, 107, 121, 90, 119,
    105, 105, 95, 60, 115, 85, 0, 0, 0, 0,
  ];
  static const _max = 121.0;
  static const _n = 22;

  @override
  double transformInternal(double t) {
    if (t <= 0) return _frames[0] / _max;
    if (t >= 1) return _frames[_n - 1] / _max;
    final pos = t * (_n - 1);
    final i = pos.floor();
    final frac = pos - i;
    final a = _frames[i];
    final b = _frames[i < _n - 1 ? i + 1 : i];
    return (a + (b - a) * frac) / _max;
  }
}

Offset? heroTapOrigin;

class HeroPageWrapper extends StatefulWidget {
  final Widget child;
  final Offset? origin;
  const HeroPageWrapper({super.key, required this.child, this.origin});

  @override
  State<HeroPageWrapper> createState() => _HeroPageWrapperState();
}

class _HeroPageWrapperState extends State<HeroPageWrapper> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Offset _origin;

  @override
  void initState() {
    super.initState();
    _origin = widget.origin ?? Offset.zero;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: Pref.heroTransitionDuration),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: const AddedSeriesHomeCustomAnimationCurve2(),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pop() {
    if (_controller.isAnimating) return;
    _controller.reverse().then((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Pref.heroTransitionEnabled) return widget.child;
    final v = _animation.value;
    if (v >= 1.0) return widget.child;

    final size = MediaQuery.of(context).size;
    final ox = _origin.dx.clamp(0, size.width);
    final oy = _origin.dy.clamp(0, size.height);
    final startW = size.width * 0.2;
    final startH = size.height * 0.15;
    final cw = startW + (size.width - startW) * v;
    final ch = startH + (size.height - startH) * v;
    final cx = ox - cw / 2 + (size.width / 2 - ox) * (1 - v);
    final cy = oy - ch / 2 + (size.height / 2 - oy) * (1 - v);
    final r = BorderRadius.circular(16.0 * (1 - v));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _pop(); },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _pop,
              child: Container(color: Colors.black.withValues(alpha: v * 0.6)),
            ),
          ),
          Positioned(
            left: cx, top: cy, width: cw, height: ch,
            child: ClipRRect(
              borderRadius: r,
              child: IgnorePointer(
                ignoring: v < 0.3,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
