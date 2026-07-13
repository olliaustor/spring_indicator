import 'package:flutter/material.dart';
import 'package:spring_indicator/src/painter/spring_painter.dart';

class SpringIndicator extends StatefulWidget {
  const SpringIndicator({
    super.key,
    required this.controller,
    required this.itemCount,

    this.radiusMax = 8,
    this.radiusMin = 5,
    this.spacing = 24,

    this.color = Colors.blue,
    this.colors,
    this.inactiveColor = const Color(0x33000000),

    this.acceleration = .5,
    this.headMoveOffset = .6,

    this.axis = Axis.horizontal,
  }) : assert(itemCount > 0),
       assert(radiusMax > radiusMin),
       assert(spacing >= 0),
       assert(acceleration >= 0 && acceleration <= 1),
       assert(headMoveOffset >= 0 && headMoveOffset <= 1),
       assert(colors != null && colors.length == itemCount || colors == null);

  final PageController controller;

  final int itemCount;

  final double radiusMax;
  final double radiusMin;

  final double spacing;

  final Color color;

  final List<Color>? colors;
  final Color inactiveColor;

  final double acceleration;

  /// Same meaning as the Android implementation.
  ///
  /// head starts moving at 0%
  /// foot starts moving at 40%
  /// (1 - headMoveOffset)
  final double headMoveOffset;

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
