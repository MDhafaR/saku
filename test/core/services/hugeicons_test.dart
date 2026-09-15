import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  testWidgets('HugeIcon widget test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HugeIcon(
            icon: HugeIcons.strokeRoundedRestaurant01,
            color: Colors.blue,
            size: 24,
          ),
        ),
      ),
    );

    expect(find.byType(HugeIcon), findsOneWidget);
  });
}
