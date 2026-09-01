import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:beerpong/features/teams/application/teams_controller.dart';
import 'package:beerpong/features/teams/data/team_repository.dart';
import 'package:beerpong/features/teams/domain/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamsController', () {
    late TeamsController controller;
    late CompetitionsController competitionsController;

    setUp(() {
      competitionsController = CompetitionsController(
        InMemoryCompetitionRepository(),
      );
      controller = TeamsController(
        InMemoryTeamRepository(),
        competitionsController,
      );
    });

    tearDown(() {
      controller.dispose();
      competitionsController.dispose();
    });

    test('adds a team with unique player ids', () {
      final added = controller.addTeam(
        name: '  Winners  ',
        playerIds: ['p1', 'p2', 'p1'],
        color: Colors.blue,
      );

      expect(added, isTrue);
      expect(controller.teams.single.name, 'Winners');
      expect(controller.teams.single.playerIds, ['p1', 'p2']);
      expect(controller.teams.single.won, 0);
      expect(controller.teams.single.lost, 0);
    });

    test('updates members and deletes a team', () {
      controller.addTeam(
        name: 'Winners',
        playerIds: ['p1'],
        color: Colors.blue,
      );
      final team = controller.teams.single;

      final updated = controller.updateTeam(
        id: team.id,
        name: 'New Winners',
        playerIds: ['p2'],
        color: Colors.red,
      );

      expect(updated, isTrue);
      expect(controller.teamById(team.id)?.playerIds, ['p2']);
      controller.deleteTeam(team.id);
      expect(controller.teams, isEmpty);
    });

    test('rejects empty names', () {
      expect(
        controller.addTeam(name: ' ', playerIds: const [], color: Colors.blue),
        isFalse,
      );
    });

    test('reports how many competitions contain a team', () {
      competitionsController.dispose();
      competitionsController = CompetitionsController(
        InMemoryCompetitionRepository(const [
          Competition(
            id: 'cup-1',
            name: 'First Cup',
            mode: TournamentMode.knockout,
            color: Colors.amber,
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
      controller.dispose();
      controller = TeamsController(
        InMemoryTeamRepository(),
        competitionsController,
      );

      expect(controller.competitionCountForTeam('team-1'), 2);
      expect(controller.competitionCountForTeam('team-2'), 1);
      expect(controller.competitionCountForTeam('unassigned'), 0);
    });

    test('deletes a team and removes it from every competition', () {
      const deletedTeam = Team(
        id: 'team-1',
        name: 'Winners',
        playerIds: [],
        color: Colors.red,
      );
      competitionsController.dispose();
      competitionsController = CompetitionsController(
        InMemoryCompetitionRepository(const [
          Competition(
            id: 'cup-1',
            name: 'First Cup',
            mode: TournamentMode.knockout,
            color: Colors.amber,
            teamIds: ['team-1', 'team-2'],
          ),
          Competition(
            id: 'cup-2',
            name: 'Second Cup',
            mode: TournamentMode.roundRobin,
            color: Colors.blue,
            teamIds: ['team-3', 'team-1'],
          ),
          Competition(
            id: 'cup-3',
            name: 'Unaffected Cup',
            mode: TournamentMode.knockout,
            color: Colors.green,
            teamIds: ['team-2'],
          ),
        ]),
      );
      controller.dispose();
      controller = TeamsController(
        InMemoryTeamRepository(const [deletedTeam]),
        competitionsController,
      );

      controller.deleteTeam(deletedTeam.id);

      expect(controller.teamById(deletedTeam.id), isNull);
      expect(competitionsController.competitionById('cup-1')?.teamIds, [
        'team-2',
      ]);
      expect(competitionsController.competitionById('cup-2')?.teamIds, [
        'team-3',
      ]);
      expect(competitionsController.competitionById('cup-3')?.teamIds, [
        'team-2',
      ]);
      expect(
        competitionsController.competitionById('cup-1')?.name,
        'First Cup',
      );
      expect(
        competitionsController.competitionById('cup-2')?.mode,
        TournamentMode.roundRobin,
      );
      expect(
        competitionsController.competitionById('cup-3')?.color,
        Colors.green,
      );
    });
  });
}
