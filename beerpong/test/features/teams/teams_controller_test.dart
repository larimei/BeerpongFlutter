import 'package:beerpong/features/teams/application/teams_controller.dart';
import 'package:beerpong/features/teams/data/team_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamsController', () {
    late TeamsController controller;

    setUp(() {
      controller = TeamsController(InMemoryTeamRepository());
    });

    tearDown(() => controller.dispose());

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
  });
}
