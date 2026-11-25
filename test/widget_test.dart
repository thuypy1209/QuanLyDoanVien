import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlidoanvien/Views/Auth/WelcomeView.dart';

void main() {
  testWidgets('WelcomeView smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeView(),
      ),
    );
    expect(find.byType(WelcomeView), findsOneWidget);
  });
}
