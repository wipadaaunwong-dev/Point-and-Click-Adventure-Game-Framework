import 'package:flame/components.dart';
import 'package:flame/events.dart';

class Hotspot extends PositionComponent with TapCallbacks {
  final String id;
  final String name;
  final Function(Hotspot) onTapAction;

  Hotspot({
    required this.id,
    required this.name,
    required Vector2 position,
    required Vector2 size,
    required this.onTapAction,
  }) : super(position: position, size: size);

  @override
  void onTapDown(TapDownEvent event) {
    onTapAction(this);
    super.onTapDown(event);
  }
}