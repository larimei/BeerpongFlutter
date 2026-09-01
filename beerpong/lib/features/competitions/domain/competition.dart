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
  });

  final String id;
  final String name;
  final TournamentMode mode;
  final Color color;
  final List<String> teamIds;
  final KnockoutTournament? tournament;

  Competition copyWith({
    String? name,
    TournamentMode? mode,
    Color? color,
    List<String>? teamIds,
    KnockoutTournament? tournament,
    bool clearTournament = false,
  }) {
    return Competition(
      id: id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      color: color ?? this.color,
      teamIds: teamIds ?? this.teamIds,
      tournament: clearTournament ? null : tournament ?? this.tournament,
    );
  }
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
  }) {
    final match = matchById(matchId);
    if (match == null ||
        !match.isPlayable ||
        !match.teamIds.contains(winnerTeamId)) {
      return this;
    }
    return _replace(match.copyWith(winnerTeamId: winnerTeamId))
        ._advance(match.copyWith(winnerTeamId: winnerTeamId));
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

@immutable
class KnockoutMatch {
  const KnockoutMatch({
    required this.id,
    required this.round,
    required this.index,
    required this.teamIds,
    this.winnerTeamId,
    this.isBye = false,
  });

  final String id;
  final int round;
  final int index;
  final List<String?> teamIds;
  final String? winnerTeamId;
  final bool isBye;

  bool get isPlayable =>
      !isBye && winnerTeamId == null && teamIds.every((team) => team != null);

  KnockoutMatch copyWith({List<String?>? teamIds, String? winnerTeamId}) =>
      KnockoutMatch(
        id: id,
        round: round,
        index: index,
        teamIds: teamIds ?? this.teamIds,
        winnerTeamId: winnerTeamId ?? this.winnerTeamId,
        isBye: isBye,
      );
}
