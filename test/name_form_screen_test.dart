import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:roznamcha/ui/screens/name_form_screen.dart';

import 'phone.dart';

/// Builds the name form alone, on the phone-sized screen, with [onSubmit].
Future<void> pumpForm(
  WidgetTester tester, {
  ValueChanged<String>? onSubmit,
}) async {
  await pumpOnPhone(
    tester,
    MaterialApp(home: NameFormScreen(onSubmit: onSubmit ?? (_) {})),
  );
}

void main() {
  // Week 4's tests. All six pass: the name form is given code now.
  testWidgets('The form shows a title, one text field and a Continue button', (
    tester,
  ) async {
    await pumpForm(tester);
    expect(find.text('What is your name?'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
  });

  testWidgets('Nothing overflows on the form', (tester) async {
    await pumpForm(tester);
    expect(tester.takeException(), isNull);
  });

  // Week 4, TODO 3
  testWidgets('The name field\'s controller is disposed with the form', (
    tester,
  ) async {
    await pumpForm(tester);
    final controller = tester
        .widget<TextField>(find.byType(TextField))
        .controller!;
    // Replace the whole app with an empty box, so the form leaves the tree
    // and Flutter calls its dispose.
    await tester.pumpWidget(const SizedBox());
    // A disposed controller refuses new listeners.
    expect(() => controller.addListener(() {}), throwsFlutterError);
  });

  // Week 4, TODO 4
  testWidgets('An empty name, or only spaces, shows an error', (tester) async {
    await pumpForm(tester);
    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please enter your name.'), findsOneWidget);
    // Spaces are not a name either: the validator trims first.
    await tester.enterText(find.byType(TextFormField), '   ');
    expect(form.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please enter your name.'), findsOneWidget);
  });

  testWidgets('A one-letter name shows an error, and a real name clears it', (
    tester,
  ) async {
    await pumpForm(tester);
    final field = find.byType(TextFormField);
    final form = tester.state<FormState>(find.byType(Form));
    await tester.enterText(field, 'A');
    expect(form.validate(), isFalse);
    await tester.pump();
    expect(find.text('A name needs at least 2 letters.'), findsOneWidget);
    await tester.enterText(field, 'Ali');
    expect(form.validate(), isTrue);
    await tester.pump();
    expect(find.text('A name needs at least 2 letters.'), findsNothing);
  });

  // Week 4, TODO 5
  testWidgets(
    'Continue with a valid name calls onSubmit with the trimmed name',
    (tester) async {
      String? submitted;
      await pumpForm(tester, onSubmit: (value) => submitted = value);
      await tester.enterText(find.byType(TextFormField), '  Ali ');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(submitted, 'Ali');
    },
  );
}
