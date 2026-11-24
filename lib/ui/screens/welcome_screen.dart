import 'package:material_ui/material_ui.dart';

/// Step 1 of Roznamcha: the welcome screen, built in week 3.
///
/// Step 2 gave it a callback for the button. The screen doesn't know what
/// happens after "Get started". Whoever builds the screen decides, by
/// passing a function in `onGetStarted` (see app_flow.dart).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onGetStarted});

  /// Called when the user taps "Get started". A function stored in a field.
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) walks up the tree to the MaterialApp and gives you
    // its colours and text styles. Never write a colour or a size by hand
    // when the theme already has it.
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      // SafeArea keeps the content away from the notch and the status bar.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          // A Column lays its children out top to bottom.
          child: Column(
            children: [
              // Two equal Spacers: the button sits at the bottom and the rest
              // is centred.
              const Spacer(),
              // A Stack draws its children on top of each other: the circle
              // first, then the illustration.
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset(
                    'assets/images/welcome.png',
                    width: 180,
                    height: 180,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Roznamcha',
                textAlign: TextAlign.center,
                style: text.displaySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Assalam o Alaikum! Keep a diary of your days.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              // Three FeatureItems in a Row, each in an Expanded, so the three
              // share the width equally.
              const Row(
                children: [
                  Expanded(child: FeatureItem(Icons.edit_note, 'Write')),
                  Expanded(child: FeatureItem(Icons.mood, 'Mood')),
                  Expanded(child: FeatureItem(Icons.lock_outline, 'Private')),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      // The callback this screen was given: a function as a
                      // value, with no parentheses. A tap reaches app_flow.dart.
                      onPressed: onGetStarted,
                      child: const Text('Get started'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One small feature: an icon above a label. Composition: the screen is
/// built from three of these, not from three copies of the same code.
class FeatureItem extends StatelessWidget {
  const FeatureItem(this.icon, this.label, {super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, size: 32, color: colors.primary),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
