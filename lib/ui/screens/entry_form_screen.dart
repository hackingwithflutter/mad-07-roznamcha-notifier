import 'package:material_ui/material_ui.dart';

import '../../data/entry.dart';
import '../../logic/entries_notifier.dart';
import '../widgets/mood_icon.dart';

/// Step 5 of Roznamcha: the form screen, for a new entry or for a change to
/// an old one.
///
/// In step 3 this was the add screen, and it handed the new entry back to
/// the home screen through a callback. Now one screen does two jobs. Without
/// an `entry` it adds; with an `entry` it opens filled in, and saves the
/// changes. And it hands nothing back: it tells the notifier, and every
/// screen that listens to the notifier follows.
class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({super.key, required this.notifier, this.entry});

  /// The object that holds the entries.
  final EntriesNotifier notifier;

  /// The entry to change, or null for a new entry.
  final Entry? entry;

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  // `late`: initState gives these fields their values, because the values
  // come from `widget.entry`, and a field can't read `widget` where it is
  // declared.
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  // The mood the user picked.
  late Mood _mood;

  @override
  void initState() {
    super.initState();
    // Fill the form in. `?.` and `??` are week 2's: with no entry, the
    // fields start empty and the mood is happy.
    _titleController = TextEditingController(text: widget.entry?.title);
    _bodyController = TextEditingController(text: widget.entry?.body);
    _mood = widget.entry?.mood ?? Mood.happy;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return 'Please enter a title.';
    }
    return null;
  }

  /// Runs when the user taps Save.
  void _save() {
    if (_formKey.currentState!.validate()) {
      // TODO 6: Tell the notifier, before the screen closes. Read the two
      // texts: `_titleController.text.trim()` and
      // `_bodyController.text.trim()`. If `widget.entry` is null, this is a
      // new entry: call `widget.notifier.add(...)` with the title, the body
      // and `_mood`. Otherwise it is a change: call
      // `widget.notifier.update(...)` with a new `Entry` that has the old
      // entry's `id` and `date`, and the new title, body and mood. (Copy
      // `widget.entry` into a local variable first, so Dart can promote it,
      // as app_flow.dart does with the name.)
      // `Navigator.pop` takes this screen off the stack.
      Navigator.pop(context);
    }
  }

  /// One mood the user can pick. The chip for the picked mood is filled.
  Widget _moodChip(Mood mood) {
    return ChoiceChip(
      avatar: Icon(moodIcon(mood), size: 18),
      label: Text(mood.label),
      showCheckmark: false,
      selected: _mood == mood,
      onSelected: (_) {
        setState(() {
          _mood = mood;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New entry' : 'Edit entry'),
      ),
      body: Form(
        key: _formKey,
        // A plain ListView with a few children, not ListView.builder: the
        // form is short, but it must scroll when the keyboard covers it.
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: _validateTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'What happened today?',
                // Keep the label at the top of a tall field.
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Text('Mood', style: text.titleSmall),
            const SizedBox(height: 8),
            // A Wrap is a Row that moves to a new line when it runs out of
            // width.
            Wrap(
              spacing: 8,
              children: [
                _moodChip(Mood.happy),
                _moodChip(Mood.okay),
                _moodChip(Mood.sad),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
