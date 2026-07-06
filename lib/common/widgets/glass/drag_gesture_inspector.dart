import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Port of KMP DragGestureInspector.
///
/// Provides a flexible drag gesture detector that tracks individual pointer
/// events with onDragStart/onDrag/onDragEnd/onDragCancel callbacks,
/// similar to KMP''s `inspectDragGestures`.
class DragGestureInspector extends StatefulWidget {
  final Widget child;
  final void Function(Offset position)? onDragStart;
  final void Function(Size size, Offset dragAmount)? onDrag;
  final void Function()? onDragEnd;
  final void Function()? onDragCancel;

  const DragGestureInspector({
    super.key,
    required this.child,
    this.onDragStart,
    this.onDrag,
    this.onDragEnd,
    this.onDragCancel,
  });

  @override
  State<DragGestureInspector> createState() => _DragGestureInspectorState();
}

class _DragGestureInspectorState extends State<DragGestureInspector> {
  Size? _widgetSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _widgetSize = renderBox.size;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _FlexibleDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_FlexibleDragGestureRecognizer>(
          _FlexibleDragGestureRecognizer.new,
          (recognizer) {
            recognizer.onDragStart = (pos) => widget.onDragStart?.call(pos);
            recognizer.onDragUpdate = (delta) {
              widget.onDrag?.call(_widgetSize ?? Size.zero, delta);
            };
            recognizer.onDragEnd = () => widget.onDragEnd?.call();
            recognizer.onDragCancel = () => widget.onDragCancel?.call();
          },
        ),
      },
      child: widget.child,
    );
  }
}

/// A gesture recognizer that provides granular drag callbacks
/// (start, update, end, cancel) similar to KMPs inspectDragGestures.
class _FlexibleDragGestureRecognizer extends OneSequenceGestureRecognizer {
  VoidCallback? onDragEnd;
  VoidCallback? onDragCancel;
  void Function(Offset)? onDragStart;
  void Function(Offset)? onDragUpdate;

  Offset? _initialPosition;

  @override
  String get debugDescription => 'flexible drag';

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    _initialPosition = event.localPosition;
    onDragStart?.call(event.localPosition);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      final delta = event.localPosition - (_initialPosition ?? event.localPosition);
      onDragUpdate?.call(delta);
    } else if (event is PointerUpEvent) {
      onDragEnd?.call();
      stopTrackingPointer(event.pointer);
    } else if (event is PointerCancelEvent) {
      onDragCancel?.call();
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
