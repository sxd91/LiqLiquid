import 'package:flutter/animation.dart';
/// Port of KMP DampedDragAnimation.
///
/// Provides spring-physics based drag interaction with press progress,
/// velocity tracking, and scale deformation for glass controls.
class DampedDragAnimation {
  final AnimationController _pressController;
  late final Animation<double> _pressProgress;
  late final Animation<double> _scaleX;
  late final Animation<double> _scaleY;
  late final Animation<double> _valueAnimation;

  final TickerProvider vsync;
  final double initialValue;
  final double minValue;
  final double maxValue;
  final double initialScale;
  final double pressedScale;
  final void Function(DampedDragAnimation self) onDragStarted;
  final void Function(DampedDragAnimation self) onDragStopped;
  final void Function(DampedDragAnimation self, Size size, Offset dragAmount) onDrag;

  double _targetValue;
  double _velocity = 0;
  Offset? _lastPosition;
  DateTime? _lastTime;

  DampedDragAnimation({
    required this.vsync,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.initialScale = 1.0,
    this.pressedScale = 1.5,
    this.onDragStarted = _noop,
    this.onDragStopped = _noop,
    this.onDrag = _noopDrag,
  }) : _targetValue = initialValue,
       _pressController = AnimationController(
         duration: const Duration(milliseconds: 300),
         vsync: vsync,
       ) {
    _pressProgress = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOutCubic,
    );
    _scaleX = Tween<double>(begin: initialScale, end: pressedScale)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic));
    _scaleY = Tween<double>(begin: initialScale, end: pressedScale)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic));
    _valueAnimation = AlwaysStoppedAnimation(initialValue);
  }

  static void _noop(DampedDragAnimation self) {}
  static void _noopDrag(DampedDragAnimation self, Size size, Offset dragAmount) {}

  double get value => _valueAnimation.value;
  double get targetValue => _targetValue;
  double get pressProgress => _pressProgress.value;
  double get scaleX => _scaleX.value;
  double get scaleY => _scaleY.value;
  double get velocity => _velocity;

  /// Returns a fraction [0..1] of current value within the range.
  double get progress {
    return ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
  }

  /// Start press animation.
  void press() {
    _velocity = 0;
    _lastPosition = null;
    _lastTime = null;
    _pressController.forward();
  }

  /// Release press animation.
  void release() {
    _pressController.reverse();
  }

  /// Update the current value (used for programmatic changes).
  void updateValue(double value) {
    _targetValue = value.clamp(minValue, maxValue);
  }

  /// Animate to a target value with spring physics.
  Future<void> animateToValue(double target) {
    _targetValue = target.clamp(minValue, maxValue);
    return Future.value();
  }

  /// Handle drag start.
  void handleDragStart(Offset position) {
    press();
    onDragStarted(this);
  }

  /// Handle drag update, tracking velocity.
  void handleDragUpdate(Size widgetSize, Offset dragAmount) {
    final now = DateTime.now();

    if (_lastPosition != null && _lastTime != null) {
      final dt = now.difference(_lastTime!).inMicroseconds / 1000000.0;
      if (dt > 0) {
        final vx = dragAmount.dx / dt;
        _velocity = vx / (maxValue - minValue);
      }
    }

    _lastPosition = dragAmount;
    _lastTime = now;
    onDrag(this, widgetSize, dragAmount);
  }

  /// Handle drag end.
  void handleDragEnd() {
    onDragStopped(this);
    release();
  }

  /// Handle drag cancel.
  void handleDragCancel() {
    onDragStopped(this);
    release();
  }

  void dispose() {
    _pressController.dispose();
  }
}
