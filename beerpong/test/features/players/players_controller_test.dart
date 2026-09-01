import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/players/application/players_controller.dart';
import 'package:beerpong/features/players/data/player_repository.dart';
import 'package:beerpong/features/players/domain/player.dart';
import 'package:beerpong/features/teams/application/teams_controller.dart';
import 'package:beerpong/features/teams/data/team_repository.dart';
import 'package:beerpong/features/teams/domain/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayersController', () {
    late PlayersController controller;
    late TeamsController teamsController;
    late CompetitionsController competitionsController;

    setUp(() {
      competitionsController = CompetitionsController(
        InMemoryCompetitionRepository(),
      );
      teamsController = TeamsController(
        InMemoryTeamRepository(),
        competitionsController,
      );
      controller = PlayersController(
        InMemoryPlayerRepository(),
        teamsController,
      );
    });

    tearDown(() {
      controller.dispose();
      teamsController.dispose();
      competitionsController.dispose();
    });

    test('starts empty and adds a valid player', () {
      final added = controller.addPlayer(name: '  Lara  ', color: Colors.pink);

      expect(added, isTrue);
      expect(controller.players, hasLength(1));
      expect(controller.players.single.name, 'Lara');
      expect(controller.players.single.color, Colors.pink);
      expect(controller.players.single.won, 0);
      expect(controller.players.single.lost, 0);
    });

    test('rejects an empty player name', () {
      final added = controller.addPlayer(name: '   ', color: Colors.green);

      expect(added, isFalse);
      expect(controller.players, isEmpty);
    });

    test('deletes a player', () {
      controller.addPlayer(name: 'Jonathan', color: Colors.green);
      final id = controller.players.single.id;

      controller.deletePlayer(id);

      expect(controller.players, isEmpty);
    });

    test('deletes a player and removes it from every team', () {
      const player = Player(
        id: 'player-1',
        name: 'Jonathan',
        color: Colors.green,
      );
      competitionsController.dispose();
      competitionsController = CompetitionsController(
        InMemoryCompetitionRepository(),
      );
      teamsController.dispose();
      teamsController = TeamsController(
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
      controller.dispose();
      controller = PlayersController(
        InMemoryPlayerRepository(const [player]),
        teamsController,
      );

      expect(controller.teamCountForPlayer(player.id), 2);

      controller.deletePlayer(player.id);

      expect(controller.playerById(player.id), isNull);
      expect(teamsController.teamById('team-1')?.playerIds, ['player-2']);
      expect(teamsController.teamById('team-2')?.playerIds, ['player-3']);
      expect(teamsController.teamById('team-1')?.name, 'First Team');
      expect(teamsController.teamById('team-2')?.color, Colors.blue);
    });

    test('loads and updates a player by id', () {
      controller.addPlayer(name: 'Jonathan', color: Colors.green);
      final id = controller.players.single.id;

      final updated = controller.updatePlayer(
        id: id,
        name: '  Marcel  ',
        color: Colors.pink,
      );

      expect(updated, isTrue);
      expect(controller.playerById(id)?.name, 'Marcel');
      expect(controller.playerById(id)?.color, Colors.pink);
    });

    test('rejects an empty update and preserves the player', () {
      controller.addPlayer(name: 'Lara', color: Colors.blue);
      final id = controller.players.single.id;

      final updated = controller.updatePlayer(
        id: id,
        name: ' ',
        color: Colors.red,
      );

      expect(updated, isFalse);
      expect(controller.playerById(id)?.name, 'Lara');
      expect(controller.playerById(id)?.color, Colors.blue);
    });
  });
}
