import 'package:flutter/material.dart';
import 'package:liqliquid/common/widgets/glass/glass_backdrop.dart';
import 'package:liqliquid/common/widgets/glass/interactive_highlight.dart';
import 'package:liqliquid/utils/storage_pref.dart';

/// Port of KMP LiquidSlider.
///
/// A glass slider with:
/// - Track backdrop with progress bar
/// - Draggable thumb with GlassBackdrop (lens deepens on press)
/// - Spring-physics based drag animation
class LiquidGlassSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final Color? accentColor;
  final Color? trackColor;
  final double thumbSize;
  final double trackHeight;
  final GlassBackdropConfig? thumbConfig;

  const LiquidGlassSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.accentColor,
    this.trackColor,
    this.thumbSize = 24,
    this.trackHeight = 6,
    this.thumbConfig,
  });

  @override
  State<LiquidGlassSlider> createState() => _LiquidGlassSliderState();
}

class _LiquidGlassSliderState extends State<LiquidGlassSlider> {
  late double _currentValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(LiquidGlassSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  double _fraction(double value) =>
      ((value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = widget.accentColor ??
        (isDark ? const Color(0xFF0091FF) : const Color(0xFF0088FF));
    final track = widget.trackColor ??
        (isDark
            ? const Color(0x5C787880)
            : const Color(0x33787878));

    if (!Pref.useLiquidGlass) {
      return Slider(
        value: _currentValue,
        min: widget.min,
        max: widget.max,
        activeColor: accent,
        inactiveColor: track,
        onChanged: (v) {
          _currentValue = v;
          widget.onChanged?.call(v);
        },
        onChangeEnd: widget.onChangeEnd,
      );
    }

    final fraction = _fraction(_currentValue);
    final isPressed = _isDragging;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final thumbHalf = widget.thumbSize / 2;

        return GestureDetector(
          onTapDown: (details) {
            final localX = details.localPosition.dx;
            final newFraction = (localX - thumbHalf) /
                (trackWidth - widget.thumbSize);
            final newValue = widget.min +
                newFraction.clamp(0.0, 1.0) *
                    (widget.max - widget.min);
            setState(() => _currentValue = newValue);
            widget.onChanged?.call(newValue);
          },
          onPanStart: (_) => setState(() => _isDragging = true),
          onPanUpdate: (details) {
            final newFraction =
                (_fraction(_currentValue) * trackWidth + details.delta.dx) /
                    trackWidth;
            final newValue = widget.min +
                newFraction.clamp(0.0, 1.0) *
                    (widget.max - widget.min);
            setState(() => _currentValue = newValue);
            widget.onChanged?.call(newValue);
          },
          onPanEnd: (details) {
            setState(() => _isDragging = false);
            widget.onChangeEnd?.call(_currentValue);
          },
          child: Container(
            height: widget.thumbSize + 16,
            padding: EdgeInsets.symmetric(
              vertical: (widget.thumbSize - widget.trackHeight) / 2 + 8,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Track
                Positioned(
                  left: 0,
                  right: 0,
                  top: (widget.thumbSize + 16 - widget.trackHeight) / 2,
                  child: Container(
                    height: widget.trackHeight,
                    decoration: BoxDecoration(
                      color: track,
                      borderRadius: BorderRadius.circular(
                        widget.trackHeight / 2,
                      ),
                    ),
                  ),
                ),
                // Progress bar
                Positioned(
                  left: 0,
                  top: (widget.thumbSize + 16 - widget.trackHeight) / 2,
                  width: trackWidth * fraction,
                  child: Container(
                    height: widget.trackHeight,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(
                        widget.trackHeight / 2,
                      ),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: (trackWidth - widget.thumbSize) * fraction,
                  top: 8,
                  child: InteractiveHighlight(
                    child: GlassBackdrop(
                      config: widget.thumbConfig ??
                          GlassBackdropConfig(
                            effects: [
                              BlurEffect(
                                radius: isPressed ? 0.0 : 8.0,
                              ),
                              LensEffect(
                                refractionHeight: isPressed ? 14.0 : 10.0,
                                refractionAmount: isPressed ? 14.0 : 10.0,
                                chromaticAberration: true,
                              ),
                            ],
                            surfaceColor:
                                isPressed ? null : Colors.white.withValues(alpha: 0.8),
                            borderRadius:
                                BorderRadius.circular(widget.thumbSize / 2),
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: widget.thumbSize,
                        height: widget.thumbSize,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.thumbSize / 2),
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
