import 'entry.dart';
import 'sample_entries.dart';

/// The place where the app keeps its entries.
///
/// This class is abstract: it says what every repository can do, and not
/// how. `load` and `save` have no body here. A class that `implements
/// EntryRepository` must write both.
///
/// The rest of the app only knows this class. So the place can change (the
/// phone's memory this week, the phone's storage in week 8) and no other
/// file has to.
abstract class EntryRepository {
  /// Returns the entries that are kept, the oldest first.
  List<Entry> load();

  /// Keeps [entries], in place of everything that was kept before.
  void save(List<Entry> entries);
}

/// A repository that keeps the entries in memory.
///
/// It starts with the eight sample entries. It forgets every change when the
/// app closes: memory is all it has. Week 8 writes a repository that saves
/// the entries on the phone.
class InMemoryEntryRepository implements EntryRepository {
  // What this repository keeps. The list is private: other code gets to it
  // only through `load` and `save`.
  final List<Entry> _kept = [...sampleEntries];

  @override
  List<Entry> load() {
    // A copy, so the caller can change its list without changing this one.
    return [..._kept];
  }

  @override
  void save(List<Entry> entries) {
    // Throw away what was kept, and keep a copy of every entry in [entries].
    _kept.clear();
    _kept.addAll(entries);
  }
}
