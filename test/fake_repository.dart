import 'package:roznamcha/data/entry.dart';
import 'package:roznamcha/data/entry_repository.dart';
import 'package:roznamcha/data/sample_entries.dart';
import 'package:roznamcha/logic/entries_notifier.dart';

/// A repository for the tests. It `implements EntryRepository`, so a
/// notifier takes it as it takes the real one. It starts with the entries it
/// is given, and it remembers what the notifier saved.
class FakeEntryRepository implements EntryRepository {
  FakeEntryRepository([List<Entry>? entries])
    : _entries = [...entries ?? sampleEntries];

  final List<Entry> _entries;

  /// How many times `save` was called.
  int saves = 0;

  /// The list the last `save` was given, or null when nothing was saved.
  List<Entry>? lastSaved;

  @override
  List<Entry> load() => [..._entries];

  @override
  void save(List<Entry> entries) {
    saves++;
    lastSaved = [...entries];
  }
}

/// A notifier for the tests, with the eight sample entries, or with
/// [entries].
EntriesNotifier fakeNotifier([List<Entry>? entries]) {
  return EntriesNotifier(FakeEntryRepository(entries));
}
