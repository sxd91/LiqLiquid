import 'package:flutter/material.dart';
import 'package:liqliquid/common/widgets/glass/glass_backdrop.dart';
import 'package:liqliquid/common/widgets/glass/interactive_highlight.dart';
import 'package:liqliquid/utils/storage_pref.dart';

/// Port of KMP LiquidToggle.
///
/// A glass toggle switch with:
/// - Track backdrop (accent color on selected)
/// - Draggable thumb with GlassBackdrop (lens deepens on press)
/// - Snap-to 0/1 on release
class LiquidGlassToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? accentColor;
  final Color? trackColor;
  final double width;
  final double height;
  final double thumbSize;
  final GlassBackdropConfig? thumbConfig;

  const LiquidGlassToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.accentColor,
    this.trackColor,
    this.width = 64,
    this.height = 28,
    this.thumbSize = 24,
    this.thumbConfig,
  });

  @override
  State<LiquidGlassToggle> createState() => _LiquidGlassToggleState();
}

class _LiquidGlassToggleState extends State<LiquidGlassToggle> {
  late double _fraction;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _fraction = widget.value ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(LiquidGlassToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.value != widget.value) {
      _fraction = widget.value ? 1.0 : 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = widget.accentColor ??
        (isDark ? const Color(0xFF30D158) : const Color(0xFF34C759));
    final track = widget.trackColor ??
        (isDark
            ? const Color(0x5C787880)
            : const Color(0x33787878));

    if (!Pref.useLiquidGlass) {
      return Switch(
        value: widget.value,
        activeColor: accent,
        inactiveTrackColor: track,
        onChanged: widget.onChanged,
      );
    }

    final padding = 2.0;
    final dragWidth = widget.width - widget.thumbSize - padding * 2;
    final isPressed = _isDragging;

    return GestureDetector(
      onTap: () {
        final newValue = !widget.value;
        setState(() => _fraction = newValue ? 1.0 : 0.0);
        widget.onChanged?.call(newValue);
      },
      onPanStart: (_) => setState(() => _isDragging = true),
      onPanUpdate: (details) {
        setState(() {
          _fraction = (_fraction + details.delta.dx / (widget.width * 1.5))
              .clamp(0.0, 1.0);
        });
      },
      onPanEnd: (details) {
        setState(() {
          _fraction = _fraction >= 0.5 ? 1.0 : 0.0;
          _isDragging = false;
        });
        final newValue = _fraction >= 0.5;
        widget.onChanged?.call(newValue);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          color: isPressed
              ? Color.lerp(track, accent, _fraction)
              : (widget.value ? accent : track),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              left: padding + dragWidth * _fraction,
              top: (widget.height - widget.thumbSize) / 2,
              child: InteractiveHighlight(
                child: GlassBackdrop(
                  config: widget.thumbConfig ??
                      GlassBackdropConfig(
                        effects: [
                          BlurEffect(radius: isPressed ? 0.0 : 8.0),
                          LensEffect(
                            refractionHeight: isPressed ? 10.0 : 5.0,
                            refractionAmount: isPressed ? 10.0 : 5.0,
                            chromaticAberration: true,
                          ),
                        ],
                        surfaceColor: isPressed
                            ? null
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius:
                            BorderRadius.circular(widget.thumbSize / 2),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                  child: Container(
                    width: widget.thumbSize,
                    height: widget.thumbSize,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(widget.thumbSize / 2),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
