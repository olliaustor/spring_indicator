import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spring_indicator/src/models/spring_point.dart';

class SpringPainter extends CustomPainter {
  SpringPainter({
    required this.page,
    required this.itemCount,
    required this.radiusMax,
    required this.radiusMin,
    required this.spacing,
    required this.acceleration,
    required this.headMoveOffset,
    required this.activeColor,
    required this.activeColors,
    required this.inactiveColor,
    required this.axis,
  });

  final double page;
  final int itemCount;

  final double radiusMax;
  final double radiusMin;
  final double spacing;

  final double acceleration;

  /// Same meaning as Android.
  ///
  /// head starts moving immediately.
  /// foot starts moving later.
  final double headMoveOffset;

  final Color activeColor;
  final List<Color>? activeColors;
  final Color inactiveColor;

  final Axis axis;

  double get footMoveOffset => 1 - headMoveOffset;

  double get radiusOffset => radiusMax - radiusMin;

  @override
  void paint(Canvas canvas, Size size) {
    final inactivePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = inactiveColor;

    // Draw inactive indicators.
    for (var i = 0; i < itemCount; i++) {
      canvas.drawCircle(_position(i), radiusMin, inactivePaint);
    }

    final current = page.floor().clamp(0, itemCount - 1);

    if (current == itemCount - 1) {
      final activePaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = activeColors == null ? activeColor : activeColors!.last;
      canvas.drawCircle(
        _position(current),
        radiusMax,
        activePaint,
      );
      return;
    }

    final offset = page - current;

    final head = _buildHead(current, offset);
    final foot = _buildFoot(current, offset);

    debugPrint(page.toString());

    final activePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = activeColors == null
          ? activeColor
          : Color.lerp(
              activeColors == null ? activeColor : activeColors![current],
              activeColors == null ? activeColor : activeColors![current + 1],
              offset,
            )!;

    final path = _makePath(head, foot);

    canvas.drawPath(path, activePaint);

    canvas.drawCircle(
      head.center,
      head.radius,
      activePaint,
    );

    canvas.drawCircle(
      foot.center,
      foot.radius,
      activePaint,
    );
  }

  SpringPoint _buildHead(
    int page,
    double offset,
  ) {
    final start = _position(page);
    final end = _position(page + 1);

    double t = 1.0;

    if (offset < headMoveOffset) {
      t = _atanInterpolation(offset / headMoveOffset);
    }

    final center = Offset.lerp(
      start,
      end,
      t,
    )!;

    double radius;

    if (offset < .5) {
      radius = radiusMin;
    } else {
      radius = radiusMin + ((offset - .5) / .5) * radiusOffset;
    }

    return SpringPoint(
      center: center,
      radius: radius,
    );
  }

  SpringPoint _buildFoot(
    int page,
    double offset,
  ) {
    final start = _position(page);
    final end = _position(page + 1);

    double t = 0;

    if (offset > footMoveOffset) {
      t = _atanInterpolation(
        (offset - footMoveOffset) / (1 - footMoveOffset),
      );
    }

    final center = Offset.lerp(
      start,
      end,
      t,
    )!;

    double radius;

    if (offset < .5) {
      radius = radiusMax - (offset / .5) * radiusOffset;
    } else {
      radius = radiusMin;
    }

    return SpringPoint(
      center: center,
      radius: radius,
    );
  }

  double _atanInterpolation(double t) {
    return (math.atan(t * acceleration * 2 - acceleration) +
            math.atan(acceleration)) /
        (2 * math.atan(acceleration));
  }

  Offset _position(int index) {
    final step = radiusMax * 2 + spacing;

    if (axis == Axis.horizontal) {
      return Offset(
        radiusMax + index * step,
        radiusMax,
      );
    }

    return Offset(
      radiusMax,
      radiusMax + index * step,
    );
  }

  Path _makePath(
    SpringPoint head,
    SpringPoint foot,
  ) {
    final dx = foot.center.dx - head.center.dx;
    final dy = foot.center.dy - head.center.dy;

    final angle = math.atan2(dy, dx);

    final headOffset = Offset(
      math.sin(angle) * head.radius,
      -math.cos(angle) * head.radius,
    );

    final footOffset = Offset(
      math.sin(angle) * foot.radius,
      -math.cos(angle) * foot.radius,
    );

    final p1 = head.center - headOffset;
    final p2 = head.center + headOffset;

    final p3 = foot.center - footOffset;
    final p4 = foot.center + footOffset;

    final anchor = Offset.lerp(
      head.center,
      foot.center,
      .5,
    )!;

    return Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(
        anchor.dx,
        anchor.dy,
        p3.dx,
        p3.dy,
      )
      ..lineTo(p4.dx, p4.dy)
      ..quadraticBezierTo(
        anchor.dx,
        anchor.dy,
        p2.dx,
        p2.dy,
      )
      ..close();
  }

  @override
  bool shouldRepaint(SpringPainter oldDelegate) {
    return oldDelegate.page != page ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.radiusMax != radiusMax ||
        oldDelegate.radiusMin != radiusMin ||
        oldDelegate.spacing != spacing ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.activeColors != activeColors ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.acceleration != acceleration ||
        oldDelegate.headMoveOffset != headMoveOffset ||
        oldDelegate.axis != axis;
  }
}
