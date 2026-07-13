import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spring_indicator/src/models/spring_point.dart';

/// A custom painter that renders a spring-like indicator animation.
///
/// This painter creates a smooth, spring-based visual effect that animates
/// between page indicators. The active indicator consists of a head circle,
/// a connecting path, and a foot circle that follows a spring-like motion
/// pattern as the page scrolls.
///
/// The animation smoothly transitions colors based on the scroll progress,
/// either using a single color or interpolating between multiple colors
/// for each indicator position.
class SpringPainter extends CustomPainter {
  /// Creates a SpringPainter with the required animation and styling parameters.
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

  /// The current page position in the scroll animation.
  ///
  /// Represents the fractional page offset (e.g., 1.5 means halfway between page 1 and 2).
  final double page;

  /// The total number of page indicators to display.
  final int itemCount;

  /// The maximum radius of the active indicator circle.
  final double radiusMax;

  /// The minimum radius of the inactive indicator circles and the base radius of the active indicator.
  final double radiusMin;

  /// The spacing between indicator circles.
  final double spacing;

  /// Controls the curve/acceleration of the spring animation using arctan interpolation.
  ///
  /// Higher values create a more pronounced easing curve.
  final double acceleration;

  /// The fraction of the scroll progress when the head starts moving.
  ///
  /// Same meaning as Android's spring indicator. For example, 0.3 means the head
  /// starts moving after 30% of the scroll progress, while the foot starts later.
  /// The foot follows with footMoveOffset = 1 - headMoveOffset.
  final double headMoveOffset;

  /// The color used for the active indicator when there's no color list.
  final Color activeColor;

  /// Optional list of colors, one for each indicator position.
  ///
  /// If provided, the painter interpolates between consecutive colors based on scroll progress.
  /// If null, [activeColor] is used for all indicators.
  final List<Color>? activeColors;

  /// The color used for all inactive indicator circles.
  final Color inactiveColor;

  /// The axis direction for indicator layout (horizontal or vertical).
  final Axis axis;

  /// Calculates when the foot indicator starts moving (reciprocal of headMoveOffset).
  ///
  /// For example, if headMoveOffset is 0.3, footMoveOffset is 0.7.
  double get footMoveOffset => 1 - headMoveOffset;

  /// The difference between max and min radius, used for interpolating radius animations.
  double get radiusOffset => radiusMax - radiusMin;

  /// Paints the spring indicator animation on the canvas.
  ///
  /// This method:
  /// 1. Draws all inactive indicators as small circles
  /// 2. Calculates the current page and scroll offset
  /// 3. For the last page, draws a single fully-sized active circle
  /// 4. For other pages, creates a spring-like shape that animates between the
  ///    current and next indicator, with smooth color transitions
  @override
  void paint(Canvas canvas, Size size) {
    final inactivePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = inactiveColor;

    // Draw all inactive indicators.
    for (var i = 0; i < itemCount; i++) {
      canvas.drawCircle(_position(i), radiusMin, inactivePaint);
    }

    final current = page.floor().clamp(0, itemCount - 1);

    // If on the last page, draw a single active circle and return.
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

    // Calculate the fractional scroll progress between current and next page.
    final offset = page - current;

    // Build the head (leading) and foot (trailing) points of the spring shape.
    final head = _buildHead(current, offset);
    final foot = _buildFoot(current, offset);

    // Create paint with color interpolated between current and next indicator colors.
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

    // Draw the connecting path between head and foot, plus both endpoint circles.
    final path = _makePath(head, foot);

    canvas
      ..drawPath(path, activePaint)
      ..drawCircle(
        head.center,
        head.radius,
        activePaint,
      )
      ..drawCircle(
        foot.center,
        foot.radius,
        activePaint,
      );
  }

  /// Builds the head (leading) point of the spring animation.
  ///
  /// The head starts at the current page position and moves toward the next page.
  /// It reaches the destination when offset >= [headMoveOffset].
  /// The radius grows from [radiusMin] to [radiusMax] as the animation progresses
  /// past the 0.5 offset mark.
  ///
  /// Parameters:
  ///   - [page]: The current page index
  ///   - [offset]: The fractional progress (0.0 to 1.0) between pages
  ///
  /// Returns a [SpringPoint] with interpolated position and radius.

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

  /// Builds the foot (trailing) point of the spring animation.
  ///
  /// The foot starts at the current page position and begins moving toward the
  /// next page only after offset >= [footMoveOffset].
  /// The radius shrinks from [radiusMax] to [radiusMin] as the animation progresses
  /// past the 0.5 offset mark.
  ///
  /// Parameters:
  ///   - [page]: The current page index
  ///   - [offset]: The fractional progress (0.0 to 1.0) between pages
  ///
  /// Returns a [SpringPoint] with interpolated position and radius.
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

  /// Applies an arctan-based easing curve to the progress value.
  ///
  /// This creates a smooth spring-like motion curve using the inverse tangent function.
  /// The [acceleration] parameter controls the curve steepness, with higher values
  /// creating more pronounced easing.
  ///
  /// Parameters:
  ///   - [t]: The progress value (0.0 to 1.0)
  ///
  /// Returns the eased progress value (0.0 to 1.0)
  double _atanInterpolation(double t) {
    return (math.atan(t * acceleration * 2 - acceleration) +
            math.atan(acceleration)) /
        (2 * math.atan(acceleration));
  }

  /// Calculates the center position of an indicator by its index.
  ///
  /// Positions are laid out horizontally or vertically based on the [axis] property,
  /// with spacing between indicators determined by [spacing] and [radiusMax].
  ///
  /// Parameters:
  ///   - [index]: The indicator position index
  ///
  /// Returns the center [Offset] of the indicator
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

  /// Creates a path that connects the head and foot circles with a smooth shape.
  ///
  /// The path is constructed using quadratic Bezier curves to create a smooth,
  /// organic-looking connection between two circles. The shape is symmetric around
  /// the line connecting the two circle centers, creating a natural spring-like appearance.
  ///
  /// Parameters:
  ///   - [head]: The leading circle point
  ///   - [foot]: The trailing circle point
  ///
  /// Returns a closed [Path] object representing the connecting shape
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

  /// Determines whether the painter should be repainted when properties change.
  ///
  /// Returns true if any property that affects the visual output has changed,
  /// triggering a full repaint. This optimization ensures the painter only
  /// redraws when necessary.
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
