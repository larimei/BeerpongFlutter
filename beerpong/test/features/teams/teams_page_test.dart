import 'package:beerpong/app/app.dart';
import 'package:beerpong/features/players/application/players_controller.dart';
import 'package:beerpong/features/players/data/player_repository.dart';
import 'package:beerpong/features/teams/application/teams_controller.dart';
import 'package:beerpong/features/teams/data/team_repository.dart';
import 'package:beerpong/features/teams/presentation/teams_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adds a team and shows its details', (tester) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No teams yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add team'), findsOneWidget);
    final nameField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(nameField.controller?.text, isNotEmpty);
    await tester.enterText(find.byType(TextFormField), 'Champions');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Champions'), findsOneWidget);
    await tester.tap(find.text('Champions'));
    await tester.pumpAndSettle();
    expect(find.text('Team details'), findsOneWidget);
    expect(find.text('No players in this team'), findsOneWidget);
    expect(find.text('Won games'), findsOneWidget);
    expect(find.text('Lost games'), findsOneWidget);
    expect(find.text('Delete team'), findsOneWidget);
  });

  testWidgets('does not show team members on the team card', (tester) async {
    final playersController = PlayersController(InMemoryPlayerRepository());
    final teamsController = TeamsController(InMemoryTeamRepository());
    addTearDown(playersController.dispose);
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
}
