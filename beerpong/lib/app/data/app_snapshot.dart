import 'dart:convert';

import 'package:flutter/material.dart';

import '../../features/competitions/domain/competition.dart';
import '../../features/players/domain/player.dart';
import '../../features/teams/domain/team.dart';

/// The part of the application that is persisted between browser sessions.
class AppSnapshot {
  const AppSnapshot({
    required this.players,
    required this.teams,
    required this.competitions,
  });

  const AppSnapshot.empty()
    : players = const [],
      teams = const [],
      competitions = const [];

  static const currentVersion = 1;

  final List<Player> players;
  final List<Team> teams;
  final List<Competition> competitions;

  AppSnapshot sanitized() {
    final playersById = <String, Player>{};
    for (final player in players) {
      if (player.id.isNotEmpty) {
        playersById.putIfAbsent(player.id, () => player);
      }
    }
    final teamsById = <String, Team>{};
    for (final team in teams) {
      if (team.id.isEmpty || teamsById.containsKey(team.id)) continue;
      teamsById[team.id] = team.copyWith(
        playerIds: team.playerIds
            .where(playersById.containsKey)
            .toSet()
            .toList(),
      );
    }
    final competitionsById = <String, Competition>{};
    for (final competition in competitions) {
      if (competition.id.isEmpty ||
          competitionsById.containsKey(competition.id)) {
        continue;
      }
      competitionsById[competition.id] = competition.copyWith(
        teamIds: competition.teamIds
            .where(teamsById.containsKey)
            .toSet()
            .toList(),
      );
    }
    return AppSnapshot(
      players: List.unmodifiable(playersById.values),
      teams: List.unmodifiable(teamsById.values),
      competitions: List.unmodifiable(competitionsById.values),
    );
  }

  String encode() => jsonEncode({
    'version': currentVersion,
    'players': players.map(_playerToJson).toList(),
    'teams': teams.map(_teamToJson).toList(),
    'competitions': competitions.map(_competitionToJson).toList(),
  });

  static AppSnapshot? tryDecode(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic> ||
          decoded['version'] != currentVersion) {
        return null;
      }
      final players = _decodeList(decoded['players'], _playerFromJson);
      final teams = _decodeList(decoded['teams'], _teamFromJson);
      final competitions = _decodeList(
        decoded['competitions'],
        _competitionFromJson,
      );
      if (players == null || teams == null || competitions == null) return null;
      return AppSnapshot(
        players: players,
        teams: teams,
        competitions: competitions,
      ).sanitized();
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

Map<String, Object> _playerToJson(Player player) => {
  'id': player.id,
  'name': player.name,
  'color': player.color.toARGB32(),
  'won': player.won,
  'lost': player.lost,
};

Map<String, Object> _teamToJson(Team team) => {
  'id': team.id,
  'name': team.name,
  'playerIds': team.playerIds,
  'color': team.color.toARGB32(),
  'won': team.won,
  'lost': team.lost,
};

Map<String, Object> _competitionToJson(Competition competition) => {
  'id': competition.id,
  'name': competition.name,
  'mode': competition.mode.name,
  'color': competition.color.toARGB32(),
  'teamIds': competition.teamIds,
  if (competition.tournament != null)
    'tournament': {
      'drawOrder': competition.tournament!.drawOrder,
      'bracketSize': competition.tournament!.bracketSize,
      'matches': competition.tournament!.matches
          .map(
            (match) => {
              'id': match.id,
              'round': match.round,
              'index': match.index,
              'teamIds': match.teamIds,
              'winnerTeamId': match.winnerTeamId,
              'isBye': match.isBye,
              'playerIdsByTeam': match.playerIdsByTeam,
            },
          )
          .toList(),
    },
  if (competition.roundRobinTournament != null)
    'roundRobinTournament': {
      'drawOrder': competition.roundRobinTournament!.drawOrder,
      'matches': competition.roundRobinTournament!.matches
          .map(
            (match) => {
              'id': match.id,
              'teamIds': match.teamIds,
              'winnerTeamId': match.winnerTeamId,
              'playerIdsByTeam': match.playerIdsByTeam,
            },
          )
          .toList(),
    },
};

typedef _JsonDecoder<T> = T? Function(Map<String, dynamic> json);

List<T>? _decodeList<T>(Object? value, _JsonDecoder<T> decoder) {
  if (value is! List) return null;
  final results = <T>[];
  for (final item in value) {
    if (item is! Map) return null;
    final decoded = decoder(Map<String, dynamic>.from(item));
    if (decoded == null) return null;
    results.add(decoded);
  }
  return results;
}

Player? _playerFromJson(Map<String, dynamic> json) {
  final id = json['id'];
  final name = json['name'];
  final color = json['color'];
  final won = json['won'];
  final lost = json['lost'];
  if (id is! String ||
      name is! String ||
      color is! int ||
      won is! int ||
      lost is! int) {
    return null;
  }
  return Player(id: id, name: name, color: Color(color), won: won, lost: lost);
}

Team? _teamFromJson(Map<String, dynamic> json) {
  final id = json['id'];
  final name = json['name'];
  final color = json['color'];
  final won = json['won'];
  final lost = json['lost'];
  final playerIds = _stringList(json['playerIds']);
  if (id is! String ||
      name is! String ||
      color is! int ||
      won is! int ||
      lost is! int ||
      playerIds == null) {
    return null;
  }
  return Team(
    id: id,
    name: name,
    playerIds: playerIds,
    color: Color(color),
    won: won,
    lost: lost,
  );
}

Competition? _competitionFromJson(Map<String, dynamic> json) {
  final id = json['id'];
  final name = json['name'];
  final mode = json['mode'];
  final color = json['color'];
  final teamIds = _stringList(json['teamIds']);
  if (id is! String ||
      name is! String ||
      mode is! String ||
      color is! int ||
      teamIds == null) {
    return null;
  }
  final tournamentMode = switch (mode) {
    'knockout' => TournamentMode.knockout,
    'roundRobin' => TournamentMode.roundRobin,
    _ => null,
  };
  if (tournamentMode == null) return null;
  final tournament = _tournamentFromJson(json['tournament']);
  if (json.containsKey('tournament') && tournament == null) return null;
  final roundRobinTournament = _roundRobinTournamentFromJson(
    json['roundRobinTournament'],
  );
  if (json.containsKey('roundRobinTournament') &&
      roundRobinTournament == null) {
    return null;
  }
  return Competition(
    id: id,
    name: name,
    mode: tournamentMode,
    color: Color(color),
    teamIds: teamIds,
    tournament: tournament,
    roundRobinTournament: roundRobinTournament,
  );
}

RoundRobinTournament? _roundRobinTournamentFromJson(Object? value) {
  if (value == null) return null;
  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final drawOrder = _stringList(json['drawOrder']);
  final rawMatches = json['matches'];
  if (drawOrder == null || rawMatches is! List) return null;
  final matches = <RoundRobinMatch>[];
  for (final rawMatch in rawMatches) {
    if (rawMatch is! Map) return null;
    final match = Map<String, dynamic>.from(rawMatch);
    final id = match['id'];
    final teamIds = _stringList(match['teamIds']);
    final winner = match['winnerTeamId'];
    final playerIdsByTeam = _playerIdsByTeam(match['playerIdsByTeam']);
    if (id is! String ||
        teamIds == null ||
        teamIds.length != 2 ||
        (winner != null && winner is! String) ||
        playerIdsByTeam == null) {
      return null;
    }
    matches.add(
      RoundRobinMatch(
        id: id,
        teamIds: teamIds,
        winnerTeamId: winner,
        playerIdsByTeam: playerIdsByTeam,
      ),
    );
  }
  if (matches.isEmpty) return null;
  return RoundRobinTournament(
    drawOrder: drawOrder,
    matches: List.unmodifiable(matches),
  );
}

KnockoutTournament? _tournamentFromJson(Object? value) {
  if (value == null) return null;
  if (value is! Map) {
    return null;
  }
  final json = Map<String, dynamic>.from(value);
  final drawOrder = _stringList(json['drawOrder']);
  final bracketSize = json['bracketSize'];
  final rawMatches = json['matches'];
  if (drawOrder == null || bracketSize is! int || rawMatches is! List) {
    return null;
  }
  final matches = <KnockoutMatch>[];
  for (final rawMatch in rawMatches) {
    if (rawMatch is! Map) {
      return null;
    }
    final match = Map<String, dynamic>.from(rawMatch);
    final id = match['id'];
    final round = match['round'];
    final index = match['index'];
    final teamIds = match['teamIds'];
    final winner = match['winnerTeamId'];
    final isBye = match['isBye'];
    final playerIdsByTeam = _playerIdsByTeam(match['playerIdsByTeam']);
    if (id is! String ||
        round is! int ||
        index is! int ||
        teamIds is! List ||
        teamIds.length != 2 ||
        teamIds.any((team) => team != null && team is! String) ||
        winner != null && winner is! String ||
        isBye is! bool ||
        playerIdsByTeam == null) {
      return null;
    }
    matches.add(
      KnockoutMatch(
        id: id,
        round: round,
        index: index,
        teamIds: List<String?>.from(teamIds),
        winnerTeamId: winner,
        isBye: isBye,
        playerIdsByTeam: playerIdsByTeam,
      ),
    );
  }
  if (matches.isEmpty) return null;
  return KnockoutTournament(
    drawOrder: drawOrder,
    bracketSize: bracketSize,
    matches: List.unmodifiable(matches),
  );
}

List<String>? _stringList(Object? value) {
  if (value is! List || value.any((item) => item is! String)) return null;
  return List<String>.from(value);
}

Map<String, List<String>>? _playerIdsByTeam(Object? value) {
  if (value == null) return const {};
  if (value is! Map) return null;
  final playerIdsByTeam = <String, List<String>>{};
  for (final entry in value.entries) {
    if (entry.key is! String) return null;
    final playerIds = _stringList(entry.value);
    if (playerIds == null) return null;
    playerIdsByTeam[entry.key as String] = playerIds;
  }
  return Map.unmodifiable(playerIdsByTeam);
}
