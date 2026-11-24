import 'package:flutter_test/flutter_test.dart';

import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/logic/entries_notifier.dart';

import 'fake_repository.dart';

final _chai = Entry(
  id: 1,
  title: 'Chai with Zain',
  body: 'Two cups each.',
  date: DateTime(2026, 11, 5),
  mood: Mood.happy,
);

final _quiz = Entry(
  id: 2,
  title: 'Quiz went badly',
  body: 'I mixed up Row and Column again.',
  date: DateTime(2026, 11, 18),
  mood: Mood.sad,
);

/// The titles of [entries], in order.
List<String> titles(List<Entry> entries) {
  return [for (final entry in entries) entry.title];
}

void main() {
  // These three tests pass before and after the TODOs: they check `add`,
  // which is given code. They start from an empty repository, so they don't
  // need TODO 1.
  test('add gives the new entry the next id, the texts and today', () {
    final notifier = fakeNotifier([]);
    notifier.add(title: 'Eid shopping', body: 'New shoes.', mood: Mood.sad);
    notifier.add(title: 'Rain', body: '', mood: Mood.okay);
    final first = notifier.entryById(1)!;
    expect(first.title, 'Eid shopping');
    expect(first.body, 'New shoes.');
    expect(first.mood, Mood.sad);
    expect(DateTime.now().difference(first.date).inMinutes, 0);
    expect(notifier.entryById(2)!.title, 'Rain');
    expect(notifier.entryById(3), isNull);
  });

  test('add saves the list, and tells the listeners', () {
    final repository = FakeEntryRepository([]);
    final notifier = EntriesNotifier(repository);
    var told = 0;
    notifier.addListener(() => told++);
    notifier.add(title: 'Eid shopping', body: '', mood: Mood.happy);
    expect(repository.saves, 1);
    expect(titles(repository.lastSaved!), ['Eid shopping']);
    expect(told, 1);
  });

  test('A listener that was removed is not told any more', () {
    final notifier = fakeNotifier([]);
    var told = 0;
    void listener() => told++;
    notifier.addListener(listener);
    notifier.add(title: 'One', body: '', mood: Mood.happy);
    notifier.removeListener(listener);
    notifier.add(title: 'Two', body: '', mood: Mood.happy);
    expect(told, 1);
  });

  // TODO 1
  test('A new notifier has the entries its repository loads', () {
    final notifier = fakeNotifier([_chai, _quiz]);
    expect(titles(notifier.entries), ['Chai with Zain', 'Quiz went badly']);
    expect(notifier.entryById(2), _quiz);
    // The next id is one more than the largest one in use.
    notifier.add(title: 'Eid shopping', body: '', mood: Mood.happy);
    expect(notifier.entries.last.id, 3);
  });

  // TODO 2
  test('The list a screen gets from the notifier can\'t be changed', () {
    final notifier = fakeNotifier([]);
    notifier.add(title: 'Eid shopping', body: '', mood: Mood.happy);
    expect(() => notifier.entries.add(_quiz), throwsUnsupportedError);
    expect(() => notifier.entries.clear(), throwsUnsupportedError);
    expect(notifier.entries.length, 1);
  });

  // TODO 3 (they also need TODO 1)
  test('update puts the changed entry in the old one\'s place', () {
    final notifier = fakeNotifier([_chai, _quiz]);
    final changed = Entry(
      id: 1,
      title: 'Chai with Zain and Ali',
      body: 'Three cups each.',
      date: _chai.date,
      mood: Mood.okay,
    );
    notifier.update(changed);
    expect(titles(notifier.entries), [
      'Chai with Zain and Ali',
      'Quiz went badly',
    ]);
    expect(notifier.entryById(1), changed);
    expect(notifier.entryById(2), _quiz);
  });

  test('update saves the list, and tells the listeners', () {
    final repository = FakeEntryRepository([_chai, _quiz]);
    final notifier = EntriesNotifier(repository);
    var told = 0;
    notifier.addListener(() => told++);
    notifier.update(
      Entry(
        id: 2,
        title: 'Quiz went well',
        body: '',
        date: _quiz.date,
        mood: Mood.happy,
      ),
    );
    expect(repository.saves, 1);
    expect(titles(repository.lastSaved!), ['Chai with Zain', 'Quiz went well']);
    expect(told, 1);
  });

  // This test needs TODO 1 only: the starter's `update` changes nothing at
  // all. A wrong TODO 3 can break it.
  test('update with an id that no entry has changes nothing', () {
    final notifier = fakeNotifier([_chai]);
    notifier.update(
      Entry(
        id: 99,
        title: 'Nobody',
        body: '',
        date: DateTime(2026, 11, 24),
        mood: Mood.okay,
      ),
    );
    expect(titles(notifier.entries), ['Chai with Zain']);
  });

  // TODO 4 (they also need TODO 1)
  test('delete removes the entry with that id, and only that one', () {
    final notifier = fakeNotifier([_chai, _quiz]);
    notifier.delete(1);
    expect(titles(notifier.entries), ['Quiz went badly']);
    expect(notifier.entryById(1), isNull);
  });

  test('delete saves the list, and tells the listeners', () {
    final repository = FakeEntryRepository([_chai, _quiz]);
    final notifier = EntriesNotifier(repository);
    var told = 0;
    notifier.addListener(() => told++);
    notifier.delete(2);
    expect(repository.saves, 1);
    expect(titles(repository.lastSaved!), ['Chai with Zain']);
    expect(told, 1);
  });
}
