import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

/// Debouncer to limit the frequency of polygon checks
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

/// Checks whether point [p] is within the specified closed [polygon]
///
/// Uses the even-odd algorithm and requires closed loop polygons,
/// i.e. `polygon.first == polygon.last`.
bool isPointInPolygon(math.Point p, List<Offset> polygon) {
  // Validate polygon length and closure
  if (polygon.length < 3 || polygon.first != polygon.last) {
    print("Invalid polygon: Must have at least three points and be closed.");
    return false;
  }

  final double px = p.x.toDouble();
  final double py = p.y.toDouble();
  bool isInPolygon = false;

  for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final double poIx = polygon[i].dx;
    final double poIy = polygon[i].dy;
    final double poJx = polygon[j].dx;
    final double poJy = polygon[j].dy;

    if ((((poIy <= py) && (py < poJy)) || ((poJy <= py) && (py < poIy))) &&
        (px < (poJx - poIx) * (py - poIy) / (poJy - poIy) + poIx)) {
      isInPolygon = !isInPolygon;
    }
  }
  return isInPolygon;
}

/// Sample usage with Debouncer for better performance in high-frequency updates
void main() {
  final Debouncer debouncer = Debouncer(milliseconds: 200);

  // Define a closed polygon
  final List<Offset> polygon = [
    Offset(0, 0),
    Offset(5, 0),
    Offset(5, 5),
    Offset(0, 5),
    Offset(0, 0),
  ];

  // Define a point to check
  final math.Point pointToCheck = math.Point(3, 3);

  // Use debouncer to limit frequency of polygon checks
  debouncer.run(() {
    final isInside = isPointInPolygon(pointToCheck, polygon);
    print("Point is ${isInside ? 'inside' : 'outside'} the polygon.");
  });
}