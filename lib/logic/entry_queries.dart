import '../data/entry.dart';

/// The orders the home screen can show the entries in.
enum SortOrder { newestFirst, oldestFirst, titleAToZ }

/// Returns the entries whose title contains [query].
///
/// Upper and lower case don't matter: `chai` finds `Chai with Zain`. Spaces
/// at both ends of [query] don't matter either. An empty [query] keeps every
/// entry.
List<Entry> searchEntries(List<Entry> entries, String query) {
  // `where` keeps the items that pass a test, `contains` is the test, and
  // `toList` makes a new list. Both texts are in lower case, so upper and
  // lower case don't matter.
  final text = query.trim().toLowerCase();
  return entries
      .where((entry) => entry.title.toLowerCase().contains(text))
      .toList();
}

/// Returns a new list with the same entries in the given [order].
///
/// The list it was given stays as it is.
List<Entry> sortEntries(List<Entry> entries, SortOrder order) {
  // `sort` changes the list it is called on, so this sorts a copy. The
  // function given to `sort` compares two entries, `a` and `b`. Newest first
  // compares `b` with `a`, which turns the order round.
  final sorted = [...entries];
  switch (order) {
    case SortOrder.newestFirst:
      sorted.sort((a, b) => b.date.compareTo(a.date));
    case SortOrder.oldestFirst:
      sorted.sort((a, b) => a.date.compareTo(b.date));
    case SortOrder.titleAToZ:
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
  }
  return sorted;
}
