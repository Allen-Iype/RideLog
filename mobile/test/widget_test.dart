// Basic Flutter widget test for RideLog
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('RideLog app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RideLogApp());

    // Verify that the app shows RideLog title
    expect(find.text('RideLog'), findsOneWidget);

    // Verify that the Start Ride button exists
    expect(find.text('Start Ride'), findsOneWidget);
  });
}
