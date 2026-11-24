import 'package:flutter_test/flutter_test.dart';

import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/logic/entry_queries.dart';
import 'package:roznamcha/ui/format_date.dart';
import 'package:roznamcha/data/sample_entries.dart';

/// The titles of [entries], in order.
List<String> titles(List<Entry> entries) {
  final result = <String>[];
  for (final entry in entries) {
    result.add(entry.title);
  }
  return result;
}

void main() {
  // Week 5's tests. All seven pass: searching and sorting are given code
  // now.
  test('The sample data has eight entries, the oldest first', () {
    expect(sampleEntries.length, 8);
    expect(sampleEntries.first.title, 'First day of the semester');
    expect(formatDate(sampleEntries.first.date), '2 Nov 2026');
    expect(sampleEntries.last.title, 'Rain in Lahore');
  });

  // Week 5, TODO 3
  test('Searching for chai finds both chai entries, in any letter case', () {
    const chai = ['Chai with Zain', 'Too much chai'];
    expect(titles(searchEntries(sampleEntries, 'chai')), chai);
    expect(titles(searchEntries(sampleEntries, 'CHAI')), chai);
    // Spaces at both ends of the search text don't count.
    expect(titles(searchEntries(sampleEntries, '  chai ')), chai);
  });

  test('A search with no match gives an empty list', () {
    expect(searchEntries(sampleEntries, 'zebra'), isEmpty);
    // An empty search keeps every entry.
    expect(searchEntries(sampleEntries, '').length, 8);
  });

  // Week 5, TODO 4
  test('Newest first puts the latest date at the top', () {
    final sorted = sortEntries(sampleEntries, SortOrder.newestFirst);
    expect(sorted.first.title, 'Rain in Lahore');
    expect(sorted.last.title, 'First day of the semester');
  });

  test('Oldest first is the opposite order, and no entry is lost', () {
    final newest = sortEntries(sampleEntries, SortOrder.newestFirst);
    final oldest = sortEntries(sampleEntries, SortOrder.oldestFirst);
    expect(titles(oldest), titles(newest).reversed.toList());
    expect(oldest.first.title, 'First day of the semester');
    expect(oldest.length, 8);
  });

  test('Title A to Z ignores upper and lower case', () {
    final day = DateTime(2026, 11, 21);
    final fruit = [
      Entry(id: 1, title: 'banana', body: '', date: day, mood: Mood.okay),
      Entry(id: 2, title: 'Cherry', body: '', date: day, mood: Mood.okay),
      Entry(id: 3, title: 'Apple', body: '', date: day, mood: Mood.okay),
    ];
    expect(titles(sortEntries(fruit, SortOrder.titleAToZ)), [
      'Apple',
      'banana',
      'Cherry',
    ]);
    expect(
      sortEntries(sampleEntries, SortOrder.titleAToZ).first.title,
      'Biryani on Sunday',
    );
  });

  test('Sorting gives a new list and leaves the given list alone', () {
    final day = DateTime(2026, 11, 21);
    final given = [
      Entry(id: 1, title: 'B', body: '', date: day, mood: Mood.okay),
      Entry(id: 2, title: 'A', body: '', date: day, mood: Mood.okay),
    ];
    final sorted = sortEntries(given, SortOrder.titleAToZ);
    expect(titles(sorted), ['A', 'B']);
    expect(titles(given), ['B', 'A']);
  });
}
