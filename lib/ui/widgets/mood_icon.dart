import 'package:material_ui/material_ui.dart';

import '../../data/entry.dart';

/// The icon the app shows for a mood. A switch on an enum must cover every
/// value (week 2), so a new mood can't be forgotten here.
IconData moodIcon(Mood mood) {
  return switch (mood) {
    Mood.happy => Icons.sentiment_satisfied_alt,
    Mood.okay => Icons.sentiment_neutral,
    Mood.sad => Icons.sentiment_dissatisfied,
  };
}
