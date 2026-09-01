import 'package:flutter/material.dart';

import '../../teams/application/teams_controller.dart';
import '../data/player_repository.dart';
import '../domain/player.dart';

class PlayersController extends ChangeNotifier {
  PlayersController(this._repository, this._teamsController)
    : _players = _repository.getAll();

  final PlayerRepository _repository;
  final TeamsController _teamsController;
  List<Player> _players;
  int _nextId = 0;

  List<Player> get players => List.unmodifiable(_players);

  Player? playerById(String id) => _repository.getById(id);

  int teamCountForPlayer(String playerId) =>
      _teamsController.teamCountForPlayer(playerId);

  bool addPlayer({required String name, required Color color}) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    final player = Player(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
      name: trimmedName,
      color: color,
    );
    _repository.add(player);
    _refresh();
    return true;
  }

  void deletePlayer(String id) {
    _teamsController.removePlayerFromTeams(id);
    _repository.delete(id);
    _refresh();
  }

  bool updatePlayer({
    required String id,
    required String name,
    required Color color,
  }) {
    final trimmedName = name.trim();
    final currentPlayer = _repository.getById(id);
    if (trimmedName.isEmpty || currentPlayer == null) return false;

    _repository.update(currentPlayer.copyWith(name: trimmedName, color: color));
    _refresh();
    return true;
  }

  void _refresh() {
    _players = _repository.getAll();
    notifyListeners();
  }
}
