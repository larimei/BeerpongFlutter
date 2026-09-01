import 'package:beerpong/app/app.dart';
import 'package:beerpong/app/widgets/entity_card.dart';
import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:beerpong/features/competitions/presentation/competition_details_page.dart';
import 'package:beerpong/features/competitions/presentation/competitions_page.dart';
import 'package:beerpong/features/players/application/players_controller.dart';
import 'package:beerpong/features/players/data/player_repository.dart';
import 'package:beerpong/features/players/domain/player.dart';
import 'package:beerpong/features/teams/application/teams_controller.dart';
import 'package:beerpong/features/teams/data/team_repository.dart';
import 'package:beerpong/features/teams/domain/team.dart';
import 'package:beerpong/features/teams/presentation/teams_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adds a team and shows its details', (tester) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Alice');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No teams yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add team'), findsOneWidget);
    final nameField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(nameField.controller?.text, isNotEmpty);
    await tester.enterText(find.byType(TextFormField), 'Champions');
    expect(find.text('Alice'), findsNothing);
    await tester.tap(find.text('Manage players'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add Alice'), findsOneWidget);
    await tester.tap(find.byTooltip('Add Alice'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Champions'), findsOneWidget);
    await tester.tap(find.text('Champions'));
    await tester.pumpAndSettle();
    expect(find.text('Team details'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('No players in this team'), findsNothing);
    expect(find.text('Won games'), findsOneWidget);
    expect(find.text('Lost games'), findsOneWidget);
    expect(find.text('Delete team'), findsOneWidget);
  });

  testWidgets('team cards summarize only existing members', (tester) async {
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [
        Team(
          id: 'empty',
          name: 'Empty team',
          playerIds: [],
          color: Colors.amber,
        ),
        Team(
          id: 'solo',
          name: 'Solo team',
          playerIds: ['alice'],
          color: Colors.amber,
        ),
        Team(
          id: 'pair',
          name: 'Pair team',
          playerIds: ['bob', 'charlie'],
          color: Colors.amber,
        ),
        Team(
          id: 'crowd',
          name: 'Crowd team',
          playerIds: ['alice', 'bob', 'charlie', 'delta', 'missing'],
          color: Colors.amber,
        ),
        Team(
          id: 'orphaned',
          name: 'Orphaned team',
          playerIds: ['missing'],
          color: Colors.amber,
        ),
      ]),
      competitionsController,
    );
    final playersController = PlayersController(
      InMemoryPlayerRepository(const [
        Player(id: 'alice', name: 'Alice', color: Colors.red),
        Player(id: 'bob', name: 'Bob', color: Colors.blue),
        Player(id: 'charlie', name: 'Charlie', color: Colors.green),
        Player(id: 'delta', name: 'Delta', color: Colors.orange),
      ]),
      teamsController,
    );
    addTearDown(playersController.dispose);
    addTearDown(competitionsController.dispose);
    addTearDown(teamsController.dispose);

    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: TeamsPage(
          controller: teamsController,
          playersController: playersController,
        ),
      ),
    );

    expect(find.text('No players'), findsNWidgets(2));
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);
    final memberRowSpacing =
        tester.getCenter(find.text('Charlie')).dy -
        tester.getCenter(find.text('Bob')).dy;
    expect(memberRowSpacing, inExclusiveRange(0, 24));
    expect(find.text('4 players'), findsOneWidget);
    expect(find.text('missing'), findsNothing);
    expect(tester.widget<Text>(find.text('Empty team')).style?.fontSize, 16);
    expect(tester.widget<Text>(find.text('Alice')).style?.fontSize, 12);
    expect(tester.widget<Text>(find.text('4 players')).style?.fontSize, 12);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long team and member names stay accessible on narrow cards', (
    tester,
  ) async {
    const teamName = 'The Incredibly Long Championship Team Name';
    const firstPlayerName = 'Alexandria-Cassandra Extremelylongsurname';
    const secondPlayerName = 'Maximilian-Alexander Anotherlongsurname';
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [
        Team(
          id: 'team-1',
          name: teamName,
          playerIds: ['player-1', 'player-2'],
          color: Colors.amber,
        ),
        Team(
          id: 'team-2',
          name: 'Short pair',
          playerIds: ['player-3', 'player-4'],
          color: Colors.blue,
        ),
      ]),
      competitionsController,
    );
    final playersController = PlayersController(
      InMemoryPlayerRepository(const [
        Player(id: 'player-1', name: firstPlayerName, color: Colors.red),
        Player(id: 'player-2', name: secondPlayerName, color: Colors.blue),
        Player(id: 'player-3', name: 'Bob', color: Colors.green),
        Player(id: 'player-4', name: 'Mia', color: Colors.orange),
      ]),
      teamsController,
    );
    addTearDown(playersController.dispose);
    addTearDown(competitionsController.dispose);
    addTearDown(teamsController.dispose);

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: TeamsPage(
          controller: teamsController,
          playersController: playersController,
        ),
      ),
    );

    expect(find.byType(EntityCard), findsNWidgets(2));
    final cardSize = tester.getSize(find.byType(EntityCard).first);
    expect(cardSize.width, cardSize.height);
    for (final name in [teamName, firstPlayerName, secondPlayerName]) {
      expect(find.byTooltip(name), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(RegExp.escape(name))),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('unassigned team keeps the existing delete confirmation', (
    tester,
  ) async {
    const team = Team(
      id: 'team-1',
      name: 'Champions',
      playerIds: [],
      color: Colors.amber,
    );
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [team]),
      competitionsController,
    );
    final playersController = PlayersController(
      InMemoryPlayerRepository(),
      teamsController,
    );
    addTearDown(playersController.dispose);
    addTearDown(competitionsController.dispose);
    addTearDown(teamsController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: TeamsPage(
          controller: teamsController,
          playersController: playersController,
        ),
      ),
    );
    await tester.tap(find.text('Champions'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete team'));
    await tester.tap(find.text('Delete team'));
    await tester.pumpAndSettle();

    expect(
      find.text('Are you sure you want to delete Champions?'),
      findsOneWidget,
    );
  });

  testWidgets('assigned team warning shows count and cancel changes nothing', (
    tester,
  ) async {
    const team = Team(
      id: 'team-1',
      name: 'Champions',
      playerIds: [],
      color: Colors.amber,
    );
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'cup-1',
          name: 'First Cup',
          mode: TournamentMode.knockout,
          color: Colors.red,
          teamIds: ['team-1'],
        ),
        Competition(
          id: 'cup-2',
          name: 'Second Cup',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
          teamIds: ['team-1', 'team-2'],
        ),
      ]),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [team]),
      competitionsController,
    );
    final playersController = PlayersController(
      InMemoryPlayerRepository(),
      teamsController,
    );
    addTearDown(competitionsController.dispose);
    addTearDown(playersController.dispose);
    addTearDown(teamsController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: TeamsPage(
          controller: teamsController,
          playersController: playersController,
        ),
      ),
    );
    await tester.tap(find.text('Champions'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete team'));
    await tester.tap(find.text('Delete team'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Champions is assigned to 2 competitions. Deleting it will remove '
        'it from those competitions.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(teamsController.teamById(team.id), same(team));
    expect(competitionsController.competitionById('cup-1')?.teamIds, [
      'team-1',
    ]);
    expect(competitionsController.competitionById('cup-2')?.teamIds, [
      'team-1',
      'team-2',
    ]);
  });

  testWidgets('confirming assigned team deletion cleans memberships', (
    tester,
  ) async {
    const team = Team(
      id: 'team-1',
      name: 'Champions',
      playerIds: [],
      color: Colors.amber,
    );
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'cup-1',
          name: 'First Cup',
          mode: TournamentMode.knockout,
          color: Colors.red,
          teamIds: ['team-1', 'team-2'],
        ),
        Competition(
          id: 'cup-2',
          name: 'Second Cup',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
          teamIds: ['team-3', 'team-1'],
        ),
      ]),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [team]),
      competitionsController,
    );
    final playersController = PlayersController(
      InMemoryPlayerRepository(),
      teamsController,
    );
    addTearDown(competitionsController.dispose);
    addTearDown(playersController.dispose);
    addTearDown(teamsController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: TeamsPage(
          controller: teamsController,
          playersController: playersController,
        ),
      ),
    );
    await tester.tap(find.text('Champions'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete team'));
    await tester.tap(find.text('Delete team'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No teams yet'), findsOneWidget);
    expect(teamsController.teams, isEmpty);
    expect(competitionsController.competitionById('cup-1')?.teamIds, [
      'team-2',
    ]);
    expect(competitionsController.competitionById('cup-2')?.teamIds, [
      'team-3',
    ]);
  });

  testWidgets('open competition details update immediately after deletion', (
    tester,
  ) async {
    const deletedTeam = Team(
      id: 'team-1',
      name: 'Champions',
      playerIds: [],
      color: Colors.amber,
    );
    const remainingTeam = Team(
      id: 'team-2',
      name: 'Runners-up',
      playerIds: [],
      color: Colors.blue,
    );
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'cup-1',
          name: 'First Cup',
          mode: TournamentMode.knockout,
          color: Colors.red,
          teamIds: ['team-1', 'team-2'],
        ),
      ]),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [deletedTeam, remainingTeam]),
      competitionsController,
    );
    addTearDown(competitionsController.dispose);
    addTearDown(teamsController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CompetitionDetailsPage(
          competitionId: 'cup-1',
          controller: competitionsController,
          teams: const [deletedTeam, remainingTeam],
        ),
      ),
    );
    expect(find.text('Champions'), findsOneWidget);
    expect(find.text('Runners-up'), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(2));

    teamsController.deleteTeam(deletedTeam.id);
    await tester.pump();

    expect(find.text('Champions'), findsNothing);
    expect(find.text('Runners-up'), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
  });

  testWidgets('competition cards update valid team metadata after deletion', (
    tester,
  ) async {
    const deletedTeam = Team(
      id: 'team-1',
      name: 'Champions',
      playerIds: [],
      color: Colors.amber,
    );
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'cup-1',
          name: 'First Cup',
          mode: TournamentMode.knockout,
          color: Colors.red,
          teamIds: ['team-1', 'team-2'],
        ),
      ]),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [deletedTeam]),
      competitionsController,
    );
    addTearDown(competitionsController.dispose);
    addTearDown(teamsController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CompetitionsPage(
          controller: competitionsController,
          teams: teamsController.teams,
        ),
      ),
    );
    var card = tester.widget<EntityCard>(
      find.widgetWithText(EntityCard, 'First Cup'),
    );
    expect(card.additionalContent, isA<EntityCardText>());
    expect(find.text('Knockout · 1 team'), findsOneWidget);

    teamsController.deleteTeam(deletedTeam.id);
    await tester.pump();

    card = tester.widget<EntityCard>(
      find.widgetWithText(EntityCard, 'First Cup'),
    );
    expect(card.additionalContent, isA<EntityCardText>());
    expect(find.text('Knockout · 0 teams'), findsOneWidget);
  });
}
