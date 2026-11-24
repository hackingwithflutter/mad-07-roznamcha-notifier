import 'package:material_ui/material_ui.dart';

import '../../data/entry.dart';
import '../../logic/entries_notifier.dart';
import '../format_date.dart';
import '../widgets/mood_icon.dart';
import 'entry_form_screen.dart';

/// Step 5 of Roznamcha: the detail screen, which shows one whole entry, and
/// can now edit and delete it.
///
/// In step 3 this screen got the entry itself, and kept it. Now it gets two
/// things: the notifier, and the id of the entry to show. It asks the
/// notifier for the entry every time it builds. So there is one copy of the
/// entry, in the notifier, and this screen can never show an old one.
class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({
    super.key,
    required this.notifier,
    required this.entryId,
  });

  /// The object that holds the entries.
  final EntriesNotifier notifier;

  /// The id of the entry to show.
  final int entryId;

  /// Opens the form screen, filled in with [entry].
  void _openEdit(BuildContext context, Entry entry) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => EntryFormScreen(notifier: notifier, entry: entry),
      ),
    );
  }

  /// Deletes this screen's entry, and closes the screen.
  void _delete(BuildContext context) {
    // Close first, then tell the notifier. The screen under this one, the
    // home screen, listens to the notifier, so its list follows by itself:
    // no callback hands anything back.
    Navigator.pop(context);
    notifier.delete(entryId);
  }

  @override
  Widget build(BuildContext context) {
    // A ListenableBuilder listens to a Listenable, and a ChangeNotifier is
    // one. It calls `builder` now, and again every time the notifier tells
    // its listeners. So after an edit on the form screen, this screen shows
    // the new text without being told by anyone but the notifier. When this
    // screen closes, the ListenableBuilder stops listening by itself.
    //
    // `child` is for a part of the screen that never changes. This screen
    // has none, so the parameter is not used.
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, child) => _buildScreen(context),
    );
  }

  /// Builds the screen from what the notifier holds at this moment.
  Widget _buildScreen(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final entry = notifier.entryById(entryId);
    // No entry has this id: it was deleted, and this screen is closing.
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Entry')),
        body: const Center(child: Text('This entry is not in your diary.')),
      );
    }
    return Scaffold(
      // No back button is written here. The AppBar adds one by itself when
      // there is a screen under this one on the Navigator's stack.
      appBar: AppBar(
        title: const Text('Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _openEdit(context, entry),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () => _delete(context),
          ),
        ],
      ),
      // A long entry can be taller than the screen, so the body scrolls.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: text.headlineSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  moodIcon(entry.mood),
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.mood.label}, ${formatDate(entry.date)}',
                  style: text.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(entry.body, style: text.bodyLarge),
          ],
        ),
      ),
    );
  }
}
