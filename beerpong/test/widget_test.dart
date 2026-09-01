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

  testWidgets('global add button opens the current page overlay', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());

    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add team'), findsOneWidget);
    expect(find.text('Add player'), findsNothing);
    expect(find.text('No players available. Add players first.'), findsNothing);
    await tester.tap(find.text('Manage players'));
    await tester.pumpAndSettle();
    expect(
      find.text('No players available. Add players first.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add competition'), findsOneWidget);
    expect(find.text('Tournament mode'), findsOneWidget);
  });
}
