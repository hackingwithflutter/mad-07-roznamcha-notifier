import 'package:flutter_test/flutter_test.dart';

import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/data/entry_repository.dart';
import 'package:roznamcha/data/sample_entries.dart';

void main() {
  // These four tests pass before and after the TODOs: the repository is
  // given code.
  test('The in-memory repository is an EntryRepository', () {
    expect(InMemoryEntryRepository(), isA<EntryRepository>());
  });

  test('A new repository loads the eight sample entries, the oldest first', () {
    final repository = InMemoryEntryRepository();
    final entries = repository.load();
    expect(entries.length, 8);
    expect(entries.first.title, 'First day of the semester');
    expect(entries.last.title, 'Rain in Lahore');
    // The sample data itself is untouched.
    expect(sampleEntries.length, 8);
  });

  test('What the repository saved, it loads again', () {
    final repository = InMemoryEntryRepository();
    final eid = Entry(
      id: 9,
      title: 'Eid shopping',
      body: 'New shoes.',
      date: DateTime(2026, 11, 24),
      mood: Mood.happy,
    );
    repository.save([eid]);
    expect(repository.load(), [eid]);
  });

  test('The repository keeps its own list, apart from the caller\'s', () {
    final repository = InMemoryEntryRepository();
    // Changing the list that `load` returned changes nothing inside.
    final loaded = repository.load();
    loaded.clear();
    expect(repository.load().length, 8);
    // Changing a list after it was saved changes nothing inside.
    final mine = [sampleEntries.first];
    repository.save(mine);
    mine.clear();
    expect(repository.load().length, 1);
  });
}
