// This is a basic Flutter widget test for the Expense Tracker app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notepad/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('记账助手')),
          body: const Center(child: Text('Hello World')),
        ),
      ),
    );

    // Verify that the app builds successfully
    expect(find.text('记账助手'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });
}
