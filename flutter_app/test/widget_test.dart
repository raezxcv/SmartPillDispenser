import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smartdose/main.dart';

void main() {
  testWidgets('App renders role selection screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartDoseApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
