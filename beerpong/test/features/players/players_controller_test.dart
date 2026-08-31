import 'package:beerpong/features/players/application/players_controller.dart';
import 'package:beerpong/features/players/data/player_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayersController', () {
    late PlayersController controller;

    setUp(() {
      controller = PlayersController(InMemoryPlayerRepository());
    });

    tearDown(() => controller.dispose());

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
