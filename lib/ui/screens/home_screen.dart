import 'package:material_ui/material_ui.dart';

import '../../data/entry.dart';
import '../../data/sample_entries.dart';
import '../../data/weather.dart';
import '../../logic/entries_notifier.dart';
import '../../logic/entry_queries.dart';
import '../widgets/entry_card.dart';
import '../widgets/weather_line.dart';
import 'entry_detail_screen.dart';
import 'entry_form_screen.dart';

/// Step 5 of Roznamcha: the home screen.
///
/// It greets the user, shows the current temperature, and shows the diary's
/// entries in a list that the user can search and sort. A tap on an entry
/// opens its detail screen, and the + button opens the form screen.
///
/// It is a StatefulWidget, because it has things to remember that belong to
/// this screen alone: the search text and the chosen order. The entries
/// belong to the whole app, so they live in the notifier.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.name,
    required this.notifier,
    required this.loadWeather,
  });

  /// The name from the form, given to this screen by app_flow.dart.
  final String name;

  /// The object that holds the entries. This screen hands it on to the
  /// detail screen and the form screen.
  final EntriesNotifier notifier;

  /// The function that loads the weather, for the weather line.
  final WeatherLoader loadWeather;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO 5: Refactor this screen. It still keeps its own copy of the
  // entries, `_entries`, as it did in step 4. So it never sees what the
  // other screens add, change or delete through the notifier. Make the
  // notifier the only place the entries come from:
  //   1. Delete the `_entries` field, and the import of sample_entries.dart
  //      that only this field uses.
  //   2. In `_buildEntries`, read `widget.notifier.entries` where the code
  //      reads `_entries`.
  //   3. In `build`, wrap the call `_buildEntries()` in a
  //      `ListenableBuilder` whose `listenable` is `widget.notifier`, as
  //      entry_detail_screen.dart does, so the list builds again when the
  //      notifier tells its listeners.
  // Nothing else on the screen changes: the search, the sort, the weather
  // line and the + button work as before.
  // The state. `[...sampleEntries]` copies the sample data into a new list
  // that this screen owns.
  final List<Entry> _entries = [...sampleEntries];
  String _query = '';
  SortOrder _order = SortOrder.newestFirst;

  /// Opens the detail screen for [entry].
  void _openEntry(Entry entry) {
    // The detail screen gets the notifier and the entry's id through its
    // constructor, inside the route's `builder`. It gets the id, not the
    // entry: it asks the notifier for the entry each time it builds.
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            EntryDetailScreen(notifier: widget.notifier, entryId: entry.id),
      ),
    );
  }

  /// Opens the form screen, empty, for a new entry.
  void _openAddEntry() {
    // No callback comes back from the form screen any more. It gets the
    // notifier, and tells the notifier about the new entry.
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => EntryFormScreen(notifier: widget.notifier),
      ),
    );
  }

  /// Builds the part of the screen under the search field: the entries that
  /// match the search, in the chosen order, or a message when none does.
  Widget _buildEntries() {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // The list on the screen is not stored: every build computes it. Search
    // first, then sort what is left. The entries themselves never change
    // order.
    final visible = sortEntries(searchEntries(_entries, _query), _order);
    if (visible.isEmpty) {
      return Center(
        child: Text(
          'No entries match your search.',
          style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
      );
    }
    // ListView.builder builds a row only when it is about to appear. Flutter
    // calls `itemBuilder` with the index of each row it needs. The padding
    // at the bottom leaves room for the + button.
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final entry = visible[index];
        return EntryCard(entry: entry, onTap: () => _openEntry(entry));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roznamcha'),
        // `actions` are the buttons at the end of the AppBar.
        actions: [
          // A button that opens a small menu. A tap on an item calls
          // `onSelected` with that item's `value`.
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            initialValue: _order,
            onSelected: (order) {
              setState(() {
                _order = order;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortOrder.newestFirst,
                child: Text('Newest first'),
              ),
              PopupMenuItem(
                value: SortOrder.oldestFirst,
                child: Text('Oldest first'),
              ),
              PopupMenuItem(
                value: SortOrder.titleAToZ,
                child: Text('Title A to Z'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Hi, ${widget.name}',
              style: text.headlineSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // The weather line loads the weather by itself and shows one of
          // its three states. This screen only hands it the function.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WeatherLine(loadWeather: widget.loadWeather),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // A plain TextField: nothing to validate, so no Form. `onChanged`
            // runs on every key press, so the list follows the typing.
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search your entries',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              // A tap anywhere else closes the keyboard.
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          // Expanded gives the list all the height that is left. A list that
          // scrolls needs to know its height.
          Expanded(child: _buildEntries()),
        ],
      ),
      // The round button that floats over the list, bottom right.
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntry,
        tooltip: 'Add an entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
