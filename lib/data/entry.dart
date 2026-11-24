/// How the writer felt that day. An enum with data (week 2): each value
/// carries the label the app shows.
enum Mood {
  happy('Happy'),
  okay('Okay'),
  sad('Sad');

  const Mood(this.label);

  final String label;
}

/// One diary entry. Its fields are final: an entry doesn't change after it
/// is made. To edit an entry, the app makes a new one with the same id and
/// puts it in the old one's place.
class Entry {
  const Entry({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.mood,
  });

  /// A number that no other entry has. Two entries can have the same title,
  /// and a title can change, so the app finds an entry by its id. The
  /// notifier gives every new entry the next free number.
  final int id;

  final String title;
  final String body;
  final DateTime date;
  final Mood mood;
}
