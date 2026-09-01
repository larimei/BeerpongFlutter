import 'package:flutter/material.dart';

import '../data/competition_repository.dart';
import '../domain/competition.dart';

class CompetitionsController extends ChangeNotifier {
  CompetitionsController(this._repository, {VoidCallback? onChanged})
    : _onChanged = onChanged ?? _doNothing,
      _competitions = _repository.getAll();

  final CompetitionRepository _repository;
  final VoidCallback _onChanged;
  List<Competition> _competitions;
  int _nextId = 0;

  List<Competition> get competitions => List.unmodifiable(_competitions);

  Competition? competitionById(String id) => _repository.getById(id);

  int competitionCountForTeam(String teamId) => _competitions
      .where((competition) => competition.teamIds.contains(teamId))
      .length;

  bool addCompetition({
    required String name,
    required TournamentMode mode,
    required Color color,
    List<String> teamIds = const [],
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    _repository.add(
      Competition(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
        name: trimmedName,
        mode: mode,
        color: color,
        teamIds: List.unmodifiable(teamIds.toSet()),
      ),
    );
    _refresh();
    return true;
  }

  bool updateCompetitionTeams({
    required String id,
    required List<String> teamIds,
  }) {
    final currentCompetition = _repository.getById(id);
    if (currentCompetition == null) return false;
    _repository.update(
      currentCompetition.copyWith(teamIds: List.unmodifiable(teamIds.toSet())),
    );
    _refresh();
    return true;
  }

  bool updateCompetition({
    required String id,
    required String name,
    required TournamentMode mode,
    required Color color,
  }) {
    final trimmedName = name.trim();
    final currentCompetition = _repository.getById(id);
    if (trimmedName.isEmpty || currentCompetition == null) return false;
    _repository.update(
      currentCompetition.copyWith(name: trimmedName, mode: mode, color: color),
    );
    _refresh();
    return true;
  }

  void removeTeamFromCompetitions(String teamId) {
    for (final competition in _competitions) {
      if (!competition.teamIds.contains(teamId)) continue;
      _repository.update(
        competition.copyWith(
          teamIds: List.unmodifiable(
            competition.teamIds.where((id) => id != teamId),
          ),
        ),
      );
    }
    _refresh();
  }

  void deleteCompetition(String id) {
    _repository.delete(id);
    _refresh();
  }

  void clear() {
    _repository.clear();
    _refresh();
  }

  void _refresh() {
    _competitions = _repository.getAll();
    _onChanged();
    notifyListeners();
  }
}

void _doNothing() {}
