import 'dart:ui';

class BlobPhysics {
  BlobPhysics();

  double leftRadiusScale = 1.0;
  double rightRadiusScale = 1.0;

  double stretch = 0.0;
  double tilt = 0.0;

  Offset trail = Offset.zero;

  void update({
    required double targetStretch,
    required double targetTilt,
    required Offset targetTrail,
    required double velocity,
  }) {
    const stiffness = 0.18;

    stretch += (targetStretch - stretch) * stiffness;

    tilt += (targetTilt - tilt) * stiffness;

    trail += (targetTrail - trail) * stiffness;

    final velocityAmount = velocity.abs().clamp(0.0, 3.0);

    leftRadiusScale +=
        (0.95 - velocityAmount * .05 - leftRadiusScale) * stiffness;

    rightRadiusScale +=
        (1.0 + velocityAmount * .08 - rightRadiusScale) * stiffness;
  }

  void reset() {
    leftRadiusScale = 1;
    rightRadiusScale = 1;

    stretch = 0;
    tilt = 0;

    trail = Offset.zero;
  }
}
