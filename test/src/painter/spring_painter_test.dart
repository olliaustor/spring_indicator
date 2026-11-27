import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_indicator/src/painter/spring_painter.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

SpringPainter _makePainter({
  double page = 0,
  int itemCount = 3,
  double radiusMax = 8,
  double radiusMin = 5,
  double spacing = 24,
  double acceleration = 0.5,
  double headMoveOffset = 0.6,
  Color activeColor = Colors.blue,
  List<Color>? activeColors,
  Color inactiveColor = const Color(0x33000000),
  Axis axis = Axis.horizontal,
}) =>
    SpringPainter(
      page: page,
      itemCount: itemCount,
      radiusMax: radiusMax,
      radiusMin: radiusMin,
      spacing: spacing,
      acceleration: acceleration,
      headMoveOffset: headMoveOffset,
      activeColor: activeColor,
      activeColors: activeColors,
      inactiveColor: inactiveColor,
      axis: axis,
    );

Widget _buildWithPainter(SpringPainter painter) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(key: const Key('test_painter'), painter: painter),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SpringPainter', () {
    // -----------------------------------------------------------------------
    group('footMoveOffset', () {
      test('returns 1 minus headMoveOffset', () {
        // arrange
        final painter = _makePainter();

        // assert
        expect(painter.footMoveOffset, closeTo(0.4, 0.0001));
      });

      test('equals 0 when headMoveOffset is 1', () {
        // arrange
        final painter = _makePainter(headMoveOffset: 1);

        // assert
        expect(painter.footMoveOffset, closeTo(0, 0.0001));
      });

      test('equals 1 when headMoveOffset is 0', () {
        // arrange
        final painter = _makePainter(headMoveOffset: 0);

        // assert
        expect(painter.footMoveOffset, closeTo(1, 0.0001));
      });
    });

    // -----------------------------------------------------------------------
    group('radiusOffset', () {
      test('returns radiusMax minus radiusMin', () {
        // arrange
        final painter = _makePainter(radiusMax: 10, radiusMin: 4);

        // assert
        expect(painter.radiusOffset, closeTo(6, 0.0001));
      });

      test('returns 0 when radiusMax equals radiusMin', () {
        // arrange
        // Note: SpringIndicator asserts radiusMax > radiusMin, but
        // SpringPainter itself has no such assert, so this tests the
        // getter in isolation.
        final painter = _makePainter(radiusMax: 5);

        // assert
        expect(painter.radiusOffset, closeTo(0, 0.0001));
      });
    });

    // -----------------------------------------------------------------------
    group('shouldRepaint', () {
      test('returns false when nothing changed', () {
        // arrange
        final a = _makePainter();
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isFalse);
      });

      test('returns true when page changes', () {
        // arrange
        final a = _makePainter(page: 1);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when itemCount changes', () {
        // arrange
        final a = _makePainter(itemCount: 4);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when radiusMax changes', () {
        // arrange
        final a = _makePainter(radiusMax: 10);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when radiusMin changes', () {
        // arrange
        final a = _makePainter(radiusMin: 6);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when spacing changes', () {
        // arrange
        final a = _makePainter(spacing: 30);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when activeColor changes', () {
        // arrange
        final a = _makePainter(activeColor: Colors.red);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when activeColors changes', () {
        // arrange
        final a = _makePainter(
          activeColors: [Colors.red, Colors.green, Colors.blue],
        );
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when inactiveColor changes', () {
        // arrange
        final a = _makePainter(inactiveColor: Colors.grey);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when acceleration changes', () {
        // arrange
        final a = _makePainter(acceleration: 0.8);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when headMoveOffset changes', () {
        // arrange
        final a = _makePainter(headMoveOffset: 0.7);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when axis changes', () {
        // arrange
        final a = _makePainter(axis: Axis.vertical);
        final b = _makePainter();

        // assert
        expect(a.shouldRepaint(b), isTrue);
      });
    });

    // -----------------------------------------------------------------------
    group('paint', () {
      // Last-page branch --------------------------------------------

      testWidgets(
        'paints last page without activeColors without error',
        (tester) async {
          // arrange
          final painter = _makePainter(page: 2);

          // act
          await tester.pumpWidget(_buildWithPainter(painter));

          // assert
          expect(find.byKey(const Key('test_painter')), findsOneWidget);
        },
      );

      testWidgets(
        'paints last page with activeColors without error',
        (tester) async {
          // arrange
          final painter = _makePainter(
            page: 2,
            activeColors: [Colors.red, Colors.green, Colors.blue],
          );

          // act
          await tester.pumpWidget(_buildWithPainter(painter));

          // assert
          expect(find.byKey(const Key('test_painter')), findsOneWidget);
        },
      );

      // Mid-page branches: offset = 0.3
      // head: offset(0.3) < headMoveOffset(0.6)  → _atanInterpolation called
      // foot: offset(0.3) ≤ footMoveOffset(0.4)  → foot stays at origin
      // radii: offset(0.3) < 0.5                 → foot shrinks, head at min
      testWidgets(
        'paints with offset below headMoveOffset and footMoveOffset',
        (tester) async {
          // arrange
          final painter = _makePainter(page: 0.3);

          // act
          await tester.pumpWidget(_buildWithPainter(painter));

          // assert
          expect(find.byKey(const Key('test_painter')), findsOneWidget);
        },
      );

      // Mid-page branches: offset = 0.7
      // head: offset(0.7) ≥ headMoveOffset(0.6)  → t stays at 1.0 (head at end)
      // foot: offset(0.7) >  footMoveOffset(0.4) → _atanInterpolation called
      // radii: offset(0.7) ≥ 0.5                 → foot at min, head grows
      testWidgets(
        'paints with offset above headMoveOffset and footMoveOffset',
        (tester) async {
          // arrange
          final painter = _makePainter(page: 0.7);

          // act
          await tester.pumpWidget(_buildWithPainter(painter));

          // assert
          expect(find.byKey(const Key('test_painter')), findsOneWidget);
        },
      );

      testWidgets(
        'paints mid-page with activeColors applying color lerp',
        (tester) async {
          // arrange
          final painter = _makePainter(
            page: 0.5,
            activeColors: [Colors.red, Colors.green, Colors.blue],
          );

          // act
          await tester.pumpWidget(_buildWithPainter(painter));

          // assert
          expect(find.byKey(const Key('test_painter')), findsOneWidget);
        },
      );

      testWidgets(
        'paints with vertical axis without error',
        (tester) async {
          // arrange
          final painter = _makePainter(
            page: 0.5,
            axis: Axis.vertical,
          );

          // act
          await tester.pumpWidget(_buildWithPainter(painter));

          // assert
          expect(find.byKey(const Key('test_painter')), findsOneWidget);
        },
      );

      testWidgets(
        'paints single-item indicator on page 0',
        (tester) async {
          // arrange
          // itemCount=1, page=0: current=0, itemCount-1=0 → last page branch
          final painter = _makePainter(itemCount: 1);

          // act
          await tester.pumpWidget(_buildWithPainter(painter));

          // assert
          expect(find.byKey(const Key('test_painter')), findsOneWidget);
        },
      );
    });
  });
}
