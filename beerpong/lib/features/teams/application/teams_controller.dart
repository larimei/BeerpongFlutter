import 'package:flutter/material.dart';

import '../../competitions/application/competitions_controller.dart';
import '../data/team_repository.dart';
import '../domain/team.dart';

class TeamsController extends ChangeNotifier {
  TeamsController(this._repository, this._competitionsController)
    : _teams = _repository.getAll();

  final TeamRepository _repository;
  final CompetitionsController _competitionsController;
  List<Team> _teams;
  int _nextId = 0;

  List<Team> get teams => List.unmodifiable(_teams);

  Team? teamById(String id) => _repository.getById(id);

  int competitionCountForTeam(String teamId) =>
      _competitionsController.competitionCountForTeam(teamId);

  int teamCountForPlayer(String playerId) =>
      _teams.where((team) => team.playerIds.contains(playerId)).length;

  bool addTeam({
    required String name,
    required List<String> playerIds,
    required Color color,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;
    _repository.add(
      Team(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
        name: trimmedName,
        playerIds: List.unmodifiable(playerIds.toSet()),
        color: color,
      ),
    );
    _refresh();
    return true;
  }

  bool updateTeam({
    required String id,
    required String name,
    required List<String> playerIds,
    required Color color,
  }) {
    final trimmedName = name.trim();
    final currentTeam = _repository.getById(id);
    if (trimmedName.isEmpty || currentTeam == null) return false;
    _repository.update(
      currentTeam.copyWith(
        name: trimmedName,
        playerIds: playerIds.toSet().toList(),
        color: color,
      ),
    );
    _refresh();
    return true;
  }

  void deleteTeam(String id) {
    _competitionsController.removeTeamFromCompetitions(id);
    _repository.delete(id);
    _refresh();
  }

  void removePlayerFromTeams(String playerId) {
    for (final team in _teams) {
      if (!team.playerIds.contains(playerId)) continue;
      _repository.update(
        team.copyWith(
          playerIds: List.unmodifiable(
            team.playerIds.where((id) => id != playerId),
          ),
        ),
      );
    }
    _refresh();
  }

  void _refresh() {
    _teams = _repository.getAll();
    notifyListeners();
  }
}
