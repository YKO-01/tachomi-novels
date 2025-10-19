// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tachomi_novel/main.dart';

void main() {
  testWidgets('App starts and shows library page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TachomiNovelApp(),
      ),
    );

    // Verify that the app starts and shows the library page
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Tachomi Novel'), findsNothing); // App name should not be visible in the body
  });
}
