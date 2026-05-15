import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinewave/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CineWaveApp());

    // Verify that the app loads without crashing
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
