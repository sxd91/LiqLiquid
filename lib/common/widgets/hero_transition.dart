import 'package:flutter/material.dart';
import 'package:liqliquid/utils/storage_pref.dart';

/// 22帧关键帧曲线，Y轴最大121，归一化输出0~1
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

/// 全局tap位置，用于Hero展开效果
Offset? heroTapOrigin;

/// Hero页面包裹器 — 页面进入时从tap位置卡片展开，退出时反向收起
class HeroPageWrapper extends StatefulWidget {
  final Widget child;
  const HeroPageWrapper({super.key, required this.child});

  @override
  State<HeroPageWrapper> createState() => _HeroPageWrapperState();
}

class _HeroPageWrapperState extends State<HeroPageWrapper> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset? _origin;

  @override
  void initState() {
    super.initState();
    _origin = heroTapOrigin;
    heroTapOrigin = null;
    final duration = Duration(milliseconds: Pref.heroTransitionDuration);
    _controller = AnimationController(vsync: this, duration: duration);
    _animation = CurvedAnimation(parent: _controller, curve: const AddedSeriesHomeCustomAnimationCurve2());
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pop();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final v = _animation.value;
          final size = MediaQuery.of(context).size;
          final ox = _origin?.dx ?? size.width / 2;
          final oy = _origin?.dy ?? size.height / 2;
          final startW = size.width * 0.3;
          final startH = size.height * 0.2;
          final cw = startW + (size.width - startW) * v;
          final ch = startH + (size.height - startH) * v;
          final cx = ox - cw / 2 + (size.width / 2 - ox) * (1 - v);
          final cy = oy - ch / 2 + (size.height / 2 - oy) * (1 - v);
          final r = 16.0 * (1 - v);

          return Stack(
            children: [
              // Full content (interactive)
              Opacity(opacity: v >= 0.5 ? 1.0 : 0.0, child: widget.child),
              // Animated card overlay
              if (v < 1.0)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _pop,
                    child: Container(color: Colors.black.withValues(alpha: (1 - v) * 0.5)),
                  ),
                ),
              if (v < 1.0)
                Positioned(
                  left: cx, top: cy, width: cw, height: ch,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r),
                    child: IgnorePointer(
                      ignoring: v < 0.5,
                      child: widget.child,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
