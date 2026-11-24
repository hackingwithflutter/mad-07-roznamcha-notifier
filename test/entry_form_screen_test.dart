import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/logic/entries_notifier.dart';
import 'package:roznamcha/ui/screens/entry_form_screen.dart';

import 'fake_repository.dart';
import 'phone.dart';

final _chai = Entry(
  id: 2,
  title: 'Chai with Zain',
  body: 'Two cups each.',
  date: DateTime(2026, 11, 5),
  mood: Mood.okay,
);

/// Builds a screen with one button, taps it, and so opens the form screen
/// on top of it, as the home screen and the detail screen do. With [entry]
/// the form edits that entry; without it, the form adds a new one.
Future<void> openForm(
  WidgetTester tester,
  EntriesNotifier notifier, {
  Entry? entry,
}) async {
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
                      EntryFormScreen(notifier: notifier, entry: entry),
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
  // Week 5's tests of the add screen, which is the form screen now. These
  // four pass before and after the TODOs.
  testWidgets('The form screen shows two fields, three moods and Save', (
    tester,
  ) async {
    await openForm(tester, fakeNotifier([]));
    expect(find.text('New entry'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('An empty title, or only spaces, does not validate', (
    tester,
  ) async {
    await openForm(tester, fakeNotifier([]));
    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please enter a title.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '   ');
    expect(form.validate(), isFalse);
  });

  testWidgets('Save closes the form screen', (tester) async {
    await openForm(tester, fakeNotifier([]));
    await tester.enterText(find.byType(TextFormField).first, 'Eid shopping');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryFormScreen), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('Save with an empty title shows the error and stays open', (
    tester,
  ) async {
    final notifier = fakeNotifier([]);
    await openForm(tester, notifier);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(find.byType(EntryFormScreen), findsOneWidget);
    expect(notifier.entries, isEmpty);
  });

  // New in week 7, and given code: with an entry, the form opens filled in.
  testWidgets('With an entry, the form opens filled in, as Edit entry', (
    tester,
  ) async {
    await openForm(tester, fakeNotifier([_chai]), entry: _chai);
    expect(find.text('Edit entry'), findsOneWidget);
    expect(find.text('New entry'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Chai with Zain'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, 'Two cups each.'),
      findsOneWidget,
    );
    // The entry's mood is the chip that is picked.
    final okay = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Okay'),
    );
    expect(okay.selected, isTrue);
  });

  // TODO 6
  testWidgets('Save on an empty form adds the entry to the notifier', (
    tester,
  ) async {
    final notifier = fakeNotifier([]);
    await openForm(tester, notifier);
    await tester.enterText(find.byType(TextFormField).first, '  Eid shopping ');
    await tester.enterText(find.byType(TextFormField).last, ' New shoes. ');
    await tester.tap(find.text('Sad'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(notifier.entries.length, 1);
    final saved = notifier.entries.first;
    expect(saved.title, 'Eid shopping');
    expect(saved.body, 'New shoes.');
    expect(saved.mood, Mood.sad);
    // The entry's date is the moment Save was tapped.
    expect(DateTime.now().difference(saved.date).inMinutes, 0);
  });

  // TODO 6 (it also needs TODO 1 and TODO 3)
  testWidgets('Save on a filled form changes the entry, not its id or date', (
    tester,
  ) async {
    final notifier = fakeNotifier([_chai]);
    await openForm(tester, notifier, entry: _chai);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Chai with Zain and Ali',
    );
    await tester.tap(find.text('Happy'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // Still one entry: the form changed it, and did not add a second one.
    expect(notifier.entries.length, 1);
    final saved = notifier.entries.first;
    expect(saved.id, 2);
    expect(saved.title, 'Chai with Zain and Ali');
    expect(saved.body, 'Two cups each.');
    expect(saved.mood, Mood.happy);
    expect(saved.date, DateTime(2026, 11, 5));
    expect(find.byType(EntryFormScreen), findsNothing);
  });
}
