import 'package:material_ui/material_ui.dart';

import '../../data/entry.dart';
import '../format_date.dart';
import 'mood_icon.dart';

/// One entry in the home screen's list: a Card with a ListTile inside.
///
/// Like week 4's buttons, it doesn't know what a tap does. It calls `onTap`,
/// and whoever built the card decides.
class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, required this.onTap});

  /// The entry this card shows.
  final Entry entry;

  /// Called when the user taps the card.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // A Card is a rounded surface that lifts its child off the background.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // Without this, the tap's ripple would paint over the rounded corners.
      clipBehavior: Clip.antiAlias,
      // A ListTile is a ready-made row: something at the start (`leading`),
      // a `title` with a `subtitle` under it, and something at the end
      // (`trailing`).
      child: ListTile(
        // The four parts of the design sheet's card: the mood icon, the
        // title, the date under it, and the mood's label at the end.
        leading: Icon(moodIcon(entry.mood)),
        title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(formatDate(entry.date)),
        trailing: Text(entry.mood.label),
        onTap: onTap,
      ),
    );
  }
}
