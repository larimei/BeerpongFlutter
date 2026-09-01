import 'package:beerpong/app/app.dart';
import 'package:beerpong/app/widgets/entity_card.dart';
import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:beerpong/features/competitions/presentation/competition_details_page.dart';
import 'package:beerpong/features/competitions/presentation/competitions_page.dart';
import 'package:beerpong/features/players/application/players_controller.dart';
import 'package:beerpong/features/players/data/player_repository.dart';
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

  testWidgets('does not show team members on the team card', (tester) async {
    final playersController = PlayersController(InMemoryPlayerRepository());
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(),
      competitionsController,
    );
    addTearDown(playersController.dispose);
    addTearDown(competitionsController.dispose);
    addTearDown(teamsController.dispose);

    for (final name in ['One', 'Two', 'Three', 'Four']) {
      playersController.addPlayer(name: name, color: Colors.amber);
    }
    teamsController.addTeam(
      name: 'Full team',
      playerIds: playersController.players.map((player) => player.id).toList(),
      color: Colors.amber,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TeamsPage(
          controller: teamsController,
          playersController: playersController,
        ),
      ),
    );

    expect(find.textContaining('One'), findsNothing);
    expect(find.text('4 players'), findsNothing);
    expect(tester.takeException(), isNull);
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
    final playersController = PlayersController(InMemoryPlayerRepository());
    final competitionsController = CompetitionsController(
      InMemoryCompetitionRepository(),
    );
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [team]),
      competitionsController,
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
    final playersController = PlayersController(InMemoryPlayerRepository());
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [team]),
      competitionsController,
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
    final playersController = PlayersController(InMemoryPlayerRepository());
    final teamsController = TeamsController(
      InMemoryTeamRepository(const [team]),
      competitionsController,
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
    expect(find.text('2'), findsOneWidget);

    teamsController.deleteTeam(deletedTeam.id);
    await tester.pump();

    expect(find.text('Champions'), findsNothing);
    expect(find.text('Runners-up'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('competition cards show only their name and icon', (
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
      MaterialApp(home: CompetitionsPage(controller: competitionsController)),
    );
    var card = tester.widget<EntityCard>(
      find.widgetWithText(EntityCard, 'First Cup'),
    );
    expect(card.additionalContent, isNull);
    expect(find.text('Knockout - 2 teams'), findsNothing);

    teamsController.deleteTeam(deletedTeam.id);
    await tester.pump();

    card = tester.widget<EntityCard>(
      find.widgetWithText(EntityCard, 'First Cup'),
    );
    expect(card.additionalContent, isNull);
    expect(find.text('Knockout - 1 team'), findsNothing);
  });
}
