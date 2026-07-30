import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_pill_dispenser/main.dart';

void main() {
  testWidgets('App renders role selection screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartPillDispenserApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
