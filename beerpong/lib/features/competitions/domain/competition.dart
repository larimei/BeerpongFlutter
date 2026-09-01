import 'package:flutter/material.dart';

import 'dart:math';

enum TournamentMode {
  knockout('Knockout'),
  roundRobin('Round robin');

  const TournamentMode(this.label);

  final String label;
}

@immutable
class Competition {
  const Competition({
    required this.id,
    required this.name,
    required this.mode,
    required this.color,
    this.teamIds = const [],
    this.tournament,
    this.roundRobinTournament,
  });

  final String id;
  final String name;
  final TournamentMode mode;
  final Color color;
  final List<String> teamIds;
  final KnockoutTournament? tournament;
  final RoundRobinTournament? roundRobinTournament;

  bool get hasConfirmedGames =>
      tournament?.hasConfirmedGames == true ||
      roundRobinTournament?.hasConfirmedGames == true;

  Competition copyWith({
    String? name,
    TournamentMode? mode,
    Color? color,
    List<String>? teamIds,
    KnockoutTournament? tournament,
    RoundRobinTournament? roundRobinTournament,
    bool clearTournament = false,
    bool clearRoundRobinTournament = false,
  }) {
    return Competition(
      id: id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      color: color ?? this.color,
      teamIds: teamIds ?? this.teamIds,
      tournament: clearTournament ? null : tournament ?? this.tournament,
      roundRobinTournament: clearRoundRobinTournament
          ? null
          : roundRobinTournament ?? this.roundRobinTournament,
    );
  }
}

@immutable
class RoundRobinTournament {
  const RoundRobinTournament({required this.drawOrder, required this.matches});

  factory RoundRobinTournament.generate(
    List<String> teamIds, {
    Random? random,
  }) {
    final drawOrder = List<String>.of(teamIds)..shuffle(random);
    final matches = <RoundRobinMatch>[];
    for (var first = 0; first < drawOrder.length; first++) {
      for (var second = first + 1; second < drawOrder.length; second++) {
        matches.add(
          RoundRobinMatch(
            id: 'game-${matches.length}',
            teamIds: [drawOrder[first], drawOrder[second]],
          ),
        );
      }
    }
    return RoundRobinTournament(
      drawOrder: List.unmodifiable(drawOrder),
      matches: List.unmodifiable(matches),
    );
  }

  final List<String> drawOrder;
  final List<RoundRobinMatch> matches;

  bool get hasConfirmedGames =>
      matches.any((match) => match.winnerTeamId != null);

  bool get isComplete => matches.every((match) => match.winnerTeamId != null);

  RoundRobinMatch? get nextMatch {
    for (final match in matches) {
      if (match.winnerTeamId == null) return match;
    }
    return null;
  }

  String? get winnerTeamId => isComplete ? standings.first.teamId : null;

  List<RoundRobinStanding> get standings {
    final wins = {for (final teamId in drawOrder) teamId: 0};
    for (final match in matches) {
      final winner = match.winnerTeamId;
      if (winner != null) wins[winner] = wins[winner]! + 1;
    }
    final groups = <int, List<String>>{};
    for (final teamId in drawOrder) {
      groups.putIfAbsent(wins[teamId]!, () => []).add(teamId);
    }
    final rankedIds = <String>[];
    for (final winCount
        in groups.keys.toList()..sort((a, b) => b.compareTo(a))) {
      final tiedIds = groups[winCount]!;
      final headToHeadWins = {for (final teamId in tiedIds) teamId: 0};
      for (final match in matches) {
        if (tiedIds.contains(match.teamIds.first) &&
            tiedIds.contains(match.teamIds.last) &&
            match.winnerTeamId != null) {
          headToHeadWins[match.winnerTeamId!] =
              headToHeadWins[match.winnerTeamId!]! + 1;
        }
      }
      tiedIds.sort((first, second) {
        final headToHead = headToHeadWins[second]!.compareTo(
          headToHeadWins[first]!,
        );
        if (headToHead != 0) return headToHead;
        return drawOrder.indexOf(first).compareTo(drawOrder.indexOf(second));
      });
      rankedIds.addAll(tiedIds);
    }
    return List.unmodifiable([
      for (final teamId in rankedIds)
        RoundRobinStanding(teamId: teamId, wins: wins[teamId]!),
    ]);
  }

  RoundRobinTournament confirmWinner({
    required String matchId,
    required String winnerTeamId,
    Map<String, List<String>> playerIdsByTeam = const {},
  }) {
    RoundRobinMatch? match;
    for (final candidate in matches) {
      if (candidate.id == matchId) {
        match = candidate;
        break;
      }
    }
    if (match == null ||
        match.winnerTeamId != null ||
        !match.teamIds.contains(winnerTeamId)) {
      return this;
    }
    return RoundRobinTournament(
      drawOrder: drawOrder,
      matches: List.unmodifiable([
        for (final candidate in matches)
          if (candidate.id == matchId)
            candidate.copyWith(
              winnerTeamId: winnerTeamId,
              playerIdsByTeam: _participantPlayers(
                candidate.teamIds,
                playerIdsByTeam,
              ),
            )
          else
            candidate,
      ]),
    );
  }
}

@immutable
class RoundRobinMatch {
  const RoundRobinMatch({
    required this.id,
    required this.teamIds,
    this.winnerTeamId,
    this.playerIdsByTeam = const {},
  });

  final String id;
  final List<String> teamIds;
  final String? winnerTeamId;
  final Map<String, List<String>> playerIdsByTeam;

  RoundRobinMatch copyWith({
    String? winnerTeamId,
    Map<String, List<String>>? playerIdsByTeam,
  }) => RoundRobinMatch(
    id: id,
    teamIds: teamIds,
    winnerTeamId: winnerTeamId ?? this.winnerTeamId,
    playerIdsByTeam: playerIdsByTeam ?? this.playerIdsByTeam,
  );
}

@immutable
class RoundRobinStanding {
  const RoundRobinStanding({required this.teamId, required this.wins});

  final String teamId;
  final int wins;
}

@immutable
class KnockoutTournament {
  const KnockoutTournament({
    required this.drawOrder,
    required this.bracketSize,
    required this.matches,
  });

  factory KnockoutTournament.generate(List<String> teamIds, {Random? random}) {
    final drawOrder = List<String>.of(teamIds)..shuffle(random);
    var bracketSize = 2;
    while (bracketSize < drawOrder.length) {
      bracketSize *= 2;
    }
    final firstRoundMatches = bracketSize ~/ 2;
    final byeCount = bracketSize - drawOrder.length;
    var nextTeam = 0;
    final matches = <KnockoutMatch>[];
    for (var index = 0; index < firstRoundMatches; index++) {
      final hasBye = index < byeCount;
      final firstTeam = drawOrder[nextTeam++];
      final secondTeam = hasBye ? null : drawOrder[nextTeam++];
      matches.add(
        KnockoutMatch(
          id: 'round-0-match-$index',
          round: 0,
          index: index,
          teamIds: [firstTeam, secondTeam],
          winnerTeamId: hasBye ? firstTeam : null,
          isBye: hasBye,
        ),
      );
    }
    for (var round = 1; (bracketSize >> round) >= 1; round++) {
      final count = bracketSize >> (round + 1);
      for (var index = 0; index < count; index++) {
        matches.add(
          KnockoutMatch(
            id: 'round-$round-match-$index',
            round: round,
            index: index,
            teamIds: const [null, null],
          ),
        );
      }
    }
    var tournament = KnockoutTournament(
      drawOrder: List.unmodifiable(drawOrder),
      bracketSize: bracketSize,
      matches: List.unmodifiable(matches),
    );
    for (final match in tournament.matches.where((match) => match.isBye)) {
      tournament = tournament._advance(match);
    }
    return tournament;
  }

  final List<String> drawOrder;
  final int bracketSize;
  final List<KnockoutMatch> matches;

  bool get hasConfirmedGames =>
      matches.any((match) => !match.isBye && match.winnerTeamId != null);

  bool get isComplete => winnerTeamId != null;

  String? get winnerTeamId => matches.last.winnerTeamId;

  KnockoutMatch? matchById(String id) {
    for (final match in matches) {
      if (match.id == id) return match;
    }
    return null;
  }

  KnockoutTournament confirmWinner({
    required String matchId,
    required String winnerTeamId,
    Map<String, List<String>> playerIdsByTeam = const {},
  }) {
    final match = matchById(matchId);
    if (match == null ||
        !match.isPlayable ||
        !match.teamIds.contains(winnerTeamId)) {
      return this;
    }
    final confirmedMatch = match.copyWith(
      winnerTeamId: winnerTeamId,
      playerIdsByTeam: _participantPlayers(
        match.teamIds.whereType<String>(),
        playerIdsByTeam,
      ),
    );
    return _replace(confirmedMatch)._advance(confirmedMatch);
  }

  KnockoutTournament clearOutcomePath(String matchId) {
    final firstMatch = matchById(matchId);
    if (firstMatch == null ||
        firstMatch.winnerTeamId == null ||
        firstMatch.isBye) {
      return this;
    }
    var tournament = this;
    var current = firstMatch.clearOutcome();
    while (true) {
      tournament = tournament._replace(current);
      if (current.round == tournament._lastRound) return tournament;
      final nextRound = current.round + 1;
      final nextIndex = current.index ~/ 2;
      final next = tournament.matches.firstWhere(
        (candidate) =>
            candidate.round == nextRound && candidate.index == nextIndex,
      );
      final slots = List<String?>.of(next.teamIds);
      slots[current.index % 2] = null;
      current = next.copyWith(
        teamIds: slots,
        clearWinnerTeamId: true,
        playerIdsByTeam: const {},
      );
    }
  }

  KnockoutTournament _advance(KnockoutMatch match) {
    if (match.round == _lastRound || match.winnerTeamId == null) return this;
    final nextRound = match.round + 1;
    final nextIndex = match.index ~/ 2;
    final target = matches.firstWhere(
      (candidate) =>
          candidate.round == nextRound && candidate.index == nextIndex,
    );
    final slots = List<String?>.of(target.teamIds);
    slots[match.index % 2] = match.winnerTeamId;
    return _replace(target.copyWith(teamIds: slots));
  }

  int get _lastRound => matches.map((match) => match.round).reduce(max);

  KnockoutTournament _replace(KnockoutMatch replacement) => KnockoutTournament(
    drawOrder: drawOrder,
    bracketSize: bracketSize,
    matches: List.unmodifiable([
      for (final match in matches)
        if (match.id == replacement.id) replacement else match,
    ]),
  );
}

Map<String, List<String>> _participantPlayers(
  Iterable<String> teamIds,
  Map<String, List<String>> playerIdsByTeam,
) => Map.unmodifiable({
  for (final teamId in teamIds)
    teamId: List<String>.unmodifiable(
      playerIdsByTeam[teamId] ?? const <String>[],
    ),
});

@immutable
class KnockoutMatch {
  const KnockoutMatch({
    required this.id,
    required this.round,
    required this.index,
    required this.teamIds,
    this.winnerTeamId,
    this.isBye = false,
    this.playerIdsByTeam = const {},
  });

  final String id;
  final int round;
  final int index;
  final List<String?> teamIds;
  final String? winnerTeamId;
  final bool isBye;
  final Map<String, List<String>> playerIdsByTeam;

  bool get isPlayable =>
      !isBye && winnerTeamId == null && teamIds.every((team) => team != null);

  KnockoutMatch copyWith({
    List<String?>? teamIds,
    String? winnerTeamId,
    Map<String, List<String>>? playerIdsByTeam,
    bool clearWinnerTeamId = false,
  }) => KnockoutMatch(
    id: id,
    round: round,
    index: index,
    teamIds: teamIds ?? this.teamIds,
    winnerTeamId: clearWinnerTeamId ? null : winnerTeamId ?? this.winnerTeamId,
    isBye: isBye,
    playerIdsByTeam: playerIdsByTeam ?? this.playerIdsByTeam,
  );

  KnockoutMatch clearOutcome() =>
      copyWith(clearWinnerTeamId: true, playerIdsByTeam: const {});
}
