import 'package:beerpong/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigates between the primary pages', (tester) async {
    await tester.pumpWidget(const BeerpongApp());

    expect(find.text('Players'), findsWidgets);

    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Teams'), findsWidgets);

    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Competitions'), findsWidgets);
  });
}
