import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class SpringBlobController {
  SpringBlobController({
    required TickerProvider vsync,
    this.stiffness = 260,
    this.damping = 18,
  }) {
    controller = AnimationController.unbounded(
      vsync: vsync,
    );
  }

  final double stiffness;
  final double damping;

  late final AnimationController controller;

  void animateTo({
    required double current,
    required double target,
    required double velocity,
    required ValueChanged<double> onUpdate,
  }) {
    controller
      ..stop()
      ..value = current;

    controller.addListener(() {
      onUpdate(
        controller.value,
      );
    });

    controller.animateWith(
      SpringSimulation(
        SpringDescription(
          mass: 1,
          stiffness: stiffness,
          damping: damping,
        ),

        current,

        target,

        velocity,
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }
}
