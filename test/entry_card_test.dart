import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/ui/widgets/entry_card.dart';

import 'phone.dart';

final _entry = Entry(
  id: 2,
  title: 'Chai with Zain',
  body: 'Two cups each.',
  date: DateTime(2026, 11, 5),
  mood: Mood.happy,
);

/// Builds one card alone, on the phone-sized screen, with [onTap].
Future<void> pumpCard(WidgetTester tester, {VoidCallback? onTap}) async {
  await pumpOnPhone(
    tester,
    MaterialApp(
      home: Scaffold(
        body: EntryCard(entry: _entry, onTap: onTap ?? () {}),
      ),
    ),
  );
}

void main() {
  // Week 5's tests. All three pass: the card is given code now.
  testWidgets('An entry card shows the title in a Card and reports a tap', (
    tester,
  ) async {
    var taps = 0;
    await pumpCard(tester, onTap: () => taps++);
    expect(find.widgetWithText(Card, 'Chai with Zain'), findsOneWidget);
    await tester.tap(find.text('Chai with Zain'));
    expect(taps, 1);
  });

  // Week 5, TODO 2
  testWidgets('An entry card shows the date under the title', (tester) async {
    await pumpCard(tester);
    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.subtitle, isA<Text>());
    expect(find.text('5 Nov 2026'), findsOneWidget);
  });

  testWidgets('An entry card shows the mood: its icon first, its label last', (
    tester,
  ) async {
    await pumpCard(tester);
    final icon = find.byIcon(Icons.sentiment_satisfied_alt);
    final label = find.text('Happy');
    expect(icon, findsOneWidget);
    expect(label, findsOneWidget);
    final title = find.text('Chai with Zain');
    expect(tester.getCenter(icon).dx, lessThan(tester.getTopLeft(title).dx));
    expect(
      tester.getCenter(label).dx,
      greaterThan(tester.getTopLeft(title).dx),
    );
  });
}
