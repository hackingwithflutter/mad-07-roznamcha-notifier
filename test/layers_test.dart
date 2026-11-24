import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The `import` lines of every Dart file in [folder] and the folders inside
/// it, each with its file's path in front.
List<String> importsIn(String folder) {
  final lines = <String>[];
  for (final item in Directory(folder).listSync(recursive: true)) {
    if (item is File && item.path.endsWith('.dart')) {
      for (final line in item.readAsLinesSync()) {
        if (line.startsWith('import ')) {
          lines.add('${item.path}: $line');
        }
      }
    }
  }
  return lines;
}

/// The lines of [imports] that contain one of [words].
List<String> thoseWith(List<String> imports, List<String> words) {
  return [
    for (final line in imports)
      if (words.any((word) => line.contains(word))) line,
  ];
}

void main() {
  // These three tests pass before and after the TODOs: the folders are given.
  // They read the files in lib/ as text. `flutter test` runs in the
  // project's folder, so `lib/data` is found.
  test('lib/ has main.dart and three folders: data, logic and ui', () {
    final names = [
      for (final item in Directory('lib').listSync())
        item.uri.pathSegments.lastWhere((part) => part.isNotEmpty),
    ]..sort();
    expect(names, ['data', 'logic', 'main.dart', 'ui']);
  });

  test('The data layer imports nothing from logic or ui, and no widgets', () {
    final imports = importsIn('lib/data');
    expect(imports, isNotEmpty);
    expect(
      thoseWith(imports, ['/logic/', '/ui/', 'material_ui', 'package:flutter']),
      isEmpty,
    );
  });

  test('The logic layer imports nothing from ui, and no widgets', () {
    final imports = importsIn('lib/logic');
    expect(imports, isNotEmpty);
    expect(
      thoseWith(imports, ['/ui/', 'material_ui', 'flutter/widgets.dart']),
      isEmpty,
    );
  });
}
