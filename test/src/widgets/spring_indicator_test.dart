import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_indicator/spring_indicator.dart';

// ---------------------------------------------------------------------------
// Fake controller
// ---------------------------------------------------------------------------

/// A [PageController] subclass that allows tests to control [page] and
/// [hasClients] without attaching to a real [PageView].
class _FakePageController extends PageController {
  _FakePageController({
    super.initialPage,
    this.fakeHasClients = false,
    this.fakePage,
  });

  final bool fakeHasClients;
  double? fakePage;

  @override
  bool get hasClients => fakeHasClients;

  @override
  double? get page => fakePage;

  /// Updates the internal page value and notifies all listeners.
  void setPageValue(double newPage) {
    fakePage = newPage;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildIndicator({
  required PageController controller,
  int itemCount = 3,
  double radiusMax = 8,
  double radiusMin = 5,
  double spacing = 24,
  Color color = Colors.blue,
  List<Color>? colors,
  Color inactiveColor = const Color(0x33000000),
  double acceleration = 0.5,
  double headMoveOffset = 0.6,
  Axis axis = Axis.horizontal,
}) => MaterialApp(
  home: Scaffold(
    body: SpringIndicator(
      controller: controller,
      itemCount: itemCount,
      radiusMax: radiusMax,
      radiusMin: radiusMin,
      spacing: spacing,
      color: color,
      colors: colors,
      inactiveColor: inactiveColor,
      acceleration: acceleration,
      headMoveOffset: headMoveOffset,
      axis: axis,
    ),
  ),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SpringIndicator', () {
    // -----------------------------------------------------------------------
    group('asserts', () {
      late PageController controller;

      setUp(() => controller = PageController());
      tearDown(() => controller.dispose());

      test('throws when itemCount is zero', () {
        // assert
        expect(
          () => SpringIndicator(controller: controller, itemCount: 0),
          throwsAssertionError,
        );
      });

      test('throws when itemCount is negative', () {
        // assert
        expect(
          () => SpringIndicator(controller: controller, itemCount: -1),
          throwsAssertionError,
        );
      });

      test('throws when radiusMax equals radiusMin', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            radiusMax: 5,
          ),
          throwsAssertionError,
        );
      });

      test('throws when radiusMax is less than radiusMin', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            radiusMax: 4,
          ),
          throwsAssertionError,
        );
      });

      test('throws when spacing is negative', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            spacing: -1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when acceleration is below 0', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            acceleration: -0.1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when acceleration is above 1', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            acceleration: 1.1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when headMoveOffset is below 0', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            headMoveOffset: -0.1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when headMoveOffset is above 1', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            headMoveOffset: 1.1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when colors length does not match itemCount', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            colors: const [Colors.red, Colors.blue],
          ),
          throwsAssertionError,
        );
      });

      test('does not throw when colors length matches itemCount', () {
        // assert
        expect(
          () => SpringIndicator(
            controller: controller,
            itemCount: 3,
            colors: const [Colors.red, Colors.green, Colors.blue],
          ),
          returnsNormally,
        );
      });

      test('does not throw when colors is null', () {
        // assert
        expect(
          () => SpringIndicator(controller: controller, itemCount: 3),
          returnsNormally,
        );
      });
    });

    // -----------------------------------------------------------------------
    group('build', () {
      testWidgets('renders horizontal indicator', (tester) async {
        // arrange
        final controller = PageController();
        addTearDown(controller.dispose);

        // act
        await tester.pumpWidget(_buildIndicator(controller: controller));

        // assert
        expect(find.byType(SpringIndicator), findsOneWidget);
      });

      testWidgets('renders vertical indicator', (tester) async {
        // arrange
        final controller = PageController();
        addTearDown(controller.dispose);

        // act
        await tester.pumpWidget(
          _buildIndicator(controller: controller, axis: Axis.vertical),
        );

        // assert
        expect(find.byType(SpringIndicator), findsOneWidget);
      });

      testWidgets('renders with per-page colors', (tester) async {
        // arrange
        final controller = PageController();
        addTearDown(controller.dispose);

        // act
        await tester.pumpWidget(
          _buildIndicator(
            controller: controller,
            colors: const [Colors.red, Colors.green, Colors.blue],
          ),
        );

        // assert
        expect(find.byType(SpringIndicator), findsOneWidget);
      });

      testWidgets('horizontal SizedBox has correct dimensions', (tester) async {
        // arrange
        const radiusMax = 8.0;
        const spacing = 24.0;
        const itemCount = 3;
        final controller = PageController();
        addTearDown(controller.dispose);

        // act
        await tester.pumpWidget(_buildIndicator(controller: controller));

        // assert
        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        const step = radiusMax * 2 + spacing;
        const expectedWidth = step * (itemCount - 1) + radiusMax * 2;
        expect(sizedBox.width, equals(expectedWidth));
        expect(sizedBox.height, equals(radiusMax * 2));
      });

      testWidgets('vertical SizedBox has correct dimensions', (tester) async {
        // arrange
        const radiusMax = 8.0;
        const spacing = 24.0;
        const itemCount = 3;
        final controller = PageController();
        addTearDown(controller.dispose);

        // act
        await tester.pumpWidget(
          _buildIndicator(controller: controller, axis: Axis.vertical),
        );

        // assert
        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        const step = radiusMax * 2 + spacing;
        expect(sizedBox.width, equals(radiusMax * 2));
        const expectedHeight = step * (itemCount - 1) + radiusMax * 2;
        expect(sizedBox.height, equals(expectedHeight));
      });
    });

    // -----------------------------------------------------------------------
    group('initState', () {
      testWidgets(
        'uses 0 as initial page when controller has no clients',
        (tester) async {
          // arrange
          final controller = _FakePageController();
          addTearDown(controller.dispose);

          // act
          await tester.pumpWidget(_buildIndicator(controller: controller));

          // assert
          expect(find.byType(SpringIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'reads page from controller when it has clients',
        (tester) async {
          // arrange
          final controller = _FakePageController(
            fakeHasClients: true,
            fakePage: 2,
          );
          addTearDown(controller.dispose);

          // act
          await tester.pumpWidget(_buildIndicator(controller: controller));

          // assert
          expect(find.byType(SpringIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'falls back to initialPage when controller.page is null',
        (tester) async {
          // arrange
          final controller = _FakePageController(
            initialPage: 1,
            fakeHasClients: true,
          );
          addTearDown(controller.dispose);

          // act
          await tester.pumpWidget(_buildIndicator(controller: controller));

          // assert
          expect(find.byType(SpringIndicator), findsOneWidget);
        },
      );
    });

    // -----------------------------------------------------------------------
    group('_controllerChanged', () {
      testWidgets('rebuilds when page value changes', (tester) async {
        // arrange
        final controller = _FakePageController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(_buildIndicator(controller: controller));

        // act
        controller.setPageValue(1);
        await tester.pump();

        // assert
        expect(find.byType(SpringIndicator), findsOneWidget);
      });

      testWidgets('does not crash when page is unchanged', (tester) async {
        // arrange
        final controller = _FakePageController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(_buildIndicator(controller: controller));
        controller.setPageValue(1);
        await tester.pump();

        // act – notify with the same page value; no setState should be called
        controller.setPageValue(1);
        await tester.pump();

        // assert
        expect(find.byType(SpringIndicator), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    group('didUpdateWidget', () {
      testWidgets(
        'swaps controller listener when controller changes',
        (tester) async {
          // arrange
          final controller1 = _FakePageController();
          final controller2 = _FakePageController();
          addTearDown(controller1.dispose);
          addTearDown(controller2.dispose);
          await tester.pumpWidget(_buildIndicator(controller: controller1));

          // act – rebuild with a different controller
          await tester.pumpWidget(_buildIndicator(controller: controller2));

          // assert – new controller drives updates; old one no longer does
          controller2.setPageValue(1);
          await tester.pump();
          expect(find.byType(SpringIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'does not swap listener when controller is unchanged',
        (tester) async {
          // arrange
          final controller = _FakePageController();
          addTearDown(controller.dispose);
          await tester.pumpWidget(_buildIndicator(controller: controller));

          // act – rebuild with same controller but different color
          await tester.pumpWidget(
            _buildIndicator(controller: controller, color: Colors.red),
          );

          // assert – controller still drives updates
          controller.setPageValue(1);
          await tester.pump();
          expect(find.byType(SpringIndicator), findsOneWidget);
        },
      );
    });

    // -----------------------------------------------------------------------
    group('dispose', () {
      testWidgets('removes controller listener on dispose', (tester) async {
        // arrange
        final controller = _FakePageController();
        await tester.pumpWidget(_buildIndicator(controller: controller));

        // act – replace tree to trigger dispose of SpringIndicator
        await tester.pumpWidget(const SizedBox());

        // assert – notifying the controller after disposal must not throw
        // (the listener calling setState on a disposed widget was removed)
        expect(() => controller.setPageValue(0), returnsNormally);

        controller.dispose();
      });
    });
  });
}
