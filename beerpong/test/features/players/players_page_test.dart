import 'package:beerpong/app/app.dart';
import 'package:beerpong/app/widgets/entity_card.dart';
import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/players/application/players_controller.dart';
import 'package:beerpong/features/players/data/player_repository.dart';
import 'package:beerpong/features/players/domain/player.dart';
import 'package:beerpong/features/players/presentation/player_details_page.dart';
import 'package:beerpong/features/players/presentation/players_page.dart';
import 'package:beerpong/features/teams/application/teams_controller.dart';
import 'package:beerpong/features/teams/data/team_repository.dart';
import 'package:beerpong/features/teams/domain/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  testWidgets(
    'long player names stay accessible without overflow on narrow displays',
    (tester) async {
      const longName = 'Alexandria-Cassandra von Extremelylongsurname';
      final competitionsController = CompetitionsController(
        InMemoryCompetitionRepository(),
      );
      final teamsController = TeamsController(
        InMemoryTeamRepository(),
        competitionsController,
      );
      final playersController = PlayersController(
        InMemoryPlayerRepository(const [
          Player(id: 'player-1', name: longName, color: Colors.amber),
          Player(id: 'player-2', name: 'Lara', color: Colors.blue),
        ]),
        teamsController,
      );
      addTearDown(competitionsController.dispose);
      addTearDown(teamsController.dispose);
      addTearDown(playersController.dispose);

      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: PlayersPage(controller: playersController),
        ),
      );

      final cardFinder = find.byType(EntityCard);
      expect(cardFinder, findsNWidgets(2));
      var cardSize = tester.getSize(cardFinder.first);
      expect(cardSize.width, cardSize.height);
      expect(tester.getSize(cardFinder.last), cardSize);

      final cardIcon = tester.widget<Icon>(
        find.descendant(of: cardFinder.first, matching: find.byType(Icon)),
      );
      expect(cardIcon.size, 40);

      final nameText = tester.widget<Text>(find.text(longName));
      expect(nameText.maxLines, lessThanOrEqualTo(2));
      expect(nameText.overflow, TextOverflow.ellipsis);
      expect(nameText.style?.fontSize, 14);
      expect(find.byTooltip(longName), findsOneWidget);
      expect(find.bySemanticsLabel(longName), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(1024, 768);
      await tester.pump();
      cardSize = tester.getSize(cardFinder.first);
      expect(cardSize.width, cardSize.height);
      expect(tester.getSize(cardFinder.last), cardSize);
      final shortNameText = tester.widget<Text>(find.text('Lara'));
      expect(shortNameText.style?.fontSize, 18);
      expect(find.byTooltip('Lara'), findsNothing);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('adds a player and opens details from a two-column card', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());
    expect(find.text('No players yet'), findsOneWidget);

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add player'), findsOneWidget);
    expect(find.text('Add Team'), findsNothing);
    expect(find.text('Add Competition'), findsNothing);
    final nameField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(nameField.controller?.text, isNotEmpty);
    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    expect(find.text('Enter a player name'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Lara');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(delegate.childAspectRatio, 1);
    expect(find.text('Won games'), findsNothing);
    expect(find.text('Lost games'), findsNothing);
    expect(find.text('Delete player'), findsNothing);

    await tester.tap(find.text('Lara'));
    await tester.pumpAndSettle();
    expect(find.text('Player details'), findsOneWidget);
    expect(find.text('Won games'), findsOneWidget);
    expect(find.text('Lost games'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('Delete player'), findsOneWidget);
    expect(find.byKey(const Key('player-details-surface')), findsOneWidget);
    final detailsBackground = tester.widget<Container>(
      find.byKey(const Key('player-details-background')),
    );
    final detailsDecoration = detailsBackground.decoration as BoxDecoration;
    final detailsGradient = detailsDecoration.gradient as LinearGradient;
    expect(detailsGradient.colors, [const Color(0xFFFFD95A), Colors.white]);
    expect(find.byKey(const Key('player-avatar')), findsOneWidget);
    final avatar = tester.widget<Container>(
      find.byKey(const Key('player-avatar')),
    );
    final avatarDecoration = avatar.decoration as BoxDecoration;
    expect(avatarDecoration.boxShadow, isNull);
    final detailsIcon = tester.widget<Icon>(
      find.byKey(const Key('player-details-icon')),
    );
    expect(detailsIcon.color, const Color(0xFFFFD95A));
  });

  testWidgets('edits and deletes a player from details only', (tester) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Jonathan');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jonathan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit player'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  Marcel  ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Marcel'), findsOneWidget);

    await tester.ensureVisible(find.text('Delete player'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete player'));
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to delete Marcel?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No players yet'), findsOneWidget);
  });

  testWidgets('assigned player warning cancels or cleans every team', (
    tester,
  ) async {
    const player = Player(
      id: 'player-1',
      name: 'Jonathan',
      color: Colors.green,
    );
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [
        Team(
          id: 'team-1',
          name: 'First Team',
          playerIds: ['player-1', 'player-2'],
          color: Colors.red,
        ),
        Team(
          id: 'team-2',
          name: 'Second Team',
          playerIds: ['player-3', 'player-1'],
          color: Colors.blue,
        ),
      ]),
      competitionsController,
    );
    final playersController = PlayersController(
      InMemoryPlayerRepository(const [player]),
      teamsController,
    );
    addTearDown(competitionsController.dispose);
    addTearDown(teamsController.dispose);
    addTearDown(playersController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: PlayerDetailsPage(
          playerId: player.id,
          controller: playersController,
        ),
      ),
    );
    await tester.ensureVisible(find.text('Delete player'));
    await tester.tap(find.text('Delete player'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Jonathan is assigned to 2 teams. Deleting it will remove it from '
        'those teams.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(playersController.playerById(player.id), same(player));
    expect(teamsController.teamById('team-1')?.playerIds, [
      'player-1',
      'player-2',
    ]);

    await tester.tap(find.text('Delete player'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(playersController.playerById(player.id), isNull);
    expect(teamsController.teamById('team-1')?.playerIds, ['player-2']);
    expect(teamsController.teamById('team-2')?.playerIds, ['player-3']);
  });

  testWidgets('color picker shows a preview and requires confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    final background = tester.widget<Container>(
      find.byKey(const Key('add-player-background')),
    );
    final backgroundDecoration = background.decoration as BoxDecoration;
    final gradient = backgroundDecoration.gradient as LinearGradient;
    expect(gradient.colors, [const Color(0xFFFFD95A), Colors.white]);
    expect(find.byKey(const Key('selected-color-preview')), findsOneWidget);
    await tester.tap(find.text('Choose color'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-color-wheel')), findsOneWidget);
    expect(find.byKey(const Key('color-picker-preview')), findsOneWidget);
    expect(find.text('Use color'), findsOneWidget);

    final wheel = tester.widget<HueRingPicker>(
      find.byKey(const Key('player-color-wheel')),
    );
    wheel.onColorChanged(Colors.blue);
    await tester.pump();
    final pickerIcon = tester.widget<Icon>(
      find.byKey(const Key('color-picker-player-icon')),
    );
    expect(pickerIcon.color, Colors.blue);

    await tester.tap(find.text('Use color'));
    await tester.pumpAndSettle();
    final addIcon = tester.widget<Icon>(
      find.byKey(const Key('add-player-icon')),
    );
    expect(addIcon.color, Colors.blue);
  });
}
