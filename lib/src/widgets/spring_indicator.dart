import 'package:flutter/material.dart';
import 'package:spring_indicator/src/painter/spring_painter.dart';

/// A page indicator widget that animates with a spring-like stretching effect
/// between dots as the user swipes through pages.
///
/// The indicator renders one dot per page. The active dot stretches toward the
/// next dot while scrolling, then snaps back — mimicking a spring. Dot sizes,
/// spacing, colors, and animation timing are all configurable.
///
/// {@tool snippet}
/// Typical usage inside a [Column] alongside a [PageView]:
///
/// ```dart
/// final _controller = PageController();
///
/// Column(
///   children: [
///     Expanded(
///       child: PageView(
///         controller: _controller,
///         children: const [
///           ColoredBox(color: Colors.red),
///           ColoredBox(color: Colors.green),
///           ColoredBox(color: Colors.blue),
///         ],
///       ),
///     ),
///     SpringIndicator(
///       controller: _controller,
///       itemCount: 3,
///       color: Colors.deepPurple,
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [PageView], which is typically controlled by the same [PageController].
///  * [PageController], which drives the animation.
class SpringIndicator extends StatefulWidget {
  /// Creates a [SpringIndicator].
  ///
  /// The [controller] and [itemCount] arguments must not be null.
  /// [itemCount] must be greater than zero.
  /// [radiusMax] must be greater than [radiusMin].
  /// [spacing] must be non-negative.
  /// [acceleration] and [headMoveOffset] must each be between 0.0 and 1.0.
  /// If [colors] is provided, its length must equal [itemCount].
  const SpringIndicator({
    required this.controller,
    required this.itemCount,
    super.key,

    this.radiusMax = 8,
    this.radiusMin = 5,
    this.spacing = 24,

    this.color = Colors.blue,
    this.colors,
    this.inactiveColor = const Color(0x33000000),

    this.acceleration = .5,
    this.headMoveOffset = .6,

    this.axis = Axis.horizontal,
  }) : assert(itemCount > 0, 'itemCount must be greater than zero.'),
       assert(
         radiusMax > radiusMin,
         'radiusMax must be greater than radiusMin.',
       ),
       assert(spacing >= 0, 'spacing must be non-negative.'),
       assert(
         acceleration >= 0 && acceleration <= 1,
         'acceleration must be between 0.0 and 1.0.',
       ),
       assert(
         headMoveOffset >= 0 && headMoveOffset <= 1,
         'headMoveOffset must be between 0.0 and 1.0.',
       ),
       assert(
         colors != null && colors.length == itemCount || colors == null,
         'colors.length must equal itemCount when colors is provided.',
       );

  /// The [PageController] that this indicator listens to.
  ///
  /// The indicator reflects the current page position reported by this
  /// controller and updates whenever the page changes.
  final PageController controller;

  /// The total number of pages (and dots) to display.
  ///
  /// Must be greater than zero.
  final int itemCount;

  /// The radius of the active (largest) dot, in logical pixels.
  ///
  /// Must be greater than [radiusMin]. Defaults to `8`.
  final double radiusMax;

  /// The radius of an inactive (smallest) dot, in logical pixels.
  ///
  /// Must be less than [radiusMax]. Defaults to `5`.
  final double radiusMin;

  /// The gap between the edges of adjacent dots, in logical pixels.
  ///
  /// Must be non-negative. Defaults to `24`.
  final double spacing;

  /// The color used for the active dot when [colors] is not provided.
  ///
  /// Defaults to [Colors.blue].
  final Color color;

  /// Per-dot active colors, one entry per page.
  ///
  /// When provided, [colors] overrides [color] and its length must equal
  /// [itemCount]. When null, [color] is used for all active dots.
  final List<Color>? colors;

  /// The color of inactive dots.
  ///
  /// Defaults to `Color(0x33000000)` (black at ~20 % opacity).
  final Color inactiveColor;

  /// Controls how quickly the spring head accelerates toward the target dot.
  ///
  /// A value of `0.0` means the head does not move until the foot catches up;
  /// `1.0` means the head moves at the same rate as the foot with no spring
  /// effect. Must be between 0.0 and 1.0. Defaults to `0.5`.
  final double acceleration;

  /// The scroll progress at which the spring head begins to move, expressed as
  /// a fraction of a single page swipe.
  ///
  /// This mirrors the behavior of the Android implementation:
  /// - The head starts moving at `0 %` scroll progress.
  /// - The foot starts moving at `(1 - headMoveOffset) * 100 %` scroll
  ///   progress (e.g. `40 %` with the default value of `0.6`).
  ///
  /// Must be between 0.0 and 1.0. Defaults to `0.6`.
  final double headMoveOffset;

  /// The axis along which the dots are laid out.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis axis;

  @override
  State<SpringIndicator> createState() => _SpringIndicatorState();
}

class _SpringIndicatorState extends State<SpringIndicator> {
  double _page = 0;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_controllerChanged);

    if (widget.controller.hasClients) {
      _page =
          widget.controller.page ?? widget.controller.initialPage.toDouble();
    }
  }

  @override
  void didUpdateWidget(SpringIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_controllerChanged);

      widget.controller.addListener(_controllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerChanged);
    super.dispose();
  }

  void _controllerChanged() {
    final page =
        widget.controller.page ?? widget.controller.initialPage.toDouble();

    if (page != _page) {
      setState(() {
        _page = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radiusMax * 2;

    final step = diameter + widget.spacing;

    return SizedBox(
      width: widget.axis == Axis.horizontal
          ? step * widget.itemCount
          : diameter,
      height: widget.axis == Axis.horizontal
          ? diameter
          : step * widget.itemCount,

      child: CustomPaint(
        painter: SpringPainter(
          page: _page,

          itemCount: widget.itemCount,

          radiusMax: widget.radiusMax,
          radiusMin: widget.radiusMin,

          spacing: widget.spacing,

          acceleration: widget.acceleration,

          headMoveOffset: widget.headMoveOffset,

          activeColor: widget.color,
          activeColors: widget.colors,
          inactiveColor: widget.inactiveColor,

          axis: widget.axis,
        ),
      ),
    );
  }
}
