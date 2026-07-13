import 'dart:math';
import 'dart:ui';

/// Builds a gooey metaball connection between two circles.
///
/// The algorithm is based on the classic metaball/blob technique:
/// two circles are connected by Bézier curves whose tangent points
/// rotate according to the direction between the circles.
///
/// The closer the circles are, the stronger the connection.
class BlobPathBuilder {
  const BlobPathBuilder();

  /// Creates a gooey blob path.
  ///
  /// Returns `null` when the circles are too far apart and should
  /// be rendered as separate circles.
  Path? build({
    required Offset firstCenter,
    required Offset secondCenter,
    required double firstRadius,
    required double secondRadius,
    double maxDistance = 120,
    double handleStrength = 0.45,
    double minConnection = 0.1,
  }) {
    final delta = secondCenter - firstCenter;

    final distance = delta.distance;

    if (distance == 0) {
      return null;
    }

    //
    // Too far apart -> no blob connection
    //
    if (distance > maxDistance) {
      return null;
    }

    final direction = delta / distance;

    final angle = atan2(
      direction.dy,
      direction.dx,
    );

    //
    // Connection strength
    //
    final connection = (1 - distance / maxDistance).clamp(
      minConnection,
      1.0,
    );

    //
    // Calculate tangent angle.
    //
    // This is the key part of the metaball effect.
    //
    final radiusDifference = (firstRadius - secondRadius) / distance;

    final tangentOffset = asin(
      radiusDifference.clamp(
        -0.85,
        0.85,
      ),
    );

    final topAngle1 = angle + tangentOffset;

    final bottomAngle1 = angle - tangentOffset;

    final topAngle2 = angle + pi - tangentOffset;

    final bottomAngle2 = angle + pi + tangentOffset;

    final p1 = _pointOnCircle(
      firstCenter,
      firstRadius,
      topAngle1,
    );

    final p2 = _pointOnCircle(
      secondCenter,
      secondRadius,
      topAngle2,
    );

    final p3 = _pointOnCircle(
      secondCenter,
      secondRadius,
      bottomAngle2,
    );

    final p4 = _pointOnCircle(
      firstCenter,
      firstRadius,
      bottomAngle1,
    );

    //
    // Bézier handle length.
    //
    // Smaller separation = softer blob.
    //
    final handle = distance * handleStrength * connection;

    final forward =
        Offset(
          cos(angle),
          sin(angle),
        ) *
        handle;

    final backward =
        Offset(
          cos(angle + pi),
          sin(angle + pi),
        ) *
        handle;

    final path = Path();

    path.moveTo(
      p1.dx,
      p1.dy,
    );

    //
    // Upper bridge
    //
    path.cubicTo(
      p1.dx + forward.dx,
      p1.dy + forward.dy,

      p2.dx + backward.dx,
      p2.dy + backward.dy,

      p2.dx,
      p2.dy,
    );

    //
    // Lower bridge
    //
    path.cubicTo(
      p3.dx + backward.dx,
      p3.dy + backward.dy,

      p4.dx + forward.dx,
      p4.dy + forward.dy,

      p4.dx,
      p4.dy,
    );

    path.close();

    return path;
  }

  Offset _pointOnCircle(
    Offset center,
    double radius,
    double angle,
  ) {
    return center +
        Offset(
              cos(angle),
              sin(angle),
            ) *
            radius;
  }
}
