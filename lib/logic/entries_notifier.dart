import 'package:flutter/foundation.dart';

import '../data/entry.dart';
import '../data/entry_repository.dart';

/// The one place that holds the diary's entries while the app runs.
///
/// It is a ChangeNotifier: other objects can listen to it, and it tells them
/// when the entries change. A screen never changes the list itself. It calls
/// `add`, `update` or `delete`, and every screen that listens builds again.
///
/// The notifier doesn't know where the entries are kept. It gets a
/// repository through its constructor, and only knows the abstract class
/// `EntryRepository`: the app passes one that keeps the entries in memory,
/// and the tests pass one that counts what was saved.
class EntriesNotifier extends ChangeNotifier {
  EntriesNotifier(this._repository) {
    // TODO 1: Load the entries. Ask the repository for them with
    // `_repository.load()`, and put them all in `_entries` with `addAll`.
    // No `notifyListeners()` here: nobody can listen yet, because the object
    // is still being made.
  }

  // Where the entries are kept. The notifier asks it once, for the entries
  // to start with, and tells it after every change.
  final EntryRepository _repository;

  // The state: the entries, the oldest first. The list is private, so the
  // only way to change it is through the methods below.
  final List<Entry> _entries = [];

  /// The entries, the oldest first, as a list that can't be changed.
  List<Entry> get entries {
    // TODO 2: Don't hand out the private list itself: a screen could `add`
    // to it, and no listener would be told. Return
    // `List.unmodifiable(_entries)`, a copy that refuses every change.
    // Replace the `return` line below.
    return _entries;
  }

  /// The entry with this [id], or null when no entry has it.
  Entry? entryById(int id) {
    for (final entry in _entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  /// Adds a new entry, written now, with the next free id.
  void add({required String title, required String body, required Mood mood}) {
    // Every method that changes the entries has the same three steps.
    // 1. Change the list.
    _entries.add(
      Entry(
        id: _nextId(),
        title: title,
        body: body,
        date: DateTime.now(),
        mood: mood,
      ),
    );
    // 2. Give the repository the new list to keep.
    _repository.save(_entries);
    // 3. Tell everyone who listens. Without this line the list has changed
    // and no screen knows.
    notifyListeners();
  }

  /// Puts [changed] in the place of the entry that has the same id.
  void update(Entry changed) {
    // TODO 3: Find the place of the old entry with
    // `_entries.indexWhere((entry) => entry.id == changed.id)`. It gives -1
    // when no entry has that id: then `return`, and change nothing.
    // Otherwise put `changed` at that index of `_entries`, and do steps 2
    // and 3 as `add` does: save, then tell the listeners.
  }

  /// Removes the entry with this [id].
  void delete(int id) {
    // TODO 4: Remove the entry with
    // `_entries.removeWhere((entry) => entry.id == id)`. Then do steps 2 and
    // 3 as `add` does: save, then tell the listeners.
  }

  /// The next free id: one more than the largest id in use, or 1 for the
  /// first entry.
  int _nextId() {
    var largest = 0;
    for (final entry in _entries) {
      if (entry.id > largest) {
        largest = entry.id;
      }
    }
    return largest + 1;
  }
}
