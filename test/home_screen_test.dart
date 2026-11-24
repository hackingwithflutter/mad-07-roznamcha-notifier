import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/data/weather.dart';
import 'package:roznamcha/logic/entries_notifier.dart';
import 'package:roznamcha/ui/screens/home_screen.dart';
import 'package:roznamcha/ui/widgets/entry_card.dart';
import 'package:roznamcha/ui/widgets/weather_line.dart';

import 'fake_repository.dart';
import 'fake_weather.dart';
import 'phone.dart';

/// Builds the home screen alone, on the phone-sized screen. The entries
/// come from [notifier], or from a new notifier with the eight sample
/// entries. The weather comes from `fakeWeather`, and the second pump lets
/// it arrive.
Future<void> pumpHome(WidgetTester tester, {EntriesNotifier? notifier}) async {
  await pumpOnPhone(
    tester,
    MaterialApp(
      home: HomeScreen(
        name: 'Ali',
        notifier: notifier ?? fakeNotifier(),
        loadWeather: fakeWeather,
      ),
    ),
  );
  await tester.pump();
}

/// True when the widget [above] finds is higher on the screen than [below].
bool isAbove(WidgetTester tester, Finder above, Finder below) {
  return tester.getTopLeft(above).dy < tester.getTopLeft(below).dy;
}

void main() {
  // The first twelve tests are weeks 4, 5 and 6's. They pass before and
  // after the TODOs: they are the safety net for TODO 5. A refactor changes
  // how the code is built, and not what it does, so these must stay green.
  testWidgets('The home screen greets the user by name', (tester) async {
    await pumpHome(tester);
    expect(find.text('Hi, Ali'), findsOneWidget);
  });

  testWidgets('Nothing overflows on the home screen', (tester) async {
    await pumpOnPhone(
      tester,
      MaterialApp(
        home: HomeScreen(
          name: 'Fatima Noor',
          notifier: fakeNotifier(),
          loadWeather: fakeWeather,
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('The home screen has a search field, a sort button and a +', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.sort), findsOneWidget);
    expect(
      find.widgetWithIcon(FloatingActionButton, Icons.add),
      findsOneWidget,
    );
  });

  // Week 5, TODO 1
  testWidgets('The entries are in a ListView.builder, one item per entry', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.byType(ListView), findsOneWidget);
    final list = tester.widget<ListView>(find.byType(ListView));
    // ListView.builder keeps a builder function, not a list of children.
    expect(list.childrenDelegate, isA<SliverChildBuilderDelegate>());
    expect(list.childrenDelegate.estimatedChildCount, 8);
    expect(find.byType(EntryCard), findsAtLeastNWidgets(2));
  });

  testWidgets('On a short screen the list scrolls', (tester) async {
    // 360 x 500: shorter than the phone, so the list can't show every entry.
    tester.view.physicalSize = const Size(1080, 1500);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          name: 'Ali',
          notifier: fakeNotifier(),
          loadWeather: fakeWeather,
        ),
      ),
    );
    await tester.pump();
    final top = tester.widget<EntryCard>(find.byType(EntryCard).first).entry;
    expect(find.text(top.title), findsOneWidget);
    // Drag the list up by more than one card: the top entry leaves the screen.
    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pump();
    expect(find.text(top.title), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // Week 5, TODO 3
  testWidgets('Typing in the search field shows only the matching entries', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.enterText(find.byType(TextField), 'chai');
    await tester.pump();
    expect(find.text('Chai with Zain'), findsOneWidget);
    expect(find.text('Too much chai'), findsOneWidget);
    expect(find.byType(EntryCard), findsNWidgets(2));
  });

  testWidgets('A search with no match shows a message', (tester) async {
    await pumpHome(tester);
    await tester.enterText(find.byType(TextField), 'zebra');
    await tester.pump();
    expect(find.text('No entries match your search.'), findsOneWidget);
    expect(find.byType(EntryCard), findsNothing);
  });

  // Week 5, TODO 4
  testWidgets('The list starts with the newest entry at the top', (
    tester,
  ) async {
    await pumpHome(tester);
    final newest = find.text('Rain in Lahore');
    final older = find.text('Quiz went badly');
    expect(isAbove(tester, newest, older), isTrue);
  });

  testWidgets('Choosing Title A to Z in the sort menu sorts the list', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title A to Z'));
    await tester.pumpAndSettle();
    final first = find.text('Biryani on Sunday');
    final second = find.text('Chai with Zain');
    expect(isAbove(tester, first, second), isTrue);
    expect(tester.getTopLeft(first).dy, lessThan(300));
  });

  // Week 6
  testWidgets('The weather line sits between the greeting and the search', (
    tester,
  ) async {
    await pumpHome(tester);
    final line = find.byType(WeatherLine);
    expect(line, findsOneWidget);
    expect(isAbove(tester, find.text('Hi, Ali'), line), isTrue);
    expect(isAbove(tester, line, find.byType(TextField)), isTrue);
  });

  testWidgets('Typing in the search field does not load the weather again', (
    tester,
  ) async {
    var loads = 0;
    Future<Weather> countingWeather() async {
      loads++;
      return const Weather(temperature: 19.9, unit: '°C');
    }

    await pumpOnPhone(
      tester,
      MaterialApp(
        home: HomeScreen(
          name: 'Ali',
          notifier: fakeNotifier(),
          loadWeather: countingWeather,
        ),
      ),
    );
    await tester.pump();
    // Every key press rebuilds the home screen, and the weather line in it.
    await tester.enterText(find.byType(TextField), 'c');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ch');
    await tester.pump();
    expect(loads, 1);
  });

  // Week 6, TODO 3
  testWidgets('The home screen shows the temperature under the greeting', (
    tester,
  ) async {
    await pumpHome(tester);
    final temperature = find.textContaining('20°C');
    expect(temperature, findsOneWidget);
    expect(isAbove(tester, find.text('Hi, Ali'), temperature), isTrue);
  });

  // This test passes before and after TODO 5. A wrong answer to TODO 5 can
  // break it: a screen that adds itself as a listener must remove itself
  // when it leaves. A ListenableBuilder does both by itself.
  testWidgets('When the home screen is gone, it no longer listens', (
    tester,
  ) async {
    final notifier = fakeNotifier();
    await pumpHome(tester, notifier: notifier);
    // Another widget takes the home screen's place, so its State is disposed.
    await tester.pumpWidget(const SizedBox());
    notifier.add(title: 'Eid shopping', body: '', mood: Mood.happy);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // TODO 5 (they also need TODO 1)
  testWidgets('The home screen shows the entries the notifier holds', (
    tester,
  ) async {
    final exam = Entry(
      id: 1,
      title: 'Midterm tomorrow',
      body: 'Eight weeks of notes on one table.',
      date: DateTime(2026, 11, 24),
      mood: Mood.okay,
    );
    await pumpHome(tester, notifier: fakeNotifier([exam]));
    expect(find.text('Midterm tomorrow'), findsOneWidget);
    expect(find.byType(EntryCard), findsOneWidget);
    expect(find.text('Rain in Lahore'), findsNothing);
  });

  testWidgets('When the notifier adds an entry, the list shows it at once', (
    tester,
  ) async {
    final notifier = fakeNotifier();
    await pumpHome(tester, notifier: notifier);
    expect(find.text('Eid shopping'), findsNothing);
    // No tap and no setState: only the notifier changes.
    notifier.add(title: 'Eid shopping', body: '', mood: Mood.happy);
    await tester.pump();
    expect(find.text('Eid shopping'), findsOneWidget);
  });

  // TODO 5 (it also needs TODO 1 and TODO 4)
  testWidgets('When the notifier deletes an entry, the list drops it', (
    tester,
  ) async {
    final notifier = fakeNotifier();
    await pumpHome(tester, notifier: notifier);
    expect(find.text('Rain in Lahore'), findsOneWidget);
    notifier.delete(8);
    await tester.pump();
    expect(find.text('Rain in Lahore'), findsNothing);
    expect(find.text('Quiz went badly'), findsOneWidget);
  });
}
