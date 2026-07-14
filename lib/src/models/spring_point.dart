import 'dart:ui';

/// Represents a single point in a spring animation, defined by its
/// center position and radius.
class SpringPoint {
  /// Creates a [SpringPoint] with the given [center] and [radius].
  const SpringPoint({
    required this.center,
    required this.radius,
  });

  /// The center position of this point in 2D space.
  final Offset center;

  /// The radius of this point, used to determine its visual size.
  final double radius;
}
