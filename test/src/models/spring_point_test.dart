import 'package:flutter_test/flutter_test.dart';
import 'package:spring_indicator/src/models/spring_point.dart';

void main() {
  group('SpringPoint', () {
    group('constructor', () {
      test('stores center', () {
        // arrange
        const center = Offset(3, 7);

        // act
        const point = SpringPoint(center: center, radius: 1);

        // assert
        expect(point.center, equals(center));
      });

      test('stores radius', () {
        // arrange
        const radius = 4.5;

        // act
        const point = SpringPoint(center: Offset.zero, radius: radius);

        // assert
        expect(point.radius, equals(radius));
      });

      test('accepts zero radius', () {
        // act
        const point = SpringPoint(center: Offset.zero, radius: 0);

        // assert
        expect(point.radius, equals(0));
      });

      test('accepts negative center coordinates', () {
        // arrange
        const center = Offset(-5, -10);

        // act
        const point = SpringPoint(center: center, radius: 2);

        // assert
        expect(point.center, equals(center));
      });
    });
  });
}
