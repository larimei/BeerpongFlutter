import 'package:beerpong/app/app.dart';
import 'package:beerpong/app/widgets/entity_card.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the empty state and competition form defaults', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.text('Competitions'));
    await tester.pumpAndSettle();

    expect(find.text('No competitions yet'), findsOneWidget);
    expect(
      find.text('Add your first competition to start a tournament.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add competition'), findsOneWidget);
    final nameField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(nameField.controller?.text, isEmpty);
    final modeField = tester.widget<DropdownButtonFormField<TournamentMode>>(
      find.byKey(const Key('competition-mode')),
    );
    expect(modeField.initialValue, TournamentMode.knockout);
    final colorPreview = tester.widget<Container>(
      find.byKey(const Key('selected-color-preview')),
    );
    final decoration = colorPreview.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFFFFD95A));

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    expect(find.text('Enter a competition name'), findsOneWidget);
  });

  testWidgets('creates competitions and immediately renders mode summaries', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.text('Competitions'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'First Cup');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('First Cup'), findsOneWidget);
    expect(find.text('Knockout - 0 teams'), findsOneWidget);
    final card = tester.widget<EntityCard>(
      find.widgetWithText(EntityCard, 'First Cup'),
    );
    expect(card.color, const Color(0xFFFFD95A));
    expect(card.icon, Icons.emoji_events_outlined);
    expect(card.onTap, isNull);

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'First Cup');
    await tester.tap(find.byKey(const Key('competition-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Round robin').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('First Cup'), findsNWidgets(2));
    expect(find.text('Knockout - 0 teams'), findsOneWidget);
    expect(find.text('Round robin - 0 teams'), findsOneWidget);
  });

  testWidgets('empty state and add form remain usable on mobile web', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.text('Competitions'));
    await tester.pumpAndSettle();

    expect(find.text('No competitions yet'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add competition'), findsOneWidget);
    expect(find.byKey(const Key('competition-mode')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
