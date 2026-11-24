import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/main.dart';
import 'package:roznamcha/ui/screens/entry_detail_screen.dart';
import 'package:roznamcha/ui/screens/entry_form_screen.dart';
import 'package:roznamcha/ui/screens/home_screen.dart';

import 'fake_repository.dart';
import 'fake_weather.dart';
import 'phone.dart';

/// Starts the app and walks to the home screen: Get started, a name,
/// Continue.
Future<void> openHome(WidgetTester tester) async {
  await pumpOnPhone(
    tester,
    RoznamchaApp(notifier: fakeNotifier(), loadWeather: fakeWeather),
  );
  await tester.tap(find.text('Get started'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), 'Ali');
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  // Week 5's four tests. Opening and closing screens is given code. What
  // the screens show comes from the notifier now, so two of them need this
  // week's TODOs.
  // TODO 1
  testWidgets('Tapping an entry opens the detail screen with that entry', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Rain in Lahore'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryDetailScreen), findsOneWidget);
    expect(find.textContaining('smelled of pakoras'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('Back from the detail screen returns to the home screen', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Rain in Lahore'));
    await tester.pumpAndSettle();
    // Taps the back arrow that the AppBar added by itself.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(EntryDetailScreen), findsNothing);
  });

  testWidgets('The + button opens the form screen, empty', (tester) async {
    await openHome(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(EntryFormScreen), findsOneWidget);
    expect(find.text('New entry'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  // TODO 5 and TODO 6 (it also needs TODO 1)
  testWidgets('A saved entry shows at the top of the list', (tester) async {
    await openHome(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Eid shopping');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    // The new entry has today's date, so newest first puts it at the top.
    final saved = find.text('Eid shopping');
    expect(saved, findsOneWidget);
    final rain = find.text('Rain in Lahore');
    expect(tester.getTopLeft(saved).dy, lessThan(tester.getTopLeft(rain).dy));
  });

  // New in week 7: one change, made on one screen, shows on every screen.
  // TODO 3, TODO 5 and TODO 6 (it also needs TODO 1)
  testWidgets('An edit shows on the detail screen and on the home screen', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Rain in Lahore'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Rain at last');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // Back on the detail screen, which was under the form the whole time.
    expect(find.byType(EntryDetailScreen), findsOneWidget);
    expect(find.text('Rain at last'), findsOneWidget);
    expect(find.text('Rain in Lahore'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    // Back on the home screen, which was under both.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Rain at last'), findsOneWidget);
    expect(find.text('Rain in Lahore'), findsNothing);
  });

  // TODO 4 and TODO 5 (it also needs TODO 1)
  testWidgets('A delete on the detail screen shows on the home screen', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Rain in Lahore'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Rain in Lahore'), findsNothing);
    expect(find.text('Quiz went badly'), findsOneWidget);
  });
}
