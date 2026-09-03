import 'package:flutter/material.dart';

import '../data/competition_repository.dart';
import '../domain/competition.dart';
import '../domain/competition_statistics.dart';

class CompetitionsController extends ChangeNotifier {
  CompetitionsController(this._repository, {VoidCallback? onChanged})
    : _onChanged = onChanged ?? _doNothing,
      _competitions = _repository.getAll();

  final CompetitionRepository _repository;
  final VoidCallback _onChanged;
  List<Competition> _competitions;
  int _nextId = 0;

  List<Competition> get competitions => List.unmodifiable(_competitions);

  CompetitionStatistics get statistics =>
      CompetitionStatistics.fromCompetitions(_competitions);

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
    final updatedTeamIds = List<String>.unmodifiable(teamIds.toSet());
    final teamsChanged = !_sameIds(currentCompetition.teamIds, updatedTeamIds);
    if (teamsChanged && currentCompetition.hasConfirmedGames) return false;
    _repository.update(
      currentCompetition.copyWith(
        teamIds: updatedTeamIds,
        clearTournament: teamsChanged && currentCompetition.tournament != null,
        clearRoundRobinTournament:
            teamsChanged && currentCompetition.roundRobinTournament != null,
      ),
    );
    _refresh();
    return true;
  }

  bool generateKnockoutTournament(String competitionId) {
    final competition = _repository.getById(competitionId);
    if (competition == null ||
        competition.mode != TournamentMode.knockout ||
        competition.teamIds.length < 2 ||
        competition.tournament != null) {
      return false;
    }
    _repository.update(
      competition.copyWith(
        tournament: KnockoutTournament.generate(competition.teamIds),
      ),
    );
    _refresh();
    return true;
  }

  bool generateRoundRobinTournament(String competitionId) {
    final competition = _repository.getById(competitionId);
    if (competition == null ||
        competition.mode != TournamentMode.roundRobin ||
        competition.teamIds.length < 2 ||
        competition.roundRobinTournament != null) {
      return false;
    }
    _repository.update(
      competition.copyWith(
        roundRobinTournament: RoundRobinTournament.generate(
          competition.teamIds,
        ),
      ),
    );
    _refresh();
    return true;
  }

  bool confirmKnockoutMatchWinner({
    required String competitionId,
    required String matchId,
    required String winnerTeamId,
    Map<String, List<String>> playerIdsByTeam = const {},
  }) {
    final competition = _repository.getById(competitionId);
    final tournament = competition?.tournament;
    if (competition == null ||
        competition.mode != TournamentMode.knockout ||
        tournament == null) {
      return false;
    }
    final updatedTournament = tournament.confirmWinner(
      matchId: matchId,
      winnerTeamId: winnerTeamId,
      playerIdsByTeam: playerIdsByTeam,
    );
    if (identical(updatedTournament, tournament)) return false;
    _repository.update(competition.copyWith(tournament: updatedTournament));
    _refresh();
    return true;
  }

  bool confirmRoundRobinMatchWinner({
    required String competitionId,
    required String matchId,
    required String winnerTeamId,
    Map<String, List<String>> playerIdsByTeam = const {},
  }) {
    final competition = _repository.getById(competitionId);
    final tournament = competition?.roundRobinTournament;
    if (competition == null ||
        competition.mode != TournamentMode.roundRobin ||
        tournament == null) {
      return false;
    }
    final updatedTournament = tournament.confirmWinner(
      matchId: matchId,
      winnerTeamId: winnerTeamId,
      playerIdsByTeam: playerIdsByTeam,
    );
    if (identical(updatedTournament, tournament)) return false;
    _repository.update(
      competition.copyWith(roundRobinTournament: updatedTournament),
    );
    _refresh();
    return true;
  }

  bool clearRoundRobinMatchOutcome({
    required String competitionId,
    required String matchId,
  }) {
    final competition = _repository.getById(competitionId);
    final tournament = competition?.roundRobinTournament;
    if (competition == null || tournament == null) return false;
    final updatedTournament = tournament.clearOutcome(matchId);
    if (identical(updatedTournament, tournament)) return false;
    _repository.update(
      competition.copyWith(roundRobinTournament: updatedTournament),
    );
    _refresh();
    return true;
  }

  bool clearKnockoutOutcomePath({
    required String competitionId,
    required String matchId,
  }) {
    final competition = _repository.getById(competitionId);
    final tournament = competition?.tournament;
    if (competition == null || tournament == null) return false;
    final updatedTournament = tournament.clearOutcomePath(matchId);
    if (identical(updatedTournament, tournament)) return false;
    _repository.update(competition.copyWith(tournament: updatedTournament));
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
    final modeChanged = mode != currentCompetition.mode;
    if (modeChanged && currentCompetition.hasConfirmedGames) return false;
    _repository.update(
      currentCompetition.copyWith(
        name: trimmedName,
        mode: mode,
        color: color,
        clearTournament: modeChanged && mode != TournamentMode.knockout,
        clearRoundRobinTournament:
            modeChanged && mode != TournamentMode.roundRobin,
      ),
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
          clearTournament: competition.tournament != null,
          clearRoundRobinTournament: competition.roundRobinTournament != null,
        ),
      );
    }
    _refresh();
  }

  bool canReplaceTournamentPlan({
    required String competitionId,
    TournamentMode? mode,
    List<String>? teamIds,
  }) {
    final competition = _repository.getById(competitionId);
    if (competition == null) return false;
    final wouldChangeMode = mode != null && mode != competition.mode;
    final wouldChangeTeams =
        teamIds != null &&
        !_sameIds(
          competition.teamIds,
          List<String>.unmodifiable(teamIds.toSet()),
        );
    return (!wouldChangeMode && !wouldChangeTeams) ||
        !competition.hasConfirmedGames;
  }

  bool resetTournament(String competitionId) {
    final competition = _repository.getById(competitionId);
    if (competition == null ||
        (competition.tournament == null &&
            competition.roundRobinTournament == null)) {
      return false;
    }
    _repository.update(
      competition.copyWith(
        clearTournament: true,
        clearRoundRobinTournament: true,
      ),
    );
    _refresh();
    return true;
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

bool _sameIds(List<String> first, List<String> second) =>
    first.length == second.length && first.every((id) => second.contains(id));
