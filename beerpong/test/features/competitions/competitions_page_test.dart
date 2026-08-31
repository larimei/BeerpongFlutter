import 'package:beerpong/app/app.dart';
import 'package:beerpong/app/widgets/entity_card.dart';
import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:beerpong/features/competitions/presentation/competition_details_page.dart';
import 'package:beerpong/features/competitions/presentation/competitions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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

  testWidgets('creates competitions as two-column square entity cards', (
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
    expect(find.text('Knockout - 0 teams'), findsNothing);
    final card = tester.widget<EntityCard>(
      find.widgetWithText(EntityCard, 'First Cup'),
    );
    expect(card.color, const Color(0xFFFFD95A));
    expect(card.icon, Icons.emoji_events_outlined);
    expect(card.onTap, isNotNull);
    final cardSize = tester.getSize(find.byType(EntityCard));
    expect(cardSize.width, cardSize.height);
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(delegate.childAspectRatio, 1);

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
    expect(find.text('Knockout - 0 teams'), findsNothing);
    expect(find.text('Round robin - 0 teams'), findsNothing);
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

  testWidgets('opens competition details without artificial statistics', (
    tester,
  ) async {
    final controller = _controllerWithCompetitions();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: CompetitionsPage(controller: controller)),
    );

    await tester.tap(find.text('Summer Cup'));
    await tester.pumpAndSettle();

    expect(find.text('Competition details'), findsOneWidget);
    expect(find.text('Summer Cup'), findsOneWidget);
    expect(find.text('Tournament mode'), findsOneWidget);
    expect(find.text('Knockout'), findsOneWidget);
    expect(find.text('Teams'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Competition color'), findsOneWidget);
    expect(find.byKey(const Key('competition-color-preview')), findsOneWidget);
    expect(find.text('Won games'), findsNothing);
    expect(find.text('Lost games'), findsNothing);
  });

  testWidgets('validates, cancels, and saves competition edits', (
    tester,
  ) async {
    final controller = _controllerWithCompetitions();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: CompetitionsPage(controller: controller)),
    );
    await tester.tap(find.text('Summer Cup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit competition'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    expect(find.text('Enter a competition name'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Cancelled Cup');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Summer Cup'), findsOneWidget);

    await tester.tap(find.text('Edit competition'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  Updated Cup  ');
    await tester.tap(find.byKey(const Key('edit-competition-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Round robin').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose color'));
    await tester.pumpAndSettle();
    final wheel = tester.widget<HueRingPicker>(
      find.byKey(const Key('competition-color-wheel')),
    );
    wheel.onColorChanged(Colors.blue);
    await tester.pump();
    await tester.tap(find.text('Use color'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Cup'), findsOneWidget);
    expect(find.text('Round robin'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(controller.competitions.first.color, Colors.blue);

    await tester.pageBack();
    await tester.pumpAndSettle();
    final updatedCard = tester.widget<EntityCard>(
      find.widgetWithText(EntityCard, 'Updated Cup'),
    );
    expect(updatedCard.color, Colors.blue);
  });

  testWidgets('cancels deletion or deletes only the selected competition', (
    tester,
  ) async {
    final controller = _controllerWithCompetitions();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: CompetitionsPage(controller: controller)),
    );
    await tester.tap(find.text('Summer Cup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete competition'));
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to delete Summer Cup?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Competition details'), findsOneWidget);
    expect(controller.competitions, hasLength(2));

    await tester.tap(find.text('Delete competition'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Competition details'), findsNothing);
    expect(find.text('Summer Cup'), findsNothing);
    expect(find.text('Winter Cup'), findsOneWidget);
    expect(controller.competitions, hasLength(1));
  });

  testWidgets('shows a missing message for an unknown competition', (
    tester,
  ) async {
    final controller = CompetitionsController(InMemoryCompetitionRepository());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CompetitionDetailsPage(
          competitionId: 'missing',
          controller: controller,
        ),
      ),
    );

    expect(find.text('Competition no longer exists'), findsOneWidget);
  });
}

CompetitionsController _controllerWithCompetitions() {
  return CompetitionsController(
    InMemoryCompetitionRepository(const [
      Competition(
        id: 'summer-cup',
        name: 'Summer Cup',
        mode: TournamentMode.knockout,
        color: Colors.amber,
        teamIds: ['team-1', 'team-2'],
      ),
      Competition(
        id: 'winter-cup',
        name: 'Winter Cup',
        mode: TournamentMode.roundRobin,
        color: Colors.blue,
      ),
    ]),
  );
}
