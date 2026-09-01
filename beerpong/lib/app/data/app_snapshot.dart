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
  return Competition(
    id: id,
    name: name,
    mode: tournamentMode,
    color: Color(color),
    teamIds: teamIds,
  );
}

List<String>? _stringList(Object? value) {
  if (value is! List || value.any((item) => item is! String)) return null;
  return List<String>.from(value);
}
