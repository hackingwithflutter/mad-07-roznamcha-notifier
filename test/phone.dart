import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Builds [widget] on a 360 x 800 screen, the size of the design.
Future<void> pumpOnPhone(WidgetTester tester, Widget widget) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(widget);
}
