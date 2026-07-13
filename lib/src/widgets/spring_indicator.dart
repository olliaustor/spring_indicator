import 'package:flutter/material.dart';

import '../models/blob_sample.dart';
import '../painter/gooey_blob_painter.dart';
import '../physics/blob_physics.dart';
import '../physics/spring_blob_controller.dart';

/// A gooey animated page indicator.
///
/// Example:
///
/// ```dart
/// final controller = PageController();
///
/// PageView(
///   controller: controller,
///   children: pages,
/// );
///
/// SpringIndicator(
///   controller: controller,
///   count: pages.length,
/// );
/// ```
class SpringIndicator extends StatefulWidget {
  const SpringIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.size = 12,
    this.spacing = 12,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.black26,
    this.axis = Axis.horizontal,
    this.springStiffness = 260,
    this.springDamping = 18,
    this.maxBlobDistance = 120,
  });

  final PageController controller;

  final int count;

  final double size;

  final double spacing;

  final Color activeColor;

  final Color inactiveColor;

  final Axis axis;

  final double springStiffness;

  final double springDamping;

  final double maxBlobDistance;

  @override
  State<SpringIndicator> createState() => _SpringIndicatorState();
}

class _SpringIndicatorState extends State<SpringIndicator>
    with SingleTickerProviderStateMixin {
  late final SpringBlobController _springController;

  final BlobPhysics _physics = BlobPhysics();

  final List<BlobSample> _samples = [];

  double _page = 0;

  double _displayPage = 0;

  double _velocity = 0;

  @override
  void initState() {
    super.initState();

    _displayPage = widget.controller.initialPage.toDouble();

    _springController = SpringBlobController(
      vsync: this,
      stiffness: widget.springStiffness,
      damping: widget.springDamping,
    );

    widget.controller.addListener(
      _pageChanged,
    );
  }

  void _pageChanged() {
    if (!widget.controller.hasClients) {
      return;
    }

    final value =
        widget.controller.page ?? widget.controller.initialPage.toDouble();

    _updateVelocity(
      value,
    );

    _page = value;

    //
    // During dragging:
    // follow finger directly.
    //
    if (!_springController.controller.isAnimating) {
      setState(() {
        _displayPage = value;
      });
    }
  }

  void _updateVelocity(
    double value,
  ) {
    final now = Duration(
      microseconds: DateTime.now().microsecondsSinceEpoch,
    );

    _samples.add(
      BlobSample(
        page: value,
        time: now,
      ),
    );

    //
    // Keep a small history.
    //
    if (_samples.length > 5) {
      _samples.removeAt(0);
    }

    if (_samples.length < 2) {
      return;
    }

    final previous = _samples[_samples.length - 2];

    final current = _samples.last;

    final seconds = (current.time - previous.time).inMicroseconds / 1000000;

    if (seconds <= 0) {
      return;
    }

    _velocity = (current.page - previous.page) / seconds;

    //
    // Prevent extreme values
    //
    _velocity = _velocity.clamp(
      -5,
      5,
    );
  }

  void _animateToPage(
    double target,
  ) {
    _springController.animateTo(
      current: _displayPage,

      target: target,

      velocity: _velocity,

      onUpdate: (value) {
        if (!mounted) {
          return;
        }

        setState(() {
          _displayPage = value;
        });
      },
    );
  }

  bool _handleScrollNotification(
    ScrollNotification notification,
  ) {
    if (notification is ScrollEndNotification) {
      if (widget.controller.hasClients) {
        final target = widget.controller.page!.round().toDouble();

        _animateToPage(
          target,
        );
      }
    }

    return false;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final diameter = widget.size;

    final totalLength =
        widget.count * diameter + (widget.count - 1) * widget.spacing;

    final paintSize = widget.axis == Axis.horizontal
        ? Size(
            totalLength,
            diameter,
          )
        : Size(
            diameter,
            totalLength,
          );

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,

      child: CustomPaint(
        size: paintSize,

        painter: GooeyBlobPainter(
          page: _displayPage,

          count: widget.count,

          radius: widget.size / 2,

          spacing: widget.spacing,

          activeColor: widget.activeColor,

          inactiveColor: widget.inactiveColor,

          physics: _physics,

          velocity: _velocity,

          axis: widget.axis,

          maxBlobDistance: widget.maxBlobDistance,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(
      _pageChanged,
    );

    _springController.dispose();

    super.dispose();
  }
}
