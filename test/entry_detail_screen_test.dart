import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/logic/entries_notifier.dart';
import 'package:roznamcha/ui/screens/entry_detail_screen.dart';
import 'package:roznamcha/ui/screens/entry_form_screen.dart';

import 'fake_repository.dart';
import 'phone.dart';

final _chai = Entry(
  id: 2,
  title: 'Chai with Zain',
  body: 'Two cups each.',
  date: DateTime(2026, 11, 5),
  mood: Mood.happy,
);

/// Builds a screen with one button, taps it, and so opens the detail screen
/// for the entry with [id] on top of it, as the home screen does.
Future<void> openDetail(
  WidgetTester tester,
  EntriesNotifier notifier,
  int id,
) async {
  await pumpOnPhone(
    tester,
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) =>
                      EntryDetailScreen(notifier: notifier, entryId: id),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  // The first two tests are week 5's. The screen asks the notifier for its
  // entry now, so these four need TODO 1. Without it the notifier has no
  // entry to show.
  // TODO 1
  testWidgets('The detail screen shows the entry with the id it was given', (
    tester,
  ) async {
    await openDetail(tester, fakeNotifier([_chai]), 2);
    expect(find.text('Chai with Zain'), findsOneWidget);
    expect(find.text('Happy, 5 Nov 2026'), findsOneWidget);
    expect(find.text('Two cups each.'), findsOneWidget);
    expect(find.byIcon(Icons.sentiment_satisfied_alt), findsOneWidget);
  });

  testWidgets('A long entry scrolls and nothing overflows', (tester) async {
    final long = Entry(
      id: 1,
      title: 'A very long day that needs a very long title to describe it',
      body: 'I wrote and wrote. ' * 200,
      date: DateTime(2026, 11, 5),
      mood: Mood.sad,
    );
    await openDetail(tester, fakeNotifier([long]), 1);
    expect(find.textContaining('A very long day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('The detail screen has an Edit and a Delete button', (
    tester,
  ) async {
    await openDetail(tester, fakeNotifier([_chai]), 2);
    expect(find.widgetWithIcon(IconButton, Icons.edit), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.delete), findsOneWidget);
  });

  testWidgets('Edit opens the form screen, filled in with this entry', (
    tester,
  ) async {
    await openDetail(tester, fakeNotifier([_chai]), 2);
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    expect(find.byType(EntryFormScreen), findsOneWidget);
    expect(find.text('Edit entry'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Chai with Zain'),
      findsOneWidget,
    );
  });

  // This test passes before and after the TODOs: the screen's last branch
  // is given code.
  testWidgets('An id that no entry has gets a message, not a crash', (
    tester,
  ) async {
    await openDetail(tester, fakeNotifier([]), 2);
    expect(find.text('This entry is not in your diary.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // TODO 3 (it also needs TODO 1)
  testWidgets('When the notifier changes the entry, the screen follows', (
    tester,
  ) async {
    final notifier = fakeNotifier([_chai]);
    await openDetail(tester, notifier, 2);
    // No tap and no setState: only the notifier changes.
    notifier.update(
      Entry(
        id: 2,
        title: 'Chai with Zain and Ali',
        body: 'Three cups each.',
        date: _chai.date,
        mood: Mood.okay,
      ),
    );
    await tester.pump();
    expect(find.text('Chai with Zain and Ali'), findsOneWidget);
    expect(find.text('Three cups each.'), findsOneWidget);
    expect(find.text('Okay, 5 Nov 2026'), findsOneWidget);
    expect(find.text('Chai with Zain'), findsNothing);
  });

  // TODO 4 (it also needs TODO 1)
  testWidgets('Delete removes the entry and closes the screen', (tester) async {
    final notifier = fakeNotifier([_chai]);
    await openDetail(tester, notifier, 2);
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(notifier.entries, isEmpty);
    expect(find.byType(EntryDetailScreen), findsNothing);
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
