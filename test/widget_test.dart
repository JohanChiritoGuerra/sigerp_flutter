// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sigerp_flutter/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const SigerpApp());

    // Allow the splash screen delay to complete and settle navigation.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that the MaterialApp widget is present.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
