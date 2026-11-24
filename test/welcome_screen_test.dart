import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/main.dart';
import 'package:roznamcha/ui/screens/welcome_screen.dart';

import 'fake_repository.dart';
import 'fake_weather.dart';
import 'phone.dart';

/// Builds the app on a 360 x 800 screen, the size of the design.
Future<void> pumpApp(WidgetTester tester) async {
  await pumpOnPhone(
    tester,
    RoznamchaApp(notifier: fakeNotifier(), loadWeather: fakeWeather),
  );
}

void main() {
  // Week 3's tests, and one from week 4 at the end. All twelve pass: the
  // welcome screen is given code.
  testWidgets('The app opens on the welcome screen', (tester) async {
    await pumpApp(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Nothing overflows on a 360 x 800 screen', (tester) async {
    await pumpApp(tester);
    expect(tester.takeException(), isNull);
  });

  // Week 3, TODO 1
  testWidgets('The theme is made from the design\'s seed colour', (
    tester,
  ) async {
    await pumpApp(tester);
    final context = tester.element(find.byType(WelcomeScreen));
    final primary = Theme.of(context).colorScheme.primary;
    // #006A63 is the primary colour that Material makes from the seed #0F766E.
    expect(primary.toARGB32().toRadixString(16).toUpperCase(), 'FF006A63');
  });

  // Week 3, TODO 2
  testWidgets('The illustration is an Image loaded from assets', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // Week 3, TODO 3
  testWidgets('The app name is shown, centred', (tester) async {
    await pumpApp(tester);
    final name = find.text('Roznamcha');
    expect(name, findsOneWidget);
    expect(tester.getCenter(name).dx, closeTo(180, 1));
  });

  testWidgets('The greeting is shown', (tester) async {
    await pumpApp(tester);
    expect(
      find.text('Assalam o Alaikum! Keep a diary of your days.'),
      findsOneWidget,
    );
  });

  // Week 3, TODO 4
  testWidgets('Three features sit in one Row, each in an Expanded', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(FeatureItem), findsNWidgets(3));
    expect(find.text('Write'), findsOneWidget);
    expect(find.text('Mood'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    for (final label in ['Write', 'Mood', 'Private']) {
      final item = find.ancestor(
        of: find.text(label),
        matching: find.byType(FeatureItem),
      );
      expect(
        find.ancestor(of: item, matching: find.byType(Expanded)),
        findsOneWidget,
      );
    }
    expect(
      tester.getSize(find.byType(FeatureItem).first).width,
      closeTo(104, 1),
    );
  });

  // Week 3, TODO 5
  testWidgets('The Get started button is a FilledButton that can be pressed', (
    tester,
  ) async {
    await pumpApp(tester);
    final button = find.widgetWithText(FilledButton, 'Get started');
    expect(button, findsOneWidget);
    expect(tester.widget<FilledButton>(button).enabled, isTrue);
  });

  testWidgets('The button fills the width', (tester) async {
    await pumpApp(tester);
    expect(tester.getSize(find.byType(FilledButton)).width, closeTo(312, 1));
  });

  // Week 3, TODO 6
  testWidgets('The button sits at the bottom', (tester) async {
    await pumpApp(tester);
    expect(tester.getBottomLeft(find.byType(FilledButton)).dy, closeTo(776, 1));
  });

  testWidgets('The rest is centred above the button', (tester) async {
    await pumpApp(tester);
    // The first Stack on the screen is the circle's.
    final circleTop = tester.getTopLeft(find.byType(Stack).first).dy;
    final features = find.ancestor(
      of: find.byType(FeatureItem).first,
      matching: find.byType(Row),
    );
    final featuresBottom = tester.getBottomLeft(features).dy;
    final buttonTop = tester.getTopLeft(find.byType(FilledButton)).dy;
    // The space above the circle, under the 24 dp padding, is as tall as the
    // space between the features and the button.
    final above = circleTop - 24;
    final below = buttonTop - featuresBottom;
    expect(above, greaterThan(0));
    expect(above, closeTo(below, 1));
  });

  // Week 4, TODO 1
  testWidgets('Get started calls onGetStarted', (tester) async {
    var called = false;
    await pumpOnPhone(
      tester,
      MaterialApp(home: WelcomeScreen(onGetStarted: () => called = true)),
    );
    await tester.tap(find.text('Get started'));
    expect(called, isTrue);
  });
}
