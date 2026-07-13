import 'package:flutter/material.dart';

import '../physics/blob_physics.dart';
import 'blob_path_builder.dart';

/// Paints a liquid/metaball blob indicator.
///
/// This painter is intentionally independent from PageView.
/// It only consumes a logical position (`page`) and physics values.
///
/// It can be reused for:
/// - page indicators
/// - tab indicators
/// - draggable bubbles
/// - game UI elements
class GooeyBlobPainter extends CustomPainter {
  GooeyBlobPainter({
    required this.page,
    required this.count,
    required this.radius,
    required this.spacing,
    required this.activeColor,
    required this.inactiveColor,
    required this.physics,
    this.velocity = 0,
    this.axis = Axis.horizontal,
    this.maxBlobDistance = 120,
  });

  /// Current fractional indicator position.
  ///
  /// Example:
  ///
  /// 0.0 -> first page
  /// 0.5 -> halfway between first and second
  /// 1.0 -> second page
  final double page;

  final int count;

  final double radius;

  final double spacing;

  final Color activeColor;

  final Color inactiveColor;

  final BlobPhysics physics;

  /// Page velocity used for inertia deformation.
  final double velocity;

  final Axis axis;

  /// Maximum distance before the metaball connection disappears.
  final double maxBlobDistance;

  final BlobPathBuilder _pathBuilder = const BlobPathBuilder();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    //
    // Draw inactive indicators
    //
    _drawInactiveDots(
      canvas,
      paint,
    );

    //
    // Determine active transition
    //
    final current = page.floor().clamp(
      0,
      count - 1,
    );

    final next = (current + 1).clamp(
      0,
      count - 1,
    );

    final progress = (page - current).clamp(
      0.0,
      1.0,
    );

    final first = _position(current);

    final second = _position(next);

    //
    // Update liquid physics
    //
    final direction = second - first;

    final distance = direction.distance;

    if (distance > 0) {
      final normalized = direction / distance;

      physics.update(
        targetStretch: progress * (1 - progress) * 2 + velocity.abs() * .15,

        targetTilt: velocity * .04,

        targetTrail: normalized * (-velocity * radius * .25),

        velocity: velocity,
      );
    }

    if (current == next) {
      _drawCircle(
        canvas,
        paint,
        first,
        radius,
        activeColor,
      );

      return;
    }

    _drawBlobTransition(
      canvas,
      paint,
      first,
      second,
      progress,
    );
  }

  void _drawInactiveDots(
    Canvas canvas,
    Paint paint,
  ) {
    paint.color = inactiveColor;

    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        _position(i),
        radius,
        paint,
      );
    }
  }

  Offset _position(
    int index,
  ) {
    final step = radius * 2 + spacing;

    if (axis == Axis.horizontal) {
      return Offset(
        radius + index * step,
        radius,
      );
    }

    return Offset(
      radius,
      radius + index * step,
    );
  }

  void _drawCircle(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
    Color color,
  ) {
    paint.color = color;

    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  void _drawBlobTransition(
    Canvas canvas,
    Paint paint,
    Offset first,
    Offset second,
    double progress,
  ) {
    //
    // Interpolated active blob position.
    //
    // The front blob moves toward the next position,
    // while the physics trail keeps the rear stretched.
    //
    final movement = second - first;

    final distance = movement.distance;

    if (distance == 0) {
      _drawCircle(
        canvas,
        paint,
        first,
        radius,
        activeColor,
      );

      return;
    }

    final direction = movement / distance;

    final trail = physics.trail;

    final firstCenter =
        first +
        Offset(
          movement.dx * progress,
          movement.dy * progress,
        ) +
        trail;

    final secondCenter = second + trail * .15;

    //
    // Liquid mass deformation.
    //
    // The leading blob grows,
    // the trailing blob compresses.
    //
    final velocityScale = velocity.abs().clamp(
      0.0,
      3.0,
    );

    final firstRadius =
        radius * (physics.leftRadiusScale - velocityScale * .03);

    final secondRadius =
        radius * (physics.rightRadiusScale + velocityScale * .05);

    //
    // Build gooey bridge.
    //
    final path = _pathBuilder.build(
      firstCenter: firstCenter,

      secondCenter: secondCenter,

      firstRadius: firstRadius,

      secondRadius: secondRadius,

      maxDistance: maxBlobDistance,
    );

    paint.color = activeColor;

    //
    // Draw bridge first.
    //
    // The circles cover the joins,
    // removing any visible seams.
    //
    if (path != null) {
      canvas.drawPath(
        path,
        paint,
      );
    }

    //
    // Draw metaball bodies.
    //
    canvas.drawCircle(
      firstCenter,
      firstRadius,
      paint,
    );

    canvas.drawCircle(
      secondCenter,
      secondRadius,
      paint,
    );

    //
    // Optional leading highlight effect.
    //
    // Makes the front blob feel heavier.
    //
    _drawVelocityTail(
      canvas,
      paint,
      firstCenter,
      direction,
    );
  }

  void _drawVelocityTail(
    Canvas canvas,
    Paint paint,
    Offset center,
    Offset direction,
  ) {
    final strength = velocity.abs().clamp(
      0.0,
      4.0,
    );

    if (strength < .05) {
      return;
    }

    final tailRadius = radius * strength * .04;

    final tailOffset = direction * -radius * strength * .12;

    paint.color = activeColor.withOpacity(
      .8,
    );

    canvas.drawCircle(
      center + tailOffset,
      tailRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant GooeyBlobPainter oldDelegate,
  ) {
    return oldDelegate.page != page ||
        oldDelegate.velocity != velocity ||
        oldDelegate.count != count;
  }
}
